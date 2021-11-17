FROM python:3.8-slim AS compile-image
RUN apt-get update
RUN apt-get install -y --no-install-recommends build-essential gcc git && pip3 install virtualenv
# TODO: optimise
RUN virtualenv /opt/venv
# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"
RUN git clone https://github.com/facebookresearch/ParlAI
WORKDIR /ParlAI
COPY ./tasks ./parlai_internal/tasks
RUN pip install transformers fairseq && pip install -e .

# FROM python:3.8-slim AS build-image
# COPY --from=compile-image /opt/venv /opt/venv

# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"
# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Copy local code to the container image.
# ENV APP_HOME /app
# WORKDIR $APP_HOME
# COPY run.py .
COPY run.py ./parlai_internal/run.py

ENTRYPOINT ["python", "./parlai_internal/run.py"]
CMD ["--config_path", "./config.yaml", "--port", "8080"]