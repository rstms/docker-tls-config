# make PKI for client certificate authenticated TLS connections to docker daemon
# implements the commands described at https://docs.docker.com/engine/security/https/

HOST:=$(shell hostname -f)
IP:=$(shell ifconfig eth0 | awk -F: '/inet addr:/{print $$2}'|awk '{print $$1}')

default: server-cert.pem cert.pem

ca-key.pem:
	openssl genrsa -aes256 -out $@ 4096
	chmod 0400 $@
	
ca.pem: ca-key.pem
	openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out $@
	chmod 0444 $@

server-key.pem key.pem: 
	openssl genrsa -out $@ 4096
	chmod 0400 $@

server.csr: server-key.pem
	openssl req -subj "/CN=${HOST}" -sha256 -new -key server-key.pem -out $@

extfile.cnf:
	echo subjectAltName = DNS:${HOST},IP:${IP},IP:127.0.0.1 >$@
	echo extendedKeyUsage = serverAuth >>$@

server-cert.pem: server.csr ca.pem extfile.cnf
	openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem \
	-CAcreateserial -out $@ -extfile extfile.cnf
	chmod 0444 $@
	rm server.csr extfile.cnf

client.csr: key.pem
	openssl req -subj '/CN=client' -new -key $< -out $@

extfile-client.cnf:
	echo extendedKeyUsage = clientAuth >$@

cert.pem: client.csr ca.pem extfile-client.cnf
	openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem \
	-CAcreateserial -out $@ -extfile extfile-client.cnf
	chmod 0444 $@
	rm client.csr extfile-client.cnf

clean:
	rm -f *.pem
	rm -f *.csr
	rm -f *.cnf
