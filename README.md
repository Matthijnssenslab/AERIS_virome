# AERIS virome visualizations

This repository contains the code supporting all visualizations presented in the paper:

**Uncovering lung virome signatures of COPD severity and acute exacerbations in longitudinally sampled AERIS cohort**

## Repository contents

- [`HPC scripts/`](HPC%20scripts/): Slurm scripts to be executed on high-performance computing cluster, starting from the raw sequencing data and generating the derived data used by the analysis.
- [`COPD_AERIS_virome.Rmd`](COPD_AERIS_virome.Rmd): fully executable R Markdown analysis that generates the visualizations.
- `COPD_AERIS_virome.html`: rendered HTML version of the analysis. 

## Reproducing the visualizations

1. Download the derived data associated with this repository from Zenodo: (https://doi.org/10.5281/zenodo.22014499.).
2. Extract the downloaded files into the repository so that the directories are available under `data/` as shown below.
3. Open `AERIS_virome.Rproj` in RStudio or set the repository root as the working directory.
4. Install the R packages listed in the setup chunk of `COPD_AERIS_virome.Rmd` if they are not already installed.
5. Execute `COPD_AERIS_virome.Rmd` to reproduce the visualizations and analysis output.

## Derived-data structure

```text
data/
├── ABUNDANCES/
│   └── abundance_table.csv
├── BACTERIOME/
│   ├── diversity_table_bact.csv
│   ├── mastertable_bactDADA2.csv
│   └── SraRunTable.csv
├── COUNTS/
│   ├── AERIS.number_raw_reads.txt
│   └── AERIS.number_trimmed_reads.txt
├── METADATA/
│   └── AERIS_virome_metadata.csv
├── PHAGE_ANNOTATION/
│   ├── COMPLETENESS/
│   │   └── quality_summary_R.tsv
│   ├── HOST_PREDICTION/
│   │   └── Host_prediction_to_genus_m90.csv
│   ├── PHAGE_LIFESTYLE/
│   │   └── BC_predict.summary
│   └── PHOLD/
│       ├── AERIS_phold_per_cds_predictions.tsv
│       ├── defensefinder_cds_predictions.tsv
│       └── vfdb_cds_predictions.tsv
└── VIRAL_CLASSIFICATION/
    ├── ANELLO/
    │   ├── anello.treefile
    │   └── Modha_allsequence_data.csv
    ├── BLASTN_AGAINST_HG38/
    │   └── AERIS.blastn_against_hg38.txt
    ├── DIAMOND/
    │   ├── AERIS.1000_contigs_95-85_diamond_path.tsv
    │   └── AERIS.1000_contigs_95-85_diamond.csv
    ├── GENOMAD/
    │   ├── All_samples_clustered_95-85_virus_scores.tsv
    │   └── All_samples_clustered_95-85_virus_taxonomy.tsv
    ├── PHAGES_AAI_SHARED_GENES/
    │   ├── Nayfach_families_annotated.txt
    │   └── Nayfach_genera_annotated.txt
    └── RHINO/
        └── rhino.blastn_taxonomy.csv
```

## License

See [`LICENSE`](LICENSE).