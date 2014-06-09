#!/usr/bin/env perl
# A trie-like structure for DZ Interset features and their values.
# Copyright © 2012, 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package Lingua::Interset::Trie;
use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
use Carp;
our $VERSION; BEGIN { $VERSION = "2.00" }



has root_hash ( isa => 'HashRef', is => 'rw', default => {} );



#------------------------------------------------------------------------------
# Adds a feature value to the trie. It does not need to know the feature name.
# It takes the feature value and the pointer to the trie level corresponding to
# the feature (reference to an existing hash). If the hash already has a key
# corresponding to the value, the function only advances to the sub-hash
# referenced by the value, and returns the new pointer. If there is no such
# key, the function first creates the new sub-hash and then advances the
# pointer.
#------------------------------------------------------------------------------
sub add_value
{
    my $self = shift;
    my $pointer = shift; # hash reference
    my $value = shift;
    my $tag = shift; # tag example; only for the last feature
    if(!exists($pointer->{$value}))
    {
        # Last feature (last level of the trie) stores tag examples instead of pointers.
        if(defined($tag) && $tag ne '')
        {
            $pointer->{$value} = $tag;
        }
        else
        {
            my %new_sub_hash;
            $pointer->{$value} = \%new_sub_hash;
        }
    }
    return $pointer->{$value};
}



#------------------------------------------------------------------------------
# Advances a trie pointer. Normally it observes the value of the current
# feature. Special treatment of the "tagset" and "other" features.
#------------------------------------------------------------------------------
sub advance_pointer
{
    my $self = shift;
    my $pointer = shift;
    my $feature = shift;
    my $value = shift;
    if($feature =~ m/^(tagset|other)$/)
    {
        my @keys = keys(%{$pointer});
        $value = $keys[0];
    }
    else
    {
        if(ref($value) eq 'ARRAY')
        {
            $value = join('|', @{$value});
        }
        if(!exists($pointer->{$value}))
        {
            confess("Dead trie pointer.");
        }
    }
    return $pointer->{$value};
}



1;

=over

=item Lingua::Interset::Trie

The C<Trie> class defines a trie-like data structure for DZ Interset features
and their values. It is an auxiliary data structure that an outside user should
not need to use directly.

It is used to describe all feature-value combinations that
are permitted under a given tagset. (Example: If the prefix already traversed
in the trie indicates that we have a noun, with subtype of proper noun, what
are the possible values of the next feature, say, gender?)

The trie assumes that features are ordered according to their priority.
However, the priorities are defined outside the trie, by default in the
FeatureStructure class, or they may be overriden in a Tagset subclass.
The trie can store features in any order.

=back

=cut

# Copyright © 2012 Dan Zeman <zeman@ufal.mff.cuni.cz>
# This file is distributed under the GNU General Public License v3. See doc/COPYING.txt.
