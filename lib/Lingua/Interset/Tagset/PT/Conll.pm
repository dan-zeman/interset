# ABSTRACT: Driver for the Portuguese tagset of the CoNLL 2006 Shared Task (derived from the Bosque / Floresta sintá(c)tica treebank).
# Copyright © 2007-2009, 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset::Tagset::PT::Conll;
use strict;
use warnings;
our $VERSION = '2.037';

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
    return 'pt::conll';
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
            # n = common noun # example: revivalismo
            'n'         => ['pos' => 'noun', 'nountype' => 'com'],
            # prop = proper noun # example: Castro_Verde, João_Pedro_Henriques
            'prop'      => ['pos' => 'noun', 'nountype' => 'prop'],
            # adj = adjective # example: refrescante, algarvio
            'adj'       => ['pos' => 'adj'],
            # art = article # example: a, as, o, os, uma, um
            'art'       => ['pos' => 'adj', 'prontype' => 'art'],
            # pron-pers = personal # example: ela, elas, ele, eles, eu, nós, se, tu, você, vós
            'pron-pers' => ['pos' => 'noun', 'prontype' => 'prs'],
            # pron-det = determiner # example: algo, ambos, bastante, demais, este, menos, nosso, o, que, todo_o
            'pron-det'  => ['pos' => 'adj', 'prontype' => 'ind'],
            # pron-indp = independent # example: algo, aquilo, cada_qual, o, o_que, que, todo_o_mundo, um_pouco
            'pron-indp' => ['pos' => 'noun', 'prontype' => 'ind'],
            # num = number # example: 0,05, cento_e_quatro, cinco, setenta_e_dois, um, zero
            'num'       => ['pos' => 'num'],
            # v-inf = infinitive # example: abafar, abandonar, abastecer...
            'v-inf'     => ['pos' => 'verb', 'verbform' => 'inf'],
            # v-fin = finite # example: abafaram, abalou, abandonará...
            'v-fin'     => ['pos' => 'verb', 'verbform' => 'fin'],
            # v-pcp = participle # example: abafado, abalada, abandonadas...
            'v-pcp'     => ['pos' => 'verb', 'verbform' => 'part'],
            # v-ger = gerund # example: abraçando, abrindo, acabando...
            'v-ger'     => ['pos' => 'verb', 'verbform' => 'ger'],
            # vp = verb phrase # 1 occurrence in CoNLL 2006 data ("existente"), looks like an error
            'vp'        => ['pos' => 'adj', 'other' => {'pos' => 'vp'}],
            # adv = adverb # example: 20h45, abaixo, abertamente, a_bordo...
            'adv'       => ['pos' => 'adv'],
            # pp = prepositional phrase # example: ao_mesmo_tempo, de_acordo, por_último...
            'pp'        => ['pos' => 'adv', 'other' => {'pos' => 'pp'}],
            # prp = preposition # example: a, abaixo_de, ao, com, de, em, por, que...
            'prp'       => ['pos' => 'adp', 'adpostype' => 'prep'],
            # coordinating conjunction # example: e, mais, mas, nem, ou, quer, tampouco, tanto
            'conj-c'    => ['pos' => 'conj', 'conjtype' => 'coor'],
            # subordinating conjunction # example: a_fim_de_que, como, desde_que, para_que, que...
            'conj-s'    => ['pos' => 'conj', 'conjtype' => 'sub'],
            # in = interjection # example: adeus, ai, alô
            'in'        => ['pos' => 'int'],
            # ec = partial word # example: anti-, ex-, pós, pré-
            'ec'        => ['pos' => 'part', 'hyph' => 'hyph'],
            # punc = punctuation # example: --, -, ,, ;, :, !, ?:?...
            'punc'      => ['pos' => 'punc'],
            # ? = unknown # 2 occurrences in CoNLL 2006 data
            '?'         => [],
        },
        'encode_map' =>
        {
            'pos' => { 'noun' => { 'prontype' => { ''    => { 'nountype' => { 'prop' => 'prop',
                                                                              '@'    => 'n' }},
                                                   'prs' => 'pron-pers',
                                                   '@'   => 'pron-indp' }},
                       'adj'  => { 'prontype' => { ''    => { 'other/pos' => { 'vp' => 'vp',
                                                                               '@'  => 'adj' }},
                                                   'art' => 'art',
                                                   '@'   => 'pron-det' }},
                       'num'  => 'num',
                       'verb' => { 'verbform' => { 'inf'  => 'v-inf',
                                                   'fin'  => 'v-fin',
                                                   'part' => 'v-pcp',
                                                   'ger'  => 'v-ger' }},
                       'adv'  => { 'other/pos' => { 'pp' => 'pp',
                                                    '@'  => 'adv' }},
                       'adp'  => 'prp',
                       'conj' => { 'conjtype' => { 'sub' => 'conj-s',
                                                   '@'   => 'conj-c' }},
                       'part' => 'ec',
                       'int'  => 'in',
                       'punc' => 'punc',
                       'sym'  => 'punc',
                       '@'    => '?' }
        }
    );
    # GENDER ####################
    $atoms{gender} = $self->create_atom
    (
        'surfeature' => 'gender',
        'decode_map' =>
        {
            # gender = F|F/M|M|M/F
            'F'   => ['gender' => 'fem'],
            'F/M' => ['gender' => 'fem|masc'],
            'M'   => ['gender' => 'masc'],
            'M/F' => ['gender' => 'masc|fem']
        },
        'encode_map' =>
        {
            'gender' => { 'fem|masc' => 'F/M',
                          'fem'      => 'F',
                          'masc'     => 'M' }
        }
    );
    # NUMBER ####################
    $atoms{number} = $self->create_simple_atom
    (
        'intfeature' => 'number',
        'simple_decode_map' =>
        {
            # number = P|S|S/P
            'S'   => 'sing',
            'P'   => 'plur',
            'S/P' => ''
        }
    );
    # CASE ####################
    $atoms{case} = $self->create_atom
    (
        'surfeature' => 'case',
        'decode_map' =>
        {
            # case = ACC|ACC/DAT|DAT|NOM|NOM/PIV|PIV
            'NOM'     => ['case' => 'nom'],
            'NOM/PIV' => ['case' => 'nom|acc', 'prepcase' => 'pre'],
            'DAT'     => ['case' => 'dat'],
            'ACC/DAT' => ['case' => 'acc|dat'],
            'ACC'     => ['case' => 'acc'],
            # Note: PIV also occurs as the syntactic tag of prepositions heading prepositional objects.
            'PIV'     => ['case' => 'acc', 'prepcase' => 'pre']
        },
        'encode_map' =>
        {
            'case' => { 'acc|nom' => 'NOM/PIV',
                        'acc|dat' => 'ACC/DAT',
                        'nom'     => 'NOM',
                        'dat'     => 'DAT',
                        'acc'     => { 'prepcase' => { 'pre' => 'PIV',
                                                       '@'   => 'ACC' }}}
        }
    );
    # PERSON AND NUMBER ####################
    $atoms{person} = $self->create_atom
    (
        'surfeature' => 'person',
        'decode_map' =>
        {
            # person+number = 1/3S|1S|1P|2S|2P|3S|3S/P|3P
            # for possessives, this is the possnumber
            # elsewhere, this is the normal number
            '1/3S'  => ['person' => '1|3', 'number' => 'sing'],
            '1/3S>' => ['person' => '1|3', 'number' => 'sing'],
            '1S'    => ['person' => '1', 'number' => 'sing'],
            '1S>'   => ['person' => '1', 'number' => 'sing'],
            '1P'    => ['person' => '1', 'number' => 'plur'],
            '1P>'   => ['person' => '1', 'number' => 'plur'],
            '2S'    => ['person' => '2', 'number' => 'sing'],
            '2S>'   => ['person' => '2', 'number' => 'sing'],
            '2P'    => ['person' => '2', 'number' => 'plur'],
            '2P>'   => ['person' => '2', 'number' => 'plur'],
            '3S'    => ['person' => '3', 'number' => 'sing'],
            '3S>'   => ['person' => '3', 'number' => 'sing'],
            '3S/P'  => ['person' => '3'],
            '3S/P>' => ['person' => '3'],
            '3P'    => ['person' => '3', 'number' => 'plur'],
            '3P>'   => ['person' => '3', 'number' => 'plur'],
        },
        'encode_map' =>
        {
            'number' => { 'sing' => { 'person' => { '1|3' => '1/3S',
                                                    '1'   => '1S',
                                                    '2'   => '2S',
                                                    '@'   => '3S' }},
                          'plur' => { 'person' => { '1'   => '1P',
                                                    '2'   => '2P',
                                                    '@'   => '3P' }},
                          '@'    => '3S/P' }
        }
    );
    # MOOD AND TENSE ####################
    $atoms{tense} = $self->create_atom
    (
        'surfeature' => 'tense',
        'decode_map' =>
        {
            # tense/mood = COND|FUT|IMP|IMPF|IND|MQP|PR|PR/PS|PS|PS/MQP|SUBJ
            'IND'    => ['mood' => 'ind'],
            'IMP'    => ['mood' => 'imp'],
            'PR'     => ['tense' => 'pres'],
            'PR/PS'  => ['tense' => 'pres|past'],
            'PS'     => ['tense' => 'past'],
            'IMPF'   => ['tense' => 'imp'],
            'PS/MQP' => ['tense' => 'imp|pqp'],
            'MQP'    => ['tense' => 'pqp'],
            'FUT'    => ['tense' => 'fut'],
            'COND'   => ['mood' => 'cnd'],
            'SUBJ'   => ['mood' => 'sub']
        },
        'encode_map' =>
        {
            'tense' => { 'pres'      => 'PR',
                         'past|pres' => 'PR/PS',
                         'past'      => 'PS',
                         'imp'       => 'IMPF',
                         'imp|pqp'   => 'PS/MQP',
                         'pqp'       => 'MQP',
                         'fut'       => 'FUT',
                         '@'         => { 'mood' => { 'ind' => 'IND',
                                                      'imp' => 'IMP',
                                                      'cnd' => 'COND',
                                                      'sub' => 'SUBJ' }}}
        }
    );
    # MERGED ATOM TO DECODE ANY FEATURE VALUE ####################
    my @fatoms = map {$atoms{$_}} (@{$self->features_all()});
    $atoms{feature} = $self->create_merged_atom
    (
        'surfeature' => 'feature',
        'atoms'      => \@fatoms
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
    my @features = ('pos', 'adjtype', 'degree', 'adjform', 'advtype', 'function', 'definiteness', 'gender', 'case', 'conjtype', 'sconjtype', 'nountype', 'number',
                    'numtype', 'misctype', 'adpostype', 'prontype', 'pronoun', 'person', 'punctype', 'verbtype', 'verbform', 'subst');
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
        'Adj'   => ['adjtype', 'degree', 'adjform'],
        'Adv'   => ['advtype', 'function', 'degree', 'adjform'],
        'Art'   => ['definiteness', 'gender', 'case'],
        'Conj'  => ['conjtype', 'sconjtype'],
        'Misc'  => ['misctype'],
        'N'     => ['nountype', 'number', 'case'],
        'Num'   => ['numtype', 'definiteness', 'prontype', 'adjtype', 'degree', 'adjform'],
        'Prep'  => ['adpostype'],
        'Pron'  => ['prontype', 'person', 'number', 'case', 'adjtype', 'pronoun'],
        'Punc'  => ['punctype'],
        'V'     => ['verbtype', 'verbform', 'subst', 'person', 'number'],
        'Vpart' => ['verbtype', 'verbform', 'adjform']
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
    my $fs = Lingua::Interset::FeatureStructure->new();
    $fs->set_tagset('nl::conll');
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
    # The feature 'onbep' can mean indefinite pronoun or indefinite article.
    # If it is article, we want prontype=art, not prontype=ind.
    if($tag =~ m/^Art.*onbep/)
    {
        $fs->set('prontype', 'art');
        $fs->set('definiteness', 'ind');
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
    my $fpos = $subpos;
    $fpos = 'Vpart' if($fpos eq 'V' && $fs->is_participle());
    my $feature_names = $self->get_feature_names($fpos);
    my $pos = $subpos;
    my $value_only = 1;
    my $tag = $self->encode_conll($fs, $pos, $subpos, $feature_names, $value_only);
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# Tags were collected from the corpus, 745 distinct tags found.
# MWU (multi-word-unit) tags were removed because they are sequences of normal
# tags and we cannot support them.
# Total 198 tags survived.
# Total 208 tags after adding missing tags (without the 'other' feature etc.)
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
adj	adj	<DERP>|<DERS>|F|S
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
adj	adj	<error>|M|S
adj	adj	<hyfen>|F|P
adj	adj	<n>
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
adj	adj	_
adv	adv	<-sam>
adv	adv	<ALT>
adv	adv	<DERP>|<DERS>
adv	adv	<DERS>
adv	adv	<KOMP>
adv	adv	<SUP>
adv	adv	<co-acc>
adv	adv	<co-advl>
adv	adv	<co-prparg>
adv	adv	<co-sc>
adv	adv	<dem>
adv	adv	<dem>|<quant>
adv	adv	<dem>|<quant>|<KOMP>
adv	adv	<error>
adv	adv	<foc>
adv	adv	<interr>
adv	adv	<interr>|<ks>
adv	adv	<interr>|<quant>
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
adv	adv	<quant>|<KOMP>|F|P
adv	adv	<quant>|<det>
adv	adv	<rel>
adv	adv	<rel>|<ks>
adv	adv	<rel>|<ks>|<quant>
adv	adv	<rel>|<prp>
adv	adv	<rel>|<prp>|<co-advl>
adv	adv	<rel>|<quant>
adv	adv	<sam->
adv	adv	F|S
adv	adv	M|P
adv	adv	M|S
adv	adv	_
art	art	<-sam>|<artd>|F|P
art	art	<-sam>|<artd>|F|S
art	art	<-sam>|<artd>|M|P
art	art	<-sam>|<artd>|M|S
art	art	<-sam>|<artd>|P
art	art	<-sam>|<artd>|S
art	art	<-sam>|<arti>|F|S
art	art	<-sam>|<arti>|M|S
art	art	<-sam>|F|P
art	art	<-sam>|F|S
art	art	<-sam>|M|S
art	art	<ALT>|<artd>|F|S
art	art	<ALT>|F|S
art	art	<artd>
art	art	<artd>|F|P
art	art	<artd>|F|S
art	art	<artd>|M|P
art	art	<artd>|M|S
art	art	<arti>|F|S
art	art	<arti>|M|S
art	art	<dem>|F|S
art	art	<dem>|M|S
art	art	<error>|<arti>|F|S
art	art	F|P
art	art	F|S
art	art	M|P
art	art	M|S
art	art	P
art	art	S
art	art	_
conj	conj-c	<co-acc>
conj	conj-c	<co-advl>
conj	conj-c	<co-advo>
conj	conj-c	<co-advs>
conj	conj-c	<co-app>
conj	conj-c	<co-fmc>
conj	conj-c	<co-ger>
conj	conj-c	<co-inf>
conj	conj-c	<co-inf>|<co-fmc>
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
conj	conj-c	<co-vfin>|<co-fmc>
conj	conj-c	<fmc>
conj	conj-c	<quant>|<KOMP>
conj	conj-c	_
conj	conj-s	<co-prparg>
conj	conj-s	<kc>
conj	conj-s	<prp>
conj	conj-s	<rel>
conj	conj-s	_
ec	ec	_
in	in	F|S
in	in	M|S
in	in	PS|3S|IND
in	in	_
n	n	<ALT>|F|S
n	n	<ALT>|M|P
n	n	<ALT>|M|S
n	n	<DERP>|<DERS>|F|P
n	n	<DERP>|<DERS>|M|P
n	n	<DERP>|<DERS>|M|S
n	n	<DERP>|F|P
n	n	<DERP>|F|S
n	n	<DERP>|M|P
n	n	<DERP>|M|S
n	n	<DERS>|F|P
n	n	<DERS>|F|S
n	n	<DERS>|M|P
n	n	<DERS>|M|S
n	n	<NUM-ord>|F|S
n	n	<co-prparg>|M|P
n	n	<error>|F|P
n	n	<fmc>|F|S
n	n	<hyfen>|F|S
n	n	<hyfen>|M|P
n	n	<hyfen>|M|S
n	n	<n>|<NUM-ord>|F|S
n	n	<n>|M|P
n	n	<n>|M|S
n	n	<prop>|F|P
n	n	<prop>|F|S
n	n	<prop>|M/F|S
n	n	<prop>|M|P
n	n	<prop>|M|S
n	n	F
n	n	F|P
n	n	F|S
n	n	F|S/P
n	n	M/F|P
n	n	M/F|S
n	n	M|P
n	n	M|S
n	n	M|S/P
n	n	_
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
num	num	_
pp	pp	<sam->
pp	pp	F|S
pp	pp	_
pron	pron-det	<-sam>|<artd>|F|P
pron	pron-det	<-sam>|<artd>|F|S
pron	pron-det	<-sam>|<artd>|M|P
pron	pron-det	<-sam>|<artd>|M|S
pron	pron-det	<-sam>|<artd>|M|S/P
pron	pron-det	<-sam>|<arti>|F|S
pron	pron-det	<-sam>|<arti>|M|S
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
pron	pron-det	<-sam>|F|P
pron	pron-det	<-sam>|F|S
pron	pron-det	<-sam>|M|P
pron	pron-det	<-sam>|M|S
pron	pron-det	<KOMP>|F|P
pron	pron-det	<KOMP>|F|S
pron	pron-det	<KOMP>|M/F|S
pron	pron-det	<KOMP>|M|P
pron	pron-det	<KOMP>|M|S
pron	pron-det	<artd>|F|P
pron	pron-det	<artd>|F|S
pron	pron-det	<artd>|M|P
pron	pron-det	<artd>|M|S
pron	pron-det	<arti>|F|S
pron	pron-det	<arti>|M|S
pron	pron-det	<dem>|<KOMP>|F|P
pron	pron-det	<dem>|<KOMP>|M|P
pron	pron-det	<dem>|<foc>|M|S
pron	pron-det	<dem>|<quant>|F|S
pron	pron-det	<dem>|<quant>|M|S
pron	pron-det	<dem>|F|P
pron	pron-det	<dem>|F|S
pron	pron-det	<dem>|M|P
pron	pron-det	<dem>|M|S
pron	pron-det	<diff>|<KOMP>|F|P
pron	pron-det	<diff>|<KOMP>|F|S
pron	pron-det	<diff>|<KOMP>|M/F|S
pron	pron-det	<diff>|<KOMP>|M|P
pron	pron-det	<diff>|<KOMP>|M|S
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
pron	pron-det	<n>|<diff>|<KOMP>|F|S
pron	pron-det	<n>|<diff>|<KOMP>|M|P
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
pron	pron-det	<quant>
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
pron	pron-indp	<artd>|F|S
pron	pron-indp	<artd>|M|S
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
pron	pron-indp	<quant>
pron	pron-indp	<quant>|M/F|S
pron	pron-indp	<quant>|M|S
pron	pron-indp	<rel>
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
pron	pron-pers	<coll>|F|3P|ACC
pron	pron-pers	<coll>|M|3P|ACC
pron	pron-pers	<coll>|M|3S|ACC
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
prop	prop	<prop>|F|S
prop	prop	<prop>|M|P
prop	prop	<prop>|M|S
prop	prop	F|P
prop	prop	F|S
prop	prop	M/F|P
prop	prop	M/F|S
prop	prop	M/F|S/P
prop	prop	M|P
prop	prop	M|S
prop	prop	_
prp	prp	<-sam>
prp	prp	<ALT>
prp	prp	<co-prparg>
prp	prp	<error>
prp	prp	<kc>
prp	prp	<kc>|<co-acc>
prp	prp	<kc>|<co-prparg>
prp	prp	<ks>
prp	prp	<quant>
prp	prp	<rel>
prp	prp	<rel>|<ks>
prp	prp	<rel>|<prp>
prp	prp	<sam->
prp	prp	<sam->|<co-acc>
prp	prp	<sam->|<kc>
prp	prp	F|S
prp	prp	M|S
prp	prp	_
punc	punc	_
v	v-fin	<ALT>|IMPF|3S|IND
v	v-fin	<ALT>|IMPF|3S|SUBJ
v	v-fin	<ALT>|PR|3S|IND
v	v-fin	<ALT>|PS|3S|IND
v	v-fin	<ALT>|PS|3S|SUBJ
v	v-fin	<DERP>|<DERS>|IMPF|3S|SUBJ
v	v-fin	<DERP>|PR|1S|IND
v	v-fin	<DERP>|PR|3P|IND
v	v-fin	<DERP>|PR|3S|IND
v	v-fin	<DERP>|PS|3S|IND
v	v-fin	<fmc>|PR|3S|SUBJ
v	v-fin	<hyfen>|<DERP>|PR|3S|IND
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
v	v-fin	<sam->|PR|3S|IND
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
v	v-fin	_
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
v	v-inf	FUT|3S|IND
v	v-inf	_
v	v-pcp	<ALT>|F|S
v	v-pcp	<DERP>|<DERS>|M|S
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
v	v-pcp	_
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
