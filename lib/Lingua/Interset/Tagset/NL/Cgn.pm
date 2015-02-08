# ABSTRACT: Driver for the CGN/Lassy/Alpino Dutch tagset.
# Copyright © 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Copyright © 2014 Ondřej Dušek <odusek@ufal.mff.cuni.cz>

# tagset documentation at
# http://www.let.rug.nl/~vannoord/Lassy/POS_manual.pdf

package Lingua::Interset::Tagset::NL::Cgn;
use strict;
use warnings;
our $VERSION = '2.034';

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
    return 'nl::cgn';
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
            'ADJ'  => ['pos' => 'adj'], # adjectief: groot, goed, bekend, nodig, vorig
            'BW'   => ['pos' => 'adv'], # zo, nu, dan, hier, altijd
            'LET'  => ['pos' => 'punc'], # " ' : ( ) ...
            'LID'  => ['pos' => 'adj', 'prontype' => 'art'], # het, der, de, des, den
            'N'    => ['pos' => 'noun'], # substantief: jaar, heer, land, plaats, tijd
            'TSW'  => ['pos' => 'int'], # ja, nee
            'TW'   => ['pos' => 'num'], # telwoord: twee, drie, vier, miljoen, tien
            'VG'   => ['pos' => 'conj'], # en, maar, of, dat, als, om
            'VNW'  => ['pos' => 'noun', 'prontype' => 'prs'], # voornaamwoord: ik, we, wij, u, je, jij, jullie, ze, zij, hij, het, ie, zijzelf
            'VZ'   => ['pos' => 'adp', 'adpostype' => 'prep'], # van, in, op, met, voor
            'WW'   => ['pos' => 'verb'] # werkwoord: worden, zijn, blijven, komen, wezen
        },
        'encode_map' =>
        {
            'pos' => { 'noun' => { 'prontype' => { ''  => 'N',
                                                   '@' => 'VNW' }},
                       'adj'  => { 'prontype' => { ''    => { 'numtype' => { ''  => 'ADJ',
                                                                             '@' => 'TW' }},
                                                   'art' => 'LID' }},
                       'num'  => 'TW',
                       'verb' => 'WW',
                       'adv'  => 'BW',
                       'adp'  => 'VZ',
                       'conj' => 'VG',
                       'int'  => 'TSW',
                       'punc' => 'LET',
                       'sym'  => 'LET' }
        }
    );
    # NOUN TYPE ####################
    $atoms{nountype} = $self->create_simple_atom
    (
        'intfeature' => 'nountype',
        'simple_decode_map' =>
        {
            'soort' => 'com', # common noun (jaar, heer, land, plaats, tijd)
            'eigen' => 'prop' # proper noun (Nederland, Amsterdam, zaterdag, Groningen, Rotterdam)
        }
    );
    # DEGREE ####################
    # graad
    $atoms{degree} = $self->create_simple_atom
    (
        'intfeature' => 'degree',
        'simple_decode_map' =>
        {
            # degree of comparison (adjectives, adverbs and indefinite numerals (veel/weinig, meer/minder, meest/minst))
            # positive (goed, lang, erg, snel, zeker)
            'basis' => 'pos',
            # comparative (verder, later, eerder, vroeger, beter)
            'comp'  => 'comp',
            # superlative (best, grootst, kleinst, moeilijkst, mooist)
            'sup'   => 'sup',
            # diminutive (stoeltje, huisje, nippertje, Kareltje)
            'dim'   => 'dim'
        }
    );
    # POSITION OF ADJECTIVE, NUMERAL OR NON-FINITE VERB FORM ####################
    # positie
    $atoms{position} = $self->create_atom
    (
        'surfeature' => 'position',
        'decode_map' =>
        {
            # attribute modifying a following noun (adjectives, verbs "de nog te lezen post")
            'prenom'   => ['other' => {'usage' => 'prenom'}],
            # attribute modifying a preceding noun
            'postnom'  => ['other' => {'usage' => 'postnom'}],
            # independently used (adjectives, verbs)
            'vrij'     => ['other' => {'usage' => 'vrij'}],
            # substantively used (adjectives, verbs)
            'nom'      => ['other' => {'usage' => 'nom'}],
        },
        'encode_map' =>
        {
            'other/usage' => { 'prenom'  => 'prenom',
                               'nom'     => 'nom',
                               'postnom' => 'postnom',
                               'vrij'    => 'vrij',
                               '@'       => { 'numtype' => { 'card' => { 'degree' => { ''  => { 'case' => { ''  => 'vrij',
                                                                                                            '@' => 'prenom' }},
                                                                                       '@' => 'nom' }},
                                                             'ord'  => { 'case' => { ''  => 'nom',
                                                                                     '@' => 'prenom' }},
                                                             '@'    => { 'number' => { 'plur' => 'nom',
                                                                                       '@'    => { 'degree' => { 'dim' => 'vrij',
                                                                                                                 '@'   => 'prenom' }}}}}}}
        }
    );
    # INFLECTED FORM ####################
    # buiging, getal-n
    $atoms{inflection} = $self->create_atom
    (
        'surfeature' => 'inflection',
        'decode_map' =>
        {
            # base form (een mooi huis)
            'zonder' => ['other' => {'inflection' => '0'}],
            # -e (een groote pot, een niet te verstane verleiding); adjectives, verbs
            # ADJ(prenom,basis,met-e,stan): mooie huizen, een grote pot
            # ADJ(prenom,basis,met-e,bijz): zaliger gedachtenis, van goeden huize
            # ADJ(prenom,comp,met-e,stan): mooiere huizen, een grotere pot
            # ADJ(prenom,comp,met-e,bijz): van beteren huize
            'met-e'  => ['other' => {'inflection' => 'e'}],
            # -s (iets moois)
            'met-s'  => ['other' => {'inflection' => 's'}],
        },
        'encode_map' =>
        {
            'other/inflection' => { '0' => 'zonder',
                                    'e' => 'met-e',
                                    's' => 'met-s',
                                    # Non-empty number ("mv-n") or case ("stan" or "bijz") means inflection cannot be "zonder".
                                    '@' => { 'number' => { ''  => { 'case' => { ''  => 'zonder',
                                                                                '@' => 'met-e' }},
                                                           '@' => 'met-e' }}}
        }
    );
    # DEFINITENESS ####################
    $atoms{definiteness} = $self->create_simple_atom
    (
        'intfeature' => 'definiteness',
        'simple_decode_map' =>
        {
            'bep'   => 'def', # (het, der, de, des, den)
            'onbep' => 'ind'  # (een)
        }
    );
    # GENUS / GENDER ####################
    $atoms{gender} = $self->create_simple_atom
    (
        'intfeature' => 'gender',
        'simple_decode_map' =>
        {
            'zijd' => 'com',  # zijdig / common, i.e. non-neuter (de)
            'masc' => 'masc', # masculien / masculine; only pronouns
            'fem'  => 'fem',  # feminien / feminine; only pronouns
            'onz'  => 'neut'  # onzijdig / neuter (het)
        }
    );
    # GETAL / NUMBER ####################
    $atoms{number} = $self->create_atom
    (
        'surfeature' => 'number',
        'decode_map' =>
        {
            # enkelvoud (jaar, heer, land, plaats, tijd)
            'ev'    => ['number' => 'sing'],
            'evf'   => ['number' => 'sing'],
            'evmo'  => ['number' => 'sing'],
            'evon'  => ['number' => 'sing'],
            # meervoud (mensen, kinderen, jaren, problemen, landen)
            'mv'    => ['number' => 'plur'],
            # finite verbs: polite form of 2nd and 3rd person singular and plural
            'met-t' => ['politeness' => 'pol'],
            # underspecified number (e.g. with some pronouns)
            'getal' => []
        },
        'encode_map' =>
        {
            'number' => { 'sing' => 'ev',
                          'plur' => 'mv',
                          '@'    => { 'verbform' => { 'fin' => { 'politeness' => { 'pol' => 'met-t' }},
                                                      '@'   => 'getal' }}}
        }
    );
    # GETAL-N / NUMBER-N ####################
    $atoms{numbern} = $self->create_atom
    (
        'surfeature' => 'numbern',
        'decode_map' =>
        {
            # nominal usage without plural -n (het groen)
            'zonder-n' => ['other' => {'numbern' => 'without'}],
            # nominal usage with plural -n (de rijken)
            'mv-n'     => ['number' => 'plur']
        },
        'encode_map' =>
        {
            'number' => { 'plur' => 'mv-n',
                          '@'    => { 'other/numbern' => { 'without' => 'zonder-n',
                                                           '@'       => { 'numtype' => { 'card' => { 'degree' => { ''  => '',
                                                                                                                   '@' => 'zonder-n' }},
                                                                                         'ord'  => { 'case' => { '' => 'zonder-n' }}}}}}}
        }
    );
    # NAAMVAL / CASE ####################
    $atoms{case} = $self->create_atom
    (
        'surfeature' => 'case',
        'decode_map' =>
        {
            # standaard naamval / standard case (a word that does not take case markings and is used in nominative or oblique situations)
            'stan'  => ['case' => 'nom|acc'],
            # bijzonder naamval / special case (zaliger gedachtenis, van goeden huize, ten enen male)
            'bijz'  => ['case' => 'gen|dat'],
            # nominative (only pronouns: ik, we, wij, u, je, jij, jullie, ze, zij, hij, het, ie, zijzelf)
            'nomin' => ['case' => 'nom'],
            # oblique case (mij, haar, ons)
            'obl'   => ['case' => 'acc'],
            # genitive (der, des)
            'gen'   => ['case' => 'gen'],
            # dative (den)
            'dat'   => ['case' => 'dat']
        },
        'encode_map' =>
        {
            'case' => { 'acc|nom' => 'stan',
                        'dat|gen' => 'bijz',
                        'nom'     => 'nomin',
                        'gen'     => 'gen',
                        'dat'     => 'dat',
                        'acc'     => 'obl' }
        }
    );
    # NUMERAL TYPE ####################
    $atoms{numtype} = $self->create_atom
    (
        'surfeature' => 'numtype',
        'decode_map' =>
        {
            'hoofd' => ['pos' => 'num', 'numtype' => 'card'], # hoofdtelwoord (twee, 1969, beider, minst, veel)
            'rang'  => ['pos' => 'adj', 'numtype' => 'ord'], # rangtelwoord (eerste, tweede, derde, vierde, vijfde)
        },
        'encode_map' =>
        {
            'numtype' => { 'card' => 'hoofd',
                           'ord'  => 'rang' }
        }
    );
    # PRONOUN TYPE ####################
    # vwtype
    $atoms{prontype} = $self->create_atom
    (
        'surfeature' => 'prontype',
        'decode_map' =>
        {
            'pers'  => ['prontype' => 'prs'], # persoonlijk (me, ik, ons, we, je, u, jullie, ze, hem, hij, hen)
            'pr'    => ['prontype' => 'prs'],
            'bez'   => ['prontype' => 'prs', 'poss' => 'poss'], # beztittelijk (mijn, onze, je, jullie, zijner, zijn, hun)
            'refl'  => ['prontype' => 'prs', 'reflex' => 'reflex'], # reflexief (me, mezelf, mij, ons, onszelf, je, jezelf, zich, zichzelf)
            'recip' => ['prontype' => 'rcp'], # reciprook (elkaar, elkaars)
            'aanw'  => ['prontype' => 'dem'], # aanwijzend (deze, dit, die, dat)
            'betr'  => ['prontype' => 'rel'], # betrekkelijk (welk, die, dat, wat, wie)
            'vrag'  => ['prontype' => 'int'], # vragend (wie, wat, welke, welk)
            'onbep' => ['prontype' => 'ind|neg|tot'] # onbepaald (geen, andere, alle, enkele, wat)
        },
        'encode_map' =>
        {
            'prontype' => { 'prs' => { 'poss' => { 'poss' => 'bez',
                                                   '@'    => { 'reflex' => { 'reflex' => 'refl',
                                                                             '@'      => 'pers' }}}},
                            'rcp' => 'recip',
                            'dem' => 'aanw',
                            'rel' => 'betr',
                            'int' => 'vrag',
                            'ind' => 'onbep',
                            'neg' => 'onbep',
                            'tot' => 'onbep' }
        }
    );
    # PDTYPE ####################
    $atoms{pdtype} = $self->create_atom
    (
        'surfeature' => 'pdtype',
        'decode_map' =>
        {
            'pron'     => ['pos' => 'noun'],
            'det'      => ['pos' => 'adj'],
            # pronominal adverbs
            'adv-pron' => ['pos' => 'adv']
        },
        'encode_map' =>
        {
            'pos' => { 'noun' => 'pron',
                       'adj'  => 'det',
                       'adv'  => 'adv-pron' }
        }
    );
    # PERSON ####################
    $atoms{person} = $self->create_atom
    (
        'surfeature' => 'person',
        'decode_map' =>
        {
            '1'  => ['person' => '1'], # (mijn, onze, ons, me, mij, ik, we, mezelf, onszelf)
            '2'  => ['person' => '2'], # (je, uw, jouw, jullie, jou, u, je, jij, jezelf)
            '2v' => ['person' => '2', 'politeness' => 'inf'], # (je, jouw, jullie, jou, je, jij, jezelf)
            '2b' => ['person' => '2', 'politeness' => 'pol'], # (u, uw)
            '3'  => ['person' => '3'], # (zijner, zijn, haar, zijnen, zijne, hun, ze, zij, hem, het, hij, ie, zijzelf, zich, zichzelf)
            '3o' => ['person' => '3'], # (iets)
            '3p' => ['person' => '3'], # (iemand)
        },
        'encode_map' =>
        {
            'person' => { '1' => '1',
                          '2' => { 'politeness' => { 'inf' => '2v',
                                                     'pol' => '2b',
                                                     '@'   => '2' }},
                          '3' => '3' }
        }
    );
    # PRONOUN FORM ####################
    $atoms{pronform} = $self->create_simple_atom
    (
        'intfeature' => 'variant',
        'simple_decode_map' =>
        {
            'vol'  => 'long',  # vol / full: zij, haar
            'red'  => 'short', # gereduceerd / reduced: ze, d'r
            'nadr' => '1'      # nadruk / emphasis: ikke, ditte, datte, watte; -zelf, -lie(den)
        }
    );
    # VERB FORM ####################
    # wvorm
    $atoms{verbform} = $self->create_atom
    (
        'surfeature' => 'verbform',
        'decode_map' =>
        {
            # persoonsvorm / personal form (finite verb)
            # (kom, speel, komen, spelen, komt, speelt, kwam, speelde, kwamen, speelden, kwaamt, gingt, kome, leve de koning)
            'pv'    => ['verbform' => 'fin'],
            # infinitief / infinitive
            # (zijn, gaan, slaan, staan, doen, zien)
            'inf'   => ['verbform' => 'inf'],
            # voltooid deelwoord / past participle
            # (afgelopen, gekomen, gegaan, gebeurd, begonnen)
            'vd'    => ['verbform' => 'part', 'tense' => 'past', 'aspect' => 'perf'],
            # onvoltooid deelwoord / present participle
            # (volgend, verrassend, bevredigend, vervelend, aanvallend)
            'od'    => ['verbform' => 'part', 'tense' => 'pres', 'aspect' => 'imp']
        },
        'encode_map' =>
        {
            'verbform' => { 'inf'  => 'inf',
                            'fin'  => 'pv',
                            'part' => { 'tense' => { 'pres' => 'od',
                                                     'past' => 'vd' }}}
        }
    );
    # MOOD AND TENSE ####################
    # tijd
    $atoms{tense} = $self->create_atom
    (
        'surfeature' => 'tense',
        'decode_map' =>
        {
            # tegenwoordige tijd / present tense
            # imperatief / imperative
            # (kom, speel, komen, spelen, komt, speelt)
            'tgw'   => ['mood' => 'ind|imp', 'tense' => 'pres'],
            # verleden tijd / past tense
            # (kwam, speelde, kwamen, speelden, gingt, kome)
            'verl'  => ['mood' => 'ind', 'tense' => 'past'],
            # conjunctief / subjunctive
            # (moge, leve, kome)
            # also expressing wishes (het ga je goed)
            'conj'  => ['mood' => 'sub'],
        },
        'encode_map' =>
        {
            'mood' => { 'sub' => 'conj',
                        '@'   => { 'tense' => { 'pres' => 'tgw',
                                                'past' => 'verl' }}}
        }
    );
    # ADPOSITION TYPE ####################
    $atoms{adpostype} = $self->create_atom
    (
        'surfeature' => 'adpostype',
        'decode_map' =>
        {
            'fin'   => ['adpostype' => 'post'], # postposition (achterzetsel) (in, incluis, op)
            'versm' => ['adpostype' => 'comprep'] # fused preposition and article?
        },
        'encode_map' =>
        {
            'adpostype' => { 'post'    => 'fin',
                             'comprep' => 'versm' }
        }
    );
    # CONJUNCTION TYPE ####################
    $atoms{conjtype} = $self->create_simple_atom
    (
        'intfeature' => 'conjtype',
        'simple_decode_map' =>
        {
            'neven' => 'coor', # coordinating (en, maar, of)
            'onder' => 'sub'   # subordinating (dat, als, dan, om, zonder, door)
        }
    );
    # SYMBOL ####################
    $atoms{symbol} = $self->create_atom
    (
        'surfeature' => 'symbol',
        'decode_map' =>
        {
            'symb' => ['pos' => 'sym'],
            'afk'  => ['abbr' => 'abbr']
        },
        'encode_map' =>
        {
            'abbr' => { 'abbr' => 'afk',
                        '@'    => { 'pos' => { 'sym' => 'symb' }}}
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
    my @features = ('pos', 'nountype', 'position', 'degree', 'inflection', 'definiteness', 'gender', 'case', 'number', 'numbern',
                    'prontype', 'pdtype', 'person', 'pronform', 'numtype', 'verbform', 'tense', 'adpostype', 'conjtype', 'symbol');
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
        'N'     => ['nountype', 'number', 'degree', 'gender', 'case'],
        'ADJ'   => ['position', 'degree', 'inflection', 'numbern', 'case'],
        'WWpv'  => ['verbform', 'tense', 'number'],
        'WWopv' => ['verbform', 'position', 'inflection', 'numbern'],
        'TW'    => ['numtype', 'position', 'case', 'numbern', 'degree'],
        'VNW'   => ['prontype', 'pdtype', 'case', 'pronform', 'person', 'number', 'gender']
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
    $fs->set_tagset('nl::cgn');
    my $atoms = $self->atoms();
    # Two components, part-of-speech tag and features.
    # example: N(soort,ev)
    my ($pos, $features) = split(/[\(\)]/, $tag);
    $features = '' if(!defined($features));
    my @features = split(/,/, $features);
    $atoms->{pos}->decode_and_merge_hard($pos, $fs);
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
    if($fpos eq 'WW')
    {
        $fpos = $fs->is_finite_verb() ? 'WWpv' : 'WWopv';
    }
    my $feature_names = $self->get_feature_names($fpos);
    my $tag = $pos;
    if(defined($feature_names) && ref($feature_names) eq 'ARRAY')
    {
        my @features;
        foreach my $feature (@{$feature_names})
        {
            my $value = $atoms->{$feature}->encode($fs);
            push(@features, $value) unless($value eq '');
        }
        if(scalar(@features)>0)
        {
            $tag .= '('.join(',', @features).')';
        }
    }
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
###!!! We do not have the list of possible tags for this tagset. What follows
###!!! is just an approximation to enable at least minimal testing.
#------------------------------------------------------------------------------
sub list
{
    my $self = shift;
    my $list = <<end_of_list
BW
LET
LID
TSW
VG
VZ
N(soort,ev,basis,zijd,stan)
N(soort,ev,basis,onz,stan)
N(soort,ev,dim,onz,stan)
N(soort,ev,basis,gen)
N(soort,ev,dim,gen)
N(soort,ev,basis,dat)
N(soort,mv,basis)
N(soort,mv,dim)
N(eigen,ev,basis,zijd,stan)
N(eigen,ev,basis,onz,stan)
N(eigen,ev,dim,onz,stan)
N(eigen,ev,basis,gen)
N(eigen,ev,dim,gen)
N(eigen,ev,basis,dat)
N(eigen,mv,basis)
N(eigen,mv,dim)
ADJ(prenom,basis,zonder)
ADJ(prenom,basis,met-e,stan)
ADJ(prenom,basis,met-e,bijz)
ADJ(prenom,comp,zonder)
ADJ(prenom,comp,met-e,stan)
ADJ(prenom,comp,met-e,bijz)
ADJ(prenom,sup,zonder)
ADJ(prenom,sup,met-e,stan)
ADJ(prenom,sup,met-e,bijz)
ADJ(nom,basis,zonder,zonder-n)
ADJ(nom,basis,zonder,mv-n)
ADJ(nom,basis,met-e,zonder-n,stan)
ADJ(nom,basis,met-e,zonder-n,bijz)
ADJ(nom,basis,met-e,mv-n)
ADJ(nom,comp,zonder,zonder-n)
ADJ(nom,comp,met-e,zonder-n,stan)
ADJ(nom,comp,met-e,zonder-n,bijz)
ADJ(nom,comp,met-e,mv-n)
ADJ(nom,sup,zonder,zonder-n)
ADJ(nom,sup,met-e,zonder-n,stan)
ADJ(nom,sup,met-e,zonder-n,bijz)
ADJ(nom,sup,met-e,mv-n)
ADJ(postnom,basis,zonder)
ADJ(postnom,basis,met-s)
ADJ(postnom,comp,zonder)
ADJ(postnom,comp,met-s)
ADJ(vrij,basis,zonder)
ADJ(vrij,comp,zonder)
ADJ(vrij,sup,zonder)
ADJ(vrij,dim,zonder)
WW(pv,tgw,ev)
WW(pv,tgw,mv)
WW(pv,tgw,met-t)
WW(pv,verl,ev)
WW(pv,verl,mv)
WW(pv,verl,met-t)
WW(pv,conj,ev)
WW(inf,prenom,zonder)
WW(inf,prenom,met-e)
WW(inf,nom,zonder,zonder-n)
WW(inf,vrij,zonder)
WW(vd,prenom,zonder)
WW(vd,prenom,met-e)
WW(vd,nom,met-e,zonder-n)
WW(vd,nom,met-e,mv-n)
WW(vd,vrij,zonder)
WW(od,prenom,zonder)
WW(od,prenom,met-e)
WW(od,nom,met-e,zonder-n)
WW(od,nom,met-e,mv-n)
WW(od,vrij,zonder)
TW(hoofd,prenom,stan)
TW(hoofd,prenom,bijz)
TW(hoofd,nom,zonder-n,basis)
TW(hoofd,nom,mv-n,basis)
TW(hoofd,nom,zonder-n,dim)
TW(hoofd,nom,mv-n,dim)
TW(hoofd,vrij)
TW(rang,prenom,stan)
TW(rang,prenom,bijz)
TW(rang,nom,zonder-n)
TW(rang,nom,mv-n)
VNW(pers,pron,nomin,vol,1,ev)
VNW(pers,pron,nomin,nadr,1,ev)
VNW(pers,pron,nomin,red,1,ev)
VNW(pers,pron,nomin,vol,1,mv)
VNW(pers,pron,nomin,nadr,1,mv)
VNW(pers,pron,nomin,red,1,mv)
VNW(pers,pron,nomin,vol,2v,ev)
VNW(pers,pron,nomin,nadr,2v,ev)
VNW(pers,pron,nomin,red,2v,ev)
VNW(pers,pron,nomin,vol,2b,getal)
VNW(pers,pron,nomin,nadr,2b,getal)
VNW(pers,pron,nomin,vol,2,getal)
VNW(pers,pron,nomin,nadr,2,getal)
VNW(pers,pron,nomin,red,2,getal)
VNW(pers,pron,nomin,vol,3,ev,masc)
VNW(pers,pron,nomin,nadr,3m,ev,masc)
VNW(pers,pron,nomin,red,3,ev,masc)
VNW(pers,pron,nomin,red,3p,ev,masc)
VNW(pers,pron,nomin,vol,3v,ev,fem)
VNW(pers,pron,nomin,nadr,3v,ev,fem)
VNW(pers,pron,nomin,vol,3p,mv)
VNW(pers,pron,nomin,nadr,3p,mv)
VNW(pers,pron,obl,vol,2v,ev)
VNW(pers,pron,obl,vol,3,ev,masc)
VNW(pers,pron,obl,nadr,3m,ev,masc)
VNW(pers,pron,obl,red,3,ev,masc)
VNW(pers,pron,obl,vol,3,getal,fem)
VNW(pers,pron,obl,nadr,3v,getal,fem)
VNW(pers,pron,obl,red,3v,getal,fem)
VNW(pers,pron,obl,vol,3p,mv)
VNW(pers,pron,obl,nadr,3p,mv)
VNW(pers,pron,stan,nadr,2v,mv)
VNW(pers,pron,stan,red,3,ev,onz)
VNW(pers,pron,stan,red,3,ev,fem)
VNW(pers,pron,stan,red,3,mv)
VNW(pers,pron,gen,vol,1,ev)
VNW(pers,pron,gen,vol,1,mv)
VNW(pers,pron,gen,vol,2,getal)
VNW(pers,pron,gen,vol,3m,ev)
VNW(pers,pron,gen,vol,3v,getal)
VNW(pers,pron,gen,vol,3p,mv)
VNW(refl,pron,obl,red,3,getal)
VNW(refl,pron,obl,nadr,3,getal)
VNW(recip,pron,obl,vol,persoon,mv)
VNW(recip,pron,gen,vol,persoon,mv)
VNW(bez,det,stan,vol,1,ev,prenom,zonder,agr)
VNW(bez,det,stan,vol,1,ev,prenom,met-e,rest)
VNW(bez,det,stan,red,1,ev,prenom,zonder,agr)
VNW(bez,det,stan,vol,1,mv,prenom,zonder,evon)
VNW(bez,det,stan,vol,1,mv,prenom,met-e,rest)
VNW(bez,det,stan,vol,2,getal,prenom,zonder,agr)
VNW(bez,det,stan,vol,2,getal,prenom,met-e,rest)
VNW(bez,det,stan,vol,2v,ev,prenom,zonder,agr)
VNW(bez,det,stan,red,2v,ev,prenom,zonder,agr)
VNW(bez,det,stan,nadr,2v,mv,prenom,zonder,agr)
VNW(bez,det,stan,vol,3,ev,prenom,zonder,agr)
VNW(bez,det,stan,vol,3m,ev,prenom,met-e,rest)
VNW(bez,det,stan,vol,3v,ev,prenom,met-e,rest)
VNW(bez,det,stan,red,3,ev,prenom,zonder,agr)
VNW(bez,det,stan,vol,3,mv,prenom,zonder,agr)
VNW(bez,det,stan,vol,3p,mv,prenom,met-e,rest)
VNW(bez,det,stan,red,3,getal,prenom,zonder,agr)
VNW(bez,det,gen,vol,1,ev,prenom,zonder,evmo)
VNW(bez,det,gen,vol,1,ev,prenom,met-e,rest3)
VNW(bez,det,gen,vol,1,mv,prenom,met-e,evmo)
VNW(bez,det,gen,vol,1,mv,prenom,met-e,rest3)
VNW(bez,det,gen,vol,2,getal,prenom,zonder,evmo)
VNW(bez,det,gen,vol,2,getal,prenom,met-e,rest3)
VNW(bez,det,gen,vol,2v,ev,prenom,met-e,rest3)
VNW(bez,det,gen,vol,3,ev,prenom,zonder,evmo)
VNW(bez,det,gen,vol,3,ev,prenom,met-e,rest3)
VNW(bez,det,gen,vol,3v,ev,prenom,zonder,evmo)
VNW(bez,det,gen,vol,3v,ev,prenom,met-e,rest3)
VNW(bez,det,gen,vol,3p,mv,prenom,zonder,evmo)
VNW(bez,det,gen,vol,3p,mv,prenom,met-e,rest3)
VNW(bez,det,dat,vol,1,ev,prenom,met-e,evmo)
VNW(bez,det,dat,vol,1,ev,prenom,met-e,evf)
VNW(bez,det,dat,vol,1,mv,prenom,met-e,evmo)
VNW(bez,det,dat,vol,1,mv,prenom,met-e,evf)
VNW(bez,det,dat,vol,2,getal,prenom,met-e,evmo)
VNW(bez,det,dat,vol,2,getal,prenom,met-e,evf)
VNW(bez,det,dat,vol,2v,ev,prenom,met-e,evf)
VNW(bez,det,dat,vol,3,ev,prenom,met-e,evmo)
VNW(bez,det,dat,vol,3,ev,prenom,met-e,evf)
VNW(bez,det,dat,vol,3v,ev,prenom,met-e,evmo)
VNW(bez,det,dat,vol,3v,ev,prenom,met-e,evf)
VNW(bez,det,dat,vol,3p,mv,prenom,met-e,evmo)
VNW(bez,det,dat,vol,3p,mv,prenom,met-e,evf)
VNW(bez,det,stan,vol,1,ev,nom,met-e,zonder-n)
VNW(bez,det,stan,vol,1,mv,nom,met-e,zonder-n)
VNW(bez,det,stan,vol,2,getal,nom,met-e,zonder-n)
VNW(bez,det,stan,vol,2v,ev,nom,met-e,zonder-n)
VNW(bez,det,stan,vol,3m,ev,nom,met-e,zonder-n)
VNW(bez,det,stan,vol,3v,ev,nom,met-e,zonder-n)
VNW(bez,det,stan,vol,3p,mv,nom,met-e,zonder-n)
VNW(bez,det,stan,vol,1,ev,nom,met-e,mv-n)
VNW(bez,det,stan,vol,1,mv,nom,met-e,mv-n)
VNW(bez,det,stan,vol,2,getal,nom,met-e,mv-n)
VNW(bez,det,stan,vol,2v,ev,nom,met-e,mv-n)
VNW(bez,det,stan,vol,3m,ev,nom,met-e,mv-n)
VNW(bez,det,stan,vol,3v,ev,nom,met-e,mv-n)
VNW(bez,det,stan,vol,3p,mv,nom,met-e,mv-n)
VNW(bez,det,dat,vol,1,ev,nom,met-e,zonder-n)
VNW(bez,det,dat,vol,1,mv,nom,met-e,zonder-n)
VNW(bez,det,dat,vol,2,getal,nom,met-e,zonder-n)
VNW(bez,det,dat,vol,3m,ev,nom,met-e,zonder-n)
VNW(bez,det,dat,vol,3v,ev,nom,met-e,zonder-n)
VNW(bez,det,dat,vol,3p,mv,nom,met-e,zonder-n)
VNW(vrag,pron,stan,nadr,3o,ev)
VNW(betr,pron,stan,vol,persoon,getal)
VNW(betr,pron,stan,vol,3,ev)
VNW(betr,det,stan,nom,zonder,zonder-n)
VNW(betr,det,stan,nom,met-e,zonder-n)
VNW(betr,pron,gen,vol,3o,ev)
VNW(betr,pron,gen,vol,3o,getal)
VNW(vb,pron,stan,vol,3p,getal)
VNW(vb,pron,stan,vol,3o,ev)
VNW(vb,pron,gen,vol,3m,ev)
VNW(vb,pron,gen,vol,3v,ev)
VNW(vb,pron,gen,vol,3p,mv)
VNW(vb,adv-pron,obl,vol,3o,getal)
VNW(excl,pron,stan,vol,3,getal)
VNW(vb,det,stan,prenom,zonder,evon)
VNW(vb,det,stan,prenom,met-e,rest)
VNW(vb,det,stan,nom,met-e,zonder-n)
VNW(excl,det,stan,vrij,zonder)
VNW(aanw,pron,stan,vol,3o,ev)
VNW(aanw,pron,stan,nadr,3o,ev)
VNW(aanw,pron,stan,vol,3,getal)
VNW(aanw,pron,gen,vol,3m,ev)
VNW(aanw,pron,gen,vol,3o,ev)
VNW(aanw,adv-pron,obl,vol,3o,getal)
VNW(aanw,adv-pron,stan,red,3,getal)
VNW(aanw,det,stan,prenom,zonder,evon)
VNW(aanw,det,stan,prenom,zonder,rest)
VNW(aanw,det,stan,prenom,zonder,agr)
VNW(aanw,det,stan,prenom,met-e,rest)
VNW(aanw,det,gen,prenom,met-e,rest3)
VNW(aanw,det,dat,prenom,met-e,evmo)
VNW(aanw,det,dat,prenom,met-e,evf)
VNW(aanw,det,stan,nom,met-e,zonder-n)
VNW(aanw,det,stan,nom,met-e,mv-n)
VNW(aanw,det,gen,nom,met-e,zonder-n)
VNW(aanw,det,dat,nom,met-e,zonder-n)
VNW(aanw,det,stan,vrij,zonder)
VNW(onbep,pron,stan,vol,3p,ev)
VNW(onbep,pron,stan,vol,3o,ev)
VNW(onbep,pron,gen,vol,3p,ev)
VNW(onbep,adv-pron,obl,vol,3o,getal)
VNW(onbep,adv-pron,gen,red,3,getal)
VNW(onbep,det,stan,prenom,zonder,evon)
VNW(onbep,det,stan,prenom,zonder,agr)
VNW(onbep,det,stan,prenom,met-e,evz)
VNW(onbep,det,stan,prenom,met-e,mv)
VNW(onbep,det,stan,prenom,met-e,rest)
VNW(onbep,det,stan,prenom,met-e,agr)
VNW(onbep,det,gen,prenom,met-e,mv)
VNW(onbep,det,dat,prenom,met-e,evmo)
VNW(onbep,det,dat,prenom,met-e,evf)
VNW(onbep,grad,stan,prenom,zonder,agr,basis)
VNW(onbep,grad,stan,prenom,met-e,agr,basis)
VNW(onbep,grad,stan,prenom,met-e,mv,basis)
VNW(onbep,grad,stan,prenom,zonder,agr,comp)
VNW(onbep,grad,stan,prenom,met-e,agr,sup)
VNW(onbep,grad,stan,prenom,met-e,agr,comp)
VNW(onbep,det,stan,nom,met-e,mv-n)
VNW(onbep,det,stan,nom,met-e,zonder-n)
VNW(onbep,det,stan,nom,zonder,zonder-n)
VNW(onbep,det,gen,nom,met-e,mv-n)
VNW(onbep,grad,stan,nom,met-e,zonder-n,basis)
VNW(onbep,grad,stan,nom,met-e,mv-n,basis)
VNW(onbep,grad,stan,nom,met-e,zonder-n,sup)
VNW(onbep,grad,stan,nom,met-e,mv-n,sup)
VNW(onbep,grad,stan,nom,zonder,mv-n,dim)
VNW(onbep,grad,gen,nom,met-e,mv-n,basis)
VNW(onbep,det,stan,vrij,zonder)
VNW(onbep,grad,stan,vrij,zonder,basis)
VNW(onbep,grad,stan,vrij,zonder,sup)
VNW(onbep,grad,stan,vrij,zonder,comp)
end_of_list
    ;
    # Protect from editors that replace tabs by spaces.
    $list =~ s/ \s+/\t/sg;
    my @list = split(/\r?\n/, $list);
    return \@list;
}



1;

=head1 SYNOPSIS

  use Lingua::Interset::Tagset::NL::Cgn;
  my $driver = Lingua::Interset::Tagset::NL::Cgn->new();
  my $fs = $driver->decode('N(soort,ev,basis,zijd,stan)');

or

  use Lingua::Interset qw(decode);
  my $fs = decode('nl::cgn', 'N(soort,ev,basis,zijd,stan)');

=head1 DESCRIPTION

Interset driver for the CGN/Lassy/Alpino Dutch tagset.
Tagset documentation at L<http://www.let.rug.nl/~vannoord/Lassy/POS_manual.pdf>.

=head1 AUTHOR

Ondřej Dušek, Dan Zeman

=head1 SEE ALSO

L<Lingua::Interset>,
L<Lingua::Interset::Tagset>,
L<Lingua::Interset::Tagset::Conll>,
L<Lingua::Interset::FeatureStructure>

=cut
