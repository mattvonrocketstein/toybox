#!/usr/bin/env python
""" toybox demo for elasticsearch
    Example usage follows:

        # create 500 fake documents
        $ demo_elasticsearch --records 500

"""
import random
import datetime
import argparse
import logging
import logstash
import sys

from datetime import datetime
from elasticsearch import Elasticsearch

host = 'localhost'

def build_parser():
    parser = argparse.ArgumentParser(conflict_handler='resolve')
    parser.add_argument('-n','--records', type=int, default=0)
    return parser

def build_records(num_records):
    # test_logger.addHandler(logstash.TCPLogstashHandler(host, 5959, version=1))
    # create an index in elasticsearch, ignore status code 400 (index already exists)
    es = Elasticsearch('http://localhost:9200')
    es.indices.create(index='toybox-demo', ignore=400)
    #{u'acknowledged': True}

    # datetimes will be serialized
    # but not deserialized

    #es.get(index="my-index", doc_type="test-type", id=42)['_source']
    #{u'any': u'data', u'timestamp': u'2013-05-12T19:45:31.804229'}
    for i in range(num_records):
        x = random.choice(xrange(100))
        # add extra field to logstash message
        extra = {
            'test_string': 'python version: ' + repr(sys.version_info),
            'test_boolean': True,
            'test_dict': {'a': x, 'b': 'c'},
            'test_float': x+1.23,
            'test_integer': x,
            'test_list': [x]*2,
            'message': str([str(x)]*x)
            }
        body = {"any": "data", "timestamp": datetime.now()}
        body.update(extra)
        es.index(index="my-index", doc_type="test-type", id=i,
                 body=body)
        print i

if __name__=='__main__':
    parser = build_parser()
    args = parser.parse_args()
    num_records = args.records
    if num_records:
        build_records(num_records)
    else:
        raise SystemExit('nothing to do')
