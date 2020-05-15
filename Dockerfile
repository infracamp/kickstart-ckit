FROM ubuntu:18.04
LABEL   maintainer="Matthias Leuffen <m@tth.es>" \
        org.infracamp.flavor.tag="${DOCKER_TAG}" \
        org.infracamp.flavor.name="${IMAGE_NAME}"

ADD /kickstart /kickstart
RUN chmod -R 755 /kickstart \
    && /kickstart/build/install-ubuntu-minimal.sh  \
    && /kickstart/build/setup.sh

RUN /kickstart/lib/install-kicker.sh

ENV TIMEZONE Europe/Berlin
ENV SYSLOG_HOST ""

ENV DEV_MODE "0"
ENV DEV_CONTAINER_NAME "unnamed"
ENV DEV_UID "1000"
ENV DEV_TTYID "xXx"

# Set from hub.docker.com
ENV IMAGE_NAME "${IMAGE_NAME}"

# Use for debugging:
#ENTRYPOINT ["/bin/bash"]

## Don't append standalone parameter - only in projects
ENTRYPOINT ["/kickstart/run/entrypoint.sh"]

