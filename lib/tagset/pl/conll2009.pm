# Driver for the CoNLL/IPI PAN Polish tagset.
# (c) 2013 Jan Masek <honza.masek@gmail.com>
# License: GNU GPL

package tagset::pl::conll2009;
use utf8;
use tagset::pl::ipipan;


#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode {
    my $tag = shift;
    $tag =~ s/\t|\|/:/g;
    return tagset::pl::ipipan::decode($tag);
};

#------------------------------------------------------------------------------
# Takes feature hash.
# Returns tag string.
#------------------------------------------------------------------------------
sub encode {
    my $f0 = shift;
    my $nonstrict = shift;
    my $tag = tagset::pl::ipipan::encode($f0, $nonstrict);
    return "$tag\t$tag\t_";
}

#------------------------------------------------------------------------------
# Returns reference to list of known tags.
#------------------------------------------------------------------------------
sub list {
    my $list = tagset::pl::ipipan::list();
    my @list = map {"$_\t$_\t_"} @{$list};
    return \@list;
}

1;

