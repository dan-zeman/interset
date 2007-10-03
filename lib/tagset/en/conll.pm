#!/usr/bin/perl
# Driver for the CoNLL/Penn English tagset.
# (c) 2007 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::en::conll;
use utf8;
use tagset::en::penn;



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    # three components: coarse-grained pos, fine-grained pos, features
    # example: N\tNC\tgender=neuter|number=sing|case=unmarked|def=indef
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    # The CoNLL tagset is derived from the Penn tagset.
    # Coarse-grained POS is the first two characters of the Penn tag.
    # Fine-grained POS is the entire Penn tag.
    # Features is an underscore.
    return tagset::en::penn::decode($subpos);
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
    return substr($tag, 0, 2)."\t$tag\t_";
}



1;
