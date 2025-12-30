.PHONY: docker-build all help

IMAGE_TAG ?= latest
REGISTRY ?= ghcr.io/kristophercrawford333/simple-web-server
IMAGE_DESCRIPTION ?= $(shell grep 'org.opencontainers.image.description=' Dockerfile | sed 's/.*="\([^"]*\)".*/\1/')

all: docker-build

docker-build:
	docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t $(REGISTRY):$(IMAGE_TAG) --output type=registry .

help:
	@echo "Available targets:"
	@echo "  all             Build and push the Docker image (default)"
	@echo "  docker-build    Build the Docker image"
	@echo "  help            Show this help message"
