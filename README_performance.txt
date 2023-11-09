
Seems like the perl script is almost as fast as the IO of reading, decompressing and compressing+writing.

In on a large file containing 96M PE seq (R1 of roughly 7.2GB) took 9 minutes to read and dereplicate, and took 14 minutes in addition to gzip and write.

Total processing time roughly 23 minutes for a sample of 96M reads.
See performace folder.

A small DEMO as runner is also attached demoing gzip in and allow to manually see that one seq got dereplicated.

Alex 20220915

Update October 2022: Instead of siple overwrite the highest SUM qualscore is kept of the duplicate sequences
Update August 2023: script is now compatible with the NEW format of having UMI in the header (R1 and R2 files) instead of older R1 R2 and R3 files.

PERFORMANCE was tested on the initial september version!
