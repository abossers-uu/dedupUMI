# Deduplicate fastq sequences using UMI's
Simple **quick and dirty** script that will deduplicate fastq sequences using UMI sequences without having to align the reads to a reference first. Exact 
duplicates (incl UMI) are typically the result of over-amplification / too many amplification cycles in sequence library prepping.  

Handling time is roughly I/O time. It writes out the best total-quality read-pair from de exact-duplicated set.

Latest version allows for input of just R1 and R2 where the UMI should be available in the fastq header (new format). R3 system is still supported as Wel.  
This R2 or R3 system is handled automatically if two or three Rx files are provided respectively.  

# Example
Example fastq header plain vs UMI

Old:
- Plain : `@A01685:89:HLHWFDRX2:1:1101:4200:1094 1:N:0:TTACGGCT+AAGGACCA`     
- Note: Even though R1 R2 R3 doesn't matter which is the UMI, usually it is in R2 when using an R1 R2 R3 system
  
New:
- UMI+  : `@A01685:89:HLHWFDRX2:1:1101:4200:1094:GAAAACTC 1:N:0:TTACGGCT+AAGGACCA`

# Input / Output:

Older system R1 R2 R3 UMI in R2:
- Input: R1 R2 and R3 fastq readset. For the best total quality to work the UMI should be present in R2!
- Output: R1 R2 R3 filtered for EXACT duplicates based on concatenated seq of R1 R2 R3 keeping highest TOTAL qual score.

NEW system R1 R2 UMI in header:
- Input: R1 and R2 fastq readset. UMI shuld be present in the header of at least R1!
- Output: R1 and R2 filtered for EXACT duplicates based on concatenated seq of R1 R2 keeping highest TOTAL qual score.

# Requires 
zcat available (on unix)) to allow reading/writing of gzipped files!

# Note! 
It writes out the last sequences found of a duplicate set having the highest TOTAL qualityscore.  
Input should be 4 lines convention starting at the FIRST line!  
Sequences in R1 R2 (and R3) should be in same order and NOT INTERLEAVED!!  

# How it works: 
It reads simulatenous R1 R2 (R3) per 4 line set (1 seq) and concatenates seq1 seq2 seq3 as the hash key and stores qual values in the hash. Duplicates will overwrite each time the hash if total qualityscore is higher.    This leaves a hash of unique sequences which is written out again into R1 R2 (R3).

# Author

a.bossers@uu.nl // alex.bossers@wur.nl

# Disclaimer:  
**Script is povided AS IS** under G-GPL3.  
We did our best to verify that the results are legitimate. However, the output should be considered erroneous, so you should check your results.  
The authors nor their institutions/employers are in any way direct or indirect responsible for the direct or indirect damages caused by using this script.  
Use at your own responsibility.

