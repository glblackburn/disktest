#!/bin/bash

TEST_FILE='tstfile'
if [ -e "${TEST_FILE}" ] ; then
    echo "delete found test file [${TEST_FILE}]"
    ls -l ${TEST_FILE}
    rm ${TEST_FILE}
fi

dd if=/dev/zero bs=1024k of=${TEST_FILE} count=1024 2> write.txt
write_speed=`cat write.txt | grep "bytes/sec"| sed "s/^.*(\([0-9]* bytes\/sec\))$/\1/"`

dd if=${TEST_FILE} bs=1024k of=/dev/null count=1024 2> read.txt
read_speed=`cat read.txt | grep "bytes/sec"| sed "s/^.*(\([0-9]* bytes\/sec\))$/\1/"`

rm ${TEST_FILE}

echo "Write speed : $write_speed"
echo "Read speed  : $read_speed"



