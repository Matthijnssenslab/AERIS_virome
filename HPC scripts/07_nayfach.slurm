#!/bin/bash
#SBATCH --job-name="nayfach"
#SBATCH --cluster=wice
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=72
#SBATCH --partition=bigmem

#Run the following command in your terminal to submit the job to the cluster.
#Make sure to change NAMEOFSTUDY to the name of your study.
#sbatch -o LOGS/nayfach_date.log --export=ALL,study=NAMEOFSTUDY 07_nayfach.slurm

export PATH="$CONDA_PREFIX/bin:$PATH"
source activate aai

cd /path/to/study/folder/$study
mkdir -p VIRAL_CLASSIFICATION && cd VIRAL_CLASSIFICATION
mkdir -p PHAGES_AAI_SHARED_GENES && cd PHAGES_AAI_SHARED_GENES/

### FASTA WITH GQ VIRUSES ###
grep 'Complete\|High-quality\|Medium-quality' ../../PHAGE_ANNOTATION/COMPLETENESS/quality_summary_R.tsv |\
        cut -f1 > $study.1000_contigsGQ_95-85.txt
grep -F -f $study.1000_contigsGQ_95-85.txt ../GENOMAD/All_samples_clustered_95-85_summary/All_samples_clustered_95-85_virus_summary.tsv |\
        cut -f1 > $study.1000_virusesGQ_95-85.txt
rm $study.1000_contigsGQ_95-85.txt

seqkit grep -n -f $study.1000_virusesGQ_95-85.txt ../../CLUSTERING/All_samples_clustered_95-85.fasta > $study.1000_virusesGQ_95-85.fasta

### FASTA WITH REFERENCE PHAGE GENOMES ###
cat /path/to/DB/Inoviruses/Roux2019/Roux2019.fasta >> viral_reference_genomes.fasta
cat /path/to/DB/Microviruses/Kirchberger2022/Kirchberger2022.fasta >> viral_reference_genomes.fasta
cat /path/to/DB/INPHARED/*_genomes.fa >> viral_reference_genomes.fasta

cat $study.1000_virusesGQ_95-85.fasta viral_reference_genomes.fasta | cut -d ' ' -f1 |\
	seqkit rmdup -s	> $study.combined_reference_virusesGQ.fasta

grep '>' $study.combined_reference_virusesGQ.fasta | sed 's/>//g' \
	> $study.combined_reference_virusesGQ.txt

### GENE PREDICTION ###
prodigal-gv -i $study.combined_reference_virusesGQ.fasta \
	-o $study.AAI.genes.gff \
	-a $study.AAI.proteins.faa \
	-d $study.AAI.genes.fna \
	-p meta -f gff

#input should be a fasta file with your good-quality viruses (geNomad + checkv >50% completeness)
#gff files are tab-separated files representing the position of genes and transcripts (exons, introns, UTRs) in a reference genome
#gbf files are GenBank format files with genes sequences and their metadata (publication source, sample source, author)

### ALIGNMENT ###
diamond makedb --in $study.AAI.proteins.faa --db $study.viral_proteins_db --threads 36
diamond blastp --query $study.AAI.proteins.faa \
	--db $study.viral_proteins_db --out $study.blastp.tsv \
	--outfmt 6 --evalue 1e-5 --max-target-seqs 10000 \
	--query-cover 50 --subject-cover 50

### COMPUTE AAI ###
python $VSC_DATA/MGV/aai_cluster/amino_acid_identity.py \
	--in_faa $study.AAI.proteins.faa \
	--in_blast $study.blastp.tsv \
	--out_tsv $study.AAI.tsv

### FILTER USING NAYFACH'S PYTHON SCRIPTS###
#https://github.com/snayfach/MGV/blob/master/aai_cluster/amino_acid_identity.py
#https://github.com/snayfach/MGV/blob/master/aai_cluster/filter_aai.py

python path/to/MGV/aai_cluster/filter_aai.py --in_aai $study.AAI.tsv \
	--min_percent_shared 20 --min_num_shared 16 --min_aai 40 \
	--out_tsv $study.genus_edges.tsv
python path/to/MGV/aai_cluster/filter_aai.py --in_aai $study.AAI.tsv \
	--min_percent_shared 10 --min_num_shared 8 --min_aai 20 \
	--out_tsv $study.family_edges.tsv

### CLUSTERING ###
mcl $study.genus_edges.tsv -te 8 -I 2.0 --abc -o $study.genus_clusters.txt
mcl $study.family_edges.tsv -te 8 -I 1.2 --abc -o $study.family_clusters.txt

### REFORMATTING ###
nl $study.genus_clusters.txt |\
	tr -s ' ' '\t' | sed 's/^\t/GenusAAI_/g' \
	> $study.AAI.genus_clusters.tsv
awk -v OFS='\t' '{for (i=2;i<=NF;i++)print $1,$i}' \
        $study.AAI.genus_clusters.tsv \
        > $study.AAI.genus_clusters.txt
nl $study.family_clusters.txt |\
	tr -s ' ' '\t' | sed 's/^\t/FamilyAAI_/g' \
	> $study.AAI.family_clusters.tsv
awk -v OFS='\t' '{for (i=2;i<=NF;i++)print $1,$i}' \
	$study.AAI.family_clusters.tsv \
	> $study.AAI.family_clusters.txt
