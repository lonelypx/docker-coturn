[![MIT License](https://img.shields.io/github/license/zenosmosis/docker-coturn)](https://raw.githubusercontent.com/zenOSmosis/docker-coturn/master/LICENSE)
[![ci][ci-image]][ci-url]

[ci-image]: https://github.com/zenosmosis/docker-coturn/actions/workflows/ci.yml/badge.svg
[ci-url]: https://github.com/zenOSmosis/docker-coturn/actions

# Docker image for Coturn TURN / STUN server

A Docker container with the [Coturn TURN server](https://github.com/coturn/coturn).

- hub.docker.com (Docker image): [zenosmosis/docker-coturn](https://hub.docker.com/r/zenosmosis/docker-coturn/)
- github.com (Repo): [zenOSmosis/docker-coturn](https://github.com/zenOSmosis/docker-coturn)

Note, for those who would rather build this sort of thing from scratch, here's an article written by the author of the original package we forked from: https://devblogs.microsoft.com/cse/2018/01/29/orchestrating-turn-servers-cloud-deployment.

# Run the container

### Without Docker Compose

```bash
docker run \
  -d \
  -p 3478:3478 \
  -p 3478:3478/udp \
  -p 65435-65535:65435-65535/udp \
  --restart=always \
  --name coturn \
  zenosmosis/docker-coturn
```

### With Docker Compose

```bash
docker compose up
```

## Environment variables

This image supports some environment variables:

- `USERNAME`: Username needed for turn. Defaults to `username`
- `PASSWORD`: Password needed for turn. Defaults ro `password`
- `REALM`: Realm needed for turn. Defaults to `realm`
- `MIN_PORT`: This defines the min-port for the range used by turn. Defaults to `65435`
- `MAX_PORT`: This defines the max-port for the range used by turn. Defaults to `65535`

_An example:_

```bash
# This makes sure, that the min- and max-port is the same for all environment variables
export MIN_PORT=50000
export MAX_PORT=50010
docker run \
  -d \
  -p 3478:3478 \
  -p 3478:3478/udp \
  -p ${MIN_PORT}-${MAX_PORT}:${MIN_PORT}-${MAX_PORT}/udp \
  -e USERNAME=another_user \
  -e PASSWORD=another_password \
  -e REALM=another_realm \
  -e MIN_PORT=${MIN_PORT} \
  -e MAX_PORT=${MAX_PORT} \
  --restart=always \
  --name coturn \
  zenosmosis/docker-coturn
```

(see [docker-compose.yml](docker-compose.yml) for configuration)

## Certificates

Store the cert under `/opt/cert.pem` and the key under `/opt/pkey.pem` and mount them as volumes:

```bash
docker run \
  -d \
  -p 3478:3478 \
  -p 3478:3478/udp \
  -p 65435-65535:65435-65535/udp \
  --volume /opt/cert.pem:/etc/ssl/turn_server_cert.pem \
  --volume /opt/pkey.pem:/etc/ssl/turn_server_pkey.pem \
  --restart=always \
  --name coturn \
  zenosmosis/docker-coturn
```

## Debugging

```bash
docker logs coturn
docker exec -it coturn /bin/bash
```

# Bonus: Build and push the container to [Docker Hub](https://hub.docker.com/)

```bash
# Clone
git clone https://github.com/zenOSmosis/docker-coturn.git

# Build
docker build -t zenosmosis/docker-coturn .

# Tag
VERSION=0.0.2
docker tag zenosmosis/docker-coturn zenosmosis/docker-coturn:$VERSION

# Login to Docker (if not already logged in)
docker login

# Push
docker push zenosmosis/docker-coturn:latest
docker push zenosmosis/docker-coturn:$VERSION

# At this point, you MAY want to log out of Docker, as it could cause authentication errors when trying to build other's containers
docker logout
```

# Thanks

The initial version of this image was created by [anastasiia-zolochevska/turn-server-docker-image](https://github.com/anastasiia-zolochevska/turn-server-docker-image). Thanks to [boldt/turn-server-docker-image](https://github.com/boldt/turn-server-docker-image) for the README.md and Dockerfile updates.

Usage: turnserver [options]
Options:
-d, --listening-device <device-name> Listener interface device (NOT RECOMMENDED. Optional, Linux only).
-p, --listening-port <port> TURN listener port (Default: 3478).
Note: actually, TLS & DTLS sessions can connect to the "plain" TCP & UDP port(s), too,
if allowed by configuration.
--tls-listening-port <port> TURN listener port for TLS & DTLS listeners
(Default: 5349).
Note: actually, "plain" TCP & UDP sessions can connect to the TLS & DTLS port(s), too,
if allowed by configuration. The TURN server
"automatically" recognizes the type of traffic. Actually, two listening
endpoints (the "plain" one and the "tls" one) are equivalent in terms of
functionality; but we keep both endpoints to satisfy the RFC 5766 specs.
For secure TCP connections, we currently support SSL version 3 and
TLS versions 1.0, 1.1 and 1.2. For secure UDP connections, we support
DTLS version 1.
--alt-listening-port<port> <port> Alternative listening port for STUN CHANGE_REQUEST (in RFC 5780 sense,
or in old RFC 3489 sense, default is "listening port plus one").
--alt-tls-listening-port <port> Alternative listening port for TLS and DTLS,
the default is "TLS/DTLS port plus one".
--tcp-proxy-port <port> Support connections from TCP loadbalancer on this port. The loadbalancer should
use the binary proxy protocol (https://www.haproxy.org/download/1.8/doc/proxy-protocol.txt)
-L, --listening-ip <ip> Listener IP address of relay server. Multiple listeners can be specified.
--aux-server <ip:port> Auxiliary STUN/TURN server listening endpoint.
Auxiliary servers do not have alternative ports and
they do not support RFC 5780 functionality (CHANGE REQUEST).
Valid formats are 1.2.3.4:5555 for IPv4 and [1:2::3:4]:5555 for IPv6.
--udp-self-balance (recommended for older Linuxes only) Automatically balance UDP traffic
over auxiliary servers (if configured).
The load balancing is using the ALTERNATE-SERVER mechanism.
The TURN client must support 300 ALTERNATE-SERVER response for this functionality.
-i, --relay-device <device-name> Relay interface device for relay sockets (NOT RECOMMENDED. Optional, Linux only).
-E, --relay-ip <ip> Relay address (the local IP address that will be used to relay the
packets to the peer).
Multiple relay addresses may be used.
The same IP(s) can be used as both listening IP(s) and relay IP(s).
If no relay IP(s) specified, then the turnserver will apply the default
policy: it will decide itself which relay addresses to be used, and it
will always be using the client socket IP address as the relay IP address
of the TURN session (if the requested relay address family is the same
as the family of the client socket).
-X, --external-ip <public-ip[/private-ip]> TURN Server public/private address mapping, if the server is behind NAT.
In that situation, if a -X is used in form "-X ip" then that ip will be reported
as relay IP address of all allocations. This scenario works only in a simple case
when one single relay address is be used, and no STUN CHANGE_REQUEST
functionality is required.
That single relay address must be mapped by NAT to the 'external' IP.
For that 'external' IP, NAT must forward ports directly (relayed port 12345
must be always mapped to the same 'external' port 12345).
In more complex case when more than one IP address is involved,
that option must be used several times in the command line, each entry must
have form "-X public-ip/private-ip", to map all involved addresses.
--allow-loopback-peers Allow peers on the loopback addresses (127.x.x.x and ::1).
--no-multicast-peers Disallow peers on well-known broadcast addresses (224.0.0.0 and above, and FFXX:\*).
-m, --relay-threads <number> Number of relay threads to handle the established connections
(in addition to authentication thread and the listener thread).
If explicitly set to 0 then application runs in single-threaded mode.
If not set then a default OS-dependent optimal algorithm will be employed.
The default thread number is the number of CPUs.
In older systems (pre-Linux 3.9) the number of UDP relay threads always equals
the number of listening endpoints (unless -m 0 is set).
--min-port <port> Lower bound of the UDP port range for relay endpoints allocation.
Default value is 49152, according to RFC 5766.
--max-port <port> Upper bound of the UDP port range for relay endpoints allocation.
Default value is 65535, according to RFC 5766.
-v, --verbose 'Moderate' verbose mode.
-V, --Verbose Extra verbose mode, very annoying (for debug purposes only).
-o, --daemon Start process as daemon (detach from current shell).
--no-software-attribute Production mode: hide the software version (formerly --prod).
-f, --fingerprint Use fingerprints in the TURN messages.
-a, --lt-cred-mech Use the long-term credential mechanism.
-z, --no-auth Do not use any credential mechanism, allow anonymous access.
-u, --user <user:pwd> User account, in form 'username:password', for long-term credentials.
Cannot be used with TURN REST API.
-r, --realm <realm> The default realm to be used for the users when no explicit
origin/realm relationship was found in the database.
Must be used with long-term credentials
mechanism or with TURN REST API.
--check-origin-consistency The flag that sets the origin consistency check:
across the session, all requests must have the same
main ORIGIN attribute value (if the ORIGIN was
initially used by the session).
-q, --user-quota <number> Per-user allocation quota: how many concurrent allocations a user can create.
This option can also be set through the database, for a particular realm.
-Q, --total-quota <number> Total allocations quota: global limit on concurrent allocations.
This option can also be set through the database, for a particular realm.
-s, --max-bps <number> Default max bytes-per-second bandwidth a TURN session is allowed to handle
(input and output network streams are treated separately). Anything above
that limit will be dropped or temporary suppressed
(within the available buffer limits).
This option can also be set through the database, for a particular realm.
-B, --bps-capacity <number> Maximum server capacity.
Total bytes-per-second bandwidth the TURN server is allowed to allocate
for the sessions, combined (input and output network streams are treated separately).
-c <filename> Configuration file name (default - turnserver.conf).
-b, , --db, --userdb <filename> SQLite database file name; default - /var/db/turndb or
/usr/local/var/db/turndb or /var/lib/turn/turndb.
-e, --psql-userdb, --sql-userdb <conn-string> PostgreSQL database connection string, if used (default - empty, no PostreSQL DB used).
This database can be used for long-term credentials mechanism users,
and it can store the secret value(s) for secret-based timed authentication in TURN REST API.
See http://www.postgresql.org/docs/8.4/static/libpq-connect.html for 8.x PostgreSQL
versions format, see
http://www.postgresql.org/docs/9.2/static/libpq-connect.html#LIBPQ-CONNSTRING
for 9.x and newer connection string formats.
-M, --mysql-userdb <connection-string> MySQL database connection string, if used (default - empty, no MySQL DB used).
This database can be used for long-term credentials mechanism users,
and it can store the secret value(s) for secret-based timed authentication in TURN REST API.
The connection string my be space-separated list of parameters:
"host=<ip-addr> dbname=<database-name> user=<database-user> \
 password=<database-user-password> port=<db-port> connect_timeout=<seconds> read_timeout=<seconds>".

                                                The connection string parameters for the secure communications (SSL):
                                                ca, capath, cert, key, cipher
                                                (see http://dev.mysql.com/doc/refman/5.1/en/ssl-options.html for the
                                                command options description).

                                                All connection-string parameters are optional.

--secret-key-file <filename> This is the file path which contain secret key of aes encryption while using MySQL password encryption.
If you want to use in the MySQL connection string the password in encrypted format,
then set in this option the file path of the secret key. The key which is used to encrypt MySQL password.
Warning: If this option is set, then MySQL password must be set in "mysql-userdb" option in encrypted format!
If you want to use cleartext password then do not set this option!
-N, --redis-userdb <connection-string> Redis user database connection string, if used (default - empty, no Redis DB used).
This database can be used for long-term credentials mechanism users,
and it can store the secret value(s) for secret-based timed authentication in TURN REST API.
The connection string my be space-separated list of parameters:
"host=<ip-addr> dbname=<db-number> \
 password=<database-user-password> port=<db-port> connect_timeout=<seconds>".

                                                All connection-string parameters are optional.

-O, --redis-statsdb <connection-string> Redis status and statistics database connection string, if used
(default - empty, no Redis stats DB used).
This database keeps allocations status information, and it can be also used for publishing
and delivering traffic and allocation event notifications.
The connection string has the same parameters as redis-userdb connection string.
--use-auth-secret TURN REST API flag.
Flag that sets a special authorization option that is based upon authentication secret
(TURN Server REST API, see TURNServerRESTAPI.pdf). This option is used with timestamp.
--static-auth-secret <secret> 'Static' authentication secret value (a string) for TURN REST API only.
If not set, then the turn server will try to use the 'dynamic' value
in turn_secret table in user database (if present).
That database value can be changed on-the-fly
by a separate program, so this is why it is 'dynamic'.
Multiple shared secrets can be used (both in the database and in the "static" fashion).
--no-auth-pings Disable periodic health checks to 'dynamic' auth secret tables.
--no-dynamic-ip-list Do not use dynamic allowed/denied peer ip list.
--no-dynamic-realms Do not use dynamic realm assignment and options.
--server-name Server name used for
the oAuth authentication purposes.
The default value is the realm name.
--oauth Support oAuth authentication.
-n Do not use configuration file, take all parameters from the command line only.
--cert <filename> Certificate file, PEM format. Same file search rules
applied as for the configuration file.
If both --no-tls and --no_dtls options
are specified, then this parameter is not needed.
--pkey <filename> Private key file, PEM format. Same file search rules
applied as for the configuration file.
If both --no-tls and --no-dtls options
--pkey-pwd <password> If the private key file is encrypted, then this password to be used.
--cipher-list <"cipher-string"> Allowed OpenSSL cipher list for TLS/DTLS connections.
Default value is "DEFAULT".
--CA-file <filename> CA file in OpenSSL format.
Forces TURN server to verify the client SSL certificates.
By default, no CA is set and no client certificate check is performed.
--ec-curve-name <curve-name> Curve name for EC ciphers, if supported by OpenSSL
library (TLS and DTLS). The default value is prime256v1,
if pre-OpenSSL 1.0.2 is used. With OpenSSL 1.0.2+,
an optimal curve will be automatically calculated, if not defined
by this option.
--dh566 Use 566 bits predefined DH TLS key. Default size of the predefined key is 2066.
--dh1066 Use 1066 bits predefined DH TLS key. Default size of the predefined key is 2066.
--dh-file <dh-file-name> Use custom DH TLS key, stored in PEM format in the file.
Flags --dh566 and --dh1066 are ignored when the DH key is taken from a file.
--no-tlsv1 Do not allow TLSv1/DTLSv1 protocol.
--no-tlsv1_1 Do not allow TLSv1.1 protocol.
--no-tlsv1_2 Do not allow TLSv1.2/DTLSv1.2 protocol.
--no-udp Do not start UDP client listeners.
--no-tcp Do not start TCP client listeners.
--no-tls Do not start TLS client listeners.
--no-dtls Do not start DTLS client listeners.
--no-udp-relay Do not allow UDP relay endpoints, use only TCP relay option.
--no-tcp-relay Do not allow TCP relay endpoints, use only UDP relay options.
-l, --log-file <filename> Option to set the full path name of the log file.
By default, the turnserver tries to open a log file in
/var/log/turnserver/, /var/log, /var/tmp, /tmp and . (current) directories
(which open operation succeeds first that file will be used).
With this option you can set the definite log file name.
The special names are "stdout" and "-" - they will force everything
to the stdout; and "syslog" name will force all output to the syslog.
--no-stdout-log Flag to prevent stdout log messages.
By default, all log messages are going to both stdout and to
a log file. With this option everything will be going to the log file only
(unless the log file itself is stdout).
--syslog Output all log information into the system log (syslog), do not use the file output.
--simple-log This flag means that no log file rollover will be used, and the log file
name will be constructed as-is, without PID and date appendage.
This option can be used, for example, together with the logrotate tool.
--new-log-timestamp Enable full ISO-8601 timestamp in all logs.
--new-log-timestamp-format <format> Set timestamp format (in strftime(1) format)
--log-binding Log STUN binding request. It is now disabled by default to avoid DoS attacks.
--stale-nonce[=<value>] Use extra security with nonce value having limited lifetime (default 600 secs).
--max-allocate-lifetime <value> Set the maximum value for the allocation lifetime. Default to 3600 secs.
--channel-lifetime <value> Set the lifetime for channel binding, default to 600 secs.
This value MUST not be changed for production purposes.
--permission-lifetime <value> Set the value for the lifetime of the permission. Default to 300 secs.
This MUST not be changed for production purposes.
-S, --stun-only Option to set standalone STUN operation only, all TURN requests will be ignored.
--no-stun Option to suppress STUN functionality, only TURN requests will be processed.
--alternate-server <ip:port> Set the TURN server to redirect the allocate requests (UDP and TCP services).
Multiple alternate-server options can be set for load balancing purposes.
See the docs for more information.
--tls-alternate-server <ip:port> Set the TURN server to redirect the allocate requests (DTLS and TLS services).
Multiple alternate-server options can be set for load balancing purposes.
See the docs for more information.
-C, --rest-api-separator <SYMBOL> This is the timestamp/username separator symbol (character) in TURN REST API.
The default value is ':'.
--max-allocate-timeout=<seconds> Max time, in seconds, allowed for full allocation establishment. Default is 60.
--allowed-peer-ip=<ip[-ip]> Specifies an ip or range of ips that are explicitly allowed to connect to the
turn server. Multiple allowed-peer-ip can be set.
--denied-peer-ip=<ip[-ip]> Specifies an ip or range of ips that are not allowed to connect to the turn server.
Multiple denied-peer-ip can be set.
--pidfile <"pid-file-name"> File name to store the pid of the process.
Default is /var/run/turnserver.pid (if superuser account is used) or
/var/tmp/turnserver.pid .
--acme-redirect <URL> Redirect ACME, i.e. HTTP GET requests matching '^/.well-known/acme-challenge/(.\*)' to '<URL>$1'.
Default is '', i.e. no special handling for such requests.
--secure-stun Require authentication of the STUN Binding request.
By default, the clients are allowed anonymous access to the STUN Binding functionality.
--proc-user <user-name> User name to run the turnserver process.
After the initialization, the turnserver process
will make an attempt to change the current user ID to that user.
--proc-group <group-name> Group name to run the turnserver process.
After the initialization, the turnserver process
will make an attempt to change the current group ID to that group.
--mobility Mobility with ICE (MICE) specs support.
-K, --keep-address-family TURN server allocates address family according TURN
Client <=> Server communication address family.
!! It breaks RFC6156 section-4.2 (violates default IPv4) !!
--no-cli Turn OFF the CLI support. By default it is always ON.
--cli-ip=<IP> Local system IP address to be used for CLI server endpoint. Default value
is 127.0.0.1.
--cli-port=<port> CLI server port. Default is 5766.
--cli-password=<password> CLI access password. Default is empty (no password).
For the security reasons, it is recommended to use the encrypted
for of the password (see the -P command in the turnadmin utility).
The dollar signs in the encrypted form must be escaped.
--web-admin Enable Turn Web-admin support. By default it is disabled.
--web-admin-ip=<IP> Local system IP address to be used for Web-admin server endpoint. Default value
is 127.0.0.1.
--web-admin-port=<port> Web-admin server port. Default is 8080.
--web-admin-listen-on-workers Enable for web-admin server to listens on STUN/TURN workers STUN/TURN ports.
By default it is disabled for security resons!
(This behavior used to be the default behavior, and was enabled by default.)
--server-relay Server relay. NON-STANDARD AND DANGEROUS OPTION. Only for those applications
when we want to run server applications on the relay endpoints.
This option eliminates the IP permissions check on the packets
incoming to the relay endpoints.
--cli-max-output-sessions Maximum number of output sessions in ps CLI command.
This value can be changed on-the-fly in CLI. The default value is 256.
--ne=[1|2|3] Set network engine type for the process (for internal purposes).
-h Help

openssl req -x509 -newkey rsa:4096 -keyout /opt/key.pem -out /opt/cert.pem -days 365 -nodes
