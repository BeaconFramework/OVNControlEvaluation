#!/bin/bash
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

TEST_NAME=hot_
source perf/perf.rc

nhosts=$(( (HOSTS * OVERLAP + 99)/100 ))
nhosts=$((nhosts < 1 ? 1 : nhosts))

before=`date +%s%3N`

init_cpu_var

for port in `seq $HOT_PORTS`; do
    net=$((port%NETS + 1))
    host=$((port%nhosts + 1))
    
    (as hv$host
        
    vif=${port};
        
	ovs-vsctl add-port br-int hot-vif${vif} -- set Interface hot-vif${vif} external-ids:iface-id=hot-lp${host}_${vif}

    yy=$(printf %02x $(expr $port / 256))
    xx=$(printf %02x $(expr $port % 256))
            
    ovn-nbctl lsp-add br$net hot-lp${host}_${vif}
    ovn-nbctl lsp-set-addresses hot-lp${host}_${vif} f0:00:00:00:$yy:$xx
    ) &
		
	sleep 0.2
        
    if (( $port % 10 == 0)); then
		wait
		echo "$port ports created"
		record_cpu $((port))
	fi
done

wait

after=`date +%s%3N`
printf "Elapsed time %'.fms\n" $(( after-before ))
printf "total of %d (in %'.fms per port)\n" $(( port )) $(( after-before/port ))
