#!/usr/bin/env perl
# The root class for all physical tagsets covered by DZ Interset 2.0.
# Copyright © 2012 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package Lingua::Interset::Tagset;
use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
use Lingua::Interset::FeatureStructure;
use Lingua::Interset::Trie;
our $VERSION; BEGIN { $VERSION = "2.00" }



###!!! A temporary toy example.
my %postable =
(
    '.'     => ['pos' => 'punc', 'punctype' => 'peri'],
    ','     => ['pos' => 'punc', 'punctype' => 'comm'],
    '-LRB-' => ['pos' => 'punc', 'punctype' => 'brck', 'puncside' => 'ini'],
    '-RRB-' => ['pos' => 'punc', 'punctype' => 'brck', 'puncside' => 'fin'],
    '``'    => ['pos' => 'punc', 'punctype' => 'quot', 'puncside' => 'ini'],
    "''"    => ['pos' => 'punc', 'punctype' => 'quot', 'puncside' => 'fin'],
    ':'     => ['pos' => 'punc'],
    '$'     => ['pos' => 'punc', 'punctype' => 'symb', 'other' => 'currency'],
    '\#'    => ['pos' => 'punc', 'other' => '\#'],
    'AFX'   => ['pos' => 'adj',  'hyph' => 'hyph'],
    'CC'    => ['pos' => 'conj', 'conjtype' => 'coor'],
);



#------------------------------------------------------------------------------
# Decodes a physical tag (string) and returns the corresponding feature
# structure.
#------------------------------------------------------------------------------
sub decode
{
    my $self = shift;
    my $tag = shift;
    my $fs = Lingua::Interset::FeatureStructure->new();
    ###!!! A temporary toy example.
    $fs->tagset('en::penn');
    my $assignments = $postable{$tag};
    if($assignments)
    {
        $fs->multiset(@{$assignments});
    }
    return $fs;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
#------------------------------------------------------------------------------
sub list
{
    my $self = shift;
    my @list = sort(keys(%postable));
    return \@list;
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
        $fs->other('');
        my $tag1 = $self->encode($fs);
        $result{$tag1}++;
    }
    my @list1 = sort(keys(%result));
    return \@list1;
}



#------------------------------------------------------------------------------
# Reads a list of tags, decodes each tag, converts all array values to scalars
# (by sorting and joining them), remembers permitted feature structures in a
# trie. Returns a reference to the trie.
#------------------------------------------------------------------------------
sub get_permitted_structures
{
    my $self = shift;
    # Can we consider tags that require setting the 'other' feature?
    my $no_other = shift;
    my $list = $self->list();
    my $trie = Lingua::Interset::Trie->new();
    # Make sure that the list of possible tags is not empty.
    # If it is, the driver's list() function is probably not implemented.
    unless(scalar(@{$list}))
    {
        confess('Cannot figure out the permitted values because the list of possible tags is empty');
    }
    my @features = Lingua::Interset::FeatureStructure::priority_features();
    foreach my $tag (@{$list})
    {
        my $fs = $self->decode($tag);
        # If required, skip tags that set the 'other' feature.
        ###!!! Alternatively, we need not skip the tag.
        ###!!! Instead, strip the 'other' information, make sure that we have a valid tag (by encoding and decoding once more),
        ###!!! then add feature values to the tree.
        next if($no_other && exists($fs->{other}));
        # Loop over known features (in the order of feature priority).
        my $pointer = $trie;
        foreach my $f (@features)
        {
            # Make sure the value is not an array.
            ###!!! This ugly code is a pre-Moose relict. Instead of a static function, we should have a method of $fs that returns scalarized value of a particular named feature.
            my $v = Lingua::Interset::FeatureStructure::array_to_scalar_value($fs->{$f});
            # Supply tag only if this is the last feature in the list.
            my $t = $f eq $features[$#features] ? $tag : undef;
            $pointer = $trie->add_value($pointer, $v, $t);
        }
    }
    return $trie;
}



1;

=over

=item Lingua::Interset::Tagset

DZ Interset is a universal framework for reading, writing, converting and
interpreting part-of-speech and morphosyntactic tags from multiple tagsets
of many different natural languages.

The C<Tagset> class defines is the inheritance root for all classes describing
physical tagsets (strings of characters). It defines decoding of tags, encoding
and list of known tags.

=back

=cut

# Copyright © 2012 Dan Zeman <zeman@ufal.mff.cuni.cz>
# This file is distributed under the GNU General Public License v3. See doc/COPYING.txt.
