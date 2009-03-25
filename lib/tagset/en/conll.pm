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
    if($subpos eq "(")
    {
        $subpos = "-LRB-";
    }
    elsif($subpos eq ")")
    {
        $subpos = "-RRB-";
    }
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
    if($tag eq "-LRB-")
    {
        $tag = "(";
    }
    elsif($tag eq "-RRB-")
    {
        $tag = ")";
    }
    return substr($tag, 0, 2)."\t$tag\t_";
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
#
# cat otrain.conll etest.conll | perl -pe '@x = split(/\s+/, $_); $_ = "$x[3]\n"' | sort -u | wc -l
# 45
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
``      ``      _
,       ,       _
:       :       _
.       .       _
''      ''      _
(       (       _
)       )       _
\$       \$       _
\#       \#       _
AF      AFX     _
CC      CC      _
CD      CD      _
DT      DT      _
EX      EX      _
FW      FW      _
HY      HYPH    _
IN      IN      _
JJ      JJ      _
JJ      JJR     _
JJ      JJS     _
LS      LS      _
MD      MD      _
NI      NIL     _
NN      NN      _
NN      NNP     _
NN      NNPS    _
NN      NNS     _
PD      PDT     _
PO      POS     _
PR      PRP\$    _
PR      PRP     _
RB      RB      _
RB      RBR     _
RB      RBS     _
RP      RP      _
SY      SYM     _
TO      TO      _
UH      UH      _
VB      VB      _
VB      VBD     _
VB      VBG     _
VB      VBN     _
VB      VBP     _
VB      VBZ     _
WD      WDT     _
WP      WP\$     _
WP      WP      _
WR      WRB     _
end_of_list
    ;
    # Protect from editors that replace tabs by spaces.
    $list =~ s/ \s+/\t/sg;
    my @list = split(/\r?\n/, $list);
    pop(@list) if($list[$#list] eq "");
    return \@list;
}



1;
