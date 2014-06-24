#!/usr/bin/perl
# Driver for the Swedish MAMBA tagset (Talbanken) in the CoNLL format.
# (c) 2006 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::sv::conll;
use utf8;
use tagset::sv::mamba;



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    $tag =~ s/\t.*//;
    return tagset::sv::mamba::decode($tag);
}



#------------------------------------------------------------------------------
# Takes feature hash.
# Returns tag string.
#------------------------------------------------------------------------------
sub encode
{
    my $f = shift;
    my $tag = tagset::sv::mamba::encode($f);
    return "$tag\t$tag\t_";
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
#
# cat otrain.conll etest.conll | perl -pe '@x = split(/\s+/, $_); $_ = "$x[3]\n"' | sort -u | wc -l
# 42
#------------------------------------------------------------------------------
sub list
{
    my $list = tagset::sv::mamba::list();
    my @list = map {"$_\t$_\t_"} @{$list};
    return \@list;
}



1;
