#!/usr/bin/env bash

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=24:00:00
#SBATCH --job-name=scenic-nf
#SBATCH --mail-type=ALL
#SBATCH --mail-user=aspandit@ucsc.edu

cd /home/aspandit/lab/scenic

module load nextflow
# singularity default on hb

nextflow run main.nf --h5ad data/poscablo-raw-hvg.h5ad > nextflow.log 2>&1

