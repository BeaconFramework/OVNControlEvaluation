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

TEST_NAME=""
source perf/perf.rc

assign_net_hosts

before=`date +%s%3N`
tot_cnt=0

init_cpu_var

for i in `seq $NETS`; do

    cnt=0

    for host in `get_net_hosts $i`; do
        #echo Creating ports for network $i on host ${host}
		(as hv$host
        for j in `seq $PORTS_PER_NET_PER_HOST`; do

            if [ $PORTS_PER_NET_PER_HOST == 1 ]; then
                vif=${i};
            else
                vif=${i}_${j};
            fi

	        ovs-vsctl add-port br-int vif${vif} -- set Interface vif${vif} external-ids:iface-id=lp${host}_${vif}

            yy=$(printf %02x $(expr $cnt / 256))
            xx=$(printf %02x $(expr $cnt % 256))
            
            ovn-nbctl lsp-add br$i lp${host}_${vif}
            ovn-nbctl lsp-set-addresses lp${host}_${vif} f0:00:00:00:$yy:$xx
        done) &
		
		sleep 0.2
        
        ((cnt++))
        ((tot_cnt++))
    done
    
    if (( $tot_cnt % 10 == 0)); then
		wait
		echo Network $i: $((cnt * PORTS_PER_NET_PER_HOST)) physical "port(s)" created
		record_cpu $((tot_cnt * PORTS_PER_NET_PER_HOST))
	fi

    #case $i in
        #*50|*00) echo Network $i: $((cnt * PORTS_PER_NET_PER_HOST)) physical "port(s)" created; wait ;;
    #esac

done

wait

printf "Wait a while...\n"
sleep 1
for i in 1 2 3; do
    as hv$i ovs-ofctl dump-flows br-int > $RES_DIR/flows$i.txt
    flows=`wc -l $RES_DIR/flows$i.txt | awk '{print $1}'`
    printf "Host $i # flows $flows\n"
done

ovn-sbctl list Logical_Flow > $RES_DIR/lflow.txt

lflows=`wc -l $RES_DIR/lflow.txt | awk '{print $1}'`
lflows=$(((lflows + 1)/9))

printf "Logical flows = $lflows\n"

after=`date +%s%3N`
printf "Elapsed time %'.fms\n" $((after-before))
printf "total of %d (in %'.fms per port)\n" $((tot_cnt)) $(( ((after-before + tot_cnt-1)/tot_cnt) ))
