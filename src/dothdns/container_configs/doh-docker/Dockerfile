FROM alpine

ARG BUILD_DATE
ARG VERSION

LABEL \
    org.label-schema.vendor="Cielquan - cielquan@protonmail.com" \
    org.label-schema.url="https://github.com/Cielquan/DoTH-DNS/" \
    org.label-schema.name="DoH Server" \
    org.label-schema.version=$VERSION \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.license="GPL-3.0" \
    org.label-schema.schema-version="1.0"

ENV \
    GOPATH="/go" \
    GOCACHE="/tmp/gocache"

WORKDIR /opt/dns-over-https

COPY configs/ conf/

RUN \
    set -x \
    && delgroup ping \
    && addgroup -g 8053 doh \
    && adduser -D -G doh -u 8053 doh \
    && apk add -q --no-cache --virtual .build-deps gcc git go musl-dev \
    && apk add -q --no-cache bash ca-certificates shadow su-exec tzdata \
    && go get github.com/m13253/dns-over-https/doh-server \
    && cp -r /go/bin/* /usr/local/bin \
    && apk del -q --purge .build-deps \
    && rm -rf /go /root/.cache/* /tmp/* /var/cache/apk/*

ENTRYPOINT su-exec doh:doh doh-server -conf /opt/dns-over-https/conf/doh-server.conf
