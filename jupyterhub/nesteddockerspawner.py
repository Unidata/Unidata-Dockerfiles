"""
A Spawner for JupyterHub that runs each user's server in a separate docker container
"""
from dockerspawner import DockerSpawner
from tornado import gen
from traitlets import Unicode

class NestedDockerSpawner(DockerSpawner):

    external_pattern = Unicode('/home/{0.user.name}/work', config=True)

    @gen.coroutine
    def start(self, *args, **kwargs):
        self.volumes.update({self.external_pattern.format(self):'/home/jupyter/work'})
        yield DockerSpawner.start(self, *args, **kwargs)

        # get the internal Docker ip
        resp = yield self.docker('inspect_container', container=self.container_id)
        self.user.server.ip = resp['NetworkSettings']['IPAddress']
        self.user.server.port = 8888
        self.log.info('Set user server to %s', self.user.server)
