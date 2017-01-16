# ABSTRACT: Implements a converter between two physical tagsets via Interset.
# Copyright © 2015 Univerzita Karlova v Praze / Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset::Converter;
use strict;
use warnings;
our $VERSION = '3.003';

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose 2;
use MooseX::SemiAffordanceAccessor; # attribute x is written using set_x($value) and read using x()
use Lingua::Interset qw(decode encode list);

has 'from'   => ( isa => 'Str', is => 'ro', required => 1, documentation => 'Source tagset identifier, e.g. cs::multext' );
has 'to'     => ( isa => 'Str', is => 'ro', required => 1, documentation => 'Target tagset identifier, e.g. cs::pdt' );
has '_cache' => ( isa => 'HashRef', is => 'ro', default => sub { return {} } );



#------------------------------------------------------------------------------
# Converts tag from tagset A to tagset B via Interset. Caches tags converted
# previously.
#------------------------------------------------------------------------------
=method convert()

  my $tag1  = convert ($tag0);

Converts tag from the source tagset to the target tagset via Interset.
Tags once converted are cached so the (potentially costly) Interset decoding-encoding
methods are called only once per source tag.

=cut
sub convert
{
    my $self = shift;
    my $stag = shift;
    my $cache = $self->_cache();
    my $ttag = $cache->{$stag};
    if(!defined($ttag))
    {
        my $stagset = $self->from();
        my $ttagset = $self->to();
        $ttag = encode($ttagset, decode($stagset, $stag));
        $cache->{$stag} = $ttag;
    }
    return $ttag;
}



1;

=head1 SYNOPSIS

  use Lingua::Interset::Converter;

  my $c = new Lingua::Interset::Converter ('from' => 'cs::multext', 'to' => 'cs::pdt');
  while (<CONLL_IN>)
  {
      chomp ();
      my @fields = split (/\t/, $_);
      my $source_tag = $fields[4];
      $fields[4] = $c->convert ($source_tag);
      print (join("\t", @fields), "\n");
  }

=head1 DESCRIPTION

C<Converter> is a simple class that implements Interset-based conversion of tags
between two physical tagsets. It includes caching, which will improve performance
when converting tags in a large corpus.

=attr from

Identifier of the source tagset (composed of language code and tagset id, all
lowercase, for example C<cs::multext>). It must be provided upon construction.

=attr from

Identifier of the target tagset (composed of language code and tagset id, all
lowercase, for example C<cs::pdt>). It must be provided upon construction.

=head1 SEE ALSO

L<Lingua::Interset>

=cut
