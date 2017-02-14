#!/bin/bash -f
###########################################################################
#   Copyright 2016 IBM Corp.
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
############################################################################

source perf/perf.rc

# start OVN
ovn_start

# Move our proc to shield
#cset shield --force --shield `cat sandbox/ovn-nb/ovsdb-server.pid`
#cset shield --force --shield `cat sandbox/ovn-sb/ovsdb-server.pid`

# if database process CPU pinning defined, do it
[ $NB_CPU ] && pin sandbox/ovn-nb/ovsdb-server.pid $NB_CPU
[ $SB_CPU ] && pin sandbox/ovn-sb/ovsdb-server.pid $SB_CPU

# create management network
net_add n1

# create logical networks
for i in `seq $NETS`; do
   ovn-nbctl ls-add br$i
done

# create and connect simulated hypervisors
for i in `seq $HOSTS`; do
   (sim_add hv$i

   as hv$i
   ovs-vsctl add-br br-phys
   y=$(expr $i / 256)
   x=$(expr $i % 256)
   ovn_attach n1 br-phys 192.168.$y.$x

   # if hypervisor processes CPU pinning defined, do it
   if [ $HV_CPU ]; then
      for pid in `find sandbox/hv$i -name *pid`; do
          #cset shield --force --shield `cat $pid`
          [ $HV_CPU ] && pin $pid $HV_CPU
      done
   fi ) &

   case $i in
       *5|*0) echo Inited hypervisor $i; wait ;;
   esac
done

wait

## let all the components calm down
#sleep 3
