#!/usr/bin/perl
# Reads CSTS from STDIN, converts tags from tagset A to tagset B, writes the result to STDOUT.
# Copyright © 2008, 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL
# 11.6.2014: Adapted to Interset 2.0.

sub usage
{
    print STDERR ("Usage: csts_convert_tags.pl -f driver1 -t driver2\n");
}

use utf8;
use open ':utf8';
use Getopt::Long;
use Lingua::Interset qw(get_driver_object);
binmode(STDIN,  ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

# Get options.
GetOptions('from=s' => \$tagset1, 'to=s' => \$tagset2);
if($tagset1 eq '' || $tagset2 eq '')
{
    usage();
    die();
}

my $driver1 = get_driver_object($tagset1);
my $driver2 = get_driver_object($tagset2);
my %cache;
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
            my $fs = $driver1->decode($tag1);
            $tag2 = $driver2->encode($fs);
        }
        s/<_tag_to_change_>/<t>$tag2/;
    }
    print;
}
