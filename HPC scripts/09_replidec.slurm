#!/bin/bash
#SBATCH --job-name="replidec"
#SBATCH --cluster=wice
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=72

#Run the following command in your terminal to submit the job to the cluster.
#Make sure to change NAMEOFSTUDY to the name of your study.
#sbatch -o LOGS/replidec_date.log --export=ALL,study=NAMEOFSTUDY 09_replidec.slurm

export PATH="$CONDA_PREFIX/bin:$PATH"
source activate replidec

cd /path/to/study/folder/$study

mkdir -p PHAGE_ANNOTATION && cd PHAGE_ANNOTATION
mkdir -p LIFESTYLE && cd LIFESTYLE

Replidec -p multiSeqEachAsOne -i ../../VIRAL_CLASSIFICATION/PHAGES_AAI_SHARED_GENES/$study.1000_phagesGQ_95-85.fasta -w replidec
