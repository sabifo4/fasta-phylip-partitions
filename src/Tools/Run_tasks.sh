#!/bin/bash

#-------------------------------------------------------------------#
# This script can be used for the following:                        #
#                                                                   #
#   a) If you have several fasta files with sequences               #
#      already *ALIGNED*, it will output the                        # 
#      corresponding alignment in PHYLIP format (one per            #
#      fasta file provided).                                        #
#      If more than one fasta file is provided, then an             #
#      extra output file called `all_genes_PHYLIP.aln`,             #
#      in which each PHYLIP alignment is appended,                  #
#      will be generated.                                           #
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
#   b) You can generate partitioned files (1st+2nd codon positions) #
#      and 3rd codon positions (read how to pass the argument       #
#      below)                                                       #
#                                                                   #
#   c) You need to create a file called "species_names.txt" with    #
#      the names of the species in your alignments listed (one      #
#      name per line). Please save it in your working directory.    #
#      An example of this file format is:                           #
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
#                |- 1 
#                |  |- file1.aln 
#                |
#                |- 2 
#                |  |- file2.aln 
#                |
#                |- . 
#                |- .
#                |- `n`
#                   |- file`n`.aln 
#                

 
# =====================================================================================
# TASK 2 
# =====================================================================================
# If you wanted to partition each of your alignments into two (1st+2nd codon positions 
# and 3rd codon positions), you can uncomment the code below. 
# This code will generate the `partitions12.3_*aln` and `partitions12_*aln` alignments 
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
		perl $base_dir/Tools/partition_alignments.pl *.aln 2 "\s{6}"
		cd ..
	done 
	printf "\nPartitioned alignments generated!\n"
fi

# =====================================================================================
# TASK 3 
# =====================================================================================
# Concantenate individual alignments in one big alignment in a format that the 
# next perl script  `partition_alignments.pl` can work
# =====================================================================================

# Move to main_dir 
cd $main_dir

printf "\n#----------------------------------------------#"
printf "\n# Generating tmp concatenated alignment... ... #"
printf "\n#----------------------------------------------#\n\n"

# Run script
$base_dir/Tools/02_Concatenate_genes_separated_for_partition.sh $main_dir/phylip_format/00_alignments_per_locus $num_fasta $parts
mv $main_dir/phylip_format/00_alignments_per_locus/tmp_combined.aln $main_dir/phylip_format
if [ $parts == partY ]
then 
	mv $main_dir/phylip_format/00_alignments_per_locus/tmp_combined_12.aln $main_dir/phylip_format
	mv $main_dir/phylip_format/00_alignments_per_locus/tmp_combined_3.aln $main_dir/phylip_format
fi 
# =====================================================================================
# TASK 4 
# =====================================================================================
# Run the script `concatenate_genes_loci_1part.pl` as 
#
#  <path_to_script>/concatenate_genes.pl <alignment_file> <lines_to_skip> \ 
#  <separator> <out_name>
# =====================================================================================

# Move to phylip_format dir
cd $main_dir/phylip_format  

printf "\n#-----------------------------------#"
printf "\n# Generating final alignment... ... #"
printf "\n#-----------------------------------#\n"

perl $base_dir/Tools/02_concatenate_genes.pl tmp_combined.aln $main_dir/species_names.txt "\s{6}" $out_name
if [ -f tmp_combined_12.aln ] 
then 
	printf "\n================================\n"
	printf "\nYou want to partition your data!\n"
	printf "\n1. Generating concatenated alignment with 1st+2nd CPs... ..." 
	printf "\n------------------------------------------------------------\n" 
	perl $base_dir/Tools/02_concatenate_genes.pl tmp_combined_12.aln $main_dir/species_names.txt "\s{6}" part12_$out_name
	printf "\nDONE!\n"
	printf "\n2. Generating concatenated alignment with 3rd CPs... ..." 
	printf "\n--------------------------------------------------------\n" 
	perl $base_dir/Tools/02_concatenate_genes.pl tmp_combined_3.aln $main_dir/species_names.txt "\s{6}" part3_$out_name
	printf "\nDONE!\n\n"
	printf "\n================================\n"
	rm tmp_combined_12.aln tmp_combined_3.aln
fi 
rm tmp_combined.aln

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
printf "           |          |  |- "$file1".aln\n"
printf "           |          |  |- "$file1".log.txt\n"
printf "           |          |\n"
printf "           |          |- . \n"
printf "           |          |- . \n"
printf "           |          |- . \n"
printf "           |          |\n"
printf "           |          |- "$num_fasta" \n"
printf "           |          |  |- "$filen".aln\n"
printf "           |          |  |- "$filen".log.txt\n"
printf "           |          |\n"
printf "           |          |- log01_phylip.format.txt\n" 
printf "           |          |- log02_generate_tmp_aln.txt\n"
printf "           |\n"
printf "           |- 01_alignment_all_loci\n" 
printf "           |          |- "$out_name"_all_loci.aln \n" 
printf "           |\n"
printf "           |- 02_concatenated_alignments\n" 
printf "                      |- "$out_name"_concat.aln \n" 
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
printf "           |          |  |- "$file1".aln\n"
printf "           |          |  |- "$file1".log.txt\n"
printf "           |          |  |- partitions3_"$file1".aln\n"
printf "           |          |  |- partitions12.3_"$file1".aln\n"
printf "           |          |  |- partitions12_"$file1".aln\n"
printf "           |          |\n"
printf "           |          |- . \n"
printf "           |          |- . \n"
printf "           |          |- . \n"
printf "           |          |\n"
printf "           |          |- "$num_fasta" \n"
printf "           |          |  |- "$filen".aln\n"
printf "           |          |  |- "$filen".log.txt\n"
printf "           |          |  |- partitions3_"$filen".aln\n"
printf "           |          |  |- partitions12.3_"$filen".aln\n"
printf "           |          |  |- partitions12_"$filen".aln\n"
printf "           |          |\n"
printf "           |          |- log01_phylip.format.txt\n" 
printf "           |          |- log02_generate_tmp_aln.txt\n"
printf "           |\n"
printf "           |- 01_alignment_all_loci\n" 
printf "           |          |- "$out_name"_all_loci.aln \n" 
printf "           |\n"
printf "           |- 02_concatenated_alignments\n" 
printf "                      |- part3\n"
printf "                      |    |- part3_"$out_name"_concat.aln \n" 
printf "                      |    |- part3_"$out_name"_concat.fasta\n"
printf "                      |    |- part3_"$out_name"_concat_log.txt\n"
printf "                      |    |- part3_"$out_name"_concat_one_line.fasta\n"
printf "                      |    |- part3_"$out_name"_concat_sumstats.tsv\n"
printf "                      |\n"
printf "                      |- part12\n"
printf "                      |    |- part12_"$out_name"_concat.aln \n" 
printf "                      |    |- part12_"$out_name"_concat.fasta\n"
printf "                      |    |- part12_"$out_name"_concat_log.txt\n"
printf "                      |    |- part12_"$out_name"_concat_one_line.fasta\n"
printf "                      |    |- part12_"$out_name"_concat_sumstats.tsv\n"
printf "                      |\n"
printf "                      |- "$out_name"_concat.aln \n" 
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
	mkdir -p part12 part3 
	mv part12_* part12 
	mv part3_* part3
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
fi 

 
printf "\n#----------------------#"
printf "\n# All tasks completed! #"
printf "\n#----------------------#\n\n"
