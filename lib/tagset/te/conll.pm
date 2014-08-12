#!/usr/bin/perl
# Driver for the CoNLL 2006 Telugu tagset.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>, Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::te::conll;
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
    $f{tagset} = "te::conll";
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
BLK	INJ	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
BLK	INJ	cat-avy|gend-|num-|pers-|case-|vib-A|tam-A_avy
BLK	RP	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
BLK	RP	cat-avy|gend-|num-|pers-|case-|vib-|tam-
BLK	RP	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
BLK	SYM	cat-punc|gend-|num-|pers-|case-|vib-|tam-
BLK	SYM	cat-|gend-punc|num-|pers-|case-|vib-|tam-
BLK	UT	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
BLK	UT	cat-avy|gend-|num-|pers-|case-|vib-|tam-
BLK	UT	cat-unk|gend-|num-|pers-|case-|vib-|tam-
CCP	CC	cat-adv|gend-|num-|pers-|case-|vib-wo|tam-wo_adv
CCP	CC	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
CCP	CC	cat-avy|gend-|num-|pers-|case-|vib-|tam-
CCP	CC	cat-unk|gend-|num-|pers-|case-|vib-|tam-
CCP	NST	cat-adv|gend-|num-|pers-|case-|vib-0|tam-0_adv
CCP	PRP	cat-avy|gend-|num-|pers-|case-|vib-|tam-
CCP	PRP	cat-n|gend-|num-sg|pers-|case-|vib-wo|tam-wo
CCP	PRP	cat-pn|gend-fn|num-sg|pers-3|case-|vib-ki|tam-ki
CCP	PSP	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
CCP	RP	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
CCP	RP	cat-avy|gend-|num-|pers-|case-|vib-|tam-
CCP	RP	cat-v|gend-any|num-any|pers-any|case-|vib-we|tam-we
CCP	SYM	cat-|gend-punc|num-|pers-|case-|vib-|tam-
CCP	UT	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
CCP	UT	cat-avy|gend-|num-|pers-|case-|vib-|tam-
CCP	WQ	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
FRAGP	PSP	_
JJP	INTF	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
JJP	JJ	cat-adj|gend-|num-sg|pers-|case-o|vib-0|tam-0_adj
JJP	JJ	cat-adj|gend-|num-sg|pers-|case-|vib-xi|tam-xi_adj
JJP	JJ	cat-adj|gend-|num-|pers-|case-|vib-0|tam-0_adj
JJP	JJ	cat-adj|gend-|num-|pers-|case-|vib-gA|tam-gA_adj
JJP	JJ	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
JJP	JJ	cat-avy|gend-|num-|pers-|case-|vib-e|tam-e_avy
JJP	JJ	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
JJP	JJ	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0|poslcat-NM
JJP	JJ	cat-n|gend-|num-sg|pers-|case-|vib-0|tam-0_e
JJP	JJ	cat-n|gend-|num-sg|pers-|case-|vib-Ena|tam-Ena
JJP	JJ	cat-n|gend-|num-sg|pers-|case-|vib-gA|tam-gA
JJP	JJ	cat-n|gend-|num-sg|pers-|case-|vib-lAti|tam-lAti
JJP	JJ	cat-n|gend-|num-sg|pers-|case-|vib-vi|tam-vi
JJP	JJ	cat-pn|gend-|num-sg|pers-|case-|vib-xi_0|tam-xi_0_o
JJP	JJ	cat-unk|gend-|num-|pers-|case-|vib-|tam-
JJP	JJ	cat-v|gend-|num-sg|pers-2|case-|vib-AjFArWa|tam-AjFArWa
JJP	QC	cat-adj|gend-|num-|pers-|case-|vib-0|tam-0_adj
JJP	QC	cat-num|gend-|num-|pers-|case-|vib-|tam-
NEGP	NEG	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
NP	CL	cat-n|gend-|num-pl|pers-|case-d|vib-0|tam-0
NP	CL	cat-n|gend-|num-pl|pers-|case-|vib-ni|tam-ni
NP	CL	cat-n|gend-|num-pl|pers-|case-|vib-nu|tam-nu
NP	DEM	cat-pn|gend-fn|num-sg|pers-3|case-|vib-0|tam-0_o
NP	INTF	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
NP	JJ	cat-adj|gend-|num-sg|pers-|case-o|vib-0|tam-0_adj
NP	JJ	cat-adj|gend-|num-|pers-|case-|vib-0|tam-0_adj
NP	JJ	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	JJ	cat-pn|gend-|num-pl|pers-|case-|vib-lAMti_xi|tam-lAMti_xi_0
NP	NN	cat-adj|gend-|num-|pers-|case-|vib-0|tam-0_adj
NP	NN	cat-adj|gend-|num-|pers-|case-|vib-0|tam-0_adj|poslcat-NM
NP	NN	cat-adj|gend-|num-|pers-|case-|vib-xi|tam-xi_adj
NP	NN	cat-adv|gend-|num-|pers-|case-|vib-aMwa_0_A|tam-aMwa_0_A_adv
NP	NN	cat-adv|gend-|num-|pers-|case-|vib-kiMxa_yoVkka|tam-kiMxa_yoVkka_adv
NP	NN	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
NP	NN	cat-avy|gend-|num-|pers-|case-|vib-|tam-
NP	NN	cat-n|gend-|num-pl|pers-|case-d|vib-0_kUdA|tam-0
NP	NN	cat-n|gend-|num-pl|pers-|case-d|vib-0_mAwraM|tam-0
NP	NN	cat-n|gend-|num-pl|pers-|case-d|vib-0_sEwaM|tam-0
NP	NN	cat-n|gend-|num-pl|pers-|case-d|vib-0|tam-0
NP	NN	cat-n|gend-|num-pl|pers-|case-d|vib-ru|tam-ru
NP	NN	cat-n|gend-|num-pl|pers-|case-o|vib-0_kosaM|tam-ti
NP	NN	cat-n|gend-|num-pl|pers-|case-o|vib-0_mIxa|tam-ti
NP	NN	cat-n|gend-|num-pl|pers-|case-o|vib-0_nuMdi_kUdA|tam-ti
NP	NN	cat-n|gend-|num-pl|pers-|case-o|vib-0_nuMdi|tam-ti
NP	NN	cat-n|gend-|num-pl|pers-|case-o|vib-0_varaku|tam-ti
NP	NN	cat-n|gend-|num-pl|pers-|case-o|vib-ti|tam-ti
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-0_batti|tam-ni
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-0_kUdA|tam-ki
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-0_nuMci|tam-0_o
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-0|tam-0_A
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-0|tam-0_e
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-0|tam-0_o
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-I|tam-I
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-kUdA|tam-kUdA
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-ki|tam-ki
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-ki|tam-ki_V
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-lA|tam-lA
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-lo|tam-lo
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-lo|tam-lo_V
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-lo|tam-lo_e
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-mIxa|tam-mIxa
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-ni|tam-ni
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-wopAtu|tam-wopAtu
NP	NN	cat-n|gend-|num-pl|pers-|case-|vib-wo|tam-wo
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_aMxulo|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_guriMci|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_kUdA|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_koVraku|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_kosaM|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_lopala|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_lo|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_mAwraM|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_nuMci|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_nuMdi|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_varaku|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_warvAwa|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_xAkA|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0_xvArA|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	NN	cat-n|gend-|num-sg|pers-|case-o|vib-0_xAkA|tam-ti
NP	NN	cat-n|gend-|num-sg|pers-|case-o|vib-ti|tam-ti
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-0_batti|tam-nu
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-0_guriMci|tam-nu
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-0_kUdA|tam-gAru
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-0_kUdA|tam-ki
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-0_kUdA|tam-ni
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-0_kUdA|tam-niMci
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-0_le|tam-0_le
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-0_nuMci|tam-lo
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-0_pAtu|tam-wo
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-0|tam-0_A
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-0|tam-0_V
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-0|tam-0_e
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-0|tam-0_e|pbank-ARG3
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-0|tam-0_o
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-aMte|tam-aMte
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-cotlo|tam-cotlo
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-gAdu|tam-gAdu
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-gAru|tam-gAru
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-kAda|tam-kAda
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-kUdA|tam-kUdA
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-ki|tam-ki
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-ki|tam-ki_V
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-ki|tam-ki_e
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-kosaM|tam-kosaM
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-loni|tam-loni
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-lopalaki|tam-lopalaki
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-lo|tam-lo
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-lo|tam-lo_V
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-lo|tam-lo_e
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-mIxa|tam-mIxa
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-na|tam-na
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-niMci|tam-niMci
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-ni|tam-ni
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-ni|tam-ni_A
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-nu|tam-nu
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-vAdu|tam-vAdu
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-vi|tam-vi
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-wo|tam-wo
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-wo|tam-wo_e
NP	NN	cat-n|gend-|num-sg|pers-|case-|vib-xi|tam-xi
NP	NN	cat-n|gend-|num-|pers-|case-|vib-ru|tam-ru
NP	NN	cat-pn|gend-fm|num-pl|pers-3|case-|vib-xi|tam-xi
NP	NN	cat-pn|gend-fn|num-sg|pers-3|case-|vib-ki|tam-ki
NP	NN	cat-pn|gend-fn|num-sg|pers-3|case-|vib-xi|tam-xi
NP	NN	cat-pn|gend-f|num-sg|pers-3|case-|vib-xi|tam-xi
NP	NN	cat-pn|gend-|num-pl|pers-|case-d|vib-0|tam-0
NP	NN	cat-pn|gend-|num-pl|pers-|case-o|vib-0_nuMci|tam-ti
NP	NN	cat-pn|gend-|num-pl|pers-|case-|vib-gAru_ki|tam-gAru_ki
NP	NN	cat-pn|gend-|num-pl|pers-|case-|vib-gAru_obl|tam-gAru_obl
NP	NN	cat-pn|gend-|num-pl|pers-|case-|vib-ki|tam-ki
NP	NN	cat-pn|gend-|num-pl|pers-|case-|vib-lAMti_xi|tam-lAMti_xi_0
NP	NN	cat-pn|gend-|num-pl|pers-|case-|vib-vAlYlu_kaMteV|tam-vAlYlu_kaMteV|poslcat-NM
NP	NN	cat-pn|gend-|num-pl|pers-|case-|vib-vAlYlu_ki|tam-vAlYlu_ki
NP	NN	cat-pn|gend-|num-pl|pers-|case-|vib-vAlYlu_lo|tam-vAlYlu_lo
NP	NN	cat-pn|gend-|num-pl|pers-|case-|vib-vAlYlu_obl|tam-vAlYlu_obl
NP	NN	cat-pn|gend-|num-pl|pers-|case-|vib-vAlYlu_wo|tam-vAlYlu_wo
NP	NN	cat-pn|gend-|num-pl|pers-|case-|vib-vAru_obl|tam-vAru_obl
NP	NN	cat-pn|gend-|num-pl|pers-|case-|vib-xi_0|tam-xi_0_e
NP	NN	cat-pn|gend-|num-pl|pers-|case-|vib-xi|tam-xi_0
NP	NN	cat-pn|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	NN	cat-pn|gend-|num-sg|pers-|case-|vib-0_ceVMwa_nuMdi|tam-gAdu_obl
NP	NN	cat-pn|gend-|num-sg|pers-|case-|vib-Ena_xi|tam-Ena_xi_0
NP	NN	cat-pn|gend-|num-sg|pers-|case-|vib-lAMti_xi_0|tam-lAMti_xi_0_A
NP	NN	cat-pn|gend-|num-sg|pers-|case-|vib-xi_0|tam-xi_0_o|poslcat-NM
NP	NN	cat-pn|gend-|num-sg|pers-|case-|vib-xi_nu|tam-xi_nu
NP	NN	cat-pn|gend-|num-sg|pers-|case-|vib-xi|tam-xi_0
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_ku|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_mAwrame|tam-|poslcat-NM
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-0_wo|tam-
NP	NN	cat-unk|gend-|num-|pers-|case-|vib-|tam-
NP	NN	cat-v|gend-any|num-any|pers-any|case-|vib-0_nuMdi|tam-an
NP	NN	cat-v|gend-any|num-any|pers-any|case-|vib-an|tam-an
NP	NN	cat-v|gend-fn|num-sg|pers-3|case-|vib-A|tam-A
NP	NN	cat-v|gend-|num-sg|pers-2|case-|vib-AjFArWa|tam-AjFArWa
NP	NNP	cat-n|gend-|num-pl|pers-|case-d|vib-0|tam-0
NP	NNP	cat-n|gend-|num-pl|pers-|case-|vib-0|tam-0_o
NP	NNP	cat-n|gend-|num-pl|pers-|case-|vib-ki|tam-ki
NP	NNP	cat-n|gend-|num-sg|pers-|case-d|vib-0_cewa|tam-0
NP	NNP	cat-n|gend-|num-sg|pers-|case-d|vib-0_kUdA|tam-0
NP	NNP	cat-n|gend-|num-sg|pers-|case-d|vib-0_kosaM|tam-0
NP	NNP	cat-n|gend-|num-sg|pers-|case-d|vib-0_lo|tam-0
NP	NNP	cat-n|gend-|num-sg|pers-|case-d|vib-0_nuMci|tam-0
NP	NNP	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	NNP	cat-n|gend-|num-sg|pers-|case-o|vib-ti|tam-ti
NP	NNP	cat-n|gend-|num-sg|pers-|case-|vib-0_kUdA|tam-ki
NP	NNP	cat-n|gend-|num-sg|pers-|case-|vib-0|tam-0_V
NP	NNP	cat-n|gend-|num-sg|pers-|case-|vib-0|tam-0_e
NP	NNP	cat-n|gend-|num-sg|pers-|case-|vib-ki|tam-ki
NP	NNP	cat-n|gend-|num-sg|pers-|case-|vib-ki|tam-ki_V
NP	NNP	cat-n|gend-|num-sg|pers-|case-|vib-ki|tam-ki_e
NP	NNP	cat-n|gend-|num-sg|pers-|case-|vib-lo|tam-lo
NP	NNP	cat-n|gend-|num-sg|pers-|case-|vib-ni|tam-ni
NP	NNP	cat-n|gend-|num-sg|pers-|case-|vib-ni|tam-ni_e
NP	NNP	cat-n|gend-|num-sg|pers-|case-|vib-nu|tam-nu
NP	NNP	cat-n|gend-|num-sg|pers-|case-|vib-wo|tam-wo
NP	NNP	cat-n|gend-|num-sg|pers-|case-|vib-xi|tam-xi
NP	NNP	cat-n|gend-|num-|pers-|case-|vib-|tam-
NP	NNP	cat-pn|gend-|num-sg|pers-|case-|vib-xi_0|tam-xi_0_A
NP	NNP	cat-pn|gend-|num-sg|pers-|case-|vib-xi|tam-xi_0
NP	NNP	cat-unk|gend-|num-|pers-|case-|vib-0_nuMdi|tam-
NP	NNP	cat-unk|gend-|num-|pers-|case-|vib-0_wo|tam-
NP	NNP	cat-unk|gend-|num-|pers-|case-|vib-|tam-
NP	NNP	cat-unk|gend-|num-|pers-|case-|vib-|tam-|poslcat-NM
NP	NST	cat-adv|gend-|num-|pers-|case-|vib-0_e|tam-0_e_adv
NP	NST	cat-adv|gend-|num-|pers-|case-|vib-0_kUdA|tam-0_adv
NP	NST	cat-adv|gend-|num-|pers-|case-|vib-0_nuMci|tam-yoVkka_adv
NP	NST	cat-adv|gend-|num-|pers-|case-|vib-0_o|tam-0_o_adv
NP	NST	cat-adv|gend-|num-|pers-|case-|vib-0_varaku|tam-yoVkka_adv
NP	NST	cat-adv|gend-|num-|pers-|case-|vib-0|tam-0_adv
NP	NST	cat-adv|gend-|num-|pers-|case-|vib-0|tam-0_adv|poslcat-NM
NP	NST	cat-adv|gend-|num-|pers-|case-|vib-ku|tam-ku_adv
NP	NST	cat-adv|gend-|num-|pers-|case-|vib-ku|tam-ku_adv|poslcat-NM
NP	NST	cat-adv|gend-|num-|pers-|case-|vib-lo|tam-lo_adv
NP	NST	cat-adv|gend-|num-|pers-|case-|vib-yoVkka|tam-yoVkka_adv
NP	NST	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
NP	NST	cat-avy|gend-|num-|pers-|case-|vib-V|tam-V_avy
NP	NST	cat-avy|gend-|num-|pers-|case-|vib-|tam-
NP	NST	cat-n|gend-|num-sg|pers-|case-d|vib-0_kUdA|tam-0
NP	NST	cat-n|gend-|num-sg|pers-|case-d|vib-0_nuMdi|tam-0
NP	NST	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	NST	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0|poslcat-NM
NP	NST	cat-n|gend-|num-sg|pers-|case-|vib-0|tam-0_V
NP	NST	cat-n|gend-|num-sg|pers-|case-|vib-ki|tam-ki
NP	NST	cat-n|gend-|num-sg|pers-|case-|vib-na|tam-na
NP	NST	cat-n|gend-|num-sg|pers-|case-|vib-niMci|tam-niMci
NP	NST	cat-n|gend-|num-sg|pers-|case-|vib-ni|tam-ni_e
NP	NST	cat-pn|gend-|num-sg|pers-|case-|vib-varaku|tam-varaku
NP	NST	cat-unk|gend-|num-|pers-|case-|vib-|tam-
NP	NST	cat-v|gend-any|num-any|pers-any|case-|vib-0_nuMci|tam-i
NP	NST	cat-v|gend-any|num-any|pers-any|case-|vib-ina|tam-ina
NP	PRP	cat-avy|gend-|num-|pers-|case-|vib-0_kUdA|tam-0_avy
NP	PRP	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
NP	PRP	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy|poslcat-NM
NP	PRP	cat-avy|gend-|num-|pers-|case-|vib-e|tam-e_avy
NP	PRP	cat-avy|gend-|num-|pers-|case-|vib-|tam-
NP	PRP	cat-avy|gend-|num-|pers-|case-|vib-|tam-|poslcat-NM
NP	PRP	cat-n|gend-|num-sg|pers-|case-d|vib-0_valana|tam-0
NP	PRP	cat-pn|gend-any|num-pl|pers-1|case-o|vib-ti|tam-ti
NP	PRP	cat-pn|gend-any|num-pl|pers-1|case-|vib-0|tam-0_e
NP	PRP	cat-pn|gend-any|num-pl|pers-2|case-o|vib-ti|tam-ti
NP	PRP	cat-pn|gend-any|num-pl|pers-2|case-|vib-0|tam-0_e
NP	PRP	cat-pn|gend-any|num-pl|pers-2|case-|vib-ki|tam-ki
NP	PRP	cat-pn|gend-any|num-sg|pers-1|case-d|vib-0_kUdA|tam-0
NP	PRP	cat-pn|gend-any|num-sg|pers-1|case-d|vib-0|tam-0
NP	PRP	cat-pn|gend-any|num-sg|pers-1|case-o|vib-0_woti|tam-ti
NP	PRP	cat-pn|gend-any|num-sg|pers-1|case-o|vib-ti|tam-ti
NP	PRP	cat-pn|gend-any|num-sg|pers-1|case-|vib-0_kUdA|tam-ki
NP	PRP	cat-pn|gend-any|num-sg|pers-1|case-|vib-0|tam-0_e
NP	PRP	cat-pn|gend-any|num-sg|pers-1|case-|vib-aMte|tam-aMte
NP	PRP	cat-pn|gend-any|num-sg|pers-1|case-|vib-kaMteV|tam-kaMteV
NP	PRP	cat-pn|gend-any|num-sg|pers-1|case-|vib-ki|tam-ki
NP	PRP	cat-pn|gend-any|num-sg|pers-1|case-|vib-mIxa|tam-mIxa
NP	PRP	cat-pn|gend-any|num-sg|pers-1|case-|vib-ni|tam-ni
NP	PRP	cat-pn|gend-any|num-sg|pers-1|case-|vib-wo|tam-wo
NP	PRP	cat-pn|gend-any|num-sg|pers-2|case-d|vib-0|tam-0
NP	PRP	cat-pn|gend-any|num-sg|pers-2|case-o|vib-ti|tam-ti
NP	PRP	cat-pn|gend-any|num-sg|pers-2|case-|vib-0_kUdA|tam-ki
NP	PRP	cat-pn|gend-any|num-sg|pers-2|case-|vib-ki|tam-ki
NP	PRP	cat-pn|gend-any|num-sg|pers-2|case-|vib-ki|tam-ki_e
NP	PRP	cat-pn|gend-any|num-sg|pers-2|case-|vib-ni|tam-ni
NP	PRP	cat-pn|gend-any|num-sg|pers-2|case-|vib-wo|tam-wo
NP	PRP	cat-pn|gend-fm|num-pl|pers-3|case-d|vib-0|tam-0
NP	PRP	cat-pn|gend-fm|num-pl|pers-3|case-d|vib-nu|tam-nu
NP	PRP	cat-pn|gend-fm|num-pl|pers-3|case-o|vib-ki|tam-ki
NP	PRP	cat-pn|gend-fm|num-pl|pers-3|case-o|vib-ti|tam-ti
NP	PRP	cat-pn|gend-fm|num-pl|pers-3|case-|vib-ki|tam-ki
NP	PRP	cat-pn|gend-fm|num-pl|pers-3|case-|vib-lo|tam-lo
NP	PRP	cat-pn|gend-fm|num-pl|pers-3|case-|vib-mIxa|tam-mIxa
NP	PRP	cat-pn|gend-fn|num-pl|pers-3|case-d|vib-0|tam-0
NP	PRP	cat-pn|gend-fn|num-pl|pers-3|case-|vib-0|tam-0_V
NP	PRP	cat-pn|gend-fn|num-pl|pers-3|case-|vib-lo|tam-lo
NP	PRP	cat-pn|gend-fn|num-pl|pers-3|case-|vib-ni|tam-ni
NP	PRP	cat-pn|gend-fn|num-sg|pers-3|case-d|vib-0|tam-0
NP	PRP	cat-pn|gend-fn|num-sg|pers-3|case-o|vib-0_guriMcayinA|tam-ti
NP	PRP	cat-pn|gend-fn|num-sg|pers-3|case-o|vib-0_valana_kUdA|tam-ti
NP	PRP	cat-pn|gend-fn|num-sg|pers-3|case-o|vib-0_valana|tam-ti
NP	PRP	cat-pn|gend-fn|num-sg|pers-3|case-o|vib-0_xvArA|tam-ti
NP	PRP	cat-pn|gend-fn|num-sg|pers-3|case-o|vib-ti|tam-ti
NP	PRP	cat-pn|gend-fn|num-sg|pers-3|case-|vib-0|tam-0_V
NP	PRP	cat-pn|gend-fn|num-sg|pers-3|case-|vib-0|tam-0_e
NP	PRP	cat-pn|gend-fn|num-sg|pers-3|case-|vib-0|tam-0_o
NP	PRP	cat-pn|gend-fn|num-sg|pers-3|case-|vib-ki|tam-ki
NP	PRP	cat-pn|gend-fn|num-sg|pers-3|case-|vib-lo|tam-lo
NP	PRP	cat-pn|gend-fn|num-sg|pers-3|case-|vib-nu|tam-nu
NP	PRP	cat-pn|gend-fn|num-sg|pers-3|case-|vib-valana|tam-valana
NP	PRP	cat-pn|gend-fn|num-sg|pers-3|case-|vib-wo|tam-wo
NP	PRP	cat-pn|gend-f|num-sg|pers-3|case-d|vib-0_vaxxa|tam-0
NP	PRP	cat-pn|gend-f|num-sg|pers-3|case-d|vib-0|tam-0
NP	PRP	cat-pn|gend-f|num-sg|pers-3|case-|vib-0|tam-0_e
NP	PRP	cat-pn|gend-f|num-sg|pers-3|case-|vib-ki|tam-ki
NP	PRP	cat-pn|gend-f|num-sg|pers-3|case-|vib-ki|tam-ki_o
NP	PRP	cat-pn|gend-f|num-sg|pers-3|case-|vib-ni|tam-ni
NP	PRP	cat-pn|gend-f|num-sg|pers-3|case-|vib-wo|tam-wo
NP	PRP	cat-pn|gend-m|num-sg|pers-3|case-d|vib-0_kUdA|tam-0
NP	PRP	cat-pn|gend-m|num-sg|pers-3|case-d|vib-0|tam-0
NP	PRP	cat-pn|gend-m|num-sg|pers-3|case-o|vib-0_koVraku|tam-ti
NP	PRP	cat-pn|gend-m|num-sg|pers-3|case-o|vib-0_kosaM|tam-ti
NP	PRP	cat-pn|gend-m|num-sg|pers-3|case-o|vib-ti|tam-ti
NP	PRP	cat-pn|gend-m|num-sg|pers-3|case-|vib-0|tam-0_e
NP	PRP	cat-pn|gend-m|num-sg|pers-3|case-|vib-ki|tam-ki
NP	PRP	cat-pn|gend-m|num-sg|pers-3|case-|vib-ni|tam-ni
NP	PRP	cat-pn|gend-m|num-sg|pers-3|case-|vib-nu|tam-nu
NP	PRP	cat-pn|gend-|num-pl|pers-|case-d|vib-0_kUdA|tam-0
NP	PRP	cat-pn|gend-|num-pl|pers-|case-d|vib-0|tam-0
NP	PRP	cat-pn|gend-|num-pl|pers-|case-o|vib-ti|tam-ti
NP	PRP	cat-pn|gend-|num-pl|pers-|case-|vib-0|tam-0_V
NP	PRP	cat-pn|gend-|num-pl|pers-|case-|vib-e_axi|tam-e_axi_0
NP	PRP	cat-pn|gend-|num-pl|pers-|case-|vib-ki|tam-ki
NP	PRP	cat-pn|gend-|num-pl|pers-|case-|vib-ki|tam-ki_V
NP	PRP	cat-pn|gend-|num-pl|pers-|case-|vib-lo|tam-lo
NP	PRP	cat-pn|gend-|num-pl|pers-|case-|vib-ni|tam-ni_V
NP	PRP	cat-pn|gend-|num-pl|pers-|case-|vib-nu|tam-nu
NP	PRP	cat-pn|gend-|num-pl|pers-|case-|vib-wo|tam-wo
NP	PRP	cat-pn|gend-|num-pl|pers-|case-|vib-wo|tam-wo_V
NP	PRP	cat-pn|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	PRP	cat-pn|gend-|num-sg|pers-|case-o|vib-ti|tam-ti
NP	PRP	cat-pn|gend-|num-sg|pers-|case-|vib-e_axi_0|tam-e_axi_0_o
NP	PRP	cat-pn|gend-|num-sg|pers-|case-|vib-kaMteV|tam-kaMteV
NP	PRP	cat-pn|gend-|num-sg|pers-|case-|vib-ki|tam-ki
NP	PRP	cat-pn|gend-|num-sg|pers-|case-|vib-ni|tam-ni
NP	PRP	cat-pn|gend-|num-sg|pers-|case-|vib-xAkA|tam-xAkA
NP	PRP	cat-unk|gend-|num-|pers-|case-|vib-|tam-
NP	PRP	cat-unk|gend-|num-|pers-|case-|vib-|tam-|poslcat-NM
NP	PRP	cat-v|gend-|num-sg|pers-2|case-|vib-AjFArWa|tam-AjFArWa
NP	QC	cat-num|gend-|num-|pers-|case-|vib-0_nuMdi|tam-
NP	QC	cat-num|gend-|num-|pers-|case-|vib-|tam-
NP	QC	cat-n|gend-|num-sg|pers-|case-d|vib-0_nuMdi|tam-0
NP	QC	cat-n|gend-|num-sg|pers-|case-d|vib-0_xAkA|tam-0
NP	QC	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	QC	cat-n|gend-|num-sg|pers-|case-o|vib-0_nuMci|tam-ti
NP	QC	cat-n|gend-|num-sg|pers-|case-|vib-xAkA|tam-xAkA
NP	QC	cat-n|gend-|num-|pers-|case-|vib-unnara|tam-unnara
NP	QC	cat-unk|gend-|num-|pers-|case-|vib-|tam-
NP	QF	cat-adj|gend-|num-|pers-|case-|vib-0|tam-0_adj
NP	QF	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
NP	QF	cat-n|gend-|num-pl|pers-|case-o|vib-ti|tam-ti
NP	QF	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	QF	cat-n|gend-|num-sg|pers-|case-|vib-na|tam-na
NP	QF	cat-n|gend-|num-|pers-|case-|vib-iMwa|tam-iMwa
NP	QF	cat-pn|gend-|num-pl|pers-|case-d|vib-0|tam-0
NP	QF	cat-pn|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	QF	cat-unk|gend-|num-|pers-|case-|vib-|tam-
NP	QF	cat-v|gend-|num-sg|pers-2|case-|vib-AjFArWa|tam-AjFArWa
NP	QO	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	RB	cat-n|gend-|num-sg|pers-|case-|vib-gA|tam-gA
NP	RDP	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
NP	RP	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
NP	SYM	cat-punc|gend-|num-|pers-|case-|vib-0_aMxulo|tam-
NP	SYM	cat-punc|gend-|num-|pers-|case-|vib-|tam-
NP	SYM	cat-punc|gend-|num-|pers-|case-|vib-|tam-|poslcat-NM
NP	UT	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
NP	UT	cat-avy|gend-|num-|pers-|case-|vib-|tam-
NP	VM	cat-adj|gend-|num-|pers-|case-|vib-0|tam-0_adj
NP	VM	cat-v|gend-any|num-any|pers-any|case-|vib-Ali_ani|tam-Ali_ani
NP	VM	cat-v|gend-any|num-any|pers-any|case-|vib-adaM|tam-adaM
NP	VM	cat-v|gend-any|num-any|pers-any|case-|vib-koVn_Ali_ani|tam-koVn_Ali_ani
NP	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-A|tam-A
NP	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-a|tam-a
NP	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-a|tam-a
NP	VM	cat-v|gend-|num-pl|pers-3|case-|vib-a_le_a|tam-a_le_a
NP	WQ	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
NP	WQ	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy|poslcat-NM
NP	WQ	cat-avy|gend-|num-|pers-|case-|vib-o|tam-o_avy
NP	WQ	cat-avy|gend-|num-|pers-|case-|vib-|tam-
NP	WQ	cat-n|gend-|num-pl|pers-|case-|vib-ni|tam-ni
NP	WQ	cat-n|gend-|num-sg|pers-|case-|vib-ni|tam-ni_o
NP	WQ	cat-pn|gend-fm|num-pl|pers-3|case-o|vib-ti|tam-ti
NP	WQ	cat-pn|gend-fm|num-pl|pers-3|case-|vib-ki|tam-ki_V
NP	WQ	cat-pn|gend-fm|num-pl|pers-3|case-|vib-ni|tam-ni
NP	WQ	cat-pn|gend-fn|num-pl|pers-3|case-|vib-0|tam-0_V
NP	WQ	cat-pn|gend-fn|num-sg|pers-3|case-|vib-0|tam-0_o
NP	WQ	cat-pn|gend-|num-sg|pers-|case-d|vib-0|tam-0
NP	WQ	cat-unk|gend-|num-|pers-|case-|vib-|tam-
NULL_CCP	CC	_
NULL_VGF	VM	_
NULL__CCP	CC	_
NULL__CCP	NST	_
NULL__VGF	VM	_
QF	DEM	_
RBP	ECH	cat-n|gend-|num-sg|pers-|case-|vib-gA|tam-gA
RBP	INTF	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
RBP	JJ	cat-adj|gend-|num-|pers-|case-|vib-0|tam-0_adj
RBP	NN	cat-n|gend-|num-sg|pers-|case-|vib-gA|tam-gA
RBP	NN	cat-n|gend-|num-sg|pers-|case-|vib-na|tam-na
RBP	NST	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
RBP	QF	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
RBP	RB	cat-adj|gend-|num-|pers-|case-|vib-0|tam-0_adj
RBP	RB	cat-adj|gend-|num-|pers-|case-|vib-gA|tam-gA_adj
RBP	RB	cat-adv|gend-|num-sg|pers-|case-o|vib-0|tam-0_adv
RBP	RB	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
RBP	RB	cat-avy|gend-|num-|pers-|case-|vib-A|tam-A_avy
RBP	RB	cat-avy|gend-|num-|pers-|case-|vib-V|tam-V_avy
RBP	RB	cat-avy|gend-|num-|pers-|case-|vib-e|tam-e_avy
RBP	RB	cat-avy|gend-|num-|pers-|case-|vib-|tam-
RBP	RB	cat-n|gend-|num-pl|pers-|case-|vib-gA|tam-gA
RBP	RB	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
RBP	RB	cat-n|gend-|num-sg|pers-|case-|vib-0|tam-0_e
RBP	RB	cat-n|gend-|num-sg|pers-|case-|vib-gA|tam-gA
RBP	RB	cat-n|gend-|num-|pers-|case-|vib-iMwa|tam-iMwa
RBP	RB	cat-unk|gend-|num-|pers-|case-|vib-|tam-
RBP	RB	cat-v|gend-any|num-any|pers-any|case-|vib-akuMdA|tam-akuMdA
RBP	RB	cat-v|gend-any|num-any|pers-any|case-|vib-i|tam-i
RBP	RP	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
RBP	RP	cat-avy|gend-|num-|pers-|case-|vib-V|tam-V_avy
RBP	RP	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
RBP	VM	cat-v|gend-|num-sg|pers-1|case-|vib-a|tam-a
RBP	WQ	cat-adv|gend-|num-|pers-|case-|vib-0|tam-0_adv
RBP	WQ	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
RBP	WQ	cat-pn|gend-|num-sg|pers-|case-d|vib-0|tam-0
VGF	SYM	cat-punc|gend-|num-|pers-|case-|vib-|tam-
VGF	VAUX	cat-v|gend-fn|num-sg|pers-3|case-|vib-A|tam-A
VGF	VAUX	cat-v|gend-fn|num-sg|pers-3|case-|vib-wA|tam-wA
VGF	VM	cat-adj|gend-|num-|pers-|case-|vib-xi|tam-xi_adj
VGF	VM	cat-adv|gend-|num-|pers-|case-|vib-0_V|tam-0_V_adv
VGF	VM	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
VGF	VM	cat-avy|gend-|num-|pers-|case-|vib-|tam-|poslcat-NM
VGF	VM	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
VGF	VM	cat-n|gend-|num-sg|pers-|case-|vib-xi|tam-xi
VGF	VM	cat-pn|gend-fm|num-sg|pers-3|case-|vib-e_axi|tam-e_axi_0
VGF	VM	cat-pn|gend-fm|num-sg|pers-3|case-|vib-e_vAdu_avvu+a|tam-e_vAdu_0
VGF	VM	cat-pn|gend-|num-any|pers-any|case-|vib-e_axi_gala+aka|tam-e_axi_0
VGF	VM	cat-pn|gend-|num-pl|pers-|case-|vib-e_vAlYlu_nu|tam-e_vAlYlu_nu
VGF	VM	cat-pn|gend-|num-pl|pers-|case-|vib-e_vAru_0|tam-e_vAru_0_e
VGF	VM	cat-pn|gend-|num-pl|pers-|case-|vib-e_vAru|tam-e_vAru_0
VGF	VM	cat-pn|gend-|num-pl|pers-|case-|vib-gala_xi|tam-gala_xi_0|poslcat-NM
VGF	VM	cat-pn|gend-|num-pl|pers-|case-|vib-ina_axi|tam-ina_axi_0
VGF	VM	cat-pn|gend-|num-sg|pers-3|case-|vib-e_axi_avvu+a|tam-e_axi_0
VGF	VM	cat-pn|gend-|num-sg|pers-3|case-|vib-e_vAdu_avvu+a|tam-e_vAdu_0
VGF	VM	cat-pn|gend-|num-sg|pers-|case-|vib-e_axi|tam-e_axi_0
VGF	VM	cat-pn|gend-|num-sg|pers-|case-|vib-e_vAdu|tam-e_vAdu_0
VGF	VM	cat-pn|gend-|num-sg|pers-|case-|vib-ina_axi|tam-ina_axi_0
VGF	VM	cat-pn|gend-|num-sg|pers-|case-|vib-wunna_axi|tam-wunna_axi_0
VGF	VM	cat-unk|gend-|num-sg|pers-3|case-|vib-0_po+A|tam-
VGF	VM	cat-unk|gend-|num-|pers-|case-|vib-|tam-
VGF	VM	cat-unk|gend-|num-|pers-|case-|vib-|tam-|poslcat-NM
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-Ali_aMte|tam-Ali_aMte
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-Ali_ani|tam-Ali_ani
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-Ali|tam-Ali
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-a_kUdaxu|tam-a_kUdaxu
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-a_le_aka_po+adaM|tam-a_le_aka
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-a_lexu|tam-a_lexu
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-a_neru|tam-a_neru
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-a_vaccu|tam-a_vaccu
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-a_valayu_ina_aMwa_uMdu+Ali|tam-a_valayu_ina_aMwa
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-a_vaxxu|tam-a_vaxxu
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-adaM_lexemo|tam-adaM
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-adaM|tam-adaM
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-akapowe|tam-akapowe
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-akuMdA_ayiMdu|tam-akuMdA
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-ani|tam-ani
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-e|tam-e
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i_uMdu+Ali|tam-i
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i_uMdu+a_vaccu|tam-i
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i_uMdu+e|tam-i
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i_uMdu_Ali|tam-i_uMdu_Ali
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i_uMdu_we|tam-i_uMdu_we
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i_vaccu+Ali|tam-i
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i_vaccu|tam-i_vaccu
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i_veVyyi+Ali|tam-i
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i_veVyyi_a_kUdaxu|tam-i_veVyyi_a_kUdaxu
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-inA|tam-inA
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-ina_atlu|tam-ina_atlu
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i|tam-i
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-koVn_Ali|tam-koVn_Ali
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-koVn_a_vaccu|tam-koVn_a_vaccu
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-koVn|tam-koVn
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-wU_uMdu_Ali|tam-wU_uMdu_Ali
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-wU_uMdu|tam-wU_uMdu
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-wU_unnAM|tam-wU_e
VGF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-we|tam-we
VGF	VM	cat-v|gend-any|num-pl|pers-2|case-|vib-e_lA_cUdu+AjFArWa|tam-e_lA
VGF	VM	cat-v|gend-any|num-pl|pers-2|case-|vib-i_uMdu+xA|tam-i
VGF	VM	cat-v|gend-any|num-pl|pers-3|case-|vib-a_gala_aka_po+A|tam-a_gala_aka
VGF	VM	cat-v|gend-any|num-pl|pers-3|case-|vib-akuMdA_ceVyyi+A|tam-akuMdA
VGF	VM	cat-v|gend-any|num-pl|pers-3|case-|vib-e_atlu_cUdu+A|tam-e_atlu
VGF	VM	cat-v|gend-any|num-pl|pers-3|case-|vib-i_ceVyyi+A|tam-i_A
VGF	VM	cat-v|gend-any|num-pl|pers-3|case-|vib-i_po+A|tam-i
VGF	VM	cat-v|gend-any|num-pl|pers-3|case-|vib-i_po+wA|tam-i
VGF	VM	cat-v|gend-any|num-sg|pers-1|case-|vib-i_uMcu+A|tam-i
VGF	VM	cat-v|gend-any|num-sg|pers-1|case-|vib-i_vaccu+wA|tam-i
VGF	VM	cat-v|gend-any|num-sg|pers-1|case-|vib-wU_uMdu+A|tam-wU_e
VGF	VM	cat-v|gend-any|num-sg|pers-2|case-|vib-i_po+wA|tam-i
VGF	VM	cat-v|gend-any|num-sg|pers-2|case-|vib-i_uMcu+AjFArWa_manu|tam-i
VGF	VM	cat-v|gend-any|num-sg|pers-2|case-|vib-koVn_we_cAlu+AjFArWa|tam-koVn_we
VGF	VM	cat-v|gend-any|num-sg|pers-2|case-|vib-we_cAlu+AjFArWa|tam-we
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-Ali_ani_gala+a|tam-Ali_ani
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-Ali_ani_uMdu+A|tam-Ali_ani
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-a_valayu_i_uMdu+A|tam-a_valayu_i
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-a_valayu_i_uMdu+wA|tam-a_valayu_i
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-adaM_gala+a|tam-adaM
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-an_kUdu+a|tam-an
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-e_lA_ceVyyi+A|tam-e_lA
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-i_ivvu+A|tam-i
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-i_po+A|tam-i
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-i_po+wA|tam-i
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-i_po_Ali_ani_uMdu+A|tam-i_po_Ali_ani
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-i_uMdu+A|tam-i
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-i_vaccu+A|tam-i
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-i_veVyyi_an_gUdu+a|tam-i_veVyyi_an
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-ina_atlu_avvu+wA|tam-ina_atlu
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-koVn_Ali_ani_uMdu+A|tam-koVn_Ali_ani
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-wU_uMdu+A|tam-wU_e
VGF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-wU_uMdu+wA|tam-wU
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-A_ani|tam-A_ani
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-A|tam-A
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-A|tam-A_A
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-a_gala_aka_po|tam-a_gala_aka_po_A
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-a_ivvu_a_gala_a|tam-a_ivvu_a_gala_a
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-a_ivvu_a|tam-a_ivvu_a
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-a_sAgu|tam-a_sAgu_A
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-a_valayu_avvu+a|tam-a_valayu_A
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-a|tam-a
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-a|tam-a_o
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-i_po_wU_uMdu|tam-i_po_wU_uMdu_A
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-i_po_wunn|tam-i_po_wunn
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-i_po|tam-i_po_A
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-i_vaccu|tam-i_vaccu_A
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-i_veVyyi_wU_uMdu_A|tam-i_veVyyi_wU_uMdu_A_A
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-i_veVyyi|tam-i_veVyyi_A
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-koVn_wU_uMdu|tam-koVn_wU_uMdu_A
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-koVn_wunn|tam-koVn_wunn
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-koVn|tam-koVn_A
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-wA|tam-wA
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-wA|tam-wA_A
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-wA|tam-wA|stype-declarative|voicetype-active
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-wunn|tam-wunn
VGF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-wunn|tam-wunn_A
VGF	VM	cat-v|gend-m|num-sg|pers-3|case-|vib-A|tam-A
VGF	VM	cat-v|gend-m|num-sg|pers-3|case-|vib-A|tam-A_o
VGF	VM	cat-v|gend-m|num-sg|pers-3|case-|vib-a_gala_aka_po|tam-a_gala_aka_po_A
VGF	VM	cat-v|gend-m|num-sg|pers-3|case-|vib-a_manu|tam-a_manu_A
VGF	VM	cat-v|gend-m|num-sg|pers-3|case-|vib-a|tam-a
VGF	VM	cat-v|gend-m|num-sg|pers-3|case-|vib-i_cUdu|tam-i_cUdu_A
VGF	VM	cat-v|gend-m|num-sg|pers-3|case-|vib-i_po|tam-i_po_A
VGF	VM	cat-v|gend-m|num-sg|pers-3|case-|vib-i_veVyyi|tam-i_veVyyi_A
VGF	VM	cat-v|gend-m|num-sg|pers-3|case-|vib-koVn_a_galugu|tam-koVn_a_galugu_A
VGF	VM	cat-v|gend-m|num-sg|pers-3|case-|vib-koVn_wA_ata|tam-koVn_wA_ata
VGF	VM	cat-v|gend-m|num-sg|pers-3|case-|vib-koVn_wA|tam-koVn_wA
VGF	VM	cat-v|gend-m|num-sg|pers-3|case-|vib-koVn|tam-koVn_A
VGF	VM	cat-v|gend-m|num-sg|pers-3|case-|vib-wA|tam-wA
VGF	VM	cat-v|gend-m|num-sg|pers-3|case-|vib-wunn|tam-wunn
VGF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-A_ata|tam-A_ata
VGF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-A|tam-A
VGF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-a_ani|tam-a_ani
VGF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-a_manu_iwi|tam-a_manu_iwi
VGF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-a_sAgu_iwi|tam-a_sAgu_iwi
VGF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-aka_uMdu_iwi|tam-aka_uMdu_iwi
VGF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-a|tam-a
VGF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-a|tam-a_A
VGF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-i_po_iwi|tam-i_po_iwi
VGF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-i_po|tam-i_po_A
VGF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-iwi|tam-iwi
VGF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-uxu|tam-uxu
VGF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-wA|tam-wA
VGF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-wU_uMdu_wA|tam-wU_uMdu_wA
VGF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-wunn|tam-wunn
VGF	VM	cat-v|gend-|num-pl|pers-1|case-|vib-A|tam-A
VGF	VM	cat-v|gend-|num-pl|pers-1|case-|vib-a_gala_a|tam-a_gala_a
VGF	VM	cat-v|gend-|num-pl|pers-1|case-|vib-a|tam-a
VGF	VM	cat-v|gend-|num-pl|pers-1|case-|vib-koVn_a_le_a|tam-koVn_a_le_a_A
VGF	VM	cat-v|gend-|num-pl|pers-1|case-|vib-wA|tam-wA
VGF	VM	cat-v|gend-|num-pl|pers-2|case-|vib-AjFArWa|tam-AjFArWa
VGF	VM	cat-v|gend-|num-pl|pers-2|case-|vib-xA_ani|tam-xA_ani
VGF	VM	cat-v|gend-|num-pl|pers-2|case-|vib-xA_le|tam-xA_le
VGF	VM	cat-v|gend-|num-pl|pers-2|case-|vib-xA|tam-xA
VGF	VM	cat-v|gend-|num-pl|pers-3|case-|vib-A|tam-A
VGF	VM	cat-v|gend-|num-pl|pers-3|case-|vib-A|tam-A_A
VGF	VM	cat-v|gend-|num-pl|pers-3|case-|vib-a_gala_wA|tam-a_gala_wA
VGF	VM	cat-v|gend-|num-pl|pers-3|case-|vib-a|tam-a
VGF	VM	cat-v|gend-|num-pl|pers-3|case-|vib-i_po|tam-i_po_A
VGF	VM	cat-v|gend-|num-pl|pers-3|case-|vib-i_veVyyi_koVn_wU_uMdi_veVyyi_koVn_wU_uMdu_A|tam-i_veVyyi_koVn_wU_uMdu_A
VGF	VM	cat-v|gend-|num-pl|pers-3|case-|vib-wA|tam-wA
VGF	VM	cat-v|gend-|num-pl|pers-3|case-|vib-wU_uMdu_wA|tam-wU_uMdu_wA
VGF	VM	cat-v|gend-|num-pl|pers-3|case-|vib-wunn|tam-wunn
VGF	VM	cat-v|gend-|num-sg|pers-1|case-|vib-A_ani|tam-A_ani
VGF	VM	cat-v|gend-|num-sg|pers-1|case-|vib-A|tam-A
VGF	VM	cat-v|gend-|num-sg|pers-1|case-|vib-a_badu|tam-a_badu_A
VGF	VM	cat-v|gend-|num-sg|pers-1|case-|vib-a_sAgu|tam-a_sAgu_A
VGF	VM	cat-v|gend-|num-sg|pers-1|case-|vib-a|tam-a
VGF	VM	cat-v|gend-|num-sg|pers-1|case-|vib-i_po|tam-i_po_A
VGF	VM	cat-v|gend-|num-sg|pers-1|case-|vib-i_veVyyi_wA_rA|tam-i_veVyyi_wA_rA
VGF	VM	cat-v|gend-|num-sg|pers-1|case-|vib-i_veVyyi|tam-i_veVyyi_A
VGF	VM	cat-v|gend-|num-sg|pers-1|case-|vib-koVn_a_galugu|tam-koVn_a_galugu_A
VGF	VM	cat-v|gend-|num-sg|pers-1|case-|vib-koVn_wA|tam-koVn_wA_A
VGF	VM	cat-v|gend-|num-sg|pers-1|case-|vib-wA|tam-wA
VGF	VM	cat-v|gend-|num-sg|pers-1|case-|vib-wunn|tam-wunn
VGF	VM	cat-v|gend-|num-sg|pers-2|case-|vib-A_ani|tam-A_ani
VGF	VM	cat-v|gend-|num-sg|pers-2|case-|vib-AjFArWa_cAlu+AjFArWa|tam-AjFArWa
VGF	VM	cat-v|gend-|num-sg|pers-2|case-|vib-AjFArWa|tam-AjFArWa
VGF	VM	cat-v|gend-|num-sg|pers-2|case-|vib-A|tam-A
VGF	VM	cat-v|gend-|num-sg|pers-2|case-|vib-aku|tam-aku
VGF	VM	cat-v|gend-|num-sg|pers-2|case-|vib-i_veVyyi|tam-i_veVyyi_A
VGF	VM	cat-v|gend-|num-sg|pers-2|case-|vib-koVn_wA|tam-koVn_wA
VGF	VM	cat-v|gend-|num-sg|pers-2|case-|vib-wA|tam-wA
VGF	VM	cat-v|gend-|num-sg|pers-3|case-|vib-a_vaccu+a|tam-a_e
VGINF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-e_atlu|tam-e_atlu
VGINF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-ina_appudu|tam-ina_appudu
VGINF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-ina|tam-ina
VGINF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-we|tam-we
VGNF	NN	cat-unk|gend-|num-|pers-|case-|vib-|tam-
VGNF	VAUX	cat-v|gend-any|num-any|pers-any|case-|vib-ina|tam-ina
VGNF	VM	cat-adj|gend-|num-|pers-|case-|vib-xi|tam-xi_adj
VGNF	VM	cat-adv|gend-|num-|pers-|case-|vib-0|tam-0_adv
VGNF	VM	cat-adv|gend-|num-|pers-|case-|vib-_e_appudu_0_V|tam-_e_appudu_0_V_adv
VGNF	VM	cat-avy|gend-|num-|pers-|case-|vib-0|tam-0_avy
VGNF	VM	cat-avy|gend-|num-|pers-|case-|vib-o|tam-o_avy
VGNF	VM	cat-n|gend-|num-pl|pers-|case-d|vib-0|tam-0
VGNF	VM	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
VGNF	VM	cat-n|gend-|num-sg|pers-|case-|vib-0|tam-0_A
VGNF	VM	cat-n|gend-|num-sg|pers-|case-|vib-adaM_ki|tam-adaM_ki
VGNF	VM	cat-n|gend-|num-sg|pers-|case-|vib-adaM_wo|tam-adaM_wo
VGNF	VM	cat-n|gend-|num-sg|pers-|case-|vib-na|tam-na
VGNF	VM	cat-pn|gend-|num-pl|pers-|case-|vib-ina_axi_0|tam-ina_axi_0_e
VGNF	VM	cat-pn|gend-|num-pl|pers-|case-|vib-ina_vAru_0|tam-ina_vAru_0_e
VGNF	VM	cat-pn|gend-|num-pl|pers-|case-|vib-ina_vAru_ki|tam-ina_vAru_ki
VGNF	VM	cat-pn|gend-|num-pl|pers-|case-|vib-xi|tam-xi_0
VGNF	VM	cat-pn|gend-|num-sg|pers-|case-|vib-e_axi_0|tam-e_axi_0_e
VGNF	VM	cat-pn|gend-|num-sg|pers-|case-|vib-e_axi|tam-e_axi_0
VGNF	VM	cat-pn|gend-|num-sg|pers-|case-|vib-ina_axi|tam-ina_axi_0
VGNF	VM	cat-unk|gend-|num-|pers-|case-|vib-0_mAwrame|tam-
VGNF	VM	cat-unk|gend-|num-|pers-|case-|vib-|tam-
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-Ali_aMte|tam-Ali_aMte
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-Ali_ani|tam-Ali_ani
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-Ali|tam-Ali
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-Ali|tam-Ali_o
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-a_gAne|tam-a_gAne
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-a_gala_aka|tam-a_gala_aka
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-a_galugu_inA|tam-a_galugu_inA
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-a_le_aka_po+adaM|tam-a_le_aka
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-a_manu_i|tam-a_manu_i
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-a_po_i|tam-a_po_i
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-a_po|tam-a_po_e
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-a_valayu_ina|tam-a_valayu_ina
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-adaM_valla|tam-adaM
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-adaM|tam-adaM
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-aka_po_ina_app_ki|tam-aka_po_ina_app_ki
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-aka_uMdu_e_eMxuku|tam-aka_uMdu_e_eMxuku
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-akapowe|tam-akapowe
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-aka|tam-aka
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-akuMdA|tam-akuMdA
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-ani|tam-ani
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-an|tam-an
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-a|tam-a_gA
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-e_appudu|tam-e_appudu
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-e_atlu|tam-e_atlu
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-e_eMxuku|tam-e_eMxuku
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-e_muMxu|tam-e_muMxu
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-e_sariki|tam-e_sariki
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-e|tam-e
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i_po+a_lexu|tam-i
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i_po_adaM|tam-i_po_adaM
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i_po_i|tam-i_po_i
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i_po_we|tam-i_po_we
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i_uMdu_a_gAne|tam-i_uMdu_a_gAne
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i_veVyyi_i|tam-i_veVyyi_i
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-inA|tam-inA
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-ina_Aka|tam-ina_Aka
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-ina_aMwa|tam-ina_aMwa
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-ina_aMxuku|tam-ina_aMxuku
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-ina_appudu|tam-ina_appudu
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-ina_atlu|tam-ina_atlu
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-ina_xAkA|tam-ina_xAkA
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-ina|tam-ina
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i|tam-i
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i|tam-i_A
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i|tam-i_o
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-koVn_akuMdA|tam-koVn_akuMdA_e
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-koVn_inA|tam-koVn_inA
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-koVn_wU|tam-koVn_wU
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-koVn_we|tam-koVn_we
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-koVn_wunnA|tam-koVn_wunnA
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-koVn|tam-koVn
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-koVn|tam-koVn_e
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-wU_po_wU|tam-wU_po_wU
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-wU_uMdu|tam-wU_uMdu
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-wU|tam-wU
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-we|tam-we
VGNF	VM	cat-v|gend-any|num-any|pers-any|case-|vib-wuMte|tam-wuMte
VGNF	VM	cat-v|gend-any|num-pl|pers-3|case-|vib-i_uMdu+iwi|tam-i
VGNF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-i_uMdu+A|tam-i
VGNF	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-wU_uMdu+wA|tam-wU
VGNF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-A_ani|tam-A_ani
VGNF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-A|tam-A
VGNF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-A|tam-A_o
VGNF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-a_ani|tam-a_ani
VGNF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-a_valayu|tam-a_valayu_A
VGNF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-a|tam-a
VGNF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-koVn_a_le_a|tam-koVn_a_le_a
VGNF	VM	cat-v|gend-fn|num-sg|pers-3|case-|vib-wA|tam-wA_o
VGNF	VM	cat-v|gend-m|num-sg|pers-3|case-|vib-A_ani|tam-A_ani
VGNF	VM	cat-v|gend-m|num-sg|pers-3|case-|vib-A|tam-A
VGNF	VM	cat-v|gend-m|num-sg|pers-3|case-|vib-koVn_A_ani|tam-koVn_A_ani
VGNF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-A|tam-A
VGNF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-a_uta|tam-a_uta
VGNF	VM	cat-v|gend-n|num-pl|pers-3|case-|vib-iwi|tam-iwi
VGNF	VM	cat-v|gend-|num-pl|pers-1|case-|vib-wA_ani|tam-wA_ani
VGNF	VM	cat-v|gend-|num-pl|pers-2|case-|vib-xA_ani|tam-xA_ani
VGNF	VM	cat-v|gend-|num-pl|pers-2|case-|vib-xA|tam-xA
VGNF	VM	cat-v|gend-|num-pl|pers-3|case-|vib-wA|tam-wA_o
VGNF	VM	cat-v|gend-|num-sg|pers-1|case-|vib-A_ani|tam-A_ani
VGNF	VM	cat-v|gend-|num-sg|pers-1|case-|vib-a|tam-a_e
VGNF	VM	cat-v|gend-|num-sg|pers-2|case-|vib-AjFArWa_manu|tam-AjFArWa_manu
VGNF	VM	cat-v|gend-|num-sg|pers-2|case-|vib-AjFArWa|tam-AjFArWa
VGNF	VM	cat-v|gend-|num-sg|pers-2|case-|vib-i_veVyyi_A|tam-i_veVyyi_A_A
VGNF	VM	cat-v|gend-|num-sg|pers-2|case-|vib-koVn_wU_uMdu_A|tam-koVn_wU_uMdu_A_A
VGNF	WQ	cat-pn|gend-|num-sg|pers-|case-|vib-e_axi_0|tam-e_axi_0_o
VGNN	NN	cat-pn|gend-|num-pl|pers-|case-|vib-e_vAlYlu|tam-e_vAlYlu_0
VGNN	VM	cat-n|gend-|num-sg|pers-|case-d|vib-0|tam-0
VGNN	VM	cat-n|gend-|num-sg|pers-|case-|vib-adaM_0|tam-adaM_0_e
VGNN	VM	cat-n|gend-|num-sg|pers-|case-|vib-adaM_ki|tam-adaM_ki
VGNN	VM	cat-n|gend-|num-sg|pers-|case-|vib-lo|tam-lo
VGNN	VM	cat-unk|gend-|num-|pers-|case-|vib-|tam-
VGNN	VM	cat-v|gend-any|num-any|pers-any|case-|vib-adaM_valla|tam-adaM
VGNN	VM	cat-v|gend-any|num-any|pers-any|case-|vib-adaM|tam-adaM
VGNN	VM	cat-v|gend-any|num-any|pers-any|case-|vib-aka_po_adaM|tam-aka_po_adaM
VGNN	VM	cat-v|gend-any|num-any|pers-any|case-|vib-i_po_adaM|tam-i_po_adaM
VGNN	VM	cat-v|gend-any|num-any|pers-any|case-|vib-ina|tam-ina
VGNN	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-a_ivvu_adaM_gala+a|tam-a_ivvu_adaM
VGNN	VM	cat-v|gend-any|num-sg|pers-3|case-|vib-adaM_gala+a|tam-adaM
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
