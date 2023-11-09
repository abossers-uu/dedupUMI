
Seems like the perl script is almost as fast as the IO of reading, decompressing and compressing+writing.

In on a large sample (files R1 R2 R3) containing 96M PE seq (R1.gz of roughly 7.2GB) took 9 minutes to read and dereplicate, and took 14 minutes in addition to gzip and write.

Total processing time roughly 23 minutes for a sample of 96M PE reads.
See performance folder.

A small DEMO as runner is also attached demoing gzip in and allow to manually see that one seq got dereplicated.

Alex 20220915

Update October 2022: Instead of siple overwrite, now the best (highest SUM qualityscore) is kept of the duplicated sequence set and written to disk.
Update August 2023: Script is now compatible with the NEW format of having UMI in the header (R1 and R2 files) instead of older R1 R2 and R3 files.

PERFORMANCE was tested on the initial september version!
