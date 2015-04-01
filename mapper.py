#!/usr/bin/env python

import sys


line_list = sys.stdin
for line in line_list:
    line = line.strip()
    word_list = line.split()
    for word in word_list:
        print '{:s}\t{:d}'.format(word, 1)
