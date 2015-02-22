# ABSTRACT: Driver for the Slovene tagset of the CoNLL 2006 Shared Task (derived from the Slovene Dependency Treebank).
# Copyright © 2011, 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset::Tagset::SL::Conll;
use strict;
use warnings;
our $VERSION = '2.038';

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
extends 'Lingua::Interset::Tagset::Conll';



#------------------------------------------------------------------------------
# Returns the tagset id that should be set as the value of the 'tagset' feature
# during decoding. Every derived class must (re)define this method! The result
# should correspond to the last two parts in package name, lowercased.
# Specifically, it should be the ISO 639-2 language code, followed by '::' and
# a language-specific tagset id. Example: 'cs::multext'.
#------------------------------------------------------------------------------
sub get_tagset_id
{
    return 'sl::conll';
}



#------------------------------------------------------------------------------
# Creates atomic drivers for surface features.
#------------------------------------------------------------------------------
sub _create_atoms
{
    my $self = shift;
    my %atoms;
    # PART OF SPEECH ####################
    $atoms{pos} = $self->create_atom
    (
        'surfeature' => 'pos',
        'decode_map' =>
        {
            # example: V-B
            'Abbreviation'              => ['abbr' => 'abbr'],
            # Ordinal adjectives, unlike qualificative, cannot be graded. Interset currently does not provide for this distinction.
            # example qualificative: boljše, kasnejšimi, revnejših, pomembnejše, močnejšo
            'Adjective-qualificative'   => ['pos' => 'adj'],
            # example ordinal: mali, partijske, zunanjim, srednjih, azijskimi
            'Adjective-ordinal'         => ['pos' => 'adj', 'other' => {'adjtype' => 'ordinal'}],
            # example possessive: O'Brienovih, Časnikovih, nageljnovimi, dečkovih, starčeve
            'Adjective-possessive'      => ['pos' => 'adj', 'poss' => 'poss'],
            # example: nanj, v, proti
            'Adposition-preposition'    => ['pos' => 'adp', 'adpostype' => 'prep'],
            # example: več, hitro, najbolj
            'Adverb-general'            => ['pos' => 'adv'],
            # example: in, pa, ali, a
            'Conjunction-coordinating'  => ['pos' => 'conj', 'conjtype' => 'coor'],
            # example: da, ki, kot, ko, če
            'Conjunction-subordinating' => ['pos' => 'conj', 'conjtype' => 'sub'],
            # example: oh, pozor
            'Interjection'              => ['pos' => 'int'],
            # example: ploščici, sil, neznankama, stvari, prsi
            'Noun-common'               => ['pos' => 'noun', 'nountype' => 'com'],
            # example: Winston, Parsons, Syme, O'Brien, Goldstein
            'Noun-proper'               => ['pos' => 'noun', 'nountype' => 'prop'],
            # example cardinal: eno, dve, tri
            'Numeral-cardinal'          => ['pos' => 'num', 'numtype' => 'card'],
            # example multiple: dvojno
            'Numeral-multiple'          => ['pos' => 'adv', 'numtype' => 'mult'],
            # example ordinal: prvi, drugi, tretje, devetnajstega
            'Numeral-ordinal'           => ['pos' => 'adj', 'numtype' => 'ord'],
            # example special: dvoje, enkratnem
            'Numeral-special'           => ['pos' => 'num', 'numtype' => 'gen'],
            # example: , . " - ?
            'PUNC'                      => ['pos' => 'punc'],
            # example: ne, pa, še, že, le
            'Particle'                  => ['pos' => 'part'],
            # example demonstrative: take, tem, tistih, teh, takimi
            'Pronoun-demonstrative'     => ['pos' => 'noun|adj', 'prontype' => 'dem'],
            # example general: vsakdo, obe, vse, vsemi, vsakih
            'Pronoun-general'           => ['pos' => 'noun|adj', 'prontype' => 'tot'],
            # example indefinite: koga, nekoga, nekatere, druge, isti
            'Pronoun-indefinite'        => ['pos' => 'noun|adj', 'prontype' => 'ind'],
            # example interrogative: koga, česa, čem, kaj, koliko
            'Pronoun-interrogative'     => ['pos' => 'noun|adj', 'prontype' => 'int'],
            # example negative: nič, nikakršne, nobeni, nobenega, nobenem
            'Pronoun-negative'          => ['pos' => 'noun|adj', 'prontype' => 'neg'],
            # example personal: jaz, ti, on, ona, mi, vi, oni
            'Pronoun-personal'          => ['pos' => 'noun', 'prontype' => 'prs'],
            # example possessive: moj, tvoj, njegove, naše, vašo, njihove
            'Pronoun-possessive'        => ['pos' => 'adj', 'prontype' => 'prs', 'poss' => 'poss'],
            # example reflexive: sebe, se, sebi, si, seboj, svoj, svoja
            # Both reflexive and possessive reflexive pronouns are included in Pronoun-reflexive.
            # The possessive reflexives are recognized by Referent-Type=possessive.
            'Pronoun-reflexive'         => ['pos' => 'noun|adj', 'prontype' => 'prs', 'reflex' => 'reflex'],
            # example relative: kar, česar, čimer, kdorkoli, katerih, kakršna, kolikor
            'Pronoun-relative'          => ['pos' => 'noun|adj', 'prontype' => 'rel'],
            # example copula: bi, bova, bomo, bom, boste, boš, bosta, bodo, bo, sva, smo, nismo, sem, nisem, ste, si, nisi, sta, nista, so, niso, je, ni, bili, bila, bile, bil, bilo
            'Verb-copula'               => ['pos' => 'verb', 'verbtype' => 'cop'],
            # example main: vzemiva, dajmo, krčite, bodi, greva
            'Verb-main'                 => ['pos' => 'verb'],
            # example modal: moremo, hočem, želiš, dovoljene, mogla
            'Verb-modal'                => ['pos' => 'verb', 'verbtype' => 'mod']
        },
        'encode_map' =>
        {
            'pos' => { 'noun' => { 'nountype' => { 'prop' => 'Noun-proper',
                                                   '@'    => 'Noun-common' }},
                       'adj'  => { 'poss' => { 'poss' => 'Adjective-possessive',
                                               '@'    => { 'other/adjtype' => { 'ordinal' => 'Adjective-ordinal',
                                                                                '@'       => 'Adjective-qualificative' }}}},
                       'num'  => { 'numtype' => { 'ord'  => 'Numeral-ordinal',
                                                  'mult' => 'Numeral-multiple',
                                                  'gen'  => 'Numeral-special',
                                                  '@'    => 'Numeral-cardinal' }},
                       'verb' => { 'verbtype' => { 'cop' => 'Verb-copula',
                                                   'mod' => 'Verb-modal',
                                                   '@'   => 'Verb-main' }},
                       'adv'  => 'Adverb-general',
                       'adp'  => 'Adposition-preposition',
                       'conj' => { 'conjtype' => { 'sub' => 'Conjunction-subordinating',
                                                   '@'   => 'Conjunction-coordinating' }},
                       'part' => 'Particle',
                       'int'  => 'Interjection',
                       'punc' => 'Punctuation',
                       'sym'  => 'Punctuation',
                       '@'    => { 'abbr' => { 'abbr' => 'Abbreviation' }}}
        }
    );
    # DEGREE OF COMPARISON ####################
    $atoms{Degree} = $self->create_simple_atom
    (
        'intfeature' => 'degree',
        'simple_decode_map' =>
        {
            'positive'    => 'pos',
            'comparative' => 'comp',
            'superlative' => 'sup'
        }
    );
    # GENDER ####################
    $atoms{Gender} = $self->create_simple_atom
    (
        'intfeature' => 'gender',
        'simple_decode_map' =>
        {
            'masculine' => 'masc',
            'feminine'  => 'fem',
            'neuter'    => 'neut'
        }
    );
    # NUMBER ####################
    $atoms{Number} = $self->create_simple_atom
    (
        'intfeature' => 'number',
        'simple_decode_map' =>
        {
            'singular' => 'sing',
            'dual'     => 'dual',
            'plural'   => 'plur'
        }
    );
    # CASE ####################
    $atoms{Case} = $self->create_simple_atom
    (
        'intfeature' => 'case',
        'simple_decode_map' =>
        {
            'nominative'   => 'nom',
            'genitive'     => 'gen',
            'dative'       => 'dat',
            'accusative'   => 'acc',
            'locative'     => 'loc',
            'instrumental' => 'ins'
        }
    );
    # FORMATION OF PREPOSITIONS ####################
    $atoms{Formation} = $self->create_simple_atom
    (
        'intfeature' => 'adpostype',
        'simple_decode_map' =>
        {
            'simple'   => 'prep',
            'compound' => 'comprep'
        }
    );
    # FORMAT OF NUMERALS ####################
    $atoms{Form} = $self->create_simple_atom
    (
        'intfeature' => 'numform',
        'simple_decode_map' =>
        {
            'digit'  => 'digit',
            'letter' => 'word'
        }
    );
    # SYNTACTIC TYPE ####################
    # Applies solely to pronouns.
    # nominal|adjectival
    $atoms{'Syntactic-Type'} = $self->create_simple_atom
    (
        'intfeature' => 'pos',
        'simple_decode_map' =>
        {
            'nominal'    => 'noun',
            'adjectival' => 'adj'
        }
    );
    # CLITIC ####################
    # no examples:  mene meni tebe njiju njih njo njej nje njega njemu sebe sebi
    # yes examples: me   mi   te   ju    jih  jo  ji   je  ga    mu    se   si
    # I am taking the same approach as in cs::pdt.
    # In future we may prefer to introduce a new 'clitic' feature in Interset.
    $atoms{Clitic} = $self->create_simple_atom
    (
        'intfeature' => 'variant',
        'simple_decode_map' =>
        {
            'yes' => 'short',
            'no'  => ''
        }
    );
    # POSSESSOR'S NUMBER ####################
    $atoms{'Owner-Number'} = $self->create_simple_atom
    (
        'intfeature' => 'possnumber',
        'simple_decode_map' =>
        {
            'singular' => 'sing',
            'dual'     => 'dual',
            'plural'   => 'plur'
        }
    );
    # POSSESSOR'S GENDER ####################
    $atoms{'Owner-Gender'} = $self->create_simple_atom
    (
        'intfeature' => 'possgender',
        'simple_decode_map' =>
        {
            'masculine' => 'masc',
            'feminine'  => 'fem'
        }
    );
    # REFERENT TYPE ####################
    # This feature is used to subclassify pronouns:
    # personal|possessive
    $atoms{'Referent-Type'} = $self->create_simple_atom
    (
        'intfeature' => 'poss',
        'simple_decode_map' =>
        {
            'personal'   => '',
            'possessive' => 'poss'
        }
    );
    # VERB FORM ####################
    $atoms{VForm} = $self->create_atom
    (
        'surfeature' => 'verbform',
        'decode_map' =>
        {
            # biti, videti, vedeti, spomniti, reči
            'infinitive'  => ['verbform' => 'inf'],
            # ima, pomeni, govori, opazuje, obstaja
            'indicative'  => ['verbform' => 'fin', 'mood' => 'ind'],
            # pokaži, bodi, drži, prosi, zavračaj
            'imperative'  => ['verbform' => 'fin', 'mood' => 'imp'],
            # bi
            'conditional' => ['verbform' => 'fin', 'mood' => 'cnd'],
            # imel, vedel, rekel, videl, pomislil
            # prepričan, poročen, pomešan, opremljen, določen
            'participle'  => ['verbform' => 'part'],
            # gledat
            # (Si šel včeraj gledat obešanje ujetnikov?)
            'supine'      => ['verbform' => 'sup']
        },
        'encode_map' =>
        {
            'verbform' => { 'inf'  => 'infinitive',
                            'fin'  => { 'mood' => { 'ind' => 'indicative',
                                                    'imp' => 'imperative',
                                                    'cnd' => 'conditional' }},
                            'part' => 'participle',
                            'sup'  => 'supine' }
        }
    );
    # TENSE ####################
    $atoms{Tense} = $self->create_simple_atom
    (
        'intfeature' => 'tense',
        'simple_decode_map' =>
        {
            'past'    => 'past',
            'present' => 'pres',
            'future'  => 'fut'
        }
    );
    # PERSON ####################
    $atoms{Person} = $self->create_simple_atom
    (
        'intfeature' => 'person',
        'simple_decode_map' =>
        {
            'first'  => '1',
            'second' => '2',
            'third'  => '3'
        }
    );
    # NEGATIVENESS ####################
    $atoms{Negative} = $self->create_simple_atom
    (
        'intfeature' => 'negativeness',
        'simple_decode_map' =>
        {
            'yes' => 'neg',
            'no'  => 'pos'
        }
    );
    # VOICE ####################
    $atoms{Voice} = $self->create_simple_atom
    (
        'intfeature' => 'voice',
        'simple_decode_map' =>
        {
            'active'  => 'act',
            'passive' => 'pass'
        }
    );
    return \%atoms;
}



#------------------------------------------------------------------------------
# Creates the list of all surface CoNLL features that can appear in the FEATS
# column. This list will be used in decode().
#------------------------------------------------------------------------------
sub _create_features_all
{
    my $self = shift;
    my @features = ('pos', 'gender', 'number', 'case', 'person', 'tense', 'mood',
                    'degree', 'alt', 'possessor', 'prontype', 'definiteness', 'numtype', 'anglefeature', 'sam', 'co', 'transcat');
    return \@features;
}



#------------------------------------------------------------------------------
# Creates the list of surface CoNLL features that can appear in the FEATS
# column with particular parts of speech. This list will be used in encode().
#------------------------------------------------------------------------------
sub _create_features_pos
{
    my $self = shift;
    my %features =
    (
        'adj'       => ['anglefeature', 'transcat', 'numtype', 'alt', 'degree', 'gender', 'number'],
        'adv'       => ['prontype', 'transcat', 'anglefeature', 'sam', 'co', 'alt', 'degree'],
        'art'       => ['sam', 'alt', 'definiteness', 'gender', 'number'],
        'conj-c'    => ['co'],
        'conj-s'    => ['transcat'],
        'n'         => ['anglefeature', 'transcat', 'alt', 'gender', 'number'],
        'num'       => ['transcat', 'sam', 'alt', 'numtype', 'gender', 'number'],
        'pp'        => ['sam'],
        'pron-det'  => ['transcat', 'sam', 'possessor', 'prontype', 'definiteness', 'degree', 'gender', 'number'],
        'pron-indp' => ['sam', 'alt', 'prontype', 'gender', 'number'],
        'pron-pers' => ['anglefeature', 'sam', 'prontype', 'gender', 'person', 'case'],
        'prop'      => ['anglefeature', 'alt', 'gender', 'number'],
        'prp'       => ['sam', 'transcat', 'co', 'alt'],
        'v-fin'     => ['anglefeature', 'transcat', 'alt', 'tense', 'person', 'mood'],
        'v-ger'     => ['anglefeature', 'alt'],
        'v-inf'     => ['anglefeature', 'transcat', 'alt', 'person'],
        'v-pcp'     => ['anglefeature', 'transcat', 'alt', 'gender', 'number']
    );
    return \%features;
}



#------------------------------------------------------------------------------
# Decodes a physical tag (string) and returns the corresponding feature
# structure.
#------------------------------------------------------------------------------
sub decode
{
    my $self = shift;
    my $tag = shift;
    # Preprocess the tag. Processing of some features depends on processing of some other features.
    # For adverbs, <dem> almost always comes together with <quant>.
    # There was one occurrence of <dem> without <quant> (an error?) and it also came with the word "tão".
    $tag =~ s/(adv\s+<dem>)\|<quant>/$1/;
    $tag =~ s/<rel>\|<quant>/<relquant>/;
    $tag =~ s/<interr>\|<quant>/<intquant>/;
    $tag =~ s/<poss\|([123](S|P|S\/P))>/<poss$1>/;
    my $fs = Lingua::Interset::FeatureStructure->new();
    $fs->set_tagset('pt::conll');
    my $atoms = $self->atoms();
    # Three components, and the first two are identical: pos, pos, features.
    # example: N\tN\tsoort|ev|neut
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    # The underscore character is used if there are no features.
    $features = '' if($features eq '_');
    my @features = split(/\|/, $features);
    $atoms->{pos}->decode_and_merge_hard($subpos, $fs);
    foreach my $feature (@features)
    {
        $atoms->{feature}->decode_and_merge_hard($feature, $fs);
    }
    return $fs;
}



#------------------------------------------------------------------------------
# Takes feature structure and returns the corresponding physical tag (string).
#------------------------------------------------------------------------------
sub encode
{
    my $self = shift;
    my $fs = shift; # Lingua::Interset::FeatureStructure
    my $atoms = $self->atoms();
    my $subpos = $atoms->{pos}->encode($fs);
    my $pos = $subpos;
    $pos =~ s/-.*//;
    my $fpos = $subpos;
    my $feature_names = $self->get_feature_names($fpos);
    my $value_only = 1;
    my $tag = $self->encode_conll($fs, $pos, $subpos, $feature_names, $value_only);
    # Postprocess the tag. Processing of some features depends on processing of some other features.
    # For adverbs, <dem> almost always comes together with <quant>.
    # There was one occurrence of <dem> without <quant> (an error?) and it also came with the word "tão".
    $tag =~ s/<poss([123](S|P|S\/P))>/<poss|$1>/;
    $tag =~ s/<intquant>/<interr>|<quant>/;
    $tag =~ s/<relquant>/<rel>|<quant>/;
    $tag =~ s/(adv\s+<dem>)/$1|<quant>/;
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# Tags were collected from the corpus, 671 distinct tags found.
# Cleaned up suspicious combinations of features that were hard to replicate.
# 564 tags survived.
#------------------------------------------------------------------------------
sub list
{
    my $self = shift;
    my $list = <<end_of_list
?	?	_
adj	adj	<ALT>|<SUP>|M|S
adj	adj	<ALT>|F|P
adj	adj	<ALT>|F|S
adj	adj	<ALT>|M|S
adj	adj	<DERP>|<n>|M|P
adj	adj	<DERP>|F|P
adj	adj	<DERP>|F|S
adj	adj	<DERP>|M|P
adj	adj	<DERP>|M|S
adj	adj	<DERS>|<n>|M|P
adj	adj	<DERS>|F|P
adj	adj	<DERS>|F|S
adj	adj	<DERS>|M|P
adj	adj	<DERS>|M|S
adj	adj	<KOMP>|F|P
adj	adj	<KOMP>|F|S
adj	adj	<KOMP>|M/F|S
adj	adj	<KOMP>|M|P
adj	adj	<KOMP>|M|S
adj	adj	<NUM-ord>|F|P
adj	adj	<NUM-ord>|F|S
adj	adj	<NUM-ord>|M/F|S
adj	adj	<NUM-ord>|M|P
adj	adj	<NUM-ord>|M|S
adj	adj	<SUP>|F|P
adj	adj	<SUP>|F|S
adj	adj	<SUP>|M|P
adj	adj	<SUP>|M|S
adj	adj	<hyfen>|F|P
adj	adj	<n>|<KOMP>|F|P
adj	adj	<n>|<KOMP>|F|S
adj	adj	<n>|<KOMP>|M|P
adj	adj	<n>|<KOMP>|M|S
adj	adj	<n>|<NUM-ord>|F|P
adj	adj	<n>|<NUM-ord>|F|S
adj	adj	<n>|<NUM-ord>|M|P
adj	adj	<n>|<NUM-ord>|M|S
adj	adj	<n>|<SUP>|F|P
adj	adj	<n>|<SUP>|F|S
adj	adj	<n>|<SUP>|M|P
adj	adj	<n>|<SUP>|M|S
adj	adj	<n>|F|P
adj	adj	<n>|F|S
adj	adj	<n>|M/F|P
adj	adj	<n>|M/F|S
adj	adj	<n>|M|P
adj	adj	<n>|M|S
adj	adj	<prop>|<NUM-ord>|M|S
adj	adj	<prop>|F|P
adj	adj	<prop>|F|S
adj	adj	<prop>|M/F|S
adj	adj	<prop>|M|P
adj	adj	<prop>|M|S
adj	adj	F|P
adj	adj	F|S
adj	adj	M/F|P
adj	adj	M/F|S
adj	adj	M/F|S/P
adj	adj	M|P
adj	adj	M|S
adv	adv	<-sam>
adv	adv	<ALT>
adv	adv	<DERS>
adv	adv	<KOMP>
adv	adv	<SUP>
adv	adv	<co-acc>
adv	adv	<co-advl>
adv	adv	<co-prparg>
adv	adv	<co-sc>
adv	adv	<dem>|<quant>
adv	adv	<dem>|<quant>|<KOMP>
adv	adv	<foc>
adv	adv	<interr>
adv	adv	<interr>|<ks>
adv	adv	<kc>
adv	adv	<kc>|<-sam>
adv	adv	<kc>|<KOMP>
adv	adv	<kc>|<co-acc>
adv	adv	<kc>|<co-advl>
adv	adv	<kc>|<co-pass>
adv	adv	<kc>|<co-piv>
adv	adv	<kc>|<foc>
adv	adv	<ks>
adv	adv	<n>|<KOMP>
adv	adv	<prp>
adv	adv	<quant>
adv	adv	<quant>|<KOMP>
adv	adv	<quant>|<det>
adv	adv	<rel>
adv	adv	<rel>|<ks>
adv	adv	<rel>|<prp>
adv	adv	<rel>|<prp>|<co-advl>
adv	adv	<rel>|<quant>
adv	adv	<sam->
adv	adv	_
art	art	<-sam>|<artd>|F|P
art	art	<-sam>|<artd>|F|S
art	art	<-sam>|<artd>|M|P
art	art	<-sam>|<artd>|M|S
art	art	<-sam>|<arti>|F|S
art	art	<-sam>|<arti>|M|S
art	art	<-sam>|F|P
art	art	<-sam>|F|S
art	art	<-sam>|M|S
art	art	<ALT>|<artd>|F|S
art	art	<ALT>|F|S
art	art	<artd>|F|P
art	art	<artd>|F|S
art	art	<artd>|M|P
art	art	<artd>|M|S
art	art	<arti>|F|S
art	art	<arti>|M|S
art	art	F|P
art	art	F|S
art	art	M|P
art	art	M|S
conj	conj-c	<co-acc>
conj	conj-c	<co-advl>
conj	conj-c	<co-advo>
conj	conj-c	<co-advs>
conj	conj-c	<co-app>
conj	conj-c	<co-fmc>
conj	conj-c	<co-ger>
conj	conj-c	<co-inf>
conj	conj-c	<co-oc>
conj	conj-c	<co-pass>
conj	conj-c	<co-pcv>
conj	conj-c	<co-piv>
conj	conj-c	<co-postad>
conj	conj-c	<co-postnom>
conj	conj-c	<co-pred>
conj	conj-c	<co-prenom>
conj	conj-c	<co-prparg>
conj	conj-c	<co-sc>
conj	conj-c	<co-subj>
conj	conj-c	<co-vfin>
conj	conj-c	_
conj	conj-s	<prp>
conj	conj-s	_
ec	ec	_
in	in	_
n	n	<ALT>|F|S
n	n	<ALT>|M|P
n	n	<ALT>|M|S
n	n	<DERP>|F|P
n	n	<DERP>|F|S
n	n	<DERP>|M|P
n	n	<DERP>|M|S
n	n	<DERS>|F|P
n	n	<DERS>|F|S
n	n	<DERS>|M|P
n	n	<DERS>|M|S
n	n	<hyfen>|F|S
n	n	<hyfen>|M|P
n	n	<hyfen>|M|S
n	n	<prop>|F|P
n	n	<prop>|F|S
n	n	<prop>|M/F|S
n	n	<prop>|M|P
n	n	<prop>|M|S
n	n	F|P
n	n	F|S
n	n	F|S/P
n	n	M/F|P
n	n	M/F|S
n	n	M|P
n	n	M|S
n	n	M|S/P
num	num	<-sam>|<card>|M|S
num	num	<-sam>|M|S
num	num	<ALT>|<card>|M|P
num	num	<card>|F|P
num	num	<card>|F|S
num	num	<card>|M/F|P
num	num	<card>|M/F|S
num	num	<card>|M|P
num	num	<card>|M|S
num	num	<card>|M|S/P
num	num	<n>|<card>|M|P
num	num	<n>|<card>|M|S
num	num	<n>|M|P
num	num	<prop>|<card>|F|P
num	num	<prop>|<card>|M|P
num	num	F|P
num	num	M/F|P
num	num	M|P
num	num	M|S
pp	pp	<sam->
pp	pp	_
pron	pron-det	<-sam>|<dem>|F|P
pron	pron-det	<-sam>|<dem>|F|S
pron	pron-det	<-sam>|<dem>|M|P
pron	pron-det	<-sam>|<dem>|M|S
pron	pron-det	<-sam>|<diff>|F|P
pron	pron-det	<-sam>|<diff>|F|S
pron	pron-det	<-sam>|<diff>|M|P
pron	pron-det	<-sam>|<diff>|M|S
pron	pron-det	<-sam>|<quant>|F|P
pron	pron-det	<-sam>|<quant>|M|P
pron	pron-det	<dem>|<KOMP>|F|P
pron	pron-det	<dem>|<KOMP>|M|P
pron	pron-det	<dem>|F|P
pron	pron-det	<dem>|F|S
pron	pron-det	<dem>|M|P
pron	pron-det	<dem>|M|S
pron	pron-det	<diff>|F|P
pron	pron-det	<diff>|F|S
pron	pron-det	<diff>|M/F|S
pron	pron-det	<diff>|M|P
pron	pron-det	<diff>|M|S
pron	pron-det	<ident>|F|P
pron	pron-det	<ident>|F|S
pron	pron-det	<ident>|M|P
pron	pron-det	<ident>|M|S
pron	pron-det	<interr>|<quant>|F|P
pron	pron-det	<interr>|<quant>|M|P
pron	pron-det	<interr>|<quant>|M|S
pron	pron-det	<interr>|F|P
pron	pron-det	<interr>|F|S
pron	pron-det	<interr>|M/F|S
pron	pron-det	<interr>|M/F|S/P
pron	pron-det	<interr>|M|P
pron	pron-det	<interr>|M|S
pron	pron-det	<n>|<dem>|M|S
pron	pron-det	<poss|1P>|F|P
pron	pron-det	<poss|1P>|F|S
pron	pron-det	<poss|1P>|M|P
pron	pron-det	<poss|1P>|M|S
pron	pron-det	<poss|1S>|F|P
pron	pron-det	<poss|1S>|F|S
pron	pron-det	<poss|1S>|M|P
pron	pron-det	<poss|1S>|M|S
pron	pron-det	<poss|2P>|F|S
pron	pron-det	<poss|2P>|M|S
pron	pron-det	<poss|2S>|M|S
pron	pron-det	<poss|3P>|<si>|F|P
pron	pron-det	<poss|3P>|<si>|F|S
pron	pron-det	<poss|3P>|<si>|M|P
pron	pron-det	<poss|3P>|<si>|M|S
pron	pron-det	<poss|3P>|F|S
pron	pron-det	<poss|3P>|M|P
pron	pron-det	<poss|3P>|M|S
pron	pron-det	<poss|3S/P>|<si>|F|S
pron	pron-det	<poss|3S/P>|<si>|M|S
pron	pron-det	<poss|3S/P>|F|S
pron	pron-det	<poss|3S/P>|M|P
pron	pron-det	<poss|3S>|<si>|F|P
pron	pron-det	<poss|3S>|<si>|F|S
pron	pron-det	<poss|3S>|<si>|M|P
pron	pron-det	<poss|3S>|<si>|M|S
pron	pron-det	<poss|3S>|F|P
pron	pron-det	<poss|3S>|F|S
pron	pron-det	<poss|3S>|M|P
pron	pron-det	<poss|3S>|M|S
pron	pron-det	<quant>|<KOMP>|F|P
pron	pron-det	<quant>|<KOMP>|F|S
pron	pron-det	<quant>|<KOMP>|M/F|S/P
pron	pron-det	<quant>|<KOMP>|M|P
pron	pron-det	<quant>|<KOMP>|M|S
pron	pron-det	<quant>|<SUP>|M|S
pron	pron-det	<quant>|F|P
pron	pron-det	<quant>|F|S
pron	pron-det	<quant>|M/F|P
pron	pron-det	<quant>|M/F|S
pron	pron-det	<quant>|M/F|S/P
pron	pron-det	<quant>|M|P
pron	pron-det	<quant>|M|S
pron	pron-det	<rel>|F|P
pron	pron-det	<rel>|F|S
pron	pron-det	<rel>|M|P
pron	pron-det	<rel>|M|S
pron	pron-det	F|P
pron	pron-det	F|S
pron	pron-det	M/F|S
pron	pron-det	M|P
pron	pron-det	M|S
pron	pron-det	M|S/P
pron	pron-indp	<-sam>|<dem>|M|S
pron	pron-indp	<-sam>|<rel>|F|P
pron	pron-indp	<-sam>|<rel>|F|S
pron	pron-indp	<-sam>|<rel>|M|P
pron	pron-indp	<-sam>|<rel>|M|S
pron	pron-indp	<ALT>|<rel>|F|S
pron	pron-indp	<dem>|M/F|S/P
pron	pron-indp	<dem>|M|S
pron	pron-indp	<diff>|M|S
pron	pron-indp	<interr>|F|P
pron	pron-indp	<interr>|F|S
pron	pron-indp	<interr>|M/F|P
pron	pron-indp	<interr>|M/F|S
pron	pron-indp	<interr>|M/F|S/P
pron	pron-indp	<interr>|M|P
pron	pron-indp	<interr>|M|S
pron	pron-indp	<quant>|M/F|S
pron	pron-indp	<quant>|M|S
pron	pron-indp	<rel>|F|P
pron	pron-indp	<rel>|F|S
pron	pron-indp	<rel>|M/F|P
pron	pron-indp	<rel>|M/F|S
pron	pron-indp	<rel>|M/F|S/P
pron	pron-indp	<rel>|M|P
pron	pron-indp	<rel>|M|S
pron	pron-indp	F|S
pron	pron-indp	M/F|S
pron	pron-indp	M/F|S/P
pron	pron-indp	M|P
pron	pron-indp	M|S
pron	pron-indp	M|S/P
pron	pron-pers	<-sam>|<refl>|F|3S|PIV
pron	pron-pers	<-sam>|<refl>|M|3S|PIV
pron	pron-pers	<-sam>|F|1P|PIV
pron	pron-pers	<-sam>|F|1S|PIV
pron	pron-pers	<-sam>|F|3P|NOM
pron	pron-pers	<-sam>|F|3P|NOM/PIV
pron	pron-pers	<-sam>|F|3P|PIV
pron	pron-pers	<-sam>|F|3S|ACC
pron	pron-pers	<-sam>|F|3S|NOM/PIV
pron	pron-pers	<-sam>|F|3S|PIV
pron	pron-pers	<-sam>|M/F|2P|PIV
pron	pron-pers	<-sam>|M|3P|NOM
pron	pron-pers	<-sam>|M|3P|NOM/PIV
pron	pron-pers	<-sam>|M|3P|PIV
pron	pron-pers	<-sam>|M|3S|ACC
pron	pron-pers	<-sam>|M|3S|NOM
pron	pron-pers	<-sam>|M|3S|NOM/PIV
pron	pron-pers	<-sam>|M|3S|PIV
pron	pron-pers	<hyfen>|<refl>|F|3S|ACC
pron	pron-pers	<hyfen>|<refl>|M/F|1S|DAT
pron	pron-pers	<hyfen>|F|3S|ACC
pron	pron-pers	<hyfen>|M/F|3S/P|ACC
pron	pron-pers	<hyfen>|M|3S|ACC
pron	pron-pers	<hyfen>|M|3S|DAT
pron	pron-pers	<reci>|F|3P|ACC
pron	pron-pers	<reci>|M|3P|ACC
pron	pron-pers	<refl>|<coll>|F|3P|ACC
pron	pron-pers	<refl>|<coll>|M/F|3P|ACC
pron	pron-pers	<refl>|<coll>|M|3P|ACC
pron	pron-pers	<refl>|<coll>|M|3S|ACC
pron	pron-pers	<refl>|F|1S|ACC
pron	pron-pers	<refl>|F|1S|DAT
pron	pron-pers	<refl>|F|3P|ACC
pron	pron-pers	<refl>|F|3S|ACC
pron	pron-pers	<refl>|F|3S|DAT
pron	pron-pers	<refl>|F|3S|PIV
pron	pron-pers	<refl>|M/F|1P|ACC
pron	pron-pers	<refl>|M/F|1P|ACC/DAT
pron	pron-pers	<refl>|M/F|1P|DAT
pron	pron-pers	<refl>|M/F|1S|ACC
pron	pron-pers	<refl>|M/F|1S|DAT
pron	pron-pers	<refl>|M/F|2P|DAT
pron	pron-pers	<refl>|M/F|3P|ACC
pron	pron-pers	<refl>|M/F|3S/P|ACC
pron	pron-pers	<refl>|M/F|3S/P|ACC/DAT
pron	pron-pers	<refl>|M/F|3S/P|DAT
pron	pron-pers	<refl>|M/F|3S/P|PIV
pron	pron-pers	<refl>|M/F|3S|ACC
pron	pron-pers	<refl>|M/F|3S|PIV
pron	pron-pers	<refl>|M|1P|ACC
pron	pron-pers	<refl>|M|1P|DAT
pron	pron-pers	<refl>|M|1S|ACC
pron	pron-pers	<refl>|M|1S|DAT
pron	pron-pers	<refl>|M|2S|ACC
pron	pron-pers	<refl>|M|3P|ACC
pron	pron-pers	<refl>|M|3P|DAT
pron	pron-pers	<refl>|M|3P|PIV
pron	pron-pers	<refl>|M|3S/P|ACC
pron	pron-pers	<refl>|M|3S|ACC
pron	pron-pers	<refl>|M|3S|DAT
pron	pron-pers	<refl>|M|3S|PIV
pron	pron-pers	<sam->|M/F|3S|DAT
pron	pron-pers	F|1P|NOM/PIV
pron	pron-pers	F|1P|PIV
pron	pron-pers	F|1S|ACC
pron	pron-pers	F|1S|NOM
pron	pron-pers	F|1S|PIV
pron	pron-pers	F|3P|ACC
pron	pron-pers	F|3P|DAT
pron	pron-pers	F|3P|NOM
pron	pron-pers	F|3P|NOM/PIV
pron	pron-pers	F|3P|PIV
pron	pron-pers	F|3S/P|ACC
pron	pron-pers	F|3S|ACC
pron	pron-pers	F|3S|DAT
pron	pron-pers	F|3S|NOM
pron	pron-pers	F|3S|NOM/PIV
pron	pron-pers	F|3S|PIV
pron	pron-pers	M/F|1P|ACC
pron	pron-pers	M/F|1P|DAT
pron	pron-pers	M/F|1P|NOM
pron	pron-pers	M/F|1P|NOM/PIV
pron	pron-pers	M/F|1P|PIV
pron	pron-pers	M/F|1S|ACC
pron	pron-pers	M/F|1S|DAT
pron	pron-pers	M/F|1S|NOM
pron	pron-pers	M/F|1S|PIV
pron	pron-pers	M/F|2P|ACC
pron	pron-pers	M/F|2P|NOM
pron	pron-pers	M/F|2P|PIV
pron	pron-pers	M/F|3P|ACC
pron	pron-pers	M/F|3P|DAT
pron	pron-pers	M/F|3P|NOM
pron	pron-pers	M/F|3S/P|ACC
pron	pron-pers	M/F|3S|ACC
pron	pron-pers	M/F|3S|DAT
pron	pron-pers	M/F|3S|NOM
pron	pron-pers	M/F|3S|NOM/PIV
pron	pron-pers	M|1P|ACC
pron	pron-pers	M|1P|DAT
pron	pron-pers	M|1P|NOM
pron	pron-pers	M|1P|NOM/PIV
pron	pron-pers	M|1S|ACC
pron	pron-pers	M|1S|DAT
pron	pron-pers	M|1S|NOM
pron	pron-pers	M|1S|PIV
pron	pron-pers	M|2S|ACC
pron	pron-pers	M|2S|PIV
pron	pron-pers	M|3P|ACC
pron	pron-pers	M|3P|DAT
pron	pron-pers	M|3P|NOM
pron	pron-pers	M|3P|NOM/PIV
pron	pron-pers	M|3P|PIV
pron	pron-pers	M|3S
pron	pron-pers	M|3S/P|ACC
pron	pron-pers	M|3S|ACC
pron	pron-pers	M|3S|DAT
pron	pron-pers	M|3S|NOM
pron	pron-pers	M|3S|NOM/PIV
pron	pron-pers	M|3S|PIV
prop	prop	<ALT>|F|S
prop	prop	<ALT>|M|S
prop	prop	<DERS>|M|S
prop	prop	<hyfen>|F|P
prop	prop	<hyfen>|F|S
prop	prop	<hyfen>|M|S
prop	prop	F|P
prop	prop	F|S
prop	prop	M/F|P
prop	prop	M/F|S
prop	prop	M/F|S/P
prop	prop	M|P
prop	prop	M|S
prp	prp	<ALT>
prp	prp	<kc>
prp	prp	<kc>|<co-acc>
prp	prp	<kc>|<co-prparg>
prp	prp	<ks>
prp	prp	<sam->
prp	prp	<sam->|<co-acc>
prp	prp	<sam->|<kc>
prp	prp	_
punc	punc	_
v	v-fin	<ALT>|IMPF|3S|IND
v	v-fin	<ALT>|IMPF|3S|SUBJ
v	v-fin	<ALT>|PR|3S|IND
v	v-fin	<ALT>|PS|3S|IND
v	v-fin	<ALT>|PS|3S|SUBJ
v	v-fin	<DERP>|PR|1S|IND
v	v-fin	<DERP>|PR|3P|IND
v	v-fin	<DERP>|PR|3S|IND
v	v-fin	<DERP>|PS|3S|IND
v	v-fin	<hyfen>|COND|1S
v	v-fin	<hyfen>|COND|3S
v	v-fin	<hyfen>|FUT|3S|IND
v	v-fin	<hyfen>|IMPF|1S|IND
v	v-fin	<hyfen>|IMPF|3P|IND
v	v-fin	<hyfen>|IMPF|3S|IND
v	v-fin	<hyfen>|MQP|1/3S|IND
v	v-fin	<hyfen>|MQP|3S|IND
v	v-fin	<hyfen>|PR|1/3S|SUBJ
v	v-fin	<hyfen>|PR|1P|IND
v	v-fin	<hyfen>|PR|1S|IND
v	v-fin	<hyfen>|PR|3P|IND
v	v-fin	<hyfen>|PR|3P|SUBJ
v	v-fin	<hyfen>|PR|3S|IND
v	v-fin	<hyfen>|PR|3S|SUBJ
v	v-fin	<hyfen>|PS/MQP|3P|IND
v	v-fin	<hyfen>|PS|1S|IND
v	v-fin	<hyfen>|PS|2S|IND
v	v-fin	<hyfen>|PS|3P|IND
v	v-fin	<hyfen>|PS|3S|IND
v	v-fin	<n>|PR|3S|IND
v	v-fin	COND|1/3S
v	v-fin	COND|1P
v	v-fin	COND|1S
v	v-fin	COND|3P
v	v-fin	COND|3S
v	v-fin	FUT|1/3S|SUBJ
v	v-fin	FUT|1P|IND
v	v-fin	FUT|1P|SUBJ
v	v-fin	FUT|1S|IND
v	v-fin	FUT|1S|SUBJ
v	v-fin	FUT|2S|IND
v	v-fin	FUT|3P|IND
v	v-fin	FUT|3P|SUBJ
v	v-fin	FUT|3S|IND
v	v-fin	FUT|3S|SUBJ
v	v-fin	IMPF|1/3S|IND
v	v-fin	IMPF|1/3S|SUBJ
v	v-fin	IMPF|1P|IND
v	v-fin	IMPF|1P|SUBJ
v	v-fin	IMPF|1S|IND
v	v-fin	IMPF|1S|SUBJ
v	v-fin	IMPF|3P|IND
v	v-fin	IMPF|3P|SUBJ
v	v-fin	IMPF|3S|IND
v	v-fin	IMPF|3S|SUBJ
v	v-fin	IMP|2S
v	v-fin	MQP|1/3S|IND
v	v-fin	MQP|1S|IND
v	v-fin	MQP|3P|IND
v	v-fin	MQP|3S|IND
v	v-fin	PR/PS|1P|IND
v	v-fin	PR|1/3S|SUBJ
v	v-fin	PR|1P|IND
v	v-fin	PR|1P|SUBJ
v	v-fin	PR|1S|IND
v	v-fin	PR|1S|SUBJ
v	v-fin	PR|2P|IND
v	v-fin	PR|2S|IND
v	v-fin	PR|2S|SUBJ
v	v-fin	PR|3P|IND
v	v-fin	PR|3P|SUBJ
v	v-fin	PR|3S
v	v-fin	PR|3S|IND
v	v-fin	PR|3S|SUBJ
v	v-fin	PS/MQP|3P|IND
v	v-fin	PS|1/3S|IND
v	v-fin	PS|1P|IND
v	v-fin	PS|1S|IND
v	v-fin	PS|2S|IND
v	v-fin	PS|3P|IND
v	v-fin	PS|3S|IND
v	v-ger	<ALT>
v	v-ger	<hyfen>
v	v-ger	_
v	v-inf	1/3S
v	v-inf	1P
v	v-inf	1S
v	v-inf	3P
v	v-inf	3S
v	v-inf	<DERP>
v	v-inf	<DERS>
v	v-inf	<hyfen>
v	v-inf	<hyfen>|1S
v	v-inf	<hyfen>|3P
v	v-inf	<hyfen>|3S
v	v-inf	<n>
v	v-inf	<n>|3S
v	v-inf	_
v	v-pcp	<ALT>|F|S
v	v-pcp	<DERP>|M|P
v	v-pcp	<DERS>|F|P
v	v-pcp	<DERS>|M|S
v	v-pcp	<n>|F|P
v	v-pcp	<n>|F|S
v	v-pcp	<n>|M|P
v	v-pcp	<n>|M|S
v	v-pcp	<prop>|F|S
v	v-pcp	<prop>|M|P
v	v-pcp	F|P
v	v-pcp	F|S
v	v-pcp	M|P
v	v-pcp	M|S
end_of_list
    ;
    # Protect from editors that replace tabs by spaces.
    $list =~ s/ \s+/\t/sg;
    my @list = split(/\r?\n/, $list);
    return \@list;
}



1;

=head1 SYNOPSIS

  use Lingua::Interset::Tagset::PT::Conll;
  my $driver = Lingua::Interset::Tagset::PT::Conll->new();
  my $fs = $driver->decode("n\tn\tM|S");

or

  use Lingua::Interset qw(decode);
  my $fs = decode('pt::conll', "n\tn\tM|S");

=head1 DESCRIPTION

Interset driver for the Portuguese tagset of the CoNLL 2006 Shared Task.
CoNLL tagsets in Interset are traditionally three values separated by tabs.
The values come from the CoNLL columns CPOS, POS and FEAT. For Portuguese,
these values are derived from the tagset of the Bosque treebank (part of Floresta sintá(c)tica).

=head1 SEE ALSO

L<Lingua::Interset>,
L<Lingua::Interset::Tagset>,
L<Lingua::Interset::Tagset::Conll>,
L<Lingua::Interset::FeatureStructure>

=cut
