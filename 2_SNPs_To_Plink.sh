#!/bin/bash
###########################################################################################################
#   @author Ian Huntress
#   Generates vcf calls for each bam
###########################################################################################################
export NTHREADS=4
export outdir="./"

while getopts ":hs:r:@:e:o:w:" opt; do
  case $opt in
    s) export sampleListFile=$OPTARG ;;
    @) export NTHREADS=$OPTARG ;;
    o) export outdir=$OPTARG ;;
    :) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
    h) echo "Usage: 2_SNPs_To_Plink.sh -s sampleListFile (one per line) -@ Threads -o output directory"; exit 1 ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done

if [ -z "$sampleListFile" ]; then echo "Missing -s sampleListFile"; exit 1; fi
if [ -z "$ref" ]; then echo "Missing -r Reference genome"; exit 1; fi

export batchscript=$(realpath $0)
sbatch -c $NTHREADS --mem=24G plink.sh -s $sampleListFile -@ $NTHREADS -o $outdir
