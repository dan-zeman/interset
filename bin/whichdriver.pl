#!/usr/bin/env perl
# Searches the installed Interset drivers and for a given tagset id tells the path to the driver that will be used.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use strict;
use warnings;
use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Lingua::Interset;

if(scalar(@ARGV)==0)
{
    die("Usage: whichdriver.pl tagset_id\n");
}
my $tagset = $ARGV[0];
my $drivers = Lingua::Interset::get_driver_hash();
print($drivers->{$tagset}{path}, "\n");
