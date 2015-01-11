#!/usr/bin/env python
""" __main__ for tests

    this file describes simple tests for the toybox guest.  you can run
    it directly without invoking pytest or nose.

    NOTE: tests may work differently depending on whether the tests are
          running from the guest or the host.  this program will detect
          whether or not it's running on the guest OS by looking for a
          '/vagrant' directory.

    TODO: DRYer with the portmap in Vagrantfile
"""
import os
import unittest
import requests

BASE_URL = 'http://localhost'

HOST_PORTS = dict(
    neo=[7474, 200],
    esearch=[9200, 200],
    nginx=[8080, 'any'],
    rabbit=[15672, 200],
    flower=[5555, 200],
    genghis=[5556, 200],
    supervisor=[9001, 200],)

GUEST_PORTS = dict(
    neo=[7474, 200],
    esearch=[9200, 200],
    nginx=[80, 'any'],
    rabbit=[15672, 200],
    flower=[5555, 200],
    genghis=[5556, 200],
    supervisor=[9001, 200],)


class BaseTest(unittest.TestCase):
    def _test_port(self, name, port_map):
        port, code = port_map[name]
        url = '{base}:{port}'.format(base=BASE_URL, port=port)
        try:
            resp = requests.get(url)
        except requests.ConnectionError:
            self.fail("Connection error on port {0}".format(port))
        if isinstance(code, int):
            self.assertEqual(code,resp.status_code)
        if code=='any':
            self.assertTrue(resp.status_code)

class TestGuestFromHost(BaseTest):
    pass

class TestGuestFromGuest(BaseTest):
    pass

def install(port_map, kls):
    for service_name in HOST_PORTS:
        fxn_name = 'test_'+service_name
        fxn = lambda himself: himself._test_port(service_name, HOST_PORTS)
        setattr(kls, fxn_name, fxn)

if not os.path.exists('/vagrant'):
    install(HOST_PORTS, TestGuestFromHost)
else:
    install(GUEST_PORTS, TestGuestFromGuest)

if __name__=='__main__':
    unittest.main()
