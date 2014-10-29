#!/usr/bin/env python
""" toybox.tests.render_index

    not really a test, but there's justnot a better place
    to put toybox devtools currently.  this takes the
    toybox/README.md file and creates toybox/index.html
    in a way that's github compatable.
"""

import os
#from grip.github_renderer import render_content
from grip import render_content, export

if __name__=='__main__':
    test_dir = os.path.dirname(__file__)
    toybox_dir = os.path.split(test_dir)[0]
    readme_f= os.path.join(toybox_dir, 'README.md')
    index_f = os.path.join(toybox_dir, 'index.html')
    assert os.path.exists(readme_f)
    export(readme_f, out_filename=index_f)
    print 'done.'
