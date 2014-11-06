#!/usr/bin/env python
""" toybox demo for neo4j
    Example usage follows:


        # no arguments loads the default datset "cieasts_12k_movies_50k"
        $ demo_neo.py

        # download specific named dataset from neo4j example data server,
        # then install it to our server.
        $ demo_neo.py --dataset=some_dataset.zip

        # reset database completely
        $ demo_neo.py --wipe
"""
import os
import argparse
from fabric.api import lcd, local
from fabric.colors import red


DEFAULT_DATASET = 'cineasts_12k_movies_50k_actors.zip'
NEO_DATA_DIR = '/opt/neo4j/neo4j-community-1.7.2/data/'
DATASET_URL_T = 'http://example-data.neo4j.org/files/{0}'
GRAPH_DB_DIR = os.path.join(NEO_DATA_DIR, 'graph.db')

def _report(msg):
    print red(msg)

def main(_CINE_FILE):
    DATASET_URL = DATASET_URL_T.format(_CINE_FILE)
    local_dataset = '/vagrant/{0}'.format(_CINE_FILE)
    if not os.path.exists(local_dataset):
        msg = "{0} does not exist.  downloading it now..".format(local_dataset)
        _report(msg)
        with lcd('/vagrant'):
            local('wget {0}'.format(DATASET_URL))
    else:
        _report("dataset is already downloaded: {0}".format(local_dataset))
    with lcd('/vagrant'):
        _report("decompressing dataset..")
        local('unzip -o {0} -d graph.db'.format(_CINE_FILE))
        backup_dir = 'graph.db.old'
        count = 1
        while True:
            tmp = backup_dir + '-' + str(count)
            backup = os.path.join(NEO_DATA_DIR, tmp)
            if not os.path.exists(backup):
                msg="existing graph.db data will be backed up here {0}"
                _report(msg.format(backup))
                break
            else:
                count+=1

        cmd = 'sudo mv {0} {1}'.format(
            GRAPH_DB_DIR, backup)
        local(cmd)
        cmd = 'sudo mv /vagrant/graph.db {0}'.format(GRAPH_DB_DIR)
        local(cmd)
        local('sudo chown -R neo4j:neo4j {0}'.format(GRAPH_DB_DIR))
        local('sudo chown -R neo4j:neo4j {0}'.format(backup))
        _report("finished copying dataset.")
        _restart_neo()
    msg = "finished installing dataset.  view it at the url below"
    _report(msg)
    _report("http://localhost:7474/webadmin/#/data/search/0/")

def wipedb():
    local('sudo rm -rf {0}'.format(
        GRAPH_DB_DIR))
    _restart_neo()

def _restart_neo():
    _report("restarting neo")
    local('sudo /etc/init.d/neo4j-service restart')

def build_parser():
    parser = argparse.ArgumentParser(conflict_handler='resolve')
    parser.add_argument('-d', '--dataset', default=DEFAULT_DATASET)
    parser.add_argument('--wipedb', action='store_true')
    return parser

if __name__ == '__main__':
    parser = build_parser()
    args = parser.parse_args()
    if args.wipedb:
        wipedb()
    else:
        main(args.dataset)
    #from IPython import Shell; Shell.IPShellEmbed(argv=['-noconfirm_exit'])()
