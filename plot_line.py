#!/bin/python

import sys

data_file = open(sys.argv[2], 'r')

data = {}

for line_number, line in enumerate(data_file, 1):
	if line_number == 1:
		continue

	line = line.split(" ")
	data[line[0]] = line[1].rstrip()

print "%s %s %s %s" % (sys.argv[3], data['NB'], data['SB'], data['ovn-controller'])
