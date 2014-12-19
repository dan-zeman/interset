#!/usr/bin/perl
# Reads CoNLL data from STDIN, collects all features (FEAT column, delimited by vertical bars) and prints them sorted to STDOUT.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

# Argument "2009" toggles the CoNLL 2009 data format.
my $format = shift;
my $i_feat_column = $format eq '2009' ? 6 : 5;

while(<>)
{
    unless(m/^\s*$/)
    {
        # Get rid of the line break.
        s/\r?\n$//;
        # Split line into columns.
        my @columns = split(/\s+/, $_);
        my @features = split(/\|/, $columns[$i_feat_column]);
        my $form = $columns[1];
        foreach my $feature (@features)
        {
            $tagset{$feature}++;
            # We can also print example words that had the feature.
            $examples{$feature}{$form}++;
        }
    }
}
# Sort the tagset alphabetically and print it to the STDOUT.
@tagset = sort(keys(%tagset));
foreach my $tag (@tagset)
{
    my @examples = sort {$examples{$tag}{$b} <=> $examples{$tag}{$a}} (keys(%{$examples{$tag}}));
    splice(@examples, 10);
    print($tag, " (", join(', ', @examples), ")\n");
}
print("Total ", scalar(@tagset), " feature values.\n");
