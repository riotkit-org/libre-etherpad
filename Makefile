VERSION = $(shell ./get-version.sh)

build: clone build-docker

clone:
	rm -rf etherpad-lite 2>/dev/null || true
	git clone https://github.com/ether/etherpad-lite -b ${VERSION}

build-docker:
	cd etherpad-lite \
	&& docker build . --build-arg ETHERPAD_PLUGINS="ep_adminpads2 ep_announce ep_themes_ext ep_inline_voting ep_prometheus ep_mypads ep_etherpad-lite ep_message_all ep_desktop_notifications" -t ghcr.io/riotkit-org/libre-etherpad:${VERSION}

push:
	docker push ghcr.io/riotkit-org/libre-etherpad:${VERSION}
