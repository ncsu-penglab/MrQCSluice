#!/bin/bash
###########################################################################################################
#   @author Ian Huntress
#   Generates vcf calls for each bam
###########################################################################################################
export NTHREADS=4

while getopts ":hs:r:@:" opt; do
  case $opt in
    s) export sampleListFile=$OPTARG ;;
    r) export ref=$OPTARG ;;
    @) export NTHREADS=$OPTARG ;;
    :) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
    h) echo "Usage: 1_RNASeq_To_SNPs.sh -s sampleListFile (one per line) -r reference fasta file -@ Threads"; exit 1 ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done

if [ -z "$sampleListFile" ]; then echo "Missing -s sampleListFile"; exit 1; fi
if [ -z "$ref" ]; then echo "Missing -r Reference genome"; exit 1; fi
readarray -t FileQueue < $sampleListFile

    echo "Starting array job:"
    # Input
    export batchscript=$(realpath $0)
    sbatch -c $NTHREADS --mem=8G --array=0-$((${#FileQueue[@]}-1))%6 bcftools.sh -s $sampleListFile -r $ref -@ $NTHREADS
