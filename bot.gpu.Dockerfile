FROM python:3.8-slim AS compile-image
RUN apt-get update
RUN apt-get install -y --no-install-recommends build-essential gcc && pip3 install virtualenv
# TODO: this dockerfile is broken, look cpu

# FROM nvidia/cuda:11.4.2-base-ubuntu20.04
