""" toybox.data
"""
import os

HOME     = os.path.dirname(os.path.dirname(__file__))

PUPPET   = os.path.join(HOME, 'puppet')

DEFAULTS = {
        'ssh'           : [22,8022],
        'nginx'         : [8080, 8081],
        'kibana'        : [8080, 8081],
        'rabbit'        : [15672, 15672], # this entry is for the rabbitmq WUI
        'flower'        : [5555, 5555],
        'genghis'       : [5556, 5556],
        'supervisor'    : [9001, 9001],
        'elasticsearch' : [9200, 9200],
        'neo'           : [7474, 7474]
        }
