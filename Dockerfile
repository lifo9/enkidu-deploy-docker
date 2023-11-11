FROM alpine:3.18.4

ENV PATH="/home/deploy/.fly/bin:$PATH"

RUN apk --update --no-cache add \
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
