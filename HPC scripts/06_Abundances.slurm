#!/bin/bash
#SBATCH --job-name="abundances"
#SBATCH --cluster=wice
#SBATCH --time=01:00:00
#SBATCH --nodes=1

#Run the following command in your terminal to submit the job to the cluster.
#Make sure to change NAMEOFSTUDY to the name of your study and names.txt to the path of your file containing the sample names.	
#while read line; do sbatch -o LOGS/ABUND_LOGS/$line.abundances.log --export=ALL,study=NAMEOFSTUDY,sample="$line" 06_Abundances.slurm; done < names.txt

cd /path/to/study/folder/$study/

export PATH="$CONDA_PREFIX/bin:$PATH"
source activate viper

mkdir -p ABUNDANCES && cd ABUNDANCES/

##TO BE DONE IN AN INTERACTIVE JOB BEFORE SUBMITTING ABUNDANCE CALCULATIONS
### INDEX REFERENCE FASTA ###
#cp ../CLUSTERING/All_samples_clustered_95-85.fasta .
#bwa-mem2 index All_samples_clustered_95-85.fasta

### MAPPING ###
bwa-mem2 mem All_samples_clustered_95-85.fasta \
	/path/to/study/folder/$study/SAMPLES/$sample/READ/TRIMMED/$sample.trimmed.R1.fastq.gz \
	/path/to/study/folder/$study/SAMPLES/$sample/READ/TRIMMED/$sample.trimmed.R2.fastq.gz -t 72 |\
	samtools view -F 2048 -F 256 -Su -@ 72 - |\
	samtools sort - -@ 72 \
	-o $sample.1000_contigs_95-85.paired.bam			#align the paired reads against the cluster representatives (removing secondary and supplementary alignments)
bwa-mem2 mem All_samples_clustered_95-85.fasta \
	/path/to/study/folder/$study/SAMPLES/$sample/READ/TRIMMED/$sample.trimmed.unpaired.fastq.gz -t 72 |\
	samtools view -F 2048 -F 256 -Su -@ 72 - |\
	samtools sort - -@ 72 \
	-o $sample.1000_contigs_95-85.unpaired.bam			#align the unpaired reads against the cluster representatives (removing secondary and supplementary alignments)
samtools merge $sample.1000_contigs_95-85.bam \
	$sample.1000_contigs_95-85.paired.bam \
	$sample.1000_contigs_95-85.unpaired.bam
samtools index $sample.1000_contigs_95-85.bam
samtools idxstats $sample.1000_contigs_95-85.bam |\
	 cut -f1,3 > $sample.1000_contigs_95-85.reads.txt		#reports alignment summary statistics (the input file is indexed by samtools index first). The report includes reference sequence name, sequence length, # mapped read-segments and # unmapped read-segments (we only select the sequence name and the mapped reads)

### COVERAGE CORRECTION ###
python $VSC_DATA/scripts/coverage.py \
	-i $sample.1000_contigs_95-85.bam -d 1				#determine horizontal coverage (we want a minimum depth of 1 read for every nucleotide). It counts the number of reads that align against one nucleotide. If it is more than 1, the nucleotide is evaluated as "covered". Then it divides the number of "covered nucleotides" by the total length of the contig. The coverage.py script outputs creates a .1depth_percent.txt file	
paste <(sort $sample.1000_contigs_95-85.reads.txt) <(sort $sample.1000_contigs_95-85.1depth_percent.txt | cut -f2) |\
	grep 'NODE' | awk '{if ($3>=50) print $1 "\t" $2; else print $1 "\t" "0";}' \
	> $sample.1000_contigs_95-85.reads_coverage.txt

#paste the files with the NODES names + Abundances with the file with NODES names + horizontal coverage (only select the second column as the NODES names are the same in the 1st file)
#takes only the rows with NODE (the last row is different). Then, it puts the abundance only if the HC is higher than 50%. If <50% the read count is set to 0.
#it can be interesting to check if the number of contigs is significantly lower after applying the horizontal coverage cut-off

sed -i '1s/^/\t'$sample'\n/' $sample.1000_contigs_95-85.reads_coverage.txt #Add the name of the sample on top on the read counts (second column) for R

### CLEAN FOLDER ###
rm $sample.1000_contigs_95-85.paired.bam
rm $sample.1000_contigs_95-85.unpaired.bam
rm $sample.1000_contigs_95-85.bam.bai

### MANUALLY REMOVE THE INDEXED REFERENCE FILES AFTER USE ###
#rm All_samples_clustered_95-85.fasta*

