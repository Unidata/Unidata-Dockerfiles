# Configuration file for Jupyter Hub

import os
import sys

here = os.path.dirname(__file__)
sys.path.insert(0, here)

c = get_config()

c.JupyterHub.log_level = 10

# Spawn with Docker running inside Docker
c.JupyterHub.spawner_class = 'nesteddockerspawner.NestedDockerSpawner'

# The docker instances need access to the Hub, so the default loopback port doesn't work:
from jupyter_client.localinterfaces import public_ips
c.JupyterHub.hub_ip = '0.0.0.0'
c.JupyterHub.proxy_api_ip = '0.0.0.0'
c.DockerSpawner.hub_ip_connect = public_ips()[0]
c.DockerSpawner.remove_containers = True

# Authenticate with GitHub
#c.JupyterHub.authenticator_class = 'oauthenticator.LocalGitHubOAuthenticator'
#c.LocalGitHubOAuthenticator.create_system_users = True
#c.GitHubOAuthenticator.oauth_callback_url = os.environ['OAUTH_CALLBACK_URL']

c.Authenticator.whitelist = whitelist = set()
c.Authenticator.admin_users = admin = set()

# Find the user list and add the users
root = os.environ.get('OAUTHENTICATOR_DIR', here)
join = os.path.join
with open(join(root, 'userlist')) as f:
    for line in f:
        if not line:
            continue
        parts = line.split()
        name = parts[0]
        whitelist.add(name)
        if len(parts) > 1 and parts[1] == 'admin':
            admin.add(name)

# ssl config
ssl = join(root, 'ssl')
keyfile = join(ssl, 'ssl.key')
certfile = join(ssl, 'ssl.cert')
if os.path.exists(keyfile):
    c.JupyterHub.ssl_key = keyfile
if os.path.exists(certfile):
    c.JupyterHub.ssl_cert = certfile
