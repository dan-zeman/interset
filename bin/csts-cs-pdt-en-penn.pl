#!/usr/bin/perl
# Reads CSTS from STDIN, converts PDT tags to Penn, writes the result to STDOUT.
# (c) 2006 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
#binmode(STDOUT, ":utf8");
binmode(STDOUT, ":encoding(cp852)");
binmode(STDERR, ":utf8");
use tagset::pdt;
use tagset::penn;

while(<>)
{
    if(m/<t>([^<]+)/)
    {
        my $tag0 = $1;
        my $features = tagset::pdt::decode($tag0);
        my $tag1 = tagset::penn::encode($features);
        s/<t>$tag0.*/<t>$tag1/;
    }
    print;
}
