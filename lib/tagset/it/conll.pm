#!/usr/bin/perl
# Driver for the CoNLL 2007 Italian tagset.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>, Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::it::conll;
use utf8;
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
    my %f; # features
    $f{tagset} = "it::conll";
    # three components: coarse-grained pos, fine-grained pos, features
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    # pos: ? adj adv art conj ec in n num pp pron prop prp punc v vp
    # n = common noun # example: revivalismo
    if($pos eq "S")
    {
        $f{pos} = "noun";

        if ($subpos eq "SP") {
            $f{subpos} = "prop";
        }
        elsif($pos eq "SA")
        {
            $f{abbr} = "abbr";
        }
    }
    # adj = adjective # example: refrescante, algarvio
    elsif($pos eq "A")
    {
        $f{pos} = "adj";
    }
    # art = article # example: a, as, o, os, uma, um
    elsif($pos eq "R")
    {
        $f{pos} = "adj";
        $f{subpos} = "art";
    }
    # pron = pronoun # example: que, outro, ela, certo, o, algum, todo, nós
    elsif($pos eq "P")
    {
        $f{pos} = "noun";

        if ($subpos eq "PD") {
            $f{prontype} = "dem";
        }
        elsif ($subpos eq "PI") {
            $f{prontype} = "ind";
        }
        elsif ($subpos eq "PP") {
            $f{prontype} = "prs";
        }
        elsif ($subpos eq "PQ") {
            $f{prontype} = "prs";
        }
        elsif ($subpos eq "PR") {
            $f{prontype} = "rel";
        }
        elsif ($subpos eq "PT") {
            $f{prontype} = "int";
        }
    }
    # determiner
    elsif($pos eq "D")
    {
        $f{pos} = "adj";

        if ($subpos eq "DD") {
            $f{subpos} = "det";
        }
    }
    # num = number # example: 0,05, cento_e_quatro, cinco, setenta_e_dois, um, zero
    elsif($pos eq "N")
    {
        $f{pos} = "num";

        if ($subpos eq "N") {
            $f{numtype} = "card";
        }
        elsif ($subpos eq "NO") {
            $f{numtype} = "ord";
        }
    }
    # v = verb
    elsif($pos eq "V")
    {
        $f{pos} = "verb";
    }
    # adv = adverb # example: 20h45, abaixo, abertamente, a_bordo...
    elsif($pos eq "B")
    {
        $f{pos} = "adv";
    }
    # prp = preposition # example: a, abaixo_de, ao, com, de, em, por, que...
    elsif($pos eq "E")
    {
        $f{pos} = "prep";
    }
    # conj = conjunction # example: e, enquanto_que, mas, nem, ou, que...
    elsif($pos eq "C")
    {
        $f{pos} = "conj";
    }
    # in = interjection # example: adeus, ai, alô
    elsif($pos eq "I")
    {
        $f{pos} = "int";
    }
    # punc = punctuation # example: --, -, ,, ;, :, !, ?:?...
    elsif($pos eq "PU")
    {
        $f{pos} = "punc";
    }
    # ? = unknown # 2 occurrences in CoNLL 2006 data
    elsif($pos eq "X")
    {
        $f{pos} = "noun";
    }
    # Decode feature values.
    my @features = split(/\|/, $features);
    foreach my $feature (@features)
    {
        my @feat_val = split /\s*=\s*/, $feature;

        if ($feat_val[0] eq "gen") {
            if ($feat_val[1] eq "M") {
                $f{gender} = "masc";
            }
            elsif ($feat_val[1] eq "F") {
                $f{gender} = "fem";
            }
            elsif ($feat_val[1] eq "N") {
                $f{gender} = "neut";
            }
        }
        elsif ($feat_val[0] eq "num") {
            if ($feat_val[1] eq "S") {
                $f{number} = "sing";
            }
            elsif ($feat_val[1] eq "P") {
                $f{number} = "plu";
            }
            else {
                $f{number} = "coll";
            }
        }
        elsif ($feat_val[0] eq "per") {
            if ($feat_val[1] eq "1") {
                $f{person} = "1";
            }
            elsif ($feat_val[1] eq "2") {
                $f{person} = "2";
            }
            elsif ($feat_val[1] eq "3") {
                $f{person} = "3";
            }
        }
        elsif ($feat_val[0] eq "mod") {
            if ($feat_val[1] eq "G") {
                $f{verbform} = "part";
            }
            elsif ($feat_val[1] eq "F") {
                $f{verbform} = "inf";
            }
            elsif ($feat_val[1] eq "I") {
                $f{mood} = "ind";
            }
            elsif ($feat_val[1] eq "C") {
                $f{mood} = "sub";
            }
            elsif ($feat_val[1] eq "D") {
                $f{mood} = "cnd";
            }
            elsif ($feat_val[1] eq "M") {
                $f{mood} = "imp";
            }
            elsif ($feat_val[1] eq "P") {
                $f{verbform} = "part";
            }
        }
        elsif ($feat_val[0] eq "tmp") {
            if ($feat_val[1] eq "P") {
                $f{tense} = "pres";
            }
            elsif ($feat_val[1] eq "F") {
                $f{tense} = "fut";
            }
            elsif ($feat_val[1] eq "R") {
                $f{tense} = "past";
            }
        }
        elsif ($feat_val[0] eq "sup") {
            if ($feat_val[1] eq "S") {
                $f{degree} = "sup";
            }
        }
    }
    return \%f;
}



#------------------------------------------------------------------------------
# Takes feature hash.
# Returns tag string.
#------------------------------------------------------------------------------
sub encode
{
    my $f0 = shift;
    my $nonstrict = shift; # strict is default
    $strict = !$nonstrict;
    # Modify the feature structure so that it contains values expected by this
    # driver.
    my $f = tagset::common::enforce_permitted_joint($f0, $permitted);
    my %f = %{$f}; # This is not a deep copy but $f already refers to a deep copy of the original %{$f0}.
    my $tag;
    # pos and subpos
    # Add the features to the part of speech.
    my @features;
    my $features = join("|", @features);
    if($features eq "")
    {
        $features = "_";
    }
    $tag .= "\t$features";
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# cat train.conll test.conll |\
#   perl -pe '@x = split(/\s+/, $_); $_ = "$x[3]\t$x[4]\t$x[5]\n"' |\
#   sort -u | wc -l
# 880
# 671 after cleaning and adding 'other'-resistant tags
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
A	A	gen=F|num=P
A	A	gen=F|num=P|sup=S
A	A	gen=F|num=S
A	A	gen=F|num=S|sup=S
A	A	gen=M|num=N
A	A	gen=M|num=P
A	A	gen=M|num=P|sup=S
A	A	gen=M|num=S
A	A	gen=M|num=S|sup=S
A	A	gen=N|num=N
A	A	gen=N|num=P
A	A	gen=N|num=S
A	AP	gen=F|num=P
A	AP	gen=F|num=S
A	AP	gen=M|num=P
A	AP	gen=M|num=S
A	AP	gen=N|num=P
B	B	_
B	B	sup=S
C	C	_
D	DD	gen=F|num=P
D	DD	gen=F|num=S
D	DD	gen=M|num=P
D	DD	gen=M|num=S
D	DD	gen=N|num=S
D	DE	gen=N|num=N
D	DE	gen=N|num=P
D	DI	gen=F|num=P
D	DI	gen=F|num=S
D	DI	gen=M|num=P
D	DI	gen=M|num=S
D	DI	gen=N|num=N
D	DI	gen=N|num=P
D	DI	gen=N|num=S
D	DR	gen=N|num=S
D	DT	gen=F|num=P
D	DT	gen=F|num=S
D	DT	gen=M|num=S
D	DT	gen=N|num=N
D	DT	gen=N|num=P
D	DT	gen=N|num=S
E	E	_
E	E	gen=F|num=P
E	E	gen=F|num=S
E	E	gen=M|num=P
E	E	gen=M|num=S
E	E	gen=N|num=S
I	I	_
N	N	_
N	N	gen=F|num=P
N	N	gen=N|num=N
N	N	gen=N|num=S
N	NO	_
N	NO	gen=F|num=P
N	NO	gen=F|num=S
N	NO	gen=M|num=P
N	NO	gen=M|num=S
P	PD	gen=F|num=P
P	PD	gen=F|num=S
P	PD	gen=M|num=P
P	PD	gen=M|num=S
P	PD	gen=N|num=N
P	PD	gen=N|num=P
P	PI	gen=F|num=P
P	PI	gen=F|num=S
P	PI	gen=M|num=P
P	PI	gen=M|num=S
P	PI	gen=N|num=N
P	PI	gen=N|num=P
P	PI	gen=N|num=S
P	PP	gen=F|num=S
P	PP	gen=M|num=P
P	PP	gen=M|num=S
P	PQ	gen=F|num=N
P	PQ	gen=F|num=N|per=3
P	PQ	gen=F|num=P|per=3
P	PQ	gen=F|num=S
P	PQ	gen=F|num=S|per=3
P	PQ	gen=M|num=P
P	PQ	gen=M|num=P|per=3
P	PQ	gen=M|num=S
P	PQ	gen=M|num=S|per=3
P	PQ	gen=N|num=N
P	PQ	gen=N|num=N|per=3
P	PQ	gen=N|num=P|per=1
P	PQ	gen=N|num=P|per=2
P	PQ	gen=N|num=P|per=3
P	PQ	gen=N|num=S
P	PQ	gen=N|num=S|per=1
P	PQ	gen=N|num=S|per=2
P	PQ	gen=N|num=S|per=3
P	PR	gen=M|num=P
P	PR	gen=M|num=S
P	PR	gen=N|num=N
P	PR	gen=N|num=P
P	PR	gen=N|num=S
P	PT	gen=M|num=S
P	PT	gen=N|num=N
P	PT	gen=N|num=S
PU	PU	_
R	RD	gen=F|num=P
R	RD	gen=F|num=S
R	RD	gen=M|num=P
R	RD	gen=M|num=S
R	RD	gen=N|num=S
R	RI	gen=F|num=S
R	RI	gen=M|num=S
S	S	_
S	S	gen=F|num=N
S	S	gen=F|num=P
S	S	gen=F|num=S
S	S	gen=M|num=N
S	S	gen=M|num=P
S	S	gen=M|num=S
S	S	gen=N|num=N
S	S	gen=N|num=P
S	S	gen=N|num=S
S	SP	gen=N|num=N
S	SW	gen=N|num=N
SA	SA	gen=N|num=N
V	V	gen=F|num=P|mod=P|tmp=R
V	V	gen=F|num=S|mod=P|tmp=R
V	V	gen=M|num=P|mod=P|tmp=R
V	V	gen=M|num=S|mod=P|tmp=R
V	V	gen=N|num=P|mod=P|tmp=P
V	V	gen=N|num=S|mod=P|tmp=P
V	V	mod=F
V	V	mod=G
V	V	num=P|per=1|mod=C|tmp=I
V	V	num=P|per=1|mod=C|tmp=P
V	V	num=P|per=1|mod=D|tmp=P
V	V	num=P|per=1|mod=I|tmp=F
V	V	num=P|per=1|mod=I|tmp=I
V	V	num=P|per=1|mod=I|tmp=P
V	V	num=P|per=1|mod=I|tmp=R
V	V	num=P|per=2|mod=C|tmp=I
V	V	num=P|per=2|mod=C|tmp=P
V	V	num=P|per=2|mod=I|tmp=F
V	V	num=P|per=2|mod=I|tmp=P
V	V	num=P|per=2|mod=M|tmp=P
V	V	num=P|per=3|mod=C|tmp=I
V	V	num=P|per=3|mod=C|tmp=P
V	V	num=P|per=3|mod=D|tmp=P
V	V	num=P|per=3|mod=I|tmp=F
V	V	num=P|per=3|mod=I|tmp=I
V	V	num=P|per=3|mod=I|tmp=P
V	V	num=P|per=3|mod=I|tmp=R
V	V	num=S|per=1|mod=C|tmp=I
V	V	num=S|per=1|mod=C|tmp=P
V	V	num=S|per=1|mod=D|tmp=P
V	V	num=S|per=1|mod=I|tmp=F
V	V	num=S|per=1|mod=I|tmp=I
V	V	num=S|per=1|mod=I|tmp=P
V	V	num=S|per=1|mod=I|tmp=R
V	V	num=S|per=2|mod=C|tmp=P
V	V	num=S|per=2|mod=D|tmp=P
V	V	num=S|per=2|mod=I|tmp=F
V	V	num=S|per=2|mod=I|tmp=I
V	V	num=S|per=2|mod=I|tmp=P
V	V	num=S|per=2|mod=M|tmp=P
V	V	num=S|per=3|mod=C|tmp=I
V	V	num=S|per=3|mod=C|tmp=P
V	V	num=S|per=3|mod=D|tmp=P
V	V	num=S|per=3|mod=I|tmp=F
V	V	num=S|per=3|mod=I|tmp=I
V	V	num=S|per=3|mod=I|tmp=P
V	V	num=S|per=3|mod=I|tmp=R
X	X	_
end_of_list
    ;
    # Protect from editors that replace tabs by spaces.
    $list =~ s/ \s+/\t/sg;
    my @list = split(/\r?\n/, $list);
    pop(@list) if($list[$#list] eq "");
    return \@list;
}



#------------------------------------------------------------------------------
# Create trie of permitted feature structures. This will be needed for strict
# encoding. This BEGIN block cannot appear before the definition of the list()
# function.
#------------------------------------------------------------------------------
BEGIN
{
    # Store the hash reference in a global variable.
    #$permitted = tagset::common::get_permitted_structures_joint(list(), \&decode);
}



1;
