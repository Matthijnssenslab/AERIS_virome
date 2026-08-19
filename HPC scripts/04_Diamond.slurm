#!/bin/bash
#SBATCH --job-name="diamond"
#SBATCH --cluster=wice
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=72

#Run the following command in your terminal to submit the job to the cluster.
#Make sure to change NAMEOFSTUDY to the name of your study.
#sbatch -o LOGS/diamond_date.log --export=ALL,study=NAMEOFSTUDY 04_Diamond.slurm

export PATH="$CONDA_PREFIX/bin:$PATH"
source activate viper

cd /path/to/study/folder/$study
mkdir -p VIRAL_CLASSIFICATION && cd VIRAL_CLASSIFICATION
mkdir -p DIAMOND && cd DIAMOND

### ALIGNMENT ###
diamond blastx -q ../../CLUSTERING/All_samples_clustered_95-85.fasta \
	-d /path/to/nr/database/nr \
	-a $study.1000_contigs_95-85_diamond.daa \
	-p 72 --sensitive -c1
diamond view -a $study.1000_contigs_95-85_diamond.daa \
	-o $study.1000_contigs_95-85_diamond.m8 \
	-p 72

### GET LCA AND NCBI TAXID ###
ktClassifyBLAST $study.1000_contigs_95-85_diamond.m8 \
	-o $study.1000_contigs_95-85_diamond_taxid.tsv

### GET TAXONOMY ###
#check that the latest names.dmp nodes.dmp delnodes.dmp merged.dmp files are in ~/.taxonkit
#if not, download and uncompress them using
#wget -c https://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
#tar -zxvf taxdump.tar.gz
#cp names.dmp nodes.dmp delnodes.dmp merged.dmp ~/.taxonkit

source activate taxonkit

taxonkit reformat2 $study.1000_contigs_95-85_diamond_taxid.tsv -I 2 | \
cut -f1,4 | sed 's/\t/;/g'| \
awk 'BEGIN{print "Name;Classification;Phylum;Class;Order;Family;Genus;Species"}1' \
> $study.1000_contigs_95-85_diamond_taxonomy.csv

### CLEAN FOLDER ###
if [ -s "$study.1000_contigs_95-85_diamond_taxonomy.csv" ] ; then
	rm $study.1000_contigs_95-85_diamond.daa
fi

