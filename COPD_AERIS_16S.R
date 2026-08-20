# Load packages
library(dada2)
library(dplyr)
library(vegan)

# Set path to 16S raw read files
path <- "16S_reads"
list.files(path)

# Forward and reverse fastq filenames have format: SRRXXXXXXXX_1.fastq and SRRXXXXXXXX_2.fastq
fnFs <- sort(list.files(path, pattern="_1.fastq", full.names = TRUE))
fnRs <- sort(list.files(path, pattern="_2.fastq", full.names = TRUE))

# Extract sample names, assuming filenames have format: SAMPLENAME_XXX.fastq
sample.names <- sapply(strsplit(basename(fnFs), "_"), `[`, 1)

# Inspect read quality profiles
plotQualityProfile(fnFs[1:2])
plotQualityProfile(fnRs[1:2])

# Place filtered files in filtered/ subdirectory
filtFs <- file.path(path, "filtered", paste0(sample.names, "_F_filt.fastq.gz"))
filtRs <- file.path(path, "filtered", paste0(sample.names, "_R_filt.fastq.gz"))
names(filtFs) <- sample.names
names(filtRs) <- sample.names


out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs,
                     maxN=0, maxEE=c(2,2), truncQ=2, rm.phix=TRUE,
                     compress=TRUE, multithread=TRUE)
head(out)

# Learn the error rates
errF <- learnErrors(filtFs, multithread=TRUE)
errR <- learnErrors(filtRs, multithread=TRUE)

plotErrors(errF, nominalQ=TRUE)

# Sample inference
dadaFs <- dada(filtFs, err=errF, multithread=TRUE)
dadaRs <- dada(filtRs, err=errR, multithread=TRUE)

dadaFs[[1]]

# Merge paired-end reads
mergers <- mergePairs(dadaFs, filtFs, dadaRs, filtRs, verbose=TRUE)

# Inspect the merger data.frame from the first sample
head(mergers[[1]])

# Construct sequence table
seqtab <- makeSequenceTable(mergers)
dim(seqtab)

# Inspect distribution of sequence lengths
table(nchar(getSequences(seqtab)))

# Remove non-target-length sequences from sequence table
seqtab2 <- seqtab[,nchar(colnames(seqtab)) %in% 250:256]
table(nchar(getSequences(seqtab2)))

#Remove chimeras
seqtab.nochim <- removeBimeraDenovo(seqtab2, method="consensus", multithread=TRUE, verbose=TRUE)
dim(seqtab.nochim)

sum(seqtab.nochim)/sum(seqtab2)

# Track number of reads through the pipeline
getN <- function(x) sum(getUniques(x))
track <- cbind(out, sapply(dadaFs, getN), sapply(dadaRs, getN), sapply(mergers, getN), rowSums(seqtab.nochim))
colnames(track) <- c("input", "filtered", "denoisedF", "denoisedR", "merged", "nonchim")
rownames(track) <- sample.names
head(track)

# Assign taxonomy
taxa <- assignTaxonomy(seqtab.nochim, "silva_nr99_v138.2_toSpecies_trainset.fa.gz", multithread = TRUE)

taxa.print <- taxa # Removing sequence rownames for display only
rownames(taxa.print) <- NULL
head(taxa.print)

# Calculate alpha-diversity
shannon <- diversity(seqtab.nochim, index = "shannon")
simpson <- diversity(seqtab.nochim, index = "simpson")

bact_diversity <- data.frame(
    Samples = row.names(seqtab.nochim),
    Shannon = shannon,
    Simpson = simpson)

rownames(bact_diversity) <- NULL

# Merge abundance and taxa tables
seqtab.nochim.tr <- t(seqtab.nochim)

mastertable_bact <- merge(seqtab.nochim.tr, taxa, by = "row.names")

rownames(mastertable_bact) <- mastertable_bact$Row.names
mastertable_bact$Row.names <- NULL

num_asvs <- nrow(mastertable_bact)
new_rownames <- paste0("ASV", sprintf("%04d", 1:num_asvs))
rownames(mastertable_bact) <- new_rownames

# Export bacterial mastertable (abundance + taxonomy) and diversity table

SRAruntable <- read.csv("SraRunTable.csv", header = TRUE, sep = ";")
SRAruntable <- SRAruntable %>%
    select(Run, Collection_Date, subjectID) %>%
    mutate(Collection_Date = as.POSIXct(Collection_Date))

write.csv(bact_diversity, "diversity_table_bact.csv", row.names=FALSE)
write.csv(mastertable_bact, "mastertable_bactDADA2.csv")
