#!/bin/bash
# Usage: ./count_kmers_in_reads.sh <fastq> <kmers_tsv>
# kmers_tsv must have two columns without header:
#   1. kmer_name
#   2. kmer_sequence

#SBATCH --job-name=kmer_counter
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=2:00:00

fastq_path=$1
kmers_tsv=$2

fastq=`echo $fastq_path | awk '{n=split($0, name, "/"); print name[n]}'`
script_dir="$(dirname "$(readlink -f "$0")")"

echo $fastq

for fv in `cut -f1 $kmers_tsv`
do 
  rc=`echo $fv | tr ACGTacgt TGCAtgca | rev`
  echo -n "$fv $rc "; date +"%D %T"

  if (file $fastq_path | grep -q compressed )
  then
    zgrep -oP "$fv|$rc" $fastq_path | wc -l >> "$fastq.cnt"
  else
    grep -oP "$fv|$rc" $fastq_path | wc -l >> "$fastq.cnt"
  fi
done

python3 "$script_dir/collect_counts.py" --kmers $kmers_tsv

mkdir raw_counts
mv *.cnt raw_counts
#rm -r raw_counts

