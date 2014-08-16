FROM phusion/baseimage:0.9.11

RUN printf 'APT::Get::Assume-Yes "true";\nAPT::Install-Recommends "false";\n' > /etc/apt/apt.conf.d/99-defaults

# Add nginx repository
RUN echo "deb http://nginx.org/packages/ubuntu/ trusty nginx" > /etc/apt/sources.list.d/nginx.list
RUN curl --silent -L http://nginx.org/keys/nginx_signing.key | apt-key add -
RUN apt-get update

# Registry
RUN apt-get install git
RUN apt-get install build-essential libevent-dev libssl-dev liblzma-dev libffi-dev python-dev python-pip
RUN git clone https://github.com/dotcloud/docker-registry.git /opt/docker-registry
WORKDIR /opt/docker-registry
RUN git checkout tags/0.7.2
RUN pip install /opt/docker-registry
RUN pip install --upgrade /opt/docker-registry
RUN pip install git+git://github.com/dmp42/docker-registry-driver-gcs#egg=docker-registry-driver-gcs

# Redis
RUN apt-get install redis-server

# nginx
RUN apt-get install openssl libssl1.0.0
RUN apt-get install nginx=1.6.1-1~trusty

# Disable cron sshd syslog
RUN rm /etc/my_init.d/00_regen_ssh_host_keys.sh

ADD image-files /

CMD ["/sbin/my_init"]
