# Step 1: Build doh-server executable

FROM golang:alpine AS server-build-env

RUN apk add --no-cache git make

WORKDIR /tmp

RUN \
    set -x \
    && git clone --depth=1 https://github.com/m13253/dns-over-https doh-repo \
    && cd doh-repo \
    && make doh-server/doh-server

# Step 2: Create server image

FROM alpine:latest

WORKDIR /opt/dns-over-https

COPY --from=server-build-env /tmp/doh-repo/doh-server/doh-server doh-server

COPY ./data/doh-server.conf doh-server.conf

RUN \
    set -x \
    && delgroup ping \
    && addgroup -g 8053 doh \
    && adduser -D -G doh -u 8053 doh \
    && apk add -q --no-cache bash su-exec

EXPOSE 8053

ENTRYPOINT su-exec doh:doh ./doh-server -conf ./doh-server.conf
