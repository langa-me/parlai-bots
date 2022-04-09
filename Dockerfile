FROM nvidia/cuda:11.5.0-base-ubuntu20.04
USER root
RUN apt-get update
RUN apt-get install -y --no-install-recommends python3.8 python3-pip build-essential gcc git && pip3 install virtualenv
# TODO: optimise
RUN virtualenv /opt/venv
# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

# ARG USER=docker
# ARG UID=1000
# ARG GID=1000
# # default password for user
# ARG PW=docker
# # Option1: Using unencrypted password/ specifying password
# RUN useradd -m ${USER} --uid=${UID} && echo "${USER}:${PW}" | chpasswd
# RUN mkdir -p /home/${USER}
# RUN chown ${USER} /home/${USER}
# # Setup default user, when enter docker container
# WORKDIR /home/${USER}

RUN git clone https://github.com/facebookresearch/ParlAI
# WORKDIR /home/${USER}/ParlAI
WORKDIR /ParlAI
COPY ./tasks ./parlai_internal/tasks
COPY ./services ./parlai_internal/services
# RUN pip3 install torch==1.10.1+cpu torchvision==0.11.2+cpu torchaudio==0.10.1+cpu -f https://download.pytorch.org/whl/cpu/torch_stable.html
RUN pip install fairseq spacy nltk transformers fairseq && pip install -e .

# FROM python:3.8-slim AS build-image
# COPY --from=compile-image /opt/venv /opt/venv

# Make sure we use the virtualenv:
# ENV PATH="/opt/venv/bin:$PATH"
# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Copy local code to the container image.
# ENV APP_HOME /app
# WORKDIR $APP_HOME
# COPY run.py .
COPY run.py ./parlai_internal/run.py
# ENV PORT 8080
# run nltk.download('stopwords')
RUN python3 -m nltk.downloader stopwords
USER ${UID}:${GID}

ENTRYPOINT ["/opt/venv/bin/python", "./parlai_internal/run.py"]
CMD ["--config_path", "/etc/secrets/config.yaml", "--port", "8080"]