""" toybox.bin._toybox
"""
import os, json
import subprocess
from functools import partial

from toybox import util
from toybox.data import DEFAULTS, PUPPET
from toybox.settings import Settings

INSTRUCTIONS = 'halt provision up'.split()

system = lambda x: subprocess.call(x, shell=True, env=os.environ.copy())
vagrant_instructions = ['provision', 'up']
puppet_instructions = ['apply']
apply_cmd = ('sudo puppet apply --verbose '
             '--logdest=/var/log/puppet/provision.log '
             '--modulepath={0}/modules'
             ' {0}/default.pp').format(PUPPET)

def entry():
    """ entry point from commandline """
    settings = Settings()
    opts, clargs = settings.get_parser().parse_args()

    for i in vagrant_instructions + puppet_instructions:
        setattr(opts, i, False)

    # handle clargs
    if clargs:
        if len(clargs) != 1:
            raise SystemExit((
                "\nonly know how to parse one command "
                "line argument.  try using one of: {0}").format(INSTRUCTIONS))
        cmd = clargs.pop().strip()
        if cmd in vagrant_instructions + puppet_instructions:
            setattr(opts, cmd, True)

    print 'opts:', opts,'\nargs',clargs
    for k in settings.keys():
        tmp=k
        #print k,dict(settings[k])

    # deduce the puppet facts from toybox.ini
    facts = get_fact_env(settings)

    # compute the port map implied by toybox.ini
    port_map = DEFAULTS.copy()
    port_map.update(get_portmap(facts, settings))
    facts.update(TOYBOX_PORTMAP=json.dumps(port_map))

    # update environment with the facts
    set_fact_env(facts)

    if opts.provision:
        raw_input('\nenter to continue.\n')
        system('vagrant provision')
    elif opts.apply:
        system(apply_cmd)
    elif opts.up:
        raw_input('\nenter to continue.\n')
        system('vagrant up')
    elif opts.test:
        cmd_t = 'TOYBOX_HOST={0} py.test -v {1}tests/'
        cmd = cmd_t.format('localhost','')
        system(cmd)
    elif opts.ports:
        print 'ports'
        for k,v in port_map.items():
            print k,v
    elif opts.render:
        util.render()

def test_setting(settings, k):
    """ TODO: move into goulash
        this function returns True for 'true', False for
        `false` or 'no', any other strings are passed through
    """
    k = k.split('.')
    tmp = settings
    while k:
        subsection = k.pop(0)
        try:
            tmp = tmp[subsection]
        except KeyError:
            print 'no key {0} found in {1}'.format(subsection,dict(tmp))
            return

    if isinstance(tmp, basestring):
        test = tmp not in ['0', 'false', 'no', 0]
        if not test: return test
    return tmp

def set_fact_env(tmp):
    for k,v in tmp.items():
        if v and v not in [0,'0','false']:
            print k, v
            os.environ[k] = v

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
    """ put arguments from .ini into os.environ before vagrant is
        called.  vagrant will then put these into the puppet facter
    """
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
