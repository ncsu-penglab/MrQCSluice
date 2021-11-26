###
export NTHREADS=4
export outdir="./"

while getopts ":hs:@:e:o:" opt; do
  case $opt in
    s) export sampleListFile=$OPTARG ;;
    @) export NTHREADS=$OPTARG ;;
    o) export outdir=$OPTARG ;;
    :) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
    h) echo "Usage: RNASeq_To_SNPs.sh -s sampleListFile (one per line) -@ Threads -o output directory"; exit 1 ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done

if [ -z "$sampleListFile" ]; then echo "Missing -s sampleListFile"; exit 1; fi

    cd $outdir

    rm tmp.fifo
    mkfifo tmp.fifo; sleep 1;
    bcftools merge --file-list $sampleListFile --force-samples > tmp.fifo &; sleep 1;
    
    plink --vcf tmp.fifo --allow-extra-chr --memory 16268 --threads $NTHREADS --double-id --distance square '1-ibs'
