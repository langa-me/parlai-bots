FROM python:3.8-slim AS compile-image
RUN apt-get update
RUN apt-get install -y --no-install-recommends build-essential gcc && pip3 install virtualenv
# TODO: this dockerfile is broken, look cpu
RUN virtualenv /opt/venv
# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install transformers fairseq parlai

FROM nvidia/cuda:11.4.2-base-ubuntu20.04
FROM python:3.8-slim

COPY --from=compile-image /opt/venv /opt/venv

# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"
# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY run.py .

ENTRYPOINT ["python", "run.py"]
CMD ["--config_path", "./config.yaml", "--port", "8080"]