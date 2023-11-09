#!/bin/bash

# runner for UMI dereplicator DEMO
# a.bossers@uu.nl // alex.bossers@wur.nl

#./fastq_derep_UMI.pl --input-fastq1 testR1_1M.fq.gz \
# 					--input-fastq2 testR2_1M.fq.gz \
# 					--input-fastq3 testR3_1M.fq.gz \
# 					--output-fastq1 derep_testR1_1M.2.fq.gzip \
# 					--output-fastq2 derep_testR2_1M.2.fq.gzip \
# 					--output-fastq3 derep_testR3_1M.2.fq.gzip \
# 					--suppressSeq 

./deduplicate_UMI.pl --input-fastq1 HFL2HDRX2_105134-001-083_CTAACTCG-TCGTAGTC_L002_R1.fastq.gz \
					--input-fastq2 HFL2HDRX2_105134-001-083_CTAACTCG-TCGTAGTC_L002_R2.fastq.gz \
					--input-fastq3 HFL2HDRX2_105134-001-083_CTAACTCG-TCGTAGTC_L002_R3.fastq.gz \
					--output-fastq1 derep_fullR1.fq.gzip \
					--output-fastq2 derep_fullR2.fq.gzip \
					--output-fastq3 derep_fullR3.fq.gzip \
					--suppressSeq 
