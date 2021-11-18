VERSION_CPU ?= latest-cpu
VERSION_GPU ?= latest-gpu

docker_cpu: ## [Local development] Build Docker image for CPU
	docker build -t louis030195/ava:${VERSION_CPU} . -f ./bot.cpu.Dockerfile
	docker tag louis030195/ava:${VERSION_CPU} louis030195/ava:${VERSION_CPU}
	docker push louis030195/ava:${VERSION_CPU}

docker_gpu: ## [Local development] Build Docker image for GPU
	docker build -t louis030195/ava:${VERSION_GPU} . -f ./bot.gpu.Dockerfile
	# docker tag louis030195/ava:${VERSION_GPU} louis030195/ava:${VERSION_GPU}
	# docker push louis030195/ava:${VERSION_GPU}

install: ## [Local development] Install virtualenv, activate, install requirements, install package.
	@echo "see .gitpod.yml"

.PHONY: help

help: # Run `make help` to get help on the make commands
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'