#!/usr/bin/env python
#
# This Python script implements the functionality that is difficult to specify in the Makefile.

import os, os.path
import shutil
import stat
import subprocess
import sys

VERBOSE=False

def isim(target, dependencies):
    for filename in dependencies:
        if filename.endswith('.v'):
            subprocess.call(['vlogcomp','../%s' % filename])
        else:
            shutil.copy('../%s' % filename,'.')
    testbench_name = target + '_tb'
    subprocess.call(['fuse',testbench_name])
    with open('run.tcl', 'w') as f: f.write('run all')
    with open('regression_test.bat', 'w') as f: f.write('x.exe -tclbatch run.tcl')
    with open('regression_test.sh', 'w') as f: f.write('#!/bin/sh\nx -tclbatch run.tcl')
    os.chmod('regression_test.sh', stat.S_IRWXU | stat.S_IRWXG | stat.S_IROTH | stat.S_IXOTH)
    with open('interactive_test.bat', 'w') as f: f.write('x.exe -gui -view %s.wcfg -tclbatch run.tcl' % target)
    with open('interactive_test.sh', 'w') as f: f.write('#!/bin/sh\nx -gui -view %s.wcfg -tclbatch run.tcl' % target)
    os.chmod('interactive_test.sh', stat.S_IRWXU | stat.S_IRWXG | stat.S_IROTH | stat.S_IXOTH)

def toplevel(target, dependencies):
    "Makes a top-level directory."
    try:
        os.mkdir(target)
    except OSError:
        pass
    os.chdir(target)
    # Make the isim target.
    testbench = 'tb/' + target + '_tb.v'
    uut = target + '.v'
    wcfg = 'tb/isim/' + target + '.wcfg'
    isim(target, [testbench, uut, wcfg] + dependencies)

if __name__=='__main__':
    args = sys.argv[1:]
    if len(args) == 0:
        sys.stderr.write('error: no target given\n')
        quit()
    target, dependencies = args[0], args[1:]
    if VERBOSE:
        print('target: %s' % target)
        print('dependencies: %s' % dependencies)
    # Does the target exist? make should catch this
    if os.path.exists(target):
        sys.stderr.write('error: target exists: %s\n' % target)
        quit()
    # Dispatch
    # The "all" target is phony and should not be built
    if target == 'all':
        quit()
    elif '.' not in target:
        toplevel(target, dependencies)
    else:
        sys.stderr.write('error: unsupported target: %s\n' % target)
