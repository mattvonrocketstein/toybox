#!/usr/bin/env python
""" toybox demo for mongo
    Example usage follows:

        # create 500 fake users
        $ demo_mongo --records 500

"""
import datetime
import random
import argparse
import logging
import logstash
import sys

host = 'localhost'

def build_parser():
    parser = argparse.ArgumentParser(conflict_handler='resolve')
    parser.add_argument('-n','--records', type=int, default=0)
    return parser

test_logger = logging.getLogger('python-logstash-logger')
test_logger.setLevel(logging.INFO)
test_logger.addHandler(logstash.LogstashHandler(host, 5959, version=1))

def build_records(num_records):
    # test_logger.addHandler(logstash.TCPLogstashHandler(host, 5959, version=1))
    for i in range(num_records):
        x = random.choice(xrange(100))
        test_logger.error('python-logstash: {0} test logstash error message.'.format(x))
        test_logger.info('python-logstash: {0} test logstash info message.'.format(x))
        test_logger.warning('python-logstash: {0} test logstash warning message.')

        # add extra field to logstash message
        extra = {
            'test_string': 'python version: ' + repr(sys.version_info),
            'test_boolean': True,
            'test_dict': {'a': x, 'b': 'c'},
            'test_float': x+1.23,
            'test_integer': x,
            'test_list': [x]*2
            }
        test_logger.info('python-logstash: test extra fields', extra=extra)

if __name__=='__main__':
    parser = build_parser()
    args = parser.parse_args()
    num_records = args.records
    if num_records:
        build_records(num_records, test_db)
    else:
        raise SystemExit('nothing to do')
