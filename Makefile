.PHONY: docker-build docker-push all help

IMAGE_NAME ?= simple-web-server
IMAGE_TAG ?= latest
REGISTRY ?= ghcr.io/kristophercrawford333/simple-web-server

all: docker-build docker-push

docker-build:
	docker build --platform linux/amd64 --no-cache -t $(IMAGE_NAME):$(IMAGE_TAG) -t $(REGISTRY):$(IMAGE_TAG) .

docker-push:
	docker push $(REGISTRY):$(IMAGE_TAG)

help:
	@echo "Available targets:"
	@echo "  all             Build and push the Docker image (default)"
	@echo "  docker-build    Build the Docker image"
	@echo "  docker-push     Push the Docker image to registry"
	@echo "  help            Show this help message"
