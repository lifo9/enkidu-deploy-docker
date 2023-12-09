FROM alpine:3.19.0

ENV PATH="/home/deploy/.fly/bin:/venv/bin:$PATH"

RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories && \
  apk --update --no-cache add \
  # install running dependencies
  bash \
  git \
  jq \
  nodejs-current \
  openssh-client \
  py3-pip \
  python3 \
  sshpass \
  terraform \
  curl

COPY requirements.txt .

RUN apk --update add --virtual .build-deps \
  # install build dependencies
  build-base\
  libffi-dev \
  gcc \
  npm \
  python3-dev \
  unzip \
  # install ansible
  && python3 -m venv /venv \
  && pip install --upgrade pip \
  && pip install -r requirements.txt \
  # install Bitwarden client
  && npm install -g @bitwarden/cli \
  # cleanup
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

RUN adduser -S deploy

USER deploy

RUN ansible-galaxy collection install kubernetes.core community.general \
  # install flyctl
  && curl -L https://fly.io/install.sh | sh

CMD [ "/bin/bash" ]
