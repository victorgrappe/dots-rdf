# syntax=docker/dockerfile:1
#
# Apache Jena Fuseki, built from the official Apache binary release.
# Apache does not publish a ready-made Fuseki image on Docker Hub.
# The release is fetched from Maven Central: same file as archive.apache.org,
# which is much slower.

FROM eclipse-temurin:21-jre

ARG JENA_VERSION=6.2.0
# SHA-512 of apache-jena-fuseki-${JENA_VERSION}.tar.gz.
# Update it together with JENA_VERSION.
ARG JENA_SHA512=ba65f5867d2d4741b2ed9e2af5a0d4fbb447909894ab2a0c6bc4dac8997f4fe339c87b13c48d45d054977769f0f8bf763ea346b1f7792d5cdc458041bd43a132

ENV FUSEKI_HOME=/opt/fuseki \
    FUSEKI_BASE=/fuseki/run \
    JVM_ARGS=-Xmx1G

# Checked with sha512sum below, not `ADD --checksum`: BuildKit only verifies
# sha256 there, and Apache publishes sha512.
ADD https://repo1.maven.org/maven2/org/apache/jena/apache-jena-fuseki/${JENA_VERSION}/apache-jena-fuseki-${JENA_VERSION}.tar.gz \
    /tmp/fuseki.tar.gz

RUN echo "${JENA_SHA512}  /tmp/fuseki.tar.gz" | sha512sum -c - \
 && mkdir -p "$FUSEKI_HOME" "$FUSEKI_BASE" \
 && tar -xzf /tmp/fuseki.tar.gz -C "$FUSEKI_HOME" --strip-components=1 \
 && rm /tmp/fuseki.tar.gz \
 && useradd --system --home-dir /fuseki fuseki \
 && chown -R fuseki:fuseki /fuseki

USER fuseki
WORKDIR /fuseki
EXPOSE 3030

ENTRYPOINT ["/opt/fuseki/fuseki-server"]
CMD ["--config=/fuseki/config.ttl"]
