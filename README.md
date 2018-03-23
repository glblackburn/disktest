# Try it
./run_test.sh -h
Usage: ./run_test.sh [-hv] [-H <host>] [<path>]
Options
  -H                      Remote host.
  -u                      Remote user.
  -h --help               Display this help message.
  -v                      Verbose output


# Example local run

$ time ./run_test.sh
missing path: set to current dir
missing host: set to local hostname
makeTestDir
copyScriptToTestDir
runTest
pullLog
cleanUp
showLog
Date        : Sat Mar  3 12:16:15 EST 2018
Host        : webwolf.local
Directory   : /Users/lblackb/disktest/disktest.39089
Write speed : 56459193 bytes/sec
Read speed  : 6869924518 bytes/sec
free disk space
Filesystem   Size   Used  Avail Capacity iused      ifree %iused  Mounted on
/dev/disk1  698Gi  569Gi  128Gi    82%  963483 4294003796    0%   /

real    0m19.655s
user    0m0.047s
sys    0m1.160s

# Example remote run

$ time ./run_test.sh -H tardis.local -u lblackb
found -H tardis.local
found -u lblackb
missing path: set to current dir
test connection to remote host
tardis.local
/Users/lblackb
makeTestDir
copyScriptToTestDir
runTest
pullLog
cleanUp
showLog
Date        : Sat Mar  3 12:16:30 EST 2018
Host        : tardis.local
Directory   : /Users/lblackb/disktest/disktest.39298
Write speed : 488102382 bytes/sec
Read speed  : 531443273 bytes/sec
free disk space
Filesystem     Size   Used  Avail Capacity iused               ifree %iused  Mounted on
/dev/disk1s1  214Gi   12Gi  202Gi     6%  426853 9223372036854348954    0%   /

real    0m7.494s
user    0m0.235s
sys    0m0.118s


# Some example log output greped for a summary.

1,2,and 4 are the same local disk in a "MacBook Pro (13-inch, Mid
2012). 3 is a mounted disk on the same MacBook Pro that came out of a
MacMini.  5 is a new SSD drive in a remote MacMini.  The first run was
a weird outlier. I don't beleve on the read speed.  The write speed is
consitent with the other local disk runs..

~~~
$ cat disktest_webwolf.local_2018-03-23_*.txt disktest_tardis.local_2018-03-23*.txt | grep -e "Directory" -e speed -e Host

1.
Host        : webwolf.local
Directory   : /Users/lblackb/disktest/disktest.11305
Write speed : 50509294 bytes/sec
Read speed  : 6808203870 bytes/sec

2.
Host        : webwolf.local
Directory   : /Users/lblackb/disktest/disktest.11422
Write speed : 50342934 bytes/sec
Read speed  : 60185159 bytes/sec

3.
Host        : webwolf.local
Directory   : /Volumes/Macintosh HD 1/disktest.11509
Write speed : 59453770 bytes/sec
Read speed  : 88464812 bytes/sec

4.
Host        : webwolf.local
Directory   : /Users/lblackb/disktest/disktest.11668
Write speed : 38096021 bytes/sec
Read speed  : 73277187 bytes/sec

5.
Host        : tardis.local
Directory   : /Users/lblackb/disktest/disktest.11085
Write speed : 403749613 bytes/sec
Read speed  : 517266288 bytes/sec
~~~