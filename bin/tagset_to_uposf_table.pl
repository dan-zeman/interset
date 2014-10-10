#!/usr/bin/env perl
# Prints out the conversion table from a tagset to the universal POS tags and features.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Lingua::Interset qw(hash_drivers list decode encode);

my $tagset = $ARGV[0];
my $drivers = hash_drivers();
my @tagsets = sort(keys(%{$drivers}));
my %map; # of features and values across tagsets
my $old;
my $status;
if($drivers->{$tagset}{old})
{
    $old = 'old';
    $status = 'STATUS: LESS RELIABLE (Interset driver is out of date, some values may not be converted correctly)';
}
else
{
    $old = 'new';
    $status = 'STATUS: Interset 2 driver (current version)';
}
my $list_of_tags = list($tagset);
my $n = scalar(@{$list_of_tags});
print("$i\t$tagset\t$old\t$n\n");
# Některé staré ovladače neobsahují seznam povolených značek, takže z nich žádné tabulky nedostaneme.
if($n>0)
{
    print("$status\n");
    foreach my $tag (@{$list_of_tags})
    {
        my $fs = decode($tagset, $tag);
        my $upos = encode('mul::uposf', $fs);
        my $fstext = $fs->as_string();
        # Na výstupu chceme dva sloupce oddělené tabulátorem. Některé značky ale samy obsahují tabulátory, které musíme nejdříve něčím nahradit.
        $tag =~ s/\t/ /g;
        print("$tag\t$upos\n");
        #print("$tag\t$fstext\n");
    }
    close(TABLE);
}
