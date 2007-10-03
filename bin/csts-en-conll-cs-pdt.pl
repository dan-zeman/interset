#!/usr/bin/perl
# Reads CSTS from STDIN, converts English CoNLL tags to PDT, writes the result to STDOUT.
# (c) 2007 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use tagset::en::conll;
use tagset::cs::pdt;

while(<>)
{
    # Erase original tag immediately. It is difficult to use in subsequent regular
    # expressions because it can contain vertical bars ("|") and other special characters.
    if(s/<t>([^<]+)/<_tag_to_change_>/)
    {
        my $tag0 = $1;
        my $features = tagset::en::conll::decode($tag0);
        my $tag1 = tagset::cs::pdt::encode($features);
        s/<_tag_to_change_>/<t>$tag1/;
    }
    print;
}
