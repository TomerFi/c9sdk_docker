FROM arm32v7/node:12.6.0-stretch

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
org.label-schema.name="tomerfi/c9sdk_docker" \
org.label-schema.description="Image for c9sdk webide, https://cloud9-sdk.readme.io/" \
org.label-schema.url="https://hub.docker.com/r/tomerfi/c9sdk_docker" \
org.label-schema.vcs-url="https://github.com/TomerFi/c9sdk_docker" \
org.label-schema.vcs-ref=$VCS_REF \
org.label-schema.version=$VERSION \
org.label-schema.schema-version="1.0" \
org.label-schema.docker.cmd="\
docker run -d -p 8000:8000 \
-v /path_for_data_persistence:/workspace \
-e C9USER=c9user \
-e C9PASSWORD=c9password \
--name c9sdk_server tomerfi/c9sdk_docker:latest" \
org.label-schema.docker.params="\
C9USER=Your user name | \
C9PASSWORD=Your password" \
license="MIT" \
maintainer="Tomer Figenblat <tomer.figenblat@gmail.com>"

RUN apt-get update && apt-get install -y git locales tmux zip

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
&& locale-gen

RUN git clone https://github.com/c9/core.git /opt/c9sdk \
&& /opt/c9sdk/scripts/install-sdk.sh

WORKDIR /workspace

VOLUME /workspace

COPY LICENSE VERSION ./

EXPOSE 8080/tcp

ENV C9USER="c9user" C9PASSWORD="c9password"

ENTRYPOINT ["/bin/sh", "-c", "node /opt/c9sdk/server.js -p 8080 -w /workspace/ -l 0.0.0.0 -a $C9USER:$C9PASSWORD"]

HEALTHCHECK --interval=30s --timeout=30s --start-period=20s --retries=3 \
CMD ["/bin/sh", "-c",  "if [ $(curl -L -o /dev/null -s -w %{http_code} -u $C9USER:$C9PASSWORD --basic http://localhost:8080) -ne 200 ]; then exit 1; fi"]
