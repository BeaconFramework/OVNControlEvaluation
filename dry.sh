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

DIR=`dirname $0`
pushd $DIR > /dev/null
cd ..

source perf/perf.rc
assign_net_hosts

for i in `seq $NETS`; do
    hosts=(`get_net_hosts $i`)
    case $i in
        *|*50|*00)
            hosts=(`get_net_hosts $i`)
            echo network $i connections on ${#hosts[*]} hosts: ${hosts[*]}
            ;;
    esac
done

for i in `seq $HOSTS`; do
    nets=(`get_host_nets $i`)
    case $i in
        *|*5|*0)
            nets=(`get_host_nets $i`)
            echo Host $i has ${#nets[*]} networks: ${nets[*]}
            ;;
    esac
done
