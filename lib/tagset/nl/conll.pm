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
Adj	Adj	adv|stell|onverv
Adj	Adj	adv|stell|vervneut
Adj	Adj	adv|vergr|onverv
Adj	Adj	adv|vergr|vervneut
Adj	Adj	attr|overtr|onverv
Adj	Adj	attr|overtr|vervneut
Adj	Adj	attr|stell|onverv
Adj	Adj	attr|stell|vervgen
Adj	Adj	attr|stell|vervneut
Adj	Adj	attr|vergr|onverv
Adj	Adj	attr|vergr|vervgen
Adj	Adj	attr|vergr|vervneut
Adj	Adj	zelfst|overtr|vervneut
Adj	Adj	zelfst|stell|onverv
Adj	Adj	zelfst|stell|vervmv
Adj	Adj	zelfst|stell|vervneut
Adj	Adj	zelfst|vergr|vervneut
Adv	Adv	deeladv
Adv	Adv	deelv
Adv	Adv	gew|aanw
Adv	Adv	gew|betr
Adv	Adv	gew|er
Adv	Adv	gew|geenfunc|overtr|onverv
Adv	Adv	gew|geenfunc|stell|onverv
Adv	Adv	gew|geenfunc|vergr|onverv
Adv	Adv	gew|onbep
Adv	Adv	gew|vrag
Adv	Adv	pron|aanw
Adv	Adv	pron|betr
Adv	Adv	pron|er
Adv	Adv	pron|onbep
Adv	Adv	pron|vrag
Art	Art	bep|onzijd|neut
Art	Art	bep|zijdofmv|gen
Art	Art	bep|zijdofmv|neut
Art	Art	bep|zijdofonzijd|gen
Art	Art	bep|zijd|dat
Art	Art	onbep|zijdofonzijd|neut
Conj	Conj	neven
Conj	Conj	onder|metfin
Conj	Conj	onder|metinf
Int	Int	_
MWU	Adj_Adj	adv|vergr|onverv_adv|stell|onverv
MWU	Adj_Adj	attr|stell|onverv_attr|stell|onverv
MWU	Adj_Adj	attr|stell|vervneut_attr|stell|onverv
MWU	Adj_Adj	attr|stell|vervneut_zelfst|stell|vervneut
MWU	Adj_Adj_N	adv|stell|onverv_attr|stell|onverv_soort|mv|neut
MWU	Adj_Adj_N	attr|stell|onverv_attr|stell|onverv_eigen|ev|neut
MWU	Adj_Adj_N	attr|stell|vervneut_attr|stell|vervneut_eigen|ev|neut
MWU	Adj_Adj_N	attr|stell|vervneut_attr|stell|vervneut_soort|ev|neut
MWU	Adj_Adj_N_Adj_N_N	attr|stell|vervneut_attr|stell|vervneut_soort|ev|neut_attr|stell|vervneut_soort|ev|neut_eigen|ev|neut
MWU	Adj_Adj_N_N	attr|stell|onverv_attr|stell|onverv_soort|ev|neut_eigen|ev|neut
MWU	Adj_Adv	adv|stell|onverv_deelv
MWU	Adj_Adv	adv|stell|onverv_gew|geenfunc|stell|onverv
MWU	Adj_Adv	adv|vergr|onverv_gew|geenfunc|stell|onverv
MWU	Adj_Art	adv|stell|onverv_onbep|zijdofonzijd|neut
MWU	Adj_Art	attr|stell|onverv_onbep|zijdofonzijd|neut
MWU	Adj_Conj_V	attr|stell|vervneut_neven_trans|conj
MWU	Adj_Int	attr|stell|vervneut
MWU	Adj_Misc_Misc	attr|stell|onverv_vreemd_vreemd
MWU	Adj_N	adv|stell|onverv_eigen|ev|neut
MWU	Adj_N	adv|stell|onverv_soort|ev|neut
MWU	Adj_N	attr|stell|onverv_eigen|ev|neut
MWU	Adj_N	attr|stell|onverv_soort|ev|neut
MWU	Adj_N	attr|stell|onverv_soort|mv|neut
MWU	Adj_N	attr|stell|vervneut_eigen|ev|neut
MWU	Adj_N	attr|stell|vervneut_soort|ev|neut
MWU	Adj_N	attr|stell|vervneut_soort|mv|neut
MWU	Adj_N_Conj_N	attr|stell|vervneut_soort|ev|neut_neven_soort|ev|neut
MWU	Adj_N_N	adv|stell|onverv_eigen|ev|neut_eigen|ev|neut
MWU	Adj_N_N	attr|stell|onverv_eigen|ev|neut_eigen|ev|neut
MWU	Adj_N_N	attr|stell|onverv_soort|ev|neut_eigen|ev|neut
MWU	Adj_N_N	attr|stell|onverv_soort|ev|neut_soort|ev|neut
MWU	Adj_N_N	attr|stell|vervneut_eigen|ev|neut_eigen|ev|neut
MWU	Adj_N_N	attr|stell|vervneut_soort|ev|neut_eigen|ev|neut
MWU	Adj_N_N	zelfst|stell|onverv_eigen|ev|neut_eigen|ev|neut
MWU	Adj_N_N_N	attr|stell|onverv_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	Adj_N_N_N_N	attr|stell|onverv_soort|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	Adj_N_N_N_N_N	attr|stell|vervneut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	Adj_N_Num	attr|stell|onverv_soort|ev|neut_hoofd|bep|attr|onverv
MWU	Adj_N_Prep_Art_Adj_N	attr|stell|vervneut_soort|ev|neut_voor_bep|onzijd|neut_attr|stell|vervneut_soort|ev|neut
MWU	Adj_N_Prep_Art_N	attr|stell|vervneut_soort|ev|neut_voor_bep|zijdofmv|neut_eigen|ev|neut
MWU	Adj_N_Prep_N	attr|stell|vervneut_eigen|ev|neut_voor_eigen|ev|neut
MWU	Adj_N_Prep_N	attr|stell|vervneut_soort|ev|neut_voor_eigen|ev|neut
MWU	Adj_N_Prep_N_Conj_N	attr|stell|vervneut_soort|ev|neut_voor_eigen|ev|neut_neven_eigen|ev|neut
MWU	Adj_N_Prep_N_N	attr|stell|vervneut_soort|mv|neut_voor_eigen|ev|neut_eigen|ev|neut
MWU	Adj_N_Punc	attr|stell|vervneut_soort|ev|neut_punt
MWU	Adj_Num	adv|stell|onverv_hoofd|bep|attr|onverv
MWU	Adj_Num	attr|stell|onverv_hoofd|bep|attr|onverv
MWU	Adj_Num	attr|stell|onverv_hoofd|bep|zelfst|onverv
MWU	Adj_Prep	adv|stell|vervneut_voor
MWU	Adj_Prep	adv|vergr|onverv_voor
MWU	Adj_V	adv|stell|onverv_intrans|inf
MWU	Adj_V	adv|stell|onverv_trans|imp
MWU	Adj_V	attr|stell|vervneut_intrans|inf
MWU	Adj_V_Conj_V	attr|stell|vervneut_intrans|inf|subst_neven_intrans|inf|subst
MWU	Adj_V_N	attr|stell|vervneut_trans|verldw|vervneut_soort|ev|neut
MWU	Adv_Adj	gew|geenfunc|stell|onverv_adv|vergr|onverv
MWU	Adv_Adj	gew|geenfunc|stell|onverv_attr|stell|onverv
MWU	Adv_Adj_Conj	gew|aanw_adv|stell|onverv_onder|metfin
MWU	Adv_Adv	gew|aanw_gew|geenfunc|stell|onverv
MWU	Adv_Adv	gew|geenfunc|stell|onverv_deelv
MWU	Adv_Adv	gew|geenfunc|stell|onverv_gew|geenfunc|stell|onverv
MWU	Adv_Adv	gew|geenfunc|stell|onverv_pron|aanw
MWU	Adv_Adv	pron|vrag_deeladv
MWU	Adv_Adv_Conj_Adv	gew|aanw_gew|aanw_neven_gew|aanw
MWU	Adv_Art	gew|betr_onbep|zijdofonzijd|neut
MWU	Adv_Art	gew|geenfunc|stell|onverv_onbep|zijdofonzijd|neut
MWU	Adv_Conj	gew|geenfunc|stell|onverv_onder|metinf
MWU	Adv_Conj_Adv	deelv_neven_gew|geenfunc|stell|onverv
MWU	Adv_Conj_Adv	gew|aanw_neven_gew|aanw
MWU	Adv_Conj_Adv	gew|geenfunc|stell|onverv_neven_gew|geenfunc|stell|onverv
MWU	Adv_Conj_Adv	gew|onbep_neven_gew|onbep
MWU	Adv_Conj_N	gew|geenfunc|stell|onverv_neven_soort|ev|neut
MWU	Adv_N	gew|aanw_soort|ev|neut
MWU	Adv_N	gew|geenfunc|stell|onverv_eigen|ev|neut
MWU	Adv_Num	gew|betr_hoofd|onbep|zelfst|vergr|onverv
MWU	Adv_Num	gew|geenfunc|stell|onverv_hoofd|onbep|zelfst|vergr|onverv
MWU	Adv_Prep	gew|aanw_voor
MWU	Adv_Prep	gew|geenfunc|stell|onverv_voor
MWU	Adv_Prep_N	gew|geenfunc|stell|onverv_voor_soort|ev|dat
MWU	Adv_Prep_Pron	gew|geenfunc|stell|onverv_voor_onbep|neut|zelfst
MWU	Adv_Pron	gew|geenfunc|stell|onverv_onbep|neut|attr
MWU	Adv_V	deeladv_intrans|ovt|1of2of3|ev
MWU	Art_Adj	bep|onzijd|neut_adv|vergr|onverv
MWU	Art_Adj	bep|onzijd|neut_adv|vergr|vervneut
MWU	Art_Adj	bep|onzijd|neut_attr|overtr|onverv
MWU	Art_Adj	bep|onzijd|neut_attr|overtr|vervneut
MWU	Art_Adj	bep|onzijd|neut_zelfst|overtr|vervneut
MWU	Art_Adj_N	bep|onzijd|neut_attr|overtr|vervneut_soort|ev|neut
MWU	Art_Adj_N	bep|zijdofmv|neut_attr|stell|vervneut_soort|ev|neut
MWU	Art_Adj_N_Prep_Art_N_Conj_V_N	bep|zijdofmv|neut_attr|stell|vervneut_eigen|ev|neut_voor_bep|onzijd|neut_soort|ev|neut_neven_intrans|tegdw|vervneut_soort|ev|neut
MWU	Art_Adv	bep|onzijd|neut_gew|geenfunc|overtr|onverv
MWU	Art_Conj_Pron	onbep|zijdofonzijd|neut_neven_onbep|neut|attr
MWU	Art_Conj_Pron	onbep|zijdofonzijd|neut_neven_onbep|neut|zelfst
MWU	Art_N	bep|onzijd|neut_eigen|ev|neut
MWU	Art_N	bep|onzijd|neut_soort|ev|neut
MWU	Art_N	bep|zijdofmv|neut_eigen|ev|neut
MWU	Art_N	bep|zijdofmv|neut_soort|ev|neut
MWU	Art_N	bep|zijdofmv|neut_soort|mv|neut
MWU	Art_N	bep|zijdofonzijd|gen_soort|ev|gen
MWU	Art_N	onbep|zijdofonzijd|neut_soort|ev|neut
MWU	Art_N_Conj	onbep|zijdofonzijd|neut_soort|ev|neut_neven
MWU	Art_N_Conj_Art_N	bep|onzijd|neut_soort|ev|neut_neven_bep|onzijd|neut_soort|ev|neut
MWU	Art_N_Conj_Art_V	bep|zijdofmv|neut_soort|ev|neut_neven_bep|zijdofmv|neut_trans|verldw|onverv
MWU	Art_N_Conj_Pron_N	bep|onzijd|neut_soort|ev|neut_neven_bez|3|ev|neut|attr_soort|mv|neut
MWU	Art_N_N	bep|zijdofmv|neut_eigen|ev|neut_eigen|ev|neut
MWU	Art_N_Prep_Adj	onbep|zijdofonzijd|neut_soort|ev|neut_voor_attr|stell|onverv
MWU	Art_N_Prep_Art_N	onbep|zijdofonzijd|neut_soort|ev|neut_voor_bep|zijdofmv|neut_soort|ev|neut
MWU	Art_N_Prep_N	bep|onzijd|neut_soort|ev|neut_voor_eigen|ev|neut
MWU	Art_N_Prep_N	bep|zijdofmv|neut_soort|ev|neut_voor_eigen|ev|neut
MWU	Art_N_Prep_N	onbep|zijdofonzijd|neut_soort|ev|neut_voor_eigen|ev|neut
MWU	Art_N_Prep_Pron_N	bep|zijdofmv|neut_soort|ev|neut_voor_bez|1|ev|neut|attr_soort|ev|neut
MWU	Art_N_Prep_Pron_N	bep|zijdofmv|neut_soort|ev|neut_voor_bez|1|mv|neut|attr_soort|ev|neut
MWU	Art_Num	bep|onzijd|neut_hoofd|onbep|attr|overtr|onverv
MWU	Art_Num	bep|onzijd|neut_hoofd|onbep|zelfst|overtr|onverv
MWU	Art_Num	bep|onzijd|neut_rang|bep|zelfst|onverv
MWU	Art_Num	onbep|zijdofonzijd|neut_hoofd|onbep|zelfst|stell|onverv
MWU	Art_Num_Art_Adj	bep|zijdofmv|neut_rang|bep|attr|onverv_bep|zijdofmv|neut_attr|overtr|vervneut
MWU	Art_Num_N	bep|zijdofmv|neut_rang|bep|attr|onverv_eigen|ev|neut
MWU	Art_Pron	onbep|zijdofonzijd|neut_onbep|neut|zelfst
MWU	Art_Pron_N	onbep|zijdofonzijd|neut_aanw|gen|attr_soort|mv|neut
MWU	Art_V_N	bep|zijdofmv|neut_intrans|tegdw|vervneut_soort|ev|neut
MWU	Conj_Adj	neven_adv|vergr|onverv
MWU	Conj_Adj	neven_attr|stell|onverv
MWU	Conj_Adv	neven_gew|aanw
MWU	Conj_Adv	neven_gew|geenfunc|stell|onverv
MWU	Conj_Adv	onder|metfin_gew|geenfunc|stell|onverv
MWU	Conj_Adv_Adv	neven_gew|aanw_gew|geenfunc|stell|onverv
MWU	Conj_Art_N	onder|metfin_bep|zijdofmv|neut_soort|ev|neut
MWU	Conj_Art_N	onder|metinf_bep|onzijd|neut_soort|ev|neut
MWU	Conj_Conj	neven_onder|metfin
MWU	Conj_Int	neven
MWU	Conj_Int	onder|metfin
MWU	Conj_N	onder|metfin_soort|ev|neut
MWU	Conj_N_Adv	onder|metfin_soort|ev|neut_pron|aanw
MWU	Conj_N_Prep	onder|metfin_soort|ev|neut_voor
MWU	Conj_Pron	neven_aanw|neut|zelfst
MWU	Conj_Pron_Adv	onder|metinf_per|3|ev|datofacc_gew|geenfunc|stell|onverv
MWU	Conj_Pron_V	onder|metfin_onbep|neut|zelfst_hulpofkopp|conj
MWU	Conj_Pron_V	onder|metfin_onbep|neut|zelfst_intrans|conj
MWU	Conj_Punc_Conj	neven_schuinstreep_neven
MWU	Conj_V	onder|metfin_intrans|ott|3|ev
MWU	Int_Adv	gew|aanw
MWU	Int_Adv	gew|geenfunc|stell|onverv
MWU	Int_Int	_
MWU	Int_N_N_Misc_N	eigen|ev|neut_eigen|ev|neut_vreemd_eigen|ev|neut
MWU	Int_N_Punc_Int_N	soort|ev|neut_komma_soort|ev|neut
MWU	Int_Punc_Int	komma
MWU	Misc_Misc	vreemd_vreemd
MWU	Misc_Misc_Misc	vreemd_vreemd_vreemd
MWU	Misc_Misc_Misc_Misc	vreemd_vreemd_vreemd_vreemd
MWU	Misc_Misc_Misc_Misc_Misc_Misc	vreemd_vreemd_vreemd_vreemd_vreemd_vreemd
MWU	Misc_Misc_Misc_Misc_Misc_Misc_Misc	vreemd_vreemd_vreemd_vreemd_vreemd_vreemd_vreemd
MWU	Misc_Misc_Misc_Misc_Misc_Misc_Misc_Misc_Misc	vreemd_vreemd_vreemd_vreemd_vreemd_vreemd_vreemd_vreemd_vreemd
MWU	Misc_Misc_Misc_Misc_Misc_Misc_Punc_Misc_Misc_Misc	vreemd_vreemd_vreemd_vreemd_vreemd_vreemd_komma_vreemd_vreemd_vreemd
MWU	Misc_Misc_Misc_Misc_Misc_N_Misc_Misc_Misc_Misc_Misc_Misc	vreemd_vreemd_vreemd_vreemd_vreemd_eigen|ev|neut_vreemd_vreemd_vreemd_vreemd_vreemd_vreemd
MWU	Misc_Misc_Misc_N	vreemd_vreemd_vreemd_eigen|ev|neut
MWU	Misc_Misc_Misc_N	vreemd_vreemd_vreemd_soort|ev|neut
MWU	Misc_Misc_N	vreemd_vreemd_soort|mv|neut
MWU	Misc_Misc_N_N	vreemd_vreemd_eigen|ev|neut_eigen|ev|neut
MWU	Misc_Misc_N_N	vreemd_vreemd_eigen|ev|neut_soort|ev|neut
MWU	Misc_Misc_Punc_N_N	vreemd_vreemd_aanhaalenk_eigen|ev|neut_eigen|ev|neut
MWU	Misc_N	vreemd_eigen|ev|neut
MWU	Misc_N	vreemd_soort|ev|neut
MWU	Misc_N_Misc_Misc	vreemd_eigen|ev|neut_vreemd_vreemd
MWU	Misc_N_N	vreemd_eigen|ev|neut_eigen|ev|neut
MWU	Misc_N_N	vreemd_soort|ev|neut_soort|ev|neut
MWU	N_Adj	eigen|ev|neut_adv|stell|onverv
MWU	N_Adj	eigen|ev|neut_attr|stell|onverv
MWU	N_Adj	eigen|ev|neut_attr|stell|vervneut
MWU	N_Adj	soort|ev|neut_adv|stell|onverv
MWU	N_Adj	soort|ev|neut_attr|stell|onverv
MWU	N_Adj	soort|ev|neut_attr|stell|vervneut
MWU	N_Adj	soort|mv|neut_attr|stell|onverv
MWU	N_Adj	soort|mv|neut_attr|stell|vervneut
MWU	N_Adj_N	eigen|ev|neut_zelfst|vergr|vervneut_eigen|ev|neut
MWU	N_Adj_N	soort|ev|neut_attr|stell|vervneut_soort|mv|neut
MWU	N_Adj_N_Num	soort|ev|neut_attr|stell|onverv_soort|ev|neut_hoofd|bep|zelfst|onverv
MWU	N_Adv	eigen|ev|neut_gew|geenfunc|stell|onverv
MWU	N_Adv	soort|ev|neut_deelv
MWU	N_Adv	soort|ev|neut_gew|geenfunc|stell|onverv
MWU	N_Adv_Punc_V_Pron_V	soort|ev|neut_gew|geenfunc|stell|onverv_komma_hulp|ott|2|ev_onbep|neut|zelfst_intrans|inf
MWU	N_Art_Adj_Prep_N	eigen|ev|neut_bep|zijdofmv|neut_attr|vergr|vervneut_voor_eigen|ev|neut
MWU	N_Art_N	eigen|ev|neut_bep|zijdofmv|gen_soort|mv|neut
MWU	N_Art_N	eigen|ev|neut_bep|zijdofmv|neut_eigen|ev|neut
MWU	N_Art_N	eigen|ev|neut_bep|zijdofmv|neut_eigen|mv|neut
MWU	N_Art_N	soort|ev|neut_bep|zijdofmv|neut_soort|ev|neut
MWU	N_Art_N	soort|ev|neut_bep|zijdofmv|neut_soort|mv|neut
MWU	N_Art_N	soort|ev|neut_bep|zijdofonzijd|gen_soort|ev|gen
MWU	N_Art_N	soort|ev|neut_onbep|zijdofonzijd|neut_soort|ev|neut
MWU	N_Conj	soort|ev|neut_neven
MWU	N_Conj_Adv	soort|ev|neut_neven_gew|geenfunc|stell|onverv
MWU	N_Conj_Art_N	eigen|ev|neut_neven_bep|zijdofmv|neut_eigen|ev|neut
MWU	N_Conj_Art_N	eigen|ev|neut_neven_bep|zijdofmv|neut_soort|mv|neut
MWU	N_Conj_Art_N	eigen|ev|neut_neven_onbep|zijdofonzijd|neut_soort|ev|neut
MWU	N_Conj_Art_N	soort|ev|neut_onder|metinf_bep|zijdofmv|neut_soort|ev|neut
MWU	N_Conj_N	eigen|ev|neut_neven_eigen|ev|neut
MWU	N_Conj_N	eigen|ev|neut_neven_eigen|mv|neut
MWU	N_Conj_N	soort|ev|neut_neven_soort|ev|neut
MWU	N_Conj_N	soort|ev|neut_neven_soort|mv|neut
MWU	N_Conj_N	soort|mv|neut_neven_soort|mv|neut
MWU	N_Conj_N_N	eigen|ev|neut_neven_eigen|ev|neut_eigen|ev|neut
MWU	N_Conj_N_N	soort|ev|neut_neven_eigen|ev|neut_eigen|ev|neut
MWU	N_Int_N	eigen|ev|neut_eigen|ev|neut
MWU	N_Misc	eigen|ev|neut_vreemd
MWU	N_Misc	soort|ev|neut_vreemd
MWU	N_Misc_Misc	eigen|ev|neut_vreemd_vreemd
MWU	N_Misc_Misc	soort|mv|neut_vreemd_vreemd
MWU	N_Misc_Misc_Misc_Misc	eigen|ev|neut_vreemd_vreemd_vreemd_vreemd
MWU	N_Misc_Misc_N	eigen|ev|neut_vreemd_vreemd_eigen|ev|neut
MWU	N_Misc_N	eigen|ev|neut_vreemd_eigen|ev|neut
MWU	N_Misc_N	soort|ev|neut_vreemd_soort|ev|neut
MWU	N_Misc_N_N	eigen|ev|neut_vreemd_eigen|ev|neut_eigen|ev|neut
MWU	N_Misc_N_N_N_N	eigen|ev|neut_vreemd_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_Misc_Num	eigen|ev|neut_vreemd_hoofd|bep|attr|onverv
MWU	N_N	eigen|ev|gen_eigen|ev|gen
MWU	N_N	eigen|ev|gen_eigen|ev|neut
MWU	N_N	eigen|ev|gen_soort|ev|neut
MWU	N_N	eigen|ev|gen_soort|mv|neut
MWU	N_N	eigen|ev|neut_eigen|ev|gen
MWU	N_N	eigen|ev|neut_eigen|ev|neut
MWU	N_N	eigen|ev|neut_eigen|mv|neut
MWU	N_N	eigen|ev|neut_soort|ev|neut
MWU	N_N	eigen|ev|neut_soort|mv|neut
MWU	N_N	eigen|mv|neut_eigen|mv|neut
MWU	N_N	soort|ev|neut_eigen|ev|neut
MWU	N_N	soort|ev|neut_soort|ev|neut
MWU	N_N	soort|ev|neut_soort|mv|neut
MWU	N_N	soort|mv|neut_eigen|ev|neut
MWU	N_N	soort|mv|neut_soort|ev|neut
MWU	N_N	soort|mv|neut_soort|mv|neut
MWU	N_N_Adj	eigen|ev|neut_eigen|ev|neut_attr|stell|onverv
MWU	N_N_Adj	soort|ev|neut_soort|ev|neut_attr|stell|onverv
MWU	N_N_Adj_Art_N_N	eigen|ev|neut_eigen|ev|neut_adv|stell|onverv_bep|zijdofmv|neut_soort|ev|neut_soort|ev|neut
MWU	N_N_Adj_N	eigen|ev|neut_eigen|ev|neut_attr|stell|vervneut_eigen|ev|neut
MWU	N_N_Adv	soort|ev|neut_eigen|ev|neut_gew|aanw
MWU	N_N_Art_Adv	eigen|ev|neut_eigen|ev|neut_bep|zijdofonzijd|gen_gew|geenfunc|stell|onverv
MWU	N_N_Art_N	eigen|ev|neut_eigen|ev|neut_bep|onzijd|neut_eigen|ev|neut
MWU	N_N_Art_N	eigen|ev|neut_eigen|ev|neut_bep|onzijd|neut_soort|ev|neut
MWU	N_N_Art_N	eigen|ev|neut_eigen|ev|neut_bep|zijdofmv|neut_eigen|ev|neut
MWU	N_N_Conj	eigen|ev|neut_eigen|ev|neut_onder|metfin
MWU	N_N_Conj_N	eigen|ev|neut_eigen|ev|neut_neven_eigen|ev|neut
MWU	N_N_Conj_N	soort|mv|neut_soort|mv|neut_neven_soort|ev|neut
MWU	N_N_Conj_N_N	eigen|ev|neut_eigen|ev|neut_neven_eigen|ev|neut_eigen|ev|neut
MWU	N_N_Conj_N_N_N_N_N	eigen|ev|neut_eigen|ev|neut_neven_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_N_Int_N_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_N_Misc	eigen|ev|neut_eigen|ev|neut_vreemd
MWU	N_N_Misc_Misc_Misc	eigen|ev|neut_eigen|ev|neut_vreemd_vreemd_vreemd
MWU	N_N_N	eigen|ev|gen_eigen|ev|neut_eigen|ev|neut
MWU	N_N_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_N_N	eigen|ev|neut_eigen|ev|neut_eigen|mv|neut
MWU	N_N_N	eigen|ev|neut_eigen|ev|neut_soort|ev|dat
MWU	N_N_N	eigen|ev|neut_eigen|ev|neut_soort|ev|neut
MWU	N_N_N	eigen|ev|neut_eigen|ev|neut_soort|mv|neut
MWU	N_N_N	eigen|ev|neut_soort|ev|neut_eigen|ev|neut
MWU	N_N_N	eigen|ev|neut_soort|ev|neut_soort|ev|neut
MWU	N_N_N	eigen|mv|neut_eigen|mv|neut_eigen|ev|neut
MWU	N_N_N	eigen|mv|neut_eigen|mv|neut_eigen|mv|neut
MWU	N_N_N	soort|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_N_N	soort|ev|neut_eigen|ev|neut_soort|ev|neut
MWU	N_N_N	soort|ev|neut_soort|ev|neut_eigen|ev|neut
MWU	N_N_N	soort|ev|neut_soort|ev|neut_soort|ev|neut
MWU	N_N_N	soort|mv|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_N_N	soort|mv|neut_soort|ev|neut_eigen|ev|neut
MWU	N_N_N	soort|mv|neut_soort|mv|neut_soort|mv|neut
MWU	N_N_N_Adj_N	eigen|ev|neut_eigen|ev|neut_soort|mv|neut_adv|stell|onverv_soort|ev|neut
MWU	N_N_N_Adv	eigen|ev|neut_eigen|ev|neut_soort|ev|neut_gew|geenfunc|stell|onverv
MWU	N_N_N_Conj_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_neven_eigen|ev|neut
MWU	N_N_N_Int	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_N_N_Misc	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_vreemd
MWU	N_N_N_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_N_N_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_soort|ev|neut
MWU	N_N_N_N	eigen|ev|neut_eigen|ev|neut_soort|ev|neut_eigen|ev|neut
MWU	N_N_N_N	eigen|ev|neut_soort|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_N_N_N	eigen|mv|neut_soort|mv|neut_eigen|mv|neut_eigen|mv|neut
MWU	N_N_N_N	soort|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_N_N_N	soort|mv|neut_soort|ev|gen_soort|ev|neut_soort|mv|neut
MWU	N_N_N_N_Conj_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_neven_soort|ev|neut
MWU	N_N_N_N_Misc	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_vreemd
MWU	N_N_N_N_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_N_N_N_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_soort|ev|neut
MWU	N_N_N_N_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_soort|ev|neut_eigen|ev|neut
MWU	N_N_N_N_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_soort|mv|neut_soort|mv|neut
MWU	N_N_N_N_N	eigen|ev|neut_soort|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_N_N_N_N	soort|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_N_N_N_N_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_N_N_N_N_N_Int	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_N_N_N_N_N_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_N_N_N_N_N_N	eigen|ev|neut_soort|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_N_N_N_N_N_Prep_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_voor_eigen|ev|neut
MWU	N_N_N_N_N_Prep_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_voor_eigen|ev|neut
MWU	N_N_N_N_Prep_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_voor_eigen|ev|neut
MWU	N_N_N_N_Punc_N_Punc	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_aanhaaldubb_eigen|ev|neut_aanhaaldubb
MWU	N_N_N_N_V	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_hulp|ovt|1of2of3|ev
MWU	N_N_N_Prep_Art_Adj_N	eigen|ev|neut_eigen|ev|neut_soort|ev|neut_voor_onbep|zijdofonzijd|neut_attr|stell|onverv_soort|ev|neut
MWU	N_N_N_Prep_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_voor_soort|ev|neut
MWU	N_N_N_Prep_N	eigen|ev|neut_eigen|ev|neut_soort|ev|neut_voor_eigen|ev|neut
MWU	N_N_N_Prep_N_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_voor_eigen|ev|neut_eigen|ev|neut
MWU	N_N_N_Punc	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_komma
MWU	N_N_N_Punc	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_punt
MWU	N_N_N_Punc_N	eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_komma_eigen|ev|neut
MWU	N_N_Num	eigen|ev|neut_eigen|ev|neut_hoofd|bep|attr|onverv
MWU	N_N_Num	eigen|ev|neut_eigen|ev|neut_hoofd|bep|zelfst|onverv
MWU	N_N_Num	soort|ev|neut_soort|ev|neut_hoofd|bep|attr|onverv
MWU	N_N_Num_N	eigen|ev|neut_eigen|ev|neut_hoofd|bep|attr|onverv_soort|ev|neut
MWU	N_N_Prep_Art_Adj_N	soort|ev|neut_soort|ev|neut_voor_bep|onzijd|neut_attr|stell|onverv_soort|ev|neut
MWU	N_N_Prep_Art_N	eigen|ev|neut_eigen|ev|neut_voor_bep|zijd|dat_eigen|ev|neut
MWU	N_N_Prep_Art_N_Prep_Art_N	eigen|ev|neut_eigen|ev|neut_voor_bep|zijdofmv|neut_soort|mv|neut_voor_bep|zijdofmv|neut_soort|ev|neut
MWU	N_N_Prep_N	eigen|ev|gen_soort|ev|neut_voor_eigen|ev|neut
MWU	N_N_Prep_N	eigen|ev|neut_eigen|ev|neut_voor_eigen|ev|neut
MWU	N_N_Prep_N	eigen|ev|neut_eigen|ev|neut_voor_soort|ev|neut
MWU	N_N_Prep_N	eigen|ev|neut_soort|ev|neut_voor_eigen|ev|neut
MWU	N_N_Prep_N	soort|mv|neut_soort|mv|neut_voor_eigen|ev|neut
MWU	N_N_Prep_N_N	eigen|ev|neut_eigen|ev|neut_voor_eigen|ev|neut_eigen|ev|neut
MWU	N_N_Prep_N_Prep_Adj_N	eigen|ev|neut_eigen|ev|neut_voor_eigen|ev|neut_voor_attr|stell|vervneut_soort|mv|neut
MWU	N_N_Punc_N_Punc	eigen|ev|neut_eigen|ev|neut_aanhaaldubb_eigen|ev|neut_aanhaaldubb
MWU	N_Num	eigen|ev|gen_rang|bep|zelfst|onverv
MWU	N_Num	eigen|ev|neut_hoofd|bep|attr|onverv
MWU	N_Num	eigen|ev|neut_hoofd|bep|zelfst|onverv
MWU	N_Num	soort|ev|neut_hoofd|bep|attr|onverv
MWU	N_Num	soort|ev|neut_hoofd|bep|zelfst|onverv
MWU	N_Num	soort|mv|neut_hoofd|bep|attr|onverv
MWU	N_Num_N	eigen|ev|neut_hoofd|bep|attr|onverv_eigen|ev|neut
MWU	N_Num_N	eigen|ev|neut_hoofd|bep|zelfst|onverv_eigen|ev|neut
MWU	N_Num_N_N	soort|ev|neut_hoofd|bep|attr|onverv_soort|mv|neut_soort|ev|neut
MWU	N_Num_N_Num	eigen|ev|neut_hoofd|bep|attr|onverv_eigen|ev|neut_hoofd|bep|zelfst|onverv
MWU	N_Num_Num	soort|ev|neut_hoofd|bep|attr|onverv_hoofd|bep|attr|onverv
MWU	N_Prep	soort|ev|neut_voor
MWU	N_Prep_Adj_Adj_N	soort|ev|neut_voor_attr|stell|vervneut_attr|stell|vervneut_soort|mv|neut
MWU	N_Prep_Adj_N	eigen|ev|neut_voor_attr|stell|vervneut_soort|mv|neut
MWU	N_Prep_Art_N	eigen|ev|neut_voor_bep|zijdofmv|neut_eigen|ev|neut
MWU	N_Prep_Art_N	eigen|ev|neut_voor_bep|zijdofmv|neut_soort|mv|neut
MWU	N_Prep_Art_N	eigen|ev|neut_voor_bep|zijd|dat_eigen|ev|neut
MWU	N_Prep_Art_N	soort|ev|neut_voor_bep|zijdofmv|neut_eigen|ev|neut
MWU	N_Prep_Art_N	soort|ev|neut_voor_bep|zijdofmv|neut_soort|ev|neut
MWU	N_Prep_Art_N	soort|ev|neut_voor_bep|zijdofmv|neut_soort|mv|neut
MWU	N_Prep_Art_N_Art_N	soort|ev|neut_voor_bep|zijdofmv|neut_soort|ev|neut_bep|zijdofmv|gen_soort|mv|neut
MWU	N_Prep_Art_N_N	soort|ev|neut_voor_bep|zijdofmv|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_Prep_Art_N_N	soort|ev|neut_voor_bep|zijdofmv|neut_soort|ev|neut_eigen|ev|neut
MWU	N_Prep_Art_N_Prep_Art_N	soort|ev|neut_voor_bep|onzijd|neut_soort|ev|neut_voor_bep|onzijd|neut_eigen|ev|neut
MWU	N_Prep_Art_N_Prep_Art_N	soort|ev|neut_voor_bep|zijdofmv|neut_soort|mv|neut_voor_bep|onzijd|neut_soort|ev|neut
MWU	N_Prep_N	eigen|ev|neut_voor_eigen|ev|neut
MWU	N_Prep_N	eigen|ev|neut_voor_soort|ev|neut
MWU	N_Prep_N	eigen|ev|neut_voor_soort|mv|neut
MWU	N_Prep_N	soort|ev|neut_voor_eigen|ev|neut
MWU	N_Prep_N	soort|ev|neut_voor_soort|ev|neut
MWU	N_Prep_N	soort|ev|neut_voor_soort|mv|neut
MWU	N_Prep_N	soort|mv|neut_voor_eigen|ev|neut
MWU	N_Prep_N_Art_Adj	eigen|ev|neut_voor_soort|ev|neut_bep|zijdofmv|neut_attr|stell|onverv
MWU	N_Prep_N_N	eigen|ev|neut_voor_eigen|ev|neut_eigen|ev|neut
MWU	N_Prep_N_N	soort|ev|neut_voor_eigen|ev|neut_eigen|ev|neut
MWU	N_Prep_N_Prep_Art_N	eigen|ev|neut_voor_soort|mv|neut_voor_bep|onzijd|neut_eigen|ev|neut
MWU	N_Prep_N_Prep_N_Conj_N_Prep_Art_N_N	soort|ev|neut_voor_soort|ev|neut_voor_soort|ev|neut_neven_soort|ev|neut_voor_bep|zijdofmv|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_Prep_N_Punc_N_Conj_N	soort|ev|neut_voor_soort|ev|neut_komma_eigen|ev|neut_neven_eigen|ev|neut
MWU	N_Prep_N_Punc_N_Conj_N	soort|ev|neut_voor_soort|ev|neut_komma_soort|ev|neut_neven_soort|ev|neut
MWU	N_Prep_Num	soort|ev|neut_voor_hoofd|bep|zelfst|onverv
MWU	N_Prep_Pron_N	eigen|ev|neut_voor_bez|3|ev|neut|attr_soort|mv|neut
MWU	N_Pron	eigen|ev|neut_onbep|neut|zelfst
MWU	N_Punc_Adj_N	eigen|ev|neut_aanhaalenk_attr|stell|onverv_eigen|ev|neut
MWU	N_Punc_Adj_Pron_Punc	soort|ev|neut_komma_attr|stell|onverv_per|2|ev|nom_uitroep
MWU	N_Punc_Adv_V_Pron_N	soort|ev|neut_komma_gew|betr_hulpofkopp|ott|3|ev_bez|1|ev|neut|attr_soort|ev|neut
MWU	N_Punc_Misc_Punc_N	eigen|ev|neut_aanhaalenk_vreemd_aanhaalenk_eigen|ev|neut
MWU	N_Punc_N	eigen|ev|neut_liggstreep_eigen|ev|neut
MWU	N_Punc_N	soort|ev|neut_schuinstreep_soort|ev|neut
MWU	N_Punc_N_Conj_N	soort|ev|neut_komma_eigen|ev|neut_neven_eigen|ev|neut
MWU	N_Punc_N_N_N_N	soort|ev|neut_komma_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut
MWU	N_Punc_N_Punc	soort|ev|neut_aanhaaldubb_eigen|ev|neut_aanhaaldubb
MWU	N_Punc_N_Punc_N	soort|ev|neut_schuinstreep_soort|ev|neut_schuinstreep_soort|ev|neut
MWU	N_Punc_Punc_N_N_Punc_Punc_N	eigen|ev|neut_haakopen_aanhaaldubb_eigen|ev|neut_eigen|ev|neut_aanhaaldubb_haaksluit_eigen|ev|neut
MWU	N_V	eigen|ev|neut_hulp|ovt|1of2of3|ev
MWU	N_V	eigen|ev|neut_intrans|ovt|1of2of3|ev
MWU	N_V	eigen|ev|neut_intrans|verldw|vervneut
MWU	N_V	eigen|ev|neut_trans|imp
MWU	N_V	eigen|ev|neut_trans|verldw|onverv
MWU	N_V	soort|ev|neut_hulpofkopp|conj
MWU	N_V	soort|ev|neut_intrans|conj
MWU	N_V	soort|ev|neut_trans|ovt|1of2of3|ev
MWU	N_V	soort|ev|neut_trans|verldw|onverv
MWU	N_V_N	eigen|ev|gen_trans|verldw|vervneut_soort|mv|neut
MWU	N_V_N	eigen|ev|neut_hulpofkopp|conj_soort|ev|neut
MWU	N_V_N	eigen|ev|neut_intrans|ott|3|ev_eigen|ev|neut
MWU	N_V_N	eigen|ev|neut_trans|imp_eigen|ev|neut
MWU	N_V_N	eigen|ev|neut_trans|inf_eigen|ev|neut
MWU	N_V_N_N	eigen|ev|neut_trans|verldw|onverv_soort|ev|neut_eigen|ev|neut
MWU	Num_Adj	hoofd|bep|attr|onverv_attr|stell|onverv
MWU	Num_Adj	hoofd|bep|attr|onverv_zelfst|stell|vervmv
MWU	Num_Adj	hoofd|bep|zelfst|onverv_attr|stell|onverv
MWU	Num_Adj	rang|bep|attr|onverv_attr|stell|vervneut
MWU	Num_Adj_Adj_N	rang|bep|attr|onverv_attr|stell|vervneut_attr|stell|vervneut_eigen|ev|neut
MWU	Num_Adj_N	rang|bep|attr|onverv_attr|stell|vervneut_soort|ev|neut
MWU	Num_Conj_Adj	hoofd|bep|attr|onverv_neven_attr|stell|vervneut
MWU	Num_Conj_Art_Adj	hoofd|bep|attr|onverv_neven_onbep|zijdofonzijd|neut_attr|stell|onverv
MWU	Num_Conj_Num	hoofd|onbep|attr|stell|onverv_neven_hoofd|onbep|attr|vergr|onverv
MWU	Num_Conj_Num	hoofd|onbep|zelfst|stell|onverv_neven_hoofd|onbep|attr|vergr|onverv
MWU	Num_Conj_Num	hoofd|onbep|zelfst|stell|onverv_neven_hoofd|onbep|zelfst|vergr|onverv
MWU	Num_Conj_Num_N	hoofd|bep|attr|onverv_neven_hoofd|bep|attr|onverv_eigen|ev|neut
MWU	Num_N	hoofd|bep|attr|onverv_eigen|ev|neut
MWU	Num_N	hoofd|bep|attr|onverv_soort|ev|neut
MWU	Num_N	hoofd|bep|attr|onverv_soort|mv|neut
MWU	Num_N	hoofd|bep|zelfst|onverv_eigen|ev|neut
MWU	Num_N	rang|bep|attr|onverv_soort|ev|gen
MWU	Num_N	rang|bep|attr|onverv_soort|ev|neut
MWU	Num_N_N	hoofd|bep|attr|onverv_soort|mv|neut_eigen|ev|neut
MWU	Num_N_N	rang|bep|attr|onverv_eigen|ev|neut_eigen|ev|neut
MWU	Num_N_Num	hoofd|bep|attr|onverv_eigen|ev|neut_hoofd|bep|attr|onverv
MWU	Num_N_Num	hoofd|bep|attr|onverv_eigen|ev|neut_hoofd|bep|zelfst|onverv
MWU	Num_N_Num	hoofd|bep|attr|onverv_soort|ev|neut_hoofd|bep|attr|onverv
MWU	Num_N_Num_Num_N	hoofd|bep|attr|onverv_soort|mv|neut_hoofd|bep|attr|onverv_hoofd|bep|attr|onverv_soort|mv|neut
MWU	Num_Num	hoofd|bep|attr|onverv_hoofd|bep|attr|onverv
MWU	Num_Num	hoofd|bep|attr|onverv_hoofd|bep|zelfst|onverv
MWU	Num_Num	hoofd|bep|attr|onverv_rang|bep|zelfst|onverv
MWU	Num_Num	hoofd|bep|zelfst|onverv_hoofd|bep|zelfst|onverv
MWU	Num_Num_N	hoofd|bep|attr|onverv_hoofd|bep|attr|onverv_soort|ev|neut
MWU	Num_Prep_Num	hoofd|bep|zelfst|onverv_voor_hoofd|bep|zelfst|onverv
MWU	Num_Punc	hoofd|bep|zelfst|onverv_haaksluit
MWU	Num_Punc_Num	hoofd|bep|attr|onverv_liggstreep_hoofd|bep|attr|onverv
MWU	Num_Punc_Num	hoofd|bep|attr|onverv_maal_hoofd|bep|attr|onverv
MWU	Num_Punc_Num_N_N	hoofd|bep|attr|onverv_maal_hoofd|bep|attr|onverv_soort|ev|neut_soort|ev|neut
MWU	Prep_Adj	voor_adv|vergr|vervneut
MWU	Prep_Adj	voor_attr|stell|onverv
MWU	Prep_Adj	voor_attr|stell|vervneut
MWU	Prep_Adj_Conj_Prep_N	voor_attr|stell|onverv_neven_voor_soort|ev|neut
MWU	Prep_Adj_N	voor_attr|stell|vervneut_soort|mv|neut
MWU	Prep_Adv	comb_gew|geenfunc|stell|onverv
MWU	Prep_Adv	voor_gew|aanw
MWU	Prep_Adv	voor_gew|geenfunc|overtr|vervneut
MWU	Prep_Adv	voor_gew|geenfunc|stell|onverv
MWU	Prep_Adv	voor_gew|geenfunc|stell|vervneut
MWU	Prep_Adv	voor_pron|vrag
MWU	Prep_Adv	voorinf_gew|geenfunc|stell|onverv
MWU	Prep_Art	voor_bep|onzijd|neut
MWU	Prep_Art	voor_onbep|zijdofonzijd|neut
MWU	Prep_Art_Adj	voor_bep|onzijd|neut_adv|vergr|onverv
MWU	Prep_Art_Adj	voor_bep|onzijd|neut_zelfst|overtr|onverv
MWU	Prep_Art_Adj	voor_bep|onzijd|neut_zelfst|stell|vervneut
MWU	Prep_Art_Adj	voor_bep|zijdofmv|neut_attr|stell|vervneut
MWU	Prep_Art_Adj_N	voor_bep|zijdofmv|neut_attr|stell|vervneut_soort|ev|neut
MWU	Prep_Art_Misc_Misc	voor_bep|zijdofmv|neut_vreemd_vreemd
MWU	Prep_Art_N	voor_bep|onzijd|neut_eigen|ev|neut
MWU	Prep_Art_N	voor_bep|onzijd|neut_soort|ev|neut
MWU	Prep_Art_N	voor_bep|zijdofmv|neut_eigen|ev|neut
MWU	Prep_Art_N	voor_bep|zijdofmv|neut_soort|ev|neut
MWU	Prep_Art_N	voor_bep|zijdofmv|neut_soort|mv|neut
MWU	Prep_Art_N	voor_bep|zijd|dat_soort|ev|dat
MWU	Prep_Art_N	voor_bep|zijd|dat_soort|ev|neut
MWU	Prep_Art_N	voor_onbep|zijdofonzijd|neut_soort|ev|neut
MWU	Prep_Art_N_Adv	voor_bep|zijdofmv|neut_soort|ev|neut_deelv
MWU	Prep_Art_N_Adv	voor_bep|zijdofmv|neut_soort|ev|neut_pron|vrag
MWU	Prep_Art_N_Art_N	voor_bep|zijdofmv|neut_soort|ev|neut_bep|zijdofmv|gen_soort|mv|neut
MWU	Prep_Art_N_Prep	voor_bep|onzijd|neut_soort|ev|neut_voor
MWU	Prep_Art_N_Prep	voor_bep|zijdofmv|neut_soort|ev|neut_voor
MWU	Prep_Art_N_Prep_Art_N	voor_bep|zijdofmv|neut_soort|ev|neut_voor_bep|zijdofmv|neut_soort|ev|neut
MWU	Prep_Art_N_V	voor_bep|zijdofmv|neut_soort|mv|neut_intrans|verldw|onverv
MWU	Prep_Art_V	voor_bep|onzijd|neut_intrans|inf
MWU	Prep_Art_V	voor_bep|zijdofmv|neut_trans|ott|1|ev
MWU	Prep_Conj_Prep	voor_neven_voor
MWU	Prep_Misc	voor_vreemd
MWU	Prep_N	voor_eigen|ev|neut
MWU	Prep_N	voor_soort|ev|dat
MWU	Prep_N	voor_soort|ev|neut
MWU	Prep_N	voor_soort|mv|neut
MWU	Prep_N_Adv	voor_soort|ev|neut_deeladv
MWU	Prep_N_Adv	voor_soort|ev|neut_pron|aanw
MWU	Prep_N_Adv	voor_soort|ev|neut_pron|vrag
MWU	Prep_N_Adv	voor_soort|mv|neut_deelv
MWU	Prep_N_Conj	voor_soort|ev|neut_onder|metinf
MWU	Prep_N_Conj_N	voor_soort|ev|neut_neven_soort|ev|neut
MWU	Prep_N_N	voor_soort|ev|neut_soort|ev|neut
MWU	Prep_N_Prep	voor_soort|ev|dat_voor
MWU	Prep_N_Prep	voor_soort|ev|neut_voor
MWU	Prep_N_Prep	voor_soort|mv|neut_voor
MWU	Prep_N_Prep_N	voor_soort|ev|neut_voor_soort|ev|neut
MWU	Prep_N_V	voor_soort|ev|dat_trans|verldw|vervneut
MWU	Prep_Num	voor_hoofd|onbep|zelfst|overtr|vervneut
MWU	Prep_Num	voor_hoofd|onbep|zelfst|vergr|onverv
MWU	Prep_Num_N	voor_hoofd|bep|attr|onverv_soort|ev|neut
MWU	Prep_Prep	voor_voor
MWU	Prep_Prep_Adj	voor_voor_adv|stell|onverv
MWU	Prep_Prep_Adv	voor_voor_gew|geenfunc|stell|onverv
MWU	Prep_Prep_Art_N	voor_voor_bep|zijdofmv|neut_eigen|mv|neut
MWU	Prep_Pron	voor_aanw|neut|zelfst
MWU	Prep_Pron	voor_onbep|neut|attr
MWU	Prep_Pron	voor_onbep|neut|zelfst
MWU	Prep_Pron	voor_rec|neut
MWU	Prep_Pron	voor_ref|3|evofmv
MWU	Prep_Pron_Adj	voor_bez|3|ev|neut|attr_adv|vergr|onverv
MWU	Prep_Pron_N	voor_aanw|dat|attr_soort|ev|dat
MWU	Prep_Pron_N	voor_aanw|dat|attr_soort|ev|neut
MWU	Prep_Pron_N	voor_bez|3|ev|neut|attr_soort|ev|neut
MWU	Prep_Pron_N_Adv	voor_onbep|neut|attr_soort|mv|neut_deelv
MWU	Prep_Punc_N_Conj_N	voor_aanhaaldubb_soort|mv|neut_neven_soort|mv|neut
MWU	Prep_V	voor_intrans|inf
MWU	Prep_V	voorinf_trans|inf
MWU	Prep_V_N	voor_intrans|tegdw|vervneut_soort|ev|neut
MWU	Prep_V_Pron_Pron_Adv	voor_hulp|ott|1|ev_per|1|ev|nom_per|2|ev|datofacc_gew|aanw
MWU	Pron_Adj	bez|2|ev|neut|attr_attr|overtr|vervneut
MWU	Pron_Adj	onbep|neut|zelfst_adv|vergr|onverv
MWU	Pron_Adj_N_Punc_Art_Adj_N_Prep_Art_Adj_N	bez|1|mv|neut|attr_attr|stell|vervneut_soort|ev|neut_komma_bep|zijdofmv|neut_attr|stell|vervneut_eigen|ev|neut_voor_bep|zijdofmv|neut_attr|stell|vervneut_soort|ev|neut
MWU	Pron_Adv	betr|neut|zelfst_gew|aanw
MWU	Pron_Adv	vrag|neut|attr_deelv
MWU	Pron_Art	vrag|neut|attr_onbep|zijdofonzijd|neut
MWU	Pron_Art	vrag|neut|zelfst_onbep|zijdofonzijd|neut
MWU	Pron_Art_N_N	onbep|neut|zelfst_onbep|zijdofonzijd|neut_soort|ev|neut_soort|mv|neut
MWU	Pron_N	aanw|gen|attr_soort|mv|neut
MWU	Pron_N	onbep|neut|attr_soort|ev|neut
MWU	Pron_N	onbep|neut|zelfst_eigen|ev|neut
MWU	Pron_N	onbep|neut|zelfst_soort|ev|gen
MWU	Pron_N_Adv	onbep|neut|attr_soort|ev|neut_deeladv
MWU	Pron_N_V_Adv_Num_Punc	onbep|neut|attr_soort|ev|neut_hulpofkopp|ott|3|ev_gew|er_hoofd|bep|attr|onverv_punt
MWU	Pron_N_V_Conj_N	onbep|neut|attr_soort|ev|neut_hulpofkopp|ott|3|ev_onder|metfin_soort|ev|neut
MWU	Pron_Prep	betr|neut|zelfst_voor
MWU	Pron_Prep	onbep|neut|zelfst_voor
MWU	Pron_Prep	vrag|neut|attr_voor
MWU	Pron_Prep_Art	betr|neut|zelfst_voor_onbep|zijdofonzijd|neut
MWU	Pron_Prep_Art	vrag|neut|attr_voor_onbep|zijdofonzijd|neut
MWU	Pron_Prep_N	vrag|neut|attr_voor_soort|mv|neut
MWU	Pron_Prep_Pron	onbep|neut|zelfst_voor_onbep|neut|zelfst
MWU	Pron_Pron	ref|3|evofmv_aanw|neut|attr|wzelf
MWU	Pron_Pron_V	betr|neut|zelfst_onbep|neut|zelfst_trans|ott|2|ev
MWU	Pron_V	bez|1|mv|neut|attr_intrans|inf|subst
MWU	Pron_V	bez|3|ev|gen|attr_intrans|inf|subst
MWU	Pron_V_V	aanw|neut|zelfst_hulp|ott|3|ev_trans|inf
MWU	Punc_Int_Punc_N_N_N_Punc_Pron_V_Pron_Adj_V_Punc	aanhaaldubb_komma_eigen|ev|neut_eigen|ev|neut_eigen|ev|neut_komma_vrag|neut|attr_hulpofkopp|ott|2|ev_per|2|ev|nom_adv|stell|onverv_intrans|verldw|onverv_aanhaaldubb
MWU	Punc_N_Punc_N	aanhaaldubb_eigen|ev|neut_aanhaaldubb_eigen|ev|neut
MWU	Punc_Num	liggstreep_hoofd|bep|attr|onverv
MWU	Punc_Num	liggstreep_hoofd|bep|zelfst|onverv
MWU	Punc_Num_Num	liggstreep_hoofd|bep|attr|onverv_hoofd|bep|zelfst|onverv
MWU	V_Adj_N	trans|verldw|vervneut_attr|stell|vervneut_soort|mv|neut
MWU	V_Adv	trans|imp_gew|geenfunc|stell|onverv
MWU	V_Adv_Art_N_Prep_Pron_N	trans|imp_gew|geenfunc|stell|onverv_onbep|zijdofonzijd|neut_soort|ev|neut_voor_bez|2|ev|neut|attr_soort|mv|neut
MWU	V_Art_N	trans|imp_bep|zijdofmv|neut_eigen|ev|neut
MWU	V_Art_N_Num_N	hulp|ott|3|ev_bep|zijdofmv|neut_eigen|ev|neut_hoofd|bep|attr|onverv_soort|mv|neut
MWU	V_Conj_N_N	trans|verldw|vervneut_neven_eigen|ev|neut_eigen|ev|neut
MWU	V_Conj_Pron	trans|verldw|onverv_neven_onbep|neut|attr
MWU	V_N	trans|imp_eigen|ev|neut
MWU	V_N	trans|verldw|vervneut_soort|mv|neut
MWU	V_N_Conj_Adj_N_Prep_Art_N	trans|verldw|onverv_soort|mv|neut_neven_attr|stell|vervneut_soort|mv|neut_voor_bep|zijdofmv|neut_soort|ev|neut
MWU	V_N_Misc_Punc	trans|imp_eigen|ev|neut_vreemd_uitroep
MWU	V_N_N	intrans|tegdw|onverv_soort|ev|neut_eigen|ev|neut
MWU	V_N_N	trans|verldw|onverv_soort|ev|neut_eigen|ev|neut
MWU	V_N_V	intrans|ott|1of2of3|mv_eigen|ev|neut_intrans|inf
MWU	V_Prep	intrans|verldw|onverv_voor
MWU	V_Pron	hulpofkopp|conj_onbep|neut|zelfst
MWU	V_Pron_Adv	trans|ott|1|ev_per|2|ev|nom_gew|geenfunc|stell|onverv
MWU	V_Pron_Adv_Adv_Pron_V	trans|imp_ref|2|ev_gew|aanw_gew|betr_per|1|ev|nom_intrans|ott|2|ev
MWU	V_Pron_V	trans|conj_betr|neut|zelfst_trans|ott|3|ev
MWU	V_V	hulp|imp_intrans|inf
MWU	V_V	hulp|imp_trans|inf
Misc	Misc	vreemd
N	N	eigen|ev|gen
N	N	eigen|ev|neut
N	N	eigen|mv|neut
N	N	soort|ev|dat
N	N	soort|ev|gen
N	N	soort|ev|neut
N	N	soort|mv|neut
Num	Num	hoofd|bep|attr|onverv
Num	Num	hoofd|bep|zelfst|onverv
Num	Num	hoofd|bep|zelfst|vervgen
Num	Num	hoofd|bep|zelfst|vervmv
Num	Num	hoofd|onbep|attr|overtr|onverv
Num	Num	hoofd|onbep|attr|overtr|vervneut
Num	Num	hoofd|onbep|attr|stell|onverv
Num	Num	hoofd|onbep|attr|stell|vervneut
Num	Num	hoofd|onbep|attr|vergr|onverv
Num	Num	hoofd|onbep|attr|vergr|vervneut
Num	Num	hoofd|onbep|zelfst|overtr|onverv
Num	Num	hoofd|onbep|zelfst|overtr|vervmv
Num	Num	hoofd|onbep|zelfst|overtr|vervneut
Num	Num	hoofd|onbep|zelfst|stell|onverv
Num	Num	hoofd|onbep|zelfst|stell|vervmv
Num	Num	hoofd|onbep|zelfst|stell|vervneut
Num	Num	hoofd|onbep|zelfst|vergr|onverv
Num	Num	hoofd|onbep|zelfst|vergr|vervmv
Num	Num	hoofd|onbep|zelfst|vergr|vervneut
Num	Num	rang|bep|attr|onverv
Num	Num	rang|bep|zelfst|onverv
Prep	Prep	achter
Prep	Prep	comb
Prep	Prep	voor
Prep	Prep	voorinf
Pron	Pron	aanw|dat|attr
Pron	Pron	aanw|gen|attr
Pron	Pron	aanw|neut|attr
Pron	Pron	aanw|neut|attr|weigen
Pron	Pron	aanw|neut|attr|wzelf
Pron	Pron	aanw|neut|zelfst
Pron	Pron	betr|gen|zelfst
Pron	Pron	betr|neut|attr
Pron	Pron	betr|neut|zelfst
Pron	Pron	bez|1|ev|neut|attr
Pron	Pron	bez|1|mv|neut|attr
Pron	Pron	bez|2|ev|neut|attr
Pron	Pron	bez|2|mv|neut|attr
Pron	Pron	bez|3|ev|gen|attr
Pron	Pron	bez|3|ev|neut|attr
Pron	Pron	bez|3|ev|neut|zelfst
Pron	Pron	bez|3|mv|neut|attr
Pron	Pron	onbep|gen|attr
Pron	Pron	onbep|gen|zelfst
Pron	Pron	onbep|neut|attr
Pron	Pron	onbep|neut|zelfst
Pron	Pron	per|1|ev|datofacc
Pron	Pron	per|1|ev|nom
Pron	Pron	per|1|mv|datofacc
Pron	Pron	per|1|mv|nom
Pron	Pron	per|2|ev|datofacc
Pron	Pron	per|2|ev|nom
Pron	Pron	per|2|mv|datofacc
Pron	Pron	per|2|mv|nom
Pron	Pron	per|3|evofmv|datofacc
Pron	Pron	per|3|evofmv|nom
Pron	Pron	per|3|ev|datofacc
Pron	Pron	per|3|ev|nom
Pron	Pron	per|3|mv|datofacc
Pron	Pron	per|3|mv|nom
Pron	Pron	rec|gen
Pron	Pron	rec|neut
Pron	Pron	ref|1|ev
Pron	Pron	ref|1|mv
Pron	Pron	ref|2|ev
Pron	Pron	ref|3|evofmv
Pron	Pron	vrag|neut|attr
Pron	Pron	vrag|neut|zelfst
Punc	Punc	aanhaaldubb
Punc	Punc	aanhaalenk
Punc	Punc	dubbpunt
Punc	Punc	haakopen
Punc	Punc	haaksluit
Punc	Punc	hellip
Punc	Punc	isgelijk
Punc	Punc	komma
Punc	Punc	liggstreep
Punc	Punc	maal
Punc	Punc	punt
Punc	Punc	puntkomma
Punc	Punc	schuinstreep
Punc	Punc	uitroep
Punc	Punc	vraag
V	V	hulpofkopp|conj
V	V	hulpofkopp|imp
V	V	hulpofkopp|inf
V	V	hulpofkopp|inf|subst
V	V	hulpofkopp|ott|1of2of3|mv
V	V	hulpofkopp|ott|1|ev
V	V	hulpofkopp|ott|2|ev
V	V	hulpofkopp|ott|3|ev
V	V	hulpofkopp|ovt|1of2of3|ev
V	V	hulpofkopp|ovt|1of2of3|mv
V	V	hulpofkopp|tegdw|vervneut
V	V	hulpofkopp|verldw|onverv
V	V	hulp|conj
V	V	hulp|inf
V	V	hulp|ott|1of2of3|mv
V	V	hulp|ott|1|ev
V	V	hulp|ott|2|ev
V	V	hulp|ott|3|ev
V	V	hulp|ovt|1of2of3|ev
V	V	hulp|ovt|1of2of3|mv
V	V	hulp|verldw|onverv
V	V	intrans|conj
V	V	intrans|imp
V	V	intrans|inf
V	V	intrans|inf|subst
V	V	intrans|ott|1of2of3|mv
V	V	intrans|ott|1|ev
V	V	intrans|ott|2|ev
V	V	intrans|ott|3|ev
V	V	intrans|ovt|1of2of3|ev
V	V	intrans|ovt|1of2of3|mv
V	V	intrans|tegdw|onverv
V	V	intrans|tegdw|vervmv
V	V	intrans|tegdw|vervneut
V	V	intrans|tegdw|vervvergr
V	V	intrans|verldw|onverv
V	V	intrans|verldw|vervmv
V	V	intrans|verldw|vervneut
V	V	refl|imp
V	V	refl|inf
V	V	refl|inf|subst
V	V	refl|ott|1of2of3|mv
V	V	refl|ott|1|ev
V	V	refl|ott|2|ev
V	V	refl|ott|3|ev
V	V	refl|ovt|1of2of3|ev
V	V	refl|ovt|1of2of3|mv
V	V	refl|tegdw|vervneut
V	V	refl|verldw|onverv
V	V	trans|conj
V	V	trans|imp
V	V	trans|inf
V	V	trans|inf|subst
V	V	trans|ott|1of2of3|mv
V	V	trans|ott|1|ev
V	V	trans|ott|2|ev
V	V	trans|ott|3|ev
V	V	trans|ovt|1of2of3|ev
V	V	trans|ovt|1of2of3|mv
V	V	trans|tegdw|onverv
V	V	trans|tegdw|vervneut
V	V	trans|verldw|onverv
V	V	trans|verldw|vervmv
V	V	trans|verldw|vervneut
V	V	trans|verldw|vervvergr
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
