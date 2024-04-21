#!/bin/bash

# Parses arguments from the command line, which are four
# Usage: bash script.sh -list list.txt -db db.fasta -output output.fasta -tree
# This assumes that there is a list.txt file, in which all ids are listed.
while getopts ":list:db:output:tree" opt; do
  case ${opt} in
    list ) # process list file
      listfile=$OPTARG
      ;;
    db ) # process database file
      dbfile=$OPTARG
      ;;
    output ) # process output file
      outputfile=$OPTARG
      ;;
    tree ) # process tree flag
      treeflag=1
      ;;
    \? ) echo "Usage: cmd [-list listfile] [-db dbfile] [-output outputfile] [-tree]"
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

# Initialize variables
declare -a ids=()
outfile=""

# Read list file line by line
while IFS= read -r line
do
  # Check if line is a new list indicator
  if [[ $line == "---" ]]; then
    # If ids array is not empty, extract sequences and write to file
    if [[ ${#ids[@]} -ne 0 ]]; then
      seqkit grep -f <(printf '%s\n' "${ids[@]}") $dbfile > $outfile
    fi
    # Clear ids array
    ids=()
  else
    # Add id to ids array
    ids+=("$line")
    # If outfile is empty, set it to the first id
    if [[ -z $outfile ]]; then
      outfile="${line#>}.fasta"
    fi
  fi
done < "$listfile"

# Handle last list
if [[ ${#ids[@]} -ne 0 ]]; then
  seqkit grep -f <(printf '%s\n' "${ids[@]}") $dbfile > $outfile
fi

for file in *.fasta
do
    # Print number of sequences in file
    echo "$file: $(grep -c "^>" "$file") sequences"
done

# Concatenate all .fasta files
# This uses seqkit
seqkit concat *.fasta > $outputfile

# Print number of sequences in output file
echo "Number of sequences in output file: $(grep -c "^>" $outputfile)"

# If tree flag is set, align sequences and generate tree
if [[ $treeflag -eq 1 ]]; then
  mafft --auto $outputfile > aligned.fasta
  iqtree -s aligned.fasta
fi
