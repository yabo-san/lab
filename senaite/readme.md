# senaite deployment
## dependencies:
- msgfmt (came installed on arch)
- [docker compose](https://gist.github.com/kashifulhaque/3d56028729c29f9d6a353a6615d1beb9)
## project structure:
- senaite.core.po
  - language file for overwriting verbage
- dockerfile
  - instructions for mounting language file to image
- docker-compose.yaml
  - instructions for deploying senaite

## step 1:
- generate the .mo file
  - msgfmt senaite.core.po -o senaite.core.mo
## step 2:
- docker compose up --build -d
  - build flag specifies to rebuild image
## step 3:
- docker ps
  - check status of container

## step 3.5:
- docker exec -it <container ID you can get it with docker ps> /bin/bash
  - get inside the app container to verify changes
  - ie: cat /home/senaite/senaitelims/eggs/cp27mu/senaite.core-2.6.0-py2.7.egg/senaite/core/locales/en_US/LC_MESSAGES/senaite.core.po
