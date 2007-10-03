#!/usr/bin/perl
# Driver for the Swedish MAMBA tagset (Talbanken).
# (c) 2006 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::sv::mamba;
use utf8;



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = "svmamba";
    $f{other} = $tag;
    # ++ Coordinating conjunction
    if($tag eq "++")
    {
        $f{pos} = "conj";
        $f{subpos} = "coor";
    }
    # AB Adverb
    elsif($tag eq "AB")
    {
        $f{pos} = "adv";
    }
    # AJ Adjective
    elsif($tag eq "AJ")
    {
        $f{pos} = "adj";
    }
    # AN Adjectival noun
    elsif($tag eq "AN")
    {
        $f{pos} = "noun";
        $f{synpos} = "attr";
    }
    # AV The verb "vara" (be)
    elsif($tag eq "AV")
    {
        $f{pos} = "verb";
        $f{other} = "vara";
    }
    # BV The verb "bli(va)" (become)
    elsif($tag eq "BV")
    {
        $f{pos} = "verb";
        $f{other} = "bliva";
    }
    # EN Indefinite article or numeral "en", "ett" (one)
    elsif($tag eq "EN")
    {
        $f{pos} = "det";
        $f{synpos} = "attr";
        $f{definiteness} = "ind";
    }
    # FV The verb "faa" (get)
    elsif($tag eq "FV")
    {
        $f{pos} = "verb";
        $f{other} = "faa";
    }
    # GV The verb "göra" (do, make)
    elsif($tag eq "GV")
    {
        $f{pos} = "verb";
        $f{other} = "göra";
    }
    # HV The verb "ha(va)" (have)
    elsif($tag eq "HV")
    {
        $f{pos} = "verb";
        $f{other} = "hava";
    }
    # I? Question mark
    elsif($tag eq "I?")
    {
        $f{pos} = "punc";
        $f{other} = "question";
    }
    # IC Quotation mark
    elsif($tag eq "IC")
    {
        $f{pos} = "punc";
        $f{other} = "quotation";
    }
    # ID Part of idiom (multi-word unit)
    elsif($tag eq "ID")
    {
        $f{hyph} = "hyph";
    }
    # IG Other punctuation mark
    elsif($tag eq "IG")
    {
        $f{pos} = "punc";
        $f{other} = "other";
    }
    # IK Comma
    elsif($tag eq "IK")
    {
        $f{pos} = "punc";
        $f{other} = "comma";
    }
    # IM Infinitive marker
    elsif($tag eq "IM")
    {
        $f{pos} = "conj";
        $f{verbform} = "inf";
    }
    # IP Period
    elsif($tag eq "IP")
    {
        $f{pos} = "punc";
        $f{other} = "period";
    }
    # IQ Colon
    elsif($tag eq "IQ")
    {
        $f{pos} = "punc";
        $f{other} = "colon";
    }
    # IR Parenthesis
    elsif($tag eq "IR")
    {
        $f{pos} = "punc";
        $f{other} = "parenthesis";
    }
    # IS Semicolon
    elsif($tag eq "IS")
    {
        $f{pos} = "punc";
        $f{other} = "semicolon";
    }
    # IT Dash
    elsif($tag eq "IT")
    {
        $f{pos} = "punc";
        $f{other} = "dash";
    }
    # IU Exclamation mark
    elsif($tag eq "IU")
    {
        $f{pos} = "punc";
        $f{other} = "exclamation";
    }
    # KV The verb "komma att" (periphrastic future)
    elsif($tag eq "KV")
    {
        $f{pos} = "verb";
        $f{other} = "komma";
    }
    # MN Adversative
    elsif($tag eq "MN")
    {
        $f{pos} = "conj";
        $f{subpos} = "coor";
        $f{other} = "adversative";
    }
    # MV The verb "maaste" (must)
    elsif($tag eq "MV")
    {
        $f{pos} = "verb";
        $f{other} = "maaste";
    }
    # NN Other noun
    elsif($tag eq "NN")
    {
        $f{pos} = "noun";
    }
    # PN Proper name
    elsif($tag eq "PN")
    {
        $f{pos} = "noun";
        $f{subpos} = "prop";
    }
    # PO Pronoun
    elsif($tag eq "PO")
    {
        $f{pos} = "pron";
    }
    # PR Preposition
    elsif($tag eq "PR")
    {
        $f{pos} = "prep";
    }
    # PU Pause
    elsif($tag eq "PU")
    {
        $f{pos} = "int";
        $f{other} = "pause";
    }
    # QV The verb "kunna" (can)
    elsif($tag eq "QV")
    {
        $f{pos} = "verb";
        $f{other} = "kunna";
    }
    # RO Numeral other than "en", "ett" (one)
    elsif($tag eq "RO")
    {
        $f{pos} = "num";
    }
    # SP Present participle
    elsif($tag eq "SP")
    {
        $f{pos} = "verb";
        $f{verbform} = "part";
        $f{tense} = "pres";
    }
    # SV The verb "skola" (will, shall)
    elsif($tag eq "SV")
    {
        $f{pos} = "verb";
        $f{other} = "skola";
    }
    # TP Totality pronoun
    elsif($tag eq "TP")
    {
        $f{pos} = "pron";
        $f{definiteness} = "col";
    }
    # UK Subordinating conjunction
    elsif($tag eq "UK")
    {
        $f{pos} = "conj";
        $f{subpos} = "sub";
    }
    # VN Verbal noun
    elsif($tag eq "VN")
    {
        $f{pos} = "noun";
        $f{verbform} = "ger";
    }
    # VV Other verb
    elsif($tag eq "VV")
    {
        $f{pos} = "verb";
    }
    # WV The verb "vilja" (want)
    elsif($tag eq "WV")
    {
        $f{pos} = "verb";
        $f{other} = "vilja";
    }
    # XX Unclassifiable part-of-speech
    elsif($tag eq "XX")
    {
        # nothing to do
    }
    # YY Interjection
    elsif($tag eq "YY")
    {
        $f{pos} = "int";
    }
    # EH Filled pause
    elsif($tag eq "EH")
    {
        $f{pos} = "int";
    }
    # RJ Juncture - straight
    elsif($tag eq "RJ")
    {
        $f{pos} = "int";
    }
    # UJ Juncture - rise
    elsif($tag eq "UJ")
    {
        $f{pos} = "int";
    }
    # NJ Juncture - fall
    elsif($tag eq "NJ")
    {
        $f{pos} = "int";
    }
    # QQ Dummy for final omission
    elsif($tag eq "QQ")
    {
        # nothing to do
    }
    # UU Exclamative or optative
    elsif($tag eq "UU")
    {
        # ???
    }
    # TT Vocative
    elsif($tag eq "TT")
    {
        # ???
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
    # Noun: AN NN PN VN
    if($f{pos} eq "noun")
    {
        if($f{synpos} eq "attr")
        {
            $tag = "AN";
        }
        elsif($f{verbform} eq "ger")
        {
            $tag = "VN";
        }
        elsif($f{subpos} eq "prop")
        {
            $tag = "PN";
        }
        else
        {
            $tag = "NN";
        }
    }
    # Adjective: AJ
    elsif($f{pos} eq "adj")
    {
        $tag = "AJ";
    }
    # Determiner: EN
    elsif($f{pos} eq "det")
    {
        if($f{definiteness} eq "ind")
        {
            $tag = "EN";
        }
        else
        {
            $tag = "AJ";
        }
    }
    # Pronoun: PO TP
    elsif($f{pos} eq "pron")
    {
        if($f{definiteness} eq "col")
        {
            $tag = "TP";
        }
        else
        {
            $tag = "PO";
        }
    }
    # Numeral: RO
    elsif($f{pos} eq "num")
    {
        $tag = "RO";
    }
    # Verb: AV BV FV GV HV KV MV QV SP SV VV WV
    elsif($f{pos} eq "verb")
    {
        if($f{verbform} eq "part" && $f{tense} eq "pres")
        {
            $tag = "SP";
        }
        else
        {
            $tag = "VV";
        }
        if($f{tagset} eq "svmamba")
        {
            if($f{other} eq "vara")
            {
                $tag = "AV";
            }
            elsif($f{other} eq "bliva")
            {
                $tag = "BV";
            }
            elsif($f{other} eq "faa")
            {
                $tag = "FV";
            }
            elsif($f{other} eq "göra")
            {
                $tag = "GV";
            }
            elsif($f{other} eq "hava")
            {
                $tag = "HV";
            }
            elsif($f{other} eq "komma")
            {
                $tag = "KV";
            }
            elsif($f{other} eq "maaste")
            {
                $tag = "MV";
            }
            elsif($f{other} eq "kunna")
            {
                $tag = "QV";
            }
            elsif($f{other} eq "skola")
            {
                $tag = "SV";
            }
            elsif($f{other} eq "vilja")
            {
                $tag = "WV";
            }
        }
    }
    # Adverb: AB
    elsif($f{pos} eq "adv")
    {
        $tag = "AB";
    }
    # Preposition: PR
    elsif($f{pos} eq "prep")
    {
        $tag = "PR";
    }
    # Conjunction: ++ IM MN UK
    elsif($f{pos} eq "conj")
    {
        if($f{verbform} eq "inf")
        {
            $tag = "IM";
        }
        elsif($f{subpos} eq "sub")
        {
            $tag = "UK";
        }
        else
        {
            $tag = "++";
            if($f{tagset} eq "svmamba" && $f{other} eq "adversative")
            {
                $tag = "MN";
            }
        }
    }
    # Interjection: PU YY EH RJ UJ NJ
    elsif($f{pos} eq "int")
    {
        $tag = "YY";
        if($f{tagset} eq "svmamba")
        {
            if($f{other} eq "pause")
            {
                $tag = "PU";
            }
        }
    }
    # Punctuation: I? IC IG IK IP IQ IR IS IT IU
    elsif($f{pos} eq "punc")
    {
        $tag = "IG";
        if($f{tagset} eq "svmamba")
        {
            if($f{other} eq "question")
            {
                $tag = "I?";
            }
            elsif($f{other} eq "quotation")
            {
                $tag = "IC";
            }
            elsif($f{other} eq "comma")
            {
                $tag = "IK";
            }
            elsif($f{other} eq "period")
            {
                $tag = "IP";
            }
            elsif($f{other} eq "colon")
            {
                $tag = "IQ";
            }
            elsif($f{other} eq "parenthesis")
            {
                $tag = "IR";
            }
            elsif($f{other} eq "semicolon")
            {
                $tag = "IS";
            }
            elsif($f{other} eq "dash")
            {
                $tag = "IT";
            }
            elsif($f{other} eq "exclamation")
            {
                $tag = "IU";
            }
        }
    }
    # Unknown: ID XX QQ UU TT
    elsif($f{hyph} eq "hyph")
    {
        $tag = "ID";
    }
    else
    {
        $tag = "XX";
    }
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
#
# cat otrain.conll etest.conll | perl -pe '@x = split(/\s+/, $_); $_ = "$x[3]\n"' | sort -u | wc -l
# 42
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
++
AB
AJ
AN
AV
BV
EN
FV
GV
HV
I?
IC
ID
IG
IK
IM
IP
IQ
IR
IS
IT
IU
KV
MN
MV
NN
PN
PO
PR
PU
QV
RO
SP
SV
TP
UK
VN
VV
WV
XX
YY
end_of_list
    ;
    my @list = split(/\r?\n/, $list);
    pop(@list) if($list[$#list] eq "");
    return \@list;
}



1;
