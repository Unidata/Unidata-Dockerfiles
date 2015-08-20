"""
A Spawner for JupyterHub that runs each user's server in a separate docker container
"""
import os
import docker
from tornado import gen
from traitlets import Unicode
from dockerspawner import DockerSpawner

class NestedDockerSpawner(DockerSpawner):

    external_pattern = Unicode('/home/{0.user.name}/work', config=True)

    _client = None
    @property
    def client(self):
        """single global client instance"""
        cls = self.__class__
        if cls._client is None:
            if self.use_docker_client_env:
                kwargs = kwargs_from_env()
                kwargs['tls'].assert_hostname = self.tls_assert_hostname
                client = docker.Client(**kwargs)
            else:
                if self.tls:
                    tls_config = True
                elif self.tls_verify or self.tls_ca or self.tls_client:
                    tls_config = docker.tls.TLSConfig(
                        client_cert=self.tls_client,
                        ca_cert=self.tls_ca,
                        verify=self.tls_verify,
                        assert_hostname = self.tls_assert_hostname)
                else:
                    tls_config = None

                docker_host = os.environ.get('DOCKER_HOST', 'unix://var/run/docker.sock')
                client = docker.Client(base_url=docker_host, tls=tls_config,
                                       version='auto')
            cls._client = client
        return cls._client

    @gen.coroutine
    def start(self, *args, **kwargs):
        self.volumes.update({self.external_pattern.format(self):'/home/jupyter/work'})
        yield DockerSpawner.start(self, *args, **kwargs)

        # get the internal Docker ip
        resp = yield self.docker('inspect_container', container=self.container_id)
        self.user.server.ip = resp['NetworkSettings']['IPAddress']
        self.user.server.port = 8888
        self.log.info('Set user server to %s', self.user.server)
