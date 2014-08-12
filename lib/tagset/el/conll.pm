#!/usr/bin/perl
# Driver for the CoNLL 2007 Modern Greek.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>, Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::el::conll;
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
    $f{tagset} = "el::conll";
    # three components: coarse-grained pos, fine-grained pos, features
    my ($pos, $subpos, $features) = split(/\s+/, $tag);

    # nouns
    if($pos =~ /^(No)$/)
    {
        $f{pos} = "noun";

        if ($subpos eq "NoPr") {
            $f{subpos} = "prop";
        }
    }
    elsif ($pos eq "Pn") {
        $f{pos} = "noun";

        if ($subpos eq "PnPe") {
            $f{prontype} = "prs";
        }
        elsif ($subpos eq "PnPo") {
            $f{prontype} = "prs";
        }
        elsif ($subpos eq "PnRe") {
            $f{prontype} = "rel";
        }
        elsif ($subpos eq "PnRi") {
            $f{prontype} = "rel";
        }
        elsif ($subpos eq "PnDm") {
            $f{prontype} = "dem";
        }
        elsif ($subpos eq "PnIr") {
            $f{prontype} = "int";
        }
        elsif ($subpos eq "PnId") {
            $f{prontype} = "ind";
        }

    }
    elsif ($pos eq "DIG") {
        $f{pos} = "noun";
        $f{numform} = "digit";
    }
    elsif ($pos eq "Rg") {
        $f{pos} = "noun";
    }
    # adjectives
    elsif($pos =~ /^(Aj)$/)
    {
        $f{pos} = "adj";
    }

    # numeral
    elsif($pos =~ /^(Nm)$/)
    {
        $f{pos} = "num";

        if ($subpos eq "NumCd") {
            $f{numtype} = "card";
        }
        elsif ($subpos eq "NumOd") {
            $f{numtype} = "ord";
        }
        elsif ($subpos eq "NumCt") {
            $f{numtype} = "gen";
        }
        elsif ($subpos eq "NumMl") {
            $f{numtype} = "mult";
        }
    }

    # v = verb
    elsif(($pos =~ /^(Vb)$/))
    {
        $f{pos} = "verb";
    }

    # adverb
    elsif($pos eq "Ad")
    {
        $f{pos} = "adv";
    }
    # postposition
    elsif($pos eq "AsPp")
    {
        $f{pos} = "prep";
    }
    elsif($pos eq "At") {
        $f{pos} = "adj";
        if ($subpos eq "AtDf") {
            $f{subpos} = "art";
            $f{definiteness} = "def";
        }
        elsif ($subpos eq "AtId") {
            $f{subpos} = "art";
            $f{definiteness} = "ind";
        }
    }

    # conjunction
    elsif($pos eq "Cj")
    {
        $f{pos} = "conj";

        if ($subpos eq "CjCo") {
            $f{subpos} = "coor";
        }
        elsif ($subpos eq "CjSb") {
            $f{subpos} = "sub";
        }
    }

    # punctuation
    elsif($pos eq "PUNCT")
    {
        $f{pos} = "punc";
    }
    elsif ($pos eq "Pt") {
        $f{pos} = "part";
    }
    elsif ($pos =~ /^(DATE|ENUM)$/) {
        $f{pos} = "noun";
    }
    elsif ($pos =~ /^(COMP|INIT|LSPLIT)$/) {
        $f{pos} = "noun";
    }

    # Decode feature values.
    my @features = split(/\|/, $features);
    foreach my $feature (@features)
    {
        # gender
        $f{gender} = "masc" if $feature eq "Ma";
        $f{gender} = "fem" if $feature eq "Fe";
        $f{gender} = "neut" if $feature eq "Ne";

        # person
        $f{person} = "1" if $feature eq "01";
        $f{person} = "2" if $feature eq "02";
        $f{person} = "3" if $feature eq "03";

        # number
        $f{number} = "sing" if $feature eq "Sg";
        $f{number} = "plu" if $feature eq "Pl";

        # case features
        $f{case} = "nom" if $feature eq "Nm";
        $f{case} = "gen" if $feature eq "Ge";
        $f{case} = "acc" if $feature eq "Ac";
        $f{case} = "voc" if $feature eq "Vo";
        $f{case} = "dat" if $feature eq "Da";

        $f{degree} = "comp" if $feature eq "Cp";
        $f{degree} = "sup" if $feature eq "Su";

        # verb features
        $f{verbform} = "inf" if $feature eq "Nf";
        $f{verbform} = "part" if $feature eq "Pp";
        $f{mood} = "ind" if $feature eq "Id";
        $f{mood} = "imp" if $feature eq "Mp";
        $f{tense} = "past" if $feature eq "Pa";
        $f{tense} = "pres" if $feature eq "Pr";

        # voice
        $f{voice} = "act" if $feature eq "Av";
        $f{voice} = "pass" if $feature eq "Pv";

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
Ad	Ad	Ba
Ad	Ad	Cp
Ad	Ad	Su
Aj	Aj	Ba|Fe|Pl|Ac
Aj	Aj	Ba|Fe|Pl|Ge
Aj	Aj	Ba|Fe|Pl|Nm
Aj	Aj	Ba|Fe|Sg|Ac
Aj	Aj	Ba|Fe|Sg|Da
Aj	Aj	Ba|Fe|Sg|Ge
Aj	Aj	Ba|Fe|Sg|Nm
Aj	Aj	Ba|Ma|Pl|Ac
Aj	Aj	Ba|Ma|Pl|Ge
Aj	Aj	Ba|Ma|Pl|Nm
Aj	Aj	Ba|Ma|Pl|Vo
Aj	Aj	Ba|Ma|Sg|Ac
Aj	Aj	Ba|Ma|Sg|Ge
Aj	Aj	Ba|Ma|Sg|Nm
Aj	Aj	Ba|Ma|Sg|Vo
Aj	Aj	Ba|Ne|Pl|Ac
Aj	Aj	Ba|Ne|Pl|Da
Aj	Aj	Ba|Ne|Pl|Ge
Aj	Aj	Ba|Ne|Pl|Nm
Aj	Aj	Ba|Ne|Sg|Ac
Aj	Aj	Ba|Ne|Sg|Da
Aj	Aj	Ba|Ne|Sg|Ge
Aj	Aj	Ba|Ne|Sg|Nm
Aj	Aj	Cp|Fe|Pl|Ac
Aj	Aj	Cp|Fe|Pl|Ge
Aj	Aj	Cp|Fe|Pl|Nm
Aj	Aj	Cp|Fe|Sg|Ac
Aj	Aj	Cp|Fe|Sg|Ge
Aj	Aj	Cp|Fe|Sg|Nm
Aj	Aj	Cp|Ma|Pl|Ac
Aj	Aj	Cp|Ma|Pl|Nm
Aj	Aj	Cp|Ma|Sg|Ac
Aj	Aj	Cp|Ma|Sg|Ge
Aj	Aj	Cp|Ma|Sg|Nm
Aj	Aj	Cp|Ne|Pl|Ac
Aj	Aj	Cp|Ne|Pl|Nm
Aj	Aj	Cp|Ne|Sg|Ac
Aj	Aj	Cp|Ne|Sg|Nm
Aj	Aj	Su|Fe|Pl|Ac
Aj	Aj	Su|Fe|Pl|Ge
Aj	Aj	Su|Fe|Pl|Nm
Aj	Aj	Su|Fe|Sg|Ac
Aj	Aj	Su|Fe|Sg|Ge
Aj	Aj	Su|Ma|Pl|Ac
Aj	Aj	Su|Ma|Pl|Ge
Aj	Aj	Su|Ma|Sg|Ac
Aj	Aj	Su|Ne|Pl|Ac
Aj	Aj	Su|Ne|Pl|Nm
Aj	Aj	Su|Ne|Sg|Ac
Aj	Aj	Su|Ne|Sg|Nm
AsPp	AsPpPa	Fe|Pl|Ac
AsPp	AsPpPa	Fe|Sg|Ac
AsPp	AsPpPa	Ma|Pl|Ac
AsPp	AsPpPa	Ma|Sg|Ac
AsPp	AsPpPa	Ne|Pl|Ac
AsPp	AsPpPa	Ne|Sg|Ac
AsPp	AsPpSp	_
At	AtDf	Fe|Pl|Ac
At	AtDf	Fe|Pl|Ge
At	AtDf	Fe|Pl|Nm
At	AtDf	Fe|Sg|Ac
At	AtDf	Fe|Sg|Ge
At	AtDf	Fe|Sg|Nm
At	AtDf	Ma|Pl|Ac
At	AtDf	Ma|Pl|Ge
At	AtDf	Ma|Pl|Nm
At	AtDf	Ma|Sg|Ac
At	AtDf	Ma|Sg|Ge
At	AtDf	Ma|Sg|Nm
At	AtDf	Ne|Pl|Ac
At	AtDf	Ne|Pl|Da
At	AtDf	Ne|Pl|Ge
At	AtDf	Ne|Pl|Nm
At	AtDf	Ne|Sg|Ac
At	AtDf	Ne|Sg|Da
At	AtDf	Ne|Sg|Ge
At	AtDf	Ne|Sg|Nm
At	AtId	Fe|Sg|Ac
At	AtId	Fe|Sg|Ge
At	AtId	Fe|Sg|Nm
At	AtId	Ma|Sg|Ac
At	AtId	Ma|Sg|Ge
At	AtId	Ma|Sg|Nm
At	AtId	Ne|Sg|Ac
At	AtId	Ne|Sg|Ge
At	AtId	Ne|Sg|Nm
COMP	COMP	_
Cj	CjCo	_
Cj	CjSb	_
DATE	DATE	_
DIG	DIG	_
ENUM	ENUM	_
INIT	INIT	_
LSPLIT	LSPLIT	_
Nm	NmCd	Fe|Pl|Ac|Aj
Nm	NmCd	Fe|Pl|Ge|Aj
Nm	NmCd	Fe|Pl|Nm|Aj
Nm	NmCd	Fe|Sg|Ac|Aj
Nm	NmCd	Fe|Sg|Nm|Aj
Nm	NmCd	Ma|Pl|Ac|Aj
Nm	NmCd	Ma|Pl|Ge|Aj
Nm	NmCd	Ma|Pl|Nm|Aj
Nm	NmCd	Ma|Sg|Ac|Aj
Nm	NmCd	Ma|Sg|Nm|Aj
Nm	NmCd	Ne|Pl|Ac|Aj
Nm	NmCd	Ne|Pl|Da|Aj
Nm	NmCd	Ne|Pl|Ge|Aj
Nm	NmCd	Ne|Pl|Nm|Aj
Nm	NmCd	Ne|Sg|Ac|Aj
Nm	NmCd	Ne|Sg|Ge|Aj
Nm	NmCd	Ne|Sg|Nm|Aj
Nm	NmCt	Fe|Pl|Ac|No
Nm	NmCt	Fe|Pl|Ge|No
Nm	NmCt	Fe|Pl|Nm|No
Nm	NmMl	Ne|Sg|Ac|Aj
Nm	NmOd	Fe|Pl|Ac|Aj
Nm	NmOd	Fe|Pl|Ge|Aj
Nm	NmOd	Fe|Pl|Nm|Aj
Nm	NmOd	Fe|Sg|Ac|Aj
Nm	NmOd	Fe|Sg|Ge|Aj
Nm	NmOd	Fe|Sg|Nm|Aj
Nm	NmOd	Ma|Pl|Ac|Aj
Nm	NmOd	Ma|Pl|Ge|Aj
Nm	NmOd	Ma|Sg|Ac|Aj
Nm	NmOd	Ma|Sg|Ge|Aj
Nm	NmOd	Ma|Sg|Nm|Aj
Nm	NmOd	Ne|Pl|Nm|Aj
Nm	NmOd	Ne|Sg|Ac|Aj
Nm	NmOd	Ne|Sg|Ge|Aj
Nm	NmOd	Ne|Sg|Nm|Aj
No	NoCm	Fe|Pl|Ac
No	NoCm	Fe|Pl|Ge
No	NoCm	Fe|Pl|Nm
No	NoCm	Fe|Pl|Vo
No	NoCm	Fe|Sg|Ac
No	NoCm	Fe|Sg|Da
No	NoCm	Fe|Sg|Ge
No	NoCm	Fe|Sg|Nm
No	NoCm	Fe|Sg|Vo
No	NoCm	Ma|Pl|Ac
No	NoCm	Ma|Pl|Ge
No	NoCm	Ma|Pl|Nm
No	NoCm	Ma|Pl|Vo
No	NoCm	Ma|Sg|Ac
No	NoCm	Ma|Sg|Da
No	NoCm	Ma|Sg|Ge
No	NoCm	Ma|Sg|Nm
No	NoCm	Ma|Sg|Vo
No	NoCm	Ne|Pl|Ac
No	NoCm	Ne|Pl|Ge
No	NoCm	Ne|Pl|Nm
No	NoCm	Ne|Sg|Ac
No	NoCm	Ne|Sg|Da
No	NoCm	Ne|Sg|Ge
No	NoCm	Ne|Sg|Nm
No	NoPr	Fe|Pl|Ac
No	NoPr	Fe|Pl|Ge
No	NoPr	Fe|Pl|Nm
No	NoPr	Fe|Sg|Ac
No	NoPr	Fe|Sg|Ge
No	NoPr	Fe|Sg|Nm
No	NoPr	Ma|Pl|Ac
No	NoPr	Ma|Pl|Ge
No	NoPr	Ma|Pl|Nm
No	NoPr	Ma|Sg|Ac
No	NoPr	Ma|Sg|Ge
No	NoPr	Ma|Sg|Nm
No	NoPr	Ma|Sg|Vo
No	NoPr	Ne|Pl|Ac
No	NoPr	Ne|Pl|Ge
No	NoPr	Ne|Sg|Ac
No	NoPr	Ne|Sg|Ge
No	NoPr	Ne|Sg|Nm
PUNCT	PUNCT	_
Pn	PnDm	Fe|03|Pl|Ac|Xx
Pn	PnDm	Fe|03|Pl|Ge|Xx
Pn	PnDm	Fe|03|Pl|Nm|Xx
Pn	PnDm	Fe|03|Sg|Ac|Xx
Pn	PnDm	Fe|03|Sg|Ge|Xx
Pn	PnDm	Fe|03|Sg|Nm|Xx
Pn	PnDm	Ma|03|Pl|Ac|Xx
Pn	PnDm	Ma|03|Pl|Ge|Xx
Pn	PnDm	Ma|03|Pl|Nm|Xx
Pn	PnDm	Ma|03|Sg|Ac|Xx
Pn	PnDm	Ma|03|Sg|Ge|Xx
Pn	PnDm	Ma|03|Sg|Nm|Xx
Pn	PnDm	Ne|03|Pl|Ac|Xx
Pn	PnDm	Ne|03|Pl|Ge|Xx
Pn	PnDm	Ne|03|Pl|Nm|Xx
Pn	PnDm	Ne|03|Sg|Ac|Xx
Pn	PnDm	Ne|03|Sg|Ge|Xx
Pn	PnDm	Ne|03|Sg|Nm|Xx
Pn	PnId	Fe|03|Pl|Ac|Xx
Pn	PnId	Fe|03|Pl|Ge|Xx
Pn	PnId	Fe|03|Pl|Nm|Xx
Pn	PnId	Fe|03|Sg|Ac|Xx
Pn	PnId	Fe|03|Sg|Ge|Xx
Pn	PnId	Fe|03|Sg|Nm|Xx
Pn	PnId	Ma|03|Pl|Ac|Xx
Pn	PnId	Ma|03|Pl|Ge|Xx
Pn	PnId	Ma|03|Pl|Nm|Xx
Pn	PnId	Ma|03|Sg|Ac|Xx
Pn	PnId	Ma|03|Sg|Ge|Xx
Pn	PnId	Ma|03|Sg|Nm|Xx
Pn	PnId	Ne|03|Pl|Ac|Xx
Pn	PnId	Ne|03|Pl|Ge|Xx
Pn	PnId	Ne|03|Pl|Nm|Xx
Pn	PnId	Ne|03|Sg|Ac|Xx
Pn	PnId	Ne|03|Sg|Ge|Xx
Pn	PnId	Ne|03|Sg|Nm|Xx
Pn	PnIr	Fe|03|Pl|Nm|Xx
Pn	PnIr	Fe|03|Sg|Ac|Xx
Pn	PnIr	Fe|03|Sg|Nm|Xx
Pn	PnIr	Ma|03|Pl|Ac|Xx
Pn	PnIr	Ma|03|Pl|Nm|Xx
Pn	PnIr	Ma|03|Sg|Ac|Xx
Pn	PnIr	Ma|03|Sg|Nm|Xx
Pn	PnIr	Ne|03|Pl|Ac|Xx
Pn	PnIr	Ne|03|Pl|Nm|Xx
Pn	PnIr	Ne|03|Sg|Ac|Xx
Pn	PnIr	Ne|03|Sg|Nm|Xx
Pn	PnPe	Fe|03|Pl|Ac|We
Pn	PnPe	Fe|03|Sg|Ac|We
Pn	PnPe	Fe|03|Sg|Ge|We
Pn	PnPe	Ma|01|Pl|Ac|St
Pn	PnPe	Ma|01|Pl|Ac|We
Pn	PnPe	Ma|01|Pl|Ge|We
Pn	PnPe	Ma|01|Pl|Nm|St
Pn	PnPe	Ma|01|Sg|Ac|St
Pn	PnPe	Ma|01|Sg|Ac|We
Pn	PnPe	Ma|01|Sg|Ge|We
Pn	PnPe	Ma|01|Sg|Nm|St
Pn	PnPe	Ma|02|Pl|Ac|St
Pn	PnPe	Ma|02|Pl|Ac|We
Pn	PnPe	Ma|02|Pl|Ge|We
Pn	PnPe	Ma|02|Pl|Nm|St
Pn	PnPe	Ma|02|Sg|Ac|We
Pn	PnPe	Ma|03|Pl|Ac|We
Pn	PnPe	Ma|03|Pl|Ge|We
Pn	PnPe	Ma|03|Sg|Ac|We
Pn	PnPe	Ma|03|Sg|Ge|We
Pn	PnPe	Ne|03|Pl|Ac|We
Pn	PnPe	Ne|03|Sg|Ac|We
Pn	PnPo	Fe|03|Sg|Ge|Xx
Pn	PnPo	Ma|01|Pl|Ge|Xx
Pn	PnPo	Ma|01|Sg|Ge|Xx
Pn	PnPo	Ma|02|Pl|Ge|Xx
Pn	PnPo	Ma|03|Pl|Ge|Xx
Pn	PnPo	Ma|03|Sg|Ge|Xx
Pn	PnRe	Fe|03|Pl|Ac|Xx
Pn	PnRe	Fe|03|Pl|Ge|Xx
Pn	PnRe	Fe|03|Pl|Nm|Xx
Pn	PnRe	Fe|03|Sg|Ac|Xx
Pn	PnRe	Fe|03|Sg|Ge|Xx
Pn	PnRe	Fe|03|Sg|Nm|Xx
Pn	PnRe	Ma|03|Pl|Ac|Xx
Pn	PnRe	Ma|03|Pl|Nm|Xx
Pn	PnRe	Ma|03|Sg|Ac|Xx
Pn	PnRe	Ma|03|Sg|Nm|Xx
Pn	PnRe	Ne|03|Pl|Ac|Xx
Pn	PnRe	Ne|03|Pl|Ge|Xx
Pn	PnRe	Ne|03|Pl|Nm|Xx
Pn	PnRe	Ne|03|Sg|Ac|Xx
Pn	PnRe	Ne|03|Sg|Ge|Xx
Pn	PnRe	Ne|03|Sg|Nm|Xx
Pn	PnRi	Fe|03|Pl|Ac|Xx
Pn	PnRi	Fe|03|Sg|Ac|Xx
Pn	PnRi	Fe|03|Sg|Ge|Xx
Pn	PnRi	Ma|03|Pl|Ac|Xx
Pn	PnRi	Ma|03|Pl|Nm|Xx
Pn	PnRi	Ma|03|Sg|Ac|Xx
Pn	PnRi	Ma|03|Sg|Nm|Xx
Pn	PnRi	Ne|03|Pl|Ac|Xx
Pn	PnRi	Ne|03|Pl|Ge|Xx
Pn	PnRi	Ne|03|Sg|Ac|Xx
Pn	PnRi	Ne|03|Sg|Nm|Xx
Pt	PtFu	_
Pt	PtNg	_
Pt	PtOt	_
Pt	PtSj	_
Rg	RgAbXx	_
Rg	RgAnXx	_
Rg	RgFwOr	_
Rg	RgFwTr	_
Vb	VbIs	Id|Pa|03|Sg|Xx|Ip|Av|Xx
Vb	VbIs	Id|Pa|03|Sg|Xx|Ip|Pv|Xx
Vb	VbIs	Id|Pa|03|Sg|Xx|Pe|Pv|Xx
Vb	VbIs	Id|Pr|03|Sg|Xx|Ip|Av|Xx
Vb	VbIs	Id|Pr|03|Sg|Xx|Ip|Pv|Xx
Vb	VbMn	Id|Pa|01|Pl|Xx|Ip|Av|Xx
Vb	VbMn	Id|Pa|01|Pl|Xx|Ip|Pv|Xx
Vb	VbMn	Id|Pa|01|Pl|Xx|Pe|Av|Xx
Vb	VbMn	Id|Pa|01|Pl|Xx|Pe|Pv|Xx
Vb	VbMn	Id|Pa|01|Sg|Xx|Ip|Av|Xx
Vb	VbMn	Id|Pa|01|Sg|Xx|Pe|Av|Xx
Vb	VbMn	Id|Pa|01|Sg|Xx|Pe|Pv|Xx
Vb	VbMn	Id|Pa|02|Pl|Xx|Ip|Av|Xx
Vb	VbMn	Id|Pa|02|Pl|Xx|Pe|Av|Xx
Vb	VbMn	Id|Pa|02|Pl|Xx|Pe|Pv|Xx
Vb	VbMn	Id|Pa|02|Sg|Xx|Pe|Pv|Xx
Vb	VbMn	Id|Pa|03|Pl|Xx|Ip|Av|Xx
Vb	VbMn	Id|Pa|03|Pl|Xx|Ip|Pv|Xx
Vb	VbMn	Id|Pa|03|Pl|Xx|Pe|Av|Xx
Vb	VbMn	Id|Pa|03|Pl|Xx|Pe|Pv|Xx
Vb	VbMn	Id|Pa|03|Sg|Xx|Ip|Av|Xx
Vb	VbMn	Id|Pa|03|Sg|Xx|Ip|Pv|Xx
Vb	VbMn	Id|Pa|03|Sg|Xx|Pe|Av|Xx
Vb	VbMn	Id|Pa|03|Sg|Xx|Pe|Pv|Xx
Vb	VbMn	Id|Pr|01|Pl|Xx|Ip|Av|Xx
Vb	VbMn	Id|Pr|01|Pl|Xx|Ip|Pv|Xx
Vb	VbMn	Id|Pr|01|Sg|Xx|Ip|Av|Xx
Vb	VbMn	Id|Pr|01|Sg|Xx|Ip|Pv|Xx
Vb	VbMn	Id|Pr|02|Pl|Xx|Ip|Av|Xx
Vb	VbMn	Id|Pr|02|Pl|Xx|Ip|Pv|Xx
Vb	VbMn	Id|Pr|02|Sg|Xx|Ip|Av|Xx
Vb	VbMn	Id|Pr|03|Pl|Xx|Ip|Av|Xx
Vb	VbMn	Id|Pr|03|Pl|Xx|Ip|Pv|Xx
Vb	VbMn	Id|Pr|03|Sg|Xx|Ip|Av|Xx
Vb	VbMn	Id|Pr|03|Sg|Xx|Ip|Pv|Xx
Vb	VbMn	Id|Xx|01|Pl|Xx|Pe|Av|Xx
Vb	VbMn	Id|Xx|01|Pl|Xx|Pe|Pv|Xx
Vb	VbMn	Id|Xx|01|Sg|Xx|Pe|Av|Xx
Vb	VbMn	Id|Xx|01|Sg|Xx|Pe|Pv|Xx
Vb	VbMn	Id|Xx|02|Pl|Xx|Pe|Av|Xx
Vb	VbMn	Id|Xx|02|Pl|Xx|Pe|Pv|Xx
Vb	VbMn	Id|Xx|03|Pl|Xx|Pe|Av|Xx
Vb	VbMn	Id|Xx|03|Pl|Xx|Pe|Pv|Xx
Vb	VbMn	Id|Xx|03|Sg|Xx|Pe|Av|Xx
Vb	VbMn	Id|Xx|03|Sg|Xx|Pe|Pv|Xx
Vb	VbMn	Mp|Xx|02|Pl|Xx|Pe|Av|Xx
Vb	VbMn	Mp|Xx|02|Pl|Xx|Pe|Pv|Xx
Vb	VbMn	Nf|Xx|Xx|Xx|Xx|Pe|Av|Xx
Vb	VbMn	Nf|Xx|Xx|Xx|Xx|Pe|Pv|Xx
Vb	VbMn	Pp|Xx|Xx|Pl|Fe|Pe|Pv|Ac
Vb	VbMn	Pp|Xx|Xx|Pl|Fe|Pe|Pv|Ge
Vb	VbMn	Pp|Xx|Xx|Pl|Fe|Pe|Pv|Nm
Vb	VbMn	Pp|Xx|Xx|Pl|Ma|Pe|Pv|Nm
Vb	VbMn	Pp|Xx|Xx|Pl|Ne|Pe|Pv|Ac
Vb	VbMn	Pp|Xx|Xx|Pl|Ne|Pe|Pv|Ge
Vb	VbMn	Pp|Xx|Xx|Pl|Ne|Pe|Pv|Nm
Vb	VbMn	Pp|Xx|Xx|Sg|Fe|Pe|Pv|Ac
Vb	VbMn	Pp|Xx|Xx|Sg|Fe|Pe|Pv|Ge
Vb	VbMn	Pp|Xx|Xx|Sg|Fe|Pe|Pv|Nm
Vb	VbMn	Pp|Xx|Xx|Sg|Ma|Pe|Pv|Nm
Vb	VbMn	Pp|Xx|Xx|Sg|Ne|Pe|Pv|Ac
Vb	VbMn	Pp|Xx|Xx|Sg|Ne|Pe|Pv|Nm
Vb	VbMn	Pp|Xx|Xx|Xx|Xx|Ip|Av|Xx
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
