/**
A DSL-2 Nextflow pipeline for pySCENIC with AnnData objects.

Designed by Akash Pandit (aspandit@ucsc.edu) for BME 230A / the Forsberg lab.

What transcription factors drive the differentiation of old HSCs into 
canonical/non-canonical MkPs?
*/

process h5ad_to_loom {
    container '/home/aspandit/lab/scenic/containers/h5ad-to-loom.sif'

    input:
    path h5ad

    output:
    path 'countmtx.loom'

    script:
    """
    #!/usr/bin/env python

    from pathlib import Path
    from anndata import read_h5ad
    import loompy

    adata = read_h5ad('${h5ad}')

    X = adata.X.toarray() if hasattr(adata.X, 'toarray') else adata.X
    X = X.T
    row_attrs = {'Gene': adata.var_names.to_numpy().astype(str)}
    col_attrs = {'CellID': adata.obs_names.to_numpy().astype(str)}

    loompy.create('countmtx.loom', X, row_attrs=row_attrs, col_attrs=col_attrs)
    """
}

process infer_grn {
    container 'aertslab/pyscenic:0.12.1'

    publishDir "${params.outdir}/grn", mode: 'copy'

    input:
    path loom
    path tfs

    output:
    path 'adj.tsv'

    script:
    """
    arboreto_with_multiprocessing.py \\
        ${loom} \\
        ${tfs} \\
        -m grnboost2 \\
        -o adj.tsv \\
        --num_workers ${task.cpus} \\
        --seed 67
    """ 
}

process cisTarget {
    container 'aertslab/pyscenic:0.12.1'

    publishDir "${params.outdir}/cistarget", mode: 'copy'

    input:
    path adj
    path rankingsdb
    path scoresdb
    path motifs
    path loom

    output:
    path 'regulons.csv'

    script:
    """
    pyscenic ctx \\
        ${adj} \\
        ${rankingsdb} \\
        ${scoresdb} \\
        --annotations_fname ${motifs} \\
        --expression_mtx_fname ${loom} \\
        --output regulons.csv \\
        --mask_dropouts \\
        --num_workers ${task.cpus} \\
        --cell_id_attribute CellID \\
        --gene_attribute Gene \\
    """
}

process aucell {
    container 'aertslab/pyscenic:0.12.1'

    publishDir "${params.outdir}/aucell", mode: 'copy'

    input:
    path loom
    path regulons

    output:
    path 'auc_mtx.csv'

    script:
    """
    pyscenic aucell \\
        ${loom} \\
        ${regulons} \\
        --output auc_mtx.csv \\
        --num_workers ${task.cpus} \\
        --seed 67
    """
}

process add_auc_to_h5ad {
    container '/home/aspandit/lab/scenic/containers/h5ad-to-loom.sif'

    publishDir "${params.outdir}", mode: 'copy'

    input:
    path h5ad
    path auc_csv

    output:
    path 'annotated.h5ad'

    script:
    """
    #!/usr/bin/env python

    import anndata
    import pandas as pd

    adata = anndata.read_h5ad('${h5ad}')
    auc  = pd.read_csv('${auc_csv}', index_col=0)

    # reindex to match adata.obs_names order, fill missing with 0
    auc = auc.reindex(adata.obs_names, fill_value=0)

    adata.obsm['X_scenic_auc'] = auc.values
    adata.uns['scenic_regulons'] = list(auc.columns)

    adata.write_h5ad('annotated.h5ad')
    """
}


workflow {
    if (!params.h5ad) error "Please provide --h5ad"

    h5ad_ch     = Channel.fromPath(params.h5ad).first()  // can be reused
    tfs_ch      = Channel.fromPath(params.tfs)
    rankings_ch = Channel.fromPath(params.rankings)
    scores_ch   = Channel.fromPath(params.scores)
    motifs_ch   = Channel.fromPath(params.motifs)

    loom_ch     = h5ad_to_loom(h5ad_ch).first()  // can be reused in adj/regulons
    adj_ch      = infer_grn(loom_ch, tfs_ch)
    regulons_ch = cisTarget(adj_ch, rankings_ch, scores_ch, motifs_ch, loom_ch)
    auc_ch      = aucell(loom_ch, regulons_ch)
    add_auc_to_h5ad(h5ad_ch, auc_ch)
}
