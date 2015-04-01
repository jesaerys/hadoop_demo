#!/usr/bin/env python

from operator import itemgetter
import sys


CURRENT_WORD = None
CURRENT_COUNT = 0
WORD = None


line_list = sys.stdin
for line in line_list:
    line = line.strip()

    # Parse the output from mapper.py
    WORD, count = line.split('\t', 1)
    try:
        count = int(count)
    except ValueError:
        continue  # Not a number; ignore this line

    # Hadoop output is sorted by key (i.e., WORD)
    if CURRENT_WORD == WORD:
        CURRENT_COUNT += count
    else:
        if CURRENT_WORD is not None:
            print '{:s}\t{:d}'.format(CURRENT_WORD, CURRENT_COUNT)
        CURRENT_COUNT = count
        CURRENT_WORD = WORD

if CURRENT_WORD == WORD:
    print '{:s}\t{:d}'.format(CURRENT_WORD, CURRENT_COUNT)
