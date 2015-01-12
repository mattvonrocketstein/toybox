""" toybox.bin._toybox
"""
import os, json
import subprocess

from toybox import util
from toybox.settings import Settings

INSTRUCTIONS = 'provision up'.split()

def entry():
    """ entry point from commandline """
    settings = Settings()
    opts, clargs = settings.get_parser().parse_args()

    opts.up = False
    opts.provision = False

    # handle clargs
    if clargs:
        if len(clargs) != 1:
            raise SystemExit((
                "\nonly know how to parse one command "
                "line argument.  try using one of: {0}").format(INSTRUCTIONS))
        cmd = clargs.pop().strip()
        if cmd=='provision':
            opts.provision=True

    print opts,clargs
    for k in settings.keys():
        tmp=k
        #print k,dict(settings[k])


    # put arguments from .ini into os.environ before vagrant is
    # called.  vagrant will then put these into the puppet facter
    tmp = {}

    # compute json for main package list
    tmp['PROVISION_XTRAS'] = json.dumps(settings['packages'].keys())

    # compute json for package list which is only installed if xwin is
    xwin_pkgs = settings['xwindows'].get('packages','').split(',')
    xwin_pkgs = [x for x in xwin_pkgs if x]
    xwin_pkgs = json.dumps(xwin_pkgs)
    tmp['PROVISION_XWIN_EXTRA'] = xwin_pkgs

    # transfer settings re: rabbit, mongo, xwin
    tmp['PROVISION_XWIN']   = settings['xwindows'].get('enable', '')
    tmp['PROVISION_RABBIT'] = settings['rabbitmq'].get('enable', '')
    tmp['PROVISION_MONGO']  = settings['mongodb'].get('enable', '')

    # transfer settings re: neo4j, elasticsearch
    tmp['PROVISION_NEO'] = settings['neo4j'].get('enable', "")
    tmp['PROVISION_ELASTICSEARCH']  = settings['elasticsearch'].get("enable","")

    # whether java is needed is specified implicitly via the ini-file:
    # java is installed if neo or elasticsearch are installed
    tmp['PROVISION_JAVA'] = tmp['PROVISION_ELASTICSEARCH'] or \
                            tmp['PROVISION_NEO']


    for k,v in tmp.items():
        v = v and v not in [0, '0','false','False','no']
        if not v:
            continue
        print k, v
        os.environ[k] = str(v)

    if opts.provision:
        raw_input('\nenter to continue.\n')
        subprocess.call('vagrant provision', shell=True, env=os.environ.copy())
    elif opts.render:
        util.render()
