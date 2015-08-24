"""
A Spawner for JupyterHub that runs each user's server in a separate docker container
"""
import os
import docker
from docker.errors import APIError
from tornado import gen
from traitlets import Unicode, Int
from dockerspawner import DockerSpawner

class NestedDockerSpawner(DockerSpawner):

    data_image = Unicode('unidata/python-workshop', config=True)
    memory_limit = Unicode('4g', config=True)
    cpu_share = Int(2, config=True)

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

    @property
    def data_container_name(self):
        return "{}-data".format(self.escaped_name)

    @gen.coroutine
    def start(self, *args, **kwargs):
        data_container = yield self.get_data_container()
        if data_container is None:
            # create the container
            resp = yield self.docker('create_container', volumes='/notebooks',
                    name=self.data_container_name, image=self.data_image,
                    command='/bin/true')
            data_container_id = resp['Id']
            self.log.info(
                "Created container '%s' (id: %s) from image %s",
                self.data_container_name, data_container_id[:7],
                self.data_image)


        extra_kwargs = kwargs.setdefault('extra_create_kwargs', dict())
        extra_kwargs['cpu_shares'] = self.cpu_share
        host_config = kwargs.setdefault('extra_host_config', dict())
        host_config['volumes_from'] = [self.data_container_name]

        # Needs conditional based on API
        resp = yield self.docker('version')
        if resp['ApiVersion'] < '1.19':
            extra_kwargs['mem_limit'] = self.memory_limit
        else:
            host_config['mem_limit'] = self.memory_limit

        # We'll use the hostname here
        self.log.info('Using hostname: %s', os.environ['HOSTNAME'])
        host_config['links'] = [(os.environ['HOSTNAME'], 'hub')]
        yield DockerSpawner.start(self, *args, **kwargs)

        # get the internal Docker ip
        resp = yield self.docker('inspect_container', container=self.container_id)
        self.user.server.ip = resp['NetworkSettings']['IPAddress']
        # Rely on linking and just use the container name (needs Docker >= 1.6)
        # self.user.server.ip = self.container_name
        self.user.server.port = 8888
        self.log.info('Set user server to %s', self.user.server)

    @gen.coroutine
    def get_data_container(self):
        self.log.debug("Getting data container '%s'", self.data_container_name)
        try:
            container = yield self.docker(
                'inspect_container', self.data_container_name
            )
        except APIError as e:
            if e.response.status_code == 404:
                self.log.info("Container '%s' is gone", self.data_container_name)
                container = None
            else:
                raise
        return container
