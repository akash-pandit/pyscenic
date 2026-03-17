# A pySCENIC Pipeline for Regulatory Analysis of the Hematopoietic Tree

Final project for BME 230A, builds on the findings of [this paper](https://doi.org/10.1016/j.cell.2024.04.018) published in 2024. 

3 main portions:
- preprocessing: light preparation of anndata objects for pipeline
- pipeline: parses anndata, runs the pySCENIC pipeline, and outputs annotations in copy of anndata (obsm for scores, uns for regulon names)
- analysis: subsequent analysis of regulons for the Poscablo 2024 dataset

> README under construction, proper documentation coming soon...