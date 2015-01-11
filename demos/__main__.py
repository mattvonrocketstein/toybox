""" __main__ for demos
"""

import os
import glob

def main():
    demo_dir = os.path.dirname(__file__)
    files = glob.glob(demo_dir+os.path.sep+'demo_*py')
    print files

if __name__=='__main__':
    main()
    raise SystemExit(0)
