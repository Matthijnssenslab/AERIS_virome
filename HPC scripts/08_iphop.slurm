#!/bin/bash
#SBATCH --job-name="iphop"
#SBATCH --cluster=wice
#SBATCH --time=12:00:00
#SBATCH --nodes=1

#Run the following command in your terminal to submit the job to the cluster.
#Make sure to change NAMEOFSTUDY to the name of your study.
#sbatch -o LOGS/iphop_date.log --export=ALL,study=NAMEOFSTUDY 08_iphop.slurm

export PATH="$CONDA_PREFIX/bin:$PATH"
source activate iphop_env

cd /path/to/study/folder/$study

mkdir -p PHAGE_ANNOTATION && cd PHAGE_ANNOTATION
mkdir -p HOST_PREDICTION && cd HOST_PREDICTION

iphop predict --fa_file ../../VIRAL_CLASSIFICATION/PHAGES_AAI_SHARED_GENES/$study.1000_phagesGQ_95-85.fasta \
	--db_dir /path/to/iphop_db/Aug_2023_pub_rw -t 12
