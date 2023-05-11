# ABSTRACT: Driver for the UniMorph features.
# https://unimorph.github.io/
# Copyright © 2023 Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset::Tagset::MUL::Unimorph;
use strict;
use warnings;
our $VERSION = '3.016';

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
use Lingua::Interset::FeatureStructure;
extends 'Lingua::Interset::Tagset';



#------------------------------------------------------------------------------
# Returns the tagset id that should be set as the value of the 'tagset' feature
# during decoding. Every derived class must (re)define this method! The result
# should correspond to the last two parts in package name, lowercased.
# Specifically, it should be the ISO 639-2 language code, followed by '::' and
# a language-specific tagset id. Example: 'cs::multext'.
#------------------------------------------------------------------------------
sub get_tagset_id
{
    return 'mul::unimorph';
}



#------------------------------------------------------------------------------
# Decodes a physical tag (string) and returns the corresponding feature
# structure.
#------------------------------------------------------------------------------
sub decode
{
    my $self = shift;
    my $tag = shift;
    # There is a string of feature values, separated by semicolons. The order of
    # the features is not significant, except that the main part of speech always
    # comes first.
    my @features = split(/;/, $tag);
    $fs->set_tagset('mul::unimorph');
    ###!!!
    # DECODE THE FEATURES HERE.
    ###!!!
    return $fs;
}



#------------------------------------------------------------------------------
# Takes feature structure and returns the corresponding physical tag (string).
#------------------------------------------------------------------------------
sub encode
{
    my $self = shift;
    my $fs = shift; # Lingua::Interset::FeatureStructure
    ###!!!
    # ENCODE THE FEATURES HERE.
    ###!!!
    my $tag = join(';', @features);
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
###!!! WHAT DO WE DO FOR UNIMORPH HERE? THERE ARE TOO MANY POSSIBLE COMBINATIONS.
#------------------------------------------------------------------------------
sub list
{
    my $self = shift;
    my @list = ();
    return \@list;
}



1;

=head1 SYNOPSIS

  use Lingua::Interset::Tagset::MUL::Unimorph;
  my $driver = Lingua::Interset::Tagset::MUL::Unimorph->new();
  my $fs = $driver->decode("N;MASC;SG;NOM");

or

  use Lingua::Interset qw(decode);
  my $fs = decode('mul::unimorph', "N;MASC;SG;NOM");

=head1 DESCRIPTION

Interset driver for UniMorph 4.0 feature strings,
see L<https://unimorph.github.io/>.

=head1 SEE ALSO

L<Lingua::Interset>
L<Lingua::Interset::Tagset>,
L<Lingua::Interset::Tagset::MUL::Uposf>,
L<Lingua::Interset::Atom>,
L<Lingua::Interset::FeatureStructure>

=cut
