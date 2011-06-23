#!/usr/bin/perl
# Reads CoNLL 2006/2007 data from STDIN, collects all combinations of CPOS + POS + FEAT and prints them sorted to STDOUT.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

while(<>)
{
    unless(m/^\s*$/)
    {
        # Get rid of the line break.
        s/\r?\n$//;
        # Split line into columns.
        my @columns = split(/\s+/, $_);
        # Join coarse-grained pos, fine-grained pos, and features into one tag.
        my $tag = "$columns[3]\t$columns[4]\t$columns[5]";
        $tagset{$tag}++;
    }
}
# Sort the tagset alphabetically and print it to the STDOUT.
@tagset = sort(keys(%tagset));
foreach my $tag (@tagset)
{
    print("$tag\n");
}
print("Total ", scalar(@tagset), " tags.\n");
