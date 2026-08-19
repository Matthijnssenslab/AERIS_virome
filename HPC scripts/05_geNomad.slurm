#!/bin/bash
#SBATCH --job-name="genomad"
#SBATCH --cluster=wice
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=72

#Run the following command in your terminal to submit the job to the cluster.
#Make sure to change NAMEOFSTUDY to the name of your study.
#sbatch -o LOGS/genomad_date.log --export=ALL,study=NAMEOFSTUDY 05_geNomad.slurm

export PATH="$CONDA_PREFIX/bin:$PATH"
source activate viper

cd /path/to/study/folder/$study

mkdir -p VIRAL_CLASSIFICATION && cd VIRAL_CLASSIFICATION
mkdir -p GENOMAD && cd GENOMAD

genomad end-to-end --cleanup --splits 8 \
	../../CLUSTERING/All_samples_clustered_95-85.fasta \
	/path/to/study/folder/$study/VIRAL_CLASSIFICATION/GENOMAD/ \
	/path/to/genomad/database/ \
	--enable-score-calibration \
	--threads 72

cd All_samples_clustered_95-85_summary/

cut -f1,11 All_samples_clustered_95-85_virus_summary.tsv | sed 1d | \
	awk 'BEGIN {print "CONTIGS;superkingdom;realm;kingdom;phylum;class;order;family;subfamily;genus;species"}{print $0}' | \
	sed 's/;/\t/g' \
	> All_samples_clustered_95-85_virus_taxonomy.tsv

cut -f1-10 All_samples_clustered_95-85_virus_summary.tsv \
	> All_samples_clustered_95-85_virus_scores.tsv
