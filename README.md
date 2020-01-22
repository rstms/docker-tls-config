docker-tls-config
-----------------

Makefile to generate the public key infrastructure files required for client certificate authenticated TLS
connections to dockerd

Requirements:
 - make
 - openssl

Installation: 

copy Makefile to /etc/docker
```
cd /etc/docker
make
```
restart docker daemon

Example `/etc/docker/daemon.json`
```
{
  "tls": true,
  "tlsverify": true,
  "tlscacert": "/etc/docker/ca.pem",
  "tlscert": "/etc/docker/server-cert.pem",
  "tlskey": "/etc/docker/server-key.pem",
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2376"]
}
```

Example client configuration:
Copy `/etc/docker/{ca|cert|key}.pem` to `~/.docker` on the client machine
```
export DOCKER_HOST=tcp://<FQDN_OF_DOCKER_DAEMON_HOST>:2376
export DOCKER_TLS_VERIFY=1

ls ~/.docker
ca.pem cert.pem key.pem
```



