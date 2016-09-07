# ABSTRACT: Driver for the Faroese tagset provided by Bjartensen.
# See also https://github.com/UniversalDependencies/docs/issues/336
# Copyright © 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset::Tagset::FO::Bjartensen;
use strict;
use warnings;
our $VERSION = '2.053';

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
extends 'Lingua::Interset::Tagset';



has 'atoms'       => ( isa => 'HashRef', is => 'ro', builder => '_create_atoms',       lazy => 1 );
has 'feature_map' => ( isa => 'HashRef', is => 'ro', builder => '_create_feature_map', lazy => 1 );



#------------------------------------------------------------------------------
# Returns the tagset id that should be set as the value of the 'tagset' feature
# during decoding. Every derived class must (re)define this method! The result
# should correspond to the last two parts in package name, lowercased.
# Specifically, it should be the ISO 639-2 language code, followed by '::' and
# a language-specific tagset id. Example: 'cs::multext'.
#------------------------------------------------------------------------------
sub get_tagset_id
{
    return 'fo::bjartensen';
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
            # substantiv / noun
            'S' => ['pos' => 'noun'],
            # adjective
            'A' => ['pos' => 'adj'],
            # pronomen / pronoun
            'P' => ['pos' => 'noun', 'prontype' => 'prn'],
            # numeral
            'N' => ['pos' => 'num'],
            # verb
            'V' => ['pos' => 'verb'],
            # adverb
            'D' => ['pos' => 'adv'],
            # conjunction
            'C' => ['pos' => 'conj'],
            # preposition
            'E' => ['pos' => 'adp'],
            # interjection
            'I' => ['pos' => 'int'],
            # foreign word
            'F' => ['foreign' => 'foreign'],
            # unanalyzed word
            'X' => [],
            # abbreviation
            'T' => ['abbr' => 'abbr']
        },
        'encode_map' =>
        {
            'abbr' => { 'abbr' => 'T',
                        '@'    => { 'foreign' => { 'foreign' => 'F',
                                                   '@'       => { 'pos' => { 'noun' => { 'prontype' => { ''  => 'S',
                                                                                                         '@' => 'P' }},
                                                                             'adj'  => 'A',
                                                                             'num'  => 'N',
                                                                             'verb' => 'V',
                                                                             'adv'  => 'D',
                                                                             'conj' => 'C',
                                                                             'adp'  => 'E',
                                                                             'int'  => 'I',
                                                                             '@'    => 'X' }}}}}
        }
    );
    # GENDER ####################
    $atoms{gender} = $self->create_simple_atom
    (
        'intfeature' => 'gender',
        'simple_decode_map' =>
        {
            'M' => 'masc',
            'F' => 'fem',
            'N' => 'neut',
            'X' => ''
        },
        'encode_default' => 'X'
    );
    # NUMBER ####################
    $atoms{number} = $self->create_simple_atom
    (
        'intfeature' => 'number',
        'simple_decode_map' =>
        {
            'S' => 'sing',
            'P' => 'plur'
        },
        'encode_default' => 'X'
    );
    # CASE ####################
    # also used as valency feature of adverbs and prepositions; then N means "does not govern case"
    $atoms{case} = $self->create_simple_atom
    (
        'intfeature' => 'case',
        'simple_decode_map' =>
        {
            'N' => 'nom',
            'A' => 'acc',
            'D' => 'dat',
            'G' => 'gen'
        },
        'encode_default' => 'X'
    );
    # DEFINITENESS ####################
    $atoms{definiteness} = $self->create_simple_atom
    (
        'intfeature' => 'definiteness',
        'simple_decode_map' =>
        {
            # definite (i.e. with suffixed definite article)
            'A' => 'def'
        },
        'encode_default' => 'X'
    );
    # NAME TYPE ####################
    $atoms{nametype} = $self->create_atom
    (
        'surfeature' => 'nametype',
        'decode_map' =>
        {
            'P' => ['nountype' => 'prop', 'nametype' => 'prs'],
            'L' => ['nountype' => 'prop', 'nametype' => 'geo']
        },
        'encode_map' =>
        {
            'nametype' => { 'prs' => 'P',
                            'geo' => 'L',
                            '@'   => 'X' }
        }
    );
    # DEGREE OF COMPARISON ####################
    $atoms{degree} = $self->create_simple_atom
    (
        'intfeature' => 'degree',
        'simple_decode_map' =>
        {
            'P' => 'pos',
            'C' => 'cmp',
            'S' => 'sup'
        },
        'encode_default' => 'X'
    );
    # DECLENSION OF ADJECTIVES ####################
    $atoms{declension} = $self->create_atom
    (
        'surfeature' => 'declension',
        'decode_map' =>
        {
            'S' => ['other' => {'declension' => 'strong'}],
            'W' => ['other' => {'declension' => 'weak'}],
            'I' => ['other' => {'declension' => 'indeclinable'}]
        },
        'encode_map' =>
        {
            'other/declension' => { 'strong' => 'S',
                                    'weak'   => 'W',
                                    '@'      => 'I' }
        }
    );
    # PRONOUN TYPE ####################
    $atoms{prontype} = $self->create_atom
    (
        'surfeature' => 'prontype',
        'decode_map' =>
        {
            'D' => ['prontype' => 'dem'],
            'I' => ['prontype' => 'ind']
        },
        'encode_map' =>
        {
            'prontype' => { 'dem' => 'D',
                            '@'   => 'I' }
        }
    );
    # NUMERAL TYPE ####################
    $atoms{numtype} = $self->create_atom
    (
        'surfeature' => 'numtype',
        'decode_map' =>
        {
            'C' => ['numtype' => 'card'],
            'O' => ['numtype' => 'ord']
        },
        'encode_map' =>
        {
            'numtype' => { 'ord' => 'O',
                           '@'   => 'C' }
        }
    );
    # VERB FORM AND MOOD ####################
    $atoms{verbform} = $self->create_atom
    (
        'surfeature' => 'verbform',
        'decode_map' =>
        {
            'I' => ['verbform' => 'inf'],
            'M' => ['verbform' => 'fin', 'mood' => 'imp'],
            'N' => ['verbform' => 'fin', 'mood' => 'ind'],
            'S' => ['verbform' => 'fin', 'mood' => 'sub'],
            'P' => ['verbform' => 'part', 'tense' => 'pres'],
            'A' => ['verbform' => 'part', 'tense' => 'past'],
            # medium (what is it? according to wiktionary, Faroese has supine - could it be it?)
            'M' => ['verbform' => 'sup']
        },
        'encode_map' =>
        {
            'verbform' => { 'fin'  => { 'mood' => { 'imp' => 'M',
                                                    'sub' => 'S',
                                                    '@'   => 'N' }},
                            'part' => { 'tense' => { 'pres' => 'P',
                                                     '@'    => 'A' }},
                            'sup'  => 'M',
                            '@'    => 'I' }
        }
    );
    # TENSE ####################
    $atoms{tense} = $self->create_simple_atom
    (
        'intfeature' => 'tense',
        'simple_decode_map' =>
        {
            'P' => 'pres',
            'A' => 'past'
        },
        'encode_default' => 'X'
    );
    # PERSON ####################
    $atoms{person} = $self->create_simple_atom
    (
        'intfeature' => 'person',
        'simple_decode_map' =>
        {
            '1' => '1',
            '2' => '2',
            '3' => '3'
        },
        'encode_default' => 'X'
    );
    # CONJUNCTION TYPE ####################
    $atoms{conjtype} = $self->create_atom
    (
        'surfeature' => 'conjtype',
        'decode_map' =>
        {
            'I' => ['conjtype' => 'sub', 'verbform' => 'inf'], # infinitive marker
            'R' => ['conjtype' => 'sub'] # relative conjunction
        },
        'encode_map' =>
        {
            'conjtype' => { 'sub' => { 'verbform' => { 'inf' => 'I',
                                                       '@'   => 'R' }},
                            '@'   => 'X' }
        }
    );
    return \%atoms;
}



#------------------------------------------------------------------------------
# Creates a map that tells for each surface part of speech which features are
# relevant and in what order they appear.
#------------------------------------------------------------------------------
sub _create_feature_map
{
    my $self = shift;
    my %features =
    (
        'S'  => ['pos', 'gender', 'number', 'case', 'definiteness', 'nametype'],
        'A'  => ['pos', 'degree', 'declension', 'gender', 'number', 'case'],
        'P'  => ['pos', 'prontype', 'gender', 'number', 'case'],
        'N'  => ['pos', 'numtype', 'gender', 'number', 'case'],
        'V'  => ['pos', 'verbform', 'tense', 'number', 'person'],
        'VA' => ['pos', 'verbform', 'gender', 'number', 'case'],
        'D'  => ['pos', 'degree', 'case'],
        'C'  => ['pos', 'conjtype'],
        'E'  => ['pos', 'case']
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
    $fs->set_tagset('fo::bjartensen');
    my $atoms = $self->atoms();
    my $features = $self->feature_map();
    my @chars = split(//, $tag);
    $atoms->{pos}->decode_and_merge_hard($chars[0], $fs);
    my $fpos = $chars[0];
    $fpos = 'VA' if($chars[0] eq 'V' && $chars[1] eq 'A');
    my @features;
    @features = @{$features->{$fpos}} if(defined($features->{$fpos}));
    for(my $i = 1; $i<=$#features; $i++)
    {
        if(defined($features[$i]) && defined($chars[$i]))
        {
            # Tagset drivers normally do not throw exceptions because they should be able to digest any input.
            # However, if we know we expect a feature and we have not defined an atom to handle that feature,
            # then it is an error of our code, not of the input data.
            if(!defined($atoms->{$features[$i]}))
            {
                confess("There is no atom to handle the feature '$features[$i]'");
            }
            $atoms->{$features[$i]}->decode_and_merge_hard($chars[$i], $fs);
        }
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
    my $features = $self->feature_map();
    my $tag = $atoms->{pos}->encode($fs);
    my $fpos = $tag;
    $fpos = 'VA' if($fs->is_participle() && $fs->is_past());
    my @features;
    @features = @{$features->{$fpos}} if(defined($features->{$fpos}));
    for(my $i = 1; $i<=$#features; $i++)
    {
        if(defined($features[$i]))
        {
            # Tagset drivers normally do not throw exceptions because they should be able to digest any input.
            # However, if we know we expect a feature and we have not defined an atom to handle that feature,
            # then it is an error of our code, not of the input data.
            if(!defined($atoms->{$features[$i]}))
            {
                confess("There is no atom to handle the feature '$features[$i]'");
            }
            $tag .= $atoms->{$features[$i]}->encode($fs);
        }
        else
        {
            $tag .= 'X';
        }
    }
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
#------------------------------------------------------------------------------
sub list
{
    my $self = shift;
    my $list = <<end_of_list
SFSNP
end_of_list
    ;
    # Protect from editors that replace tabs by spaces.
    $list =~ s/ \s+/\t/sg;
    my @list = split(/\r?\n/, $list);
    return \@list;
}



1;

=head1 SYNOPSIS

  use Lingua::Interset::Tagset::FO::Bjartensen;
  my $driver = Lingua::Interset::Tagset::FO::Bjartensen->new();
  my $fs = $driver->decode('SFSNP');

or

  use Lingua::Interset qw(decode);
  my $fs = decode('fo::bjartensen', 'SFSNP');

=head1 DESCRIPTION

Interset driver for the Faroese tagset briefly described by Bjartensen in
https://github.com/UniversalDependencies/docs/issues/336

=head1 SEE ALSO

L<Lingua::Interset>,
L<Lingua::Interset::Tagset>,
L<Lingua::Interset::FeatureStructure>

=cut
