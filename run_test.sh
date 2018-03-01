#!/bin/bash

HOST='localhost'
DIR=`pwd`

DATETIME=`date "+%Y-%m-%d_%H%M%S"`

TEST_DIR="disktest.$$"
TEST_PATH="${DIR}/${TEST_DIR}"
TEST_SCRIPT="test_disk_speed.sh"
LOG_DIR="`pwd`/log"
TEST_LOG="disktest_${HOST}_${DATETIME}.txt"

echo "HOST=[${HOST}]"
echo "DIR=[${DIR}]"
echo "TEST_DIR=[${TEST_DIR}]"


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
    cd ${TEST_PATH}
    ./${TEST_SCRIPT} > ${TEST_LOG}
    ls -la ${TEST_PATH}
    cat ${TEST_LOG}
}

function pullLogs {
    echo "copy ${TEST_PATH}/${TEST_LOG} to ${LOG_DIR}"
    cp "${TEST_PATH}/${TEST_LOG}" ${LOG_DIR}
    ls -la  ${LOG_DIR}
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

makeTestDir
copyScriptToTestDir
runTest
pullLogs
cleanUp
