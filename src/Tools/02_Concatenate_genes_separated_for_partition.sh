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
		sed 1,2d $phyl_dir/${i}/*phy >> $phyl_dir/tmp_combined.phy 
		printf "\n" >> $phyl_dir/tmp_combined.phy 
		name=$( echo $phyl_dir/${i}/*phy | sed 's/..*\///' )
	else
		sed 1d $phyl_dir/${i}/partitions12_*phy >> $phyl_dir/tmp_combined_12.phy 
		printf "\n" >> $phyl_dir/tmp_combined_12.phy 

		# 250511-SAC: writing out sequence alignment with only 1st CPs or
		# only 2nd CPs
		sed 1d $phyl_dir/${i}/partitions1_*phy >> $phyl_dir/tmp_combined_1.phy 
		printf "\n" >> $phyl_dir/tmp_combined_1.phy 
		
		sed 1d $phyl_dir/${i}/partitions2_*phy >> $phyl_dir/tmp_combined_2.phy 
		printf "\n" >> $phyl_dir/tmp_combined_2.phy 
		
		sed 1d $phyl_dir/${i}/partitions3_*phy >> $phyl_dir/tmp_combined_3.phy 
		printf "\n" >> $phyl_dir/tmp_combined_3.phy 
		
		name_locus=$( echo $phyl_dir/${i}/partitions12.3*phy | sed 's/..*partitions12\.3\_//' | sed 's/\.phy//' )
		sed 1,2d $phyl_dir/${i}/$name_locus*phy >> $phyl_dir/tmp_combined.phy 
		printf "\n" >> $phyl_dir/tmp_combined.phy 
		
		name=$( echo $name_locus )
	fi 
	
	echo File $i visited ":" $name 
	echo File $i visited ":" $name >> $phyl_dir/log02_generate_tmp_aln.txt
	
done 
