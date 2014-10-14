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
# Do we want the output to use HTML/Markdown so that it can be included in the documentation of the Universal Dependencies?
my $udepformat = 1;
if($udepformat)
{
    print("---\n");
    print("layout: base\n");
    print("title: 'Tagset $tagset conversion to universal POS tags and features'\n");
    print("---\n\n");
    print("<a href=\"index.html\">all tables</a>\n\n");
    print("\#\# Tagset $tagset\n\n");
    print("**Disclaimer:**\n");
    print("This conversion table was generated automatically via Interset.\n");
    print("It uses only tags (+ features) as input, therefore it is only an approximation.\n");
    print("Some tags can only be mapped if we also know the lemma or the syntactic context; such information has not been available here.\n");
    print("The table requires manual postprocessing in order to provide accurate and complete information.\n\n");
}
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
# Některé staré ovladače neobsahují seznam povolených značek, takže z nich žádné tabulky nedostaneme.
if($n>0)
{
    if($udepformat)
    {
        print("Tagset <tt>$tagset</tt>, total $n tags.\n\n");
        print("<table>\n");
    }
    else
    {
        print("$status\n");
    }
    foreach my $tag (@{$list_of_tags})
    {
        my $fs = decode($tagset, $tag);
        my $upos = encode('mul::uposf', $fs);
        my $fstext = $fs->as_string();
        if($udepformat)
        {
            # Na výstupu chceme dva sloupce oddělené tabulátorem. Některé značky ale samy obsahují tabulátory, které musíme nejdříve něčím nahradit.
            $tag =~ s/\t/ /g;
            $upos =~ s/\t/<\/td><td>/g;
            print("  <tr><td>$tag</td><td>=&gt;</td><td>$upos</td></tr>\n");
        }
        else
        {
            # Na výstupu chceme dva sloupce oddělené tabulátorem. Některé značky ale samy obsahují tabulátory, které musíme nejdříve něčím nahradit.
            $tag =~ s/\t/ /g;
            print("$tag\t$upos\n");
            #print("$tag\t$fstext\n");
        }
    }
    if($udepformat)
    {
        print("</table>\n");
    }
    close(TABLE);
}
