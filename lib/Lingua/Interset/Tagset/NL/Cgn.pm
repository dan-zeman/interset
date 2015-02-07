# ABSTRACT: Driver for the CGN/Lassy/Alpino Dutch tagset.
# Copyright © 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Copyright © 2014 Ondřej Dušek <odusek@ufal.mff.cuni.cz>

# tagset documentation at
# http://www.let.rug.nl/~vannoord/Lassy/POS_manual.pdf

package Lingua::Interset::Tagset::NL::Cgn;
use strict;
use warnings;
our $VERSION = '2.033';

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
            'ADJ'  => ['pos' => 'adj'], # groot, goed, bekend, nodig, vorig
            'BW'   => ['pos' => 'adv'], # zo, nu, dan, hier, altijd
            'LET'  => ['pos' => 'punc'], # " ' : ( ) ...
            'LID'  => ['pos' => 'adj', 'prontype' => 'art'], # het, der, de, des, den
            'N'    => ['pos' => 'noun'], # jaar, heer, land, plaats, tijd
            'TSW'  => ['pos' => 'int'], # ja, nee
            'TW'   => ['pos' => 'num'], # twee, drie, vier, miljoen, tien
            'VG'   => ['pos' => 'conj'], # en, maar, of, dat, als, om
            'VNW'  => ['pos' => 'noun', 'prontype' => 'prs'], # ik, we, wij, u, je, jij, jullie, ze, zij, hij, het, ie, zijzelf
            'VZ'   => ['pos' => 'adp', 'adpostype' => 'prep'], # van, in, op, met, voor
            'WW'   => ['pos' => 'verb'] # worden, zijn, blijven, komen, wezen
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
    # ADJECTIVE TYPE ####################
    $atoms{adjtype} = $self->create_atom
    (
        'surfeature' => 'adjtype',
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
            # pronominal adverbs
            'adv-pron' => ['other' => {'usage' => 'advpron'}]
        },
        'encode_map' =>
        {
            'other/usage' => { 'prenom'  => 'prenom',
                               'postnom' => 'postnom',
                               'vrij'    => 'vrij',
                               'nom'     => 'nom',
                               'advpron' => 'adv-pron' }
        }
    );
    # DEGREE ####################
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
            'sup'   => 'sup'
        }
    );
    # INFLECTED FORM ####################
    $atoms{inflection} = $self->create_atom
    (
        'surfeature' => 'inflection',
        'decode_map' =>
        {
            # base form (een mooi huis)
            'zonder'   => [],
            # -e (een groote pot, een niet te verstane verleiding); adjectives, verbs
            'met-e'    => ['other' => {'inflection' => 'e'}],
            # -s (iets moois)
            'met-s'    => ['other' => {'inflection' => 's'}],
            # nominal usage without plural -n (het groen)
            'zonder-n' => ['other' => {'inflection' => 'non'}],
            # nominal usage with plural -n (de rijken)
            'mv-n'     => ['number' => 'plur']
        },
        'encode_map' =>
        {
            'number' => { 'plur' => 'mv-n',
                          '@'    => { 'other/inflection' => { 'e'   => 'met-e',
                                                              's'   => 'met-s',
                                                              'non' => 'zonder-n',
                                                              '@'   => 'zonder' }}}
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
    # GENDER ####################
    $atoms{gender} = $self->create_simple_atom
    (
        'intfeature' => 'gender',
        'simple_decode_map' =>
        {
            'zijd' => 'com',  # non-neuter (de)
            'masc' => 'masc', # masculine; only pronouns
            'fem'  => 'fem',  # feminine; only pronouns
            'onz'  => 'neut'  # neuter (het)
        }
    );
    # CASE ####################
    $atoms{case} = $self->create_atom
    (
        'surfeature' => 'case',
        'decode_map' =>
        {
            # no case (i.e. nominative or a word that does not take case markings) (het, de, een)
            'stan'  => [],
            # nominative (only pronouns: ik, we, wij, u, je, jij, jullie, ze, zij, hij, het, ie, zijzelf)
            'nomin' => ['case' => 'nom'],
            # oblique case (mij, haar, ons)
            'obl'   => ['case' => 'acc'],
            # genitive (der, des)
            'gen'   => ['case' => 'gen'],
            # dative (den)
            'dat'   => ['case' => 'dat'],
            # 'special' case (zaliger gedachtenis, van goeden huize, ten enen male)
            'bijz'  => ['case' => 'acc']
        },
        'encode_map' =>
        {
            'case' => { 'nom' => 'nomin',
                        'gen' => 'gen',
                        'dat' => 'dat',
                        'acc' => 'obl' }
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
    # NUMBER ####################
    $atoms{number} = $self->create_atom
    (
        'surfeature' => 'number',
        'decode_map' =>
        {
            # enkelvoud (jaar, heer, land, plaats, tijd)
            'ev'   => ['number' => 'sing'],
            'evf'  => ['number' => 'sing'],
            'evmo' => ['number' => 'sing'],
            'evon' => ['number' => 'sing'],
            # meervoud (mensen, kinderen, jaren, problemen, landen)
            'mv'   => ['number' => 'plur']
        },
        'encode_map' =>
        {
            'number' => { 'sing' => 'ev',
                          'plur' => 'mv' }
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
            'vol' => 'long', # zij, haar
            'red' => 'short' # ze, d'r
        }
    );
    # VERB FORM, MOOD, TENSE AND ASPECT ####################
    $atoms{verbform} = $self->create_atom
    (
        'surfeature' => 'verbform',
        'decode_map' =>
        {
            'pv'    => ['verbform' => 'fin'],
            'inf'   => ['verbform' => 'inf'],
            'tgw'   => ['verbform' => 'fin', 'mood' => 'ind', 'tense' => 'pres'],
            'met-t' => [], # sg. 2nd+3rd person, 'u' (polite form for sg. and pl.)
            'verl'  => ['verbform' => 'fin', 'mood' => 'ind', 'tense' => 'past'],
            'conj'  => ['mood' => 'sub'], # expressing wishes (het ga je goed)
            'od'    => ['verbform' => 'part', 'tense' => 'pres'], # (volgend, verrassend, bevredigend, vervelend, aanvallend)
            'vd'    => ['verbform' => 'part', 'tense' => 'past'], # (afgelopen, gekomen, gegaan, gebeurd, begonnen)
        },
        'encode_map' =>
        {
            'verbform' => { 'inf'  => 'inf',
                            'fin'  => { 'mood' => { 'ind' => { 'tense' => { 'pres' => 'tgw',
                                                                            'past' => 'verl' }},
                                                    'sub' => 'conj' }},
                            'part' => { 'tense' => { 'pres' => 'od',
                                                     'past' => 'vd' }}}
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
    my @features = ('pos', 'nountype', 'adjtype', 'degree', 'inflection', 'definiteness', 'gender', 'case', 'number',
                    'prontype', 'person', 'pronform', 'numtype', 'verbform', 'adpostype', 'conjtype', 'symbol');
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
        'N' => ['nountype'],
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
    my $tag = $pos;
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
ADJ
BW
LET
LID
N
TSW
TW
VG
VNW
VZ
WW
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
  my $fs = $driver->decode('N');

or

  use Lingua::Interset qw(decode);
  my $fs = decode('nl::cgn', 'N');

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
