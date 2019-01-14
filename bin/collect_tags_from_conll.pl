#!/usr/bin/perl
# Reads CoNLL 2006/2007/2009 data from STDIN, collects all combinations of CPOS + POS + FEAT and prints them sorted to STDOUT.
# For CoNLL-U prints only the treebank-specific POS column.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

# Argument "2009" toggles the CoNLL 2009 data format.
# Argument "U" toggles CoNLL-U.
my $format = shift;

while(<>)
{
    # Skip empty lines after sentences and comment lines in CoNLL-U.
    if(m/^\d/)
    {
        # Get rid of the line break.
        s/\r?\n$//;
        # Split line into columns.
        my @columns = split(/\s+/, $_);
        if($format =~ m/[uU]/)
        {
            # Use the treebank-specific tag stored in the POS column.
            $tagset{$columns[4]}++;
        }
        elsif($format != 2009)
        {
            # Join coarse-grained pos, fine-grained pos, and features into one tag.
            my $tag = "$columns[3]\t$columns[4]\t$columns[5]";
            $tagset{$tag}++;
        }
        else
        {
            # Join part of speech and features into one tag.
            my $tag = "$columns[4]\t$columns[6]";
            $tagset{$tag}++;
            # Do the same for the automatic annotation.
            $tag = "$columns[5]\t$columns[7]";
            $tagset{$tag}++;
        }
    }
}
# Sort the tagset alphabetically and print it to the STDOUT.
@tagset = sort(keys(%tagset));
foreach my $tag (@tagset)
{
    print("$tag\n");
}
print("Total ", scalar(@tagset), " tags.\n");
