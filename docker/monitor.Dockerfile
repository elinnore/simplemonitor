# -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
# >> python @ alpine
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
FROM python:2.7-alpine

# >> meta :: labels
LABEL   version_dockerfile="10-07-2018:prod" \
        version_image="python:2.7-alpine"

# >> package :: install
RUN     apk --no-cache add --update \
            # __ install :: basics
            build-base \
            openssl \
            # __ install :: tools
            bash \
            sudo \
            openrc \
            su-exec \
            bind-tools \
            openssl-dev \
            libffi-dev

# >> env :: web/docker paths
ENV     DOCKER_ROOT=/code \
        DOCKER_HTML_ROOT=/code/html \
        DOCKER_HTML_BACKUP=/code/html-backup \
        DOCKER_ENTRYPOINT_BINARY=/bin/monitor.entrypoint.sh \
        DOCKER_ENTRYPOINT_ORIGIN=/code/docker/monitor.entrypoint.sh

# >> env :: source/host paths
ENV     SOURCE_ROOT=./ \
        SOURCE_HTML_ROOT=./html/

# >> env :: volumes
ENV     VOLUME_UNIVERSAL_HTML=$DOCKER_HTML_ROOT \
        VOLUME_MONITOR_EXPORT=/code/monitor-export

# >> env :: user/groups
ENV     MAIN_USER=simplemonitor \
        MAIN_USER_ID=1500 \
        MAIN_GROUP=simplemonitor \
        MAIN_GROUP_ID=1500

# >> setup :: root-directory
RUN     mkdir -p $DOCKER_ROOT
COPY    $SOURCE_ROOT $DOCKER_ROOT
WORKDIR $DOCKER_ROOT

# >> install :: py-requirements
RUN     pip install --no-cache-dir -r "$DOCKER_ROOT"/requirements.txt

# >> setup :: html-backup
# __ this is a workaround for well known problems with docker-volumes.
# __ Initial volume instanciation, finished in [monitor.entrypoint.sh].
COPY    $SOURCE_HTML_ROOT $DOCKER_HTML_BACKUP

# >> prepare :: volumes
RUN     mkdir -p $VOLUME_MONITOR_EXPORT

# >> setup :: volumes
VOLUME  $VOLUME_UNIVERSAL_HTML \
        $VOLUME_MONITOR_EXPORT

# >> add :: user, group, project-directory-rights
RUN     addgroup -g $MAIN_GROUP_ID $MAIN_GROUP \
        && adduser -D -G $MAIN_GROUP -u $MAIN_USER_ID $MAIN_USER \
        && chown -R $MAIN_USER:$MAIN_GROUP $DOCKER_ROOT

# >> entrypoint :: prepare
RUN     cp $DOCKER_ENTRYPOINT_ORIGIN $DOCKER_ENTRYPOINT_BINARY \
        && chmod +x $DOCKER_ENTRYPOINT_BINARY

# Start the monitor
CMD     ["/bin/monitor.entrypoint.sh"]
