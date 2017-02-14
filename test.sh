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

echo Creating the sim environment
. perf/init.sh

TEST_NAME=""
source perf/perf.rc

echo "Run $TEST_NAME"
mkdir -p $RES_DIR
rm -f $RES_DIR/*.csv

sleep $COOL_DOWN_PERIOD
record_reference perf initial
cycles=`report_reference perf initial`
cycles=`printf "%'.f\n" $cycles`
echo Initial load was $cycles cycles over $REFERENCE_PERIOD seconds

echo Creating the ports
record_command perf ports_creation perf/create_ports.sh
cycles=`report_command_cpu perf ports_creation $ACTIVE_CPU`
echo Ports created and bound in `printf "%'.f\n" $cycles` cycles

cycles_sb=`report_command_cpu perf ports_creation $SB_CPU`
cycles_nb=`report_command_cpu perf ports_creation $NB_CPU`
cycles_hv=`report_command_cpu perf ports_creation $HV_CPU`
echo $((cycles_sb * 100 / cycles))% south `printf "%'.f\n" $cycles_sb`
echo $((cycles_nb * 100 / cycles))% north `printf "%'.f\n" $cycles_nb`
echo $((cycles_hv * 100 / cycles))% clients `printf "%'.f\n" $cycles_hv`

# let all the components calm down
sleep $COOL_DOWN_PERIOD

record_reference perf final

cycles=`report_reference perf final`
cycles=`printf "%'.f\n" $cycles`
echo Final load was $cycles cycles over $REFERENCE_PERIOD seconds

PORTS=$((HOSTS*PORTS_PER_HOST))

echo "Branch:" `git rev-parse --abbrev-ref HEAD` `git rev-parse HEAD` > $RES_DIR/result.csv
printf "Hosts %d Networks %d ports %d overlap %d\nSB $cycles_sb\nNB $cycles_nb\novn-controller $cycles_hv\n" $HOSTS $NETS $((HOSTS*PORTS_PER_HOST)) $OVERLAP > $RES_DIR/result.csv 

mv *.csv $RES_DIR

gnuplot -e "filename='$RES_DIR/nb_cpu.csv'" perf/plot.plg
mv output.png $RES_DIR/nb_cpu.png
gnuplot -e "filename='$RES_DIR/sb_cpu.csv'" perf/plot.plg
mv output.png $RES_DIR/sb_cpu.png
gnuplot -e "filename='$RES_DIR/host1_cpu.csv'" perf/plot.plg
mv output.png $RES_DIR/host1_cpu.png

popd > /dev/null
