#!/usr/bin/env bash

# Builds singularity image (.sif) from Dockerfile. Requires (docker or podman) and (singularity or apptainer).
# Requires root to execute. Builds dockerfile in script execution directory.
# 
# TBD: add ssh target for automatic transfer of built .sif image

# color codes

RED="\e[31m"
LRED="\e[1;31m"
BLUE="\e[34m"
LBLUE="\e[1;34m"
RESET="\e[0m"

# utility functions

log() { echo -e "${BLUE}[build.sh] ${LBLUE}LOG${RESET}: $1"; }
err() { echo -e "${RED}[build.sh] ${LRED}ERR${RESET}: $1" >&2 && exit 1; }

# check user permissions

[[ $(id -u) -ne 0 ]] && err "this script must be run as root/administrator"

# check software dependencies (docker/podman, singularity/apptainer)

docker --version > /dev/null 2>&1; DOCKER_IS_INSTALLED=$?

if [[ DOCKER_IS_INSTALLED -ne 0 ]]; then
    log "docker not found, checking for podman"
    podman --version > /dev/null 2>&1; PODMAN_IS_INSTALLED=$?

    [[ PODMAN_IS_INSTALLED -ne 0 ]] && err "podman not found, cannot build/export dockerfile, exiting..."

    DOCKER_BUILDER="podman"
else
    DOCKER_BUILDER="docker"
fi

which singularity > /dev/null 2>&1; SINGULARITY_IS_INSTALLED=$?

if [[ SINGULARITY_IS_INSTALLED -ne 0 ]]; then
    log "singularity not found, checking for apptainer"
    which apptainer > /dev/null 2>&1; APPTAINER_IS_INSTALLED=$?

    [[ APPTAINER_IS_INSTALLED -ne 0 ]] && err "apptainer not found, cannot convert image to singularity image file format, exiting..."

    SIF_BUILDER="apptainer"
else
    SIF_BUILDER="singularity"
fi

# build local image

$DOCKER_BUILDER build -t local/h5ad-to-loom .
[[ $? -ne 0 ]] && err "image build process failed, exiting..."

# convert local image to tarball (works with both docker/podman)

$DOCKER_BUILDER save -o h5ad-to-loom.tar local/h5ad-to-loom
[[ $? -ne 0 ]] && err "image compression process failed, exiting..."

# build singularity image

sudo $SIF_BUILDER build h5ad-to-loom.sif docker-archive://h5ad-to-loom.tar
[[ $? -ne 0 ]] && err "image compression process failed, exiting..."

rm h5ad-to-loom.tar

log "done :))"
