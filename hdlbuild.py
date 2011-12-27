#!/usr/bin/env python
#
# This Python script implements the functionality that is difficult to specify in the Makefile.

import ConfigParser
import glob
import os, os.path
import shutil
import stat
import subprocess
import sys

VERBOSE=False

class HDLBuildException(Exception): pass

def abspath(path):
    "Recursive wrapper for os.path.abspath()."
    if type(path) == list:
        return [abspath(p) for p in path]
    return os.path.abspath(os.path.expandvars(path.strip()))

def build(target):
    "Builds a target."
    if target.endswith('.isim'):
        build_isim(target)

def build_isim(target):
    "Builds an Xilinx ISIM simulator."
    # Remove the .isim suffix to form the module name.
    module = target[:-5]
    # Determine our list of library directories to search for source files. This includes the top-level directory, the
    # *.coregen subdirectories (so generate those first), and all directories listed in the libdirs file.
    with open('libdirs','r') as f:
        libdirs = [abspath(path) for path in f.readlines()]
    coregendirs = [abspath(path) for path in glob.glob('*.coregen')]
    dirs = [abspath('.')] + coregendirs + libdirs
    # Enumerate all Verilog and VHDL source.
    # Enumerate all CoreGen MIF files for initializing RAMs and ROMs.
    verilog_source = []
    vhdl_source = []
    mif_files = []
    for dir in dirs: verilog_source += abspath(glob.glob(dir + '/*.v'))
    for dir in dirs: vhdl_source += abspath(glob.glob(dir + '/*.vhd'))
    for dir in dirs: mif_files += abspath(glob.glob(dir + '/*.mif'))
    # Find and add the testbench source to the correct list.
    testbench_source_verilog = abspath('tb/' + module + '_tb.v')
    testbench_source_vhdl = abspath('tb/' + module + '_tb.vhd')
    if os.path.exists(testbench_source_verilog):
        verilog_source.append(testbench_source_verilog)
    elif os.path.exists(testbench_source_vhdl):
        vhdl_source.append(testbench_source_vhdl)
    else:
        sys.stderr.write('error: could not find testbench source file\n')
        quit(-1)
    # Create the target directory.
    cwd = os.getcwd()
    shutil.rmtree(target)
    os.mkdir(target)
    os.chdir(target)
    # Compile the source.
    for file in verilog_source:
        subprocess.call(['vlogcomp',file])
    for file in vhdl_source:
        subprocess.call(['vhpcomp',file])
    for file in mif_files:
        shutil.copy(file,'.')
    # Copy the ISIM Waveform Configuration file if it exists.
    wcfgfile = abspath('tb/isim/' + module + '.wcfg')
    if os.path.exists(wcfgfile):
        shutil.copy(wcfgfile,'.')
    # Compile the ISIM executable.
    glbl = abspath('$XILINX/verilog/src/glbl.v')
    subprocess.call(['vlogcomp',glbl])
    testbench = module + '_tb'
    subprocess.call(['fuse',testbench,'-L','unisims_ver','-L','unimacros_ver','-L','xilinxcorelib_ver'])
    # Generate helper scripts.
    with open('run.tcl', 'w') as f: f.write('run all')
    with open('interactive_test.bat', 'w') as f: f.write('x.exe -gui -view %s.wcfg -tclbatch run.tcl' % module)
    with open('interactive_test.sh', 'w') as f: f.write('#!/bin/sh\nx -gui -view %s.wcfg -tclbatch run.tcl' % module)
    os.chmod('interactive_test.sh', stat.S_IRWXU | stat.S_IRWXG | stat.S_IROTH | stat.S_IXOTH)
    with open('regression_test.bat', 'w') as f: f.write('x.exe -tclbatch run.tcl')
    with open('regression_test.sh', 'w') as f: f.write('#!/bin/sh\nx -tclbatch run.tcl')
    os.chmod('regression_test.sh', stat.S_IRWXU | stat.S_IRWXG | stat.S_IROTH | stat.S_IXOTH)
    # We are done.
    os.chdir(cwd)

# usage: python hdlbuild.py target1 [target2 [...]]
if __name__=='__main__':
    args = sys.argv[1:]
    if len(args) == 0:
        sys.stderr.write('ERROR: no target specified\n')
        quit()
    for target in args:
        build(target)
