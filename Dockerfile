FROM ubuntu:18.04
LABEL   maintainer="Matthias Leuffen <m@tth.es>" \
        org.infracamp.flavor.tag="${DOCKER_TAG}" \
        org.infracamp.flavor.name="${IMAGE_NAME}"

ADD /kickstart /kickstart

## Ignore ubuntu tools for now.
RUN chmod -R 755 /kickstart \
    && /kickstart/build/00-install-ubuntu-minimal.sh  \
    && /kickstart/build/99-setup-user-rights.sh \
    && rm -rf /var/lib/apt/lists/*

RUN /kickstart/lib/install-kicker.sh

# ENV TIMEZONE Europe/Berlin
# ENV SYSLOG_HOST ""
#
# ENV DEV_MODE "0"
# ENV DEV_CONTAINER_NAME "unnamed"
# ENV DEV_UID "1000"
# ENV DEV_TTYID "xXx"


# Use for debugging:
#ENTRYPOINT ["/bin/bash"]

## Don't append standalone parameter - only in projects
ENTRYPOINT ["/kickstart/run/entrypoint.sh"]

