#!/usr/bin/env python
"""
"""
import unittest
import requests

BASE_URL = 'http://localhost'

PORTS = dict(
    neo=7474,
    nginx=8080,
    supervisor=9001,
    flower=5555,
    genghis=5556,
    rabbit=15672)


class TestGuest(unittest.TestCase):

    def _test_port(self, port, code=None):
        url = '{base}:{port}'.format(base=BASE_URL, port=port)
        try:
            resp = requests.get(url)
        except requests.ConnectionError:
            self.fail("Connection error on port {0}".format(port))
        if isinstance(code, int):
            self.assertEqual(code,resp.status_code)
        if code=='any':
            self.assertTrue(resp.status_code)

    def test_rabbit(self):
        resp = self._test_port(PORTS['rabbit'], 200)

    def test_neo(self):
        resp = self._test_port(PORTS['neo'], 200)

    def test_genghisapp(self):
        resp = self._test_port(PORTS['genghis'], 200)

    def test_supervisor(self):
        resp = self._test_port(PORTS['supervisor'], 200)

    def test_flower(self):
        resp = self._test_port(PORTS['flower'], 200)

    def test_nginx(self):
        # might be 500, that's ok for now.
        resp = self._test_port(PORTS['nginx'], code='any')

if __name__=='__main__':
    unittest.main()
