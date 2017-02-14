#!/bin/bash -f

source perf/perf.rc

assign_net_hosts

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

        done) &

        ((cnt++))

    done

    case $i in
        *50|*00) echo Network $i: $((cnt * PORTS_PER_NET_PER_HOST)) physical "port(s)" created; wait ;;
    esac

done

wait

cnt=1

before=`date +%s%3N`
echo -n 'Creating & binding logical ports...'
for i in `seq $NETS`; do

    for host in `get_net_hosts $i`; do

        for j in `seq $PORTS_PER_NET_PER_HOST`; do

            if [ $PORTS_PER_NET_PER_HOST == 1 ]; then
                vif=${i};
            else
                vif=${i}_${j};
            fi

            yy=$(printf %02x $(expr $cnt / 256))
            xx=$(printf %02x $(expr $cnt % 256))

            ovn-nbctl lport-add br$i lp${host}_${vif}
            ovn-nbctl lport-set-addresses lp${host}_${vif} f0:00:00:00:$yy:$xx

            ((cnt++))

        done

    done

done
after=`date +%s%3N`
((cnt--))
printf "total of %d (in %'.fms per port)\n" $((cnt)) $(( ((after-before + cnt-1)/cnt) ))
