Usage: ./run_test.sh [-H <host>] [<path>]
Options
  -H                      Remote host.
  -u                      Remote user.
  -h                      Display this help message.
  --help                  Display this help message.


Examples:

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
