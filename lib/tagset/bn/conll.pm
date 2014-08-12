#!/usr/bin/perl
# Driver for the CoNLL 2006 Bengali tagset.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>, Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::bn::conll;
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
    $f{tagset} = "bn::conll";
    # three components: coarse-grained pos, fine-grained pos, features
    my ($pos, $subpos, $features) = split(/\s+/, $tag);

    # For telugu proper pos is stored in subpos.
    $pos = $subpos;

    # pos: ADJ ADV CD CNJ GR ITJ NAME N NT N P PreN PS PUNC PV UNIT VADJ VAUX VS V xxx

    # nouns
    if($pos =~ /^(NN|NNC|NNP|NNPC|NST|NSTC|PRP|PRPC|WQ|ECH|XC)$/)
    {
        $f{pos} = "noun";

        if ($pos =~ /^(NNP|NNPC)$/) {
            $f{subpos} = "prop";
        }

        if ($pos eq "PRP") {
            $f{prontype} = "prs";
        }
        elsif ($pos eq "WQ") {
            $f{prontype} = "int";
        }

    }
    # adjectives
    elsif($pos =~ /^(DEM|JJ|JJC|QF|QFC)$/)
    {
        $f{pos} = "adj";

        if ($pos eq "DEM") {
            $f{subpos} = "det";
        }
    }
    # numeral
    elsif($pos =~ /^(QC|QCC|QO)$/)
    {
        $f{pos} = "num";

        if ($pos eq "QC" || $pos eq "QCC") {
            $f{numtype} = "card";
        }

        if ($pos eq "QO") {
            $f{numtype} = "ord";
        }
    }
    # v = verb
    elsif(($pos =~ /^(VM|VMC|VAUX)$/))
    {
        $f{pos} = "verb";

        if ($pos eq "VAUX") {
            $f{subpos} = "mod";
        }
    }
    # adverb
    elsif($pos eq "RB" || $pos eq "RBC" || $pos eq "RDP" || $pos eq "INTF" || $pos eq "NEG")
    {
        $f{pos} = "adv";
    }
    # postposition
    elsif($pos eq "PSP")
    {
        $f{pos} = "prep";
    }
    # conjunction
    elsif($pos eq "CC" | $pos eq "UT")
    {
        $f{pos} = "conj";

        if ($pos eq "UT") {
            $f{subpos} = "sub";
        }
    }
    # interjection
    elsif($pos eq "INJ")
    {
        $f{pos} = "int";
    }
    # punctuation
    elsif($pos eq "SYM")
    {
        $f{pos} = "punc";
    }
    elsif ($pos eq "RP") {
        $f{pos} = "part";
    }
    # ? = unknown tag "xxx"
    elsif($pos eq "UNK")
    {
        $f{pos} = "noun";
    }
    # Decode feature values.
    my @features = split(/\|/, $features);
    foreach my $feature (@features)
    {
        my @ind = split /\-/, $feature;
        my $len = scalar(@ind);
        if ($len == 2) {
            if ($ind[0] eq "gend") {
                if ($ind[1] eq "m") {
                    $f{gender} = "masc";
                }
                elsif ($ind[1] eq "f") {
                    $f{gender} = "fem";
                }
                elsif ($ind[1] eq "n") {
                    $f{gender} = "neut";
                }
                else {
                    $f{gender} = "com";
                }
            }
            elsif ($ind[0] eq "num") {
                if ($ind[1] eq "sg") {
                    $f{number} = "sing";
                }
                elsif ($ind[1] eq "pl") {
                    $f{number} = "plu";
                }
                elsif ($ind[1] eq "dual") {
                    $f{number} = "dual";
                }
                else {
                    $f{number} = "dual";
                }
            }
            elsif ($ind[0] eq "pers") {
                if ($ind[1] eq "1") {
                    $f{person} = "1";
                }
                elsif ($ind[1] eq "2") {
                    $f{person} = "2";
                }
                elsif ($ind[1] eq "3") {
                    $f{person} = "3";
                }
                else {
                    $f{person} = "3";
                }
            }
            elsif ($ind[0] eq "voicetype") {
                if ($ind[1] eq "active") {
                    $f{voice} = "act";
                }
                elsif ($ind[1] eq "passive") {
                    $f{voice} = "pass";
                }
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
BLK	INJ	cat-adj|gend-|num-|pers-|case-|vib-|tam-
BLK	INJ	cat-avy|gend-|num-|pers-|case-|vib-|tam-
BLK	INJ	cat-unk|gend-|num-|pers-|case-|vib-|tam-
BLK	RP	cat-avy|gend-|num-|pers-|case-|vib-|tam-
BLK	SYM	cat-punc|gend-|num-|pers-|case-|vib-|tam-
BLK	SYM	cat-|gend-punc|num-|pers-|case-|vib-|tam-
CCP	CC	cat-avy|gend-|num-|pers-|case-|vib-|tam-
CCP	CC	cat-unk|gend-|num-|pers-|case-|vib-|tam-
CCP	PRP	cat-pn|gend-|num-sg|pers-|case-d|vib-0|tam-0
CCP	SYM	cat-punc|gend-|num-|pers-|case-|vib-|tam-
CCP	SYM	cat-|gend-punc|num-|pers-|case-|vib-|tam-
FRAGP	PSP	_
FRAGP	RP	_
JJP	JJ	cat-WQ|gend-|num-|pers-|case-|vib-|tam-
JJP	JJ	cat-adj|gend-|num-|pers-|case-|vib-|tam-
JJP	JJ	cat-adv|gend-|num-|pers-|case-|vib-|tam-
JJP	JJ	cat-n|gend-|num-sg|pers-|case-d|vib-me|tam-me
JJP	JJ	cat-unk|gend-|num-|pers-|case-|vib-|tam-
JJP	JJ	cat-v|gend-|num-|pers-1|case-|vib-ne|tam-ne
JJP	QF	cat-adj|gend-|num-|pers-|case-|vib-|tam-
JJP	RP	cat-avy|gend-|num-|pers-|case-|vib-|tam-
JJP	XC	cat-adj|gend-|num-|pers-|case-|vib-|tam-
NEGP	NEG	cat-avy|gend-|num-|pers-|case-|vib-|tam-
NP	DEM	cat-pn|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	DEM	cat-unk|gend-|num-|pers-|case-|vib-|tam-
NP	JJ	cat-adj|gend-|num-|pers-|case-|vib-|tam-
NP	JJ	cat-unk|gend-|num-|pers-|case-|vib-|tam-
NP	NEG	cat-avy|gend-|num-|pers-|case-|vib-|tam-
NP	NN	cat-adj|gend-|num-|pers-|case-|vib-0_Weke|tam-
NP	NN	cat-adj|gend-|num-|pers-|case-|vib-0_hisebe|tam-
NP	NN	cat-adj|gend-|num-|pers-|case-|vib-0_janya|tam-
NP	NN	cat-adj|gend-|num-|pers-|case-|vib-0_ke|tam-
NP	NN	cat-adj|gend-|num-|pers-|case-|vib-|tam-
NP	NN	cat-adv|gend-|num-|pers-|case-|vib-|tam-
NP	NN	cat-avy|gend-|num-|pers-|case-|vib-|tam-
NP	NN	cat-n|gend-|num-pl|pers-|case-d|vib-0|tam-0
NP	NN	cat-n|gend-|num-pl|pers-|case-d|vib-me|tam-me
NP	NN	cat-n|gend-|num-pl|pers-|case-o|vib-era|tam-era
NP	NN	cat-n|gend-|num-pl|pers-|case-o|vib-ke|tam-ke
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_CAdZA|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_Weke|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_Xare|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_anuyAyZI|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_hisAbe|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_hisebe|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_niyZe|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_paryanwa|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_paryyanwa|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_saha|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_samparke|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_wo|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_xiyZez|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_xiyZe|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_xiye|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-era|tam-era
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-ke|tam-ke
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-me|tam-me
NP	NN	cat-n|gend-|num-sg|pers-|case-o|vib-0_Pale|tam-era
NP	NN	cat-n|gend-|num-sg|pers-|case-o|vib-0_ceyZe|tam-era
NP	NN	cat-n|gend-|num-sg|pers-|case-o|vib-0_janya|tam-era
NP	NN	cat-n|gend-|num-sg|pers-|case-o|vib-0_mawa|tam-era
NP	NN	cat-n|gend-|num-sg|pers-|case-o|vib-0_mawo|tam-era
NP	NN	cat-n|gend-|num-sg|pers-|case-o|vib-0_pakRe|tam-era
NP	NN	cat-n|gend-|num-sg|pers-|case-o|vib-0_uxxeSya|tam-era
NP	NN	cat-n|gend-|num-sg|pers-|case-o|vib-0_xike|tam-era
NP	NN	cat-n|gend-|num-sg|pers-|case-o|vib-era|tam-era
NP	NN	cat-n|gend-|num-sg|pers-|case-o|vib-ke|tam-ke
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_Weke|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_hisAbe|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_janya|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_mawana|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_mawa|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_mawo|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_niyZe|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_niye|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_of|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_pakRe|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_paryanwa|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_safge|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_sambanXe|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_samparke|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_sbarUpa|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_xaruna|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_xbArA|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_xiyZe|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-|tam-
NP	NN	cat-v|gend-|num-|pers-1|case-|vib-ne|tam-ne
NP	NN	cat-v|gend-|num-|pers-3|case-|vib-ne|tam-ne
NP	NN	cat-v|gend-|num-|pers-4|case-|vib-ka|tam-ka
NP	NN	cat-v|gend-|num-|pers-5|case-|vib-ne|tam-ne
NP	NN	cat-v|gend-|num-|pers-6|case-|vib-ka|tam-ka
NP	NN	cat-v|gend-|num-|pers-any|case-|vib-Be|tam-Be
NP	NN	cat-v|gend-|num-|pers-any|case-|vib-iwe|tam-iwe
NP	NN	cat-v|gend-|num-|pers-any|case-|vib-we|tam-we
NP	NNP	cat-adj|gend-|num-|pers-|case-|vib-0_Weke|tam-
NP	NNP	cat-adj|gend-|num-|pers-|case-|vib-|tam-
NP	NNP	cat-num|gend-|num-|pers-|case-|vib-|tam-
NP	NNP	cat-n|gend-|num-pl|pers-|case-d|vib-0|tam-0
NP	NNP	cat-n|gend-|num-pl|pers-|case-d|vib-ke|tam-ke
NP	NNP	cat-n|gend-|num-pl|pers-|case-o|vib-ke|tam-ke
NP	NNP	cat-n|gend-|num-sg|pers-|case-d|vib-0_Weke|tam-0
NP	NNP	cat-n|gend-|num-sg|pers-|case-d|vib-0_aBimuKe|tam-0
NP	NNP	cat-n|gend-|num-sg|pers-|case-d|vib-0_paryanwa|tam-0
NP	NNP	cat-n|gend-|num-sg|pers-|case-d|vib-0_saMkrAnwa|tam-0
NP	NNP	cat-n|gend-|num-sg|pers-|case-d|vib-0_sambanXe|tam-0
NP	NNP	cat-n|gend-|num-sg|pers-|case-d|vib-0_samparke|tam-0
NP	NNP	cat-n|gend-|num-sg|pers-|case-d|vib-0_xiyZe|tam-0
NP	NNP	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	NNP	cat-n|gend-|num-sg|pers-|case-d|vib-ke|tam-ke
NP	NNP	cat-n|gend-|num-sg|pers-|case-d|vib-me|tam-me
NP	NNP	cat-n|gend-|num-sg|pers-|case-o|vib-0_mawana|tam-era
NP	NNP	cat-n|gend-|num-sg|pers-|case-o|vib-0_mawa|tam-era
NP	NNP	cat-n|gend-|num-sg|pers-|case-o|vib-0_mawo|tam-era
NP	NNP	cat-n|gend-|num-sg|pers-|case-o|vib-0_pakRe|tam-era
NP	NNP	cat-n|gend-|num-sg|pers-|case-o|vib-era|tam-era
NP	NNP	cat-pn|gend-|num-pl|pers-|case-o|vib-era|tam-era
NP	NNP	cat-pn|gend-|num-sg|pers-|case-o|vib-era|tam-era
NP	NNP	cat-unk|gend-|num-|pers-|case-|vib-0_-|tam-
NP	NNP	cat-unk|gend-|num-|pers-|case-|vib-0_Weke|tam-
NP	NNP	cat-unk|gend-|num-|pers-|case-|vib-0_anwargawa|tam-
NP	NNP	cat-unk|gend-|num-|pers-|case-|vib-0_ceyZe|tam-
NP	NNP	cat-unk|gend-|num-|pers-|case-|vib-0_hayZe|tam-
NP	NNP	cat-unk|gend-|num-|pers-|case-|vib-0_in|tam-
NP	NNP	cat-unk|gend-|num-|pers-|case-|vib-0_janya|tam-
NP	NNP	cat-unk|gend-|num-|pers-|case-|vib-0_mawa|tam-
NP	NNP	cat-unk|gend-|num-|pers-|case-|vib-0_mawo|tam-
NP	NNP	cat-unk|gend-|num-|pers-|case-|vib-0_prawi|tam-
NP	NNP	cat-unk|gend-|num-|pers-|case-|vib-0_saha|tam-
NP	NNP	cat-unk|gend-|num-|pers-|case-|vib-0_xiyZe|tam-
NP	NNP	cat-unk|gend-|num-|pers-|case-|vib-|tam-
NP	NNP	cat-v|gend-|num-|pers-6|case-|vib-ka|tam-ka
NP	NST	cat-adj|gend-|num-|pers-|case-|vib-0_Weke|tam-
NP	NST	cat-adj|gend-|num-|pers-|case-|vib-0_xiyZe|tam-
NP	NST	cat-adj|gend-|num-|pers-|case-|vib-0_xiye|tam-
NP	NST	cat-adj|gend-|num-|pers-|case-|vib-|tam-
NP	NST	cat-adv|gend-|num-|pers-|case-|vib-0_Weke|tam-
NP	NST	cat-adv|gend-|num-|pers-|case-|vib-|tam-
NP	NST	cat-n|gend-|num-sg|pers-|case-d|vib-0_Weke|tam-0
NP	NST	cat-n|gend-|num-sg|pers-|case-d|vib-0_xiyZe|tam-0
NP	NST	cat-n|gend-|num-sg|pers-|case-d|vib-0_xiye|tam-0
NP	NST	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	NST	cat-n|gend-|num-sg|pers-|case-d|vib-me|tam-me
NP	NST	cat-psp|gend-|num-|pers-|case-|vib-|tam-
NP	NST	cat-unk|gend-|num-|pers-|case-|vib-|tam-
NP	NST	cat-v|gend-|num-|pers-4|case-|vib-0_xiye|tam-ka
NP	PRP	cat-adj|gend-|num-|pers-|case-|vib-|tam-
NP	PRP	cat-adv|gend-|num-|pers-|case-|vib-|tam-
NP	PRP	cat-avy|gend-|num-|pers-|case-|vib-|tam-
NP	PRP	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	PRP	cat-pn|gend-|num-pl|pers-|case-d|vib-0_ceyZe|tam-0
NP	PRP	cat-pn|gend-|num-pl|pers-|case-d|vib-0|tam-0
NP	PRP	cat-pn|gend-|num-pl|pers-|case-d|vib-ke|tam-ke
NP	PRP	cat-pn|gend-|num-pl|pers-|case-d|vib-me|tam-me
NP	PRP	cat-pn|gend-|num-pl|pers-|case-o|vib-0_mawo|tam-era
NP	PRP	cat-pn|gend-|num-pl|pers-|case-o|vib-0_niyZe|tam-era
NP	PRP	cat-pn|gend-|num-pl|pers-|case-o|vib-0_prawi|tam-era
NP	PRP	cat-pn|gend-|num-pl|pers-|case-o|vib-0_sambanXe|tam-era
NP	PRP	cat-pn|gend-|num-pl|pers-|case-o|vib-0|tam-0
NP	PRP	cat-pn|gend-|num-pl|pers-|case-o|vib-era|tam-era
NP	PRP	cat-pn|gend-|num-sg|pers-|case-d|vib-0_CAdZA|tam-0
NP	PRP	cat-pn|gend-|num-sg|pers-|case-d|vib-0_CA|tam-0
NP	PRP	cat-pn|gend-|num-sg|pers-|case-d|vib-0_janya|tam-0
NP	PRP	cat-pn|gend-|num-sg|pers-|case-d|vib-0_niyZe|tam-0
NP	PRP	cat-pn|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	PRP	cat-pn|gend-|num-sg|pers-|case-d|vib-ke|tam-ke
NP	PRP	cat-pn|gend-|num-sg|pers-|case-d|vib-me|tam-me
NP	PRP	cat-pn|gend-|num-sg|pers-|case-o|vib-0_Pale|tam-era
NP	PRP	cat-pn|gend-|num-sg|pers-|case-o|vib-0_Weke|tam-era
NP	PRP	cat-pn|gend-|num-sg|pers-|case-o|vib-0_baxale|tam-era
NP	PRP	cat-pn|gend-|num-sg|pers-|case-o|vib-0_janya|tam-era
NP	PRP	cat-pn|gend-|num-sg|pers-|case-o|vib-0_mawa|tam-era
NP	PRP	cat-pn|gend-|num-sg|pers-|case-o|vib-0|tam-0
NP	PRP	cat-pn|gend-|num-sg|pers-|case-o|vib-era|tam-era
NP	PRP	cat-pn|gend-|num-sg|pers-|case-o|vib-me|tam-me
NP	PRP	cat-pn|gend-|num-|pers-|case-d|vib-0_Weke|tam-me
NP	PRP	cat-pn|gend-|num-|pers-|case-d|vib-0|tam-0
NP	PRP	cat-pn|gend-|num-|pers-|case-d|vib-me|tam-me
NP	PRP	cat-unk|gend-|num-|pers-|case-|vib-|tam-
NP	PRP	cat-v|gend-|num-|pers-5|case-|vib-i|tam-i
NP	PRP	cat-v|gend-|num-|pers-5|case-|vib-sao|tam-sao
NP	PRP	cat-v|gend-|num-|pers-any|case-|vib-Be|tam-Be
NP	QC	cat-adj|gend-|num-|pers-|case-|vib-|tam-
NP	QC	cat-num|gend-|num-|pers-|case-|vib-0_Weke|tam-
NP	QC	cat-num|gend-|num-|pers-|case-|vib-|tam-
NP	QC	cat-unk|gend-|num-|pers-|case-|vib-|tam-
NP	QF	cat-adj|gend-|num-|pers-|case-|vib-|tam-
NP	QF	cat-avy|gend-|num-|pers-|case-|vib-|tam-
NP	RB	cat-adv|gend-|num-|pers-|case-|vib-|tam-
NP	RDP	cat-adj|gend-|num-|pers-|case-|vib-|tam-
NP	RP	cat-adj|gend-|num-|pers-|case-|vib-|tam-
NP	RP	cat-avy|gend-|num-|pers-|case-|vib-0_janya|tam-
NP	RP	cat-avy|gend-|num-|pers-|case-|vib-|tam-
NP	RP	cat-unk|gend-|num-|pers-|case-|vib-|tam-
NP	SYM	cat-punc|gend-|num-|pers-|case-|vib-|tam-
NP	SYM	cat-|gend-punc|num-|pers-|case-|vib-|tam-
NP	VAUX	cat-v|gend-|num-|pers-5|case-|vib-ne|tam-ne
NP	VM	cat-unk|gend-|num-|pers-|case-|vib-0_janya|tam-
NP	VM	cat-v|gend-|num-|pers-7|case-|vib-A|tam-A
NP	WQ	cat-WQ|gend-|num-|pers-|case-|vib-0_Weke|tam-
NP	WQ	cat-WQ|gend-|num-|pers-|case-|vib-|tam-
NP	WQ	cat-adj|gend-|num-|pers-|case-|vib-|tam-
NP	WQ	cat-avy|gend-|num-|pers-|case-|vib-|tam-
NP	WQ	cat-pn|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	WQ	cat-pn|gend-|num-sg|pers-|case-o|vib-era|tam-era
NP	XC	cat-pn|gend-|num-sg|pers-|case-o|vib-era|tam-era
NULL__CCP	CC	_
NULL__CCP	NULL	_
NULL__CCP	SYM	_
NULL__NP	NULL	_
NULL__VGF	NULL	_
NULL__VGF	SYM	_
NULL__VGF	VM	_
RBP	INJ	cat-avy|gend-|num-|pers-|case-|vib-|tam-
RBP	JJ	cat-adj|gend-|num-|pers-|case-|vib-|tam-
RBP	NN	cat-unk|gend-|num-|pers-|case-|vib-|tam-
RBP	QF	cat-adj|gend-|num-|pers-|case-|vib-|tam-
RBP	RB	cat-WQ|gend-|num-|pers-|case-|vib-|tam-
RBP	RB	cat-adj|gend-|num-|pers-|case-|vib-|tam-
RBP	RB	cat-adv|gend-|num-|pers-|case-|vib-|tam-
RBP	RB	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
RBP	RB	cat-unk|gend-|num-|pers-|case-|vib-|tam-
RBP	RP	cat-avy|gend-|num-|pers-|case-|vib-|tam-
RBP	SYM	cat-punc|gend-|num-|pers-|case-|vib-|tam-
RBP	WQ	cat-pn|gend-|num-sg|pers-|case-d|vib-0|tam-0
VGF	NULL	cat-unk|gend-|num-|pers-|case-|vib-|tam-
VGF	PRP	cat-pn|gend-|num-|pers-|case-d|vib-me|tam-me
VGF	SYM	cat-punc|gend-|num-|pers-|case-|vib-|tam-
VGF	VAUX	cat-v|gend-|num-|pers-2|case-|vib-be|tam-be
VGF	VAUX	cat-v|gend-|num-|pers-5|case-|vib-ne|tam-ne
VGF	VM	cat-adj|gend-|num-|pers-|case-|vib-|tam-
VGF	VM	cat-adv|gend-|num-|pers-5|case-|vib-0_cal+Ce|tam-
VGF	VM	cat-n|gend-|num-sg|pers-5|case-d|vib-me_yA+la|tam-me
VGF	VM	cat-n|gend-|num-sg|pers-5|case-d|vib-me_yA+ne|tam-me
VGF	VM	cat-n|gend-|num-sg|pers-|case-d|vib-me|tam-me
VGF	VM	cat-unk|gend-|num-sg|pers-|case-|vib-0_Ala+me|tam-
VGF	VM	cat-unk|gend-|num-|pers-1|case-|vib-0_xe+be|tam-
VGF	VM	cat-unk|gend-|num-|pers-2|case-|vib-0_per+Ce|tam-
VGF	VM	cat-unk|gend-|num-|pers-2|case-|vib-0_xe+ne|tam-
VGF	VM	cat-unk|gend-|num-|pers-2|case-|vib-0_yA+la|tam-
VGF	VM	cat-unk|gend-|num-|pers-3|case-|vib-0_pAr+be|tam-
VGF	VM	cat-unk|gend-|num-|pers-3|case-|vib-0_yA+ka|tam-
VGF	VM	cat-unk|gend-|num-|pers-5|case-|vib-0_As+Ce|tam-
VGF	VM	cat-unk|gend-|num-|pers-5|case-|vib-0_As+la|tam-
VGF	VM	cat-unk|gend-|num-|pers-5|case-|vib-0_Cila+wai|tam-
VGF	VM	cat-unk|gend-|num-|pers-5|case-|vib-0_WAk+ne|tam-
VGF	VM	cat-unk|gend-|num-|pers-5|case-|vib-0_mar+ne|tam-
VGF	VM	cat-unk|gend-|num-|pers-5|case-|vib-0_ne|tam-
VGF	VM	cat-unk|gend-|num-|pers-5|case-|vib-0_padZ+ne|tam-
VGF	VM	cat-unk|gend-|num-|pers-5|case-|vib-0_rAKA+ka_ha+la|tam-
VGF	VM	cat-unk|gend-|num-|pers-5|case-|vib-0_uT+ne|tam-
VGF	VM	cat-unk|gend-|num-|pers-5|case-|vib-0_xe+la|tam-
VGF	VM	cat-unk|gend-|num-|pers-5|case-|vib-0_yA+Ce|tam-
VGF	VM	cat-unk|gend-|num-|pers-5|case-|vib-0_yA+la|tam-
VGF	VM	cat-unk|gend-|num-|pers-5|case-|vib-0_yA+ne|tam-
VGF	VM	cat-unk|gend-|num-|pers-5|case-|vib-0_yAc+Ce|tam-
VGF	VM	cat-unk|gend-|num-|pers-5|case-|vib-nAi_pAr+ne_0|tam-
VGF	VM	cat-unk|gend-|num-|pers-|case-|vib-0_WAkibyi|tam-
VGF	VM	cat-unk|gend-|num-|pers-|case-|vib-0_geCye|tam-
VGF	VM	cat-unk|gend-|num-|pers-|case-|vib-0_habeka|tam-
VGF	VM	cat-unk|gend-|num-|pers-|case-|vib-0_liyZez_AsyeCi|tam-
VGF	VM	cat-unk|gend-|num-|pers-|case-|vib-0_ney|tam-
VGF	VM	cat-unk|gend-|num-|pers-|case-|vib-0_oTe|tam-
VGF	VM	cat-unk|gend-|num-|pers-|case-|vib-0_xao|tam-
VGF	VM	cat-unk|gend-|num-|pers-|case-|vib-0_xiCi|tam-
VGF	VM	cat-unk|gend-|num-|pers-|case-|vib-nA_0|tam-
VGF	VM	cat-unk|gend-|num-|pers-|case-|vib-|tam-
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-A_cA+ne|tam-A
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-A_pAr+ne|tam-A
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-A_per+Ce|tam-A
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-Be_xe+A_cA+la|tam-Be
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-Be_xe+be|tam-Be
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-Be_yA+Ce|tam-Be
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-Be_yA+Cila|tam-Be
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-Be_yA+iwe_cA+ne|tam-Be
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-Ce|tam-Ce
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-Cila|tam-Cila
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-be|tam-be
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-eni|tam-eni
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-la|tam-la
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-nA_be|tam-be
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-nA_ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-nAi_ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-ne_ACa+ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-ne_As+Ce|tam-ne
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-ne_xe+Cila|tam-ne
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-ne_xe+be|tam-ne
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-ne_xe+la|tam-ne
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-ne_yA+be|tam-ne
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-ne_yAkanA|tam-ne
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-wa|tam-wa
VGF	VM	cat-v|gend-|num-|pers-1|case-|vib-yZa|tam-yZa
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-A_Pel+la|tam-A
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-A_pAr+be|tam-A
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-A_pAr+ne|tam-A
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-A_uT+la|tam-A
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-A_xe+be|tam-A
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-Be_ACa+ne|tam-Be
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-Be_As+ne|tam-Be
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-Be_ne+la|tam-Be
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-Be_uT+Ce|tam-Be
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-Be_uT+be|tam-Be
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-Be_xe+lei_pAr+wa|tam-Be
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-Be_yA+be|tam-Be
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-Ce|tam-Ce
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-Cila|tam-Cila
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-be|tam-be
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-iwe_pAr+ne|tam-iwe
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-iyZe_ne+la|tam-iyZe
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-iyZe_xe+la|tam-iyZe
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-la|tam-la
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-li|tam-li
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-nA_be|tam-be
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-nA_la|tam-la
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-nA_ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-ne_As+be|tam-ne
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-ne_As+ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-ne_Pel+la|tam-ne
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-ne_padZ+la|tam-ne
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-ne_xe+la|tam-ne
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-ne_xe+ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-wai|tam-wai
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-wa|tam-wa
VGF	VM	cat-v|gend-|num-|pers-2|case-|vib-yZa|tam-yZa
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-A_WAk+be|tam-A
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-A_ha+be|tam-A
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-A_pAr+be|tam-A
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-A_pAr+ini|tam-A
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-A_yA+be|tam-A
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-Be_yA+be|tam-Be
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-Ce|tam-Ce
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-Cila|tam-Cila
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-be|tam-be
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-eni|tam-eni
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-ini|tam-ini
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-ka_ha+be|tam-ka
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-ka_yA+be|tam-ka
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-ka|tam-ka
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-nA_Ce|tam-Ce
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-nA_be|tam-be
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-nA_ka|tam-ka
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-ne_ne+A_ha+be|tam-ne
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-ne_yA+ka|tam-ne
VGF	VM	cat-v|gend-|num-|pers-3|case-|vib-ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-4|case-|vib-A_pAr+ka|tam-A
VGF	VM	cat-v|gend-|num-|pers-4|case-|vib-ka_halya|tam-ka
VGF	VM	cat-v|gend-|num-|pers-4|case-|vib-ka_hayeCe|tam-ka
VGF	VM	cat-v|gend-|num-|pers-4|case-|vib-ka_hayeCila|tam-ka
VGF	VM	cat-v|gend-|num-|pers-4|case-|vib-ka_yAcCila|tam-ka
VGF	VM	cat-v|gend-|num-|pers-4|case-|vib-ka_yAy|tam-ka
VGF	VM	cat-v|gend-|num-|pers-4|case-|vib-ka|tam-ka
VGF	VM	cat-v|gend-|num-|pers-4|case-|vib-la|tam-la
VGF	VM	cat-v|gend-|num-|pers-4|case-|vib-nA_ka|tam-ka
VGF	VM	cat-v|gend-|num-|pers-4|case-|vib-nAi_ka|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-A_WAk+ne|tam-A
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-A_cA+ne|tam-A
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-A_ha+Ce|tam-A
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-A_ha+eni|tam-A
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-A_ha+la|tam-A
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-A_ha+ne|tam-A
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-A_ha+wa|tam-A
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-A_lAg+la|tam-A
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-A_pA+Ce|tam-A
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-A_pA+la|tam-A
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-A_pA+ne|tam-A
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-A_pAr+ne|tam-A
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-A_padZ+Cila|tam-A
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-A_per+Ce|tam-A
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-A_yA+Ce|tam-A
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-A_yA+Cila|tam-A
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_An+Ce|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_As+Ce|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_As+la|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_Pel+ne|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_WAk+A_pArA+ka_yA+eni|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_WAk+ne|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_cal+Ce|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_cal+la|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_cal+ne|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_ne+Ce|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_padZ+Ce|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_padZ+eni|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_padZ+ne|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_uT+la|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_xe+Ce|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_xe+ne|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_xeoyZA+ka_ha+ne|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_yA+Ce|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_yA+iwe_WAk+ne|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_yA+iwe_pAr+ne|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_yA+la|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_yA+ne|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Be_yAc+Ce|tam-Be
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Ce|tam-Ce
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-Cila|tam-Cila
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-eni|tam-eni
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-iwe_bas+Ce|tam-iwe
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-iyZe_ACa+ne|tam-iyZe
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-iyZe_ne+Be_yAc+Ce|tam-iyZe
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-iyZe_ne|tam-iyZe
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-iyZe_padZ+ne|tam-iyZe
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-iyZe_rAK+ne|tam-iyZe
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-iyZe_xe+Ce|tam-iyZe
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-iyZe_xe+ne|tam-iyZe
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-iyZe_xe+wa|tam-iyZe
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-iyZe_yA+ne|tam-iyZe
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ka_ha+A_WAk+ne|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ka_ha+Ce|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ka_ha+Cila|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ka_ha+la|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ka_ha+ne|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ka_padZ+ne|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ka_xe+A_pAr+ne|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ka_xe+ne|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ka_yA+Ce|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ka_yA+eni|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ka_yA+iwe_pAr+ne|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ka_yA+ka|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ka_yA+la|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ka_yA+ne|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ka_yAc+Ce|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ka_yewei_pAr+ne|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ka|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-la|tam-la
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-nA_Ce|tam-Ce
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-nA_Cila|tam-Cila
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-nA_ka|tam-ka
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-nA_la|tam-la
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-nA_ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-nA_wai|tam-wai
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-nA_wa|tam-wa
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_As+la|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_Cila+wai|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_Pel+Ce|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_Pel+ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_WAk+eni|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_WAk+ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_bas+Ce|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_bas+wa|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_cal+Ce|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_cal+ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_ne+A_ha+ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_oTe|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_padZ+ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_pa|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_rAK+Cila|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_uT+Ce|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_wul+Cila|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_xe+A_ha+ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_xe+Ce|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_xeoyZA+ka_ha+ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_yA+Ce|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_yA+iwe_pAr+ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_yA+la|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_yA+ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_yAc+Ce|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-ni_ne|tam-ne
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-wai|tam-wai
VGF	VM	cat-v|gend-|num-|pers-5|case-|vib-wa|tam-wa
VGF	VM	cat-v|gend-|num-|pers-6|case-|vib-Be_As+ka|tam-Be
VGF	VM	cat-v|gend-|num-|pers-6|case-|vib-Be_yA+ka|tam-Be
VGF	VM	cat-v|gend-|num-|pers-6|case-|vib-eni|tam-eni
VGF	VM	cat-v|gend-|num-|pers-6|case-|vib-iyZe_yA+ka|tam-iyZe
VGF	VM	cat-v|gend-|num-|pers-6|case-|vib-ka_yA+ka|tam-ka
VGF	VM	cat-v|gend-|num-|pers-6|case-|vib-ka|tam-ka
VGF	VM	cat-v|gend-|num-|pers-6|case-|vib-nA_be|tam-be
VGF	VM	cat-v|gend-|num-|pers-6|case-|vib-ne_Pel+ka|tam-ne
VGF	VM	cat-v|gend-|num-|pers-6|case-|vib-ne_xe+ka|tam-ne
VGF	VM	cat-v|gend-|num-|pers-6|case-|vib-ne_yA+ka|tam-ne
VGF	VM	cat-v|gend-|num-|pers-6|case-|vib-oni|tam-oni
VGF	VM	cat-v|gend-|num-|pers-7|case-|vib-A_ACa+A|tam-A
VGF	VM	cat-v|gend-|num-|pers-7|case-|vib-A_As+A|tam-A
VGF	VM	cat-v|gend-|num-|pers-7|case-|vib-A_cAy|tam-A
VGF	VM	cat-v|gend-|num-|pers-7|case-|vib-A_oTe|tam-A
VGF	VM	cat-v|gend-|num-|pers-7|case-|vib-A|tam-A
VGF	VM	cat-v|gend-|num-|pers-7|case-|vib-Be_ACa+A|tam-Be
VGF	VM	cat-v|gend-|num-|pers-7|case-|vib-Be_uT+A|tam-Be
VGF	VM	cat-v|gend-|num-|pers-7|case-|vib-ka_ACa+A|tam-ka
VGF	VM	cat-v|gend-|num-|pers-7|case-|vib-le|tam-le
VGF	VM	cat-v|gend-|num-|pers-7|case-|vib-nA_Ao|tam-Ao
VGF	VM	cat-v|gend-|num-|pers-7|case-|vib-nA_A|tam-A
VGF	VM	cat-v|gend-|num-|pers-7|case-|vib-ne_Pel+le|tam-ne
VGF	VM	cat-v|gend-|num-|pers-7|case-|vib-ne_bas+ne_ACa+A|tam-ne
VGF	VM	cat-v|gend-|num-|pers-7|case-|vib-ni_A|tam-A
VGF	VM	cat-v|gend-|num-|pers-7|case-|vib-ni|tam-ni
VGF	VM	cat-v|gend-|num-|pers-any|case-|vib-Be_ne+A_hay|tam-Be
VGF	VM	cat-v|gend-|num-|pers-any|case-|vib-Be_oTe|tam-Be
VGF	VM	cat-v|gend-|num-|pers-any|case-|vib-Be_pATAyZa|tam-Be
VGF	VM	cat-v|gend-|num-|pers-any|case-|vib-Be_xAzdZAyZa|tam-Be
VGF	VM	cat-v|gend-|num-|pers-any|case-|vib-Be|tam-Be
VGF	VM	cat-v|gend-|num-|pers-any|case-|vib-iyZe_gel+Be|tam-iyZe
VGF	VM	cat-v|gend-|num-|pers-any|case-|vib-iyZe|tam-iyZe
VGF	VM	cat-v|gend-|num-|pers-any|case-|vib-nA_Be|tam-Be
VGF	VM	cat-v|gend-|num-|pers-any|case-|vib-nA_we|tam-we
VGF	VM	cat-v|gend-|num-|pers-any|case-|vib-we|tam-we
VGINF	VM	cat-n|gend-|num-sg|pers-|case-d|vib-me|tam-me
VGINF	VM	cat-unk|gend-|num-|pers-7|case-|vib-0_xe+A|tam-
VGINF	VM	cat-unk|gend-|num-|pers-|case-|vib-|tam-
VGINF	VM	cat-v|gend-|num-|pers-7|case-|vib-A|tam-A
VGINF	VM	cat-v|gend-|num-|pers-any|case-|vib-iwe|tam-iwe
VGNF	VM	cat-adj|gend-|num-|pers-|case-|vib-|tam-
VGNF	VM	cat-n|gend-|num-sg|pers-7|case-d|vib-me_xe+le|tam-me
VGNF	VM	cat-n|gend-|num-sg|pers-|case-d|vib-ke|tam-ke
VGNF	VM	cat-n|gend-|num-|pers-any|case-|vib-|tam-
VGNF	VM	cat-psp|gend-|num-|pers-|case-|vib-|tam-
VGNF	VM	cat-unk|gend-|num-|pers-7|case-|vib-0_As+A|tam-
VGNF	VM	cat-unk|gend-|num-|pers-7|case-|vib-0_pAr+leo|tam-
VGNF	VM	cat-unk|gend-|num-|pers-any|case-|vib-0_gel+Be|tam-
VGNF	VM	cat-unk|gend-|num-|pers-|case-|vib-0_geleo|tam-
VGNF	VM	cat-unk|gend-|num-|pers-|case-|vib-0_giye|tam-
VGNF	VM	cat-unk|gend-|num-|pers-|case-|vib-nA_0|tam-
VGNF	VM	cat-unk|gend-|num-|pers-|case-|vib-|tam-
VGNF	VM	cat-v|gend-|num-|pers-1|case-|vib-ne|tam-ne
VGNF	VM	cat-v|gend-|num-|pers-4|case-|vib-ka|tam-ka
VGNF	VM	cat-v|gend-|num-|pers-5|case-|vib-A_per+ne|tam-A
VGNF	VM	cat-v|gend-|num-|pers-5|case-|vib-i|tam-i
VGNF	VM	cat-v|gend-|num-|pers-5|case-|vib-nA_ne|tam-ne
VGNF	VM	cat-v|gend-|num-|pers-5|case-|vib-ne|tam-ne
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-A_giye|tam-A
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-A_pAr+le|tam-A
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-A_yA+Ao|tam-A
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-A_yA+A|tam-A
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-Ao|tam-Ao
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-A|tam-A
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-Be_yA+A|tam-Be
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-iyZe_WAk+A|tam-iyZe
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-iyZe_padZ+le|tam-iyZe
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-i|tam-i
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-ka_ha+leo|tam-ka
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-lei|tam-lei
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-leo|tam-leo
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-le|tam-le
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-nA_lei|tam-lei
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-nA_leo|tam-leo
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-nA_le|tam-le
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-ne_As+A|tam-ne
VGNF	VM	cat-v|gend-|num-|pers-7|case-|vib-ne_yA+A|tam-ne
VGNF	VM	cat-v|gend-|num-|pers-any|case-|vib-Be_yewei|tam-Be
VGNF	VM	cat-v|gend-|num-|pers-any|case-|vib-Be|tam-Be
VGNF	VM	cat-v|gend-|num-|pers-any|case-|vib-iwe|tam-iwe
VGNF	VM	cat-v|gend-|num-|pers-any|case-|vib-iyZe_WAk+Be|tam-iyZe
VGNF	VM	cat-v|gend-|num-|pers-any|case-|vib-iyZe|tam-iyZe
VGNF	VM	cat-v|gend-|num-|pers-any|case-|vib-ka_gel+Be|tam-ka
VGNF	VM	cat-v|gend-|num-|pers-any|case-|vib-ka_kar+A_gel+Be|tam-ka
VGNF	VM	cat-v|gend-|num-|pers-any|case-|vib-ka_xe+Be|tam-ka
VGNF	VM	cat-v|gend-|num-|pers-any|case-|vib-nA_Be|tam-Be
VGNF	VM	cat-v|gend-|num-|pers-any|case-|vib-nA_iyZe|tam-iyZe
VGNF	VM	cat-v|gend-|num-|pers-any|case-|vib-ne_ne+Be|tam-ne
VGNF	VM	cat-v|gend-|num-|pers-any|case-|vib-ne_xe+Be|tam-ne
VGNN	VM	cat-adj|gend-|num-|pers-|case-|vib-|tam-
VGNN	VM	cat-n|gend-|num-sg|pers-|case-o|vib-era|tam-era
VGNN	VM	cat-n|gend-|num-|pers-any|case-|vib-0_janya|tam-
VGNN	VM	cat-n|gend-|num-|pers-any|case-|vib-0_mawa|tam-
VGNN	VM	cat-n|gend-|num-|pers-any|case-|vib-nA_0|tam-
VGNN	VM	cat-n|gend-|num-|pers-any|case-|vib-|tam-
VGNN	VM	cat-unk|gend-|num-|pers-any|case-|vib-0_Pel|tam-
VGNN	VM	cat-unk|gend-|num-|pers-any|case-|vib-0_xe|tam-
VGNN	VM	cat-unk|gend-|num-|pers-|case-|vib-0_janya|tam-
VGNN	VM	cat-unk|gend-|num-|pers-|case-|vib-|tam-
VGNN	VM	cat-v|gend-|num-sg|pers-any|case-|vib-Be_AsA+era|tam-Be
VGNN	VM	cat-v|gend-|num-|pers-1|case-|vib-nA_ne|tam-ne
VGNN	VM	cat-v|gend-|num-|pers-1|case-|vib-ne|tam-ne
VGNN	VM	cat-v|gend-|num-|pers-3|case-|vib-ka|tam-ka
VGNN	VM	cat-v|gend-|num-|pers-4|case-|vib-A_WAkA+ka|tam-A
VGNN	VM	cat-v|gend-|num-|pers-4|case-|vib-Be_WAkA+ka|tam-Be
VGNN	VM	cat-v|gend-|num-|pers-4|case-|vib-iyZe_AnA+ka|tam-iyZe
VGNN	VM	cat-v|gend-|num-|pers-4|case-|vib-ka|tam-ka
VGNN	VM	cat-v|gend-|num-|pers-4|case-|vib-nA_paryyanwa_ka|tam-ka
VGNN	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_cal_janya|tam-ne
VGNN	VM	cat-v|gend-|num-|pers-5|case-|vib-ne_oTA|tam-ne
VGNN	VM	cat-v|gend-|num-|pers-5|case-|vib-ne|tam-ne
VGNN	VM	cat-v|gend-|num-|pers-7|case-|vib-A_CAdZA|tam-A
VGNN	VM	cat-v|gend-|num-|pers-7|case-|vib-A|tam-A
VGNN	VM	cat-v|gend-|num-|pers-7|case-|vib-Be_yA+A|tam-Be
VGNN	VM	cat-v|gend-|num-|pers-7|case-|vib-ne_yA+A|tam-ne
VGNN	VM	cat-v|gend-|num-|pers-any|case-|vib-A_xe|tam-A
VGNN	VM	cat-v|gend-|num-|pers-any|case-|vib-Be_WAk|tam-Be
VGNN	VM	cat-v|gend-|num-|pers-any|case-|vib-Be_oTAyZa|tam-Be
VGNN	VM	cat-v|gend-|num-|pers-any|case-|vib-Be_xe|tam-Be
VGNN	VM	cat-v|gend-|num-|pers-any|case-|vib-Be_yA+we|tam-Be
VGNN	VM	cat-v|gend-|num-|pers-any|case-|vib-iyZe_xe|tam-iyZe
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
