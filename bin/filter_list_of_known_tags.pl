#!/usr/bin/env perl
# Načte seznam značek, dekóduje je a znova zakóduje, čímž uvede rysy do kanonického pořadí.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Lingua::Interset qw(list decode encode);

my $list = list('eu::conll');
my %map;
foreach my $tag (@{$list})
{
    my $fs = decode('eu::conll', $tag);
    my $tag1 = encode('eu::conll', $fs);
    $map{$tag1}++;
    # Příliš mnoho informací se ukládá do rysu other. Chceme zajistit, aby i značky, které vzniknou, když tyto informace nebudou k dispozici, byly platné.
    $fs->set('other', '');
    my $tag2 = encode('eu::conll', $fs);
    $map{$tag2}++;
}
my @list1 = sort(keys(%map));
foreach my $tag (@list1)
{
    print("$tag\n");
}
