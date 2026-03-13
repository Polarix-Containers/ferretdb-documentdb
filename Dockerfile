ARG POSTGRES=17
ARG DOCUMENTDB=0.107.0
ARG FERRETDB=2.7.0

FROM ghcr.io/ferretdb/postgres-documentdb:${POSTGRES}-${DOCUMENTDB}-ferretdb-${FERRETDB} AS extract

FROM postgres:${POSTGRES}-trixie

ARG POSTGRES
ARG DOCUMENTDB
ARG FERRETDB
ARG TARGETARCH

RUN apt-get update \
    && apt-get full-upgrade -y \
    && apt-get install -y \
        postgresql-${POSTGRES}-cron \
        postgresql-${POSTGRES}-pgvector \
        postgresql-${POSTGRES}-postgis-3 \
        postgresql-${POSTGRES}-rum \
        postgresql-server-dev-${POSTGRES} \
        barman-cli-cloud \
        wget \
    && wget -O ferretdb.deb https://github.com/FerretDB/documentdb/releases/download/v${DOCUMENTDB}-ferretdb-${FERRETDB}/deb12-postgresql-${POSTGRES}-documentdb_${DOCUMENTDB}.ferretdb.${FERRETDB}_amd64.deb \
    && dpkg -i ferretdb.deb \
    && rm -rf ferretdb.deb /var/cache/apt \
    && rm /usr/local/bin/gosu


COPY --from=extract /docker-entrypoint-initdb.d/10-preload.sh /docker-entrypoint-initdb.d
COPY --from=extract /docker-entrypoint-initdb.d/20-install.sql /docker-entrypoint-initdb.d

WORKDIR /
