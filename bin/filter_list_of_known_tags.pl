#!/usr/bin/env perl
# Reads the list of known tags, decodes them and encodes again. As a result, the features are in the canonical order.
# Some features or entire tags can be filtered if desired. This is a one-time action and the exact behavior must be specified by editing this source code.
# We typically need this script during the development of a new driver.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Lingua::Interset qw(get_driver_object);

my $driver = get_driver_object('fi::turku');
my $list = $driver->list();
my %map;
foreach my $tag (@{$list})
{
    #my $fs = $driver->decode($tag);
    #my $tag1 = $driver->encode($fs);
    # Zatím nemáme hotové metody decode() a encode(), ale chceme přepsat značky z formátu, který uměle připomíná CoNLL, do základního.
    $tag1 = $tag;
    $tag1 =~ s/^\S+\s+\S+\s+(\S+)$/$1/;
    $map{$tag1}++;
    # Příliš mnoho informací se ukládá do rysu other. Chceme zajistit, aby i značky, které vzniknou, když tyto informace nebudou k dispozici, byly platné.
    #$fs->set('other', '');
    #my $tag2 = encode('eu::conll', $fs);
    #$map{$tag2}++;
}
my @list1 = sort(keys(%map));
foreach my $tag (@list1)
{
    print("$tag\n");
}
