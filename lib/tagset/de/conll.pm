#!/usr/bin/perl
# Driver for the CoNLL/STTS German tagset.
# Copyright © 2008 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::de::conll;
use utf8;
use tagset::de::stts;



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    # three components: coarse-grained pos, fine-grained pos, features
    # example: NE\tNE\t_
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    # The CoNLL tagset is derived from the STTS tagset.
    # Coarse-grained POS is the STTS tag.
    # Fine-grained POS is another copy of the STTS tag.
    # Features is an underscore.
    return tagset::de::stts::decode($pos);
}



#------------------------------------------------------------------------------
# Takes feature hash.
# Returns tag string.
#------------------------------------------------------------------------------
sub encode
{
    my $f = shift;
    # The CoNLL tagset is derived from the STTS tagset.
    # Coarse-grained POS is the STTS tag.
    # Fine-grained POS is another copy of the STTS tag.
    # Features is an underscore.
    my $tag = tagset::de::stts::encode($f);
    return "$tag\t$tag\t_";
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
#------------------------------------------------------------------------------
sub list
{
    my $list = tagset::de::stts::list();
    foreach my $tag (@{$list})
    {
        $tag = "$tag\t$tag\t_";
    }
    return $list;
}



#------------------------------------------------------------------------------
# Create trie of permitted feature structures. This will be needed for strict
# encoding. This BEGIN block cannot appear before the definition of the list()
# function.
#------------------------------------------------------------------------------
BEGIN
{
    # Store the hash reference in a global variable.
    $permitted = tagset::common::get_permitted_structures_joint(list(), \&decode);
}



1;
