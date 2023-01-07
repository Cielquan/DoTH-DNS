# Step 1: Build su-exec executable

FROM ubuntu:latest AS suexec-build-env

WORKDIR /tmp

RUN \
    set -ex \
    && apt-get update -q \
    && apt-get install -q -y --no-install-recommends ca-certificates curl gcc libc-dev \
    && curl -o su-exec.c https://raw.githubusercontent.com/Cielquan/su-exec/master/su-exec.c \
    && gcc -Wall su-exec.c -o su-exec \
    && chown root:root su-exec \
    && chmod 0755 su-exec

# Step 2: Build doh-server executable

FROM golang:alpine AS server-build-env

RUN apk add --no-cache git make

WORKDIR /tmp

RUN \
    set -x \
    && git clone --depth=1 https://github.com/m13253/dns-over-https doh-repo \
    && cd doh-repo \
    && make doh-server/doh-server

# Step 3: Create server image

FROM ubuntu:latest

WORKDIR /opt/dns-over-https

COPY --from=server-build-env /tmp/doh-repo/doh-server/doh-server doh-server
COPY --from=suexec-build-env /tmp/su-exec /usr/local/bin/su-exec

COPY ./doh-server.conf doh-server.conf

RUN \
    set -x \
    && addgroup --gid 8053 doh \
    && adduser --gecos "" --no-create-home --disabled-password --gid 8053 doh

EXPOSE 8053

ENTRYPOINT su-exec doh:doh ./doh-server -conf ./doh-server.conf
