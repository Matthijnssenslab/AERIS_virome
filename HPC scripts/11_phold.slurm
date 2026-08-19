#!/bin/bash
#SBATCH --job-name="phold"
#SBATCH --cluster=wice
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=72

#Run the following command in your terminal to submit the job to the cluster.
#Make sure to change NAMEOFSTUDY to the name of your study.
#sbatch -o phold_date.log --export=ALL,study=NAMEOFSTUDY 11_phold.slurm

export PATH="$CONDA_PREFIX/bin:$PATH"
source activate phold

cd /path/to/study/folder/$study

mkdir -p PHAGE_ANNOTATION && cd PHAGE_ANNOTATION

phold run -i PHAROKKA/"$study"_pharokka.gbk \
	-o PHOLD -t 8 -p "$study"_phold \
	-d /path/to/phold_db/phold_20251018 \
	--hyps
