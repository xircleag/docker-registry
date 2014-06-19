# docker-registry

Source repository for [layer/docker-registry][docker-registry]

Bootstrap a GCS-backed private Docker registry behind nginx with ssl
and basic auth.

Tested with [CoreOS][coreos].  Example cloud-config below.  The intent
is to have a private GCS-backed Docker registry running in one
command.

[docker-registry]:https://registry.hub.docker.com/u/layer/docker-registry/
[coreos]:https://coreos.com/


## example cloud-config

    #cloud-config

    coreos:
      units:
        - name: docker-registry.service
          command: start
          enable: true
          content: |
            [Unit]
            Description=Docker Registry
            After=docker.service
            Requires=docker.service

            [Service]
            ExecStartPre=-/usr/bin/docker rm -f docker-registry
            ExecStartPre=/usr/bin/docker pull layer/docker-registry
            ExecStart=/usr/bin/docker run --rm --name=docker-registry -e "GCS_BUCKET=gcs-bucket" -e "GCS_KEY=gcs-key -e "GCS_SECRET=gcs-secret" -e "REGISTRY_HOSTNAME=registry.example.com" -v /srv/etc-nginx-ssl.crt:/etc/nginx/ssl.crt -v /srv/etc-nginx-ssl.key:/etc/nginx/ssl.key -v /srv/etc-nginx-htpasswd:/etc/nginx/htpasswd -p 443:443 layer/docker-registry
            Restart=always
    write_files:
      - path: /opt/bin/docker-nsenter
        permissions: 0755
        content: |
          #!/bin/bash

          if [ -z "$1" ]; then
              echo >&2 "usage: $(basename $0) <container>"
              exit 1
          fi
          container=$1

          docker_pid=$(docker inspect -f '{{ .State.Pid }}' $container)
          command="sudo nsenter -p -u -m -i -n -t $docker_pid"

          echo $command
          $command
      - path: /srv/etc-nginx-htpasswd
        content: |
          output of `htpasswd -nb user password`
      - path: /srv/etc-nginx-ssl.crt
        content: |
          -----BEGIN CERTIFICATE-----
          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
          -----END CERTIFICATE-----
          -----BEGIN CERTIFICATE-----
          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
          -----END CERTIFICATE-----
      - path: /srv/etc-nginx-ssl.key
        content: |
          -----BEGIN PRIVATE KEY-----
          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
          -----END PRIVATE KEY-----
