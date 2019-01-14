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
use Lingua::Interset qw(hash_drivers list decode encode get_driver_object);

sub usage
{
    print STDERR ("Usage:   tagset_to_uposf_table.pl [--reduce-to-subpos] [--italics 0] <tagset> <corpus>\n");
    print STDERR ("Example: tagset_to_uposf_table.pl en::penn conll-2007-en --reduce-to-subpos > docs/_tagset-conversion/en-penn-uposf.md\n");
    print STDERR ('Example: tagset_to_uposf_table.pl fa::conll persian-dt --italics 0 > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\fa-conll-uposf.md', "\n");
    print STDERR ('Example: tagset_to_uposf_table.pl cs::multext > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\cs-multext-uposf.md', "\n");
    print STDERR ("         <tagset> ... e.g. en::conll\n");
    print STDERR ("         <corpus> ... e.g. conll-2007-en; where to take examples from\n");
    print STDERR ("             Omit this argument if there is no corpus tagged with these tags.\n");
    print STDERR ("         --italics ... should examples be formatted as italics? Default: 1\n");
    print STDERR ("         --reduce-to-subpos ... if the examples come from a corpus in the CoNLL\n");
    print STDERR ("             format: tags from the tagset correspond to just the subpos part\n");
    print STDERR ("             of the indexed tags with examples\n");
}

# tagset_to_uposf_table.pl ar::conll --italics 0 conll-2006-ar > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\ar-conll-uposf.md
# tagset_to_uposf_table.pl ar::conll2007 --italics 0 conll-2007-ar > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\ar-conll2007-uposf.md
# tagset_to_uposf_table.pl ar::padt > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\ar-padt-uposf.md
# tagset_to_uposf_table.pl bg::conll conll-2006-bg > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\bg-conll-uposf.md
# tagset_to_uposf_table.pl bn::conll > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\bn-conll-uposf.md
# tagset_to_uposf_table.pl ca::conll2009 conll-2009-ca > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\ca-conll2009-uposf.md
# tagset_to_uposf_table.pl cs::ajka > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\cs-ajka-uposf.md
# tagset_to_uposf_table.pl cs::conll conll-2006-cs > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\cs-conll-uposf.md
# tagset_to_uposf_table.pl cs::multext > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\cs-multext-uposf.md
# tagset_to_uposf_table.pl cs::pdt pdt > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\cs-pdt-uposf.md
# tagset_to_uposf_table.pl da::conll conll-2006-da > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\da-conll-uposf.md
# tagset_to_uposf_table.pl de::conll2009 conll-2009-de > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\de-conll2009-uposf.md
# tagset_to_uposf_table.pl de::smor > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\de-smor-uposf.md
# tagset_to_uposf_table.pl de::stts conll-2006-de --reduce-to-subpos > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\de-stts-uposf.md
# tagset_to_uposf_table.pl el::conll conll-2007-el > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\el-conll-uposf.md
# tagset_to_uposf_table.pl en::penn conll-2007-en --reduce-to-subpos > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\en-penn-uposf.md
# tagset_to_uposf_table.pl es::conll2009 conll-2009-es > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\es-conll2009-uposf.md
# tagset_to_uposf_table.pl et::puudepank eesti-keele-puudepank > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\et-puudepank-uposf.md
# tagset_to_uposf_table.pl eu::conll basque-dt > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\eu-conll-uposf.md
# tagset_to_uposf_table.pl fa::conll persian-dt --italics 0 > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\fa-conll-uposf.md
# tagset_to_uposf_table.pl fi::turku turku-dt --reduce-to-subpos > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\fi-turku-uposf.md
# tagset_to_uposf_table.pl grc::conll agdt-conll > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\grc-conll-uposf.md
# tagset_to_uposf_table.pl he::conll --italics 0 hebrew-dt > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\he-conll-uposf.md
# tagset_to_uposf_table.pl hi::conll --italics 0 hindi-tb-0.5 > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\hi-conll-uposf.md
# tagset_to_uposf_table.pl hr::multext > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\hr-multext-uposf.md
# tagset_to_uposf_table.pl hu::conll conll-2007-hu > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\hu-conll-uposf.md
# tagset_to_uposf_table.pl it::conll conll-2007-it > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\it-conll-uposf.md
# tagset_to_uposf_table.pl ja::conll conll-2006-ja > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\ja-conll-uposf.md
# tagset_to_uposf_table.pl ja::ipadic > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\ja-ipadic-uposf.md
# tagset_to_uposf_table.pl la::conll ldt-conll > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\la-conll-uposf.md
# tagset_to_uposf_table.pl la::itconll la-itt --reduce=itt > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\la-itconll-uposf.md
# tagset_to_uposf_table.pl lt::multext lt-alksnis > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\lt-multext-uposf.md
# tagset_to_uposf_table.pl mt::mlss malti --reduce-to-subpos > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\mt-mlss-uposf.md
# tagset_to_uposf_table.pl nl::cgn > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\nl-cgn-uposf.md
# tagset_to_uposf_table.pl nl::conll conll-2006-nl > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\nl-conll-uposf.md
# tagset_to_uposf_table.pl pl::ipipan > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\pl-ipipan-uposf.md
# tagset_to_uposf_table.pl pt::cintil > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\pt-cintil-uposf.md
# tagset_to_uposf_table.pl pt::conll conll-2006-pt > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\pt-conll-uposf.md
# tagset_to_uposf_table.pl pt::freeling > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\pt-freeling-uposf.md
# tagset_to_uposf_table.pl ro::multext ud-romanian > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\ro-multext-uposf.md
# tagset_to_uposf_table.pl ro::rdt > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\ro-rdt-uposf.md
# tagset_to_uposf_table.pl ru::syntagrus syntagrus > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\ru-syntagrus-uposf.md
# tagset_to_uposf_table.pl sk::snk snk > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\sk-snk-uposf.md
# tagset_to_uposf_table.pl sl::conll conll-2006-sl > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\sl-conll-uposf.md
# tagset_to_uposf_table.pl sl::multext > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\sl-multext-uposf.md
# tagset_to_uposf_table.pl sv::mamba conll-2006-sv --reduce-to-subpos > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\sv-mamba-uposf.md
# tagset_to_uposf_table.pl sv::parole ud-swedish-parole > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\sv-parole-uposf.md
# tagset_to_uposf_table.pl sv::suc ud-swedish > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\sv-suc-uposf.md
# tagset_to_uposf_table.pl ta::tamiltb --italics 0 tamiltb > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\ta-tamiltb-uposf.md
# tagset_to_uposf_table.pl te::conll > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\te-conll-uposf.md
# tagset_to_uposf_table.pl tr::conll conll-2007-tr > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\tr-conll-uposf.md
# tagset_to_uposf_table.pl zh::conll --italics 0 conll-2006-zh > Documents\Lingvistika\Projekty\universal-dependencies\docs\_tagset-conversion\zh-conll-uposf.md

# All examples in Latin, Cyrillic and Greek scripts should be in italics. Other scripts should not.
my $italics = 1;
my $reduce = 0; # 0/1/itt: whether to reduce indexed tags to subpos
GetOptions
(
    'italics=s' => \$italics,
    'reduce-to-subpos' => \$reduce,
    'reduce=s' => \$reduce
);

my $tagset = $ARGV[0];
# Do we want the output to use HTML/Markdown so that it can be included in the documentation of the Universal Dependencies?
my $udepformat = 1;
my $corpus = $ARGV[1]; # where to take examples from (Tagzplorer); e.g. conll-2007-en
my $driver = get_driver_object($tagset);
if($udepformat)
{
    print("---\n");
    print("layout: base\n");
    print("title: 'Tagset $tagset conversion to universal POS tags and features'\n");
    print("udver: '2'\n");
    print("---\n\n");
    print("<a href=\"index.html\">all tables</a>\n\n");
    print("\#\# Tagset $tagset\n\n");
    print("**Disclaimer:**\n");
    print("This conversion table was generated automatically via Interset.\n");
    print("It uses only tags (+ features) as input, therefore it is only an approximation.\n");
    print("Some tags can only be mapped if we also know the lemma or the syntactic context; such information has not been available here.\n");
    print("The table requires manual postprocessing in order to provide accurate and complete information.\n\n");
}
my %map; # of features and values across tagsets
my $list_of_tags = $driver->list();
my $n = scalar(@{$list_of_tags});
# Některé staré ovladače neobsahují seznam povolených značek, takže z nich žádné tabulky nedostaneme.
if($n>0)
{
    if($udepformat)
    {
        print("Tagset <tt>$tagset</tt>, total $n tags.\n\n");
        print("<table>\n");
    }
    my $examplehash = {};
    $examplehash = examples($corpus, $reduce, $driver) if($corpus);
    my $i = 0;
    foreach my $tag (@{$list_of_tags})
    {
        my $fs = $driver->decode($tag);
        my $upos = encode('mul::uposf', $fs);
        my @examples = @{$examplehash->{$tag}};
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
            $tag =~ s/&/&amp;/g;
            $tag =~ s/</&lt;/g;
            $tag =~ s/>/&gt;/g;
            $upos =~ s/\t/<\/td><td>/g;
            print("  <tr$style><td>$tag</td><td>=&gt;</td><td>$upos</td><td>${examples}</td></tr>\n");
        }
        else
        {
            # Na výstupu chceme dva sloupce oddělené tabulátorem. Některé značky ale samy obsahují tabulátory, které musíme nejdříve něčím nahradit.
            $tag =~ s/\t/ /g;
            print("$tag\t$upos\n");
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
    my $reduce = shift;
    my $driver = shift;
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
            # In some cases the indexed examples contain CoNLL-like tags
            # (three tab-separated strings) but our tagset contains only
            # the POS tag (the second string) and we must reduce the indexed tag to match it.
            if($reduce && $reduce ne 'itt')
            {
                $tag =~ s/^(\S+)\s+(\S+)\s+.*/$2/;
            }
            # Elsewhere (the Index Thomisticus Treebank of Latin) the examples are indexed by a combination of the subpos and features,
            # but the tagset described by the Interset driver contains also the coarse pos.
            elsif($reduce eq 'itt')
            {
                $tag =~ s/^([A-Z]?)(\d)\|(.+)$/$2\t$1$2\t$3/;
                print STDERR ("$tag\n");
            }
            # For some tagsets we have reordered features in the tags listed in the drivers.
            # Therefore the listed tags do not match those indexed with the examples.
            # Recoding the tag using Interset should help.
            my $fs = $driver->decode($tag);
            $tag = $driver->encode($fs);
            # Parse records.
            my @records = split('<dr>', $records);
            # Remove frequencies.
            my @examples = map {s/<df>.*//; $_} (@records);
            print STDERR (join(', ', @examples), "\n");
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
