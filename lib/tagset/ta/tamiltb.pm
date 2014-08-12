#!/usr/bin/perl
# Driver for the TamilTB.v0.1 Tamil tagset.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>, Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::ta::tamiltb;
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
    $f{tagset} = "ta::tamiltb";
    # three components: coarse-grained pos, fine-grained pos, features
    my ($pos, $subpos_big, $features) = split(/\s+/, $tag);

    if (length($subpos_big) != 9) {
        print "Tag length should be 9\n";
        print "Error tag: $subpos_big\n";
        die;
    }

    # cut only the second character from the positional tag
    # 2-nd position corresponds to sub pos
    my $subpos = substr $subpos_big, 1, 1;

    # nouns
    if($pos eq "N")
    {
        $f{pos} = "noun";

        if ($subpos eq "E") {
            $f{subpos} = "prop";
        }
        elsif ($subpos eq "P") {

        }

    }

    # adj = adjectives
    elsif($pos eq "J")
    {
        $f{pos} = "adj";
        if ($subpos eq "d") {
            $f{verbform} = "part";
        }
    }

    # pron = pronoun # example: que, outro, ela, certo, o, algum, todo, nós
    elsif($pos eq "R")
    {
        $f{pos} = "noun";
        if ($subpos eq "B") {
            $f{prontype} = "ind";
        }
        elsif ($subpos eq "h") {
            $f{reflex} = "reflex";
        }
        elsif ($subpos eq "i") {
            $f{prontype} = "int";
        }
        elsif ($subpos eq "p") {
            $f{prontype} = "prs";
        }
    }

    # determiner
    elsif($pos eq "D")
    {
        $f{pos} = "adj";

        if ($subpos eq "D") {
            $f{subpos} = "det";
        }
    }

    # num = number # example: 0,05, cento_e_quatro, cinco, setenta_e_dois, um, zero
    elsif($pos eq "U")
    {
        $f{pos} = "num";

        if ($subpos eq "x") {
            $f{numtype} = "card";
        }
        elsif ($subpos eq "y") {
            $f{numtype} = "ord";
        }
        elsif ($subpos eq '=') {
            $f{numform} = "digit";
        }
    }

    # v = verb
    elsif($pos eq "V")
    {
        $f{pos} = "verb";

        if ($subpos =~ /^(R|T|U|W|Z)/) {
            $f{subpoos} = "aux";
        }

    }

    # adv
    elsif($pos eq "A")
    {
        $f{pos} = "adv";
    }

    # prp
    elsif($pos eq "P")
    {
        $f{pos} = "prep";
    }

    # conj
    elsif($pos eq "C")
    {
        $f{pos} = "conj";
        if ($subpos eq "C") {
            $f{subpos} = "coor";
        }
    }

    # in
    elsif($pos eq "I")
    {
        $f{pos} = "int";
    }

    # quantifiers
    elsif ($pos eq "Q") {
        $f{pos} = "adj";
    }

    # punc
    elsif($pos eq "Z")
    {
        $f{pos} = "punc";

        if ($subpos eq "#") {
            $f{punctype} = "peri";
        }
    }

    # particles
    elsif ($pos eq "T") {
        $f{pos} = "part";
        if ($subpos =~ /^(k|q|o|v|s|S|m|l)$/) {
            $f{subpos} = "emp";
        }
        elsif ($subpos =~  /^(t|d|n|z)$/) {
            $f{subpos} = "sub"
        }
        elsif ($subpos eq "b") {
            $f{subpos} = "comp";
        }
    }

    # unknown X
    elsif($pos eq "X")
    {
        $f{pos} = "noun";
    }

    # Decode feature values.
    my @features = split(/\|/, $features);
    foreach my $feature (@features)
    {
        my @feat_val = split /\s*=\s*/, $feature;

        if ($feat_val[0] eq "Gen") {
            if ($feat_val[1] eq "M") {
                $f{gender} = "masc";
            }
            elsif ($feat_val[1] eq "F") {
                $f{gender} = "fem";
            }
            elsif ($feat_val[1] eq "N") {
                $f{gender} = "neut";
            }
            elsif ($feat_val[1] eq "A") {
                $f{gender} = "com";
                $f{animateness} = "anim";
            }
            elsif ($feat_val[1] eq "H") {
                $f{gender} = "com";
            }
        }
        elsif ($feat_val[0] eq "Num") {
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
        elsif ($feat_val[0] eq "Per") {
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
        elsif ($feat_val[0] eq "Ten") {
            if ($feat_val[1] eq "P") {
                $f{tense} = "pres";
            }
            elsif ($feat_val[1] eq "F") {
                $f{tense} = "fut";
            }
            elsif ($feat_val[1] eq "D") {
                $f{tense} = "past";
            }
        }
        elsif ($feat_val[0] eq "Voi") {
            if ($feat_val[1] eq "A") {
                $f{voice} = "act";
            }
            elsif ($feat_val[1] eq "P") {
                $f{voice} = "pass";
            }
        }
        elsif ($feat_val[0] eq "Neg") {
            if ($feat_val[1] eq "A") {
                $f{negativeness} = "pos";
            }
            elsif ($feat_val[1] eq "N") {
                $f{negativeness} = "neg";
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
A	AA-------	_
C	CC-------	_
D	DD-------	_
J	JJ-------	_
J	Jd-D----A	Ten=D|Neg=A
J	Jd-F----A	Ten=F|Neg=A
J	Jd-P----A	Ten=P|Neg=A
J	Jd-T----A	Ten=T|Neg=A
J	Jd-T----N	Ten=T|Neg=N
N	NEA-3PA--	Cas=A|Per=3|Num=P|Gen=A
N	NEA-3PN--	Cas=A|Per=3|Num=P|Gen=N
N	NEA-3SH--	Cas=A|Per=3|Num=S|Gen=H
N	NEA-3SN--	Cas=A|Per=3|Num=S|Gen=N
N	NED-3PA--	Cas=D|Per=3|Num=P|Gen=A
N	NED-3PN--	Cas=D|Per=3|Num=P|Gen=N
N	NED-3SH--	Cas=D|Per=3|Num=S|Gen=H
N	NED-3SN--	Cas=D|Per=3|Num=S|Gen=N
N	NEG-3SH--	Cas=G|Per=3|Num=S|Gen=H
N	NEG-3SN--	Cas=G|Per=3|Num=S|Gen=N
N	NEI-3PA--	Cas=I|Per=3|Num=P|Gen=A
N	NEL-3PA--	Cas=L|Per=3|Num=P|Gen=A
N	NEL-3PN--	Cas=L|Per=3|Num=P|Gen=N
N	NEL-3SN--	Cas=L|Per=3|Num=S|Gen=N
N	NEN-3PA--	Cas=N|Per=3|Num=P|Gen=A
N	NEN-3SH--	Cas=N|Per=3|Num=S|Gen=H
N	NEN-3SN--	Cas=N|Per=3|Num=S|Gen=N
N	NNA-3PA--	Cas=A|Per=3|Num=P|Gen=A
N	NNA-3PN--	Cas=A|Per=3|Num=P|Gen=N
N	NNA-3SH--	Cas=A|Per=3|Num=S|Gen=H
N	NNA-3SN--	Cas=A|Per=3|Num=S|Gen=N
N	NND-3PA--	Cas=D|Per=3|Num=P|Gen=A
N	NND-3PN--	Cas=D|Per=3|Num=P|Gen=N
N	NND-3SH--	Cas=D|Per=3|Num=S|Gen=H
N	NND-3SN--	Cas=D|Per=3|Num=S|Gen=N
N	NNG-3PA--	Cas=G|Per=3|Num=P|Gen=A
N	NNG-3PN--	Cas=G|Per=3|Num=P|Gen=N
N	NNG-3SH--	Cas=G|Per=3|Num=S|Gen=H
N	NNG-3SN--	Cas=G|Per=3|Num=S|Gen=N
N	NNI-3PA--	Cas=I|Per=3|Num=P|Gen=A
N	NNI-3PN--	Cas=I|Per=3|Num=P|Gen=N
N	NNI-3SN--	Cas=I|Per=3|Num=S|Gen=N
N	NNL-3PA--	Cas=L|Per=3|Num=P|Gen=A
N	NNL-3PN--	Cas=L|Per=3|Num=P|Gen=N
N	NNL-3SH--	Cas=L|Per=3|Num=S|Gen=H
N	NNL-3SN--	Cas=L|Per=3|Num=S|Gen=N
N	NNN-3PA--	Cas=N|Per=3|Num=P|Gen=A
N	NNN-3PN--	Cas=N|Per=3|Num=P|Gen=N
N	NNN-3SH--	Cas=N|Per=3|Num=S|Gen=H
N	NNN-3SM--	Cas=N|Per=3|Num=S|Gen=M
N	NNN-3SN--	Cas=N|Per=3|Num=S|Gen=N
N	NNS-3SA--	Cas=S|Per=3|Num=S|Gen=A
N	NNS-3SN--	Cas=S|Per=3|Num=S|Gen=N
N	NO--3SN--	Per=3|Num=S|Gen=N
N	NPDF3PH-A	Cas=D|Ten=F|Per=3|Num=P|Gen=H|Neg=A
N	NPLF3PH-A	Cas=L|Ten=F|Per=3|Num=P|Gen=H|Neg=A
N	NPND3PH-A	Cas=N|Ten=D|Per=3|Num=P|Gen=H|Neg=A
N	NPND3SH-A	Cas=N|Ten=D|Per=3|Num=S|Gen=H|Neg=A
N	NPNF3PA-A	Cas=N|Ten=F|Per=3|Num=P|Gen=A|Neg=A
N	NPNF3PH-A	Cas=N|Ten=F|Per=3|Num=P|Gen=H|Neg=A
N	NPNF3SH-A	Cas=N|Ten=F|Per=3|Num=S|Gen=H|Neg=A
N	NPNP3SH-A	Cas=N|Ten=P|Per=3|Num=S|Gen=H|Neg=A
N	NPNT3SM-A	Cas=N|Ten=T|Per=3|Num=S|Gen=M|Neg=A
P	PP-------	_
Q	QQ-------	_
R	RBA-3SA--	Cas=A|Per=3|Num=S|Gen=A
R	RBD-3SA--	Cas=D|Per=3|Num=S|Gen=A
R	RBN-3SA--	Cas=N|Per=3|Num=S|Gen=A
R	RBN-3SN--	Cas=N|Per=3|Num=S|Gen=N
R	RhA-1SA--	Cas=A|Per=1|Num=S|Gen=A
R	RhD-1SA--	Cas=D|Per=1|Num=S|Gen=A
R	RhD-3SA--	Cas=D|Per=3|Num=S|Gen=A
R	RhG-3PA--	Cas=G|Per=3|Num=P|Gen=A
R	RhG-3SA--	Cas=G|Per=3|Num=S|Gen=A
R	RiG-3SA--	Cas=G|Per=3|Num=S|Gen=A
R	RiN-3SA--	Cas=N|Per=3|Num=S|Gen=A
R	RiN-3SN--	Cas=N|Per=3|Num=S|Gen=N
R	RpA-1PA--	Cas=A|Per=1|Num=P|Gen=A
R	RpA-2SH--	Cas=A|Per=2|Num=S|Gen=H
R	RpA-3PA--	Cas=A|Per=3|Num=P|Gen=A
R	RpA-3PN--	Cas=A|Per=3|Num=P|Gen=N
R	RpA-3SN--	Cas=A|Per=3|Num=S|Gen=N
R	RpD-1SA--	Cas=D|Per=1|Num=S|Gen=A
R	RpD-2PA--	Cas=D|Per=2|Num=P|Gen=A
R	RpD-3PA--	Cas=D|Per=3|Num=P|Gen=A
R	RpD-3SH--	Cas=D|Per=3|Num=S|Gen=H
R	RpD-3SN--	Cas=D|Per=3|Num=S|Gen=N
R	RpG-1PA--	Cas=G|Per=1|Num=P|Gen=A
R	RpG-1SA--	Cas=G|Per=1|Num=S|Gen=A
R	RpG-2SH--	Cas=G|Per=2|Num=S|Gen=H
R	RpG-3PA--	Cas=G|Per=3|Num=P|Gen=A
R	RpG-3SH--	Cas=G|Per=3|Num=S|Gen=H
R	RpG-3SN--	Cas=G|Per=3|Num=S|Gen=N
R	RpI-1PA--	Cas=I|Per=1|Num=P|Gen=A
R	RpI-3PA--	Cas=I|Per=3|Num=P|Gen=A
R	RpL-3SN--	Cas=L|Per=3|Num=S|Gen=N
R	RpN-1PA--	Cas=N|Per=1|Num=P|Gen=A
R	RpN-1SA--	Cas=N|Per=1|Num=S|Gen=A
R	RpN-2PA--	Cas=N|Per=2|Num=P|Gen=A
R	RpN-2SH--	Cas=N|Per=2|Num=S|Gen=H
R	RpN-3PA--	Cas=N|Per=3|Num=P|Gen=A
R	RpN-3PN--	Cas=N|Per=3|Num=P|Gen=N
R	RpN-3SA--	Cas=N|Per=3|Num=S|Gen=A
R	RpN-3SH--	Cas=N|Per=3|Num=S|Gen=H
R	RpN-3SN--	Cas=N|Per=3|Num=S|Gen=N
T	TQ-------	_
T	TS-------	_
T	Tb-------	_
T	Td-D----A	Ten=D|Neg=A
T	Td-P----A	Ten=P|Neg=A
T	Te-------	_
T	Tg-------	_
T	Tk-------	_
T	Tl-------	_
T	Tm-------	_
T	Tn-------	_
T	To-------	_
T	Tq-------	_
T	Ts-------	_
T	Tt-T----A	Ten=T|Neg=A
T	Tv-------	_
T	Tw-T----A	Ten=T|Neg=A
T	TzAF3SN-A	Cas=A|Ten=F|Per=3|Num=S|Gen=N|Neg=A
T	TzIF3SN-A	Cas=I|Ten=F|Per=3|Num=S|Gen=N|Neg=A
T	TzNF3SN-A	Cas=N|Ten=F|Per=3|Num=S|Gen=N|Neg=A
U	U=-------	_
U	U=D-3SN-A	Cas=D|Per=3|Num=S|Gen=N|Neg=A
U	U=L-3SN-A	Cas=L|Per=3|Num=S|Gen=N|Neg=A
U	Ux-------	_
U	UxA-3SN-A	Cas=A|Per=3|Num=S|Gen=N|Neg=A
U	UxD-3SN-A	Cas=D|Per=3|Num=S|Gen=N|Neg=A
U	UxL-3SN--	Cas=L|Per=3|Num=S|Gen=N
U	UxL-3SN-A	Cas=L|Per=3|Num=S|Gen=N|Neg=A
U	UxN-3SH--	Cas=N|Per=3|Num=S|Gen=H
U	Uy-------	_
V	VR-D1SAAA	Ten=D|Per=1|Num=S|Gen=A|Voi=A|Neg=A
V	VR-D3PHAA	Ten=D|Per=3|Num=P|Gen=H|Voi=A|Neg=A
V	VR-D3PHPA	Ten=D|Per=3|Num=P|Gen=H|Voi=P|Neg=A
V	VR-D3PNAA	Ten=D|Per=3|Num=P|Gen=N|Voi=A|Neg=A
V	VR-D3PNPA	Ten=D|Per=3|Num=P|Gen=N|Voi=P|Neg=A
V	VR-D3SHAA	Ten=D|Per=3|Num=S|Gen=H|Voi=A|Neg=A
V	VR-D3SHPA	Ten=D|Per=3|Num=S|Gen=H|Voi=P|Neg=A
V	VR-D3SNAA	Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VR-D3SNPA	Ten=D|Per=3|Num=S|Gen=N|Voi=P|Neg=A
V	VR-F3PAAA	Ten=F|Per=3|Num=P|Gen=A|Voi=A|Neg=A
V	VR-F3PHPA	Ten=F|Per=3|Num=P|Gen=H|Voi=P|Neg=A
V	VR-F3SHAA	Ten=F|Per=3|Num=S|Gen=H|Voi=A|Neg=A
V	VR-F3SNAA	Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VR-F3SNPA	Ten=F|Per=3|Num=S|Gen=N|Voi=P|Neg=A
V	VR-P1PAAA	Ten=P|Per=1|Num=P|Gen=A|Voi=A|Neg=A
V	VR-P2PHAA	Ten=P|Per=2|Num=P|Gen=H|Voi=A|Neg=A
V	VR-P3PAAA	Ten=P|Per=3|Num=P|Gen=A|Voi=A|Neg=A
V	VR-P3PAPA	Ten=P|Per=3|Num=P|Gen=A|Voi=P|Neg=A
V	VR-P3PHAA	Ten=P|Per=3|Num=P|Gen=H|Voi=A|Neg=A
V	VR-P3PHPA	Ten=P|Per=3|Num=P|Gen=H|Voi=P|Neg=A
V	VR-P3PNAA	Ten=P|Per=3|Num=P|Gen=N|Voi=A|Neg=A
V	VR-P3PNPA	Ten=P|Per=3|Num=P|Gen=N|Voi=P|Neg=A
V	VR-P3SHAA	Ten=P|Per=3|Num=S|Gen=H|Voi=A|Neg=A
V	VR-P3SNAA	Ten=P|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VR-P3SNPA	Ten=P|Per=3|Num=S|Gen=N|Voi=P|Neg=A
V	VR-T1PAAA	Ten=T|Per=1|Num=P|Gen=A|Voi=A|Neg=A
V	VR-T1SAAA	Ten=T|Per=1|Num=S|Gen=A|Voi=A|Neg=A
V	VR-T3PAAA	Ten=T|Per=3|Num=P|Gen=A|Voi=A|Neg=A
V	VR-T3PHAA	Ten=T|Per=3|Num=P|Gen=H|Voi=A|Neg=A
V	VR-T3PNAA	Ten=T|Per=3|Num=P|Gen=N|Voi=A|Neg=A
V	VR-T3SHAA	Ten=T|Per=3|Num=S|Gen=H|Voi=A|Neg=A
V	VR-T3SN-N	Ten=T|Per=3|Num=S|Gen=N|Neg=N
V	VR-T3SNAA	Ten=T|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VT-T---AA	Ten=T|Voi=A|Neg=A
V	VT-T---PA	Ten=T|Voi=P|Neg=A
V	VU-T---AA	Ten=T|Voi=A|Neg=A
V	VU-T---PA	Ten=T|Voi=P|Neg=A
V	VW-T---AA	Ten=T|Voi=A|Neg=A
V	VW-T---PA	Ten=T|Voi=P|Neg=A
V	VZAF3SNAA	Cas=A|Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VZAT3SNAA	Cas=A|Ten=T|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VZDD3SNAA	Cas=D|Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VZDD3SNPA	Cas=D|Ten=D|Per=3|Num=S|Gen=N|Voi=P|Neg=A
V	VZIT3SNAA	Cas=I|Ten=T|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VZND3SNAA	Cas=N|Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VZND3SNPA	Cas=N|Ten=D|Per=3|Num=S|Gen=N|Voi=P|Neg=A
V	VZNF3SNAA	Cas=N|Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VZNT3SNAA	Cas=N|Ten=T|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	Vj-T2PAAA	Ten=T|Per=2|Num=P|Gen=A|Voi=A|Neg=A
V	Vr-D1P-AA	Ten=D|Per=1|Num=P|Voi=A|Neg=A
V	Vr-D1SAAA	Ten=D|Per=1|Num=S|Gen=A|Voi=A|Neg=A
V	Vr-D3PAAA	Ten=D|Per=3|Num=P|Gen=A|Voi=A|Neg=A
V	Vr-D3PHAA	Ten=D|Per=3|Num=P|Gen=H|Voi=A|Neg=A
V	Vr-D3PNAA	Ten=D|Per=3|Num=P|Gen=N|Voi=A|Neg=A
V	Vr-D3SHAA	Ten=D|Per=3|Num=S|Gen=H|Voi=A|Neg=A
V	Vr-D3SNAA	Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	Vr-F1P-AA	Ten=F|Per=1|Num=P|Voi=A|Neg=A
V	Vr-F3PHAA	Ten=F|Per=3|Num=P|Gen=H|Voi=A|Neg=A
V	Vr-F3PNAA	Ten=F|Per=3|Num=P|Gen=N|Voi=A|Neg=A
V	Vr-F3SHAA	Ten=F|Per=3|Num=S|Gen=H|Voi=A|Neg=A
V	Vr-F3SNAA	Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	Vr-P1P-AA	Ten=P|Per=1|Num=P|Voi=A|Neg=A
V	Vr-P1PAAA	Ten=P|Per=1|Num=P|Gen=A|Voi=A|Neg=A
V	Vr-P1SAAA	Ten=P|Per=1|Num=S|Gen=A|Voi=A|Neg=A
V	Vr-P2PAAA	Ten=P|Per=2|Num=P|Gen=A|Voi=A|Neg=A
V	Vr-P2PHAA	Ten=P|Per=2|Num=P|Gen=H|Voi=A|Neg=A
V	Vr-P3PHAA	Ten=P|Per=3|Num=P|Gen=H|Voi=A|Neg=A
V	Vr-P3PNAA	Ten=P|Per=3|Num=P|Gen=N|Voi=A|Neg=A
V	Vr-P3SHAA	Ten=P|Per=3|Num=S|Gen=H|Voi=A|Neg=A
V	Vr-P3SNAA	Ten=P|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	Vr-T1SAAA	Ten=T|Per=1|Num=S|Gen=A|Voi=A|Neg=A
V	Vr-T2SH-N	Ten=T|Per=2|Num=S|Gen=H|Neg=N
V	Vr-T3PNAA	Ten=T|Per=3|Num=P|Gen=N|Voi=A|Neg=A
V	Vr-T3SNAA	Ten=T|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	Vt-T----N	Ten=T|Neg=N
V	Vt-T---AA	Ten=T|Voi=A|Neg=A
V	Vu-T---AA	Ten=T|Voi=A|Neg=A
V	Vu-T---PA	Ten=T|Voi=P|Neg=A
V	Vw-T---AA	Ten=T|Voi=A|Neg=A
V	VzAD3SNAA	Cas=A|Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzAF3SNAA	Cas=A|Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzDD3SNAA	Cas=D|Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzDF3SNAA	Cas=D|Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzDF3SNPA	Cas=D|Ten=F|Per=3|Num=S|Gen=N|Voi=P|Neg=A
V	VzGD3SNAA	Cas=G|Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzID3SNAA	Cas=I|Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzIF3SNAA	Cas=I|Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzIT3SNAA	Cas=I|Ten=T|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzLD3SNAA	Cas=L|Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzLF3SNAA	Cas=L|Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzLT3SNAA	Cas=L|Ten=T|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzND3PNAA	Cas=N|Ten=D|Per=3|Num=P|Gen=N|Voi=A|Neg=A
V	VzND3SNAA	Cas=N|Ten=D|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzND3SNPA	Cas=N|Ten=D|Per=3|Num=S|Gen=N|Voi=P|Neg=A
V	VzNF3SNAA	Cas=N|Ten=F|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzNP3SNAA	Cas=N|Ten=P|Per=3|Num=S|Gen=N|Voi=A|Neg=A
V	VzNT3SN-N	Cas=N|Ten=T|Per=3|Num=S|Gen=N|Neg=N
V	VzNT3SNAA	Cas=N|Ten=T|Per=3|Num=S|Gen=N|Voi=A|Neg=A
Z	Z#-------	_
Z	Z:-------	_
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
