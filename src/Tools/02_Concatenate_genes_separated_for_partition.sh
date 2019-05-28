#!/bin/bash

# Combine all the different fasta alignment in a unique
# fasta file

# 1. Start counter, get $phyl_dir, and number of dirs
# $1 == phylip_format						
phyl_dir=$1 #phylip_format/00_alignments_per_locus
num_dirs=$2 #num_fasta
parts=$3    #partition data?

# 2. Get combined aln in format for next perl script
for i in `seq 1 $num_dirs`
do
	if [ $parts == "partN" ]
	then
		sed 1,2d $phyl_dir/${i}/*aln >> $phyl_dir/tmp_combined.aln 
		printf "\n" >> $phyl_dir/tmp_combined.aln 
		name=$( echo $phyl_dir/${i}/*aln | sed 's/..*\///' )
	else
		sed 1d $phyl_dir/${i}/partitions12_*aln >> $phyl_dir/tmp_combined_12.aln 
		printf "\n" >> $phyl_dir/tmp_combined_12.aln 
		
		sed 1d $phyl_dir/${i}/partitions3_*aln >> $phyl_dir/tmp_combined_3.aln 
		printf "\n" >> $phyl_dir/tmp_combined_3.aln 
		
		name_locus=$( echo $phyl_dir/${i}/partitions12.3*aln | sed 's/..*partitions12\.3\_//' | sed 's/\.aln//' )
		sed 1,2d $phyl_dir/${i}/$name_locus*aln >> $phyl_dir/tmp_combined.aln 
		printf "\n" >> $phyl_dir/tmp_combined.aln 
		
		name=$( echo $name_locus )
	fi 
	
	echo File $i visited ":" $name 
	echo File $i visited ":" $name >> $phyl_dir/log02_generate_tmp_aln.txt
	
done 
