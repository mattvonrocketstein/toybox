""" tests/test_esearch
"""
import sys, os
import argparse
import random
import unittest
from datetime import datetime
from elasticsearch import Elasticsearch

HOST = os.environ.get('TOYBOX_HOST', 'localhost')
BASE_URL = 'http://{0}:9200'.format(HOST)

class TestESearch(unittest.TestCase):

    num_records = 100
    doc_type = "utest-type"
    _index = "utest-toybox"

    def setUp(self):
        self.es = Elasticsearch(BASE_URL)

    def test_1_write(self):
        # create an index in elasticsearch,
        # ignore status code 400 (index already exists)
        result = self.es.indices.create(index=self.doc_type, ignore=400)
        try:
            self.assertEqual(result, dict(acknowledged=True))
        except AssertionError:
            self.assertTrue(
                result['error'].startswith(
                    'IndexAlreadyExistsException'))
            return
        else:
            for i in range(self.num_records):
                x = random.choice(xrange(100))
                # add extra field to logstash message
                extra = dict(
                    message= str([str(x)]*x),
                    test_dict={'a': x, 'b': 'c'},
                    test_integer= x, test_list= [x]*2,
                    test_boolean= True, test_float= x+1.23,
                    test_string= 'python version: ' + repr(sys.version_info),
                    )
                body = {"any": "data", "timestamp": datetime.now()}
                body.update(extra)
                self.es.index(
                    index=self._index, doc_type=self.doc_type, id=i,
                    body=body)
                if i%21==0:
                    print '..writing elasticsearch record number ',i

    def test_2_read(self):
        item = self.es.get(
            index="utest-toybox",
            doc_type=self.doc_type,
            id=self.num_records/2)
        self.assertEqual(item['_type'], self.doc_type)
        print '..',item
