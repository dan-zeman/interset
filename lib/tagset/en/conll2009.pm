#!/usr/bin/perl
# Driver for the CoNLL 2009 English tagset.
# This tagset differs slightly from the English tagset of CoNLL 2006 and 2007.
# Copyright © 2009 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::en::conll2009;
use utf8;
use tagset::common;
use tagset::en::penn;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    # The CoNLL tagset is derived from the Penn tagset.
    # POS is the entire Penn tag.
    # Features is an underscore.
    my $pos = conll_to_penn($tag);
    return tagset::en::penn::decode($pos);
}



#------------------------------------------------------------------------------
# Takes feature hash.
# Returns tag string.
#------------------------------------------------------------------------------
sub encode
{
    my $f = shift;
    # The CoNLL tagset is derived from the Penn tagset.
    # Coarse-grained POS is the first two characters of the Penn tag.
    # Fine-grained POS is the entire Penn tag.
    # Features is an underscore.
    my $tag = tagset::en::penn::encode($f);
    return penn_to_conll($tag);
}



#------------------------------------------------------------------------------
# Converts a Penn English tag into the CoNLL 2009 format.
#------------------------------------------------------------------------------
sub penn_to_conll
{
    my $tag = shift;
    if($tag eq '-LRB-')
    {
        $tag = '(';
    }
    elsif($tag eq '-RRB-')
    {
        $tag = ')';
    }
    elsif($tag eq 'AFX')
    {
        $tag = 'PRF';
    }
    return "$tag\t_";
}



#------------------------------------------------------------------------------
# Converts a CoNLL 2009 English tag into the Penn Treebank tagset.
#------------------------------------------------------------------------------
sub conll_to_penn
{
    my $tag = shift;
    # two components: part-of-speech tag and features (no features for English)
    # example: IN\t_
    my ($pos, $features) = split(/\s+/, $tag);
    if($pos eq '(')
    {
        $pos = '-LRB-';
    }
    elsif($pos eq ')')
    {
        $pos = '-RRB-';
    }
    elsif($pos eq 'PRF')
    {
        $pos = 'AFX';
    }
    return $pos;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
#------------------------------------------------------------------------------
sub list
{
    my $list = tagset::en::penn::list();
    map {$_ = penn_to_conll($_)} @{$list};
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
