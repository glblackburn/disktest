#!/bin/bash

#
# This script run as disk speed test in the current directory.
#
DIR=`pwd`
TEST_FILE='tstfile'
if [ -e "${TEST_FILE}" ] ; then
    echo "delete found test file [${TEST_FILE}]"
    ls -l ${TEST_FILE}
    rm ${TEST_FILE}
fi

TMP_FILE='tstfile.out'
dd if=/dev/zero bs=1024k of=${TEST_FILE} count=1024 2> ${TMP_FILE}
write_speed=`cat ${TMP_FILE} | grep "bytes/sec"| sed "s/^.*(\([0-9]* bytes\/sec\))$/\1/"`

dd if=${TEST_FILE} bs=1024k of=/dev/null count=1024 2> ${TMP_FILE}
read_speed=`cat ${TMP_FILE} | grep "bytes/sec"| sed "s/^.*(\([0-9]* bytes\/sec\))$/\1/"`

rm ${TEST_FILE}
rm ${TMP_FILE}

echo "Date        : `date`"
echo "Host        : ${HOSTNAME}"
echo "Directory   : ${DIR}"
echo "Write speed : $write_speed"
echo "Read speed  : $read_speed"

