FROM debian:bullseye-slim

LABEL maintainer="mylesgrindon+github@gmail.com"

WORKDIR /build

RUN apt-get update && \
    apt-get install --no-install-recommends --yes \
                    debian-cd \
                    debian-archive-keyring \
                    dosfstools \
                    mtools \
                    netcat-openbsd \
                    python3 \
                    rsync \
                    xorriso

ENTRYPOINT ["/bin/bash", "-c", "conf/docker/entrypoint.sh"]
