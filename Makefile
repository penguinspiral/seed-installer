.PHONY: iso clean distclean

DEBIAN_RELEASE = "bullseye"

WORKDIR      = /build
MIRROR       = "$(shell pwd)/mirror"
LOCAL_MIRROR = "$(shell pwd)/local/mirror"
LOCAL_KEYS   = "$(shell pwd)/local/keys"
EXTRA        = "$(shell pwd)/extra"
IMAGE        = "$(shell pwd)/image"
TMP          = "$(shell pwd)/tmp"

iso:
	docker run --env DEBIAN_RELEASE=$(DEBIAN_RELEASE) \
                   --mount type=bind,source=$(shell pwd),target=$(WORKDIR) \
		   --mount type=bind,source=$(MIRROR),target=$(WORKDIR)/mirror,readonly \
		   --mount type=bind,source=$(LOCAL_MIRROR),target=$(WORKDIR)/local/mirror,readonly \
		   --mount type=bind,source=$(LOCAL_KEYS),target=$(WORKDIR)/local/keys,readonly \
		   --mount type=bind,source=$(EXTRA),target=$(WORKDIR)/extra,readonly \
                   --mount type=bind,source=$(IMAGE),target=$(WORKDIR)/image \
                   --mount type=bind,source=$(TMP),target=$(WORKDIR)/tmp \
		   --user $(shell id -u "${USER}"):$(shell id -g "${USER}") \
                   --rm \
		   penguinspiral/seed-installer:bullseye-slim

clean:
	rm --force \
           --recursive \
           debian-cd/ $(TMP)/* 

distclean: clean
	rm --force \
           --recursive \
           $(IMAGE)/* $(EXTRA)/*
