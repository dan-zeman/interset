# ABSTRACT: Driver for the tagset of the (Prague) Tamil Treebank (TamilTB)
# Copyright © 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Copyright © 2011 Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>
# Documentation at http://ufal.mff.cuni.cz/~ramasamy/tamiltb/0.1/morph_annotation.html

package Lingua::Interset::Tagset::SK::Snk;
use strict;
use warnings;
our $VERSION = '2.039';

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
extends 'Lingua::Interset::Tagset';



has 'atoms' => ( isa => 'HashRef', is => 'ro', builder => '_create_atoms', lazy => 1 );
has 'features_pos' => ( isa => 'HashRef', is => 'ro', builder => '_create_features_pos', lazy => 1 );



#------------------------------------------------------------------------------
# Returns the tagset id that should be set as the value of the 'tagset' feature
# during decoding. Every derived class must (re)define this method! The result
# should correspond to the last two parts in package name, lowercased.
# Specifically, it should be the ISO 639-2 language code, followed by '::' and
# a language-specific tagset id. Example: 'cs::multext'.
#------------------------------------------------------------------------------
sub get_tagset_id
{
    return 'ta::tamiltb';
}



#------------------------------------------------------------------------------
# Creates atomic drivers for surface features.
#------------------------------------------------------------------------------
sub _create_atoms
{
    my $self = shift;
    my %atoms;
    # 1.+2. DETAILED PART OF SPEECH ####################
    $atoms{pos} = $self->create_atom
    (
        'surfeature' => 'pos',
        'decode_map' =>
        {
            # AA: adverb, general (aka, inru, melum, anal, pinnar)
            'AA' => ['pos' => 'adv'],
            # CC: coordinating conjunction (marrum = and; allatu = or)
            'CC' => ['pos' => 'conj', 'conjtype' => 'coor'],
            # DD: determiner, general (inta, anta, intap, enta, antap)
            'DD' => ['pos' => 'adj', 'prontype' => 'prn'],
            # II: interjection, general (aha = aha)
            'II' => ['pos' => 'int'],
            # JJ: adjective, general (mattiya, oru, katanta, putiya, munnal)
            'JJ' => ['pos' => 'adj'],
            # Jd: participial adjective?
            'Jd' => ['pos' => 'adj', 'verbform' => 'part'],
            # NN: common noun (warkali = chair, peruwtu = bus)
            'NN' => ['pos' => 'noun', 'nountype' => 'com'],
            # NE: proper name (intiya, ilangkai, atimuka, pakistan, kirikket)
            'NE' => ['pos' => 'noun', 'nountype' => 'prop'],
            # NO: oblique noun (intiya, amerikka, tamilaka, carvateca, manila)
            # Only one tag found in the corpus: NO--3SN--. Does it apply to location names only?
            'NO' => ['pos' => 'noun', 'nountype' => 'prop'],
            # NP: participial noun (otiyaval = she who ran; utaviyavar = he/she who helped)
            'NP' => ['pos' => 'noun', 'verbform' => 'part'],
            # postposition
            'PP' => ['pos' => 'adp', 'adpostype' => 'post'],
            # QQ: quantifier, general (mika, mikap, mikac, atikam, atika)
            'QQ' => ['pos' => 'adj', 'prontype' => 'prn', 'numtype' => 'card'],
            # Rh: reflexive pronoun (tannaip, tanakku, tamakk, tanatu)
            'Rh' => ['pos' => 'noun', 'prontype' => 'prs', 'reflex' => 'reflex'],
            # Ri: interrogative pronoun (yAr = who, evan = who he, etu = which, enna = what)
            'Ri' => ['pos' => 'noun', 'prontype' => 'int'],
            # Rp: personal pronoun (wAn = I, nIngkal = you, tAn = he/she, itu = it, wAm = we, avarkal = they, anaittum = they)
            'Rp' => ['pos' => 'noun', 'prontype' => 'prs'],
            # RB: general referential pronoun (yarum = anyone; etuvum = anything)
            'RB' => ['pos' => 'noun', 'prontype' => 'ind'],
            # RF: specific indefinite referential pronoun (yaro = someone; etuvo = something)
            # Not found in the corpus.
            'RF' => ['pos' => 'noun', 'prontype' => 'ind'],
            # RG: non-specific indefinite pronoun (yaravatu = someone, at least; etavatu = something, at least)
            # Not found in the corpus.
            'RG' => ['pos' => 'noun', 'prontype' => 'ind'],
            # Tb: comparative particle (kAttilum = than, vita = than)
            'Tb' => ['pos' => 'part'],
            # Tc: connective particle (um = also, and)
            'Tc' => ['pos' => 'part'],
            # Td: adjectival particle (??? - see also Jd, participial adjectives)
            # Td-D----A ... enra (17 occurrences)
            # Td-P----A ... enkira (3 occurrences)
            'Td' => ['pos' => 'part'],
            # Te: interrogative particle (A)
            'Te' => ['pos' => 'part', 'prontype' => 'int'],
            # Tf: civility particle (um = may please: varavum = may you please come)
            'Tf' => ['pos' => 'part'],
            # Tg: particle, general (Ana, Aka, Akav, Akat, Akak)
            'Tg' => ['pos' => 'part'],
            # Tk: intensifier particle (E = very, indeed, itself)
            'Tk' => ['pos' => 'part'],
            # Tl: particle "Avatu" = "at least"
            'Tl' => ['pos' => 'part'],
            # Tm: particle "mattum" = "only"
            'Tm' => ['pos' => 'part'],
            # Tn: particle complementizing nouns (pati, mAtiri = manner, way; pOtu = when)
            'Tn' => ['pos' => 'part'],
            # To: particle of doubt or indefiniteness (O)
            'To' => ['pos' => 'part'],
            # Tq: emphatic particle (tAn: rAmantAn = it was Ram)
            'Tq' => ['pos' => 'part'],
            # Ts: concessive particle (um: Otiyum = although ran; utavinAlum = even if helps)
            'Ts' => ['pos' => 'part'],
            # Tt-T----A: verbal particle (enru, ena, enr, enat, enak, enav)
            # See also Vt?
            'Tt' => ['pos' => 'part'],
            # Tv: inclusive particle (um = also: rAmanum = also Raman)
            'Tv' => ['pos' => 'part'],
            # Tw-T----A: conditional verbal particle (enrAl)
            # See also Vw?
            'Tw' => ['pos' => 'part', 'mood' => 'cnd'],
            # Tz: verbal noun particle (enpatu, etuppat, kotuppat)
            # See also Vz?
            'Tz' => ['pos' => 'part'],
            # TS: immediacy particle (um: vawtatum = as soon as came; otiyatum = as soon as ran)
            'TS' => ['pos' => 'part'],
            # U=: number expressed using digits
            'U=' => ['pos' => 'num', 'numform' => 'digit'],
            # Ux: cardinal number (iru, ayiram, munru, latcam, irantu)
            'Ux' => ['pos' => 'num', 'numtype' => 'card'],
            # Uy: ordinal number (mutal, irantavatu, 1992-m, 1-m, 21-m)
            'Uy' => ['pos' => 'adj', 'numtype' => 'ord'],
            # Vj: lexical verb, imperative (irungkal; Otu = run, utavu = help)
            'Vj' => ['pos' => 'verb', 'verbform' => 'fin', 'mood' => 'imp'],
            # Vr: lexical verb, finite form (terikiratu, terivikkiratu, irukkiratu, kUrukiratu, nilavukiratu)
            'Vr' => ['pos' => 'verb', 'verbform' => 'fin', 'mood' => 'ind'],
            # Vt: lexical verb, verbal particle (vawtu = having come; Oti = having run; utavi = having helped)
            'Vt' => ['pos' => 'verb'],
            # Vu: lexical verb, infinitive (ceyyap, terivikkap, valangkap, ceyya, niyamikkap)
            'Vu' => ['pos' => 'verb', 'verbform' => 'inf'],
            # Vw: lexical verb, conditional (vawtal = if come; otinal = if ran; utavinal = if helped)
            'Vw' => ['pos' => 'verb', 'verbform' => 'fin', 'mood' => 'cnd'],
            # Vz: lexical verb, verbal noun (uyirilappat, nampuvat, ceyalpatuvatark, povat, virippatu)
            # vawtatu = the thing that came; otiyatu = the thing that ran
            'Vz' => ['pos' => 'verb', 'verbform' => 'ger'],
            # VR: auxiliary verb, finite form (varukiratu, irukkiratu)
            'VR' => ['pos' => 'verb', 'verbtype' => 'aux', 'verbform' => 'fin', 'mood' => 'ind'],
            # VT: auxiliary verb, verbal participle (kontu, vittu, vantu, kont, vant)
            'VT' => ['pos' => 'verb', 'verbtype' => 'aux', 'verbform' => 'part'],
            # VU: auxiliary verb, infinitive (vitak, vitap, kolla, vita)
            'VU' => ['pos' => 'verb', 'verbtype' => 'aux', 'verbform' => 'inf'],
            # VW: auxiliary verb, conditional (vittal, iruntal, vantal, vitil, vaittal)
            'VW' => ['pos' => 'verb', 'verbtype' => 'aux', 'verbform' => 'fin', 'mood' => 'cnd'],
            # VZ: auxiliary verb, verbal noun (ullat, kollal, ullatu, varal)
            'VZ' => ['pos' => 'verb', 'verbtype' => 'aux', 'verbform' => 'ger'],
            # unknown
            'XX' => [],
            # Z#: sentence-terminating punctuation.
            'Z#' => ['pos' => 'punc', 'punctype' => 'peri'],
            # Z:: commas and other punctuation
            'Z:' => ['pos' => 'punc', 'punctype' => 'comm']
        },
        'encode_map' =>
        {
            'pos' => { 'noun' => { 'prontype' => { ''  => 'N',
                                                   '@' => 'R' }},
                       'adj'  => { 'prontype' => { ''  => 'J',
                                                   '@' => { 'numtype' => { 'card' => 'Q',
                                                                           '@'    => 'D' }}}},
                       'num'  => { 'prontype' => { ''  => 'U',
                                                   '@' => 'Q' }},
                       'verb' => 'V',
                       'adv'  => 'A',
                       'adp'  => 'P',
                       'conj' => 'C',
                       'part' => 'T',
                       'int'  => 'I',
                       'punc' => 'Z',
                       'sym'  => 'Z',
                       '@'    => 'X' }
        }
    );
    # 3. CASE ####################
    $atoms{case} = $self->create_simple_atom
    (
        'intfeature' => 'case',
        'simple_decode_map' =>
        {
            'A' => 'acc',
            'B' => 'ben',
            'C' => 'abl',
            'D' => 'dat',
            'I' => 'ins',
            'G' => 'gen',
            'L' => 'loc',
            'N' => 'nom',
            'S' => 'soc'
        }
    );
    # 4. TENSE ####################
    $atoms{tense} = $self->create_simple_atom
    (
        'intfeature' => 'tense',
        'simple_decode_map' =>
        {
            'D' => 'past',
            'P' => 'pres',
            'F' => 'fut',
            # tenseless form, e.g. the negative auxiliary "illai"
            'T' => ''
        }
    );
    # 5. PERSON ####################
    $atoms{person} = $self->create_simple_atom
    (
        'intfeature' => 'person',
        'simple_decode_map' =>
        {
            '1' => '1',
            '2' => '2',
            '3' => '3',
            'X' => ''
        }
    );
    # 6. NUMBER ####################
    $atoms{number} = $self->create_simple_atom
    (
        'intfeature' => 'number',
        'simple_decode_map' =>
        {
            'S' => 'sing',
            'P' => 'plur',
            'X' => ''
        }
    );
    # 7. GENDER ####################
    $atoms{gender} = $self->create_atom
    (
        'surfeature' => 'gender',
        'decode_map' =>
        {
            'A' => ['gender' => 'com', 'animateness' => 'anim'],
            'I' => ['gender' => 'com', 'animateness' => 'inan'],
            'F' => ['gender' => 'fem'],
            'M' => ['gender' => 'masc'],
            'N' => ['gender' => 'neut'],
            'H' => ['gender' => 'com', 'politeness' => 'pol']
        },
        'encode_map' =>
        {
            'gender' => { 'masc' => 'M',
                          'fem'  => 'F',
                          'com'  => { 'politeness' => { 'pol' => 'H',
                                                        '@'   => { 'animateness' => { 'inan' => 'I',
                                                                                      '@'    => 'A' }}}},
                          'neut' => 'N' }
        }
    );
    # 8. VOICE ####################
    $atoms{voice} = $self->create_simple_atom
    (
        'intfeature' => 'voice',
        'simple_decode_map' =>
        {
            'A' => 'act',
            # Only the passive auxiliary verb "patu" ("experience") is tagged with "P". All other verbs receive "A".
            'P' => 'pass'
        }
    );
    # 9. NEGATIVENESS ####################
    $atoms{negativeness} = $self->create_simple_atom
    (
        'intfeature' => 'negativeness',
        'simple_decode_map' =>
        {
            'A' => 'pos',
            'N' => 'neg'
        }
    );
    return \%atoms;
}



#------------------------------------------------------------------------------
# Creates the list of surface features (character positions) that can appear
# with particular parts of speech.
#------------------------------------------------------------------------------
sub _create_features_pos
{
    my $self = shift;
    my %features =
    (
        'A'  => ['morphpos', 'gender', 'number', 'case', 'degree'],
        'D'  => ['degree'],
        'E'  => ['adpostype', 'case'],
        'G'  => ['voice', 'gender', 'number', 'case', 'degree'],
        'N'  => ['morphpos', 'gender', 'number', 'case'],
        'O'  => ['conditionality'],
        'P'  => ['morphpos', 'gender', 'number', 'case', 'agglutination'],
        'S'  => ['morphpos', 'gender', 'number', 'case'],
        'T'  => ['conditionality'],
        'V'  => ['verbform', 'aspect', 'number', 'person', 'negativeness'],
        'VL' => ['verbform', 'aspect', 'number', 'person', 'gender', 'negativeness']
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
    $fs->set_tagset('sk::snk');
    my ($pos, $features, $appendix);
    if($tag =~ m/^(.)([^:]*)(:.*)?$/)
    {
        $pos = $1;
        $features = $2;
        $appendix = $3;
        $appendix = '' if(!defined($appendix));
    }
    else
    {
        # We do not throw exceptions from Interset drivers but if we did, this would be a good occasion.
        $features = $tag;
    }
    my @features = split(//, $features);
    # Both appendices could be present.
    while($appendix =~ s/^(:.)//)
    {
        push(@features, $1);
    }
    my $atoms = $self->atoms();
    # Decode part of speech.
    $atoms->{pos}->decode_and_merge_hard($pos, $fs);
    # Decode feature values.
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
    my $pos = $atoms->{pos}->encode($fs);
    my $fpos = $pos;
    if($fs->is_verb() && $fs->tense() eq 'past')
    {
        $fpos = 'VL';
    }
    my $features = $self->features_pos()->{$fpos};
    my @features = ($pos);
    if(defined($features))
    {
        foreach my $feature (@{$features})
        {
            if(defined($feature) && defined($atoms->{$feature}))
            {
                my $value = $atoms->{$feature}->encode($fs);
                if(defined($value) && $value ne '')
                {
                    push(@features, $value);
                }
            }
        }
    }
    my $tag = join('', @features);
    # Some tags have different forms than generated by the atoms.
    $tag =~ s/^([NP])Dh$/$1D/;
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# Got this list from Johanka and cleaned it a bit There are 1457 tags.
# 1457
#------------------------------------------------------------------------------
sub list
{
    my $self = shift;
    my $list = <<end_of_list
A	AA-------	_
C	CC-------	_
D	DD-------	_
J	JJ-------	_
J	Jd-D----A	Ten=D|Neg=A
J	Jd-F----A	Ten=F|Neg=A
J	Jd-P----A	Ten=P|Neg=A
J	Jd-T----A	Ten=T|Neg=A
J	Jd-T----N	Ten=T|Neg=N
N	NEA-3PA--	Cas=A|Per=3|Num=P|Gen=A
N	NEA-3PN--	Cas=A|Per=3|Num=P|Gen=N
N	NEA-3SH--	Cas=A|Per=3|Num=S|Gen=H
N	NEA-3SN--	Cas=A|Per=3|Num=S|Gen=N
N	NED-3PA--	Cas=D|Per=3|Num=P|Gen=A
N	NED-3PN--	Cas=D|Per=3|Num=P|Gen=N
N	NED-3SH--	Cas=D|Per=3|Num=S|Gen=H
N	NED-3SN--	Cas=D|Per=3|Num=S|Gen=N
N	NEG-3SH--	Cas=G|Per=3|Num=S|Gen=H
N	NEG-3SN--	Cas=G|Per=3|Num=S|Gen=N
N	NEI-3PA--	Cas=I|Per=3|Num=P|Gen=A
N	NEL-3PA--	Cas=L|Per=3|Num=P|Gen=A
N	NEL-3PN--	Cas=L|Per=3|Num=P|Gen=N
N	NEL-3SN--	Cas=L|Per=3|Num=S|Gen=N
N	NEN-3PA--	Cas=N|Per=3|Num=P|Gen=A
N	NEN-3SH--	Cas=N|Per=3|Num=S|Gen=H
N	NEN-3SN--	Cas=N|Per=3|Num=S|Gen=N
N	NNA-3PA--	Cas=A|Per=3|Num=P|Gen=A
N	NNA-3PN--	Cas=A|Per=3|Num=P|Gen=N
N	NNA-3SH--	Cas=A|Per=3|Num=S|Gen=H
N	NNA-3SN--	Cas=A|Per=3|Num=S|Gen=N
N	NND-3PA--	Cas=D|Per=3|Num=P|Gen=A
N	NND-3PN--	Cas=D|Per=3|Num=P|Gen=N
N	NND-3SH--	Cas=D|Per=3|Num=S|Gen=H
N	NND-3SN--	Cas=D|Per=3|Num=S|Gen=N
N	NNG-3PA--	Cas=G|Per=3|Num=P|Gen=A
N	NNG-3PN--	Cas=G|Per=3|Num=P|Gen=N
N	NNG-3SH--	Cas=G|Per=3|Num=S|Gen=H
N	NNG-3SN--	Cas=G|Per=3|Num=S|Gen=N
N	NNI-3PA--	Cas=I|Per=3|Num=P|Gen=A
N	NNI-3PN--	Cas=I|Per=3|Num=P|Gen=N
N	NNI-3SN--	Cas=I|Per=3|Num=S|Gen=N
N	NNL-3PA--	Cas=L|Per=3|Num=P|Gen=A
N	NNL-3PN--	Cas=L|Per=3|Num=P|Gen=N
N	NNL-3SH--	Cas=L|Per=3|Num=S|Gen=H
N	NNL-3SN--	Cas=L|Per=3|Num=S|Gen=N
N	NNN-3PA--	Cas=N|Per=3|Num=P|Gen=A
N	NNN-3PN--	Cas=N|Per=3|Num=P|Gen=N
N	NNN-3SH--	Cas=N|Per=3|Num=S|Gen=H
N	NNN-3SM--	Cas=N|Per=3|Num=S|Gen=M
N	NNN-3SN--	Cas=N|Per=3|Num=S|Gen=N
N	NNS-3SA--	Cas=S|Per=3|Num=S|Gen=A
N	NNS-3SN--	Cas=S|Per=3|Num=S|Gen=N
N	NO--3SN--	Per=3|Num=S|Gen=N
N	NPDF3PH-A	Cas=D|Ten=F|Per=3|Num=P|Gen=H|Neg=A
N	NPLF3PH-A	Cas=L|Ten=F|Per=3|Num=P|Gen=H|Neg=A
N	NPND3PH-A	Cas=N|Ten=D|Per=3|Num=P|Gen=H|Neg=A
N	NPND3SH-A	Cas=N|Ten=D|Per=3|Num=S|Gen=H|Neg=A
N	NPNF3PA-A	Cas=N|Ten=F|Per=3|Num=P|Gen=A|Neg=A
N	NPNF3PH-A	Cas=N|Ten=F|Per=3|Num=P|Gen=H|Neg=A
N	NPNF3SH-A	Cas=N|Ten=F|Per=3|Num=S|Gen=H|Neg=A
N	NPNP3SH-A	Cas=N|Ten=P|Per=3|Num=S|Gen=H|Neg=A
N	NPNT3SM-A	Cas=N|Ten=T|Per=3|Num=S|Gen=M|Neg=A
P	PP-------	_
Q	QQ-------	_
R	RBA-3SA--	Cas=A|Per=3|Num=S|Gen=A
R	RBD-3SA--	Cas=D|Per=3|Num=S|Gen=A
R	RBN-3SA--	Cas=N|Per=3|Num=S|Gen=A
R	RBN-3SN--	Cas=N|Per=3|Num=S|Gen=N
R	RhA-1SA--	Cas=A|Per=1|Num=S|Gen=A
R	RhD-1SA--	Cas=D|Per=1|Num=S|Gen=A
R	RhD-3SA--	Cas=D|Per=3|Num=S|Gen=A
R	RhG-3PA--	Cas=G|Per=3|Num=P|Gen=A
R	RhG-3SA--	Cas=G|Per=3|Num=S|Gen=A
R	RiG-3SA--	Cas=G|Per=3|Num=S|Gen=A
R	RiN-3SA--	Cas=N|Per=3|Num=S|Gen=A
R	RiN-3SN--	Cas=N|Per=3|Num=S|Gen=N
R	RpA-1PA--	Cas=A|Per=1|Num=P|Gen=A
R	RpA-2SH--	Cas=A|Per=2|Num=S|Gen=H
R	RpA-3PA--	Cas=A|Per=3|Num=P|Gen=A
R	RpA-3PN--	Cas=A|Per=3|Num=P|Gen=N
R	RpA-3SN--	Cas=A|Per=3|Num=S|Gen=N
R	RpD-1SA--	Cas=D|Per=1|Num=S|Gen=A
R	RpD-2PA--	Cas=D|Per=2|Num=P|Gen=A
R	RpD-3PA--	Cas=D|Per=3|Num=P|Gen=A
R	RpD-3SH--	Cas=D|Per=3|Num=S|Gen=H
R	RpD-3SN--	Cas=D|Per=3|Num=S|Gen=N
R	RpG-1PA--	Cas=G|Per=1|Num=P|Gen=A
R	RpG-1SA--	Cas=G|Per=1|Num=S|Gen=A
R	RpG-2SH--	Cas=G|Per=2|Num=S|Gen=H
R	RpG-3PA--	Cas=G|Per=3|Num=P|Gen=A
R	RpG-3SH--	Cas=G|Per=3|Num=S|Gen=H
R	RpG-3SN--	Cas=G|Per=3|Num=S|Gen=N
R	RpI-1PA--	Cas=I|Per=1|Num=P|Gen=A
R	RpI-3PA--	Cas=I|Per=3|Num=P|Gen=A
R	RpL-3SN--	Cas=L|Per=3|Num=S|Gen=N
R	RpN-1PA--	Cas=N|Per=1|Num=P|Gen=A
R	RpN-1SA--	Cas=N|Per=1|Num=S|Gen=A
R	RpN-2PA--	Cas=N|Per=2|Num=P|Gen=A
R	RpN-2SH--	Cas=N|Per=2|Num=S|Gen=H
R	RpN-3PA--	Cas=N|Per=3|Num=P|Gen=A
R	RpN-3PN--	Cas=N|Per=3|Num=P|Gen=N
R	RpN-3SA--	Cas=N|Per=3|Num=S|Gen=A
R	RpN-3SH--	Cas=N|Per=3|Num=S|Gen=H
R	RpN-3SN--	Cas=N|Per=3|Num=S|Gen=N
T	TS-------	_
T	Tb-------	_
T	Td-D----A	Ten=D|Neg=A
T	Td-P----A	Ten=P|Neg=A
T	Te-------	_
T	Tg-------	_
T	Tk-------	_
T	Tl-------	_
T	Tm-------	_
T	Tn-------	_
T	To-------	_
T	Tq-------	_
T	Ts-------	_
T	Tt-T----A	Ten=T|Neg=A
T	Tv-------	_
T	Tw-T----A	Ten=T|Neg=A
T	TzAF3SN-A	Cas=A|Ten=F|Per=3|Num=S|Gen=N|Neg=A
T	TzIF3SN-A	Cas=I|Ten=F|Per=3|Num=S|Gen=N|Neg=A
T	TzNF3SN-A	Cas=N|Ten=F|Per=3|Num=S|Gen=N|Neg=A
U	U=-------	_
U	U=D-3SN-A	Cas=D|Per=3|Num=S|Gen=N|Neg=A
U	U=L-3SN-A	Cas=L|Per=3|Num=S|Gen=N|Neg=A
U	Ux-------	_
U	UxA-3SN-A	Cas=A|Per=3|Num=S|Gen=N|Neg=A
U	UxD-3SN-A	Cas=D|Per=3|Num=S|Gen=N|Neg=A
U	UxL-3SN--	Cas=L|Per=3|Num=S|Gen=N
U	UxL-3SN-A	Cas=L|Per=3|Num=S|Gen=N|Neg=A
U	UxN-3SH--	Cas=N|Per=3|Num=S|Gen=H
U	Uy-------	_
V	VR-D1SAAA	Ten=D|Per=1|Num=S|Gen=A|Voi=A|Neg=A
V	VR-D3PHAA	Ten=D|Per=3|Num=P|Gen=H|Voi=A|Neg=A
V	VR-D3PHPA	Ten=D|Per=3|Num=P|Gen=H|Voi=P|Neg=A
V	VR-D3PNAA	Ten=D|Per=3|Num=P|Gen=N|Voi=A|Neg=A
V	VR-D3PNPA	Ten=D|Per=3|Num=P|Gen=N|Voi=P|Neg=A
V	VR-D3SHAA	Ten=D|Per=3|Num=S|Gen=H|Voi=A|Neg=A
V	VR-D3SHPA	Ten=D|Per=3|Num=S|Gen=H|Voi=P|Neg=A
V	VR-D3SNAA	Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VR-D3SNPA	Ten=D|Per=3|Num=S|Gen=N|Voi=P|Neg=A
V	VR-F3PAAA	Ten=F|Per=3|Num=P|Gen=A|Voi=A|Neg=A
V	VR-F3PHPA	Ten=F|Per=3|Num=P|Gen=H|Voi=P|Neg=A
V	VR-F3SHAA	Ten=F|Per=3|Num=S|Gen=H|Voi=A|Neg=A
V	VR-F3SNAA	Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VR-F3SNPA	Ten=F|Per=3|Num=S|Gen=N|Voi=P|Neg=A
V	VR-P1PAAA	Ten=P|Per=1|Num=P|Gen=A|Voi=A|Neg=A
V	VR-P2PHAA	Ten=P|Per=2|Num=P|Gen=H|Voi=A|Neg=A
V	VR-P3PAAA	Ten=P|Per=3|Num=P|Gen=A|Voi=A|Neg=A
V	VR-P3PAPA	Ten=P|Per=3|Num=P|Gen=A|Voi=P|Neg=A
V	VR-P3PHAA	Ten=P|Per=3|Num=P|Gen=H|Voi=A|Neg=A
V	VR-P3PHPA	Ten=P|Per=3|Num=P|Gen=H|Voi=P|Neg=A
V	VR-P3PNAA	Ten=P|Per=3|Num=P|Gen=N|Voi=A|Neg=A
V	VR-P3PNPA	Ten=P|Per=3|Num=P|Gen=N|Voi=P|Neg=A
V	VR-P3SHAA	Ten=P|Per=3|Num=S|Gen=H|Voi=A|Neg=A
V	VR-P3SNAA	Ten=P|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VR-P3SNPA	Ten=P|Per=3|Num=S|Gen=N|Voi=P|Neg=A
V	VR-T1PAAA	Ten=T|Per=1|Num=P|Gen=A|Voi=A|Neg=A
V	VR-T1SAAA	Ten=T|Per=1|Num=S|Gen=A|Voi=A|Neg=A
V	VR-T3PAAA	Ten=T|Per=3|Num=P|Gen=A|Voi=A|Neg=A
V	VR-T3PHAA	Ten=T|Per=3|Num=P|Gen=H|Voi=A|Neg=A
V	VR-T3PNAA	Ten=T|Per=3|Num=P|Gen=N|Voi=A|Neg=A
V	VR-T3SHAA	Ten=T|Per=3|Num=S|Gen=H|Voi=A|Neg=A
V	VR-T3SN-N	Ten=T|Per=3|Num=S|Gen=N|Neg=N
V	VR-T3SNAA	Ten=T|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VT-T---AA	Ten=T|Voi=A|Neg=A
V	VT-T---PA	Ten=T|Voi=P|Neg=A
V	VU-T---AA	Ten=T|Voi=A|Neg=A
V	VU-T---PA	Ten=T|Voi=P|Neg=A
V	VW-T---AA	Ten=T|Voi=A|Neg=A
V	VW-T---PA	Ten=T|Voi=P|Neg=A
V	VZAF3SNAA	Cas=A|Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VZAT3SNAA	Cas=A|Ten=T|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VZDD3SNAA	Cas=D|Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VZDD3SNPA	Cas=D|Ten=D|Per=3|Num=S|Gen=N|Voi=P|Neg=A
V	VZIT3SNAA	Cas=I|Ten=T|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VZND3SNAA	Cas=N|Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VZND3SNPA	Cas=N|Ten=D|Per=3|Num=S|Gen=N|Voi=P|Neg=A
V	VZNF3SNAA	Cas=N|Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VZNT3SNAA	Cas=N|Ten=T|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	Vj-T2PAAA	Ten=T|Per=2|Num=P|Gen=A|Voi=A|Neg=A
V	Vr-D1P-AA	Ten=D|Per=1|Num=P|Voi=A|Neg=A
V	Vr-D1SAAA	Ten=D|Per=1|Num=S|Gen=A|Voi=A|Neg=A
V	Vr-D3PAAA	Ten=D|Per=3|Num=P|Gen=A|Voi=A|Neg=A
V	Vr-D3PHAA	Ten=D|Per=3|Num=P|Gen=H|Voi=A|Neg=A
V	Vr-D3PNAA	Ten=D|Per=3|Num=P|Gen=N|Voi=A|Neg=A
V	Vr-D3SHAA	Ten=D|Per=3|Num=S|Gen=H|Voi=A|Neg=A
V	Vr-D3SNAA	Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	Vr-F1P-AA	Ten=F|Per=1|Num=P|Voi=A|Neg=A
V	Vr-F3PHAA	Ten=F|Per=3|Num=P|Gen=H|Voi=A|Neg=A
V	Vr-F3PNAA	Ten=F|Per=3|Num=P|Gen=N|Voi=A|Neg=A
V	Vr-F3SHAA	Ten=F|Per=3|Num=S|Gen=H|Voi=A|Neg=A
V	Vr-F3SNAA	Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	Vr-P1P-AA	Ten=P|Per=1|Num=P|Voi=A|Neg=A
V	Vr-P1PAAA	Ten=P|Per=1|Num=P|Gen=A|Voi=A|Neg=A
V	Vr-P1SAAA	Ten=P|Per=1|Num=S|Gen=A|Voi=A|Neg=A
V	Vr-P2PAAA	Ten=P|Per=2|Num=P|Gen=A|Voi=A|Neg=A
V	Vr-P2PHAA	Ten=P|Per=2|Num=P|Gen=H|Voi=A|Neg=A
V	Vr-P3PHAA	Ten=P|Per=3|Num=P|Gen=H|Voi=A|Neg=A
V	Vr-P3PNAA	Ten=P|Per=3|Num=P|Gen=N|Voi=A|Neg=A
V	Vr-P3SHAA	Ten=P|Per=3|Num=S|Gen=H|Voi=A|Neg=A
V	Vr-P3SNAA	Ten=P|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	Vr-T1SAAA	Ten=T|Per=1|Num=S|Gen=A|Voi=A|Neg=A
V	Vr-T2SH-N	Ten=T|Per=2|Num=S|Gen=H|Neg=N
V	Vr-T3PNAA	Ten=T|Per=3|Num=P|Gen=N|Voi=A|Neg=A
V	Vr-T3SNAA	Ten=T|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	Vt-T----N	Ten=T|Neg=N
V	Vt-T---AA	Ten=T|Voi=A|Neg=A
V	Vu-T---AA	Ten=T|Voi=A|Neg=A
V	Vu-T---PA	Ten=T|Voi=P|Neg=A
V	Vw-T---AA	Ten=T|Voi=A|Neg=A
V	VzAD3SNAA	Cas=A|Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzAF3SNAA	Cas=A|Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzDD3SNAA	Cas=D|Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzDF3SNAA	Cas=D|Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzDF3SNPA	Cas=D|Ten=F|Per=3|Num=S|Gen=N|Voi=P|Neg=A
V	VzGD3SNAA	Cas=G|Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzID3SNAA	Cas=I|Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzIF3SNAA	Cas=I|Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzIT3SNAA	Cas=I|Ten=T|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzLD3SNAA	Cas=L|Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzLF3SNAA	Cas=L|Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzLT3SNAA	Cas=L|Ten=T|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzND3PNAA	Cas=N|Ten=D|Per=3|Num=P|Gen=N|Voi=A|Neg=A
V	VzND3SNAA	Cas=N|Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzND3SNPA	Cas=N|Ten=D|Per=3|Num=S|Gen=N|Voi=P|Neg=A
V	VzNF3SNAA	Cas=N|Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzNP3SNAA	Cas=N|Ten=P|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzNT3SN-N	Cas=N|Ten=T|Per=3|Num=S|Gen=N|Neg=N
V	VzNT3SNAA	Cas=N|Ten=T|Per=3|Num=S|Gen=N|Voi=A|Neg=A
Z	Z#-------	_
Z	Z:-------	_
end_of_list
    ;
    my @list = split(/\r?\n/, $list);
    return \@list;
}



1;

=head1 SYNOPSIS

  use Lingua::Interset::Tagset::SK::Snk;
  my $driver = Lingua::Interset::Tagset::SK::Snk->new();
  my $fs = $driver->decode('SSms1');

or

  use Lingua::Interset qw(decode);
  my $fs = decode('sk::snk', 'SSms1');

=head1 DESCRIPTION

Interset driver for the tags of the Slovak National Corpus (Slovenský národný korpus).

L<http://ufal.mff.cuni.cz/~ramasamy/tamiltb/0.1/morph_annotation.html>

=head1 AUTHORS

Dan Zeman <zeman@ufal.mff.cuni.cz>,
Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>

=head1 SEE ALSO

L<Lingua::Interset>,
L<Lingua::Interset::Tagset>,
L<Lingua::Interset::FeatureStructure>

=cut
