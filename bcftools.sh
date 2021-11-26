#!/bin/bash
export NTHREADS=4

while getopts ":hs:r:@:" opt; do
  case $opt in
    s) export sampleListFile=$OPTARG ;;
    r) export ref=$OPTARG ;;
    @) export NTHREADS=$OPTARG ;;
    :) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
    h) echo "Usage: RNASeq_To_SNPs.sh -s sampleListFile (one per line) -r reference fasta file -@ Threads"; exit 1 ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done

if [ -z "$sampleListFile" ]; then echo "Missing -s sampleListFile"; exit 1; fi
if [ -z "$ref" ]; then echo "Missing -r Reference genome"; exit 1; fi
readarray -t FileQueue < $sampleListFile

    R1=${FileQueue[$SLURM_ARRAY_TASK_ID]}
    R2=$(echo $R1 | sed 's/\.bam\|$/.vcf/I')

    cd $(dirname $R1)

    echo "For file " $R1 " with ID " $SLURM_ARRAY_TASK_ID " Save in " $R2
    echo "Running mpileup"

    echo $R1 > sampleName.txt

    bcftools mpileup --threads $NTHREADS --fasta-ref $ref $R1 | bcftools reheader -s sampleName.txt - | bcftools call -vm -O v --threads $NTHREADS | bcftools filter -i 'QUAL>30 && DP>10' --threads $NTHREADS > $R2;
    rm sampleName.txt

    bgzip -f $R2;
    tabix -p vcf -f $R2.gz;

    

