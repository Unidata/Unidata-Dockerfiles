"""
A Spawner for JupyterHub that runs each user's server in a separate docker container
"""
from dockerspawner import DockerSpawner
from tornado import gen

class NestedDockerSpawner(DockerSpawner):

    @gen.coroutine
    def start(self, *args, **kwargs):
        yield DockerSpawner.start(self, *args, **kwargs)

        # get the internal Docker ip
        resp = yield self.docker('inspect_container', container=self.container_id)
        self.user.server.ip = resp['NetworkSettings']['IPAddress']
        self.user.server.port = 8888
        self.log.info('Set user server to %s', self.user.server)
