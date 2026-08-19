#!/bin/bash
#SBATCH --job-name="cross_sample_clustering"
#SBATCH --cluster=wice
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=72

#Run the following command in your terminal to submit the job to the cluster. 
#Make sure to change NAMEOFSTUDY to the name of your study.
#sbatch -o LOGS/cross_sample_clust_DATE.log --export=ALL,study=NAMEOFSTUDY 02_cross_sample_clustering.slurm

#Move to wherever your files are
cd /path/to/study/folder/$study

#Activate conda environment
export PATH="$CONDA_PREFIX/bin:$PATH"
source activate viper

#Create an output directory for the cross sample clustering results
mkdir -p CLUSTERING

#Concatenate all the contigs from all the samples into one fasta file for clustering
while read line; do cat SAMPLES/$line/CONTIGS/"$line"_1000.contigs.fasta >> CLUSTERING/All_samples_to_cross_cluster.fasta ; done < scripts/names.txt
while read line; do cat SAMPLES/$line/CONTIGS/"$line"_1000_re-include.fasta >> CLUSTERING/All_samples_re-include.fasta ; done < scripts/names.txt

cd CLUSTERING

#Run viper_cluster_study.py (found in the viper environment) with desired options to perform a cross samples clustering
viper_cluster_study.py -c All_samples_to_cross_cluster.fasta \
	-r All_samples_re-include.fasta \
	-o All_samples_clustered -t 72
