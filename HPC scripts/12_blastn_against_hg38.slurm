#!/bin/bash
#SBATCH --job-name="blastn_against_hg38"
#SBATCH --cluster=wice
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=72

#Run the following command in your terminal to submit the job to the cluster.
#Make sure to change NAMEOFSTUDY to the name of your study.
#sbatch -o LOGS/blastn_against_hg38_date.log --export=ALL,study=NAMEOFSTUDY 12_blastn_against_hg38.slurm

export PATH="$CONDA_PREFIX/bin:$PATH"
source activate viper

cd /path/to/study/folder/$study

mkdir -p VIRAL_CLASSIFICATION && cd VIRAL_CLASSIFICATION
mkdir -p BLASTN_AGAINST_HG38 && cd BLASTN_AGAINST_HG38

### BLASTING CONTIGS TO HUMAN GENOME ###
blastn -query ../../CLUSTERING/All_samples_clustered_95-85.fasta \
	-db /path/to/human_genome_db/GCF_000001405.39_top_level \
	-out $study.blastn_against_hg38.tsv \
	-outfmt "6 std qcovs qcovhsp" -evalue 1e-10 -num_threads 72

#use the viral contigs only as input to drastically decrease computing time, for virome analysis only

### FILTERING OUT CONTIGS WITH A QUERY COVERAGE SMALLER THAN 50% ###
awk '{if ($(NF-1) >= 50) print}' $study.blastn_against_hg38.tsv | cut -f1 | sort -u > $study.blastn_against_hg38.txt
