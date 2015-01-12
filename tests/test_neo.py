""" tests/test_neo

    generates graphs with networkx and then writes them to neo
    see: http://neonx.readthedocs.org/en/latest/contributing.html#get-started
"""
import sys, os
import argparse
import random
import unittest
from datetime import datetime

import neonx
import networkx as nx

HOST = os.environ.get('TOYBOX_HOST', 'localhost')
BASE_URL = 'http://{0}'.format(HOST)
100

class TestNeo(unittest.TestCase):

    def setUp(self):
        self.graph = nx.complete_graph(10)
        self.data = neonx.get_geoff(self.graph, "LINKS_TO")

    def test_1_write(self):
        results = neonx.write_to_neo("http://localhost:7474/db/data/", self.graph, 'LINKS_TO')

    def test_2_read(self):
        pass
