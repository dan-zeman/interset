# ABSTRACT: The root class for all physical tagsets covered by DZ Interset 2.0.
# Copyright © 2012, 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset::Tagset;

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
use MooseX::SemiAffordanceAccessor; # attribute x is written using set_x($value) and read using x()
use Lingua::Interset::FeatureStructure;
use Lingua::Interset::Trie;



has 'permitted_structures' => ( isa => 'Lingua::Interset::Trie', is => 'ro', builder => '_build_permitted_structures', lazy => 1 );
has 'permitted_values' => ( isa => 'HashRef', is => 'ro', builder => '_build_permitted_values', lazy => 1 );



#------------------------------------------------------------------------------
# Decodes a physical tag (string) and returns the corresponding feature
# structure.
#------------------------------------------------------------------------------
sub decode
{
    my $self = shift;
    my $tag = shift;
    my $fs = Lingua::Interset::FeatureStructure->new();
    ###!!! Should we rather confess() here?
    my %other =
    (
        'error' => 'Not implemented. Lingua::Interset::Tagset::decode() must be overridden in the tagset driver.',
        'tag' => $tag
    );
    $fs->set_other(\%other);
    return $fs;
}



#------------------------------------------------------------------------------
# Takes feature structure and returns the corresponding physical tag (string).
#------------------------------------------------------------------------------
sub encode
{
    my $self = shift;
    my $fs = shift; # Lingua::Interset::FeatureStructure
    ###!!! Should we rather confess() here?
    my $tag = '_INTERSET_ENCODE_NOT_IMPLEMENTED_';
    return $tag;
}



#------------------------------------------------------------------------------
# Takes feature structure and returns the corresponding physical tag (string).
# Unlike encode(), this method ensures that the result is a known tag of the
# target tagset. Positional tagsets allow in principle encoding feature-value
# combination that never occur in the original corpus but may make sense when
# converted from another tagset. Strict encoding can block this if desired.
# Note however, that using strict encoding may result in unnecessary loss or
# bias of information. For example, Interset says that it's the third person
# but strict encoding may realize that only first or second persons occur with
# the combination of values that have been processed before: then you will get
# the first person on the output!
#------------------------------------------------------------------------------
sub encode_strict
{
    my $self = shift;
    my $fs = shift; # Lingua::Interset::FeatureStructure
    confess('Undefined Interset feature structure') if(!defined($fs));
    # We are going to damage the feature structure so we should make its copy first.
    # The caller may still need the original structure!
    my $fs1 = $fs->duplicate();
    my $permitted = $self->permitted_structures();
    $fs1->enforce_permitted_values($permitted);
    return $self->encode($fs1);
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
#------------------------------------------------------------------------------
sub list
{
    my $self = shift;
    ###!!! Should we rather confess() here?
}



###############################################################################
# COLLECTING PERMITTED FEATURE VALUES OF A TAGSET
###############################################################################



#------------------------------------------------------------------------------
# Filters a list of tags so that the resulting list contains only tags that
# can result from conversion from a different tagset. These tags do not depend
# on the 'other' feature. It is not to say that decoding them necessarily
# leaves the feature empty. However, these tags are default with respect to the
# feature, so if the feature is not available, encoder picks the default tag.
#
# Note that it is not guaranteed that the resulting list is a subset of the
# original list. It is possible, though undesirable, that decode -> strip other
# -> encode creates an unknown tag.
#------------------------------------------------------------------------------
sub list_other_resistant_tags
{
    my $self = shift;
    my $list0 = shift; # reference to array
    my $decode = shift; # reference to driver-specific decoding function
    my $encode = shift; # reference to driver-specific encoding function
    my %result;
    foreach my $tag0 (@{$list0})
    {
        my $fs = $self->decode($tag0);
        $fs->set_other('');
        my $tag1 = $self->encode($fs);
        $result{$tag1}++;
    }
    my @list1 = sort(keys(%result));
    return \@list1;
}



#------------------------------------------------------------------------------
# Creates the trie description of all permitted feature structures (Lingua::
# Interset::Trie) and returns a reference to it. The trie is constructed lazily
# on the first demand. The builder reads the list of known tags, decodes each
# tag, converts all array values to scalars (by sorting and joining them) and
# remembers permitted feature structures in the trie.
#------------------------------------------------------------------------------
sub _build_permitted_structures
{
    my $self = shift;
    my $no_other = shift; ###!!!
    # This is a lazy attribute and the builder can be called anytime, even
    # from map() or grep(). Avoid damaging the caller's $_!
    local $_;
    my $list = $self->list();
    # Make sure that the list of possible tags is not empty.
    # If it is, the driver's list() function is probably not implemented.
    unless(scalar(@{$list}))
    {
        confess('Cannot figure out the permitted values because the list of possible tags is empty');
    }
    my @features = Lingua::Interset::FeatureStructure::priority_features();
    my $trie = Lingua::Interset::Trie->new('features' => \@features);
    foreach my $tag (@{$list})
    {
        my $fs = $self->decode($tag);
        # If required, skip tags that set the 'other' feature.
        ###!!! Alternatively, we need not skip the tag.
        ###!!! Instead, strip the 'other' information, make sure that we have a valid tag (by encoding and decoding once more),
        ###!!! then add feature values to the tree.
        next if($no_other && $fs->other());
        # Loop over known features (in the order of feature priority).
        my $pointer = $trie->root_hash();
        foreach my $f (@features)
        {
            # Make sure the value is not an array.
            my $v = $fs->get_joined($f);
            # Supply tag only if this is the last feature in the list.
            my $t = $f eq $features[$#features] ? $tag : undef;
            $pointer = $trie->add_value($pointer, $v, $t);
        }
    }
    return $trie;
}



#------------------------------------------------------------------------------
# Creates a hash of permitted feature values for this tagset:
# ($hash{$feature}{$value} != 0) => tagset permits $value of $feature
# Note that a value that is permitted in one context may not be permitted in
# another. Unlike in permitted_structures, this hash just ignores context.
# The builder reads a list of tags, decodes each tag and remembers occurrences
# of feature values in the hash. It returns a reference to the hash.
#------------------------------------------------------------------------------
sub _build_permitted_values
{
    my $self = shift;
    # This is a lazy attribute and the builder can be called anytime, even
    # from map() or grep(). Avoid damaging the caller's $_!
    local $_;
    my $list = $self->list();
    # Make sure that the list of possible tags is not empty.
    # If it is, probably the driver's list() function is not implemented.
    unless(scalar(@{$list}))
    {
        confess('Cannot figure out the permitted values because the list of possible tags is empty');
    }
    my @features = Lingua::Interset::FeatureStructure::priority_features();
    my %values;
    foreach my $tag (@{$list})
    {
        my $fs = $self->decode($tag);
        foreach my $f (@features)
        {
            # Make sure the value is always a list of values.
            my @v = $fs->get_list($f);
            foreach my $v (@v)
            {
                $values{$f}{$v}++;
            }
        }
    }
    return \%values;
}



1;


=head1 SYNOPSIS

  package Lingua::Interset::MY::Tagset;
  use Moose;
  extends 'Lingua::Interset::Tagset';
  use Lingua::Interset::FeatureStructure;

  sub decode
  {
      my $self = shift;
      my $tag = shift;
      my $fs = Lingua::Interset::FeatureStructure->new();
      ...
      return $fs;
  }

  sub encode
  {
      my $self = shift;
      my $fs = shift; # Lingua::Interset::FeatureStructure
      my $tag;
      ...
      return $tag;
  }

  sub list
  {
      my $self = shift;
      return ['NOUN', 'VERB', 'OTHER'];
  }

  1;

=head1 DESCRIPTION

DZ Interset is a universal framework for reading, writing, converting and
interpreting part-of-speech and morphosyntactic tags from multiple tagsets
of many different natural languages.

The C<Tagset> class is the inheritance root for all classes describing
physical tagsets (sets of strings of characters). It defines decoding of tags, encoding
and list of known tags.

=cut
