#!/usr/bin/perl
# Driver for the CoNLL 2009 Czech tagset.
# This tagset differs slightly from the Czech tagset of CoNLL 2006 and 2007.
# Copyright © 2009 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::cs::conll2009;
use utf8;
use tagset::cs::conll;
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
    $tag = conll_2009_to_2006($tag);
    my $fs = tagset::cs::conll::decode($tag);
    return $fs;
}



#------------------------------------------------------------------------------
# Takes feature hash.
# Returns tag string.
#------------------------------------------------------------------------------
sub encode
{
    my $fs = shift;
    my $tag = tagset::cs::conll::encode($fs);
    $tag = conll_2006_to_2009($tag);
    return $tag;
}



#------------------------------------------------------------------------------
# Converts a CoNLL 2006 Czech tag into the CoNLL 2009 format.
#------------------------------------------------------------------------------
sub conll_2006_to_2009
{
    my $tag = shift;
    # CoNLL 2006 contains tab-delimited values of the columns CPOS, POS and FEATS.
    # CoNLL 2009 contains tab-delimited values of the columns POS and FEAT (or, possibly of PPOS and PFEAT).
    $tag =~ s/^(\S+)\t(\S+)\t(.*)$/$1\tSubPOS=$2|$3/;
    return $tag;
}



#------------------------------------------------------------------------------
# Converts a CoNLL 2009 Czech tag into the CoNLL 2006 format.
#------------------------------------------------------------------------------
sub conll_2009_to_2006
{
    my $tag = shift;
    # CoNLL 2006 contains tab-delimited values of the columns CPOS, POS and FEATS.
    # CoNLL 2009 contains tab-delimited values of the columns POS and FEAT (or, possibly of PPOS and PFEAT).
    $tag =~ s/^(\S+)\tSubPOS=([^\|]+)|(.*)$/$1\t$2\t$3/;
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
#------------------------------------------------------------------------------
sub list
{
    my $list = tagset::cs::conll::list();
    map {$_ = conll_2006_to_2009($_)} @{$list};
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
