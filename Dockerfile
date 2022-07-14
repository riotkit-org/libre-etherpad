FROM ghcr.io/nicholaswilde/etherpad:version-1.8.18

ARG ETHERPAD_PLUGINS="ep_adminpads2 ep_announce ep_themes_ext ep_inline_voting ep_prometheus_exporter ep_mypads"

USER root
RUN mkdir -p /root/.npm/_logs
RUN npm i -g npm@latest
RUN rm -rf node_modules package-lock.json

RUN \
  cd /opt/etherpad-lite/app; \
  set -xe; \
  for PLUGIN_NAME in ${ETHERPAD_PLUGINS}; do npm install "${PLUGIN_NAME}" || exit 1; done && \
  chmod -R g=u . && \
	chown -R etherpad:0 /opt/etherpad-lite && \
	chown -R 5001:65533 "/root/.npm"
USER etherpad
