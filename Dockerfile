FROM ghcr.io/nicholaswilde/etherpad:version-1.8.18

ARG ETHERPAD_PLUGINS="ep_adminpads2 ep_announce ep_themes_ext ep_inline_voting ep_prometheus ep_mypads ep_etherpad-lite"

USER root
RUN mkdir -p /root/.npm/_logs
RUN npm i -g npm@latest

WORKDIR /opt/etherpad-lite
RUN \
  set -xe; \
  for PLUGIN_NAME in ${ETHERPAD_PLUGINS}; do npm install "${PLUGIN_NAME}" --no-save --legacy-peer-deps || exit 1; done && \
  chmod -R g=u . && \
	chown -R etherpad:0 /opt/etherpad-lite && \
	chown -R 5001:65533 "/root/.npm"
RUN ln -s /opt/etherpad-lite/src /opt/etherpad-lite/node_modules/ep_etherpad-lite
USER etherpad
