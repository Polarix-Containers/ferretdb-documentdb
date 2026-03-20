ARG POSTGRES=17
ARG DOCUMENTDB=0.107.0
ARG FERRETDB=2.7.0
ARG UID=200023
ARG GID=200023

FROM ghcr.io/ferretdb/postgres-documentdb:${POSTGRES}-${DOCUMENTDB}-ferretdb-${FERRETDB} AS extract

FROM postgres:${POSTGRES}-trixie
LABEL maintainer="Thien Tran contact@tommytran.io"

ARG POSTGRES
ARG DOCUMENTDB
ARG FERRETDB
ARG TARGETARCH
ARG UID
ARG GID

RUN apt-get update \
    && apt-get install -y ca-certificates \
    && sed -i 's#http://#https://#g' /etc/apt/sources.list.d/debian.sources \
    && sed -i 's#http://#https://#g' /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get full-upgrade -y \
    && apt-get install --no-install-recommends -y wget \
    && wget -O ferretdb.deb https://github.com/FerretDB/documentdb/releases/download/v${DOCUMENTDB}-ferretdb-${FERRETDB}/deb12-postgresql-${POSTGRES}-documentdb_${DOCUMENTDB}.ferretdb.${FERRETDB}_amd64.deb \
    && apt-get install --no-install-recommends -y ./ferretdb.deb \
    && apt-get autoremove \
    && apt-get autoclean \
    && rm -rf ferretdb.deb /var/cache/apt \
    && rm /usr/local/bin/gosu
    
RUN --network=none \
    usermod -u ${UID} postgres \
    && groupmod -g ${GID} postgres \
    && find / \( -path /proc -prune -false \) -user 999 -exec chown -h postgres {} \; \
    && find / \( -path /proc -prune -false \) -group 999 -exec chgrp -h postgres {} \;

COPY --from=extract /docker-entrypoint-initdb.d/10-preload.sh /docker-entrypoint-initdb.d
COPY --from=extract /docker-entrypoint-initdb.d/20-install.sql /docker-entrypoint-initdb.d

WORKDIR /
