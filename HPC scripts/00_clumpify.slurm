#!/bin/bash
#SBATCH --job-name="clumpify"
#SBATCH --clusters=wice
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=72

#Make names.txt file with all the sample names you want to run clumpify on. 
#Then run the following command in your terminal to submit all the jobs to the cluster. 
#Make sure to change NAMEOFSTUDY to the name of your study.
#while read line; do sbatch -o LOGS/CLUMPIFY_LOGS/$line.log --export=ALL,study=NAMEOFSTUDY,sample="$line" 00_clumpify.slurm; done < names.txt

#Move to wherever your files are
cd /path/to/study/folder/$study/RAW_READS/

#Activate conda environment
export PATH="$CONDA_PREFIX/bin:$PATH"
source activate viper

clumpify.sh in="${sample}".R1.fastq.gz in2="${sample}".R2.fastq.gz \
		out="${sample}".R1.clump.fastq.gz out2="${sample}".R2.clump.fastq.gz \
		rcomp=f ziplevel=9 reorder=p deleteinput=f overwrite=t \
		threads=72
