VERSION ?= 0.1.0
GCLOUD_PROJECT:=$(shell gcloud config list --format 'value(core.project)' 2>/dev/null)

ifeq ($(GCLOUD_PROJECT),langame-dev)
$(info "Using develoment configuration")
REGISTRY ?= 5306t2h8.gra7.container-registry.ovh.net/dev/parlai
else
$(info "Using production configuration")
REGISTRY ?= 5306t2h8.gra7.container-registry.ovh.net/prod/parlai
endif

prod: ## Set the GCP project to prod
	gcloud config set project langame-86ac4

dev: ## Set the GCP project to dev
	gcloud config set project langame-dev

docker/build: ## [Local development] build the docker image
	docker build -t ${REGISTRY}:${VERSION} -t ${REGISTRY}:latest . -f ./Dockerfile

docker/run: docker/build ## [Local development] run the docker container
	docker run --rm --name parlai_${VERSION} \
		--network host \
		-p 8083:8083 \
		-v $(shell pwd)/data:/ParlAI/data \
		-v $(shell pwd)/tasks/ava/blender_90m.yaml:/etc/secrets/config.yaml ${REGISTRY}:${VERSION} \
		--port 8083 \
		--config_path /etc/secrets/config.yaml

# -v $(shell pwd)/tasks/ava/seeker_cpu.yaml:/etc/secrets/config.yaml ${REGISTRY}:${VERSION} \

docker/push: docker/build ## [Local development] push the docker image to reg
	docker push ${REGISTRY}:${VERSION}
	docker push ${REGISTRY}:latest

.PHONY: help

help: # Run `make help` to get help on the make commands
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'