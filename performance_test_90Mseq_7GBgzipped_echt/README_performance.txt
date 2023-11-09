
Seems like the perl script is almst as fast as the IO of reading, decompressing and compressing+writing.

In on a large file containing 96M PE seq (R1 of roughly 7.2GB) took 9 minutes to read and dereplicate, and took 14 minutes in addition to gzip and write.

Total processing time roughly 23 minutes for a sample of 96M reads.
See performace folder.

A small DEMO as runner is also attached demoing gzip in and allow to manually see that one seq got dereplicated.

Alex 20220915




# Simpel quick and dirty script that will deduplicate fastq sequences using UMI sequences
#
#  Input: R1 R2 and R3 fastq readset. It doesn't matter which R is the UMI. It should just work.
#  Output: R1 R2 R3 filtered for EXACT duplicates based on concatenated seq of R1 R2 R3,
#
#  Requires zcat available (on unix)) to allow reading/writing of gzipped files
#
#  Note! It writes out the last sequences found of a duplicate set.
#        Input should be 4 lines convention starting at the FIRST line! Sequences in R1 R2 and R3 should be in same order!
# 
#  How it works: It reads simulatenous R1 R2 R3 per 4 line set (1 seq) and concatenates seq1 seq2 seq3 as 
#                the hash key and stores qual+header values in the hash. Duplicates will overwrite each time the hash.
#                This leaves a hash of unique sequences which is written out again into R1 R2 R3.
#      
#  @author: a.bossers@uu.nl // alex.bossers@wur.nl

