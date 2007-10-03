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
    $f{tagset} = "hajic";
    $f{other} = $tag;
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
        $f{pos} = "det";
    }
    elsif($pos eq "P")
    {
        $f{pos} = "pron";
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
            if($subpos eq "F")
            {
                $f{definiteness} = "def";
            }
            elsif($subpos eq "I")
            {
                $f{definiteness} = "ind";
            }
            elsif($subpos =~ m/[HE]/)
            {
                $f{definiteness} = "wh";
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
                $f{pos} = "inf";
                $f{verbform} = "inf";
            }
        }
    } # unless $pos =~ m/[QI]/
    # degree of comparison
    # [PD] have no compdeg but there is a dummy "W" char which we need to shift
    if($pos =~ m/[ARPD]/)
    {
        my $compdeg = shift(@chars);
        if($compdeg eq "P")
        {
            $f{compdeg} = "norm";
        }
        elsif($compdeg eq "C")
        {
            $f{compdeg} = "comp";
        }
        elsif($compdeg eq "S")
        {
            $f{compdeg} = "sup";
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
            $f{subjobj} = "subj";
        }
        elsif($so eq "O")
        {
            $f{subjobj} = "obj";
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
    my $f = shift;
    my %f = %{$f}; # this is not a deep copy! We must not modify the contents!
    my $nonstrict = shift; # strict is default
    $strict = !$nonstrict;
    my $tag;
    # pos and subpos
    if($f{foreign} eq "foreign")
    {
        $tag = "XF";
    }
    elsif($f{pos} eq "noun")
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
    elsif($f{pos} eq "adj")
    {
        $tag = "AQ";
    }
    elsif($f{pos} eq "det" ||
          $f{pos} eq "pron" && $f{synpos} eq "attr" && $f{definiteness} eq "def" && $f{poss} ne "poss")
    {
        if($f{definiteness} eq "def")
        {
            $tag = "DFW";
        }
        elsif($f{definiteness} eq "ind")
        {
            $tag = "DIW";
        }
        elsif($f{definiteness} =~ m/^(wh|int|rel)$/)
        {
            $tag = "DHW";
        }
        else
        {
            $tag = "D0W";
        }
    }
    elsif($f{pos} eq "pron")
    {
        if($f{poss} eq "poss")
        {
            if($f{definiteness} =~ m/^(wh|int|rel)$/)
            {
                $tag = "PEW";
            }
            else
            {
                $tag = "PSW";
            }
        }
        elsif($f{definiteness} =~ m/^(wh|int|rel)$/)
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
        if($f{definiteness} =~ m/^(wh|int|rel)$/)
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
    elsif($f{pos} eq "inf")
    {
        $tag = "CI";
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
        $tag = "Q";
    }
    elsif($f{pos} eq "int")
    {
        $tag = "I";
    }
    elsif($f{pos} eq "punc")
    {
        $tag = "FE"; # we cannot currently generate the alternatives FI, FP
    }
    else
    {
        $tag = "XF";
    }
    # degree of comparison
    if($f{pos} =~ m/^(adj|adv)$/ && $f{verbform} ne "part")
    {
        if($f{compdeg} eq "sup")
        {
            $tag .= "S";
        }
        elsif($f{compdeg} eq "comp")
        {
            $tag .= "C";
        }
        else
        {
            $tag .= "P";
        }
    }
    if($f{pos} =~ m/^(noun|adj|det|pron|num)$/ || $f{verbform} eq "part")
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
        else
        {
            $tag .= "N";
        }
        # number
        if($f{number} eq "plu")
        {
            $tag .= "P";
        }
        else
        {
            $tag .= "S";
        }
    }
    # case
    if($f{pos} =~ m/^(noun|adj|num)$/ || $f{verbform} eq "part")
    {
        if($f{case} eq "gen")
        {
            $tag .= "G";
        }
        else
        {
            $tag .= "N";
        }
    }
    # subject / object form
    if($f{pos} eq "pron" && !($f{synpos} eq "attr" && $f{definiteness} eq "def" && $f{poss} ne "poss"))
    {
        if($f{subjobj} eq "obj" || $f{case} eq "acc")
        {
            $tag .= "O";
        }
        else
        {
            $tag .= "S";
        }
    }
    # add the next dummy "W" char
    if($f{pos} =~ m/^(noun|det|pron)$/)
    {
        $tag .= "W";
    }
    # definiteness
    if($f{pos} =~ m/^(noun|adj|num)$/ || $f{verbform} eq "part")
    {
        if($f{definiteness} eq "def")
        {
            $tag .= "D";
        }
        else
        {
            $tag .= "I";
        }
    }
    # verb features
    if($f{pos} eq "verb" && $f{verbform} ne "part")
    {
        # verbform and mood
        if($f{mood} eq "ind")
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
        elsif($f{tense} eq "past")
        {
            $tag .= "I";
        }
        else # default: present
        {
            $tag .= "P";
        }
        # voice
        if($f{voice} eq "pass")
        {
            $tag .= "S";
        }
        else # default: active
        {
            $tag .= "A";
        }
    } # verb features
    # form
    if($f{pos} =~ m/^(noun|adj|det|pron|num|verb|adv|prep|inf|conj|part)$/)
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



1;
