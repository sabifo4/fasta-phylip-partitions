#!/bin/bash

# This script generates alignments in PHYLIP format.
# Each aligned fasta file is converted in 
# If more than one file is found in the directory,
# they are concatenated in a unique file, a format 
# file readable by software such as BPP.

# 1. Start counter and set global vars
#        $1  ==> base_dir where this script lies 
# $curr_dir  ==> Current directory when starting this script
count=0
base_dir=$1
out_name=$2
curr_dir=$( pwd )

# 2. Loop over filtered genes and prepare them for phylip_format 
#    analyses
for i in `ls -v1 *fasta`
do

	# 2.0. Create dir and increase counter
	count=$(( count + 1 ))
	mkdir -p phylip_format/$count

	# 2.1 Get locus name  
	locus=$( echo $i | sed 's/\...*//')
	# 2.2 Check num sequences
	num_seq=$( grep '>' $i | wc -l )

	echo Parsing locus $count":" $locus 
	echo Parsing locus $count":" $locus >> phylip_format/log01_phylip_format.txt

	# 2.3 Get one line sequences
	perl $base_dir/one_line_fasta.pl $i
	mv *one_line.fa phylip_format/$count
	# 2.4. Get sequence next to header
	cd phylip_format/$count
	perl $base_dir/00_get_seq_next_to_header.pl *one_line*
	# 2.5. Get alignment in PHYLIP format 
	perl $base_dir/01_conc_seqs.pl *_tab.aln
	# 2.6. Remove unnecessary files 
	rm *one_line*
	cd ../..
	
done

# 3. Go back to $curr_dir/phylip_format, create concatenated PHYLIP format 
#    file if more than one gene/locus, and finish log
cd $curr_dir/phylip_format

if [ $count != 0 ]
then 

	for i in `seq 1 $count`
	do
		cat $i/*aln >> $out_name"_all_loci.aln"
		printf "\n" >> $out_name"_all_loci.aln"
	done 
	
fi

echo There are $count loci visited to generate summary statistics
echo There are $count loci visited to generate summary statistics >> log01_phylip_format.txt

