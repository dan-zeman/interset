#!/usr/bin/perl
# Driver for the CoNLL 2006 Dutch tagset.
# Copyright © Zdeněk Žabokrtský, Dan Zeman
# License: GNU GPL

package tagset::nl::conll;
use utf8;
#use strict;
#use warnings;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");



# tagset documentation in /net/data/conll/2006/nl/doc.

my %postable =
(
    'Adj'  => ['pos' => 'adj'], # groot, goed, bekend, nodig, vorig
    'Adv'  => ['pos' => 'adv'], # zo, nu, dan, hier, altijd
    'Art'  => ['pos' => 'adj', 'subpos' => 'art'], # het, der, de, des, den
    'Conj' => ['pos' => 'conj'], # en, maar, of, dat, als, om
    'Int'  => ['pos' => 'int'], # ja, nee
    'Misc' => [], # sarx, the, jazz, plaats, Bevrijding ... words unknown by the tagger? In the corpus, it occurs only with the feature 'vreemd' (foreign).
    'MWU'  => [], # multi-word unit. Needs special treatment. Subpos contains the POSes. E.g. "MWU V_V" is combination of two verbs ("laat_staan").
    'N'    => ['pos' => 'noun'], # jaar, heer, land, plaats, tijd
    'Num'  => ['pos' => 'num'], # twee, drie, vier, miljoen, tien
    'Prep' => ['pos' => 'prep'], # van, in, op, met, voor
    'Pron' => ['pos' => 'noun', 'prontype' => 'prs'], # ik, we, wij, u, je, jij, jullie, ze, zij, hij, het, ie, zijzelf
    'Punc' => ['pos' => 'punc'], # " ' : ( ) ...
    'V'    => ['pos' => 'verb'] # worden, zijn, blijven, komen, wezen
);

my %featable =
(
    # adjective type (attr and zelfst applies to numerals and pronouns too)
    'adv'    => ['synpos' => 'adv'], # adverbially used
    'attr'   => ['synpos' => 'attr'], # attributively used
    'zelfst' => [], # independently used
    # degree of comparison (adjectives, adverbs and indefinite numerals (veel/weinig, meer/minder, meest/minst))
    'stell'  => ['degree' => 'pos'], # positive (goed, lang, erg, snel, zeker)
    'vergr'  => ['degree' => 'comp'], # comparative (verder, later, eerder, vroeger, beter)
    'overtr' => ['degree' => 'sup'], # superlative (best, grootst, kleinst, moeilijkst, mooist)
    # adjective form (applies also to indefinite numerals and verbal participles)
    'onverv'   => [], # uninflected (best, grootst, kleinst, moeilijkst, mooist)
    'vervneut' => [], # normal inflected form (mogelijke, ongelukkige, krachtige, denkbare, laatste)
    'vervgen'  => ['case' => 'gen'], # genitive form (bijzonders, goeds, nieuws, vreselijks, lekkerders)
    'vervmv'   => ['number' => 'plu'], # plural form (aanwezigen, religieuzen, Fransen, deskundigen, doden)
    'vervdat'  => ['case' => 'dat'], # dative form, verbs only, not found in corpus
    'vervverg' => ['degree' => 'comp'], # comparative form, verbs only (tegemoetkomender, overrompelender, vermoeider, verfijnder)
    # adverb type
    'gew'     => [], # normal (zo, nu, dan, hier, altijd)
    'pron'    => [], # pronominal (daar, daarna, waarin, waarbij)
    'deelv'   => ['subpos' => 'vbp'], # adverbial or prepositional part of separable verb (phrasal verb) (uit, op, aan, af, in)
    'deeladv' => [], # prepositional part of separed pronominal adverb (van, voor, aan, op, mee)
    # function of normal and pronominal adverbs
    'geenfunc' => [], # no function information (meest, niet, nog, ook, wel)
    'betr'     => ['prontype' => 'rel'], # relative pronoun or adverb (welke, die, dat, wat, wie, hoe, waar)
    'vrag'     => ['prontype' => 'int'], # interrogative pronoun or adverb (wat, wie, welke, welk, waar, dat, vanwaar)
    'aanw'     => ['prontype' => 'dem'], # demonstrative pronoun or adverb (deze, dit, die, dat, zo, nu, dan, daar, daardoor)
    'onbep'    => ['prontype' => 'ind'], # indefinite pronoun, numeral or adverb (geen, andere, alle, enkele, wat, minst, meest, nooit, ooit)
    'er'       => ['subpos' => 'ex'], # the adverb 'er' (existential 'there'?)
    # definiteness of articles (definiteness = 'ind') and numerals (prontype = 'ind')
    'bep'   => ['definiteness' => 'def'], # (het, der, de, des, den)
    'onbep' => ['definiteness' => 'ind', 'prontype' => 'ind'], # (een)
    # gender of articles
    'zijd'         => ['gender' => 'com'], # non-neuter (den)
    'zijdofmv'     => [], # non-neuter gender or plural (de, der)
    'onzijd'       => ['gender' => 'neut'], # neuter (het)
    'zijdofonzijd' => ['number' => 'sing'], # both genders possible (des, een)
    # case of articles, pronouns and nouns
    'neut' => [], # no case (i.e. nominative or a word that does not take case markings) (het, de, een)
    'nom'  => ['case' => 'nom'], # nominative (only pronouns: ik, we, wij, u, je, jij, jullie, ze, zij, hij, het, ie, zijzelf)
    'gen'  => ['case' => 'gen'], # genitive (der, des)
    'dat'  => ['case' => 'dat'], # dative (den)
    'datofacc' => ['case' => ['dat', 'acc']], # dative or accusative (only pronouns: me, mij, ons, je, jou, jullie, ze, hem, haar, het, haarzelf, hen, hun)
    'acc'  => ['case' => 'acc'], # accusative (not found in corpus (only 'datofacc'))
    # conjunction type
    'neven' => ['subpos' => 'coor'], # coordinating (en, maar, of)
    'onder' => ['subpos' => 'sub'], # subordinating (dat, als, dan, om, zonder, door)
    # subordinating conjunction type
    'metfin' => [], # followed by a finite clause (dat, als, dan, omdat)
    'metinf' => [], # followed by an infinite clause (om, zonder, door, teneinde)
    # noun type
    'soort' => [], # common noun is the default type of noun (jaar, heer, land, plaats, tijd)
    'eigen' => ['subpos' => 'prop'], # proper noun (Nederland, Amsterdam, zaterdag, Groningen, Rotterdam)
    # number
    'ev' => ['number' => 'sing'], # enkelvoud (jaar, heer, land, plaats, tijd)
    'mv' => ['number' => 'plu'], # meervoud (mensen, kinderen, jaren, problemen, landen)
    'evofmv' => [], # singular undistinguishable from plural (pronouns: ze, zij, zich, zichzelf)
    # numeral type
    'hoofd' => ['numtype' => 'card'], # hoofdtelwoord (twee, 1969, beider, minst, veel)
    'rang'  => ['numtype' => 'ord'], # rangtelwoord (eerste, tweede, derde, vierde, vijfde)
    # miscellaneous type
    'afkort'  => ['abbr' => 'abbr'], # abbreviation
    'vreemd'  => ['foreign' => 'foreign'], # foreign expression
    'symbool' => ['pos' => 'punc', 'punctype' => 'symb'], # symbol not included in Punc
    # adposition type
    'voor'    => [], # true preposition (voorzetsel) (van, in, op, met, voor)
    'achter'  => ['subpos' => 'post'], # postposition (achterzetsel) (in, incluis, op)
    'comb'    => ['subpos' => 'circ'], # second part of combined (split) preposition (toe, heen, af, in, uit) [van het begin af / from the beginning on: van/voor, af/comb]
    'voorinf' => ['subpos' => 'inf'], # infinitive marker (te)
    # pronoun type
    'per'   => ['prontype' => 'prs'], # persoonlijk (me, ik, ons, we, je, u, jullie, ze, hem, hij, hen)
    'bez'   => ['prontype' => 'prs', 'poss' => 'poss'], # beztittelijk (mijn, onze, je, jullie, zijner, zijn, hun)
    'ref'   => ['prontype' => 'prs', 'reflex' => 'reflex'], # reflexief (me, mezelf, mij, ons, onszelf, je, jezelf, zich, zichzelf)
    'rec'   => ['prontype' => 'rcp'], # reciprook (elkaar, elkaars)
    'aanw'  => ['prontype' => 'dem'], # aanwijzend (deze, dit, die, dat)
    'betr'  => ['prontype' => 'rel'], # betrekkelijk (welk, die, dat, wat, wie)
    'vrag'  => ['prontype' => 'int'], # vragend (wie, wat, welke, welk)
    'onbep' => ['prontype' => 'ind'], # onbepaald (geen, andere, alle, enkele, wat)
    # pronoun or verb person
    '1' => ['person' => 1], # (mijn, onze, ons, me, mij, ik, we, mezelf, onszelf)
    '2' => ['person' => 2], # (je, uw, jouw, jullie, jou, u, je, jij, jezelf)
    '3' => ['person' => 3], # (zijner, zijn, haar, zijnen, zijne, hun, ze, zij, hem, het, hij, ie, zijzelf, zich, zichzelf)
    '1of2of3' => [], # person not marked; applies only to verbs in imperfect past (was, werd, heette; waren, werden, bleven) and plural imperfect present (zijn, worden, blijven)
    # special pronouns
    'weigen' => [], # eigen = own (eigen)
    'wzelf'  => [], # zelf = self (zelf, zelve, haarzelve)
    # punctuation type
    'aanhaaldubb' => ['punctype' => 'quot'], # "
    'aanhaalenk'  => ['punctype' => 'quot'], # '
    'dubbpunt'    => ['punctype' => 'colo'], # :
    'en'          => ['punctype' => 'symb'], # &
    'gedstreep'   => ['punctype' => 'dash'], # -
    'haakopen'    => ['punctype' => 'brck', 'puncside' => 'ini'], # (
    'haaksluit'   => ['punctype' => 'brck', 'puncside' => 'fin'], # )
    'isgelijk'    => ['punctype' => 'symb'], # =
    'komma'       => ['punctype' => 'comm'], # ,
    'liggstreep'  => ['punctype' => 'symb'], # -, _
    'maal'        => ['punctype' => 'symb'], # x
    'plus'        => ['punctype' => 'symb'], # +
    'punt'        => ['punctype' => 'peri'], # .
    'puntkomma'   => ['punctype' => 'semi'], # ;
    'schuinstreep'=> ['punctype' => 'symb'], # /
    'uitroep'     => ['punctype' => 'excl'], # !
    'vraag'       => ['punctype' => 'qest'], # ?
    # verb type
    'trans'      => ['subcat' => 'tran'], # transitive (maken, zien, doen, nemen, geven)
    'refl'       => ['reflex' => 'reflex'], # reflexive (verzetten, ontwikkelen, voelen, optrekken, concentreren)
    'intrans'    => ['subcat' => 'intr'], # intransitive (komen, gaan, staan, vertrekken, spelen)
    'hulp'       => ['subpos' => 'mod'], # auxiliary / modal (kunnen, moeten, hebben, gaan, laten)
    'hulpofkopp' => ['subpos' => ['aux', 'cop']], # auxiliary or copula (worden, zijn, blijven, komen, wezen)
    # verb form, mood, tense and aspect
    'ott'    => ['verbform' => 'fin', 'mood' => 'ind', 'aspect' => 'imp', 'tense' => 'pres'], # (komt, heet, gaat, ligt, staat)
    'ovt'    => ['verbform' => 'fin', 'mood' => 'ind', 'aspect' => 'imp', 'tense' => 'past'], # (kwam, ging, stond, viel, won)
    'tegdw'  => ['verbform' => 'part', 'tense' => 'pres'], # (volgend, verrassend, bevredigend, vervelend, aanvallend)
    'verldw' => ['verbform' => 'part', 'tense' => 'past'], # (afgelopen, gekomen, gegaan, gebeurd, begonnen)
    'inf'    => ['verbform' => 'inf'], # (komen, gaan, staan, vertrekken, spelen)
    'conj'   => ['verbform' => 'fin', 'mood' => 'sub'], # (leve, ware, inslape, oordele, zegge)
    'imp'    => ['verbform' => 'fin', 'mood' => 'imp'], # (kijk, kom, ga, denk, wacht)
    # substantival usage of verb infinitive
    'subst' => ['synpos' => 'subst'], # (worden, zijn, optreden, streven, dringen, maken, bereiken)
);



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f = ( tagset => 'nl::conll' );
    # three components: coarse-grained pos, fine-grained pos, features
    my ($pos, $subpos, $features) = split(/\s/, $tag);
    my @features = split(/\|/, $features);
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
