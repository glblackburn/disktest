#!/bin/bash

find log/* -type d | while read dir ; do
echo "$dir"
    write_speed=`cat ${dir}/write.txt | grep "bytes/sec"| sed "s/^.*(\([0-9]* bytes\/sec\))$/\1/"`
    read_speed=`cat ${dir}/read.txt | grep "bytes/sec"| sed "s/^.*(\([0-9]* bytes\/sec\))$/\1/"`

    echo "Write speed : $write_speed"
    echo "Read speed  : $read_speed"
done

exit

write_speed=`cat macmini/write.txt | grep "bytes/sec"| sed "s/^.*(\([0-9]* bytes\/sec\))$/\1/"`
read_speed=`cat macmini/read.txt | grep "bytes/sec"| sed "s/^.*(\([0-9]* bytes\/sec\))$/\1/"`
echo "Mac Mini"
echo "Write speed : $write_speed"
echo "Read speed  : $read_speed"



