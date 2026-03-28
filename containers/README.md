# containers

A custom docker-based environment for the pipeline input-output layers. 

1. Run `build.sh` on your local machine using root to build a singularity image file from the provided dockerfile. 
2. Use `scp` or `sftp` to copy the sif file to your cluster
3. On the cluster, edit the `container` path in `main.nf` processes `h5ad-to-loom` and `add-auc-to-h5ad` with the absolute path of the copied sif file.

> TBD: push sif file to container registry & remove dependency on hardcoded sif paths

- `Dockerfile`: the environment definition, written for Docker/podman
- `build.sh`: A build script for building a singularity image file (sif) from a Dockerfile. 