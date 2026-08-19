#!/bin/bash
#SBATCH --job-name="checkv_completeness"
#SBATCH --cluster=wice
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=72

#Run the following command in your terminal to submit the job to the cluster.
#Make sure to change NAMEOFSTUDY to the name of your study.
#sbatch -o LOGS/checkv_completeness_date.log --export=ALL,study=NAMEOFSTUDY 03_checkv_completeness.slurm

export PATH="$CONDA_PREFIX/bin:$PATH"
source activate viper

cd /path/to/study/folder/$study
mkdir -p PHAGE_ANNOTATION/COMPLETENESS
cd PHAGE_ANNOTATION/COMPLETENESS

checkv end_to_end ../../CLUSTERING/All_samples_clustered_95-85.fasta . -d /path/to/CheckV/database -t 18

cat quality_summary.tsv | cut -f1,3,4,5,6,8,10  > quality_summary_R.tsv #selects the fields contig_ID, provirus, proviral_length, gene_count, viral_genes, checkv_quality, completeness

cat quality_summary_R.tsv | cut -f6 | grep -c "Complete" | sed 's/^/'"Complete contigs "'/' >> CheckV_completeness_contigs.txt
cat quality_summary_R.tsv | cut -f6 | grep -c "High-quality" | sed 's/^/'"High-quality contigs (> 90% complete)	"'/' >> CheckV_completeness_contigs.txt
cat quality_summary_R.tsv | cut -f6 | grep -c "Medium-quality" | sed 's/^/'"Medium-quality contigs (50-90% complete) "'/' >> CheckV_completeness_contigs.txt
cat quality_summary_R.tsv | cut -f6 | grep -c "Low-quality" | sed 's/^/'"Low-quality contigs (< 50% complete) "'/' >> CheckV_completeness_contigs.txt
cat quality_summary_R.tsv | cut -f6 | grep -c "Not-determined" | sed 's/^/'"Not-determined contigs "'/' >> CheckV_completeness_contigs.txt
cat quality_summary_R.tsv | wc -l | awk '{print "Total non-redundant contigs " $1-1}' >> CheckV_completeness_contigs.txt
