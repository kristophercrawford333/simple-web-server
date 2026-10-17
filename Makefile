GOCMD=go
GOTEST=$(GOCMD) test
GOVET=$(GOCMD) vet
BINARY_NAME = simpleHttpServer
IMAGE_NAME = simple-web-server
IMAGE_TAG ?= latest
REGISTRY ?= ghcr.io/kristophercrawford333/$(IMAGE_NAME)
IMAGE_DESCRIPTION ?= $(shell grep 'org.opencontainers.image.description=' Dockerfile | sed 's/.*="\([^"]*\)".*/\1/')
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: all test build docker-build docker-test clean

all: help

## Build:
build: ## Builds a go binary for this system in out/bin/
	mkdir -p out/bin
	$(GOCMD) build -o out/bin/$(BINARY_NAME) .

vet: ## go vet
	go vet ./...

fmt: ## Runs go formatter.
	go fmt ./...

tidy: ## Runs tidy to fix go.mod dependencies.
	go mod tidy

## Test
test: ## Runs tests and create generates coverage report.
	make tidy
	go test -v -timeout 10m ./... -coverprofile=coverage.out -json > report.json

coverage: ## displays test coverage report in html mode.
	make test
	go tool cover -html=coverage.out

run: ## Runs the go binary.
	make build
	chmod +x $(BINARY_NAME)
	$(BINARY_NAME)

## Docker
docker-build: ## Build and push a docker image to the registry
	make docker-roast
	docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t $(REGISTRY):$(IMAGE_TAG) --output type=registry .

docker-test: ## Build a docker image to run locally
	make docker-roast
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

docker-roast:
	droast

## Cleanup
clean: ## Clean up old images, docker containers, build artifacts
	@images=$$(docker image ls -q --filter "reference=$(IMAGE_NAME)"); if [ -n "$$images" ]; then docker image rm $$images; fi
	@containers=$$(docker container ps -qa --filter "ancestor=$(IMAGE_NAME)"); if [ -n "$$containers" ]; then docker container rm -f $$containers; fi
	rm -rf out/bin
	rm -f report.json coverage.out

## Help:
help: ## Show this help.
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)