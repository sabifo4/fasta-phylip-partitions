#!/bin/bash

#-------------------------------------------------------------------#
# This script executes the bioinformatics tool                      #
# `fasta-phylip-partitions`. You can use it to carry out the        #
# following tasks:                                                  #
#                                                                   #
#   a) If you have several fasta files with sequences               #
#      already *ALIGNED*, `fasta-phylip-partitions` will            # 
#      firstly convert them into PHYLIP format.                     #
#      If more than one fasta file is provided, then a              #
#      PHYLIP alignment file with one alignment block per           #
#      gene alignment will be generated.                            #
#      E.g., concatenated file with 3 loci:                         #
#                                                                   #
#        ___________________________                                #
#       |                            |                              #
#       | 3 256                      |                              #
#       | sp1 ATGCGTGCAAAGTTGGCC...  |                              #
#       | sp2 ATGCGaGCTTTGTAGGCC...  |                              #
#       | sp3 ATGC-TGCATACAAGGGC...  |                              #
#       |                            |                              #
#       | 3 35                       |                              #
#       | sp1 ATTG-----TTTACTTTA...  |                              #
#       | sp2 ATTGCGTGCTTTACG--A...  |                              #
#       | sp3 ATTC---GCTTTA----A...  |                              #
#       |                            |                              #
#       | 3 60                       |                              #
#       | sp1 ATGCCTTGGCTTAGATGC...  |                              #
#       | sp2 ATGT--TGGCTTAGA-GC...  |                              #
#       | sp3 ATGC-TTGGCAAAGATGC...  |                              #
#       |____________________________|                              #
#                                                                   #
#   b) You can output sequence alignment files partitioned          #
#      according to a codon-position partitioning scheme.           #
#      If you enable this feature, `fasta-phylip-partitions`        #
#      will output the following:                                   #
#         * Alignment with only 1st CPs                             #
#         * Alignment with only 2nd CPs                             #
#         * Alignment with only 3rd CPs                             #
#         * Alignment with only 1st+2nd CPs                         #
#         * Alignment with only 1st+2nd CPs (first block) and       #
#           and 3rd CPs (second block)       
#     If you do not enable this feature, you will only obtain       #
#     PHYLIP-formatted                        #
#                                                                   #
#   c) You need to create a file called "species_names.txt" with    #
#      the same names you have used to identify the sequences       #
#      in your gene alignment/s (i.e., individual FASTA-formatted   #
#      sequence alignments).                                        #
#      Please save this filet in your working directory, same       #
#      place where you will save your FASTA files!                  #
#                                                                   #
#      An example below shots the expected format for file          #
#      "species_names.txt" (please, do not change the file          #
#      name!)                                                       #
#        ____________________________                               #
#       |                            |                              #
#       | sp1                        |                              #
#       | sp2                        |                              #
#       | sp3                        |                              #
#       | sp4                        |                              #
#       | sp5                        |                              #
#       |____________________________|                              #
#                                                                   #
# You should run this script as:                                    #
#                                                                   #
# ./Run_tasks.sh <path_to_you_directory_with_fasta_alignments> \    #
#  <output_name> <partY|partN> <path_to/species_name.txt>           #
#                                                                   #
# Note that if you want to partition your data, the third argument  # 
# should be "partY" (no quotation marks). Otherwise, type "partN"   #
# without quationt marks.                                           #
#===================================================================#
# If you have any suggestions/questions, please send a message to:  #
# Sandra Alvarez-Carretero <sandra.ac93@gmail.com>                  #
#--------------------------------------------------------------------
   

# Get global vars
# $main_dir ==> Path to where you have the *.fasta files for your *ALIGNED* sequences
# $base_dir ==> Path to where all the scripts + this script can be found
main_dir_path=$1
cd $main_dir_path
main_dir=$( pwd )
base_dir_path=${0%/*}
cd $base_dir_path
base_dir=$( pwd )
out_name=$2
parts=$3

# Move to main dir 
cd $main_dir
file1=`ls -v1 *fasta | head -1 | sed 's/\.fasta$//'`
filen=`ls -v1 *fasta | tail -1 | sed 's/\.fasta$//'`

# Count fasta files 
num_fasta=`ls *fasta | wc -l`

# Create $phylip_dir if not inside $main_dir yet
if [ ! -d phylip_format ]
then 
mkdir -p phylip_format
fi

# Start tasks

# =====================================================================================
# TASK 1 
# =====================================================================================
# Run `01_Get_phylip_format.sh` inside the directory where all locus*fasta files are.
# A new directory called `phylip_format/$count` will bre created there, where the 
# loci in PHYLIP format will be saved. This is in case array jobs are to be run 
# in the cluster, so each gene is saved within a directory labelled from count=1 
# to count=n, being n the amount of total loci
# Also, a log file `log_phylip_format.txt` is generated once this script 
# finishes.
# =====================================================================================

printf "\n#---------------------------------------#"
printf "\n# Generating PHYLIP format files... ... #"
printf "\n#---------------------------------------#\n\n"


$base_dir/Tools/01_Get_phylip_format.sh $base_dir/Tools $out_name

# Create dir for individual loci alignments
cd $main_dir 
mkdir 00_alignments_per_locus

for i in $main_dir/phylip_format/*
do
	mv $i 00_alignments_per_locus
done

mv 00_alignments_per_locus $main_dir/phylip_format/

# Now, the main directory should look sth like:
#
# $main_dir 
#        |- file1.fasta 
#        |- file2.fasta 
#        |- .
#        |- .
#        |- file`n`.fasta
#        |- phylip_format
#            |- 00_alignments_per_locus
#                |- 1 
#                |  |- file1.phy 
#                |
#                |- 2 
#                |  |- file2.phy 
#                |
#                |- . 
#                |- .
#                |- `n`
#                   |- file`n`.phy 
#                

## 250516-SAC: adding new feature to count missing data
printf "\n#------------------------------------------------#"
printf "\n# Calculating missing data for each locus... ... #"
printf "\n#------------------------------------------------#\n\n"
mkdir -p $main_dir/phylip_format/logs_missingdata
cd $main_dir/phylip_format/logs_missingdata
out_logs=$( pwd )
home_dir=$( echo $main_dir/phylip_format/00_alignments_per_locus )
cd $home_dir
# Go inside every directory, `1` to `n`
for j in [0-9]*/
do
cd $home_dir/$j
i=`ls *phy`
name=$( echo $i | sed 's/\.phy//' )
printf "Calculating missing data for locus 1: "$name"... ...\n"
perl $base_dir/Tools/count_missingdat_nuc.pl $i >> $out_logs/log_count_missdat_$name".txt"
# Get a summary!
printf "<< DIR "$name" >>\n" > $home_dir/$j/out_count_NA/$name"_countNA.tsv"
sed -n '1,2p' $home_dir/$j/out_count_NA/$name"_avgmissdata.txt" >> $home_dir/$j/out_count_NA/$name"_countNA.tsv"
sed -n '7,7p' $home_dir/$j/out_count_NA/$name"_avgmissdata.txt" >> $home_dir/$j/out_count_NA/$name"_countNA.tsv"
sed -n '9,9p' $home_dir/$j/out_count_NA/$name"_avgmissdata.txt" >> $home_dir/$j/out_count_NA/$name"_countNA.tsv"
printf "\n" >> $home_dir/$j/out_count_NA/$name"_countNA.tsv"
sed -n '11,12p' $home_dir/$j/out_count_NA/$name"_avgmissdata.txt" >> $home_dir/$j/out_count_NA/$name"_countNA.tsv"
sed -n '17,17p' $home_dir/$j/out_count_NA/$name"_avgmissdata.txt" >> $home_dir/$j/out_count_NA/$name"_countNA.tsv"
sed -n '19,19p' $home_dir/$j/out_count_NA/$name"_avgmissdata.txt" >> $home_dir/$j/out_count_NA/$name"_countNA.tsv"
printf "\n" >> $home_dir/$j/out_count_NA/$name"_countNA.tsv"
mv $home_dir/$j/out_count_NA $out_logs/out_count_NA_$name
done
# Go back to main directory
mv $main_dir/phylip_format/logs_missingdata $main_dir/phylip_format/00_alignments_per_locus
cd $main_dir 
 
# =====================================================================================
# TASK 2 
# =====================================================================================
# If you wanted to partition each of your alignments into two (1st+2nd codon positions 
# and 3rd codon positions), you can uncomment the code below. 
# This code will generate the `partitions12.3_*phy` and `partitions12_*phy` alignments 
# within the corresponding directories for each alignment.
#  
# The script `partition_alignments.pl` can be run individually as it follows too:
# 
#   <path_to_script>/partition_alignments.pl <alignment_file> <lines_to_skip> \ 
#   <separator>
# =====================================================================================

if [ $parts == "partY" ] 
then 
	
	# Move to `phylip_format` directory and run as it follows: 
	cd $main_dir/phylip_format/00_alignments_per_locus
	printf "\nYou have decided to partition your alignment!\n\n"
	for i in `seq 1 $num_fasta`
	do
		cd $i
		perl $base_dir/Tools/partition_alignments.pl *.phy 2 "\s{6}"
		cd ..
	done 
	printf "\nPartitioned alignments generated!\n"
fi

# =====================================================================================
# TASK 3 
# =====================================================================================
# Concantenate individual alignments in one big alignment in a format that the 
# next perl script can work
# =====================================================================================

# Move to main_dir 
cd $main_dir

printf "\n#----------------------------------------------#"
printf "\n# Generating tmp concatenated alignment... ... #"
printf "\n#----------------------------------------------#\n\n"

# Run script
$base_dir/Tools/02_Concatenate_genes_separated_for_partition.sh $main_dir/phylip_format/00_alignments_per_locus $num_fasta $parts
mv $main_dir/phylip_format/00_alignments_per_locus/tmp_combined.phy $main_dir/phylip_format
if [ $parts == partY ]
then 
	mv $main_dir/phylip_format/00_alignments_per_locus/tmp_combined_12.phy $main_dir/phylip_format
	mv $main_dir/phylip_format/00_alignments_per_locus/tmp_combined_3.phy $main_dir/phylip_format
	# 250511-SAC: writing out sequence alignment with only 1st or 2nd CPs, separately
	mv $main_dir/phylip_format/00_alignments_per_locus/tmp_combined_1.phy $main_dir/phylip_format
	mv $main_dir/phylip_format/00_alignments_per_locus/tmp_combined_2.phy $main_dir/phylip_format
fi 
# =====================================================================================
# TASK 4 
# =====================================================================================
# Run the script `02_concatenate_genes.pl` as 
#
#  <path_to_script>/02_concatenate_genes.pl <alignment_file> <species_list> \ 
#  <separator> <out_name>
# =====================================================================================

# Move to phylip_format dir
cd $main_dir/phylip_format  

printf "\n#-----------------------------------#"
printf "\n# Generating final alignment... ... #"
printf "\n#-----------------------------------#\n"

perl $base_dir/Tools/02_concatenate_genes.pl tmp_combined.phy $main_dir/species_names.txt "\s{6}" $out_name
if [ -f tmp_combined_12.phy ] 
then 
	printf "\n================================\n"
	printf "\nYou want to partition your data!\n"
	printf "\n1. Generating concatenated alignment with 1st+2nd CPs... ..." 
	printf "\n------------------------------------------------------------\n" 
	perl $base_dir/Tools/02_concatenate_genes.pl tmp_combined_12.phy $main_dir/species_names.txt "\s{6}" part12_$out_name
	printf "\nDONE!\n"
	# 250511-SAC: writing out sequence alignment with only 1st CPs
	# or only 2nd CPs
	printf "\n2. Generating concatenated alignment with 1st CPs... ..." 
	printf "\n--------------------------------------------------------\n" 
	perl $base_dir/Tools/02_concatenate_genes.pl tmp_combined_1.phy $main_dir/species_names.txt "\s{6}" part1_$out_name
	printf "\nDONE!\n\n"
	printf "\n3. Generating concatenated alignment with 2nd CPs... ..." 
	printf "\n--------------------------------------------------------\n" 
	perl $base_dir/Tools/02_concatenate_genes.pl tmp_combined_2.phy $main_dir/species_names.txt "\s{6}" part2_$out_name
	printf "\nDONE!\n\n"
	printf "\n4. Generating concatenated alignment with 3rd CPs... ..." 
	printf "\n--------------------------------------------------------\n" 
	perl $base_dir/Tools/02_concatenate_genes.pl tmp_combined_3.phy $main_dir/species_names.txt "\s{6}" part3_$out_name
	printf "\nDONE!\n\n"
	printf "\n================================\n"
	# 250511-SAC: remove unwanted files, add tmp*1.phy and tmp*2.phy
	#rm tmp_combined_12.phy tmp_combined_3.phy
	rm tmp_combined_12.phy tmp_combined_3.phy tmp_combined_1.phy tmp_combined_2.phy
fi 
rm tmp_combined.phy

printf "\n#------------------------------#"
printf "\n# Ordering output files... ... #"
printf "\n#------------------------------#\n"

if [ $parts == "partN" ]
then 

printf "\n The \"phylip_format\" dirctory will contain"
printf "\n the following directories with output files:\n" 
printf "\n" 
printf "  phylip_format\n" 
printf "           |- 00_alignments_per_locus\n" 
printf "           |          |- 1 \n" 
printf "           |          |  |- "$file1".phy\n"
printf "           |          |  |- "$file1".log.txt\n"
printf "           |          |\n"
printf "           |          |- . \n"
printf "           |          |- . \n"
printf "           |          |- . \n"
printf "           |          |\n"
printf "           |          |- "$num_fasta" \n"
printf "           |          |  |- "$filen".phy\n"
printf "           |          |  |- "$filen".log.txt\n"
printf "           |          |\n"
# 250511-SAC: update file structure to include those files related
# to sequence alignments with only 1st CPs or 2nd CPs (separately)
printf "           |          |- logs_missingdata\n" 
printf "           |          |   |- out_count_NA_"$file1"\n"
printf "           |          |   |   |- "$file1"_avgmissdata.txt\n"
printf "           |          |   |   |- "$file1"_countNA.tsv\n"
printf "           |          |   |   |- "$file1"_missdatapersp.txt\n"
printf "           |          |   |\n"
printf "           |          |   |- . \n"
printf "           |          |   |- . \n"
printf "           |          |   |- . \n"
printf "           |          |   |\n"
printf "           |          |   |- out_count_NA_"$filen"\n"
printf "           |          |   |   |- "$filen"_avgmissdata.txt\n"
printf "           |          |   |   |- "$filen"_countNA.tsv\n"
printf "           |          |   |   |- "$filen"_missdatapersp.txt\n"
printf "           |          |   |\n"
printf "           |          |   |- log_count_missdat_"$file1".txt\n"
printf "           |          |   |\n"
printf "           |          |   |- . \n"
printf "           |          |   |- . \n"
printf "           |          |   |- . \n"
printf "           |          |   |\n"
printf "           |          |   |- log_count_missdat_"$filen".txt\n"
printf "           |          |\n"
printf "           |          |- log01_phylip_format.txt\n" 
printf "           |          |- log02_generate_tmp_aln.txt\n"
printf "           |\n"
printf "           |- 01_alignment_all_loci\n" 
printf "           |          |- "$out_name"_all_loci.phy \n" 
printf "           |\n"
printf "           |- 02_concatenated_alignments\n" 
printf "                      |- "$out_name"_concat.phy \n" 
printf "                      |- "$out_name"_concat.fasta\n"
printf "                      |- "$out_name"_concat_log.txt\n"
printf "                      |- "$out_name"_concat_one_line.fasta\n"
printf "                      |- "$out_name"_concat_sumstats.tsv\n\n"

else
printf "\n The \"phylip_format\" dirctory will contain"
printf "\n the following directories with output files:\n" 
printf "\n" 
printf "  phylip_format\n" 
printf "           |- 00_alignments_per_locus\n" 
printf "           |          |- 1 \n" 
printf "           |          |  |- "$file1".phy\n"
printf "           |          |  |- "$file1".log.txt\n"
# 250511-SAC: update file structure to include those files related
# to sequence alignments with only 1st CPs or 2nd CPs (separately)
printf "           |          |  |- partitions12.3_"$file1".phy\n"
printf "           |          |  |- partitions12_"$file1".phy\n"
printf "           |          |  |- partitions1_"$file1".phy\n"
printf "           |          |  |- partitions2_"$file1".phy\n"
printf "           |          |  |- partitions3_"$file1".phy\n"
printf "           |          |\n"
printf "           |          |- . \n"
printf "           |          |- . \n"
printf "           |          |- . \n"
printf "           |          |\n"
printf "           |          |- "$num_fasta" \n"
printf "           |          |  |- "$filen".phy\n"
printf "           |          |  |- "$filen".log.txt\n"
# 250511-SAC: update file structure to include those files related
# to sequence alignments with only 1st CPs or 2nd CPs (separately)
printf "           |          |  |- partitions12.3_"$filen".phy\n"
printf "           |          |  |- partitions12_"$filen".phy\n"
printf "           |          |  |- partitions1_"$filen".phy\n"
printf "           |          |  |- partitions2_"$filen".phy\n"
printf "           |          |  |- partitions3_"$filen".phy\n"
printf "           |          |\n"
# 250511-SAC: update file structure to include those files related
# to sequence alignments with only 1st CPs or 2nd CPs (separately)
printf "           |          |- logs_missingdata\n" 
printf "           |          |   |- out_count_NA_"$file1"\n"
printf "           |          |   |   |- "$file1"_avgmissdata.txt\n"
printf "           |          |   |   |- "$file1"_countNA.tsv\n"
printf "           |          |   |   |- "$file1"_missdatapersp.txt\n"
printf "           |          |   |\n"
printf "           |          |   |- . \n"
printf "           |          |   |- . \n"
printf "           |          |   |- . \n"
printf "           |          |   |\n"
printf "           |          |   |- out_count_NA_"$filen"\n"
printf "           |          |   |   |- "$filen"_avgmissdata.txt\n"
printf "           |          |   |   |- "$filen"_countNA.tsv\n"
printf "           |          |   |   |- "$filen"_missdatapersp.txt\n"
printf "           |          |   |\n"
printf "           |          |   |- log_count_missdat_"$file1".txt\n"
printf "           |          |   |\n"
printf "           |          |   |- . \n"
printf "           |          |   |- . \n"
printf "           |          |   |- . \n"
printf "           |          |   |\n"
printf "           |          |   |- log_count_missdat_"$filen".txt\n"
printf "           |          |\n"
printf "           |          |- log01_phylip_format.txt\n" 
printf "           |          |- log02_generate_tmp_aln.txt\n"
printf "           |\n"
printf "           |- 01_alignment_all_loci\n" 
printf "           |          |- "$out_name"_all_loci.phy \n" 
printf "           |\n"
printf "           |- 02_concatenated_alignments\n" 
# 250511-SAC: update file structure to include those files related
# to sequence alignments with only 1st CPs or 2nd CPs (separately)
printf "                      |- part1\n"
printf "                      |    |- part1_"$out_name"_concat.phy \n" 
printf "                      |    |- part1_"$out_name"_concat.fasta\n"
printf "                      |    |- part1_"$out_name"_concat_log.txt\n"
printf "                      |    |- part1_"$out_name"_concat_one_line.fasta\n"
printf "                      |    |- part1_"$out_name"_concat_sumstats.tsv\n"
printf "                      |\n"
printf "                      |- part12\n"
printf "                      |    |- part12_"$out_name"_concat.phy \n" 
printf "                      |    |- part12_"$out_name"_concat.fasta\n"
printf "                      |    |- part12_"$out_name"_concat_log.txt\n"
printf "                      |    |- part12_"$out_name"_concat_one_line.fasta\n"
printf "                      |    |- part12_"$out_name"_concat_sumstats.tsv\n"
printf "                      |\n"
printf "                      |- part2\n"
printf "                      |    |- part2_"$out_name"_concat.phy \n" 
printf "                      |    |- part2_"$out_name"_concat.fasta\n"
printf "                      |    |- part2_"$out_name"_concat_log.txt\n"
printf "                      |    |- part2_"$out_name"_concat_one_line.fasta\n"
printf "                      |    |- part2_"$out_name"_concat_sumstats.tsv\n"
printf "                      |\n"
printf "                      |- part3\n"
printf "                      |    |- part3_"$out_name"_concat.phy \n" 
printf "                      |    |- part3_"$out_name"_concat.fasta\n"
printf "                      |    |- part3_"$out_name"_concat_log.txt\n"
printf "                      |    |- part3_"$out_name"_concat_one_line.fasta\n"
printf "                      |    |- part3_"$out_name"_concat_sumstats.tsv\n"
printf "                      |\n"
printf "                      |- "$out_name"_concat.phy \n" 
printf "                      |- "$out_name"_concat.fasta\n"
printf "                      |- "$out_name"_concat_log.txt\n"
printf "                      |- "$out_name"_concat_one_line.fasta\n"
printf "                      |- "$out_name"_concat_sumstats.tsv\n\n"

fi 

# Create dir for alignment with all loci 
mkdir 01_alignment_all_loci 
mv $main_dir/phylip_format/00_alignments_per_locus/*all_loci*  01_alignment_all_loci 

# Create dir for concatenated alignments 
mkdir 02_concatenated_alignments 
mv *_concat[\_\.]* 02_concatenated_alignments
cd $main_dir/phylip_format/02_concatenated_alignments

if [ $parts == "partN" ]
then 
	perl $base_dir/Tools/one_line_fasta.pl *_concat.fasta
	for i in *.fa
	do 
		name=$( echo $i | sed 's/\.fa/\.fasta/' )
		mv $i $name
	done
else 
    # 250511-SAC: adding file structure where files
	# for sequence alignment with only 1st CPs
	# or 2nd CPs are output 
	#mkdir -p part12 part3 
	mkdir -p part12 part3 part2 part1
	mv part12_* part12 
	mv part3_* part3
	# 250511-SAC: moving files with 1st and 2nd CPs 
	# separately
	mv part1_* part1
	mv part2_* part2
	perl $base_dir/Tools/one_line_fasta.pl *_concat.fasta
	for i in *.fa
	do 
		name=$( echo $i | sed 's/\.fa/\.fasta/' )
		mv $i $name
	done
	
	cd part12
	perl $base_dir/Tools/one_line_fasta.pl *_concat.fasta
	for i in *.fa
	do 
		name=$( echo $i | sed 's/\.fa/\.fasta/' )
		mv $i $name
	done
	
	cd ../part3 
	perl $base_dir/Tools/one_line_fasta.pl *_concat.fasta
	for i in *.fa
	do 
		name=$( echo $i | sed 's/\.fa/\.fasta/' )
		mv $i $name
	done

	# 250511-SAC: fixing file structure for sequence
	# alignment files with only 1st or only 2nd CPs
	cd ../part1
	perl $base_dir/Tools/one_line_fasta.pl *_concat.fasta
	for i in *.fa
	do 
		name=$( echo $i | sed 's/\.fa/\.fasta/' )
		mv $i $name
	done
	
	cd ../part2
	perl $base_dir/Tools/one_line_fasta.pl *_concat.fasta
	for i in *.fa
	do 
		name=$( echo $i | sed 's/\.fa/\.fasta/' )
		mv $i $name
	done
fi 

 
printf "\n#----------------------#"
printf "\n# All tasks completed! #"
printf "\n#----------------------#\n\n"
