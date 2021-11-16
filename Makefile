VERSION_CPU ?= latest-cpu
VERSION_GPU ?= latest-gpu

docker_cpu:
	docker build -t louis030195/ava:${VERSION_CPU} . -f ./bot.cpu.Dockerfile
	docker tag louis030195/ava:${VERSION_CPU} louis030195/ava:${VERSION_CPU}
	docker push louis030195/ava:${VERSION_CPU}

docker_gpu:
	docker build -t louis030195/ava:${VERSION_GPU} . -f ./bot.gpu.Dockerfile
	docker tag louis030195/ava:${VERSION_GPU} louis030195/ava:${VERSION_GPU}
	docker push louis030195/ava:${VERSION_GPU}