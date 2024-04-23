#!/bin/bash

# Parses arguments from the command line, which are four
# Usage: bash concatenate_genes_bartonella.sh -list list.txt -db db.fasta -output output.fasta -tree
# This assumes that there is a list.txt file, in which all ids are listed.
while getopts ":l:d:o:t" opt; do
  case ${opt} in
    l ) # process list file
      listfile=$OPTARG
      ;;
    d ) # process database file
      dbfile=$OPTARG
      ;;
    o ) # process output file
      outputfile=$OPTARG
      ;;
    t ) # process tree flag
      treeflag=1
      ;;
    \? ) echo "Usage: cmd [-l listfile] [-d dbfile] [-o outputfile] [-t]"
      ;;
  esac
done

# Check if files exist
if [[ ! -e $listfile ]]; then
    echo "List file does not exist"
    exit 1
fi

if [[ ! -e $dbfile ]]; then
    echo "Database file does not exist"
    exit 1
fi

echo "Initializing extracting proccess. This will create files for each list"

# Read list file line by line
while IFS= read -r line
do
  # Check if line is a new list indicator
  if [[ $line == "---" ]]; then
    # If ids array is not empty, extract sequences and write to file
    if [[ ${#ids[@]} -ne 0 ]]; then
      outfile="${ids[0]}.fasta"
      seqkit grep -r -f <(printf '%s\n' "${ids[@]}") "$dbfile" -o "$outfile"
    fi
    # Clear ids array
    ids=()
  else
    # Add id to ids array
    ids+=("$line")
    # If outfile is empty, set it to the first id
    #if [[ -z $outfile ]]; then
    #  outfile="${line#>}.fasta"
    #fi
  fi
done < "$listfile"

# Handle last list
if [[ ${#ids[@]} -ne 0 ]]; then
  outfile="${ids[0]}.fasta"
  seqkit grep -f <(printf '%s\n' "${ids[@]}") $dbfile > $outfile
fi

echo "Initializing concatenation proccess. This will create temporal files for each sequence"

# Initialize variables
declare -a ids=()
outfile=""

while IFS= read -r line
do
  # Check if line is a new list indicator
  if [[ $line == "---" ]]; then
    # If ids array is not empty, extract sequences and write to file
    if [[ ${#ids[@]} -ne 0 ]]; then
      for id in "${ids[@]}"; do
        outfile="${id}.fa1"
        echo "$id" | seqkit grep -r -f /dev/stdin "$dbfile" -o "$outfile"
      done
    fi
    # Clear ids array
    ids=()
  else
    # Add id to ids array
    ids+=("$line")
  fi
done < "$listfile"

# Handle last list
if [[ ${#ids[@]} -ne 0 ]]; then
  for id in "${ids[@]}"; do
    outfile="${id}.fa1"
    echo "$id" | seqkit grep -r -f /dev/stdin "$dbfile" -o "$outfile"
  done
fi

for file in *.fasta
do
    # Print number of sequences in file
    echo "$file: $(grep -c "^>" "$file") sequences"
done

# Since all FASTA sequences have an "_" and it is necessary to delete it
# for the concatenation to work, this section will refactor all sequences
# on the fasta files
for fasta_file in *.fa1
do
    sed -i 's/_/ /g' "$fasta_file"
done

# Concatenate all .fasta files
# This uses seqkit
seqkit concat --full *.fa1 > $outputfile
#seqkit concat *.fasta > $outputfile

# Print number of sequences in output file
echo "Number of sequences in output file: $(grep -c "^>" $outputfile)"
# Then it just erases every created .fa file to do it tidily
rm *.fa1

# If tree flag is set, align sequences and generate tree
if [[ $treeflag -eq 1 ]]; then
  source /home/marlen/anaconda3/etc/profile.d/conda.sh
  conda activate mafft
  conda activate iqtree
  mafft --auto $outputfile > aligned.fasta
  iqtree -s aligned.fasta
fi
