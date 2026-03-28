#!/usr/bin/env bash

# utility functions
log() { echo "[build.sh] LOG: $0"; }
err() { echo "[build.sh] ERR: $0" >&2 && exit 1; }

# WORK IN PROGRESS

dockerfile=$1
ssh_target=$2

# check user permissions

[[ $(id -u) -ne 0 ]] && err "this script must be run as root/administrator"

# check software dependencies (docker/podman, singularity/apptainer)

which docker; DOCKER_IS_INSTALLED=$?

if [[ DOCKER_IS_INSTALLED -ne 0 ]]; then
    log "docker not found, checking for podman"
    which podman; PODMAN_IS_INSTALLED=$?

    [[ PODMAN_IS_INSTALLED -ne 0 ]] && err "podman not found, cannot build/export dockerfile, exiting..."

    DOCKER_BUILDER="podman"
else
    DOCKER_BUILDER="docker"
fi

which singularity; SINGULARITY_IS_INSTALLED=$?

if [[ SINGULARITY_IS_INSTALLED -ne 0 ]]; then
    log "singularity not found, checking for apptainer"
    which apptainer; APPTAINER_IS_INSTALLED=$?

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

log "done :))"
log "You can push the
