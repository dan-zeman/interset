# ABSTRACT: A trie-like structure for DZ Interset features and their values.
# Copyright © 2012, 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset::Trie;

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
use MooseX::SemiAffordanceAccessor; # attribute x is written using set_x($value) and read using x()
use Carp;



has 'root_hash' => ( isa => 'HashRef',  is => 'rw', default => sub {{}} );
has 'features'  => ( isa => 'ArrayRef', is => 'rw', required => 1 );



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



#------------------------------------------------------------------------------
# Debugging function. Returns permitted feature values in a form suitable for
# printing.
#------------------------------------------------------------------------------
sub as_string
{
    my $self = shift;
    my $fs = new Lingua::Interset::FeatureStructure();
    return $self->get_permitted_combinations_as_text_recursion($fs, 0, $self->root_hash());
}



#------------------------------------------------------------------------------
# Recursive part of printing permitted feature value combinations.
#------------------------------------------------------------------------------
sub get_permitted_combinations_as_text_recursion
{
    my $self = shift;
    my $fs0 = shift; # Lingua::Interset::FeatureStructure
    my $i = shift; # index of the next feature to process
    my $pointer = shift; # reference to the current hash in the trie
    my @features = @{$self->features()};
    return if($i>$#features);
    my $string;
    # Loop through permitted values of the next feature.
    my @values = sort(keys(%{$pointer}));
    foreach my $value (@values)
    {
        # Add the value of the next feature to the feature structure.
        my $fs1 = $fs0->duplicate();
        $fs1->set($features[$i], $value);
        # If this is the last feature, print the feature structure.
        if($i==$#features)
        {
            $string .= $fs1->as_string()."\n";
        }
        # Otherwise, go to the next feature.
        else
        {
            $string .= $self->get_permitted_combinations_as_text_recursion($fs1, $i+1, $pointer->{$value});
        }
    }
    return $string;
}



#------------------------------------------------------------------------------
# If a feature structure is permitted, returns an example of a known tag that
# generates the same feature structure. Otherwise returns an empty string.
#------------------------------------------------------------------------------
sub get_tag_example
{
    my $self = shift;
    my $fs = shift; # Lingua::Interset::FeatureStructure
    my @features = @{$self->features()};
    my $pointer = $self->root_hash();
    foreach my $feature (@features)
    {
        my $value = $fs->get_joined($feature);
        # advance_pointer() will die if we supply a forbidden feature value so we must check it here.
        if(exists($pointer->{$value}) || $feature =~ m/^(tagset|other)$/)
        {
            $pointer = $self->advance_pointer($pointer, $feature, $value);
        }
        else
        {
            return "Forbidden value $value of feature $feature";
        }
    }
    # The last hash in the trie (the one for the last feature) points to examples of tags.
    # Thus if we are here, our $pointer is no longer a hash reference but a scalar string.
    return $pointer;
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
