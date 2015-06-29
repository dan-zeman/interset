#!/usr/bin/env perl
# Testing DZ Interset 2.0.
# Copyright © 2014, 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
# We must declare in advance how many tests we are going to perform.
# There are currently three tests per tagset driver.
use Test::More tests => 52*3;
use Lingua::Interset qw(get_driver_object);
use Lingua::Interset::Tagset;

# Run standard driver tests for all drivers that are part of the release.
###!!! Exclude selected tagsets that are too large: cs::conll cs::conll2009 cs::cnk cs::pmk mul::uposf ur::conll
my @tagsets =
(
    'ar::padt', 'ar::conll', 'ar::conll2007',
    'bg::conll',
    'bn::conll',
    'ca::conll2009',
    'cs::pdt', 'cs::ajka', 'cs::multext', 'cs::pmkkr',
    'da::conll',
    'de::stts', 'de::conll2009', 'de::smor',
    'el::conll',
    'en::penn', 'en::conll', 'en::conll2009',
    'et::puudepank',
    'eu::conll',
    'fa::conll',
    'fi::turku',
    'grc::conll',
    'he::conll',
    'hi::conll',
    'hr::multext',
    'hu::conll',
    'it::conll',
    'ja::conll', 'ja::ipadic',
    'la::conll', 'la::itconll',
    'mul::google', 'mul::upos',
    'nl::cgn', 'nl::conll',
    'no::conll',
    'pl::ipipan',
    'pt::cintil', 'pt::conll',
    'ro::rdt',
    'ru::syntagrus',
    'sk::snk',
    'sl::conll',
    'sv::mamba', 'sv::conll', 'sv::parole', 'sv::suc',
    'ta::tamiltb',
    'te::conll',
    'tr::conll',
    'zh::conll'
);
foreach my $tagset (@tagsets)
{
    print STDERR ("Now testing the driver for the tagset '$tagset'...\n");
    my $driver = get_driver_object($tagset);
    ok(defined($driver), "tagset driver '$tagset' object defined");
    my $list = $driver->list();
    my $n = scalar(@{$list});
    ok($n > 0, "'$tagset' has non-empty list of tags");
    my @errors = $driver->test();
    if(@errors)
    {
        print STDERR (join('', @errors), "\n");
    }
    ok(!@errors, "'$tagset' driver integrity test");
}
