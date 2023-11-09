#!/bin/bash

# runner for UMI dereplicator DEMO
# a.bossers@uu.nl // alex.bossers@wur.nl
#
# for the demo I commented out the --suppressSeq argument to show output to console for debugging
# Default you probably should leave it in since it prevents flooding the console (which takes also significant time)



echo -e "\n>>> Run test for R3-system (R1 r2 R3 input/output files having UMI in R2) <<<\n"
./deduplicate_UMI.pl --input-fastq1 ./demo/aR1.fq.gz \
					 --input-fastq2 ./demo/aR2.fq \
					 --input-fastq3 ./demo/aR3.fq \
					 --output-fastq1 ./demo/outR1.fq.gz \
					 --output-fastq2 ./demo/outR2.fq \
					 --output-fastq3 ./demo/outR3.fq \
					 #--suppressSeq

echo -e "\n>>> Run test for UMI in headers (new format) <<<\n"
#Test using UMI in the HEADERS instead of in R1 R2 R3 system
./deduplicate_UMI.pl --input-fastq1 ./demo/bR1.fq \
					 --input-fastq2 ./demo/bR2.fq \
					 --output-fastq1 ./demo/out_headR1.fq \
					 --output-fastq2 ./demo/out_headR2.fq \
					 #--suppressSeq
