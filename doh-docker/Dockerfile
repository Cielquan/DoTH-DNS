# Step 1: Build

FROM golang:alpine AS build-env

RUN apk add --no-cache git make

WORKDIR /tmp

RUN \
    set -x \
    && git clone --depth=1 https://github.com/m13253/dns-over-https doh-repo \
    && cd doh-repo \
    && make doh-server/doh-server

# Step 2: Create server

FROM ubuntu:latest

WORKDIR /opt/dns-over-https

COPY --from=build-env /tmp/doh-repo/doh-server/doh-server doh-server

COPY ./doh-server.conf doh-server.conf

RUN \
    set -x \
    && addgroup --gid 8053 doh \
    && adduser --gecos "" --no-create-home --disabled-password --gid 8053 doh \
    && apt update -q \
    && apt install -q ca-certificates su-exec

EXPOSE 8053

ENTRYPOINT su-exec doh:doh ./doh-server -conf ./doh-server.conf
