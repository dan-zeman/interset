# ABSTRACT: Driver for the tagset used by the Czech National Corpus team for texts from the nineteenth century.
# Copyright © 2006-2009, 2014, 2016, 2021, 2022, 2025 Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset::Tagset::CS::Xixstol;
use strict;
use warnings;
our $VERSION = '3.017';

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
extends 'Lingua::Interset::Tagset';



has 'atoms' => ( isa => 'HashRef', is => 'ro', builder => '_create_atoms', lazy => 1 );



#------------------------------------------------------------------------------
# Returns the tagset id that should be set as the value of the 'tagset' feature
# during decoding. Every derived class must (re)define this method! The result
# should correspond to the last two parts in package name, lowercased.
# Specifically, it should be the ISO 639-2 language code, followed by '::' and
# a language-specific tagset id. Example: 'cs::multext'.
#------------------------------------------------------------------------------
sub get_tagset_id
{
    return 'cs::xixstol';
}



#------------------------------------------------------------------------------
# Creates atomic drivers for 11 surface features.
#------------------------------------------------------------------------------
sub _create_atoms
{
    my $self = shift;
    my %atoms;
    # 1. PART OF SPEECH ####################
    $atoms{pos} = $self->create_atom
    (
        'surfeature' => 'pos',
        'decode_map' =>
        {
            # noun
            # examples: pán hrad žena růže město moře
            'NN' => ['pos' => 'noun'],
            'N-' => ['pos' => 'noun'],
            # nominal postfixal segment of a hyphenated compound
            # examples: upista (in "start-upista"), tunga, timu (final parts of Chinese personal names, inflected according to Czech grammar)
            'SN' => ['pos' => 'noun', 'other' => 'postfix'],
            # noun phrase abbreviation ("USA")
            'BN' => ['pos' => 'noun', 'abbr' => 'yes'],
            # isolated letter (used as abbreviation?)
            'Q3' => ['pos' => 'noun', 'abbr' => 'yes', 'other' => 'letter'],
            # adjective
            # examples: mladý jarní
            'AA' => ['pos' => 'adj'],
            # short form of adjective ("jmenný tvar")
            # examples: mlád stár zdráv
            'AC' => ['pos' => 'adj', 'variant' => 'short'],
            # special adjectives: svůj, nesvůj, tentam
            # svůj: other usage than possessive reflexive pronoun
            'AO' => ['pos' => 'adj', 'other' => 'O'],
            # possessive adjective
            # examples: otcův matčin
            'AU' => ['pos' => 'adj', 'poss' => 'yes'],
            # adjective derived from present transgressive of verb
            # examples: dělající
            'AG' => ['pos' => 'adj', 'verbform' => 'part', 'tense' => 'pres', 'voice' => 'act', 'aspect' => 'imp'],
            # adjective derived from past transgressive of verb
            # examples: udělavší
            'AM' => ['pos' => 'adj', 'verbform' => 'part', 'tense' => 'past', 'voice' => 'act', 'aspect' => 'perf'],
            # prefixal segment of a hyphenated compound
            # examples: česko (in "česko-slovenský"), sci (in "sci-fi")
            'S2' => ['pos' => 'adj', 'hyph' => 'yes'],
            # adjectival postfixal segment of a hyphenated compound
            # examples: upový (in "start-upový"), tého, line (in "on-line")
            'SA' => ['pos' => 'adj', 'other' => 'postfix'],
            # adjectival phrase abbreviation ("aj")
            'BA' => ['pos' => 'adj', 'abbr' => 'yes'],
            # personal pronoun
            # examples: já ty my vy on
            'PP' => ['pos' => 'noun', 'prontype' => 'prs'],
            # reflexive personal pronoun, long form
            # examples: sebe sobě sebou
            'P6' => ['pos' => 'noun', 'prontype' => 'prs', 'reflex' => 'yes'],
            # reflexive personal pronoun, short form
            # examples: se si ses sis
            'P7' => ['pos' => 'noun', 'prontype' => 'prs', 'reflex' => 'yes', 'variant' => 'short'],
            # possessive pronoun, 1st or 2nd person
            # examples: můj tvůj náš váš
            'PS' => ['pos' => 'adj', 'prontype' => 'prs', 'poss' => 'yes'],
            # possessive pronoun, 3rd person
            # examples: jeho, její, jejich
            'P9' => ['pos' => 'adj', 'prontype' => 'prs', 'poss' => 'yes'],
            # reflexive possessive pronoun
            # examples: svůj
            'P8' => ['pos' => 'adj', 'prontype' => 'prs', 'poss' => 'yes', 'reflex' => 'yes'],
            # demonstrative pronoun
            # examples: ten tento tenhle onen takový týž tentýž sám
            ###!!! Syntactically they are often adjectives but not always ("to auto je moje" vs. "to je moje").
            'PD' => ['pos' => 'adj', 'prontype' => 'dem'],
            # interrogative pronoun
            # examples: kdo co kdož copak
            # zájmeno (nezáporné, nikoli neurčité, nikoli přivlastňovací) tázací (kdo, co, který, jaký, kdopak...)
            'PK' => ['pos' => 'noun', 'prontype' => 'int|rel'],
            # relative pronoun
            # examples: jaký který čí jenž
            # zájmeno (nezáporné, nikoli neurčité, nikoli přivlastňovací) vztažné (kdo, co, který, jaký, jenž)
            'P4' => ['pos' => 'adj|noun', 'prontype' => 'rel'],
            # possessive relative pronoun
            # examples: jehož jejíž
            'P1' => ['pos' => 'adj', 'prontype' => 'rel', 'poss' => 'yes'],
            # indefinite pronoun
            # examples: někdo něco kdokoli kdosi cosi nevímco
            # examples: nějaký některý něčí čísi sotvakterý
            'PZ' => ['pos' => 'adj', 'prontype' => 'ind'],
            # zájmeno (nezáporné, nikoli neurčité, nikoli přivlastňovací) vymezovací (taký, takový, onaký, týž, tentýž, sám, každý, všechen, všecek...)
            # total pronoun
            # examples: všechen sám
            'PL' => ['pos' => 'noun', 'prontype' => 'tot'],
            # negative pronoun
            # examples: nikdo nic nijaký ničí žádný nižádný pražádný nijeden nikterý nesvůj
            'PW' => ['pos' => 'adj', 'prontype' => 'neg'],
            # cardinal number expressed by digits
            # examples: 1 3,14 2014
            'C=' => ['pos' => 'num', 'numtype' => 'card', 'numform' => 'digit'],
            # cardinal number expressed by Roman numerals
            # examples: MCMLXXI
            # { ... syntax highlighting
            'C}' => ['pos' => 'num', 'numtype' => 'card', 'numform' => 'roman'],
            # interrogative or relative cardinal numeral
            # example: kolik
            'C?' => ['pos' => 'num', 'numtype' => 'card', 'prontype' => 'int|rel'],
            # indefinite or demonstrative cardinal numeral
            # examples: několik mnoho málo kdovíkolik tolik
            'Ca' => ['pos' => 'num', 'numtype' => 'card', 'prontype' => 'ind|dem'],
            # adjectival multiplicative numeral "twofold" (note: these words are included in generic numerals in the Czech grammar)
            # examples: obojí dvojí trojí
            # generic adjectival numeral (number of sets of things)
            # examples: jedny oboje dvoje troje (čtvery patery desatery?)
            # "oboje", "dvoje" and "troje" appear in the corpus as "Cd" and the feature variant=1 distinguishes them from "obojí", "dvojí" and "trojí".
            # Larger numerals of this type ("čtvery", "patery" etc.) do not appear in the corpus.
            'Cd' => ['pos' => 'adj', 'numtype' => 'mult|sets'],
            # generic adjectival numeral (number of sets of things), indefinite
            # examples: několikerý
            'Ch' => ['pos' => 'adj', 'numtype' => 'sets', 'prontype' => 'ind'],
            # generic cardinal numeral
            # examples: čtvero patero desatero
            # This tag is documented in the tagset but it does not occur in the PDT.
            'Cj' => ['pos' => 'num', 'numtype' => 'card', 'other' => {'numtype' => 'generic'}],
            # ordinal suffix as a separate token
            # only one occurrence in the corpus: tých ("posledně v letech 60 tých" = "posledně v letech šedesátých")
            # Syntactic analysis of the above example is Atr(letech, tých); Atr(tých, 60).
            # Hence we can say that the suffix works as an adjective.
            'Ck' => ['pos' => 'adj', 'numtype' => 'ord', 'other' => {'numtype' => 'suffix'}],
            # cardinal numeral, low value (agrees with counted noun)
            # examples: jeden dva tři čtyři
            'Cl' => ['pos' => 'num', 'numtype' => 'card', 'numform' => 'word'],
            # indefinite multiplicative numeral
            # examples: několikrát mnohokrát tolikrát kolikrát nesčíslněkrát
            'Co' => ['pos' => 'adv', 'numtype' => 'mult', 'prontype' => 'ind|dem'],
            # ordinal numeral (adjectival)
            # examples: první druhý třetí stý tisící
            # (Note: "poprvé" is another type of ordinal numeral, it behaves syntactically as adverb.
            # It is tagged 'Cv', together with multiplicative numerals ("jedenkrát"), which are also syntactic adverbs.)
            'Cr' => ['pos' => 'adj', 'numtype' => 'ord'],
            # interrogative or relative multiplicative numeral
            # examples: kolikrát
            'Cu' => ['pos' => 'adv', 'numtype' => 'mult', 'prontype' => 'int|rel'],
            # multiplicative numeral or adverbial ordinal numeral
            # examples: jedenkrát dvakrát třikrát stokrát tisíckrát
            # examples: poprvé podruhé potřetí posté potisící
            'Cv' => ['pos' => 'adv', 'numtype' => 'mult'],
            # Two different types of agreeing adjectival indefinite numerals are tagged 'Cw':
            # indefinite numeral "nejeden" = lit. "not one" = "more than one"
            # examples: nejeden
            # indefinite or demonstrative adjectival ordinal numeral
            # examples: několikátý, mnohý, tolikátý
            'Cw' => ['pos' => 'adj', 'numtype' => 'ord', 'prontype' => 'ind|dem'],
            # cardinal numeral, fraction denominator
            # examples: polovina třetina čtvrtina setina tisícina
            # These words behave morphologically and syntactically as feminine nouns of the paradigm "žena".
            # (Note that the fraction words "půl" and "čtvrt" are not tagged "Cy".)
            'Cy' => ['pos' => 'num', 'numtype' => 'frac'],
            # interrogative or relative ordinal numeral
            # examples: kolikátý
            'Cz' => ['pos' => 'adj', 'numtype' => 'ord', 'prontype' => 'int|rel'],
            # adjectival postfixal segment of a hyphenated compound
            # examples: ti (in "755-ti")
            'Sl' => ['pos' => 'adj', 'other' => 'postfix', 'numtype' => 'card', 'numform' => 'word'],
            # verb infinitive
            # examples: nést dělat říci
            'Vf' => ['pos' => 'verb', 'verbform' => 'inf'],
            # verb supine
            # example: modlit (infinitive: modliti), hledat (infinitive: hledati)
            'V$' => ['pos' => 'verb', 'verbform' => 'sup'],
            # finite verb, present or future indicative
            # examples: nesu beru mažu půjdu
            'VB' => ['pos' => 'verb', 'verbform' => 'fin', 'mood' => 'ind', 'tense' => 'pres'], # tense may be later overwritten by 'fut'
            # finite verb, present or future indicative with encliticized 'neboť'
            # examples: dělámť děláť
            'Vt' => ['pos' => 'verb', 'verbform' => 'fin', 'mood' => 'ind', 'tense' => 'pres', 'voice' => 'act', 'verbtype' => 'verbconj'],
            # finite verb, simple past (aorist or imperfect) indicative
            # examples: bieše, vecě, prosiechu
            'V-' => ['pos' => 'verb', 'verbform' => 'fin', 'mood' => 'ind', 'tense' => 'past'], # tense may be later overwritten by 'imp'
            # verb imperative
            # examples: nes dělej řekni
            'Vi' => ['pos' => 'verb', 'verbform' => 'fin', 'mood' => 'imp'],
            # conditional auxiliary verb form (evolved from aorist of 'to be')
            # examples: bych bys by bychom byste
            'Vc' => ['pos' => 'verb', 'verbform' => 'fin', 'mood' => 'cnd'],
            # verb active participle
            # examples: dělal dělala dělalo dělali dělaly dělals dělalas ...
            'Vp' => ['pos' => 'verb', 'verbform' => 'part', 'tense' => 'past', 'voice' => 'act'],
            # verb active participle with encliticized 'neboť'
            # examples: dělalť dělalať dělaloť ...
            'Vq' => ['pos' => 'verb', 'verbform' => 'part', 'tense' => 'past', 'voice' => 'act', 'verbtype' => 'verbconj'],
            # verb passive participle
            # examples: dělán dělána děláno děláni dělány udělán udělána
            'Vs' => ['pos' => 'verb', 'verbform' => 'part', 'voice' => 'pass'],
            # verb present transgressive (converb, gerund, přechodník)
            # examples: nesa nesouc nesouce dělaje dělajíc dělajíce
            'Ve' => ['pos' => 'verb', 'verbform' => 'conv', 'tense' => 'pres', 'aspect' => 'imp', 'voice' => 'act'],
            # verb past transgressive (converb, gerund, přechodník)
            # examples: udělav udělavši udělavše přišed přišedši přišedše
            'Vm' => ['pos' => 'verb', 'verbform' => 'conv', 'tense' => 'past', 'aspect' => 'perf', 'voice' => 'act'],
            # adverb
            'D-' => ['pos' => 'adv'],
            # compound adverb (from a prepositional phrase) written as one word
            # examples: nasucho
            'DG' => ['pos' => 'adv', 'variant' => '1'],
            # adverbial postfixal segment of a hyphenated compound
            # examples: line (in "on-line")
            'Sb' => ['pos' => 'adv', 'other' => 'postfix'],
            # adverbial phrase abbreviation ("atd")
            'Bb' => ['pos' => 'adv', 'abbr' => 'yes'],
            # preposition
            # examples: v pod k
            'RR' => ['pos' => 'adp', 'adpostype' => 'prep'],
            'R-' => ['pos' => 'adp', 'adpostype' => 'prep'],
            # vocalized preposition
            # examples: ve pode ke ku
            'RV' => ['pos' => 'adp', 'adpostype' => 'voc'],
            # first part of compound preposition
            # examples: nehledě na, vzhledem k
            'RF' => ['pos' => 'adp', 'adpostype' => 'comprep'],
            # conjunction
            'J-' => ['pos' => 'conj'],
            # coordinating conjunction
            # examples: a i ani nebo ale avšak
            'J^' => ['pos' => 'conj', 'conjtype' => 'coor'],
            # subordinating conjunction
            # examples: že, aby, zda, protože, přestože
            'J,' => ['pos' => 'conj', 'conjtype' => 'sub'],
            # mathematical conjunction (the word 'times' in 'five times')
            # examples: krát
            'J*' => ['pos' => 'conj', 'conjtype' => 'oper'],
            # conjunction phrase abbreviation ("tzn")
            'B^' => ['pos' => 'conj', 'conjtype' => 'coor', 'abbr' => 'yes'],
            # particle
            # examples: ať kéž nechť
            'TT' => ['pos' => 'part'],
            'T-' => ['pos' => 'part'],
            # interjection
            # examples: haf bum bác
            'II' => ['pos' => 'int'],
            'I-' => ['pos' => 'int'],
            # punctuation
            # examples: . ? ! , ; : -
            'Z:' => ['pos' => 'punc'],
            # artificial root node of the sentence
            # examples: #
            "Z\#" => ['pos' => 'punc', 'punctype' => 'root'],
            # foreign word
            'F-' => ['foreign' => 'yes'],
            # X: unknown part of speech
            # unrecognized word form
            'X@' => ['other' => '@'],
            # word form recognized but tag is missing in dictionary
            'XX' => ['other' => 'X'],
            # - should never appear as subpos but it does, even in the list in b2800a.o2f
            'X-' => ['other' => '-']
        },
        'encode_map' => {} # Encoding of part of speech must be solved directly in Perl code, it would be too complicated to do it here.
    );
    # 2. GENDER ####################
    $atoms{gender} = $self->create_atom
    (
        'surfeature' => 'gender',
        'decode_map' =>
        {
            'M' => ['gender' => 'masc', 'animacy' => 'anim'],
            'I' => ['gender' => 'masc', 'animacy' => 'inan'],
            'F' => ['gender' => 'fem'],
            'N' => ['gender' => 'neut'],
            'Y' => ['gender' => 'masc'],
            'T' => ['gender' => 'masc|fem', 'animacy' => 'inan|'],
            'W' => ['gender' => 'masc|neut', 'animacy' => 'inan|'],
            'H' => ['gender' => 'fem|neut'],
            'Q' => ['gender' => 'fem|neut'],
            'Z' => ['gender' => 'masc|neut'],
            'X' => []
        },
        'encode_map' =>

            { 'gender' => { 'fem|masc'  => 'T',
                            'fem|neut'  => { 'number' => { 'plur|sing' => 'Q',
                                                           'sing'     => 'H',
                                                           'plur'      => 'H',
                                                           '@'        => 'H' }},
                            'masc|neut' => { 'animacy' => { 'inan' => 'W',
                                                                '@'    => 'Z' }},
                            'masc'      => { 'animacy' => { ''     => 'Y',
                                                                'inan' => 'I',
                                                                '@'    => 'M' }},
                            'fem'  => 'F',
                            'neut' => 'N' }}
    );
    # 3. NUMBER ####################
    $atoms{number} = $self->create_atom
    (
        'surfeature' => 'number',
        'decode_map' =>
        {
            'S' => ['number' => 'sing'],
            'P' => ['number' => 'plur'],
            'W' => ['number' => 'sing|plur']
        },
        'encode_map' =>

            # Do not generate number for conditional auxiliaries. It is encoded as aggregate there.
            { 'mood' => { 'cnd' => '',
                          '@'   => { 'number' => { 'plur|sing' => 'W',
                                                   'dual' => 'P', # in this tagset, dual has P in the number slot, but then 1 in a separate dual slot
                                                   'plur' => 'P',
                                                   'sing' => 'S' }}}}
    );
    # 4. CASE ####################
    $atoms{case} = $self->create_simple_atom
    (
        'intfeature' => 'case',
        'simple_decode_map' =>
        {
            '1' => 'nom',
            '2' => 'gen',
            '3' => 'dat',
            '4' => 'acc',
            '5' => 'voc',
            '6' => 'loc',
            '7' => 'ins'
        }
    );
    # 5. PROPER NAME (OR ITS PART) ####################
    $atoms{proper} = $self->create_atom
    (
        'surfeature' => 'proper',
        'decode_map' =>
        {
            'j' => ['nountype' => 'prop'],
        },
        'encode_map' =>

            { 'nountype' => { 'prop' => 'j' }}
    );
    # 6. DUAL ####################
    # Encoded separately (while number is plural) for formally dual forms:
    # suffix -ma, or paired body parts "kolenou", "ramenou", "očí".
    $atoms{dual} = $self->create_atom
    (
        'surfeature' => 'dual',
        'decode_map' =>
        {
            '1' => ['number' => 'dual'],
        },
        'encode_map' =>

            { 'number' => { 'dual' => '1' }}
    );
    # 7. PERSON ####################
    $atoms{person} = $self->create_atom
    (
        'surfeature' => 'person',
        'decode_map' =>
        {
            '1' => ['person' => '1'],
            '2' => ['person' => '2'],
            '3' => ['person' => '3']
        },
        'encode_map' =>

            # Do not generate person for conditional auxiliaries. It is encoded as aggregate there.
            { 'mood' => { 'cnd' => '',
                          '@'   => { 'person' => { '1' => '1',
                                                   '2' => '2',
                                                   '3' => '3' }}}}
    );
    # 8. TENSE ####################
    $atoms{tense} = $self->create_atom
    (
        'surfeature' => 'tense',
        'decode_map' =>
        {
            'A' => ['tense' => 'past'], # aorist
            'I' => ['tense' => 'imp'],  # imperfekt
            'R' => ['tense' => 'past'],
            'H' => ['tense' => 'past|pres'],
            'P' => ['tense' => 'pres'],
            'F' => ['tense' => 'fut'],
        },
        'encode_map' =>

            # Do not encode tense of verbal adjectives and transgressives. Otherwise encode(decode(x)) will not equal to x.
            { 'pos' => { 'adj' => '',
                         '@'   => { 'verbform' => { 'conv' => '',
                                                    'fin'  => { 'tense' => { 'past' => 'A',
                                                                             'imp'  => 'I',
                                                                             'fut'  => 'F',
                                                                             'pres' => 'P' }},
                                                    '@'    => { 'tense' => { 'past|pres' => 'H',
                                                                             'past' => 'R',
                                                                             'fut'  => 'F',
                                                                             'pres' => 'P' }}}}}}
    );
    # 9. DEGREE ####################
    $atoms{degree} = $self->create_simple_atom
    (
        'intfeature' => 'degree',
        'simple_decode_map' =>
        {
            '1' => 'pos',
            '2' => 'cmp',
            '3' => 'sup'
        }
    );
    # 10. POLARITY ####################
    $atoms{polarity} = $self->create_atom
    (
        'surfeature' => 'polarity',
        'decode_map' =>
        {
            'A' => ['polarity' => 'pos'],
            'N' => ['polarity' => 'neg']
        },
        'encode_map' =>

            # Do not encode polarity of negative pronouns. Otherwise encode(decode(x)) will not equal to x.
            { 'prontype' => { 'neg' => '',
                              '@'   => { 'polarity' => { 'pos' => 'A',
                                                         'neg' => 'N' }}}}
    );
    # 11. VOICE ####################
    $atoms{voice} = $self->create_atom
    (
        'surfeature' => 'voice',
        'decode_map' =>
        {
            'A' => ['voice' => 'act'],
            'P' => ['voice' => 'pass']
        },
        'encode_map' =>

            # Do not encode voice of verbal adjectives and transgressives. Otherwise encode(decode(x)) will not equal to x.
            { 'pos' => { 'adj' => '',
                         '@'   => { 'verbform' => { 'conv' => '',
                                                    '@'     => { 'voice' => { 'act'  => 'A',
                                                                              'pass' => 'P' }}}}}}
    );
    # 12. AGGREGATE ####################
    $atoms{aggregate} = $self->create_atom
    (
        'surfeature' => 'aggregate',
        'decode_map' =>
        {
            # Aggregate: part of an orthographic word fused from multiple morphosyntactic words.
            # Example: -s = jsi.
            # Also in tags of prepositions and relative pronouns in: nač, oč, seč, več, zač
            '1' => ['other' => 'aggregate'], # bys, přišels, kdyžs
        },
        'encode_map' =>

            # Since this currently occurs mostly with conditional verbs, we do not want to do it for personal pronouns
            # (which always have person and number). However, in the future we may need to be able to use it with
            # pronouns 'tys', 'ses', and 'sis'. We also do not want to generate this with present indicative verbs.
            { 'other' => { 'aggregate' => '1' }}
    );
    # 13. CLITIC ####################
    $atoms{clitic} = $self->create_atom
    (
        'surfeature' => 'clitic',
        'decode_map' =>
        {
            'T' => ['other' => 'ť'],  # the word includes encliticized particle -ť, -tě, -ž
            'B' => ['other' => 'by'], # the word includes conditional morpheme -by
        },
        'encode_map' =>

            { 'other' => { 'ť'  => 'T',
                           'by' => 'B' }}
    );
    # 14. ASPECT ####################
    $atoms{aspect} = $self->create_atom
    (
        'surfeature' => 'aspect',
        'decode_map' =>
        {
            'P' => ['aspect' => 'perf'],    # napsat
            'I' => ['aspect' => 'imp'],     # psát
            'B' => ['aspect' => 'imp|perf'] # absolvovat
        },
        'encode_map' =>

            # Do not encode aspect of verbal adjectives. Otherwise encode(decode(x)) will not equal to x.
            { 'pos' => { 'adj' => '',
                         '@'   => { 'aspect' => { 'imp|perf' => 'B',
                                                  'imp'      => 'I',
                                                  'perf'     => 'P' }}}}
    );
    return \%atoms;
}



#------------------------------------------------------------------------------
# Decodes a physical tag (string) and returns the corresponding feature
# structure.
#------------------------------------------------------------------------------
sub decode
{
    my $self = shift;
    my $tag = shift;
    my $fs = Lingua::Interset::FeatureStructure->new();
    $fs->set_tagset('cs::xixstol');
    my $atoms = $self->atoms();
    my @chars = split(//, $tag);
    $atoms->{pos}->decode_and_merge_hard($chars[0].$chars[1], $fs);
    $atoms->{gender}->decode_and_merge_hard($chars[2], $fs);
    $atoms->{number}->decode_and_merge_hard($chars[3], $fs);
    $atoms->{case}->decode_and_merge_hard($chars[4], $fs);
    $atoms->{proper}->decode_and_merge_hard($chars[5], $fs);
    $atoms->{dual}->decode_and_merge_hard($chars[6], $fs);
    $atoms->{person}->decode_and_merge_hard($chars[7], $fs);
    $atoms->{tense}->decode_and_merge_hard($chars[8], $fs); ### tady ma byt pomlcka (pomocne sloveso, ale neurcuje se)
    $atoms->{degree}->decode_and_merge_hard($chars[9], $fs);
    $atoms->{polarity}->decode_and_merge_hard($chars[10], $fs);
    $atoms->{voice}->decode_and_merge_hard($chars[11], $fs);
    $atoms->{aggregate}->decode_and_merge_hard($chars[13], $fs);
    $atoms->{clitic}->decode_and_merge_hard($chars[14], $fs);
    $atoms->{aspect}->decode_and_merge_hard($chars[15], $fs);
    return $fs;
}



#------------------------------------------------------------------------------
# Takes feature structure and returns the corresponding physical tag (string).
#------------------------------------------------------------------------------
sub encode
{
    my $self = shift;
    my $fs = shift; # Lingua::Interset::FeatureStructure
    my $tag = '';
    # pos and subpos
    # Foreign words must come first because then we do not care about the foreign part of speech, if present.
    if($fs->is_foreign())
    {
        $tag = 'F---------------';
    }
    # Numerals and pronouns must come first because they can be at the same time also nouns or adjectives.
    elsif($fs->is_numeral())
    {
        if($fs->numform() eq 'digit')
        {
            $tag = 'C=--------------';
        }
        elsif($fs->numform() eq 'roman')
        { #{
            $tag = 'C}--------------';
        }
        elsif($fs->numtype() eq 'card')
        {
            if($fs->is_wh())
            {
                # kolik
                $tag = 'C?--------------';
            }
            elsif($fs->contains('prontype', 'ind') || $fs->contains('prontype', 'dem'))
            {
                # několik, mnoho, málo, tolik
                $tag = 'Ca--X-----------';
            }
            # certain "generic" numerals (druhové číslovky) are classified as cardinals
            elsif($fs->get_other_subfeature('cs::xixstol', 'numtype') eq 'generic')
            {
                # čtvero, patero, desatero
                $tag = 'Cj--------------';
            }
            else
            {
                # jeden, jedna, jedno, dva, dvě, tři, čtyři
                # pět, deset, patnáct, devadesát, sto
                $tag = 'Cl--X-----------';
            }
        }
        elsif($fs->numtype() eq 'ord')
        {
            if($fs->is_wh())
            {
                # kolikátý
                $tag = 'CzXXX-----------';
            }
            elsif($fs->contains('prontype', 'ind') || $fs->contains('prontype', 'dem'))
            {
                # několikátý, mnohý, tolikátý
                # but also: nejeden
                $tag = 'CwXXX-----------';
            }
            elsif($fs->get_other_subfeature('cs::xixstol', 'numtype') eq 'suffix' ||
               $fs->gender() eq '' && $fs->number() ne '')
            {
                # tých
                $tag = 'Ck-XX-----------';
            }
            else
            {
                $tag = 'CrXXX-----------';
            }
        }
        elsif($fs->numtype() eq 'mult')
        {
            if($fs->is_wh())
            {
                # kolikrát
                $tag = 'Cu--------------';
            }
            elsif($fs->contains('prontype', 'ind') || $fs->contains('prontype', 'dem'))
            {
                # několikrát, mnohokrát, tolikrát
                $tag = 'Co--------------';
            }
            else
            {
                $tag = 'Cv--------------'; ###!!! pozor tohle jsou i řadové číslovky příslovečné (poprvé, podruhé...)
            }
        }
        elsif($fs->numtype() eq 'frac')
        {
            $tag = 'Cy--------------';
        }
        elsif($fs->numtype() eq 'sets' && $fs->contains('prontype', 'ind'))
        {
            # několikerý
            $tag = 'Ch--------------';
            # "nejedny" is indefinite numeral and has its own tag 'Cw'.
            # "oboje", "dvoje", "troje" (and "čtvery", "patery", "desatery"?) are included in "Cd", together with "obojí", "dvojí", "trojí".
        }
        else
        {
            # obojí, dvojí, trojí (both-fold, twofold, three-fold)
            # oboje, dvoje, troje (both sets of, two sets of, three sets of)
            # The latter are distinguished by variant=1.
            $tag = 'CdX-------------';
        }
    }
    elsif($fs->is_pronominal())
    {
        # possessive pronoun
        if($fs->is_possessive())
        {
            if($fs->is_wh())
            {
                # jehož, jejíž, jejichž
                # it has possgender if it is 3rd person
                if($fs->person() eq '3')
                {
                    $tag = 'P1XXXX----------';
                }
                else
                {
                    $tag = 'P1XXX-----------';
                }
            }
            elsif($fs->is_reflexive())
            {
                # svůj
                $tag = 'P8XXX-----------';
            }
            else
            {
                # můj, tvůj, jeho, její, náš, váš, jejich
                $tag = 'PSXXX-----------';
            }
        }
        # personal pronoun
        elsif($fs->adpostype() eq 'preppron')
        {
            $tag = 'P0---------------'; # oň, naň
        }
        elsif($fs->prontype() eq 'prs')
        {
            if(!$fs->is_reflexive())
            {
                # já, ty, on, ona, ono, my, vy, oni, ony
                # it has gender if it is 3rd person
                if($fs->person() eq '3')
                {
                    $tag = 'PPXXX-----------';
                }
                else
                {
                    $tag = 'PP-XX-----------';
                }
            }
            else # reflexive
            {
                if($fs->variant() eq 'short')
                {
                    # si, sis, se, ses
                    $tag = 'P7--X-----------';
                }
                else
                {
                    # sebe, sobě, sebou
                    $tag = 'P6--X-----------';
                }
            }
        }
        # negative pronoun
        # we cannot look at polarity=neg because non-negative pronouns can be negated (e.g., nekaždý would be prontype=tot, polarity=neg)
        elsif($fs->prontype() eq 'neg')
        {
            # nikdo, nic, nijaký, ničí, žádný
            $tag = 'PW--X-----------';
        }
        # demonstrative pronoun
        elsif($fs->prontype() eq 'dem')
        {
            # ten, tento, tenhle, onen, takový, týž, tentýž
            $tag = 'PDXXX-----------';
        }
        # interrogative pronoun
        elsif($fs->is_interrogative())
        {
            # kdo, co, jaký, který, kdopak
            $tag = 'PK--X-----------';
        }
        # relative pronoun
        elsif($fs->is_relative())
        {
            # kdo, co, jaký, který, jenž
            $tag = 'P4--X-----------';
        }
        # totality (collective) pronoun
        elsif($fs->prontype() eq 'tot')
        {
            # it has gender and number if it is plural or if it does not have case
            if($fs->is_plural() || $fs->case() eq '')
            {
                $tag = 'PLXXX-----------';
            }
            else
            {
                $tag = 'PL--X-----------';
            }
        }
        # indefinite pronoun
        else
        {
            $tag = 'PZ--X-----------';
        }
    }
    elsif($fs->is_noun())
    {
        if($fs->tagset() eq 'cs::xixstol' && $fs->other() eq 'letter')
        {
            $tag = 'Q3--------------';
        }
        elsif($fs->is_abbreviation() && $fs->variant() !~ m/^[abc]$/)
        {
            # We have to set the default 'A' here for the case that 'Q3' is stored without other=letter.
            $tag = 'BNXXX-----A-----';
        }
        elsif($fs->tagset() eq 'cs::xixstol' && $fs->other() eq 'postfix')
        {
            $tag = 'SNXXX-----------';
        }
        else
        {
            $tag = 'N---------------';
        }
    }
    elsif($fs->is_adjective())
    {
        if($fs->is_abbreviation() && $fs->variant() !~ m/^[abc]$/)
        {
            $tag = 'BAXXX-----------';
        }
        elsif($fs->tagset() eq 'cs::xixstol' && $fs->other() eq 'postfix')
        {
            $tag = 'SAXXX-----------';
        }
        elsif($fs->variant() eq 'short')
        {
            $tag = 'ACXX------------';
        }
        elsif($fs->is_possessive())
        {
            $tag = 'AUXXX-----------';
        }
        elsif($fs->is_participle() && $fs->is_past())
        {
            $tag = 'AMXXX-----------';
        }
        elsif($fs->is_participle())
        {
            $tag = 'AGXXX-----------';
        }
        elsif($fs->is_hyph())
        {
            $tag = 'S2--------------';
        }
        elsif($fs->get_other_for_tagset('cs::xixstol') eq 'O' ||
              $fs->case() eq '' && $fs->polarity() eq '')
        {
            $tag = 'AOXX------------';
        }
        else
        {
            $tag = 'AAXXX-----------';
        }
    }
    elsif($fs->is_verb())
    {
        if($fs->is_infinitive())
        {
            $tag = 'Vf--------------';
        }
        elsif($fs->is_supine())
        {
            $tag = 'V$--------------';
        }
        elsif($fs->is_participle())
        {
            if($fs->voice() eq 'pass')
            {
                $tag = 'VsXX------------';
            }
            elsif($fs->verbtype() eq 'verbconj')
            {
                $tag = 'VqXX---XX-------';
            }
            else # default is active past/conditional participle
            {
                $tag = 'VpXX----X-------';
            }
        }
        elsif($fs->is_transgressive())
        {
            if($fs->tense() eq 'past')
            {
                $tag = 'VmX-------------';
            }
            else # default is present transgressive
            {
                $tag = 'VeX-------------';
            }
        }
        else # default is finite verb
        {
            if($fs->mood() eq 'imp')
            {
                $tag = 'Vi-X---X--------';
            }
            elsif($fs->mood() =~ m/^(cnd|sub)$/)
            {
                $tag = 'Vc--------------';
            }
            else # indicative
            {
                if($fs->verbtype() eq 'verbconj')
                {
                    $tag = 'Vt-X---XX-------';
                }
                elsif($fs->tense() =~ m/^(past|imp)$/) # aorist or imperfect
                {
                    $tag = 'V--X---XX-------';
                }
                else
                {
                    $tag = 'VB-X---XX-------';
                }
            }
        }
    }
    elsif($fs->is_adverb())
    {
        if($fs->is_abbreviation() && $fs->variant() !~ m/^[abc]$/)
        {
            $tag = 'Bb--------------';
        }
        elsif($fs->tagset() eq 'cs::xixstol' && $fs->other() eq 'postfix')
        {
            $tag = 'Sb--------------';
        }
        elsif($fs->variant() eq '1')
        {
            # compound adverb ("nasucho")
            $tag = 'DG--------------';
        }
        else
        {
            $tag = 'D---------------';
        }
    }
    elsif($fs->is_adposition())
    {
        if($fs->adpostype() eq 'comprep')
        {
            $tag = 'RF--------------';
        }
        elsif($fs->adpostype() eq 'voc')
        {
            $tag = 'RV--X-----------';
        }
        else
        {
            $tag = 'RR--X-----------';
        }
    }
    elsif($fs->is_conjunction())
    {
        if($fs->is_subordinator())
        {
            # it has number if it has person
            # in that case it also contains the conditional -by
            if($fs->person() =~ m/^[123]$/)
            {
                $tag = 'J,-X----------B-';
            }
            else
            {
                $tag = 'J,--------------';
            }
        }
        elsif($fs->is_coordinator())
        {
            $tag = 'J^--------------';
        }
        elsif($fs->conjtype() eq 'oper')
        {
            $tag = 'J*--------------';
        }
        elsif($fs->is_abbreviation() && $fs->variant() !~ m/^[abc]$/)
        {
            $tag = 'B^--------------';
        }
        else # by default the diachronic data do not distinguish conjunction subtypes
        {
            $tag = 'J---------------';
        }
    }
    elsif($fs->is_particle())
    {
        $tag = 'T---------------';
    }
    elsif($fs->is_interjection())
    {
        $tag = 'I---------------';
    }
    elsif($fs->is_punctuation())
    {
        if($fs->punctype() eq 'root')
        {
            $tag = 'Z#--------------';
        }
        else
        {
            $tag = 'Z:--------------';
        }
    }
    else # default is unknown tag
    {
        my $other = $fs->get_other_for_tagset('cs::xixstol');
        # Unknown abbreviation can be encoded either as 'XX------------8' or as 'Xx-------------' but not as 'Xx------------8'.
        if($fs->variant() eq '8')
        {
            $tag = 'XX--------------';
        }
        elsif($other =~ m/^[-X\@]$/)
        {
            $tag = 'X'.$other.'--------------';
        }
        elsif($fs->is_abbreviation())
        {
            $tag = 'Xx--------------';
        }
        else
        {
            $tag = 'X@--------------';
        }
    }
    # Now encode the features.
    # The PDT tagset distinguishes unknown values ("X") and irrelevant features ("-").
    # Interset does not do this distinction but we have prepared the defaults for empty values above.
    my @tag = split(//, $tag);
    my @features = ('pos', 'subpos', 'gender', 'number', 'case', 'proper', 'dual', 'person', 'tense', 'degree', 'polarity', 'voice', undef, 'aggregate', 'clitic', 'aspect');
    my $atoms = $self->atoms();
    for(my $i = 2; $i<16; $i++)
    {
        next if(!defined($features[$i]));
        my $atag = $atoms->{$features[$i]}->encode($fs);
        # If we got undef, there is something wrong with our encoding tables.
        if(!defined($atag))
        {
            print STDERR ("\n", $fs->as_string(), "\n");
            confess("Cannot encode '$features[$i]'");
        }
        if($atag ne '')
        {
            $tag[$i] = $atag;
        }
    }
    $tag = join('', @tag);
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags. The list was collected from the
# 19th etalon texts from the Hičkok project.
# 1188
# Z nich jsem kvůli konzistenci vyhodil: 0
#------------------------------------------------------------------------------
sub list
{
    my $self = shift;
    my $list = <<end_of_list
AAFP1j---1A-----
AAFP1----1A-----
AAFP1----1N-----
AAFP1----2A-----
AAFP1----2N-----
AAFP1----3A-----
AAFP2j---1A-----
AAFP2----1A-----
AAFP2----1N-----
AAFP2----2A-----
AAFP2----3A-----
AAFP3----1A-----
AAFP3----2A-----
AAFP3----3A-----
AAFP4j---1A-----
AAFP4----1A-----
AAFP4----1N-----
AAFP4----2A-----
AAFP4----3A-----
AAFP5----1A-----
AAFP6j---1A-----
AAFP6----1A-----
AAFP6----1N-----
AAFP6----2A-----
AAFP7j---1A-----
AAFP7----1A-----
AAFP7----1N-----
AAFP7-1--1A-----
AAFP7----2A-----
AAFS1j---1A-----
AAFS1----1A-----
AAFS1----1A---T-
AAFS1----1N-----
AAFS1----2A-----
AAFS1----2N-----
AAFS1----3A-----
AAFS1----3N-----
AAFS2j---1A-----
AAFS2----1A-----
AAFS2----1N-----
AAFS2----2A-----
AAFS2----3A-----
AAFS3j---1A-----
AAFS3----1A-----
AAFS3----1N-----
AAFS3----2A-----
AAFS3----3A-----
AAFS4j---1A-----
AAFS4----1A-----
AAFS4----1A--1--
AAFS4----1N-----
AAFS4----2A-----
AAFS4----3A-----
AAFS5----1A-----
AAFS5----1N-----
AAFS5----3A-----
AAFS6j---1A-----
AAFS6----1A-----
AAFS6----1N-----
AAFS6----2A-----
AAFS6----3A-----
AAFS7j---1A-----
AAFS7----1A-----
AAFS7----1N-----
AAFS7----2A-----
AAFS7----3A-----
AAIP1----1A-----
AAIP1----1N-----
AAIP1----2A-----
AAIP1----3A-----
AAIP2j---1A-----
AAIP2----1A-----
AAIP2----1N-----
AAIP2----2A-----
AAIP2----3A-----
AAIP3----1A-----
AAIP3----3A-----
AAIP4----1A-----
AAIP4----1N-----
AAIP4----2A-----
AAIP4----3A-----
AAIP6j---1A-----
AAIP6----1A-----
AAIP6----1N-----
AAIP6----2A-----
AAIP6----3A-----
AAIP7----1A-----
AAIP7----1N-----
AAIP7----2A-----
AAIP7----2N-----
AAIP7----3A-----
AAIS1j---1A-----
AAIS1----1A-----
AAIS1----1N-----
AAIS1----2A-----
AAIS1----3A-----
AAIS2j---1A-----
AAIS2----1A-----
AAIS2----1N-----
AAIS2----2A-----
AAIS2----3A-----
AAIS3j---1A-----
AAIS3----1A-----
AAIS3----1N-----
AAIS3----2A-----
AAIS3----3A-----
AAIS4j---1A-----
AAIS4----1A-----
AAIS4----1N-----
AAIS4----2A-----
AAIS4----3A-----
AAIS6j---1A-----
AAIS6----1A-----
AAIS6----1N-----
AAIS6----2A-----
AAIS6----3A-----
AAIS7j---1A-----
AAIS7----1A-----
AAIS7----1N-----
AAIS7----2A-----
AAIS7----3A-----
AAMP1----1A-----
AAMP1----1N-----
AAMP1----2A-----
AAMP1----3A-----
AAMP2----1A-----
AAMP2----1N-----
AAMP2----2A-----
AAMP2----3A-----
AAMP3----1A-----
AAMP3----1N-----
AAMP3----3A-----
AAMP4----1A-----
AAMP4----1N-----
AAMP4----2A-----
AAMP4----3A-----
AAMP5----1A-----
AAMP6----1A-----
AAMP6----3A-----
AAMP7----1A-----
AAMP7----1N-----
AAMP7----2A-----
AAMS1j---1A-----
AAMS1----1A-----
AAMS1----1N-----
AAMS1----2A-----
AAMS1----2N-----
AAMS1----3A-----
AAMS2j---1A-----
AAMS2----1A-----
AAMS2----1N-----
AAMS2----2A-----
AAMS2----3A-----
AAMS3----1A-----
AAMS3----1N-----
AAMS3----2A-----
AAMS3----3A-----
AAMS4----1A-----
AAMS4----1N-----
AAMS4----2A-----
AAMS4----3A-----
AAMS5----1A-----
AAMS5----1N-----
AAMS5----3A-----
AAMS6----1A-----
AAMS6----1N-----
AAMS7----1A-----
AAMS7----1N-----
AAMS7----2A-----
AAMS7----3A-----
AANP1----1A-----
AANP1----1N-----
AANP1----2A-----
AANP1----3A-----
AANP2----1A-----
AANP2----1N-----
AANP2----2A-----
AANP2----3A-----
AANP3----1A-----
AANP3----1N-----
AANP3----3A-----
AANP4----1A-----
AANP4----1N-----
AANP4----2A-----
AANP5----1A-----
AANP6----1A-----
AANP6----1N-----
AANP6----2A-----
AANP7----1A-----
AANP7-1--1A-----
AANP7-1--1N-----
AANS1j---1A-----
AANS1----1A-----
AANS1----1N-----
AANS1----2A-----
AANS1----3A-----
AANS2j---1A-----
AANS2----1A-----
AANS2----1N-----
AANS2----2A-----
AANS2----3A-----
AANS3----1A-----
AANS3----1N-----
AANS3----2A-----
AANS3----3A-----
AANS4j---1A-----
AANS4----1A-----
AANS4----1N-----
AANS4----2A-----
AANS4----3A-----
AANS5----1A-----
AANS6j---1A-----
AANS6----1A-----
AANS6----1N-----
AANS6----2A-----
AANS6----3A-----
AANS7j---1A-----
AANS7----1A-----
AANS7----1N-----
AANS7----2A-----
AANS7----3A-----
ACFP1----1A-----
ACFS1----1A-----
ACFS1----1N-----
ACFS4----1A-----
ACIP1----1A-----
ACIP1----1N-----
ACIP4----1A-----
ACIS1----1A-----
ACIS4----1A-----
ACMP1----1A-----
ACMP1----1A---T-
ACMP1----1N-----
ACMP4----1A-----
ACMP6----1A-----
ACMS1----1A-----
ACMS1----1N-----
ACMS4----1A-----
ACMS5----1A-----
ACNS1----1A-----
ACNS1----1N-----
ACNS4----1A-----
ACNS4----1N-----
AUFP1j---1A-----
AUFP1----1A-----
AUFP2j---1A-----
AUFP2----1A-----
AUFP3----1A-----
AUFP4j---1A-----
AUFS1j---1A-----
AUFS1----1A-----
AUFS2j---1A-----
AUFS2----1A-----
AUFS3----1A-----
AUFS4j---1A-----
AUFS4----1A-----
AUFS5----1A-----
AUFS6j---1A-----
AUFS6----1A-----
AUFS7j---1A-----
AUFS7----1A-----
AUIP1j---1A-----
AUIP2j---1A-----
AUIP4j---1A-----
AUIS1j---1A-----
AUIS1----1A-----
AUIS2j---1A-----
AUIS3j---1A-----
AUIS4j---1A-----
AUIS4----1A-----
AUIS6j---1A-----
AUIS6----1A-----
AUIS7j---1A-----
AUIS7----1A-----
AUMP1j---1A-----
AUMP1----1A-----
AUMP2----1A-----
AUMP7j---1A-----
AUMS1j---1A-----
AUMS1----1A-----
AUMS2j---1A-----
AUMS2----1A-----
AUMS3----1A-----
AUMS4j---1A-----
AUNP1j---1A-----
AUNP2j---1A-----
AUNP4j---1A-----
AUNP4----1A-----
AUNS1j---1A-----
AUNS1----1A-----
AUNS2j---1A-----
AUNS2----1A-----
AUNS3j---1A-----
AUNS3----1A-----
AUNS4j---1A-----
AUNS4----1A-----
AUNS6j---1A-----
AUNS7j---1A-----
AUNS7----1A-----
C=--------------
CdFP1-----------
CdFP2-----------
CdFS4-----------
CdFS7-----------
CdIS2-----------
CdIS4-----------
CdMP1-----------
CdMP3-----------
CdNP1-----------
CdNP2-----------
CdNP4-----------
CdNP7-----------
CdNS1-----------
CdNS2-----------
CdNS6-----------
CdNS7-----------
Cj-S4-----------
ClFP1-----------
ClFP2-----------
ClFP4-----------
ClFP6-----------
ClFP7-----------
ClFS1-----------
ClFS2-----------
ClFS3-----------
ClFS4-----------
ClFS6-----------
ClFS7-----------
ClIP1-----------
ClIP2-----------
ClIP3-----------
ClIP4-----------
ClIP6-----------
ClIP7-----------
ClIS1-----------
ClIS2-----------
ClIS4-----------
ClIS6-----------
ClIS7-----------
ClMP1-----------
ClMP2-----------
ClMP4-----------
ClMP7-----------
ClMS1-----------
ClMS2-----------
ClMS3-----------
ClMS4-----------
ClMS6-----------
ClMS7-----------
ClNP1-----------
ClNP2-----------
ClNP3-----------
ClNP4-----------
ClNP6-----------
ClNP7-----------
ClNP7-1---------
ClNS1-----------
ClNS2-----------
ClNS4-----------
ClNS6-----------
ClNS7-----------
Cl-S1-----------
Cl-S2-----------
Cl-S3-----------
Cl-S4-----------
Cl-S6-----------
Cl-S7-----------
Cl--1-----------
Cl--1-----A-----
Cl--2-----------
Cl--2-----A-----
Cl--4-----------
Cl--4-----A-----
Cl--6-----------
Cl--6-----A-----
Cl--7-----------
Cl--7-----A-----
CrFP1-----------
CrFP2-----------
CrFP3-----------
CrFP7-----------
CrFS1-----------
CrFS2-----------
CrFS4-----------
CrFS6-----------
CrFS7-----------
CrIP4-----------
CrIP6-----------
CrIS1-----------
CrIS2-----------
CrIS3-----------
CrIS4-----------
CrIS6-----------
CrIS7-----------
CrMP1-----------
CrMP2-----------
CrMP4-----------
CrMP7-----------
CrMS1-----------
CrMS2-----------
CrMS3-----------
CrMS4-----------
CrMS7-----------
CrNP1-----------
CrNS1-----------
CrNS2-----------
CrNS3-----------
CrNS4-----------
CrNS6-----------
CrNS7-----------
Cv--------------
CyFP1-----------
CyFS1-----------
CyFS4-----------
C?--1-----------
C?--4-----------
DG-------1A-----
DG-------1N-----
D--------1A-----
D--------1A---T-
D--------1N-----
D--------2A-----
D--------2N-----
D--------3A-----
F---------------
I---------------
J,--------------
J^--------------
J,-P---1------B-
J,-P---2------B-
J,-P---3------B-
J,-S---1------B-
J,-S---2------B-
J,-S---3------B-
J,------------T-
J^------------T-
J,-----------1--
N-FP1-----A-----
N-FP1j----A-----
N-FP2-----A-----
N-FP2j----A-----
N-FP3-----A-----
N-FP3j----A-----
N-FP4-----A-----
N-FP4j----A-----
N-FP5-----A-----
N-FP5j----A-----
N-FP6-----A-----
N-FP6j----A-----
N-FP6j---1A-----
N-FP7-----A-----
N-FP7j----A-----
N-FP7-1---A-----
N-FS1-----A-----
N-FS1j----A-----
N-FS2-----A-----
N-FS2j----A-----
N-FS3-----A-----
N-FS3j----A-----
N-FS4-----A-----
N-FS4j----A-----
N-FS5-----A-----
N-FS5j----A-----
N-FS6-----A-----
N-FS6j----A-----
N-FS7-----A-----
N-FS7j----A-----
N-IP1-----A-----
N-IP1j----A-----
N-IP2-----A-----
N-IP2j----A-----
N-IP3-----A-----
N-IP3j----A-----
N-IP4-----A-----
N-IP4j----A-----
N-IP5-----A-----
N-IP5j----A-----
N-IP6-----A-----
N-IP6j----A-----
N-IP7-----A-----
N-IP7j----A-----
N-IP7-1---A-----
N-IS1-----A-----
N-IS1j----A-----
N-IS2-----A-----
N-IS2j----A-----
N-IS3-----A-----
N-IS3j----A-----
N-IS4-----A-----
N-IS4j----A-----
N-IS5-----A-----
N-IS5j----A-----
N-IS6-----A-----
N-IS6j----A-----
N-IS7-----A-----
N-IS7j----A-----
N-MP1-----A-----
N-MP1j----A-----
N-MP2-----A-----
N-MP2j----A-----
N-MP3-----A-----
N-MP3j----A-----
N-MP4-----A-----
N-MP4j----A-----
N-MP5-----A-----
N-MP5j----A-----
N-MP6-----A-----
N-MP6j----A-----
N-MP7-----A-----
N-MP7j----A-----
N-MS1-----A-----
N-MS1j----A-----
N-MS2-----A-----
N-MS2j----A-----
N-MS3-----A-----
N-MS3j----A-----
N-MS4-----A-----
N-MS4j----A-----
N-MS5-----A-----
N-MS5j----A-----
N-MS6-----A-----
N-MS6j----A-----
N-MS7-----A-----
N-MS7j----A-----
N-NP1-----A-----
N-NP2-----A-----
N-NP3-----A-----
N-NP4-----A-----
N-NP5-----A-----
N-NP6-----A-----
N-NP7-----A-----
N-NP7-1---A-----
N-NS1-----A-----
N-NS1j----A-----
N-NS2-----A-----
N-NS2j----A-----
N-NS3-----A-----
N-NS3j----A-----
N-NS4-----A-----
N-NS4j----A-----
N-NS5-----A-----
N-NS6-----A-----
N-NS6j----A-----
N-NS7-----A-----
N-NS7j----A-----
PDFP1-----------
PDFP2-----------
PDFP2---------T-
PDFP3-----------
PDFP4-----------
PDFP6-----------
PDFP7-----------
PDFP7-1---------
PDFS1-----------
PDFS1---------T-
PDFS2-----------
PDFS3-----------
PDFS4-----------
PDFS6-----------
PDFS7-----------
PDIP1-----------
PDIP2-----------
PDIP3-----------
PDIP4-----------
PDIP6-----------
PDIP6---------T-
PDIP7-----------
PDIS1-----------
PDIS1---------T-
PDIS2-----------
PDIS3-----------
PDIS4-----------
PDIS6-----------
PDIS7-----------
PDMP1-----------
PDMP2-----------
PDMP3-----------
PDMP4-----------
PDMP6-----------
PDMP7-----------
PDMS1-----------
PDMS1---------T-
PDMS2-----------
PDMS2---------T-
PDMS3-----------
PDMS4-----------
PDMS6-----------
PDMS7-----------
PDNP1-----------
PDNP1---------T-
PDNP2-----------
PDNP3-----------
PDNP4-----------
PDNP6-----------
PDNP7-----------
PDNS1-----------
PDNS1---------T-
PDNS2-----------
PDNS2---------T-
PDNS3-----------
PDNS4-----------
PDNS4---------T-
PDNS4--------1--
PDNS6-----------
PDNS7-----------
PKFS1-----------
PKFS1---------T-
PKFS2-----------
PKFS4-----------
PKFS6-----------
PKFS7-----------
PKIP1-----------
PKIP2-----------
PKIP3-----------
PKIP4-----------
PKIP7-----------
PKIS1-----------
PKIS2-----------
PKIS4-----------
PKIS6-----------
PKIS7-----------
PKMP1-----------
PKMS1-----------
PKM-1-----------
PKM-3-----------
PKM-4-----------
PKNP1-----------
PKNS1-----------
PKNS4-----------
PKNS7-----------
PK--1-----------
PK--2-----------
PK--3-----------
PK--4-----------
PK--4--------1--
PK--7-----------
PLFP1-----------
PLFP2-----------
PLFP3-----------
PLFP4-----------
PLFP6-----------
PLFP7-----------
PLFP7-1---------
PLFS1-----------
PLFS2-----------
PLFS3-----------
PLFS4-----------
PLFS6-----------
PLFS7-----------
PLIP1-----------
PLIP2-----------
PLIP3-----------
PLIP4-----------
PLIP6-----------
PLIP7-----------
PLIS1-----------
PLIS2-----------
PLIS3-----------
PLIS4-----------
PLIS6-----------
PLIS7-----------
PLIS7---------T-
PLMP1-----------
PLMP2-----------
PLMP3-----------
PLMP4-----------
PLMP6-----------
PLMP7-----------
PLMS1-----------
PLMS2-----------
PLMS3-----------
PLMS3-----N-----
PLMS4-----------
PLMS7-----------
PLNP1-----------
PLNP2-----------
PLNP3-----------
PLNP4-----------
PLNP6-----------
PLNS1-----------
PLNS2-----------
PLNS3-----------
PLNS4-----------
PLNS6-----------
PLNS7-----------
PPFP1--3--------
PPFP2--3--------
PPFP3--3--------
PPFP4--3--------
PPFP6--3--------
PPFP7--3--------
PPFS1--3--------
PPFS1--3------T-
PPFS2--3--------
PPFS3--3--------
PPFS4--3--------
PPFS6--3--------
PPFS7--3--------
PPIP2--3--------
PPIP3--3--------
PPIP4--3--------
PPIP6--3--------
PPIP7--3--------
PPIS1--3--------
PPIS2--3--------
PPIS3--3--------
PPIS4--3--------
PPIS4--3-----1--
PPIS6--3--------
PPIS7--3--------
PPMP1--3--------
PPMP2--3--------
PPMP3--3--------
PPMP4--3--------
PPMP6--3--------
PPMP7--3--------
PPMS1--3--------
PPMS1--3------T-
PPMS2--3--------
PPMS3--3--------
PPMS4--3--------
PPMS4--3-----1--
PPMS6--3--------
PPMS7--3--------
PPNP2--3--------
PPNP3--3--------
PPNP4--3--------
PPNP6--3--------
PPNP7--3--------
PPNS1--3--------
PPNS2--3--------
PPNS3--3--------
PPNS4--3--------
PPNS6--3--------
PPNS7--3--------
PP-P1--1--------
PP-P1--2--------
PP-P2--1--------
PP-P2--2--------
PP-P3--1--------
PP-P3--2--------
PP-P4--1--------
PP-P4--2--------
PP-P5--2--------
PP-P6--1--------
PP-P6--2--------
PP-P7--1--------
PP-P7-11--------
PP-P7--2--------
PP-S1--1--------
PP-S1--1-----1--
PP-S1--2--------
PP-S1--2------T-
PP-S1--2-----1--
PP-S2--1--------
PP-S2--2--------
PP-S3--1--------
PP-S3--2--------
PP-S4--1--------
PP-S4--2--------
PP-S5--2--------
PP-S6--1--------
PP-S6--2--------
PP-S7--1--------
PP-S7--2--------
PSFP1-----------
PSFP2-----------
PSFP3-----------
PSFP4-----------
PSFP5-----------
PSFP6-----------
PSFP7-----------
PSFP7-1---------
PSFS1-----------
PSFS2-----------
PSFS3-----------
PSFS4-----------
PSFS5-----------
PSFS6-----------
PSFS7-----------
PSIP1-----------
PSIP2-----------
PSIP3-----------
PSIP4-----------
PSIP6-----------
PSIP7-----------
PSIS1-----------
PSIS2-----------
PSIS3-----------
PSIS4-----------
PSIS6-----------
PSIS7-----------
PSMP1-----------
PSMP2-----------
PSMP3-----------
PSMP4-----------
PSMP5-----------
PSMP7-----------
PSMS1-----------
PSMS2-----------
PSMS3-----------
PSMS4-----------
PSMS5-----------
PSMS6-----------
PSMS7-----------
PSNP1-----------
PSNP2-----------
PSNP3-----------
PSNP4-----------
PSNP5-----------
PSNP6-----------
PSNP7-----------
PSNP7-1---------
PSNS1-----------
PSNS2-----------
PSNS3-----------
PSNS4-----------
PSNS5-----------
PSNS6-----------
PSNS7-----------
PWFP1-----------
PWFP2-----------
PWFP4-----------
PWFS1-----------
PWFS2-----------
PWFS4-----------
PWFS7-----------
PWIP1-----------
PWIP2-----------
PWIP4-----------
PWIS1-----------
PWIS2-----------
PWIS3-----------
PWIS4-----------
PWIS6-----------
PWIS7-----------
PWMP2-----------
PWMS1-----------
PWMS2-----------
PWMS3-----------
PWMS4-----------
PWMS6-----------
PWM-1-----------
PWM-2-----------
PWM-3-----------
PWM-4-----------
PWNS1-----------
PWNS2-----------
PWNS3-----------
PWNS4-----------
PWNS6-----------
PWNS7-----------
PW--1-----------
PW--2-----------
PW--2---------T-
PW--3-----------
PW--4-----------
PW--6-----------
PW--7-----------
PZFP1-----------
PZFP2-----------
PZFP3-----------
PZFP4-----------
PZFP6-----------
PZFP7-----------
PZFS1-----------
PZFS2-----------
PZFS3-----------
PZFS4-----------
PZFS6-----------
PZFS7-----------
PZIP1-----------
PZIP2-----------
PZIP3-----------
PZIP4-----------
PZIP6-----------
PZIP7-----------
PZIS1-----------
PZIS2-----------
PZIS3-----------
PZIS4-----------
PZIS6-----------
PZIS7-----------
PZMP1-----------
PZMP3-----------
PZMP4-----------
PZMP6-----------
PZMP7-----------
PZMS1-----------
PZMS2-----------
PZMS4-----------
PZMS6-----------
PZMS7-----------
PZM-1-----------
PZM-2-----------
PZM-3-----------
PZM-4-----------
PZM-7-----------
PZNP1-----------
PZNP2-----------
PZNP4-----------
PZNP6-----------
PZNS1-----------
PZNS2-----------
PZNS3-----------
PZNS4-----------
PZNS6-----------
PZNS7-----------
PZ--1-----------
PZ--2-----------
PZ--3-----------
PZ--4-----------
PZ--4--------1--
PZ--7-----------
P1FP1-----------
P1FS1-----------
P1FS2-----------
P1FS4-----------
P1FS6-----------
P1FS7-----------
P1IP1-----------
P1IP2-----------
P1IP3-----------
P1IS1-----------
P1IS6-----------
P1MP1-----------
P1MS1-----------
P1MS7-----------
P1NP1-----------
P1NP4-----------
P1NS1-----------
P1NS2-----------
P1NS3-----------
P1NS6-----------
P1NS7-----------
P4FP1-----------
P4FP2-----------
P4FP3-----------
P4FP4-----------
P4FP6-----------
P4FP7-----------
P4FS1-----------
P4FS1---------T-
P4FS2-----------
P4FS3-----------
P4FS4-----------
P4FS6-----------
P4FS7-----------
P4IP1-----------
P4IP2-----------
P4IP3-----------
P4IP4-----------
P4IP6-----------
P4IP7-----------
P4IS1-----------
P4IS2-----------
P4IS3-----------
P4IS4-----------
P4IS6-----------
P4IS7-----------
P4MP1-----------
P4MP2-----------
P4MP2--------1--
P4MP3-----------
P4MP4-----------
P4MP6-----------
P4MP7-----------
P4MS1-----------
P4MS1--------1--
P4MS2-----------
P4MS3-----------
P4MS4-----------
P4MS5-----------
P4MS6-----------
P4MS7-----------
P4M-1-----------
P4M-3-----------
P4M-4-----------
P4NP1-----------
P4NP2-----------
P4NP3-----------
P4NP4-----------
P4NP6-----------
P4NP7-----------
P4NS1-----------
P4NS2-----------
P4NS3-----------
P4NS4-----------
P4NS6-----------
P4NS7-----------
P4-S1-----------
P4-S2-----------
P4-S3-----------
P4-S4-----------
P4-S4--------1--
P4-S6-----------
P4-S7-----------
P6--2-----------
P6--3-----------
P6--4-----------
P6--6-----------
P6--7-----------
P8FP1-----------
RF--------------
RR--2-----------
RR--3-----------
RR--4-----------
RR--4--------1--
RR--6-----------
RR--7-----------
RV--2-----------
RV--3-----------
RV--4-----------
RV--4--------1--
RV--6-----------
RV--7-----------
T---------------
T--P---2------B-
T--P---3------B-
T--S---1------B-
T--S---3------B-
T-------------T-
T7--------------
VB-P---1--AA---I
VB-P---1--AA---P
VB-P---1--NA---I
VB-P---1--NA---P
VB-P---2--AA---I
VB-P---2--AA---P
VB-P---2--NA---I
VB-P---2--NA---P
VB-P---3--AA---I
VB-P---3--AA---P
VB-P---3--AA--TI
VB-P---3--NA---I
VB-P---3--NA---P
VB-S---1--AA---I
VB-S---1--AA---P
VB-S---1--AA--TI
VB-S---1--NA---I
VB-S---1--NA---P
VB-S---2--AA---I
VB-S---2--AA---P
VB-S---2--AA-1-I
VB-S---2--NA---I
VB-S---2--NA---P
Vb-S---21-AA-1-I
VB-S---3--AA---I
VB-S---3--AA---P
VB-S---3--AA--TI
VB-S---3--AA--TP
VB-S---3--NA---I
VB-S---3--NA---P
VB-S---3--NA--TI
Vc--------AA---I
Vc-P---1--AA---I
Vc-P---2--AA---I
Vc-S---1--AA---I
Vc-S---2--AA---I
VeFP------AA---I
VeFP------AA---P
VeFS------AA---I
VeFS------AA---P
VeFS------NA---I
VeFS------NA---P
VeIP------AA---I
VeIP------NA---I
VeIS------AA---I
VeIS------AA---P
VeMP------AA---I
VeMP------AA---P
VeMP------NA---I
VeMP------NA---P
VeMS------AA---I
VeMS------AA---P
VeMS------NA---I
VeMS------NA---P
VeNP------AA---I
VeNP------NA---I
VeNS------AA---I
VeNS------AA---P
Vf--------AA---I
Vf--------AA---P
Vf--------NA---I
Vf--------NA---P
Vi-P---1--AA---I
Vi-P---1--AA---P
Vi-P---1--AA--TP
Vi-P---1--NA---I
Vi-P---2--AA---I
Vi-P---2--AA---P
Vi-P---2--AA--TI
Vi-P---2--NA---I
Vi-P---2--NA---P
Vi-P---3--AA---I
Vi-P---3--AA--TI
Vi-S---2--AA---I
Vi-S---2--AA---P
Vi-S---2--AA--TP
Vi-S---2--NA---I
Vi-S---2--NA---P
Vi-S---3--AA---I
Vi-S---3--AA---P
Vi-S---3--AA--TI
Vi-S---3--AA--TP
Vi-S---3--NA---I
Vi-S---3--NA---P
VmFP------AA---I
VmFP------AA---P
VmFS------AA---I
VmFS------AA---P
VmIS------AA---P
VmMP------AA---I
VmMP------AA---P
VmMP------NA---I
VmMS------AA---I
VmMS------AA---P
VmMS------NA---P
VmNS------AA---P
VpFP------AA---I
VpFP------AA---Ï
VpFP------AA---P
VpFP------AA--TI
VpFP------NA---I
VpFP------NA---P
VpFS------AA---I
VpFS------AA---P
VpFS------AA--TI
VpFS------AA--TP
VpFS------NA---I
VpFS------NA---P
VpIP------AA---I
VpIP------AA---P
VpIP------NA---I
VpIP------NA---P
VpIS------AA---I
VpIS------AA---P
VpIS------AA--TP
VpIS------NA---I
VpIS------NA---P
VpMP------AA---I
VpMP------AA---P
VpMP------AA--TI
VpMP------NA---I
VpMP------NA---P
VpMS------AA---I
VpMS------AA---P
VpMS------AA--TI
VpMS------AA--TP
VpMS------AA-1-I
VpMS------AA-1-P
VpMS------NA---I
VpMS------NA---P
VpMS------NA--TI
VpNP------AA---I
VpNP------AA---P
VpNP------NA---I
VpNS------AA---I
VpNS------AA---P
VpNS------AA--TI
VpNS------AA--TP
VpNS------NA---I
VpNS------NA---P
VpNS------NA--TI
VsFP------AP---I
VsFP------AP---P
VsFS------AP---I
VsFS------AP---P
VsIP------AP---I
VsIP------AP---P
VsIP------NP---P
VsIS------AP---I
VsIS------AP---P
VsMP------AP---I
VsMP------AP---P
VsMS------AP---I
VsMS------AP---P
VsMS------NP---P
VsNP------AP---I
VsNP------AP---P
VsNS------AP---I
VsNS------AP---P
VsNS------NP---I
Vs-S------AP---I
Vs-S------AP---P
X---------------
Yo--------------
Z---------------
end_of_list
    ;
    # Protect from editors that replace tabs by spaces.
    $list =~ s/ \s+/\t/sg;
    my @list = split(/\r?\n/, $list);
    pop(@list) if($list[$#list] eq "");
    return \@list;
}



1;

=head1 SYNOPSIS

  use Lingua::Interset::Tagset::cs::xixstol;
  my $driver = Lingua::Interset::Tagset::cs::xixstol->new();
  my $fs = $driver->decode('N-MS1-----A-----');

or

  use Lingua::Interset qw(decode);
  my $fs = decode('cs::xixstol', 'N-MS1-----A-----');

=head1 DESCRIPTION

Interset driver for the Prague-derived part-of-speech tagset used in the Hičkok
project by the Czech National Corpus team for the nineteenth-century texts.
It is a positional tagset similar to PDT and PDT-C, but it has some extra
positions and values that are needed in older Czech texts.

=head1 SEE ALSO

L<Lingua::Interset>,
L<Lingua::Interset::Tagset>,
L<Lingua::Interset::FeatureStructure>

=cut
