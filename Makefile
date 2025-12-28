.PHONY: docker-build docker-push help

IMAGE_NAME ?= simple-web-server
IMAGE_TAG ?= latest
REGISTRY ?= ghcr.io/kristophercrawford333/simple-web-server

docker-build:
	docker build --platform linux/amd64 -t $(IMAGE_NAME):$(IMAGE_TAG) -t $(REGISTRY):$(IMAGE_TAG) .

docker-push:
	docker push $(REGISTRY):$(IMAGE_TAG)

help:
	@echo "Available targets:"
	@echo "  docker-build    Build the Docker image (default)"
	@echo "  docker-push     Push the Docker image to registry"
	@echo "  help            Show this help message"
