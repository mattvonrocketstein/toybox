""" toybox.bin._toybox
"""
import os, json
import subprocess
from toybox.settings import Settings

def entry():
    """ entry point from commandline """
    settings = Settings()
    opts, clargs = settings.get_parser().parse_args()
    action, args, kargs = None, tuple(), dict()
    #settings.quiet = opts.quiet
    if clargs:
        assert len(clargs)==1, 'only know how to parse one clarg'
        path = abspath(clargs.pop())
    else:
        path = None
    print opts,clargs
    for k in settings.keys():
        tmp=k
        #print k,dict(settings[k])

    pkgs = json.dumps(settings['packages'].keys())

    xwin_pkgs = json.dumps(
        [x for x in settings['xwindows'].get('packages','').split(',') if x])

    tmp={}
    tmp['PROVISION_XTRAS'] = pkgs
    tmp['PROVISION_NEO'] = settings['neo4j'].get('enable', "")
    tmp['PROVISION_XWIN'] = settings['xwindows'].get('enable', "")
    tmp['PROVISION_ELASTICSEARCH']  = settings['elasticsearch'].get("enable","")
    tmp['PROVISION_RABBIT']  = settings['rabbitmq'].get("enable","")
    tmp['PROVISION_MONGO']  = settings['mongodb'].get("enable", "")
    tmp['PROVISION_JAVA'] = tmp['PROVISION_ELASTICSEARCH'] or \
                            tmp['PROVISION_NEO']
    tmp['PROVISION_XWIN_EXTRA'] = xwin_pkgs
    for k,v in tmp.items():
        print k, v
        if v and v not in [0,'0','false']:
            os.environ[k] = v
    raw_input('\nenter to continue.\n')
    subprocess.call('vagrant provision', shell=True, env=os.environ.copy())
