#!/usr/bin/env bash

# WORK IN PROGRESS

dockerfile=$1
ssh_target=$2

local_builder=docker
which $local_builder
[[ $? -ne 0 ]] && local_builder=podman
which $local_builder
echo "Err: need docker or podman installed to build sif from Dockerfile" && exit 1

$local_builder build -t 
