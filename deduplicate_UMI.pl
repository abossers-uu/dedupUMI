#!/usr/bin/perl -w

# Simple quick and dirty script that will deduplicate fastq sequences using UMI sequences
#
#  Latest version allows for input of just R1 and R2 where the UMI should be available in the fastq header (new format)
#  This is handled automatically such if only two Rx files are provided.
#
# Example fastq header plain vs UMI
#      Plain : @A01685:89:HLHWFDRX2:1:1101:4200:1094 1:N:0:TTACGGCT+AAGGACCA     
#              note: GAAAACTC+qual in R2 for R3-system
#      UMI+  : @A01685:89:HLHWFDRX2:1:1101:4200:1094:GAAAACTC 1:N:0:TTACGGCT+AAGGACCA
#
#
# In/Out:
#   Older system R1 R2 R3 UMI in R2:
#      Input: R1 R2 and R3 fastq readset. For the best total quality to work the UMI should be present in R2!
#      Output: R1 R2 R3 filtered for EXACT duplicates based on concatenated seq of R1 R2 R3 keeping highest TOTAL qual score.
#   NEW system R1 R2 UMI in header:
#      Input: R1 and R2 fastq readset. UMI shuld be present in the header of at least R1!
#      Output: R1 and R2 filtered for EXACT duplicates based on concatenated seq of R1 R2 keeping highest TOTAL qual score.
#
#
# Requires 
#   zcat available (on unix)) to allow reading/writing of gzipped files!
#
#
# Note! 
#   It writes out the last sequences found of a duplicate set having the highest TOTAL qualityscore.
#   Input should be 4 lines convention starting at the FIRST line! 
#   Sequences in R1 R2 (and R3) should be in same order!
# 
#
# How it works: 
#   It reads simulatenous R1 R2 (R3) per 4 line set (1 seq) and concatenates seq1 seq2 seq3 as 
#   the hash key and stores qual values in the hash. Duplicates will overwrite each time the hash if total qualityscore is higher.
#   This leaves a hash of unique sequences which is written out again into R1 R2 (R3).
#
#
# @author: a.bossers@uu.nl // alex.bossers@wur.nl
#
#
# Disclaimer:  Script is povided AS IS under G-GPL3. We did our best to verify that the results are legitimate.
#              However, the output could be erroneous so you should check your results. The authors nor their institutions/employers 
#              are in any way direct or indeirctly responsible for the direct or indirect damages caused by using this script. Use at own responsibility.
#

my $version     = "1.1";
my $versiondate = "2023-08-29";

# Version history
#       1.1      29-08-2023  Add option to use UMI in fastq headers instead of R3-system.
#       0.9=1.0  12-10-2022  Added quality check (Wouter + streamline Alexc)
#       0.8      15-09-2022  first working concept 
#       0.1      xx-xx-2010  template

use strict;
use warnings;
use diagnostics;
use Getopt::Long;
#use IO::Compress::Gzip qw(gzip $GzipError) ;
#use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;
use POSIX qw/strftime/;
use Data::Dumper;

print "Version $version date $versiondate by alex.bossers\@wur.nl / a.bossers\@uu.nl\n";
print "Started ".(strftime "%m/%d/%Y %H:%M:%S", localtime)."\n";


#handle cmd line options
my ( $input_fastq1, $input_fastq2, $input_fastq3, $output_fastq1, $output_fastq2, $output_fastq3, $suppressSeq, $help );

GetOptions ('input-fastq1=s'   => \$input_fastq1,
            'input-fastq2=s'   => \$input_fastq2,
            'input-fastq3=s'   => \$input_fastq3,
            'output-fastq1=s'  => \$output_fastq1,
            'output-fastq2=s'  => \$output_fastq2,
            'output-fastq3=s'  => \$output_fastq3,
            'suppressSeq'      => \$suppressSeq,
            'help'             => \$help);

if ( defined($help) || ! defined($input_fastq1) || ! defined($input_fastq2) || ! defined($output_fastq1 )|| ! defined($output_fastq2) )
   {
       print "Usage: fasta_selector.pl\n";
       print "   --input-fastq1     <input fastq R1 file (plain or gz)>\n";
       print "   --input-fastq2     <input fastq R2 file (plain or gz)>. In R3-system this is the UMI file.\n";
       print "   --input-fastq3     optional if UMI is NOT in fastq header <input fastq R3 file (plain or gz)>\n";
       print "   --output-fastq1    <output fastq R1 file (plain or gz)>\n";
       print "   --output-fastq2    <output fastq R2 file (plain or gz)>\n";
       print "   --output-fastq3    optional if UMI is NOT in fastq header <output fastq R3 file (plain or gz)>\n";
       print "   --suppressSeq      Do not print sequence at output to console\n";
       print "   --help             Welll... eeeuuuhhh this help text\n";
       print "\nIf you have problems reading/writing gzipped files, check if unix can use zcat command!\n\n";
	   
       if( ! defined($help) ) {
		   print STDERR "One of the required arguments --input-fastq1, --input-fastq2, --input-fastq3 or --output-fastq1, --output-fastq2, --output-fastq3 is missing!\n" if !defined($help);
           exit 1;
	   }
       exit;
   }


# Check if we have UNI in the headers (new) or in a separate file (R3-system)
my $umiheader;
if( defined($input_fastq3) ) {
    # R3-system processing (R1 R2 R3) where UMI is in R2
    if( ! defined($output_fastq3) ) {
        #output for R3 system is missing
        print STDERR "  R3-system (R1 R2 R3) detected, but output file R3 is not defined! Define by using --output-fastq3\n" if !defined($help);
        exit 1;
    }
    print "  R3-system (R1 R2 R3) UMI in-FILE processing detected!\n";
    $umiheader = 0;
} else {
    # UMI in header
    # simple check if indeed UMI is present in the header


    print "  R3 file not detected => assuming UMI present in R1 header!\n";
    $umiheader = 1;
}




#FixMe: deduplicate code or integrate. For simplicity/urgence the quick fix is duplicated code having changed UMI header stuff


if( ! $umiheader ) 
{
    # R3-system processing
    # The original / initial version (can be deprecated if these files cease to exist)
    my ($INFQ1,$INFQ2,$INFQ3, $OUT1,$OUT2,$OUT3);

    #open the INPUT files
    if( substr($input_fastq1,-3) eq ".gz" || substr($input_fastq1,-5) eq ".gzip" ) {
        #input gzipped
        open( $INFQ1 , "zcat $input_fastq1 |") || die "Input file error: $input_fastq1\n$!\n" ;
    } else {
        #regular non-gzipped input
        open ( $INFQ1, $input_fastq1 ) || die "Input file error: $input_fastq1\n$!\n" ;
    }

    if( substr($input_fastq2,-3) eq ".gz" || substr($input_fastq2,-5) eq ".gzip" ) {
        #input gzipped
        open( $INFQ2 , "zcat $input_fastq2 |") || die "Input file error: $input_fastq2\n$!\n" ;
    } else {
        #regular non-gzipped input
        open ( $INFQ2, $input_fastq2 ) || die "Input file error: $input_fastq2\n$!\n" ;
    }

    if( substr($input_fastq3,-3) eq ".gz" || substr($input_fastq3,-5) eq ".gzip" ) {
        #input gzipped
        open( $INFQ3 , "zcat $input_fastq3 |") || die "Input file error: $input_fastq3\n$!\n" ;
    } else {
        #regular non-gzipped input
        open ( $INFQ3, $input_fastq3 ) || die "Input file error: $input_fastq3\n$!\n" ;
    }

    #open output handles
    if( substr($output_fastq1,-3) eq ".gz" || substr($output_fastq1,-5) eq ".gzip" ) {
        #input gzipped
        #$OUT1 = new IO::Compress::Gzip("$output_fastq1") || die "Output file error: $output_fastq1\n$!\n";
        open ( $OUT1, "|-", "gzip >$output_fastq1" ) || die "Output file error: $output_fastq1\n$!\n" ;
    } else {
        #regular non-gzipped input
        open ( $OUT1, ">$output_fastq1" ) || die "Output file error: $output_fastq1\n$!\n" ;
    }

    if( substr($output_fastq2,-3) eq ".gz" || substr($output_fastq2,-5) eq ".gzip" ) {
        #input gzipped
        #$OUT2 = new IO::Compress::Gzip("$output_fastq2") || die "Output file error: $output_fastq2\n$!\n";
        open ( $OUT2, "|-", "gzip >$output_fastq2" ) || die "Output file error: $output_fastq2\n$!\n" ;
    } else {
        #regular non-gzipped input
        open ( $OUT2, ">$output_fastq2" ) || die "Output file error: $output_fastq2\n$!\n" ;
    }

    if( substr($output_fastq3,-3) eq ".gz" || substr($output_fastq3,-5) eq ".gzip" ) {
        #input gzipped
        #$OUT3 = new IO::Compress::Gzip("$output_fastq3") || die "Output file error: $output_fastq3\n$!\n";
        open ( $OUT3, "|-", "gzip >$output_fastq3" ) || die "Output file error: $output_fastq3\n$!\n" ;
    } else {
        #regular non-gzipped input
        open ( $OUT3, ">$output_fastq3" ) || die "Output file error: $output_fastq3\n$!\n" ;
    }

    #read lines and write lines based on tested headers
    my $seqcount = 1;   # needed to treat seqs in blocks of 4 lines (circumvent start @ in qualscore)
    my $header;         # a clean header to start
    my $fq1line1;
    my %uniqseq = ();

    while ( <$INFQ1> ) {
        #read R1, R2 and R3 line1
        my $fq1line1 = $_;                  # linealready read
        my $fq2line1 = <$INFQ2>;
        my $fq3line1 = <$INFQ3>;
        # Catch if line empty (format wrong or extra empty line ant the end) => exit
        if ( $fq1line1 lt "0") { 
            print STDERR "  WARNING from R1 read loop: Empty line detected in R1 file (extra line at the end?). Check the output.)\n";
            last;
        }

        chomp ($fq1line1);
        chomp ($fq2line1);
        chomp ($fq3line1);
        
        #read sequence line2
        my $fq1line2 = <$INFQ1>;
        my $fq2line2 = <$INFQ2>;
        my $fq3line2 = <$INFQ3>;
        chomp ($fq1line2);
        chomp ($fq2line2);
        chomp ($fq3line2);

        #skip line 3 (+)
        my $blackhole = <$INFQ1>;
        $blackhole = <$INFQ2>;
        $blackhole = <$INFQ3>;

        #read line 4 quality
        my $fq1line4 = <$INFQ1>;
        my $fq2line4 = <$INFQ2>;
        my $fq3line4 = <$INFQ3>;
        chomp ($fq1line4);
        chomp ($fq2line4);
        chomp ($fq3line4);

        #store seq header and quality
        my %contents = ();
        $contents{"head"} = $fq1line1 . "#alx#" . $fq2line1 . "#alx#" . $fq3line1;
        $contents{"qual"} = $fq1line4 . " " . $fq2line4 . " " . $fq3line4;
        #$contents{"totalqual"} =    ## not sure if this is more efficient then recalc only duplicates original.
        #                            ## leave as is for the moment. ToDo: Benchmark

        #Check if the current sequence is already stored and if its quality is better replace existing.
        if( exists( $uniqseq{ "$fq1line2 $fq2line2 $fq3line2" } ) ) {
            #Transform the quality sequence strings into numbers.
            my @fq1line4num = unpack("C*", $fq1line4);
            my @fq3line4num = unpack("C*", $fq3line4);
            #Sum the numbers.
            my $total = 0;
            $total += $_ for(@fq1line4num);
            $total += $_ for(@fq3line4num);

            #Same for the current best sequence.
            my @orgquality = split( " ", $uniqseq{ "$fq1line2 $fq2line2 $fq3line2" }{ "qual" } );
            my @orgfq1line4num = unpack("C*", $orgquality[0]);
            my @orgfq3line4num = unpack("C*", $orgquality[2]);
            my $orgtotal = 0;
            $orgtotal += $_ for(@orgfq1line4num);
            $orgtotal += $_ for(@orgfq3line4num);

            #Compare the totals. If the old total is higher, do not store the new one and skip to the next.
            if ($total <= $orgtotal) {
                next;
            }
        }
        #Store the new sequence in the hash.
        $uniqseq{ "$fq1line2 $fq2line2 $fq3line2" } = \%contents;
        #Increment the sequence we are looking at.
        $seqcount++;
    }

    print "  Read    : $seqcount sequences\n";
    print "  Unique  : ". (keys %uniqseq) . " sequences\n";
    print "Writing ".(strftime "%m/%d/%Y %H:%M:%S", localtime)."\n";

    ##################################################
    # write all unique sequences out to R1 R2 and R3 #
    ##################################################

    $seqcount = 0;
    foreach my $seqR123 (keys %uniqseq) {

        #time this if this takes too long => remove
        #using 1M sequences it saves less then 1 sec if I commnet this out => leave it in
        print "  $seqR123\n" if !$suppressSeq;

        #split lines into R1 R2 and R3 again
        my @seq = split( " ", $seqR123 );
        my @headers = split( "#alx#", $uniqseq{ $seqR123 }{ "head" } );
        my @quality = split( " ", $uniqseq{ $seqR123 }{ "qual" } );
        #print Dumper \@seq;
        
        #write lines to files
        print $OUT1 $headers[0]."\n";
        print $OUT1 $seq[0]."\n";
        print $OUT1 "+\n";
        print $OUT1 $quality[0]."\n";

        print $OUT2 $headers[1]."\n";
        print $OUT2 $seq[1]."\n";
        print $OUT2 "+\n";
        print $OUT2 $quality[1]."\n";

        print $OUT3 $headers[2]."\n";
        print $OUT3 $seq[2]."\n";
        print $OUT3 "+\n";
        print $OUT3 $quality[2]."\n";

        $seqcount++;
    }

    print "  Written : $seqcount sequences\n";
    print "Finished ".(strftime "%m/%d/%Y %H:%M:%S", localtime)."\n";

    #end and close
    close ($INFQ1);
    close ($INFQ2);
    close ($INFQ3);
    close ($OUT1);
    close ($OUT2);
    close ($OUT3);



} else {



    # UMI in headers processing

    my ($INFQ1,$INFQ2, $OUT1,$OUT2);

    #open the INPUT files
    if( substr($input_fastq1,-3) eq ".gz" || substr($input_fastq1,-5) eq ".gzip" ) {
        #input gzipped
        open( $INFQ1 , "zcat $input_fastq1 |") || die "Input file error: $input_fastq1\n$!\n" ;
    } else {
        #regular non-gzipped input
        open ( $INFQ1, $input_fastq1 ) || die "Input file error: $input_fastq1\n$!\n" ;
    }

    if( substr($input_fastq2,-3) eq ".gz" || substr($input_fastq2,-5) eq ".gzip" ) {
        #input gzipped
        open( $INFQ2 , "zcat $input_fastq2 |") || die "Input file error: $input_fastq2\n$!\n" ;
    } else {
        #regular non-gzipped input
        open ( $INFQ2, $input_fastq2 ) || die "Input file error: $input_fastq2\n$!\n" ;
    }

    #open output handles
    if( substr($output_fastq1,-3) eq ".gz" || substr($output_fastq1,-5) eq ".gzip" ) {
        #input gzipped
        #$OUT1 = new IO::Compress::Gzip("$output_fastq1") || die "Output file error: $output_fastq1\n$!\n";
        open ( $OUT1, "|-", "gzip >$output_fastq1" ) || die "Output file error: $output_fastq1\n$!\n" ;
    } else {
        #regular non-gzipped input
        open ( $OUT1, ">$output_fastq1" ) || die "Output file error: $output_fastq1\n$!\n" ;
    }

    if( substr($output_fastq2,-3) eq ".gz" || substr($output_fastq2,-5) eq ".gzip" ) {
        #input gzipped
        #$OUT2 = new IO::Compress::Gzip("$output_fastq2") || die "Output file error: $output_fastq2\n$!\n";
        open ( $OUT2, "|-", "gzip >$output_fastq2" ) || die "Output file error: $output_fastq2\n$!\n" ;
    } else {
        #regular non-gzipped input
        open ( $OUT2, ">$output_fastq2" ) || die "Output file error: $output_fastq2\n$!\n" ;
    }

    #read lines and write lines based on tested headers
    my $seqcount = 1;   # needed to treat seqs in blocks of 4 lines (circumvent start @ in qualscore)
    my $header;         # a clean header to start
    my %uniqseq = ();

    while ( <$INFQ1> ) {
        # read R1 and R2 line1
        my $fq1line1 = $_;                # line already read above
        my $fq2line1 = <$INFQ2>;
        # Catch if line empty (format wrong or extra empty line ant the end) => exit
        if ( $fq1line1 lt "0") { 
            print STDERR "  WARNING from R1 read loop: Empty line detected in R1 file (extra line at the end?). Check the output.)\n";
            last;
        }
        chomp ($fq1line1);
        chomp ($fq2line1);
       
        #read sequence line2
        my $fq1line2 = <$INFQ1>;
        my $fq2line2 = <$INFQ2>;
        chomp ($fq1line2);
        chomp ($fq2line2);

        # get umi from header instead of file
        # apparently the UMI can contain N :-)
        my $umi;
        if( $fq1line1 =~ /^@.+:[0-9]+:[0-9]+:([ATGCNatgcn]+) [0-9]+:.+/ ) {
            $umi = $1;
        } else { 
            print STDERR "  ERROR: UMI not found in fastq header or fastq header format has changed!?\n    Header: '$fq1line1'\n"; 
            exit 1;
        }
 
        #skip line 3 (+)
        my $blackhole = <$INFQ1>;
        $blackhole = <$INFQ2>;

        #read line 4 quality
        my $fq1line4 = <$INFQ1>;
        my $fq2line4 = <$INFQ2>;
        chomp ($fq1line4);
        chomp ($fq2line4);

        #store seq header and quality
        my %contents = ();
        $contents{"head"} = $fq1line1 . "#alx#" . $fq2line1;
        $contents{"qual"} = $fq1line4 . " " . $fq2line4;
        #$contents{"totalqual"} =    ## not sure if this is more efficient then recalc only duplicates original.
        #                            ## leave as is for the moment. ToDo: Benchmark

        #Check if the current sequence is already stored and if its quality is better replace existing.
        if( exists( $uniqseq{ "$fq1line2 $fq2line2 $umi" } ) ) {
            #Transform the quality sequence strings into numbers.
            my @fq1line4num = unpack("C*", $fq1line4);
            my @fq2line4num = unpack("C*", $fq2line4);
            #Sum the numbers.
            my $total = 0;
            $total += $_ for(@fq1line4num);
            $total += $_ for(@fq2line4num);

            #Same for the current best sequence.
            my @orgquality = split( " ", $uniqseq{ "$fq1line2 $fq2line2 $umi" }{ "qual" } );
            my @orgfq1line4num = unpack("C*", $orgquality[0]);
            my @orgfq2line4num = unpack("C*", $orgquality[1]);
            my $orgtotal = 0;
            $orgtotal += $_ for(@orgfq1line4num);
            $orgtotal += $_ for(@orgfq2line4num);

            #Compare the totals. If the old total is higher, do not store the new one and skip to the next.
            if ($total <= $orgtotal) {
                next;
            }
        }
        #Store the new sequence in the hash.
        $uniqseq{ "$fq1line2 $fq2line2 $umi" } = \%contents;
        #Increment the sequence we are looking at.
        $seqcount++;
    }

    print "  Read    : $seqcount sequences\n";
    print "  Unique  : ". (keys %uniqseq) . " sequences\n";
    print "Writing ".(strftime "%m/%d/%Y %H:%M:%S", localtime)."\n";

    ##################################################
    # write all unique sequences out to R1 R2 and R3 #
    ##################################################
    $seqcount = 0;
    foreach my $seqR12 (keys %uniqseq) {

        #time this if this takes too long => remove
        #using 1M sequences it saves less then 1 sec if I commnet this out => leave it in
        print "  $seqR12\n" if !$suppressSeq;

        #split lines into R1 R2 and R3 again
        my @seq = split( " ", $seqR12 );
        my @headers = split( "#alx#", $uniqseq{ $seqR12 }{ "head" } );
        my @quality = split( " ", $uniqseq{ $seqR12 }{ "qual" } );
        #print Dumper \@seq;
        
        #write lines to files
        print $OUT1 $headers[0]."\n";
        print $OUT1 $seq[0]."\n";
        print $OUT1 "+\n";
        print $OUT1 $quality[0]."\n";

        print $OUT2 $headers[1]."\n";
        print $OUT2 $seq[1]."\n";
        print $OUT2 "+\n";
        print $OUT2 $quality[1]."\n";

        $seqcount++;
    }

    print "  Written : $seqcount sequences\n";
    print "Finished ".(strftime "%m/%d/%Y %H:%M:%S", localtime)."\n";

    #end and close
    close ($INFQ1);
    close ($INFQ2);
    close ($OUT1);
    close ($OUT2);
}

#end script
