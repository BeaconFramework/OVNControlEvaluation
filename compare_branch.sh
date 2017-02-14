#!/bin/bash

TEST_NAME=hot_
source perf/perf.rc

PLOT_DATA1=$RES_DIR/../plot_data.txt
rm $PLOT_DATA1

echo "branch NB SB ovn-controller" >> $PLOT_DATA1
for i in $(find $1 -name "result.csv"); do
	parentname="$(basename "$(dirname "$i")")"
	echo "in $i $parentname $PLOT_DATA1"
	echo `python perf/plot_line.py $PLOT_DATA1 $i $parentname` >> $PLOT_DATA1
done

gnuplot -e "filename='$PLOT_DATA1'" perf/plot_histogram.plg
mv histogram.png $1