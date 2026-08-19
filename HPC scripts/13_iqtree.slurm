#!/bin/bash
#SBATCH --job-name="iqtree"
#SBATCH --cluster=wice
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=72

#Run the following command in your terminal to submit the job to the cluster.
#Make sure to change NAMEOFSTUDY to the name of your study.
#sbatch -o iqtree_DATE.log --export=ALL,study=NAMEOFSTUDY 13_iqtree.slurm

#Move to wherever your files are
cd /path/to/study/folder/$study

mkdir -p VIRAL_CLASSIFICATION && cd VIRAL_CLASSIFICATION
mkdir -p ANELLO/iqtree_output && cd ANELLO/iqtree_output

#Activate conda environment
export PATH="$CONDA_PREFIX/bin:$PATH"
source activate muscle5

iqtree3 -s ../mafft_output.fasta --prefix anello -m GTR+F+I+R10 -B 10000 -seed 865069 -T AUTO -redo
