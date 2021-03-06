# **MrQCSluice**
**M**apped **R**eads **Q**uality **C**ontrol **S**ample **L**abels **U**s**i**ng SNP **C**all**e**r
 
The purpose of MrQCSluice is to check and correct the sample mislabeling of RNA-Seq data using derived genetic information. 
It will identify potentially mislabeled samples based on the assumption that samples from the same or similar genetic backgrounds (such as repeated sampling of the same animals) should have highly similar SNPs evident in their RNA-Seq sequencing reads. To streamline this quality control step, MrQCSluice offers a set of shell scripts designed to calculate pairwise SNP distances between samples, using the BAM files generated by standard RNA-seq read mapping directly as input.

### Example Output
##### SNP distance matrix heatmap for three animals with two RNA-Seq samples each.
![alt text](https://github.com/ncsu-penglab/MrQCSluice/blob/main/ExampleHeatmap.png)

# Before you start
 1. Dependencies: Slurm sbatch, bcftools, bgzip, tabix, and plink are available commands in your PATH.
 #####  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; tested with [samtools 1.13](https://github.com/samtools/samtools/releases/tag/1.13); tested with [bcftools 1.13](https://github.com/samtools/bcftools/releases/tag/1.13); tested with [htslib 1.13](https://github.com/samtools/htslib/releases/tag/1.13); tested with [plink 1.90](https://www.cog-genomics.org/plink/)
 
 2. Make sure the input bam files are sorted.

# Example:

### Collect dependencies
```
export PATH=/tools/bcftools/1.13/bin:${PATH}
export PATH=/tools/htslib-1.13/bin:${PATH}
export PATH=/tools/plink/1.90/bin:${PATH}
```

 ### Collect bam files.
```
ls /RNAseq/Mapping/*/rheMac10_STAR/Aligned.sorted.bam > Samples.txt
head Samples.txt -n 3

/RNAseq/Mapping/WB/G043/rheMac10_STAR/Aligned.sorted.bam
/RNAseq/Mapping/WB/G044/rheMac10_STAR/Aligned.sorted.bam
/RNAseq/Mapping/WB/G045/rheMac10_STAR/Aligned.sorted.bam
```

### Find your reference genome.
ls ~/rheMac10_ensembl/fasta/genome.fa

```
./1_RNA_To_SNPs.sh -h
 Usage: 1_RNASeq_To_SNPs.sh -s sampleListFile (one per line) -r reference fasta file -@ Threads
```

### Run 1_RNA_To_SNPs.sh
```
./1_RNA_To_SNPs.shsh -s Samples.txt -r ~/rheMac10_ensembl/fasta/genome.fa -@ 6
 Starting array job:
 Submitted batch job 76946

squeue -u <yourUserID>
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
    76946_[6-20%6]  standard bcftools yourUserID PD       0:00      1 (JobArrayTaskLimit)
           76946_0  standard bcftools yourUserID  R       0:00      1 node69
           76946_1  standard bcftools yourUserID  R       0:00      1 node10
           76946_2  standard bcftools yourUserID  R       0:00      1 node10
```

##### When all slurm jobs from the first script are complete, run the second script 2_SNPs_To_Plink.sh

### Collect vcf files.
```
ls /RNAseq/Mapping/*/rheMac10_STAR/Aligned.sorted.vcf.gz > VCFSamples.txt

head VCFSamples.txt -n 3
/RNAseq/Mapping/WB/G043/rheMac10_STAR/Aligned.sorted.vcf
/RNAseq/Mapping/WB/G044/rheMac10_STAR/Aligned.sorted.vcf
/RNAseq/Mapping/WB/G045/rheMac10_STAR/Aligned.sorted.vcf
```

### Run 2_SNPs_To_Plink.sh
```
./2_SNPs_To_Plink.sh -s VCFSamples.txt -@ 6 -o ~/SNPAnalysis
```

### Inspect plink output files
```
ls ~/SNPAnalysis
plink.log  plink.mdist  plink.mdist.id  plink.nosex  tmp.fifo
```

##### @author Ian Huntress, Peng Lab
##### @description A short guide to call SNPs from RNASeq Bam files and compute the SNP edit distance between pairs of samples with plink.

