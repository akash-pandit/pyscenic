#!/usr/bin/env bash
set -euo pipefail

BASE="https://resources.aertslab.org/cistarget"
FEATHER="${BASE}/databases/mus_musculus/mm10/refseq_r80"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Downloading TF list..."
wget -P "$DIR" "${BASE}/tf_lists/allTFs_mm.txt"

echo "Downloading motif annotation table..."
wget -P "$DIR" "${BASE}/motif2tf/motifs-v10nr_clust-nr.mgi-m0.001-o0.0.tbl"

echo "Downloading cisTarget databases..."
wget -P "$DIR" "${FEATHER}/mm10_10kbp_up_10kbp_down_full_tx_v10_clust.genes_vs_motifs.rankings.feather"
wget -P "$DIR" "${FEATHER}/mm10_10kbp_up_10kbp_down_full_tx_v10_clust.genes_vs_motifs.scores.feather"

echo "Done"