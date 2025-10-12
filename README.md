# easyepg-lite
A docker container for running [easyepg-lite](https://github.com/sunsettrack4/script.service.easyepg-lite#easyepg-lite)

## Getting started

**Start the container with `docker run`**

```sh
docker run -d \
  --name easyepg-lite \
  -p 4000:4000 \
  --mount type=bind,source="/path/to/data/dir",target=/data \
  --restart=unless-stopped \
  myrck/easyepg-lite:latest
```

> [!NOTE]  
> The container will run using a user uid and gid 1000 by default, add `--user <your-UID>:<your-GID>` to the docker command to adjust it if necessary. Make sure this match the permissions of your data directory.

**or `docker-compose`**

```yaml
services:
  easyepg-lite:
    image: myrck/easyepg-lite:latest
    container_name: easyepg-lite
    volumes:
      - /path/to/data/dir:/data
    ports:
      - 4000:4000
    user: 1000:1000
    restart: unless-stopped
```
