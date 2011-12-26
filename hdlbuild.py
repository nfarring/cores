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

def build(module):
    "Builds all of the outputs that we know how to build."
    # Search for dependencies.
    dependencies = find_dependencies(module)
    # Get extra dependencies from the configuration file.
    if config.has_option(module,'dependencies'):
        value = config.get(module,'dependencies')
        if value != '': dependencies += value.split(',')
    # Make a directory for the module and change into it.
    os.chdir('build')
    os.mkdir(module)
    os.chdir(module)
    # Process each file.
    for file in dependencies:
        relpath = '../../' + file
        if file.endswith('.v'):
            xilinx_vlogcomp(relpath)
        elif file.endswith('.vhd'):
            xilinx_vhpcomp(relpath)
        elif file.endswith('.xco'):
            xilinx_coregen(relpath)
        else: shutil.copy(relpath,'.')
    # Do we need to build Xilinx ISIM?
    if os.path.exists('isim'):
        xilinx_fuse(module)
        xilinx_isim_scripts(module)

def find_dependencies(module):
    "Returns a list of dependencies for a given module."
    dependencies = []
    def add_if_exists(file):
        if os.path.exists(file):
            dependencies.append(file)
    add_if_exists(module + '.v')
    add_if_exists(module + '.vhd')
    add_if_exists('tb/' + module + '_tb.v')
    add_if_exists('tb/' + module + '_tb.vhd')
    add_if_exists('tb/isim/' + module + '.wcfg')
    add_if_exists(module + '.xco')
    return dependencies

def find_modules():
    "Returns a list of modules by looking at the files in the current directory."
    files = []
    for ext in ('.v','.vhd','.xco'):
        files += glob.glob('*' + ext)
    def stripext(file): return file.partition('.')[0]
    modules = [stripext(file) for file in files]
    return modules

def xilinx_coregen(module, file):
    "Xilinx"
    pass

def xilinx_fuse(module):
    "Generates Xilinx ISIM executable."
    testbench = module + '_tb'
    subprocess.call(['fuse',testbench])

def xilinx_isim_scripts(module):
    "Generates helper scripts for Xilinx ISIM."
    with open('run.tcl', 'w') as f: f.write('run all')
    with open('interactive_test.bat', 'w') as f: f.write('x.exe -gui -view %s.wcfg -tclbatch run.tcl' % module)
    with open('interactive_test.sh', 'w') as f: f.write('#!/bin/sh\nx -gui -view %s.wcfg -tclbatch run.tcl' % module)
    os.chmod('interactive_test.sh', stat.S_IRWXU | stat.S_IRWXG | stat.S_IROTH | stat.S_IXOTH)
    with open('regression_test.bat', 'w') as f: f.write('x.exe -tclbatch run.tcl')
    with open('regression_test.sh', 'w') as f: f.write('#!/bin/sh\nx -tclbatch run.tcl')
    os.chmod('regression_test.sh', stat.S_IRWXU | stat.S_IRWXG | stat.S_IROTH | stat.S_IXOTH)

def xilinx_vlogcomp(file):
    "Xilinx Verilog compiler for ISIM."
    subprocess.call(['vlogcomp',file])

def xilinx_vhpcomp(file):
    "Xilinx VHDL compiler for ISIM."
    subprocess.call(['vhpcomp',file])

if __name__=='__main__':
    global config
    # Try to read an hdlbuild.ini configuration file.
    config = ConfigParser.ConfigParser()
    configFiles = config.read(['hdlbuild.ini'])
    if len(configFiles) == 0:
        print('WARNING: could not find hdlbuild.ini; using defaults')
    elif VERBOSE:
        print('parsing config file hdlbuild.ini')
    # See if modules were given explicitly as arguments.
    # If not then find modules by examining the HDL files.
    modules = sys.argv[1:]
    if len(modules) == 0:
        modules = find_modules()
    # Create the build directory if it does not exist.
    if not os.path.exists('build'):
        os.mkdir('build')
    # Build each module.
    # Skip modules that already exist.
    # TODO: Add a --force flag to force the rebuilding of an existing module.
    cwd = os.getcwd()
    for module in modules:
        if not os.path.exists('build/' + module):
            os.chdir(cwd)
            build(module)
