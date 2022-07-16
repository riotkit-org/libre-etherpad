FROM etherpad/etherpad:1.8.0 as versionProvider
ADD ./Dockerfile /tmp/Dockerfile
RUN cat /tmp/Dockerfile | grep "as versionProvider" | grep -v "RUN cat" | awk '{print $2}' | cut -d ":" -f 2 > /tmp/etherpadVersion

FROM alpine:3.15.4 as base

FROM base as dl
COPY --from=versionProvider /tmp/etherpadVersion /tmp/etherpadVersion
WORKDIR /tmp
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    wget=1.21.2-r2 && \
  echo "**** download haste ****" && \
  mkdir /app && \
  wget -q --progress=dot:giga "https://github.com/ether/etherpad-lite/archive/$(cat /tmp/etherpadVersion).tar.gz" && \
  tar -xvf "$(cat /tmp/etherpadVersion).tar.gz" -C /app --strip-components 1
WORKDIR /app
RUN \
  echo "**** cleanup ****" && \
  rm -rf \
    ./*.md \
    .github \
    .gitignore \
    Dockerfile \
    doc \
    Makefile \
    settings.json\
    src/node_modules

FROM base
ARG BUILD_DATE
ARG ETHERPAD_PLUGINS="ep_adminpads2 ep_announce ep_themes_ext ep_inline_voting ep_prometheus ep_mypads ep_etherpad-lite ep_message_all ep_desktop_notifications"
LABEL maintainer="rotkit-org"
ENV NODE_ENV=production
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    nodejs=16.14.2-r0 \
    tzdata=2022a-r0 \
    npm=8.1.3-r0 && \
  adduser -S etherpad --uid 5001 && \
  mkdir /opt/etherpad-lite && \
	echo "**** cleanup ****" && \
  rm -rf /tmp/*
WORKDIR /opt/etherpad-lite
COPY --from=dl /app ./
COPY --from=dl /app/settings.json.docker /opt/etherpad-lite/settings.json
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN \
  echo "**** install packages ****" && \
  bin/installDeps.sh && \
  rm -rf ~/.npm/_cacache && \
  echo "**** install plugins ****" && \
  for PLUGIN_NAME in ${ETHERPAD_PLUGINS}; do npm install "${PLUGIN_NAME}" || exit 1; done && \
  echo "**** change permissions ****" && \
  chmod -R g=u . && \
	chown -R etherpad:0 /opt/etherpad-lite && \
	chown -R 5001:65533 "/root/.npm"
USER etherpad
EXPOSE 9001
VOLUME \
  /opt/etherpad-lite/var \
  /opt/etherpad-lite
CMD ["node", "--experimental-worker", "node_modules/ep_etherpad-lite/node/server.js"]
