#!/bin/bash

echo `pwd`
echo "Plot $1"
gnuplot -e "filename='$1'" perf/plot.plg
