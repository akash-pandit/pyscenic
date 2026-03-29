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

# nextflow run main.nf --h5ad data/poscablo-full-hvg.h5ad --outdir results/full-dataset
nextflow run main.nf --h5ad data/preprocessed/poscablo-old-subset-hvg.h5ad --outdir results/old-subset
# nextflow run main.nf --h5ad data/poscablo-young-subset-hvg.h5ad --outdir results/young-subset

