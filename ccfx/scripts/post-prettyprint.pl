#!/bin/perl
# Peter Senna Tschudin - peter.senna@gmail.com
# Convert ccfinderx pretty print format to match source code line numbers
# instead of token file line numbers.
# file,start line,endline,file,start line, end line

use DBI;
use strict;

my $DB_FILE= ":memory:";

#SQLite connect
my $dbh = DBI->connect(          
    "dbi:SQLite:dbname=$DB_FILE", 
    "",                          
    "",                          
    { RaiseError => 1 },         
) or die $DBI::errstr;

#Create table and indexes
$dbh->do("DROP TABLE IF EXISTS filerefs");
$dbh->do("CREATE TABLE filerefs(id integer primary key autoincrement, cloneid
	integer not null, file text not null, tkn_startln integer not null,
	tkn_endln integer not null, src_startln integer not null, src_endln
	integer not null)");


#Put the input file in a string
open my $input_file, $ARGV[0] or die "Unable to open file: $ARGV[0]";
my $file_string = join '', <$input_file>;
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

	$source_files_index[$fileid] = $file;

#	print $fileid . "\t" .$source_files_index[$fileid] . "\n";
}

foreach (@clone_pairs){

	my $string = $_;

	#Ignore lines containing { and }
	if ($string =~ /\{|\}/){
		next;
	}

        # 40      77.66-145       66.62-141
	# /(\d+)\t(\d+)\.(\d+)\-(\d+)\t(\d+)\.(\d+)\-(\d+)/
	(my $cloneid, my $fileref1, my $tkn_startln1, my $tkn_endln1, my $fileref2,
	my $tkn_startln2, my $tkn_endln2) = $string =~ /(\d+)\t(\d+)\.(\d+)\-(\d+)\t(\d+)\.(\d+)\-(\d+)/;

	# Get src_file numbers instead from tkn_file_numbers. The tln filename
	# ends with the content of $file_postfix
	my $src_startln1 = get_src_ln($source_files_index[$fileref1] .
		$file_postfix, $tkn_startln1);
	my $src_endln1 = get_src_ln($source_files_index[$fileref1] .
		$file_postfix, $tkn_endln1);
	my $src_startln2 = get_src_ln($source_files_index[$fileref2] .
		$file_postfix, $tkn_startln2);;
	my $src_endln2 = get_src_ln($source_files_index[$fileref2] .
		$file_postfix, $tkn_endln2);

	# id, cloneid, file, tkn_startln, tkn_endln, src_startln, src_endln
	$dbh->do("INSERT INTO filerefs VALUES(NULL, '$cloneid',
	'$source_files_index[$fileref1]', '$tkn_startln1', '$tkn_endln1', '$src_startln1', '$src_endln1')");

	$dbh->do("INSERT INTO filerefs VALUES(NULL, '$cloneid',
	'$source_files_index[$fileref2]', '$tkn_startln2', '$tkn_endln2', '$src_startln2', '$src_endln2')");
}



# Dump all SQLite.
my $sth = $dbh->prepare( "SELECT * FROM filerefs" );
$sth->execute();
while ( my @row = $sth->fetchrow_array ) {
	print join ("--", @row) . "\n";
}

# get_src_ln ($file,$ln_number)
# Open $file and read line $ln_number. Get the hex number between ^ and .,
# convert the number to decimal and return.
#
sub get_src_ln
{
	my $the_line;

	(my $file, my $ln_number) = @_;

	open my $input_file, $file or die "Unable to open file: $file";

	while (<$input_file>) {
		if ($. == $ln_number) {
			$the_line = $_;
			last;
		}
	}

	close $input_file;

	#Get the first hex number found between ^ and .
	($the_line) = $the_line =~ /^([0-9a-f]+)\./i;

	# Convert to decimal and return
	return hex($the_line);
}
