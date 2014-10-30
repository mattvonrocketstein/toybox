#!/usr/bin/env python
""" toybox.scripts.render_index

    this takes the main toybox/README.md file and creates
    toybox/index.html in a way that's github compatable.

    NOTE: the first time you run this script, grip has
    to cache a bunch of resources and it takes a long
    time.  subsequent runs are much faster.
"""

import os
from grip import export

def main():
    script_dir = os.path.dirname(__file__)
    toybox_dir = os.path.split(script_dir)[0]
    readme_f= os.path.join(toybox_dir, 'README.md')
    index_f = os.path.join(toybox_dir, 'index.html')
    assert os.path.exists(readme_f)
    export(readme_f, out_filename=index_f)
    print 'done.'

if __name__=='__main__':
    main()
