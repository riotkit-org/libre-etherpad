FROM ghcr.io/nicholaswilde/etherpad:version-1.8.18

ARG ETHERPAD_PLUGINS="ep_adminpads2 ep_desktop_notifications ep_announce ep_themes_ext ep_inline_voting ep_prometheus ep_message_all ep_mypads"

USER root
RUN mkdir -p /root/.npm/_logs
WORKDIR /opt/etherpad-lite

RUN \
  set -xe; \
  for PLUGIN_NAME in ${ETHERPAD_PLUGINS}; do npm install "${PLUGIN_NAME}" || exit 1; done && \
  chmod -R g=u . && \
	chown -R etherpad:0 /opt/etherpad-lite && \
	chown -R 5001:65533 "/root/.npm"
USER etherpad

CMD ["node", "--experimental-worker", "node_modules/ep_etherpad-lite/node/server.js"]
