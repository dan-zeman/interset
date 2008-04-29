#!/usr/bin/perl
# Reads CSTS from STDIN, converts tags from tagset A to tagset B, writes the result to STDOUT.
# (c) 2008 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

sub usage
{
    print STDERR ("Usage: csts_convert_tags.pl -f driver1 -t driver2\n");
}

use utf8;
use open ":utf8";
use Getopt::Long;
use tagset::common;
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

# Get options.
GetOptions('from=s' => \$driver1, 'to=s' => \$driver2);
if($driver1 eq "" || $driver2 eq "")
{
    usage();
    die();
}

while(<>)
{
    # Erase original tag immediately. It is difficult to use in subsequent regular
    # expressions because it can contain vertical bars ("|") and other special characters.
    if(s/<t>([^<]+)/<_tag_to_change_>/)
    {
        my $tag1 = $1;
        my $tag2;
        if(exists($cache{$tag1}))
        {
            $tag2 = $cache{$tag1};
        }
        else
        {
            my $features = tagset::common::decode($driver1, $tag1);
            $tag2 = tagset::common::encode($driver2, $features);
        }
        s/<_tag_to_change_>/<t>$tag2/;
    }
    print;
}
