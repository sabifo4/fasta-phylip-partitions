# Fasta-Phylip-Partitions 

## What can I find here?
This repository contains a set of scripts in the `src` directory that can be called through the `bash` script `Run_tasks.sh`. The tasks that are performed are the following:   
   * It can convert files with sequences **already aligned** from fasta to PHYLIP format. If more than one fasta file is provided, an extra output file called `<your_output_name>_all_genes_PHYLIP.aln` will be generated. This file will contain each of the alignments in PHYLIP format one after the other, such as:   
   ```
        ___________________________                                
       |                            |                              
       | 3 256                      |                              
       | sp1 ATGCGTGCAAAGTTGGCC...  |                              
       | sp2 ATGCGaGCTTTGTAGGCC...  |                              
       | sp3 ATGC-TGCATACAAGGGC...  |                              
       |                            |                              
       | 3 35                       |                              
       | sp1 ATTG-----TTTACTTTA...  |                              
       | sp2 ATTGCGTGCTTTACG--A...  |                              
       | sp3 ATTC---GCTTTA----A...  |                              
       |                            |                              
       | 3 60                       |                              
       | sp1 ATGCCTTGGCTTAGATGC...  |                              
       | sp2 ATGT--TGGCTTAGA-GC...  |                              
       | sp3 ATGC-TTGGCAAAGATGC...  |                              
       |____________________________|      
   ```
   > #### _This file format can be useful for software like `bpp`._   
  * You can generate partitioned files with first and second codon positions (one partition) and third codon positions (another partition). Read below how to enable this task.   

## What files should I provide?

You will need to have a directory with your _n_ aligned sequences in fasta format such as: 
```
your_working_directory 
        |- file_1.fasta 
        |- file_2.fasta 
        |- .
        |- .
        |- file_n.fasta
```
> #### **NOTE: This script will be looking for files with extension `.fasta`, not `.fa`. Please modify your files accordingly. You can use a `for` loop like this one:**
```bash
cd your_dir_with_.fa_files
for file in *fa
do
name=$( echo $file | sed 's/\.fa/\.fasta/' )
mv $file $name
done
```
You will also need to create a text file called `species_names.txt` with the names (one name per row) of all the species that are present in the alignments. The content of this file should look like this: 

```
name_sp1
name_sp2
name_sp3
name_sp4
name_spn
```

You can save it in your working directory with the rest of the fasta files. Therefore, your working directory should look like this:

```
your_working_directory 
        |- file_1.fasta 
        |- file_2.fasta 
        |- .
        |- .
        |- file_n.fasta
        |- species_names.txt
```

## How do I run this?

You should clone this repository and export the path to the script `Run_tasks.sh` to your `~/.bashrc` or `~/.bash_profile`. This will allow you to run this script from any location of your PC without having to type the absolute path to the bash script. 

The `Run_tasks.sh` takes three arguments:   

   * `<path_to_you_directory_with_fasta_alignments>`: This is the path to where all your fasta files can be found. If you are running this script within this directory, this argument should be a `.`, indicating "current directory".   
   * `<name_for_output_files>`: String (without quotation marks) that will be used to name the output files. E.g., "proj5910".   
   * `<partY|partN>`: If you want your data to be partitioned according to gene codon position, you should enter as a third argument `partY`. Otherwise, you should type `partN`.  
 
This script can be run as it follows:

```
Run_tasks.sh <path_to_you_directory_with_fasta_alignments> <name_for_output_files> <partY|partN>
```

> #### **NOTE: The bash scripts assume that the `bash` is in `/bin/bash`, hence the shebang is `#!/bin/bash`. If your `bash` is somewhere else, please change the line of the bash scripts accordingly. For instance, you could run the following `for` loop:**
```bash
cd fasta-phylip-partitions/src
sed -i 's/\#\!\/bin\/bash/\#\!<ADD_HERE_YOUR_PATH_TO_BASH>/' Run_tasks.sh 
for i in Tools/*.sh 
do 
	sed -i 's/\#\!\/bin\/bash/\#\!<ADD_HERE_YOUR_PATH_TO_BASH>/' $i 
done
```

## What will the output be?

### If you decide to generate partitioned alignments...

If you decide to run the `Run_tasks.sh` script allowing for generating partitioned alignments, you will have different output files in the following architecture:

```
phylip_format 
         |- 00_alignments_per_locus 
         |          |- 1  
         |          |  |- <file1_name>.aln
         |          |  |- <file1_name>.log.txt
         |          |  |- partitions3_<file1_name>.aln
         |          |  |- partitions12.3_<file1_name>.aln
         |          |  |- partitions12_<file1_name>.aln
         |          |
         |          |- . 
         |          |- . 
         |          |- . 
         |          |
         |          |- n
         |          |  |- <filen_name>.aln
         |          |  |- <filen_name>.log.txt
         |          |  |- partitions3_<filen_name>.aln
         |          |  |- partitions12.3_<filen_name>.aln
         |          |  |- partitions12_<filen_name>.aln
         |          |
         |          |- log01_phylip.format.txt 
         |          |- log02_generate_tmp_aln.txt
         |
         |- 01_alignment_all_loci 
         |          |- <tag_out_name>_all_loci.aln  
         |
         |- 02_concatenated_alignments 
                    |- part3
                    |    |- part3_<tag_out_name>_concat.aln  
                    |    |- part3_<tag_out_name>_concat.fasta
                    |    |- part3_<tag_out_name>_concat_log.txt
                    |    |- part3_<tag_out_name>_concat_one_line.fasta
                    |    |- part3_<tag_out_name>_concat_sumstats.tsv
                    |
                    |- part12
                    |    |- part12_<tag_out_name>_concat.aln  
                    |    |- part12_<tag_out_name>_concat.fasta
                    |    |- part12_<tag_out_name>_concat_log.txt
                    |    |- part12_<tag_out_name>_concat_one_line.fasta
                    |    |- part12_<tag_out_name>_concat_sumstats.tsv
                    |
                    |- <tag_out_name>_concat.aln  
                    |- <tag_out_name>_concat.fasta
                    |- <tag_out_name>_concat_log.txt
                    |- <tag_out_name>_concat_one_line.fasta
                    |- <tag_out_name>_concat_sumstats.tsv

```

A. Inside `00_alignments_per_locus` you will have:   
   * Subdirectories labelled from `1` to `n`, being `n` the amount of fasta files you have, in which the alignments in PHYLIP format will be output together with a log file. For subdirectory `i`, then:   
      *  `<filei_name>_.aln`: Alignment in PHYLIP format.   
      * `<filei_name>_.log.txt`: Log file that keeps track that the sequences for all the species have been visited.   
      * `partitions3_<filei_name>.aln`: Alignment in PHYLIP format with only the 3rd codon positions (CPs) of the sequences.   
      * `partitions12.3_<filei_name>.aln`: Alignment in PHYLIP format with the 1st + 2nd CPs in one partition and the 3rd CPs in another partition.   
      * `partitions12_<filei_name>.aln`: Alignment in PHYLIP format with only the 1st + 2nd CPs of the sequences.   
   * Log files that keep track of all the fasta files visited and parsed.

B. Inside `01_alignment_all_loci` you will have the `tag_out_name>_all_loci.aln` file, which contains all the PHYLIP alignments for each loci concatenated one after the other. This is the format that software such as `bpp` require for their input files.

C. Inside `02_concatenated_alignments` you will have:   
   * `part3`: Subdirectory in which the output files for the alignment with only 3rd CPs will be saved. These files are:   
      * `part3_<tag_out_name>_concat.aln`: Concatenated alignment of all the 3rd CPs for all the loci, i.e., ACG... <==> 3rdCP.locus1|3rdCP.locus2|3rdCP.locus3...   
      * `part3_<tag_out_name>_concat.fasta`: Concatenated alignment of all the 3rd CPs for all the loci in fasta format.   
      * `part3_<tag_out_name>_concat_log.txt`: Log file that keeps track that each concatenated sequence for all the species has the same length.   
      * `part3_<tag_out_name>_concat_one_line.fasta`: Same file that `part3_<tag_out_name>_concat.fasta`, but with the sequence in one line.   
      * `part3_<tag_out_name>_concat_sumstats.tsv`: Log file tab separated with 5 columns:   
         * Gene: Numeric, corresponding to the number of locus parsed.   
         * Number of species: Numeric, number of species in the alignment of that specific locus.   
         * Number of missing species: Numeric, number of missing species in this alignment.   
         * Total genes: Total number of genes (should be always the same).   
         * Name of missing species: Character, name of species missing in that locus alignment.   
   * `part12`: Subdirectory in which the output files for the alignment with only 1st+2nd CPs will be saved. The output files are the same than those described for the `part3`. The only difference is that they start with `part12`.   
   * `<tag_out_nam>_concat.*` files: The same files described above but having the sequences concatenated.   
   
### If you just want the concatenated alignments... 

If you decide to run the `Run_tasks.sh` without generating partitioned alignments, you will have the same output files that have been described in the section above except for those corresponding to the partitioned alignments. The architecture will then be the following:

```
phylip_format 
         |- 00_alignments_per_locus 
         |          |- 1  
         |          |  |- <file1_name>.aln
         |          |  |- <file1_name>.log.txt
         |          |
         |          |- . 
         |          |- . 
         |          |- . 
         |          |
         |          |- n
         |          |  |- <filen_name>.aln
         |          |  |- <filen_name>.log.txt
         |          |
         |          |- log01_phylip.format.txt 
         |          |- log02_generate_tmp_aln.txt
         |
         |- 01_alignment_all_loci 
         |          |- <tag_out_name>_all_loci.aln  
         |
         |- 02_concatenated_alignments 
                    |- <tag_out_name>_concat.aln  
                    |- <tag_out_name>_concat.fasta
                    |- <tag_out_name>_concat_log.txt
                    |- <tag_out_name>_concat_one_line.fasta
                    |- <tag_out_name>_concat_sumstats.tsv

```

## Are there any examples?

You can find two examples in the `examples` directory in which two different jobs have been carried out:   

   * Get only a concatenated alignment: You can go to `examples>test_data_partitionNO` and check the output files generated within the `fasta_data>phylip_format` directory. If you want to rerun the analysis, you can delete the `phylip_format` directory within the `fasta_data` directory and run the following command. The output files will have the tag `proj5190` in their names:  
   ```
   Run_tasks.sh . proj5190 partN
   ```

   * Get both a concatenated alignment and partitioned alignments: You can go to `examples>test_data_partitionYES` and check the output files generated within the `fasta_data>phylip_format` directory. If you want to rerun the analysis, you can delete the `phylip_format` directory within the `fasta_data` directory and run the following command.The output files will have the tag `proj5190` in their names: 
   ```
   Run_tasks.sh . proj5190 partY
   ```
   

---
If you have any questions/suggestions, please send a message to:  
Sandra Alvarez-Carretero <sandra.ac93@gmail.com>                
