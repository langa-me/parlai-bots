FROM python:3.8-slim AS compile-image
RUN apt-get update
RUN apt-get install -y --no-install-recommends build-essential git gcc && pip3 install virtualenv

RUN virtualenv /opt/venv
# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

RUN git clone https://github.com/facebookresearch/ParlAI
RUN pip install transformers fairseq ./ParlAI

# FROM python:3.8-slim AS build-image
FROM nvidia/cuda:11.4.2-base-ubuntu20.04 AS build-image
COPY --from=compile-image /opt/venv /opt/venv

# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"
# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY tasks .

ENTRYPOINT ["python", "run.py"]
CMD ["--config_path", "./config.yaml", "--port", "8080"]