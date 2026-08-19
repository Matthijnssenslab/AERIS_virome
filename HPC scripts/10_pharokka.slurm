#!/bin/bash
#SBATCH --job-name="pharokka"
#SBATCH --cluster=wice
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=72

#Run the following command in your terminal to submit the job to the cluster.
#Make sure to change NAMEOFSTUDY to the name of your study.
#sbatch -o pharokka_date.log --export=ALL,study=NAMEOFSTUDY 10_pharokka.slurm

export PATH="$CONDA_PREFIX/bin:$PATH"
source activate pharokka

cd /path/to/study/folder/$study

mkdir PHAGE_ANNOTATION && cd PHAGE_ANNOTATION

pharokka.py -i ../VIRAL_CLASSIFICATION/PHAGES_AAI_SHARED_GENES/$study.1000_virusesGQ_95-85.fasta \
	    -o PHAROKKA -t 8 -d /path/to/pharokka_db/pharokka_1.8.0 \
            -p AERIS_pharokka -g prodigal-gv -m --meta_hmm \
            --skip_mash -s
