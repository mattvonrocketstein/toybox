""" toybox.util
"""

import os

from grip import export

def render():
    this_dir = os.path.dirname(__file__)
    while 'Vagrantfile' not in os.listdir(this_dir):
        this_dir = os.path.dirname(this_dir)
    toybox_dir = this_dir#os.path.split(script_dir)[0]
    site_dir = os.path.join(toybox_dir, 'puppet', 'modules', 'site')
    www_files = os.path.join(site_dir, 'files', 'www')
    readme_f = os.path.join(toybox_dir, 'README.md')
    index_f = os.path.join(www_files, 'index.html')
    assert os.path.exists(site_dir)
    assert os.path.exists(readme_f)
    export(readme_f, out_filename=index_f)
    print 'done.'
