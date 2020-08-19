FROM alpine:latest
ARG VERSION=2.9.11

RUN \
  apk add \
    curl \
    openssh-client \
    python3 \
    py3-boto \
    py3-boto3 \
    py3-botocore \
    py3-dateutil \
    py3-httplib2 \
    py3-jinja2 \
    py3-paramiko \
    py3-pip \
    py3-setuptools \
    py3-yaml \
    tar && \
  pip install --upgrade pip && \
  pip list && pip install docker && pip list && \
  rm -rf /var/cache/apk/*

RUN which python3
RUN cp /usr/bin/python3 /usr/bin/python
RUN mkdir /etc/ansible/ /ansible

RUN \
  curl -fsSL https://releases.ansible.com/ansible/ansible-${VERSION}.tar.gz -o ansible.tar.gz && \
  tar -xzf ansible.tar.gz -C ansible --strip-components 1 && \
  rm -fr ansible.tar.gz /ansible/docs /ansible/examples /ansible/packaging

RUN mkdir -p /ansible/playbooks
WORKDIR /ansible/playbooks

ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV PATH /ansible/bin:$PATH
ENV PYTHONPATH /ansible/lib/

ENTRYPOINT ["ansible-playbook"]
