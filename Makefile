.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build-pdns-db: ## Build pdns database docker

build-pdns-server: ## Build pdns docker
		@cd docker/pdns-server && \
		sudo docker build . -t pdns --build-arg PDNS_VERSION=4.0.4-1pdns.jessie \
									--build-arg PDNS_MYSQL_VERSION=4.0.4-1pdns.jessie
build-pdns-recursor: ## Build pdns-recursor docker

build: build-pdns-server build-pdns-recursor ## Build all dockers
