#!/usr/bin/env python

# Generates stimulus and response files for spi_master_model.

import random

WIDTH=32

def printRandomWords(N):
    for i in range(N):
        word = random.randint(0x00000000,0xFFFFFFFF)
        print('%08x' % word)

if __name__=='__main__':
    printRandomWords(100)
