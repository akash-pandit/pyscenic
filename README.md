# Nextflow-based pySCENIC Pipeline

An AnnData-native Nextflow pipeline built to make pySCENIC accessible for researchers with high-performance computing (HPC) cluster access. Built as a component of my senior capstone project for the Bioinformatics concentration of the Biomolecular Engineering & Bioinformatics major at UC Santa Cruz.

### Table of Contents
1. [Prerequisites](#prerequisites)
2. [Usage](#usage)
3. [Output Structure](#output-structure)
4. [Pipeline Parameters](#pipeline-parameters)

## Prerequisites

You must have access to a HPC cluster with the SLURM scheduler to use this pipeline, a resource offered by most universities. Support for local and cloud-based (e.g. AWS Batch) runtime environments does not currently exist, but may be implemented in the future. 

The following software must exist on your cluster:
- Nextflow with DSL-2 support
- Singularity or Apptainer

You must also build the singularity image file from the provided Dockerfile in `containers/` on your local machine, then transfer the resulting `.sif` file to your cluster by running the following (locally):

```bash
# ON A LOCAL MACHINE
cd containers
bash build.sh
scp [sif filepath] user@hostname:[expected sif filepath]  # copy sif file to cluster 
```

**On the cluster**, you must then edit the `io_container` variable under the `params` block in `nextflow.config` to the `[expected sif filepath]` provided with scp (the location of the sif file). Alternatively, you can pass the full filepath at pipeline runtime with the `--io_container <sif filepath>` flag. 

## Usage

```bash
# ASSUMED PREREQUISITES:
# - working on a SLURM-based cluster
# - nextflow available as a module
# - singularity / apptainer already installed and active
# - .sif file already built locally and copied to cluster
# - params.io_container in nextflow.config reflects correct .sif filepath on cluster

# 1. download required databases
cd databases
bash download.sh
cd ..

# 2. load required modules
module load nextflow

# 3. execute pipeline
nextflow run main.nf --h5ad <input> --outdir <output directory> [--replicates <number>]
```

## Output Structure

```
output-directory/
├── aucell/
│   └── auc_mtx.csv         # regulon activation scores per cell
├── cistarget/              
│   └── regulons.csv        # regulons: pruned co-expression modules supported by cistarget databases
├── grn/                    
│   └── adj.tsv             # average of co-expression modules of 50 random runs
└── annotated.h5ad          # Resulting h5ad object annotated with auc_mtx.csv in adata.obsm['X_scenic_auc'] and regulons in adata.uns['scenic_regulons']
```

## Pipeline Parameters

| Flag | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `--h5ad <path>` | Path | Yes | N/A | The path to an AnnData object expecting raw counts in `adata.X`. Selecting and subsetting highly variable genes is highly recommended. |
| `--outdir <path>` | Path | Yes | results/ | Output directory to write files to. See [Output Structure](#output-structure) for expected output. |
| `--replicates <number>` | integer | Yes | 10 | Number of replicates to average for GRN step. 10+ is highly recommended due to stochastic nature. |
| `--partition <cluster partition>` | string | No | null | Specifies cluster partition to execute pipeline with. If left empty (null), it is left to the scheduler. |
| `--io_container <path>` | Path | Yes | `/home/aspandit/lab/scenic/containers/h5ad-to-loom.sif` | Path to singularity image file for I/O pipeline steps. Highly suggested to edit in `nextflow.config`. Future update will use image pushed to container registry instead. |
