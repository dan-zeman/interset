#!/usr/bin/perl
# Driver for the tagset of Jan Hajič's Swedish tagger (slightly modified Parole tagset).
# (c) 2006 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::sv::hajic;
use utf8;



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = "sv::hajic";
    my @chars = split(//, $tag);
    # pos
    my $pos = shift(@chars);
    if($pos eq "N")
    {
        $f{pos} = "noun";
    }
    elsif($pos eq "A")
    {
        $f{pos} = "adj";
    }
    elsif($pos eq "D")
    {
        $f{pos} = "adj";
        $f{subpos} = "det";
    }
    elsif($pos eq "P")
    {
        $f{pos} = "noun";
    }
    elsif($pos eq "M")
    {
        $f{pos} = "num";
    }
    elsif($pos eq "V")
    {
        $f{pos} = "verb";
    }
    elsif($pos eq "R")
    {
        $f{pos} = "adv";
    }
    elsif($pos eq "S")
    {
        $f{pos} = "prep";
    }
    elsif($pos eq "C")
    {
        $f{pos} = "conj";
    }
    elsif($pos eq "Q")
    {
        $f{pos} = "part";
    }
    elsif($pos eq "I")
    {
        $f{pos} = "int";
    }
    elsif($pos eq "F")
    {
        $f{pos} = "punc";
    }
    elsif($pos eq "X")
    {
        $f{foreign} = "foreign";
    }
    # subpos
    # NC NP AF AP AQ D0 DF DH DI PF PE PH PI PS MC MO VW RG RH SP CC CI CS Q I FE FI FP XF
    # => C P F Q 0 H I E S O W G
    unless($pos =~ m/[QI]/)
    {
        my $subpos = shift(@chars);
        if($pos eq "N" && $subpos eq "P")
        {
            $f{subpos} = "prop";
        }
        elsif($pos eq "A")
        {
            if($subpos eq "F")
            {
                $f{verbform} = "part";
                $f{tense} = "past";
                $f{aspect} = "perf";
            }
            elsif($subpos eq "P")
            {
                $f{verbform} = "part";
                $f{tense} = "pres";
                $f{aspect} = "imp";
            }
        }
        elsif($pos =~ m/[DPR]/)
        {
            if($subpos =~ m/[FS]/)
            {
                $f{prontype} = "prs";
                $f{definiteness} = "def";
            }
            elsif($subpos eq "I")
            {
                $f{prontype} = "ind";
                $f{definiteness} = "ind";
            }
            elsif($subpos =~ m/[HE]/)
            {
                $f{prontype} = "int";
            }
            if($subpos =~ m/[ES]/)
            {
                $f{poss} = "poss";
            }
        }
        elsif($pos eq "M")
        {
            if($subpos eq "C")
            {
                $f{subpos} = "card";
            }
            elsif($subpos eq "O")
            {
                $f{subpos} = "ord";
            }
        }
        elsif($pos eq "C")
        {
            if($subpos eq "C")
            {
                $f{subpos} = "coor";
            }
            elsif($subpos eq "S")
            {
                $f{subpos} = "sub";
            }
            elsif($subpos eq "I")
            {
                $f{pos} = "part";
                $f{subpos} = "inf";
                $f{verbform} = "inf";
            }
        }
        elsif($pos eq "F")
        {
            if($subpos eq "E")
            {
                # menningskiljande interpunktion
                # (DZ: I don't understand Swedish but maybe: "meaning-containing punctuation"?)
                # example: .
                $f{punctype} = "peri";
            }
            elsif($subpos eq "P")
            {
                # interpunktion
                # (DZ: the original legend does not tell the difference between FI and FP. Could FP be paired punctuation?)
                # example: "
                $f{punctype} = "quot";
            }
        }
    } # unless $pos =~ m/[QI]/
    # degree of comparison
    # [PD] have no degree but there is a dummy "W" char which we need to shift
    if($pos =~ m/[ARPD]/)
    {
        my $degree = shift(@chars);
        if($degree eq "P")
        {
            $f{degree} = "pos";
        }
        elsif($degree eq "C")
        {
            $f{degree} = "comp";
        }
        elsif($degree eq "S")
        {
            $f{degree} = "sup";
        }
        elsif($degree eq "0")
        {
            $f{other} = "no degree";
        }
    }
    if($pos =~ m/[NADPM]/)
    {
        # gender
        my $gender = shift(@chars);
        if($gender eq "M")
        {
            $f{gender} = "masc";
        }
        elsif($gender eq "U")
        {
            $f{gender} = "com";
        }
        elsif($gender eq "N")
        {
            $f{gender} = "neut";
        }
        # number
        my $number = shift(@chars);
        if($number eq "S")
        {
            $f{number} = "sing";
        }
        elsif($number eq "P")
        {
            $f{number} = "plu";
        }
    }
    # case
    if($pos =~ m/[NAM]/)
    {
        my $case = shift(@chars);
        if($case eq "N")
        {
            $f{case} = "nom";
        }
        elsif($case eq "G")
        {
            $f{case} = "gen";
        }
    }
    # subject / object form
    if($pos eq "P")
    {
        my $so = shift(@chars);
        if($so eq "S")
        {
            $f{case} = "nom";
        }
        elsif($so eq "O")
        {
            $f{case} = "acc";
        }
    }
    # eat the next dummy "W" char
    if($pos =~ m/[NDP]/)
    {
        shift(@chars);
    }
    # definiteness
    if($pos =~ m/[NAM]/)
    {
        my $def = shift(@chars);
        if($def eq "D")
        {
            $f{definiteness} = "def";
        }
        elsif($def eq "I")
        {
            $f{definiteness} = "ind";
        }
    }
    # verb features
    if($pos eq "V")
    {
        # verbform and mood
        my $mood = shift(@chars);
        if($mood eq "I")
        {
            $f{verbform} = "fin";
            $f{mood} = "ind";
        }
        elsif($mood eq "M")
        {
            $f{verbform} = "fin";
            $f{mood} = "imp";
        }
        elsif($mood eq "S")
        {
            $f{verbform} = "fin";
            $f{mood} = "sub";
        }
        elsif($mood eq "N")
        {
            $f{verbform} = "inf";
        }
        # tense
        my $tense = shift(@chars);
        if($tense eq "P")
        {
            $f{tense} = "pres";
        }
        elsif($tense eq "I")
        {
            $f{tense} = "past"; # preteritum
        }
        elsif($tense eq "U")
        {
            $f{verbform} = "sup"; # supinum
        }
        # voice
        my $voice = shift(@chars);
        if($voice eq "A")
        {
            $f{voice} = "act";
        }
        elsif($voice eq "S")
        {
            $f{voice} = "pass";
        }
    } # verb features
    # form
    if($pos =~ m/[NADPMVRSCQ]/)
    {
        my $form = shift(@chars); # S ... full; C ... hyphen; A ... abbreviation
        if($form eq "A")
        {
            $f{abbr} = "abbr";
        }
        elsif($form eq "C")
        {
            $f{hyph} = "hyph";
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
    # Map Interset word classes to Swedish Parole word classes (in particular, test pronouns only once - here).
    my $pos = $f{pos};
    if($f{prontype} ne "")
    {
        if($f{pos} eq "noun")
        {
            $pos = "pron";
        }
        elsif($f{pos} eq "adj" && $f{poss} eq "poss")
        {
            $pos = "pron";
        }
        elsif($f{pos} eq "adj")
        {
            $pos = "det";
        }
    }
    if($f{pos} eq "adj" && $f{subpos} eq "det")
    {
        $pos = "det";
    }
    my $tag;
    # pos and subpos
    if($f{foreign} eq "foreign")
    {
        $tag = "XF";
    }
    elsif($pos eq "noun")
    {
        if($f{subpos} eq "prop")
        {
            $tag = "NP";
        }
        else
        {
            $tag = "NC";
        }
    }
    elsif($f{verbform} eq "part")
    {
        if($f{tense} eq "pres" || $f{aspect} eq "imp")
        {
            $tag = "AP0";
        }
        else
        {
            $tag = "AF0";
        }
    }
    elsif($pos eq "adj")
    {
        $tag = "AQ";
    }
    elsif($pos eq "det")
    {
        if($f{definiteness} eq "def")
        {
            $tag = "DFW";
        }
        elsif($f{definiteness} eq "ind")
        {
            $tag = "DIW";
        }
        elsif($f{prontype} =~ m/^(int|rel)$/)
        {
            $tag = "DHW";
        }
        else
        {
            $tag = "D0W";
        }
    }
    elsif($pos eq "pron")
    {
        if($f{poss} eq "poss")
        {
            if($f{prontype} =~ m/^(int|rel)$/)
            {
                $tag = "PEW";
            }
            else
            {
                $tag = "PSW";
            }
        }
        elsif($f{prontype} =~ m/^(int|rel)$/)
        {
            $tag = "PHW";
        }
        elsif($f{definiteness} eq "def")
        {
            $tag = "PFW";
        }
        else
        {
            $tag = "PIW";
        }
    }
    elsif($f{pos} eq "num")
    {
        if($f{subpos} =~ m/^(digit|roman|card)$/)
        {
            $tag = "MC";
        }
        elsif($f{subpos} eq "ord")
        {
            $tag = "MO";
        }
        elsif($f{synpos} eq "subst")
        {
            $tag = "NC";
        }
        elsif($f{synpos} eq "adv")
        {
            $tag = "RG";
        }
        else
        {
            $tag = "AQ";
        }
    }
    elsif($f{pos} eq "verb")
    {
        $tag = "VW";
    }
    elsif($f{pos} eq "adv")
    {
        if($f{prontype} =~ m/^(int|rel)$/)
        {
            $tag = "RH";
        }
        else
        {
            $tag = "RG";
        }
    }
    elsif($f{pos} eq "prep")
    {
        $tag = "SP";
    }
    elsif($f{pos} eq "conj")
    {
        if($f{verbform} eq "inf")
        {
            $tag = "CI";
        }
        elsif($f{subpos} eq "sub")
        {
            $tag = "CS";
        }
        else
        {
            $tag = "CC";
        }
    }
    elsif($f{pos} eq "part")
    {
        if($f{subpos} eq "inf" || $f{verbform} eq "inf")
        {
            $tag = "CI";
        }
        else
        {
            $tag = "Q";
        }
    }
    elsif($f{pos} eq "int")
    {
        $tag = "I";
    }
    elsif($f{pos} eq "punc")
    {
        if($f{punctype} eq "peri")
        {
            $tag = "FE";
        }
        elsif($f{punctype} eq "quot")
        {
            $tag = "FP";
        }
        else
        {
            $tag = "FI";
        }
    }
    else
    {
        $tag = "XF";
    }
    # degree of comparison
    if($pos =~ m/^(adj|adv)$/ && $f{verbform} ne "part" && $f{subpos} ne "det")
    {
        if($f{tagset} eq "sv::hajic" && $f{other} eq "no degree" ||
           $f{abbr} eq "abbr" ||
           $f{pos} eq "adv" && $f{prontype} =~ m/^(int|rel)$/)
        {
            $tag .= "0";
        }
        elsif($f{degree} eq "sup")
        {
            $tag .= "S";
        }
        elsif($f{degree} eq "comp")
        {
            $tag .= "C";
        }
        else
        {
            $tag .= "P";
        }
    }
    if($pos =~ m/^(noun|adj|pron|det|num)$/ || $f{verbform} eq "part")
    {
        # gender
        if($f{gender} eq "masc")
        {
            $tag .= "M";
        }
        elsif($f{gender} =~ m/^(fem|com)$/)
        {
            $tag .= "U";
        }
        elsif($f{gender} eq "neut")
        {
            $tag .= "N";
        }
        else
        {
            $tag .= "0";
        }
        # number
        if($f{number} eq "plu")
        {
            $tag .= "P";
        }
        elsif($f{number} eq "sing")
        {
            $tag .= "S";
        }
        else
        {
            $tag .= "0";
        }
    }
    # case
    if($pos =~ m/^(noun|adj|num)$/ && $f{subpos} ne "det" || $f{verbform} eq "part")
    {
        if($f{case} eq "gen")
        {
            $tag .= "G";
        }
        elsif($f{case} eq "nom")
        {
            $tag .= "N";
        }
        else
        {
            $tag .= "0";
        }
    }
    # subject / object form
    if($pos eq "pron" && !($f{synpos} eq "attr" && $f{definiteness} eq "def" && $f{poss} ne "poss"))
    {
        if($f{case} eq "acc")
        {
            $tag .= "O";
        }
        elsif($f{case} eq "nom")
        {
            $tag .= "S";
        }
        else
        {
            $tag .= "0";
        }
    }
    # add the next dummy "W" char
    if($pos =~ m/^(noun|pron)$/ || $f{pos} eq "adj" && $f{subpos} eq "det")
    {
        $tag .= "W";
    }
    # definiteness
    if($pos =~ m/^(noun|adj|num)$/ && $f{subpos} ne "det" || $f{verbform} eq "part")
    {
        if($f{definiteness} eq "def")
        {
            $tag .= "D";
        }
        elsif($f{definiteness} eq "ind")
        {
            $tag .= "I";
        }
        else
        {
            $tag .= "0";
        }
    }
    # verb features
    if($pos eq "verb" && $f{verbform} ne "part")
    {
        # verbform and mood
        if($f{abbr} eq "abbr" || $f{hyph} eq "hyph")
        {
            $tag .= "0";
        }
        elsif($f{mood} eq "ind")
        {
            $tag .= "I";
        }
        elsif($f{mood} eq "imp")
        {
            $tag .= "M";
        }
        elsif($f{mood} eq "sub")
        {
            $tag .= "S";
        }
        else # default: infinitive
        {
            $tag .= "N";
        }
        # tense
        if($f{verbform} eq "sup")
        {
            $tag .= "U";
        }
        elsif($f{verbform} eq "inf" || $f{mood} eq "imp" || $f{abbr} eq "abbr" || $f{hyph} eq "hyph")
        {
            $tag .= "0";
        }
        elsif($f{tense} eq "past")
        {
            $tag .= "I";
        }
        else # default: present
        {
            $tag .= "P";
        }
        # voice
        if($f{abbr} eq "abbr" || $f{hyph} eq "hyph")
        {
            $tag .= "0";
        }
        elsif($f{voice} eq "pass")
        {
            $tag .= "S";
        }
        else # default: active
        {
            $tag .= "A";
        }
    } # verb features
    # form
    if($pos =~ m/^(noun|adj|pron|det|num|verb|adv|prep|conj|part)$/)
    {
        if($f{abbr} eq "abbr")
        {
            $tag .= "A";
        }
        elsif($f{hyph} eq "hyph")
        {
            $tag .= "C";
        }
        else # default: standard form
        {
            $tag .= "S";
        }
    }
    # fill with dashes to the length of 9
    while(length($tag)<9)
    {
        $tag .= "-";
    }
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# The source list is the Parole tag set of the Swedish SUC corpus.
# http://spraakbanken.gu.se/parole/tags.phtml
# Modifications by Jan Hajič:
# - replace @ by W
# - add trailing dashes so every tag has 9 characters
# total tags:
# 156
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
NC000\@0A
NC000\@0C
NC000\@0S
NCN00\@0C
NCN00\@0S
NCNPG\@DS
NCNPG\@IS
NCNPN\@DS
NCNPN\@IS
NCNSG\@DS
NCNSG\@IS
NCNSN\@DS
NCNSN\@IS
NCU00\@0C
NCU00\@0S
NCUPG\@DS
NCUPG\@IS
NCUPN\@DS
NCUPN\@IS
NCUSG\@DS
NCUSG\@IS
NCUSN\@DS
NCUSN\@IS
NP000\@0C
NP00G\@0S
NP00N\@0S
AF00000A
AF00PG0S
AF00PN0S
AF00SGDS
AF00SNDS
AF0MSGDS
AF0MSNDS
AF0NSNIS
AF0USGIS
AF0USNIS
AP000G0S
AP000N0S
AQ00000A
AQC0000C
AQC00G0S
AQC00N0S
AQP0000C
AQP00N0S
AQP00NIS
AQP0PG0S
AQP0PN0S
AQP0PNIS
AQP0SGDS
AQP0SNDS
AQPMSGDS
AQPMSNDS
AQPNSGIS
AQPNSN0S
AQPNSNIS
AQPU000C
AQPUSGIS
AQPUSN0S
AQPUSNIS
AQS00NDS
AQS00NIS
AQS0PNDS
AQS0PNIS
AQSMSGDS
AQSMSNDS
D0\@00\@A
D0\@0P\@S
D0\@NS\@S
D0\@US\@S
DF\@0P\@S
DF\@0S\@S
DF\@MS\@S
DF\@NS\@S
DF\@US\@S
DH\@0P\@S
DH\@NS\@S
DH\@US\@S
DI\@00\@S
DI\@0P\@S
DI\@0S\@S
DI\@MS\@S
DI\@NS\@S
DI\@US\@S
PF\@00O\@S
PF\@0P0\@S
PF\@0PO\@S
PF\@0PS\@S
PF\@MS0\@S
PF\@NS0\@S
PF\@UPO\@S
PF\@UPS\@S
PF\@US0\@S
PF\@USO\@S
PF\@USS\@S
PE\@000\@S
PH\@000\@S
PH\@0P0\@S
PH\@NS0\@C
PH\@NS0\@S
PH\@US0\@S
PI\@0P0\@S
PI\@NS0\@S
PI\@US0\@S
PI\@USS\@S
PS\@000\@A
PS\@000\@S
PS\@0P0\@S
PS\@NS0\@S
PS\@US0\@S
MC0000C
MC00G0S
MC00N0S
MC0SNDS
MCMSGDS
MCMSNDS
MCNSNIS
MCUSNIS
MO0000C
MO00G0S
MO00N0S
MOMSNDS
V\@000A
V\@000C
V\@IIAS
V\@IISS
V\@IPAS
V\@IPSS
V\@IUAS
V\@IUSS
V\@M0AS
V\@M0SS
V\@N0AS
V\@N0SS
V\@SIAS
V\@SISS
V\@SPAS
RG0A
RG0C
RG0S
RGCS
RGPS
RGSS
RH0S
SPC
SPS
CCA
CCS
CIS
CSS
QC
QS
I
FE
FI
FP
XF
end_of_list
    ;
    my @list = split(/\r?\n/, $list);
    pop(@list) if($list[$#list] eq "");
    # Convert Parole tags to Hajič.
    @list = map {s/\@/W/g; for(my $i = length($_)+1; $i<=9; $i++) {$_ .= "-"} $_} @list;
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
    $permitted = tagset::common::get_permitted_structures_joint(list(), \&decode); 
}



1;
