#!/usr/bin/perl
# Reads CSTS data from STDIN, collects all tags and prints them sorted to STDOUT.
# Copyright © 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

while(<>)
{
    # The CSTS format can contain tags from various sources:
    # <t> ... manual annotation
    # <MMt src="ma1"> ... one of possibly ambiguous tags from morphological analysis (optional src attribute)
    # <MDt src="tag1"> ... tag automatically disambiguated by a tagger (optional src attribute)
    # We collect only manual tags at the moment.
    if(m/<t>([^<]+)/)
    {
        my $tag = $1;
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
