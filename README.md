# Openrelik SQLite Export Worker

Sample for how to export tables from SQLite Database files.

You can add the Worker to your OpenRelik [Getting started](https://openrelik.org/docs/getting-started/) setup by adding the following section to the [```docker-compose.yml```](https://github.com/openrelik/openrelik-deploy/blob/main/docker/docker-compose.yml) file.

```console
  openrelik-worker-sqlite:
      container_name: openrelik-worker-sqlite
      image: europe-west1-docker.pkg.dev/repos-daschwanden/labs/openrelik-worker-sqlite:v0.1
      restart: always
      environment:
        - REDIS_URL=redis://openrelik-redis:6379
      volumes:
        - ./data:/usr/share/openrelik/data
      command: "celery --app=src.app worker --task-events --concurrency=4 --loglevel=INFO -Q openrelik-worker-sqlite"
```
