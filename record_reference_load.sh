#!/bin/bash -f

. ../perf/perf.rc

pushd $1
sudo perf record -o perf.data.reference.${2} -a -- /bin/sleep 3
