#!/bin/perl
# Peter Senna Tschudin - peter.senna@gmail.com
# Convert ccfinderx pretty print format to match source code line numbers
# instead of token file line numbers.
# file,start line,endline,file,start line, end line

use strict;

#Put all input file in a string
open my $input_file, $ARGV[0] or die "Unable to open file: $ARGV[0]";
local $/;
my $file_string = <$input_file>;
close $input_file;

# save contents of source_files { }. The entire block is saved at @source_files[0]
my @source_files = $file_string =~ /source_files\s*( \{ (?: [^{}]* | (?0) )* \} )/xg;
@source_files = split /\n/, $source_files[0]; # Now one line / @array element

# save contents of clone_pairs { }. The entire block is saved at @clone_pairs[0]
my @clone_pairs = $file_string =~ /clone_pairs\s*( \{ (?: [^{}]* | (?0) )* \} )/xg;
@clone_pairs = split /\n/, $clone_pairs[0]; # Now one line / @array element

# save file_postfix
my $file_postfix = join("", $file_string =~ /option:\s-preprocessed_file_postfix\s\S*/xg);
$file_postfix = (split(/ /, $file_postfix))[2];

my @source_files_index;
foreach (@source_files){

	my $string = $_;

	#Ignore lines containing { and }
	if ($string =~ /\{|\}/){
		next;
	}

	# 123	/path/to/file	456
	# /(\d+)\t(\S+)\t\d+/ # We want only first two fields
	(my $fileid, my $file) = $string =~ /(\d+)\t(\S+)\t\d+/;
	print $fileid . $file . "\n";
}

foreach (@clone_pairs){

	my $string = $_;

	#Ignore lines containing { and }
	if ($string =~ /\{|\}/){
		next;
	}

        # 40      77.66-145       66.62-141
	# /(\d+)\t(\d+)\.(\d+)\-(\d+)\t(\d+)\.(\d+)\-(\d+)/
	(my $cloneid, my $fileref1, my $startln1, my $endln1, my $fileref2,
	my $startln2, my $endln2) = $string =~ /(\d+)\t(\d+)\.(\d+)\-(\d+)\t(\d+)\.(\d+)\-(\d+)/;

	print $cloneid . "\t" . $fileref1 . "." . $startln1 . "-" .
	$endln1 . "\t" . $fileref2 . "." . $startln2 . "-" . $endln2 . "\n";
}

