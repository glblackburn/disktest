#!/bin/bash

#
# monitor run
# while (true) ; do find . -type d -name "disktest*" -exec ls -ld {} \; ; sleep 1 ; done
#
TEST_DIR="disktest.$$"

DATETIME=`date "+%Y-%m-%d_%H%M%S"`

#getops check :hH:u:v
#--help does not really work, need to research
function usage {
    echo "Usage: $0 [-hv] [-H <host>] [<path>]"
    echo "Options"
    echo "  -H                      Remote host."
    echo "  -u                      Remote user."
    echo "  -h --help               Display this help message."
    echo "  -v                      Verbose output"
}

function runCommand {
    cmd=$1
    if [ $IS_LOCAL ] ; then	
	if [ "$VERBOSE" = true ] ; then
	    echo "run local cmd=[${cmd}]"
	fi
	eval ${cmd}
    else
	if [ "$VERBOSE" = true ] ; then
	    echo "ssh ${REMOTE_USER}@${REMOTE_HOST} \"$cmd\""
	fi
	ssh ${REMOTE_USER}@${REMOTE_HOST} "$cmd"
    fi
}

function testStat {
    if [ $IS_LOCAL ] ; then
	stat "${TEST_PATH}" > /dev/null 2>&1
    else
	runCommand "stat '${TEST_PATH}' > /dev/null 2>&1"
    fi
}

function makeTestDir {
    echo "makeTestDir"
    runCommand "mkdir '${TEST_PATH}'"

    if ! testStat "${TEST_PATH}" ; then
	echo "Could not create test path: ${TEST_PATH}"
	exit 11
    fi
    if [ "$VERBOSE" = true ] ; then
	runCommand "hostname"
	runCommand "ls -la '${TEST_PATH}'"
    fi
}

function copyScriptToTestDir {
    echo "copyScriptToTestDir"
    if [ $IS_LOCAL ] ; then
	cp ${TEST_SCRIPT} "${TEST_PATH}"
    else
	scp -q ${TEST_SCRIPT} "${REMOTE_USER}@${REMOTE_HOST}:${TEST_PATH}"
    fi
    if ! testStat "${TEST_PATH}/${TEST_SCRIPT}" ; then
	echo "Could not copy test script (${TEST_SCRIPT}) to test path: ${TEST_PATH}"
	exit 20
    fi
    if [ "$VERBOSE" = true ] ; then
	runCommand "ls -la '${TEST_PATH}'"
    fi
}

function runTest {
    echo "runTest"
    
    if [ $IS_LOCAL ] ; then
	CPATH=`pwd`
	cd "${TEST_PATH}"
	"./${TEST_SCRIPT}" > ${TEST_LOG}
	cd ${CPATH}
	if [ "$VERBOSE" = true ] ; then
	    ls -la "${TEST_PATH}"
	    cat "${TEST_PATH}/${TEST_LOG}"
	fi
    else
    	runCommand "cd '${TEST_PATH}' && './${TEST_SCRIPT}' > '${TEST_LOG}'"
	if [ "$VERBOSE" = true ] ; then
	    runCommand "ls -la '${TEST_PATH}'"
	    runCommand "cat '${TEST_PATH}/${TEST_LOG}'"
	fi
    fi
}

function pullLog {
    echo "pullLog"
    mkdir -p ${LOG_DIR}
    if [[ ! -d ${LOG_DIR} ]] ; then
	echo "Log dir does not exist: ${LOG_DIR}"
	exit 30
    fi

    if [ $IS_LOCAL ] ; then
	cp "${TEST_PATH}/${TEST_LOG}" ${LOG_DIR}
    else
	scp -q "${REMOTE_USER}@${REMOTE_HOST}:${TEST_PATH}/${TEST_LOG}" ${LOG_DIR}
    fi
    if [ "$VERBOSE" = true ] ; then
	ls -la  ${LOG_DIR}
    fi
}

function showLog {
    echo "showLog"
    cat ${LOG_DIR}/${TEST_LOG}
}

function cleanUp {
    echo "cleanUp"
    runCommand "rm -r '${TEST_PATH}'"
    if testStat "${TEST_PATH}" ; then
	echo "Could not delete test path: ${TEST_PATH}"
	exit 41
    fi
    if [ "$VERBOSE" = true ] ; then
	runCommand "hostname"
	runCommand "ls -la '${TEST_PATH}'"
    fi
}

################################################################################
# unit tests (need to pick a framwork and turn these into real tests
# https://stackoverflow.com/questions/1339416/unit-testing-bash-scripts
# https://github.com/bats-core
# while (true) ; do date ; find tmp -type f -exec ls -l {} \; ; sleep 1 ; done
################################################################################
# test makeTestDir detects could not create test path
################################################################################
#echo "test makeTestDir should exit 1"
#DIR="test"
#TEST_DIR="disktest.9336"
#TEST_PATH="${DIR}/${TEST_DIR}"
#mkdir -p ${DIR}
#chmod 555 ${DIR}
#trap 'chmod 755 ${DIR} && rm -rf ${DIR}' EXIT
#makeTestDir
################################################################################
# test copyScriptToTestDir detects could not copy test script
################################################################################
#echo "test copyScriptToTestDir should exit 3"
#DIR="test"
#TEST_DIR="disktest.9336"
#mkdir -p ${DIR}/${TEST_DIR}
#chmod 555 ${DIR}/${TEST_DIR}
#trap 'chmod 755 ${DIR}/${TEST_DIR} && rm -rf ${DIR}' EXIT
#copyScriptToTestDir
################################################################################


################################################################################
# get command line options
################################################################################
VERBOSE=false
while getopts ":hH:u:v" opt; do
    case ${opt} in
	u )
	    REMOTE_USER=$OPTARG
	    echo "found -u $OPTARG"
	    ;;
	H )
	    REMOTE_HOST=$OPTARG
	    echo "found -H $OPTARG"
	    ;;
	u )
	    REMOTE_USER=$OPTARG
	    ;;
	v )
	    VERBOSE=true
	    ;;
	h )
	    usage
	    exit 0
	    ;;
	\? )
	    echo "Invalid Option: -$OPTARG" 1>&2
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND -1))
DIR=$1

LOCAL_HOST=`hostname`

################################################################################
# validate parameters
################################################################################
if [ ! "$DIR" ] ; then
    echo "missing path: set to current dir"
    DIR=`pwd`
fi
if [ ! $REMOTE_HOST ] ; then
    echo "missing host: set to local hostname"
    REMOTE_HOST=$LOCAL_HOST
else
    if [ ! $REMOTE_USER ] ; then
	echo "missing user"
	usage
	exit 2
    else
	echo "test connection to remote host"
	if ! ssh "${REMOTE_USER}@${REMOTE_HOST}" 'hostname ; pwd' ; then
	    echo "trouble connecting to remote host: ${REMOTE_USER}@${REMOTE_HOST}"
	    exit 3
	fi
    fi
fi

if [ $LOCAL_HOST = $REMOTE_HOST ] ; then
    IS_LOCAL=true
fi

TEST_PATH="${DIR}/${TEST_DIR}"
TEST_SCRIPT="test_disk_speed.sh"
TEST_LOG="disktest_${REMOTE_HOST}_${DATETIME}.txt"
LOG_DIR="`pwd`/log"

################################################################################
# dump environment vars
################################################################################
if [ "$VERBOSE" = true ] ; then
    echo "IS_LOCAL=[$IS_LOCAL]"
    echo "LOCAL_HOST=[$LOCAL_HOST]"
    echo "REMOTE_HOST=[${REMOTE_HOST}]"
    echo "REMOTE_USER=[${REMOTE_USER}]"
    echo "DIR=[${DIR}]"
    echo "TEST_DIR=[${TEST_DIR}]"
    echo "TEST_PATH=[${TEST_PATH}]"
    echo "TEST_SCRIPT=[${TEST_SCRIPT}]"
    echo "TEST_LOG=[${TEST_LOG}]"
    echo "LOG_DIR=[${TEST_DIR}]"
fi
################################################################################
# main code
################################################################################
makeTestDir
copyScriptToTestDir
runTest
pullLog
cleanUp
showLog
