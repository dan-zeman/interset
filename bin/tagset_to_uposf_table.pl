#!/usr/bin/env perl
# Prints out the conversion table from a tagset to the universal POS tags and features.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Carp;
use Getopt::Long;
use Lingua::Interset qw(hash_drivers list decode encode);

# All examples in Latin, Cyrillic and Greek scripts should be in italics. Other scripts should not.
my $italics = 1;
GetOptions('italics=s' => \$italics);

my $tagset = $ARGV[0];
# Do we want the output to use HTML/Markdown so that it can be included in the documentation of the Universal Dependencies?
my $udepformat = 1;
my $corpus = $ARGV[1]; # where to take examples from (Tagzplorer); e.g. conll-2007-en
my $reduce = $ARGV[2]; # 0/1: whether to reduce indexed tags to subpos
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
    my $examples = '';
    $examples = examples($corpus, $reduce) if($corpus);
    my $i = 0;
    foreach my $tag (@{$list_of_tags})
    {
        my $fs = decode($tagset, $tag);
        my $upos = encode('mul::uposf', $fs);
        my $fstext = $fs->as_string();
        my @examples = @{$examples->{$tag}};
        splice(@examples, 5);
        my $examples = join(', ', @examples);
        # Examples in the Latin, Cyrillic and Greek scripts should be shown in italics.
        # It is not easy to figure out the script (punctuation is not marked as Latin script but we still want it to use italics if the surrounding text does).
        # Therefore we require the user to specify whether they want to turn italics off.
        if($italics)
        {
            $examples = '<em>'.$examples.'</em>';
        }
        if($udepformat)
        {
            my $style = '';
            $style = ' style="background:lightgray"' if($i%2==0);
            # Na výstupu chceme dva sloupce oddělené tabulátorem. Některé značky ale samy obsahují tabulátory, které musíme nejdříve něčím nahradit.
            $tag =~ s/\t/ /g;
            $upos =~ s/\t/<\/td><td>/g;
            print("  <tr$style><td>$tag</td><td>=&gt;</td><td>$upos</td><td>${examples}</td></tr>\n");
        }
        else
        {
            # Na výstupu chceme dva sloupce oddělené tabulátorem. Některé značky ale samy obsahují tabulátory, které musíme nejdříve něčím nahradit.
            $tag =~ s/\t/ /g;
            print("$tag\t$upos\n");
            #print("$tag\t$fstext\n");
        }
        $i++;
    }
    if($udepformat)
    {
        print("</table>\n");
    }
    close(TABLE);
}



#------------------------------------------------------------------------------
# In addition to the Universal equivalents, we can also look for example words.
# We will use indexed words of Tagzplorer that reside at a fixed path.
#------------------------------------------------------------------------------
sub examples
{
    my $corpus = shift;
    my $tagzplorer_path = "C:\\Users\\Dan\\Documents\\Web\\cgi\\tags";
    my $corpus_path = "$tagzplorer_path\\$corpus"; # /tindex.txt
    my $indexpath = "$corpus_path/tindex.txt";
    my %tagzamples;
    open(INDEX, $indexpath) or confess("Cannot read $indexpath: $!");
    while(<INDEX>)
    {
        s/\r?\n$//;
        if(m/^(.*?)<dl>(.*)$/)
        {
            my $tag = $1;
            my $records = $2;
            ###!!! For en::penn, we have to convert the CoNLL 2007 tag.
            $tag =~ s/^(\S+)\s+(\S+)\s+.*/$2/ if($reduce);
            # Parse records.
            my @records = split('<dr>', $records);
            # Remove frequencies.
            my @examples = map {s/<df>.*//; $_} (@records);
            # Remove uppercase duplicates of lowercase word forms.
            my %map;
            foreach my $example (@examples)
            {
                $map{$example}++;
            }
            @examples = grep {lc($_) eq $_ || !exists($map{lc($_)})} (@examples);
            $tagzamples{$tag} = \@examples;
        }
    }
    close(INDEX);
    return \%tagzamples;
}
