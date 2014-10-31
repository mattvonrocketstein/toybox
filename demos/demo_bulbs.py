#!/usr/bin/env python
""" toybox demo for neo4j/bulbs
    Example usage follows:

      # send 100 messages to subtract task
      $ demo_celery.py -n 100 --subtract

      # send 200 messages to add task
      demo_celery.py -n 100 --subtract

      # start the worker which answers add/subtract tasks
      demo_celery.py --worker
"""
import argparse

from bulbs.config import DEBUG
from bulbs.model import Node, Relationship
from bulbs.property import String, Integer, DateTime
from bulbs.utils import current_datetime

class Person(Node):
    autoindex=True
    element_type = "person"
    name = String(nullable=False)
    age = Integer()


class Knows(Relationship):
    autoindex=True
    label = "knows"
    created = DateTime(default=current_datetime, nullable=False)

#from people import Person, Knows
from bulbs.neo4jserver import Graph


def build_parser():
    parser = argparse.ArgumentParser(conflict_handler='resolve')
    parser.add_argument('-w', '--worker', action='store_true')
    return parser

if __name__ == '__main__':
    parser = build_parser()
    args = parser.parse_args()
    g = Graph()
    g.config.set_logger(DEBUG)
    g.add_proxy("people", Person)
    g.add_proxy("knows", Knows)

    james = g.people.create(name="James")
    julie = g.people.create(name="Julie")
    relationship = g.knows.create(james, julie)
    friends = james.outV('knows')
    friends = julie.inV('knows')
    print relationship.data()
    from IPython import Shell; Shell.IPShellEmbed(argv=['-noconfirm_exit'])()
