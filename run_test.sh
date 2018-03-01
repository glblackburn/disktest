#!/bin/bash

TEST_DIR="disktest.$$"

DATETIME=`date "+%Y-%m-%d_%H%M%S"`

function usage {
    echo "Usage: $0 [-H <host>] [<path>]"
    echo "Options"
    echo "  -H                      Remote host."
    echo "  -u                      Remote user."
    echo "  -h                      Display this help message."
    echo "  --help                  Display this help message."
#    echo "  --host                  Display this help message."
}

function makeTestDir {
    echo "make ${TEST_PATH}"
    mkdir ${TEST_PATH}
    if [[ ! -e ${TEST_PATH} ]] ; then
	echo "Could not create test path: ${TEST_PATH}"
	exit 1
    fi
    ls -la ${TEST_PATH}
}

function copyScriptToTestDir {
    echo "copy ${TEST_SCRIPT} to ${TEST_PATH}"
    cp ${TEST_SCRIPT} ${TEST_PATH}
    if [[ ! -e ${TEST_PATH}/${TEST_SCRIPT} ]] ; then
	echo "Could not copy test script (${TEST_SCRIPT}) to test path: ${TEST_PATH}"
	exit 3
    fi
    ls -la ${TEST_PATH}
}

function runTest {
    echo "run ${TEST_PATH}/${TEST_SCRIPT}"
    CPATH=`pwd`
    cd ${TEST_PATH}
    ./${TEST_SCRIPT} > ${TEST_LOG}
    ls -la ${TEST_PATH}
    cat ${TEST_LOG}
    cd ${CPATH}
}

function pullLog {
    echo "copy ${TEST_PATH}/${TEST_LOG} to ${LOG_DIR}"
    cp "${TEST_PATH}/${TEST_LOG}" ${LOG_DIR}
    ls -la  ${LOG_DIR}
}

function showLog {
    echo "show ${LOG_DIR}/${TEST_LOG}"
    cat ${LOG_DIR}/${TEST_LOG}
}

function cleanUp {
    echo "delete ${TEST_PATH}"
    rm -r ${TEST_PATH}
    if [[ -e ${TEST_PATH} ]] ; then
	echo "Could not delete test path: ${TEST_PATH}"
	exit 2
    fi
    ls -la ${TEST_PATH}
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
while getopts ":hHu::v" opt; do
#    echo "*** HI! ***"
    case ${opt} in
	u )
	    USER=$OPTARG
	    ;;
	H )
	    HOST=$OPTARG
	    ;;
	v )
#	    echo "*** HI! ***"
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

################################################################################
# validate parameters
################################################################################
if [ ! $DIR ] ; then
    echo "missing path: set to current dir"
    DIR=`pwd`
fi
if [ ! $HOST ] ; then
    echo "missing host: set to local hostname"
    HOST=`hostname`
fi

TEST_PATH="${DIR}/${TEST_DIR}"
TEST_SCRIPT="test_disk_speed.sh"
TEST_LOG="disktest_${HOST}_${DATETIME}.txt"
LOG_DIR="`pwd`/log"

################################################################################
# dump environment vars
################################################################################
if [ "$VERBOSE" = true ] ; then
	echo "HOST=[${HOST}]"
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
