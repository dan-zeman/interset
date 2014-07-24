#!/usr/bin/perl
# Driver for the CGN/Lassy/Alpino tagset
# Copyright © Zdeněk Žabokrtský, Dan Zeman, Ondřej Dušek
# License: GNU GPL

package tagset::nl::cgn;
use utf8;
#use strict;
#use warnings;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

# tagset documentation at
# http://www.let.rug.nl/~vannoord/Lassy/POS_manual.pdf

my %postable =
(
    'ADJ'  => ['pos' => 'adj'], # groot, goed, bekend, nodig, vorig
    'BW'  => ['pos' => 'adv'], # zo, nu, dan, hier, altijd
    'LID'  => ['pos' => 'adj', 'subpos' => 'art'], # het, der, de, des, den
    'VG' => ['pos' => 'conj'], # en, maar, of, dat, als, om
    'TSW'  => ['pos' => 'int'], # ja, nee
    'N'    => ['pos' => 'noun'], # jaar, heer, land, plaats, tijd
    'TW'  => ['pos' => 'num'], # twee, drie, vier, miljoen, tien
    'VZ' => ['pos' => 'prep'], # van, in, op, met, voor
    'VNW' => ['pos' => 'noun', 'prontype' => 'prs'], # ik, we, wij, u, je, jij, jullie, ze, zij, hij, het, ie, zijzelf
    'LET' => ['pos' => 'punc'], # " ' : ( ) ...
    'WW'    => ['pos' => 'verb'] # worden, zijn, blijven, komen, wezen
);

my %featable =
(
    ## adjective type (attr and zelfst applies to numerals and pronouns too)
    'prenom'   => ['synpos' => 'attr'], # attributively used (adjectives, verbs "de nog te lezen post")
    'postnom'   => ['synpos' => 'attr'], # attributively used
    'vrij' => ['synpos' => 'pred'], # independently used (adjectives, verbs)
    'nom' => ['synpos' => 'subst'], # substantively used (adjectives, verbs)
    'adv-pron' => ['synpos' => 'adv'], # pronominal adverbs
    ## degree of comparison (adjectives, adverbs and indefinite numerals (veel/weinig, meer/minder, meest/minst))
    'basis'  => ['degree' => 'pos'], # positive (goed, lang, erg, snel, zeker)
    'comp'  => ['degree' => 'comp'], # comparative (verder, later, eerder, vroeger, beter)
    'sup' => ['degree' => 'sup'], # superlative (best, grootst, kleinst, moeilijkst, mooist)
    ## various inflection forms (not used: getal-n, agr3, rest3...)
    'zonder' => [], # base form (een mooi huis)
    'met-e' => [], # -e (een grote pot, een niet te verstane verleiding -- adjectives, verbs)
    'met-s' => [], # -s (iets moois)    
    'zonder-n' => [], # nominal usage without plural -n (het groen)
    'mv-n' => ['number' => 'plu'], # nominal usage with plural -n (de rijken)    
    ## definiteness of articles (definiteness = 'ind') and numerals (prontype = 'ind')
    'bep'   => ['definiteness' => 'def'], # (het, der, de, des, den)
    'onbep' => ['definiteness' => 'ind', 'prontype' => 'ind'], # (een)
    ## gender
    'zijd' => ['gender' => 'com'], # non-neuter (de)
    'fem'  => ['gender' => 'fem'], # feminine (only pronouns)
    'masc' => ['gender' => 'masc'], # masculine (only pronouns)
    'onz'       => ['gender' => 'neut'], # neuter (het)
    ## case of articles, pronouns, adjectives, numerals, and nouns
    'stan' => [], # no case (i.e. nominative or a word that does not take case markings) (het, de, een)
    'bijz' => ['case' => 'acc'], # 'special' case (zaliger gedachtenis, van goeden huize, ten enen male)
    'obl' => ['case' => 'acc'], # oblique case (mij, haar, ons)
    'nomin'  => ['case' => 'nom'], # nominative (only pronouns: ik, we, wij, u, je, jij, jullie, ze, zij, hij, het, ie, zijzelf)
    'gen'  => ['case' => 'gen'], # genitive (der, des)
    'dat'  => ['case' => 'dat'], # dative (den)
    ## conjunction type
    'neven' => ['subpos' => 'coor'], # coordinating (en, maar, of)
    'onder' => ['subpos' => 'sub'], # subordinating (dat, als, dan, om, zonder, door)
    ## noun type
    'soort' => [], # common noun is the default type of noun (jaar, heer, land, plaats, tijd)
    'eigen' => ['subpos' => 'prop'], # proper noun (Nederland, Amsterdam, zaterdag, Groningen, Rotterdam)
    ## number (nouns, verbs)
    'ev' => ['number' => 'sing'], # enkelvoud (jaar, heer, land, plaats, tijd)
    'evf' => ['number' => 'sing'], # ditto?
    'evmo' => ['number' => 'sing'], # ditto?
    'evon' => ['number' => 'sing'], # ditto?
    'mv' => ['number' => 'plu'], # meervoud (mensen, kinderen, jaren, problemen, landen)
    ## noun form
    'basis' => [], # normal
    'dim' => [], # diminutive (nouns, adjectives ~ comparative degree! -- het is hier stilletjes)
    ## numeral type
    'hoofd' => ['numtype' => 'card'], # hoofdtelwoord (twee, 1969, beider, minst, veel)
    'rang'  => ['numtype' => 'ord'], # rangtelwoord (eerste, tweede, derde, vierde, vijfde)
    ## pronoun type
    'pers'   => ['prontype' => 'prs'], # persoonlijk (me, ik, ons, we, je, u, jullie, ze, hem, hij, hen)
    'pr'   => ['prontype' => 'prs'], # the same?
    'bez'   => ['prontype' => 'prs', 'poss' => 'poss'], # beztittelijk (mijn, onze, je, jullie, zijner, zijn, hun)
    'refl'   => ['prontype' => 'prs', 'reflex' => 'reflex'], # reflexief (me, mezelf, mij, ons, onszelf, je, jezelf, zich, zichzelf)
    'recip'   => ['prontype' => 'rcp'], # reciprook (elkaar, elkaars)
    'aanw'  => ['prontype' => 'dem'], # aanwijzend (deze, dit, die, dat)
    'betr'  => ['prontype' => 'rel'], # betrekkelijk (welk, die, dat, wat, wie)
    'vrag'  => ['prontype' => 'int'], # vragend (wie, wat, welke, welk)
    'onbep' => ['prontype' => 'ind'], # onbepaald (geen, andere, alle, enkele, wat)
    ## pronoun or verb person
    '1' => ['person' => 1], # (mijn, onze, ons, me, mij, ik, we, mezelf, onszelf)
    '2v' => ['person' => 2, 'politeness' => 'inf'], # (je, jouw, jullie, jou, je, jij, jezelf)
    '2b' => ['person' => 2, 'politeness' => 'pol'], # (u, uw)
    '2' => ['person' => 2], #
    '3' => ['person' => 3], # (zijner, zijn, haar, zijnen, zijne, hun, ze, zij, hem, het, hij, ie, zijzelf, zich, zichzelf)
    '3o' => ['person' => 3], # iets
    '3p' => ['person' => 3], # iemand
    ## pronoun form 
    'vol' => ['variant' => 'long'], # zij, haar
    'red' => ['variant' => 'short'], # ze, d'r
    ## verb form, mood, tense and aspect
    'pv' => ['verbform' => 'fin'],
    'inf' => ['verbform' => 'inf'],
    'tgw' => ['tense' => 'pres' ],
    'met-t' => [], # sg. 2nd+3rd person, 'u' (polite form for sg. and pl.)
    'verl' => ['tense' => 'past'],
    'conj' => ['mood' => 'sub'], # expressing wishes (het ga je goed) -- jussive?
    'od'  => ['verbform' => 'part', 'tense' => 'pres'], # (volgend, verrassend, bevredigend, vervelend, aanvallend)
    'vd' => ['verbform' => 'part', 'tense' => 'past'], # (afgelopen, gekomen, gegaan, gebeurd, begonnen)
    ## preposition types
    'fin' => ['subpos' => 'post'],
    'versm' => ['subpos' => 'comprep'],
    ## symbols
    'symb' => ['pos' => 'punc', 'punctype' => 'symb'],
    'afk' => ['abbr' => 'abbr'],
);



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f = ( tagset => 'nl::cgn' );
    # three components: coarse-grained pos, fine-grained pos, features
    my ($pos, $features) = split(/[\(\)]/, $tag);
    my @features = split(/,/, $features);
    my @assignments = @{$postable{$pos}};
    map {push(@assignments, @{$featable{$_}})} (@features);
    for(my $i = 0; $i<=$#assignments; $i += 2)
    {
        $f{$assignments[$i]} = $assignments[$i+1];
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
