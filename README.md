# Fasta-Phylip-Partitions

## What can you find in this repository?

This repository hosts the bioinformatics tool `fasta-phylip-partitions`, which you can run by executing the main bash script `Run_tasks.sh`, which is located in the `src` directory alongside additional scripts called during its execution. The set of tasks that will be carried out are summarised below:

* Firstly, files containing FASTA-formatted gene alignments (sequences **must be aligned** and in **FASTA** format!) will be converted from FASTA to PHYLIP format. If more than one FASTA file is located in the working directory, this tool will assume that each FASTA file contains one gene alignment. Under such scenario, an extra output file called `<name_output_files>_all_genes_PHYLIP.aln` will be generated, which will include as many alignment blocks as FASTA files are located in the working directory. The alignment blocks will be written one after the other in PHYLIP format. E.g.: if three individual FASTA files had been found in the working directory (i.e.
, three gene alignments), the format could have looked as follows:

  ```text
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

> [!NOTE]
> This file format can be useful if you need to generate input sequence files for phylogenetic software such as [`PAML`](https://github.com/abacus-gene/paml) or [`BPP`](https://github.com/bpp/bpp).

* Regardless of partitioning your sequence data (option `partY`) or not (option `partN`), this tool will always output the following:
  * One PHYLIP-formatted file for each input sequence file (`00_alignments_per_locus/[0-9]*`) and a log specifying the length each sequence in the alignment.
  * Logs regarding the missing data in each input gene alignment (`00_alignments_per_locus/logs_missingadata`).
  * A sequence file with as many alignment blocks as gene alignments were found in the working directory (`01_alignment_all_loci/<name_output_files>_all_loci.phy`).
  * A concatenated sequence file with all your loci in directory `02_concatenated alignments` alongside additional files with some stats regarding the sequence length and missing data (i.e., `<name_output_files>_sumstats.csv`).
* If you decide to partition your sequence data according to a codon-position partitioning scheme, the following output will be generated for each gene alignment:
  * Inside each directory `00_alignments_per_locus/[0-9]*`, you will have one sequence file for each possible partitioning scheme:
    * One sequence file with only first codon positions.
    * One sequence file with only second codon positions.
    * One sequence file with only third codon positions.
    * One sequence file with both first and second codon positions in one block.
    * One sequence file with two blocks: the first block with first and second codon positions and the second block with the third codon positions.
  * Inside directory `02_concatenated_alignments`, you will find four directories, one for each type of partitioning scheme:
    * `part1`: concatenated sequence file with only the first codon positions from each gene alignment.
    * `part2`: concatenated sequence file with only second codon positions from each gene alignment.
    * `part3`: concatenated sequence file with only third codon positions from each gene alignment.
    * `part12`: concatenated sequence file with both first and second codon positions from each gene alignment.

## How do you need to prepare your working directory?

Firstly, you will need to create your working directory (you can choose any name, perhaps something that is related to your research project!). Subsequently, you will need to save your _n_ gene alignments in FASTA format (as many FASTA files as gene alignments you have) inside your working directory, thus following the file structure shown in the example below:

```text
your_working_directory 
  |- file_1.fasta 
  |- file_2.fasta 
  |- .
  |- .
  |- .
  |- file_n.fasta
```

> [!IMPORTANT]
> Please note that `fasta-phylip-partitions` will be looking for files with extension `.fasta`, not `.fa`. Consequently, please modify your input files accordingly. For instance, you may use a `for` loop such as the one shown in the code snippet below:
>
> ```bash
> cd your_dir_with_.fa_files
> for file in *fa
> do
> name=$( echo $file | sed 's/\.fa/\.fasta/' )
> mv $file $name
> done
> ```

In addition, please note that you will need to create a text file called `species_names.txt` that includes the names of all the taxa present in your gene alignments (i.e., one taxon name per row, please use the same names you used to identify the sequences in your sequence files!). The content of this text file should follow the format shown in the example below:

```text
name_sp1
name_sp2
name_sp3
name_sp4
name_spn
```

Once you have your gene alignments and the `species_names.txt` ready, you should save then in your working directory. If you have followed all the steps described until now, your working directory should now have a file structure similar to the one shown in the example below:

```text
your_working_directory 
  |- file_1.fasta 
  |- file_2.fasta 
  |- .
  |- .
  |- .
  |- file_n.fasta
  |- species_names.txt
```

> [!IMPORTANT]
> Please do not modify the name given to the text file with species names, always use `species_names.txt`. Otherwise, `fasta-phylip-partitions` tool will not work!

## Exporting the path to `fasta-phylip-partitions` to your global path?

Firstly, you will need to clone this repository and export the path to the script `Run_tasks.sh` to your global path by updating your `~/.bashrc`, `~/.bash_profile`, `~/.profile`, `~/.zshrc`, or similar hidden file (i.e., the file name will depend on your OS). If you are not familiar with exporting paths, you may want to follow any of the many tutorials you will be able to find when searching the Internet or the suggestions given below -- I hope you find them useful!

### Why is it important to export the path to the programs you install to your global path?

Without exporting the path to programs you may have installed on your PC to your global path, you may experience various issues:

* If some programs depend on others being installed, they may not be found and you can encounter issues when trying to install or execute such programs.
* You will have to type the absolute path (i.e., the path from the root of your file structure to wherever you have saved the executable file/s that run/s your program of interest) or the relative path (i.e., the path from your current directory to wherever you have saved the executable file/s that run/s your program of interest), which is somewhat inefficient.

### Tips for exporting paths depending on OS

Below, you can find Some tips that you can follow to export paths depending on your OS:

* **WSL users**: your path will always start with `/mnt/c/` as the WSL is installed as a mountable disk. The easiest way to find the path to a program is by using a terminal to navigate to the directory where it was installed (i.e., use `cd`). Once you are there, type `pwd`. Then, you can use your favourite text editor (e.g., `vim`, `nano`, etc.) to modify the `~/.bashrc`, a hidden file that you can edit to export the programs to your global path. E.g.: if you are familiar with `vim`, `nano`, `gedit`, etc.; then you already know the how to proceed! If not, you may want to use a text editor such as `nano` by typing the following on the terminal: `nano ~/.bashrc`. Once you press enter, you will see that a file with lots of information is now open on the terminal screen. Please use the arrows of your keyboard to scroll down (your mouse or touchpad will not work!) until you get to the end of this file. Once you are there, please add a new blank line and, subsequently, include the following two lines:

  ```text
  # Export <name_program>
  export PATH=<path_you_got_when_typing_pwd>:$PATH
  ```

  Please replace `<name_program>` with the name of the program you are trying to export to your global path and `<path_you_got_when_typing_pwd` with the absolute path that you saw printed on your terminal when you typed `pwd` as aforementioned.

  In this case, you are trying to export the path to the `src` directory, where the `Run_tasks.sh` script can be found. The text below shows an example of what you could see if the path to this directory was `/mnt/c/Users/Phylo/fasta-phylip-partitions/src`, but please change accordingly:

    ```text
    # Export path to raxml-ng
    export PATH=/mnt/c/mnt/c/Users/Phylo/fasta-phylip-partitions/src:$PATH
    ```

    Once you have written these two lines in the `~/.bashrc`, please type the "Ctrl" key followed by the "O" key in your keyboard (i.e., "Ctrl+O") so that you "write out the changes". Then, to exit the text editor, please type the "Ctrl" key followed by the "X" key (i.e., "Ctrl+X") -- you can see these tips at the end of the text editor too!

    Lastly, you will need to let your system know that you have just added something new to the global path! **PLEASE READ THE TIPS BELOW BEFORE RUNNING THE NEXT COMMAND JUST IN CASE SOMETHING GOES WRONG!**. In order to do that, please type `source ~/.bashrc` on the terminal to save the changes. If you have correctly exported the path, then you shall be able to execute `fasta-phylip-partitions` by typing `Run_tasks.sh` followed by the relevant option!

    **[[ TIP 1 ]]**: if you are scared of making any mistakes when updating your `~/.bashrc` (e.g., typos, wrong path, etc.), you may want to open two tabs on the terminal ("tab 1" and "tab 2") or two terminals ("terminal 1" and "terminal "). **It is important you open them at the same time before you make any changes to the `~/.bashrc`**. In "tab 1" (or "terminal 1"), please include the changes to the `~/.bashrc` and source the changes by typing `source ~/.bashrc`. If you have made a mistake (e.g., typo in the path) and something has crashed (e.g., suddenly, commands such as `cd` or `ls` stop working), you can go to "tab 2" (or "terminal 2"), which you should have opened already before making any changes; then type `source ~/.bashrc`. If you open now a third tab or a third terminal ("tab 3" or "terminal 3") and type `cat ~/.bashrc`, you will see that the old file without your changes should be there and you can use again simple commands such as `cd` or `ls`. Just close "tab 1" (or "terminal 1"), then try again (e.g., make sure there are no typos in the path!).
    <br><br>
    **[[ TIP 2 ]]**: If it is too late for you because you did not have a second tab or terminal and you have issues with your `~/.bashrc`, please do the following:

    * If you have mistakenly typed a wrong path in your `~/.bashrc`, you will see that, suddenly, commands like `ls`, `cp`, `mv`, etc. stop working. In order for you to be able to use these commands again, you need to add `/bin/` before you type any command (if you use a different shell than `bash`, this command may change!). E.g., `/bin/ls`. What you can do now is calling the text editor `nano` using the following command:

        ```sh
        /bin/nano ~/.bashrc
        ```

      The command above will open the `~/.bashrc` file with the `nano` editor. You can go to the last place you edited and fix the affected path you tried to export (e.g., perhaps you added an additional space, you had a typo somewhere, etc.).

      Once you have fixed the wrong path, you can save the file -- type "ctrl+O" (key "ctrl", then key "O") to save the changes, press key "y" (i.e., says yes to changes), and then exit the text editor by typing "ctrl+X" (key "ctrl", then key "X").

      Finally, you will need to source the file to save the changes:

      ```sh
      . ~/.bashrc
      ```

      Now, you should open a new terminal, where basic commands such as `ls` or `mv` should be working again. In addition, if you have correctly fixed the path that you wanted to export, `fasta-phylip-partitions` should be running without having to type absolute/relative paths, only its `Run_tasks.sh` followed by relevant options! Also, you can close the old terminal too :smile:

* **Linux users**: same as WSL users but the path does not start with `/mnt/c`. You will have a different path according to your user name, directory name, etc. The same procedure described for WSL users regarding opening/editing/saving the `~/.bashrc` file holds :slight_smile:

* **Mac users**: some of you may have `~/.profile`, `~/.bash_profil`, or similar instead of `~/.bashrc`. In that case, follow the same instructions as above but please replace all `~/.bashrc` with the relevant name for this hidden file. **If you have the Z shell (and, perhaps, the `~/.zshrc` file), please follow the recommendations in the bullet point below**.

* **Mac users with the Z shell**: the following guidelines apply to people with a Z shell, which are based on troubleshooting other people's laptops that have experienced this issue. There may be other ways to do so, but the guidelines below have worked for other Mac users with a Z shell!

  * Open a terminal and open two tabs.
  * Type `ls -a ~` in "tab 1". If you do not see a file called `~/.profile` listed, then you will need to create it. You can then type `touch ~/.profile`. This will be the file that you will use to export the programs to the global path. E.g., you could open it with your preferred text editor and type something like what I mentioned above for WSL users:

    ```sh
    # Export <name_program>
    export PATH=<path_you_got_when_typing_pwd>:$PATH
    ```

  * In tab 1, now, check that you have a file called `~/.zshrc` (i.e., `ls -a ~`). If not, please create one (i.e., `touch ~/.zshrc`), open it with your preferred text editor, and add this line:

    ```sh
    [[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile'
    ```

    Now, save the file (e.g., see instructions above if using `nano`; if you are using `vim`, you already know the deal!), and source the changes (i.e., run first `source ~/.profile`, then `source ~/.zshrc`).

  * Open a new terminal and try to see if you can run the program which path you tried to export. If that works, that's fine! If you experienced any problems (e.g., commands such as `cd` or `ls` stopped working), then go back to terminal 1, "tab 2", and just recover the original files without changes (i.e., type `source ~/.profile` and `source ~/.zshrc`, which should not include the changes you made in "tab 1"). If you did not create them, just create empty ones (i.e., `touch ~/.profile` and `touch ~/.zshrc`) and source :slight_smile: If you open a third terminal or third tab, the problem should be now solved! Then, try again and make sure there are no typos in the path you type :slight_smile:

Once you have exported the path to the script `Run_tasks.sh` to your global path, you will be able to execute `fasta-phylip-partitions` by just typing the name of the aforementioned script and relevant options, without the need of using absolute/relative paths. In other words, no matter where you open a terminal or which directory you are currently in, you will be able to type `Run_tasks.sh` to run `fasta-phylip-partitions` :smile:

## How can you run `fasta-phylip-partitions`?

The script `Run_tasks.sh`, which executes `fasta-phylip-partitions`, takes three arguments:

* `<path_to_you_directory_with_fasta_alignments>`: this is the path to where all your input FASTA files can be found. If you are running the script `Run_tasks.sh` to launch `fasta-phylip-partitions` in the same directory where you have saved all your input FASTA files, then you should type `.`, which indicates "current working directory", as the first option.
* `<name_for_output_files>`: string (without quotation marks) that will be used to name the output files. E.g., "proj5910".
* `<partY|partN>`: if you want to partition your sequence data according to a codon-partitioning scheme, the third argument should be `partY`. Otherwise, you should type `partN`.  

Considering the three options required by script `Run_tasks.sh` to successfully run `fasta-phylip-partitions`, the general format for the command would be as follows:

```sh
Run_tasks.sh <path_to_you_directory_with_fasta_alignments> <name_for_output_files> <partY|partN>
```

> [!IMPORTANT]
> The in-house bash scripts used by `fasta-phylip-partitions` assume that your `bash` is in `/bin/bash`, hence the shebang is `#!/bin/bash`. If your `bash` is somewhere else, please change the line of the bash scripts accordingly.
> For instance, you could run the `for` loop detailed in the code snippet below:
>
> ```bash
> cd fasta-phylip-partitions/src
> sed -i 's/\#\!\/bin\/bash/\#\!<ADD_HERE_YOUR_PATH_TO_BASH>/' Run_tasks.sh 
> for i in Tools/*.sh 
> do
> sed -i 's/\#\!\/bin\/bash/\#\!<ADD_HERE_YOUR_PATH_TO_BASH>/' $i 
> done
> ```

## What will the output be?

### If you decide to generate partitioned alignments...

If you decide to run `fasta-phylip-partitions` so that partitioned alignments are also generated, the output files will be saved in different directories following the file structure below:

```text
phylip_format 
         |- 00_alignments_per_locus 
         |          |- 1  
         |          |  |- <file1_name>.phy
         |          |  |- <file1_name>.log.txt
         |          |  |- partitions12.3_<file1_name>.phy
         |          |  |- partitions12_<file1_name>.phy
         |          |  |- partitions1_<file1_name>.phy
         |          |  |- partitions2_<file1_name>.phy
         |          |  |- partitions3_<file1_name>.phy
         |          |
         |          |- . 
         |          |- . 
         |          |- . 
         |          |
         |          |- "$num_fasta" 
         |          |  |- <filen_name>.phy
         |          |  |- <filen_name>.log.txt
         |          |  |- partitions12.3_<filen_name>.phy
         |          |  |- partitions12_<filen_name>.phy
         |          |  |- partitions1_<filen_name>.phy
         |          |  |- partitions2_<filen_name>.phy
         |          |  |- partitions3_<filen_name>.phy
         |          |
         |          |- logs_missingdata 
         |          |   |- out_count_NA_<file1_name>
         |          |   |   |- <file1_name>_avgmissdata.txt
         |          |   |   |- <file1_name>_countNA.tsv
         |          |   |   |- <file1_name>_missdatapersp.txt
         |          |   |
         |          |   |- . 
         |          |   |- . 
         |          |   |- . 
         |          |   |
         |          |   |- out_count_NA_<filen_name>
         |          |   |   |- <filen_name>_avgmissdata.txt
         |          |   |   |- <filen_name>_countNA.tsv
         |          |   |   |- <filen_name>_missdatapersp.txt
         |          |   |
         |          |   |- log_count_missdat_<file1_name>.txt
         |          |   |
         |          |   |- . 
         |          |   |- . 
         |          |   |- . 
         |          |   |
         |          |   |- log_count_missdat_<filen_name>.txt
         |          |
         |          |- log01_phylip_format.txt 
         |          |- log02_generate_tmp_aln.txt
         |
         |- 01_alignment_all_loci 
         |          |- <name_for_output_files>_all_loci.phy  
         |
         |- 02_concatenated_alignments 
# 250511-SAC: update file structure to include those files related
# to sequence alignments with only 1st CPs or 2nd CPs (separately)
                    |- part1
                    |    |- part1_<name_for_output_files>_concat.phy  
                    |    |- part1_<name_for_output_files>_concat.fasta
                    |    |- part1_<name_for_output_files>_concat_log.txt
                    |    |- part1_<name_for_output_files>_concat_one_line.fasta
                    |    |- part1_<name_for_output_files>_concat_sumstats.tsv
                    |
                    |- part12
                    |    |- part12_<name_for_output_files>_concat.phy  
                    |    |- part12_<name_for_output_files>_concat.fasta
                    |    |- part12_<name_for_output_files>_concat_log.txt
                    |    |- part12_<name_for_output_files>_concat_one_line.fasta
                    |    |- part12_<name_for_output_files>_concat_sumstats.tsv
                    |
                    |- part2
                    |    |- part2_<name_for_output_files>_concat.phy  
                    |    |- part2_<name_for_output_files>_concat.fasta
                    |    |- part2_<name_for_output_files>_concat_log.txt
                    |    |- part2_<name_for_output_files>_concat_one_line.fasta
                    |    |- part2_<name_for_output_files>_concat_sumstats.tsv
                    |
                    |- part3
                    |    |- part3_<name_for_output_files>_concat.phy  
                    |    |- part3_<name_for_output_files>_concat.fasta
                    |    |- part3_<name_for_output_files>_concat_log.txt
                    |    |- part3_<name_for_output_files>_concat_one_line.fasta
                    |    |- part3_<name_for_output_files>_concat_sumstats.tsv
                    |
                    |- <name_for_output_files>_concat.phy  
                    |- <name_for_output_files>_concat.fasta
                    |- <name_for_output_files>_concat_log.txt
                    |- <name_for_output_files>_concat_one_line.fasta
                    |- <name_for_output_files>_concat_sumstats.tsv\n
```

A. Inside `00_alignments_per_locus` you will have:

* Subdirectories labelled from `1` to `n`, being `n` the amount of input sequence files in FASTA format located in the working directory. A PHYLIP-formatted sequence file will be output, alongside a log file, for each input FASTA-formatted file. For subdirectory `i`, you would expect the following files:
  * `<filei_name>_.phy`: sequence file for gene alignment `i` in PHYLIP format.
  * `partitions1_<filei_name>_.phy`: sequence file for gene alignment `i` in PHYLIP format, only 1st codon positions.
  * `partitions2_<filei_name>_.phy`: sequence file for gene alignment `i` in PHYLIP format, only 2nd codon positions.
  * `partitions3_<filei_name>_.phy`: sequence file for gene alignment `i` in PHYLIP format, only 3rd codon positions.
  * `partitions12_<filei_name>_.phy`: sequence file for gene alignment `i` in PHYLIP format, only 1st+2nd codon positions.
  * `partitions12.3<filei_name>_.log.txt`: sequence file for gene alignment `i` in PHYLIP format, one alignment block with 1st+2nd codon positions and a second alignment block with only 3rd codon positions.
  * A text file that keep track of the length of each sequence in gene alignment `i`.

> [!IMPORTANT]
> Inside directory `00_alignments_per_locus`, you will also find text files tracking the visited FASTA files and a directory called `logs_missingdata`, which will have one subdirectory for each alignment file. Inside the each subdirectory (`logs_missingdata/out_count_NA_<name_for_output_files>`), you shall find various text files with information about missing data and relevant stats. Log files summarising the content of all the text files in the aforementioned subdirectory are provided as text files inside `logs_missingdata` too.\s

B. Inside directory `01_alignment_all_loci`, you will have the `<name_for_output_files>_all_loci.phy` file, which contains one alignment block (in PHYLIP format) for each input gene alignment located in the working directory.

C. Inside directory `02_concatenated_alignments`, you will find the concatenated alignment alongside log and stats files and one subdirectory for each type of partitioning scheme (i.e., `part1`, `part2`, `part3`, `part12`; one directory for each type of partitioning scheme ([see the first section in this `README.md` file for more details about these directories](README.md#what-can-you-find-in-this-repository))). The files you shall find under each subdirectory are the following:

* `part*_<name_for_output_files>_concat.phy`: sequence file with the concatenated gene alignments but under the following partitioning schemes: 1st CPs, 2nd CPs, 3rd CPs, 1st+2nd CPs, 1st+2nd and 3rd CPs.
* `part*_<name_for_output_files>_concat.fasta`: same as above, but in FASTA format. alignment of all the 3rd CPs for all the loci in fasta format.
* `part*_<name_for_output_files>_concat_log.txt`: log file where you can track that the sequences in each alignment have the same length.
* `part*_<name_for_output_files>_concat_one_line.fasta`: same as the aforementioned FASTA file but with one row per sequence.
* `part*_<name_for_output_files>_concat_sumstats.tsv`: tab-separated log file with 5 columns:
  * Gene: Numeric, corresponding to the number of locus parsed.
  * Number of species: Numeric, number of species in the alignment of that specific locus.
  * Number of missing species: Numeric, number of missing species in this alignment.
  * Total genes: Total number of genes (should be always the same).
  * Name of missing species: Character, name of species missing in that locus alignment.

The same output files can be found when the gene alignments have been concatenated without any partitioning scheme.

### If you just want to obtain concatenated alignments... 

If you decide to run the `fasta-phylip-partitions` without generating partitioned alignments, you will have the same output files that have been described in the section above except for those corresponding to the partitioned alignments. The file structure will therefore look like the example shown below:

```text
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
         |          |- <name_for_output_files>_all_loci.aln  
         |
         |- 02_concatenated_alignments 
                    |- <name_for_output_files>_concat.aln  
                    |- <name_for_output_files>_concat.fasta
                    |- <name_for_output_files>_concat_log.txt
                    |- <name_for_output_files>_concat_one_line.fasta
                    |- <name_for_output_files>_concat_sumstats.tsv

```

## Are there any examples?

You can find two examples in the `examples` directory in which two different jobs have been carried out:

* **Generate only the concatenated alignment**: you can navigate to directory `examples/test_data_partitionNO` and check the output files generated within the `fasta_data/phylip_format` directory. If you want to re-run the analysis, you can delete the `phylip_format` directory within the `fasta_data` directory and run the following command:

  ```sh
  Run_tasks.sh . proj5190 partN
  ```

> [!NOTE]
> The output files will be renamed using tag `proj5190` in their names.

* **Generate both the concatenated alignment and the partitioned alignments**: you can navigate to `examples/test_data_partitionYES` and check the output files generated within the `fasta_data/phylip_format` directory. If you want to re-run the analysis, you can delete the `phylip_format` directory within the `fasta_data` directory and run the following command:

  ```sh
  Run_tasks.sh . proj5190 partY
  ```

> [!NOTE]
> The output files will be renamed using tag `proj5190` in their names.

## Contact

This repository and its content was created by **Dr Sandra Álvarez-Carretero** ([`@sabifo4`](https://github.com/sabifo4/)), who is also responsible for its maintenance.

If you have any queries with regards to `fasta-phylip-partitions` or any suggestions about how to improve this tool, please do not hesitate to <a href="mailto:sandra.ac93@gmail.com">reach me via email</a>!
