""" toybox.bin._toybox
"""
import os, json
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
    packages = json.dumps(settings['packages'].keys())
    tmp={}
    tmp['PROVISION_XTRAS'] = packages
    tmp['PROVISION_NEO'] = settings['neo4j'].get('enable', "")
    tmp['PROVISION_XWIN'] = settings['xwindows'].get('enable', "")
    tmp['PROVISION_ELASTICSEARCH']  = settings['elasticsearch'].get("enable","")
    tmp['PROVISION_JAVA'] = tmp['PROVISION_ELASTICSEARCH'] or \
                            tmp['PROVISION_NEO']
    for k,v in tmp.items():
        print k, v
        os.environ[k] = v
    raw_input('\nenter to continue.\n')
    import subprocess
    subprocess.Popen('vagrant provision', env=os.environ.copy())
