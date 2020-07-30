.PHONY: iso clean distclean

DEBIAN_RELEASE = "buster"

WORKDIR = /build
MIRROR  = "$(shell pwd)/mirror"
EXTRA   = "$(shell pwd)/extra"
IMAGE   = "$(shell pwd)/image"
TMP     = "$(shell pwd)/tmp"

iso:
	docker run --env DEBIAN_RELEASE=$(DEBIAN_RELEASE) \
                   --mount type=bind,source=$(shell pwd),target=$(WORKDIR) \
		   --mount type=bind,source=$(MIRROR),target=$(WORKDIR)/mirror,readonly \
		   --mount type=bind,source=$(EXTRA),target=$(WORKDIR)/extra,readonly \
                   --mount type=bind,source=$(IMAGES),target=$(WORKDIR)/image \
                   --mount type=bind,source=$(TMP),target=$(WORKDIR)/tmp \
		   --user $(shell id -u "${USER}"):$(shell id -g "${USER}") \
		   penguinspiral/seed-installer:buster-slim

clean:
	rm --force \
           --recursive \
           debian-cd/ $(TMP)/* 

distclean: clean
	rm --force \
           --recursive \
           $(IMAGE)/* $(EXTRA)/*
