#!/usr/bin/perl
# Reads CSTS from STDIN, converts Chinese CoNLL tags to PDT, writes the result to STDOUT.
# (c) 2008 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use tagset::zh::conll;
use tagset::cs::pdt;
use tagset::common;
BEGIN
{
    tagset::common::get_permitted_values(tagset::cs::pdt::list(), \&tagset::cs::pdt::decode, \%permitvals, \%permitcombs);
#    tagset::common::print_permitted_values(\%permitvals);
#    tagset::common::print_permitted_combinations(\%permitcombs);
}

while(<>)
{
    # Erase original tag immediately. It is difficult to use in subsequent regular
    # expressions because it can contain vertical bars ("|") and other special characters.
    if(s/<t>([^<]+)/<_tag_to_change_>/)
    {
        my $tag0 = $1;
        my $features = tagset::zh::conll::decode($tag0);
        # Make sure the feature structure contains only permitted values.
        # (Note: This function does not care about value combinations.)
#        tagset::common::enforce_permitted_values($features, \%permitvals);
        tagset::common::enforce_permitted_combinations($features, \%permitcombs);
        my $tag1 = tagset::cs::pdt::encode($features);
        s/<_tag_to_change_>/<t>$tag1/;
    }
    print;
}
