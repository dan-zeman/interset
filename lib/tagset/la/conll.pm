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
