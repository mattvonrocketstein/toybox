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
    opts.up = False

    # handle clargs
    if clargs:
        if len(clargs) != 1:
            raise SystemExit((
                "\nonly know how to parse one command "
                "line argument.  try using one of: {0}").format(INSTRUCTIONS))
        cmd = clargs.pop().strip()
        if cmd in ['provision', 'up']:
            setattr(opts, cmd, True)

    print 'opts:',opts
    print 'args:',clargs
    for k in settings.keys():
        tmp=k
        #print k,dict(settings[k])

    facts = get_fact_env(settings)
    port_map = DEFAULTS.copy()
    port_map.update(get_portmap(facts, settings))
    facts.update(TOYBOX_PORTMAP=json.dumps(port_map))
    set_fact_env(facts)
    if opts.provision:
        raw_input('\nenter to continue.\n')
        subprocess.call('vagrant provision', shell=True, env=os.environ.copy())
    if opts.up:
        raw_input('\nenter to continue.\n')
        subprocess.call('vagrant up', shell=True, env=os.environ.copy())
    elif opts.ports:
        print 'ports'
        for k,v in port_map.items():
            print k,v
    elif opts.render:
        util.render()

def test_setting(settings, k):
    """ returns True for 'true', False for `false` or 'no',
        any other strings are passed through """
    k = k.split('.')
    tmp = settings
    while k:
        subsection = k.pop(0)
        try:
            tmp = tmp[subsection]
        except KeyError:
            print 'no key {0} found in {1}'.format(subsection,dict(tmp))

    if isinstance(tmp, basestring):
        test = tmp not in ['0', 'false', 'no', 0]
        if not test: return test
    return tmp

def set_fact_env(tmp):
    for k,v in tmp.items():
        if v and v not in [0,'0','false']:
            print k, v
            os.environ[k] = v

DEFAULTS = {
        'ssh':[22,8022],
        'nginx':[8080, 8081],
        'kibana':[8080, 8081],
        'rabbit':[15672, 15672], # this entry is for the rabbitmq WUI
        'flower':[5555, 5555],
        'genghis':[5556, 5556],
        'supervisor':[9001, 9001],
        'elasticsearch':[9200, 9200],
        'neo':[7474, 7474]
        }

from functools import partial

def get_portmap(facts, settings):
    out={}
    test = partial(test_setting, settings)
    if test('mongodb.enable') \
       and test('mongodb.genghis'):
        x = test('mongodb.genghis_port')
        if x:
            out['genghis'] = [x, x]
    return out
    #    and settings['mongo'].get('genghis')
    #    return settings['mongo'].get('genghis_port',)

def get_fact_env(settings):
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
    if tmp['PROVISION_MONGO']:
        tmp['PROVISION_GENGHIS'] = settings['mongodb'].get('genghis', "")

    # transfer settings re: neo4j, elasticsearch
    tmp['PROVISION_NEO'] = settings['neo4j'].get('enable', "")
    tmp['PROVISION_ELASTICSEARCH']  = settings['elasticsearch'].get("enable","")

    # whether java is needed is specified implicitly via the ini-file:
    # java is installed if neo or elasticsearch are installed
    tmp['PROVISION_JAVA'] = tmp['PROVISION_ELASTICSEARCH'] or \
                            tmp['PROVISION_NEO']
    return tmp
