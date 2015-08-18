#!/usr/bin/env python
import binascii
import os

def random_hex(nb):
        return binascii.hexlify(os.urandom(nb)).decode('ascii')

with open('jupyterhub.env', 'w') as f:
    f.write('JPY_COOKIE_SECRET=%s\n' % random_hex(1024))
    f.write('CONFIGPROXY_AUTH_TOKEN=%s\n' % random_hex(64))
