#!/usr/bin/env perl
# Projde všechny sady značek a vytvoří převodní tabulky z těchto sad do Google Universal POS.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Lingua::Interset qw(hash_drivers list decode encode);

my $drivers = hash_drivers();
my @tagsets = sort(keys(%{$drivers}));
my %map; # of features and values across tagsets
my $i = 0;
foreach my $tagset (@tagsets)
{
    $i++;
    my $old;
    my $status;
    my $filename = $tagset;
    $filename =~ s/::/-/;
    if($drivers->{$tagset}{old})
    {
        $old = 'old';
        $filename = "old-$filename";
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
        open(TABLE, ">$filename") or die("Cannot write $filename: $!");
        print TABLE ("$status\n");
        foreach my $tag (@{$list_of_tags})
        {
            my $fs = decode($tagset, $tag);
            my $upos = encode('mul::google', $fs);
            my $fstext = $fs->as_string();
            # Na výstupu chceme dva sloupce oddělené tabulátorem. Některé značky ale samy obsahují tabulátory, které musíme nejdříve něčím nahradit.
            $tag =~ s/\t/ /g;
            #print TABLE ("$tag\t$upos\n");
            #print TABLE ("$tag\t$fstext\n");
            # Remember occurrences of non-empty feature values in tagsets.
            my $fsh = $fs->get_hash();
            foreach my $feature (keys(%{$fsh}))
            {
                next if($feature =~ m/^(tagset|other)$/);
                my @values = $fs->get_list($feature);
                foreach my $value (@values)
                {
                    next if(!defined($value) || $value eq '');
                    $map{$feature}{$value}{$tagset}++;
                }
            }
        }
        close(TABLE);
    }
    #last if(++$stop==5);
}
my $filename = 'features.txt';
open(FEATURES, ">$filename") or die("Cannot write $filename: $!");
foreach my $feature (sort(keys(%map)))
{
    my $url = "https://wiki.ufal.ms.mff.cuni.cz/user:zeman:interset:features#$feature";
    foreach my $value (sort(keys(%{$map{$feature}})))
    {
        my @tagsets = sort(keys(%{$map{$feature}{$value}}));
        my $n = scalar(@tagsets);
        my $tagsets = "$n: ".join(', ', @tagsets);
        print FEATURES ("$feature\t$value\t$tagsets\t$url\n");
    }
}
close(FEATURES);
