#!/usr/bin/env python
""" toybox demo for mongo
    Example usage follows:

        # create 500 fake users
        $ demo_mongo --records 500

"""
import datetime
import argparse
from faker import Faker
from mongoengine import connect, Document
from mongoengine import StringField, ListField
from mongoengine import DateTimeField, DictField

TEST_DB = 'testdb'


class User(Document):
    name = StringField()
    username = StringField()
    email = StringField()
    phone = StringField()
    company = StringField()
    address = ListField()
    joined = DateTimeField()
    dict_field = DictField()

def build_parser():
    parser = argparse.ArgumentParser(conflict_handler='resolve')
    parser.add_argument('-n','--records', type=int, default=0)
    return parser

def build_records(num_records, test_db, save=True):
    connect(test_db)
    print 'saving {0} faked user documents to db "{1}"'.format(
        num_records, test_db)
    for i in range(num_records):
        f = Faker()
        user_data = dict(
            name=f.name(),
            phone=f.phonenumber(),
            company=f.company(),
            username=f.username(),
            full_address=f.full_address().split('\n'),
            joined=datetime.datetime.now())
        doc = User(**user_data)
        doc.save()
    print 'done'

if __name__=='__main__':
    parser = build_parser()
    args = parser.parse_args()
    test_db = TEST_DB
    num_records = args.records
    if num_records:
        build_records(num_records, test_db)
    else:
        raise SystemExit('nothing to do')
