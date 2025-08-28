# 🍯 HiveDrop

A sweet and simple file server, powered by [unprivileged (rootless) Nginx](https://hub.docker.com/r/nginxinc/nginx-unprivileged).

Every sunday at 2200 UTC a new container image is being build from the main branch, that contains all the downloaded files.

The latest image can be pulled from `ghcr.io/watskebart/hivedrop:latest`

Start HiveDrop with `docker run --rm -p 8080:8080 ghcr.io/watskebart/hivedrop:latest` navigate in your browser to [http://localhost:8080](http://localhost:8080) to view HiveDrop.

## Directory structure

### 🌼 Pollen (download lists)

The pollen directory contains lists of files to be downloaded by their respective downloader application.

### 🐝 Honey (downloaded files)

The honey directory contains the downloaded files, which were downloaded by the download lists from the pollen directory.

## Downloaded files

### Visual Code Extensions

>Config file: `vscode-extensions.txt`

VS Code extensions are downloaden via a Python package called `offvsix`. This application downloads the `.vsix` files straight from the Microsoft marketplace.

### 🚧 Github Release Puller (WIP)

>Config file: `github-releases.yaml`

Github releases are downloaded by the `github-release-puller`. This application downloads the latest, non pre-release, from a selected Github repository.


