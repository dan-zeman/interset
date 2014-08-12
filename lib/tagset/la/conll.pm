#!/usr/bin/perl
# Driver for the CoNLL format Latin data
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>, Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::la::conll;
use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");


#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = "la::conll";
    # three components: coarse-grained pos, fine-grained pos, features
    # The Latin corpus has been converted from the native XML format to CoNLL.
    # The 9-character positional tags were copied "as is" to the FEAT column
    # while the CPOS and POS columns only contain the first character of the tag (part of speech).
    my ($cpos, $pos, $tag) = split(/\s+/, $tag);

    # DZ 29.10.2011: feature values have been split into a more descriptive form and they are now longer than 9 characters.
    $tag = join('', map {s/^.*=//; s/&pipe;/\|/g; s/&amp;/&/g; $_} (split(/\|/, $tag)));
    if (length($tag) != 9) {
        print STDERR "Tag length should be 9\n";
        print STDERR "Error tag: $subpos_big\n";
        die;
    }

    # nouns
    if($pos eq "n")
    {
        $f{pos} = "noun";
    }

    # adj = adjectives
    elsif($pos eq "a")
    {
        $f{pos} = "adj";
    }

    # pron = pronoun
    elsif($pos eq "p")
    {
        $f{pos} = "noun";
    }

    # article
    elsif($pos eq "l")
    {
        $f{pos} = "adj";
        $f{subpos} = "art";
    }

    # num
    elsif($pos eq "m")
    {
        $f{pos} = "num";
    }

    # participle
    elsif($pos eq 't')
    {
        $f{pos} = 'verb';
        $f{verbform} = 'part';
    }

    # verb
    elsif($pos eq "v")
    {
        $f{pos} = "verb";
    }

    # adverb
    elsif($pos eq "d")
    {
        $f{pos} = "adv";
    }

    # preposition
    elsif($pos eq "r")
    {
        $f{pos} = "prep";
    }

    # conjunction
    elsif($pos eq "c")
    {
        $f{pos} = "conj";
    }

    # interjection
    elsif($pos eq "i")
    {
        $f{pos} = "int";
    }

    # exclamation
    elsif ($pos eq "e") {
        $f{pos} = "adj";
    }

    # punc
    elsif($pos eq "u")
    {
        $f{pos} = "punc";
    }

    # particles
    elsif ($pos eq "g") {
        $f{pos} = "part";
    }

    # features are stored in the positional tags itself.
    # no separate column for features.

    # person
    my $secp = substr $tag, 1, 1;
    if ($secp eq "1") {
        $f{person} = "1";
    }
    elsif ($secp eq "2") {
        $f{person} = "2";
    }
    elsif ($secp eq "3") {
        $f{person} = "3";
    }

    # number
    my $thirdp = substr $tag, 2, 1;
    if ($thirdp eq "s") {
        $f{number} = "sing";
    }
    elsif ($thirdp eq "p") {
        $f{number} = "plu";
    }
    elsif ($thirdp eq "d") {
        $f{number} = "dual";
    }

    # tense
    my $fourthp =  substr $tag, 3, 1;
    if ($fourthp eq "p") {
        $f{tense} = "pres";
    }
    elsif ($fourthp eq "f") {
        $f{tense} = "fut";
    }
    elsif ($fourthp eq "a") {
        $f{tense} = 'past';
        $f{subtense} = "aor";
    }
    elsif ($fourthp eq "i") {
        $f{tense} = 'past';
        $f{subtense} = "imp";
    }
    elsif ($fourthp eq "r") {
        $f{tense} = 'past';
        $f{aspect} = "perf";
    }
    elsif ($fourthp eq 't') {
        $f{tense} = 'fut';
        $f{aspect} = 'perf';
    }
    elsif ($fourthp eq 'l') {
        $f{tense} = 'past';
        $f{subtense} = 'pqp';
    }

    # 5. mood
    my $fifthp =  substr $tag, 4, 1;
    if ($fifthp eq "i") {
        $f{verbform} = 'fin';
        $f{mood} = "ind";
    }
    elsif ($fifthp eq "s") {
        $f{verbform} = 'fin';
        $f{mood} = "sub";
    }
    elsif ($fifthp eq "n") {
        $f{verbform} = "inf";
    }
    elsif ($fifthp eq "m") {
        $f{verbform} = 'fin';
        $f{mood} = "imp";
    }
    elsif ($fifthp eq "p") {
        $f{verbform} = "part";
    }
    # d = gerund
    elsif ($fifthp eq "d") {
        $f{verbform} = "ger";
    }
    # g = gerundive
    elsif ($fifthp eq "g") {
        $f{verbform} = "part";
    }

    # 6. voice
    my $sixthp =  substr $tag, 5, 1;
    if ($sixthp eq "a") {
        $f{voice} = "act";
    }
    elsif ($sixthp eq "p") {
        $f{voice} = "pass";
    }
    # this is called medio passive - assigned to passive
    elsif ($sixthp eq "e") {
        $f{voice} = "pass";
    }

    # 7. gender
    my $seventhp =  substr $tag, 6, 1;
    if ($seventhp eq "m") {
        $f{gender} = "masc";
    }
    elsif ($seventhp eq "f") {
        $f{gender} = "fem";
    }
    elsif ($seventhp eq "n") {
        $f{gender} = "neut";
    }

    # 8. case
    my $eighthp =  substr $tag, 7, 1;
    if ($eighthp eq "n") {
        $f{case} = "nom";
    }
    elsif ($eighthp eq "g") {
        $f{case} = "gen";
    }
    elsif ($eighthp eq "d") {
        $f{case} = "dat";
    }
    elsif ($eighthp eq "a") {
        $f{case} = "acc";
    }
    elsif ($eighthp eq "v") {
        $f{case} = "voc";
    }
    elsif ($eighthp eq "l") {
        $f{case} = "loc";
    }

    # 9. degree
    my $ninthp =  substr $tag, 8, 1;
    if ($ninthp eq "s") {
        $f{degree} = "sup";
    }
    elsif ($ninthp eq "c") {
        $f{degree} = "comp";
    }

    return \%f;
}



#------------------------------------------------------------------------------
# Takes feature hash.
# Returns tag string.
#------------------------------------------------------------------------------
sub encode
{
    my $f0 = shift;
    my $nonstrict = shift; # strict is default
    $strict = !$nonstrict;
    # Modify the feature structure so that it contains values expected by this
    # driver.
    my $f = tagset::common::enforce_permitted_joint($f0, $permitted);
    my %f = %{$f}; # This is not a deep copy but $f already refers to a deep copy of the original %{$f0}.
    my $tag;
    # pos and subpos
    # Add the features to the part of speech.
    my @features;
    my $features = join("|", @features);
    if($features eq "")
    {
        $features = "_";
    }
    $tag .= "\t$features";
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# cat train.conll test.conll |\
#   perl -pe '@x = split(/\s+/, $_); $_ = "$x[3]\t$x[4]\t$x[5]\n"' |\
#   sort -u | wc -l
# 880
# 671 after cleaning and adding 'other'-resistant tags
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
-	-	pos=-|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
-	-	pos=-|per=-|num=-|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
-	-	pos=-|per=-|num=-|ten=p|mod=n|voi=a|gen=-|cas=-|deg=-
-	-	pos=-|per=-|num=-|ten=p|mod=n|voi=p|gen=-|cas=-|deg=-
-	-	pos=-|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
-	-	pos=-|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
-	-	pos=-|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
-	-	pos=-|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=a|deg=s
-	-	pos=-|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=v|deg=-
-	-	pos=-|per=-|num=s|ten=-|mod=u|voi=-|gen=-|cas=b|deg=-
-	-	pos=-|per=2|num=s|ten=p|mod=i|voi=a|gen=-|cas=-|deg=-
-	-	pos=-|per=3|num=p|ten=l|mod=s|voi=a|gen=-|cas=-|deg=-
-	-	pos=-|per=3|num=s|ten=r|mod=i|voi=a|gen=-|cas=-|deg=-
a	a	pos=a|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=-|cas=b|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=-|cas=b|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=-|cas=d|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=a|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=a|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=b|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=b|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=d|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=d|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=g|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=n|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=n|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=n|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=v|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=a|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=a|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=b|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=b|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=b|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=d|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=g|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=n|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=n|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=v|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=v|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=a|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=a|deg=s
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=b|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=b|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=d|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=g|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=n|deg=c
a	a	pos=a|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=n|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=a|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=b|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=b|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=g|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=g|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=n|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=n|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=a|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=a|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=b|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=b|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=b|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=d|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=g|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=g|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=g|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=l|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=n|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=n|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=n|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=v|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=v|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=v|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=a|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=a|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=b|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=b|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=b|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=d|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=d|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=g|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=n|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=n|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=v|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=v|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=v|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=a|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=a|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=b|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=b|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=b|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=d|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=g|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=g|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=n|deg=c
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=n|deg=s
a	a	pos=a|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=v|deg=-
c	c	pos=c|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
d	d	pos=d|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
d	d	pos=d|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=c
d	d	pos=d|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=s
e	e	pos=e|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
i	i	pos=i|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
m	m	pos=m|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
n	n	pos=n|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
n	n	pos=n|per=-|num=-|ten=-|mod=-|voi=-|gen=m|cas=-|deg=-
n	n	pos=n|per=-|num=-|ten=-|mod=-|voi=-|gen=n|cas=-|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=-|cas=b|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=-|cas=d|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=-|cas=n|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=-|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=b|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=d|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=g|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=n|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=v|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=b|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=v|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=b|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=d|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=g|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
n	n	pos=n|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=v|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=a|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=b|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=n|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=-|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=b|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=d|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=g|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=l|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=n|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=v|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=-|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=b|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=l|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=v|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=-|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=b|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=d|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=g|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
n	n	pos=n|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=v|deg=-
n	n	pos=n|per=-|num=s|ten=p|mod=-|voi=-|gen=-|cas=v|deg=-
p	p	pos=p|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=b|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=d|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=g|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=n|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=f|cas=v|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=b|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=b|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=d|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=g|deg=-
p	p	pos=p|per=-|num=p|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=-|cas=b|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=a|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=b|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=d|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=g|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=n|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=f|cas=v|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=a|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=b|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=d|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=g|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=n|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=m|cas=v|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=a|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=b|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=d|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=g|deg=-
p	p	pos=p|per=-|num=s|ten=-|mod=-|voi=-|gen=n|cas=n|deg=-
r	r	pos=r|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
t	t	pos=t|per=-|num=-|ten=p|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=-|ten=r|mod=p|voi=p|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=-|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=a|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=a|gen=n|cas=b|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=a|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=f|mod=p|voi=p|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=g|voi=p|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=g|voi=p|gen=f|cas=b|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=g|voi=p|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=g|voi=p|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=g|voi=p|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=g|voi=p|gen=m|cas=b|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=g|voi=p|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=g|voi=p|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=g|voi=p|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=g|voi=p|gen=n|cas=b|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=g|voi=p|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=g|voi=p|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=f|cas=b|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=f|cas=v|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=m|cas=b|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=n|cas=b|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=a|gen=n|cas=v|deg=-
t	t	pos=t|per=-|num=p|ten=p|mod=p|voi=p|gen=f|cas=b|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=-|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=a|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=a|gen=f|cas=b|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=d|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=f|cas=-|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=f|cas=b|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=m|cas=b|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=m|cas=v|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=n|cas=b|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=n|cas=d|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=p|ten=r|mod=p|voi=p|gen=n|cas=v|deg=-
t	t	pos=t|per=-|num=s|ten=-|mod=p|voi=p|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=a|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=a|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=a|gen=f|cas=v|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=a|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=a|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=f|mod=p|voi=a|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=-|voi=a|gen=n|cas=b|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=-|voi=a|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=d|voi=a|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=d|voi=a|gen=n|cas=b|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=d|voi=a|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=g|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=g|voi=p|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=g|voi=p|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=g|voi=p|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=g|voi=p|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=g|voi=p|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=g|voi=p|gen=m|cas=b|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=g|voi=p|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=g|voi=p|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=g|voi=p|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=g|voi=p|gen=n|cas=b|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=g|voi=p|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=g|voi=p|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=g|voi=p|gen=n|cas=v|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=f|cas=b|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=f|cas=n|deg=c
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=m|cas=b|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=m|cas=n|deg=c
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=n|cas=b|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=n|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=p|mod=p|voi=a|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=a|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=a|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=a|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=a|gen=n|cas=b|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=f|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=f|cas=b|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=f|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=f|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=f|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=m|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=m|cas=b|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=m|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=m|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=m|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=m|cas=v|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=n|cas=a|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=n|cas=b|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=n|cas=d|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=n|cas=g|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=n|cas=n|deg=-
t	t	pos=t|per=-|num=s|ten=r|mod=p|voi=p|gen=n|cas=v|deg=-
u	u	pos=u|per=-|num=-|ten=-|mod=-|voi=-|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=-|mod=n|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=f|mod=n|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=p|mod=n|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=p|mod=n|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=-|num=-|ten=r|mod=n|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=-|ten=r|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=f|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=f|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=i|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=i|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=i|mod=s|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=l|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=l|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=p|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=p|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=p|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=p|mod=s|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=r|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=p|ten=r|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=f|mod=-|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=f|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=f|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=i|mod=-|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=i|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=i|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=i|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=i|mod=s|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=l|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=l|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=p|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=p|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=p|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=p|mod=s|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=r|mod=-|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=r|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=r|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=1|num=s|ten=t|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=f|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=f|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=i|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=i|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=l|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=p|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=p|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=p|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=p|mod=m|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=p|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=p|mod=s|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=r|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=p|ten=r|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=-|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=f|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=f|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=f|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=i|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=i|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=l|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=l|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=m|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=p|mod=s|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=r|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=r|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=2|num=s|ten=t|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=f|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=f|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=f|mod=m|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=i|mod=-|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=i|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=i|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=i|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=i|mod=s|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=l|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=l|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=p|mod=s|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=r|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=r|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=r|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=p|ten=t|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=-|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=-|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=f|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=f|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=i|mod=-|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=i|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=i|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=i|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=i|mod=s|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=l|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=l|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=i|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=p|mod=s|voi=p|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=r|mod=-|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=r|mod=i|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=r|mod=s|voi=a|gen=-|cas=-|deg=-
v	v	pos=v|per=3|num=s|ten=t|mod=i|voi=a|gen=-|cas=-|deg=-
end_of_list
    ;
    # Protect from editors that replace tabs by spaces.
    $list =~ s/ \s+/\t/sg;
    my @list = split(/\r?\n/, $list);
    pop(@list) if($list[$#list] eq "");
    return \@list;
}



#------------------------------------------------------------------------------
# Create trie of permitted feature structures. This will be needed for strict
# encoding. This BEGIN block cannot appear before the definition of the list()
# function.
#------------------------------------------------------------------------------
BEGIN
{
    # Store the hash reference in a global variable.
    #$permitted = tagset::common::get_permitted_structures_joint(list(), \&decode);
}



1;
