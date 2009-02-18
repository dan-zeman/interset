#!/usr/bin/perl
# Driver for the tagset of the Penn Treebank.
# (c) 2006 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::en::penn;
use utf8;



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = "en::penn";
    if($tag eq ".")
    {
        # sentence-final punctuation
        # examples: . ! ?
        $f{pos} = "punc";
        $f{punctype} = "peri";
    }
    elsif($tag eq ",")
    {
        # comma
        # example: ,
        $f{pos} = "punc";
        $f{punctype} = "comm";
    }
    elsif($tag eq "-LRB-")
    {
        # left bracket
        # example: -LRB- -LCB- [ {
        $f{pos} = "punc";
        $f{punctype} = "brck";
        $f{puncside} = "ini";
    }
    elsif($tag eq "-RRB-")
    {
        # right bracket
        # example: -RRB- -RCB- ] }
        $f{pos} = "punc";
        $f{punctype} = "brck";
        $f{puncside} = "fin";
    }
    elsif($tag eq "``")
    {
        # left quotation mark
        # example: ``
        $f{pos} = "punc";
        $f{punctype} = "quot";
        $f{puncside} = "ini";
    }
    elsif($tag eq "''")
    {
        # right quotation mark
        # example: ''
        $f{pos} = "punc";
        $f{punctype} = "quot";
        $f{puncside} = "fin";
    }
    elsif($tag eq ":")
    {
        # generic other punctuation
        # examples: : ; - ...
        $f{pos} = "punc";
    }
    elsif($tag eq "\$")
    {
        # currency
        # example: $ US$ C$ A$ NZ$
        $f{other} = "currency";
    }
    elsif($tag eq "\#")
    {
        # channel
        # example: #
        $f{pos} = "punc";
        $f{other} = "\#";
    }
    elsif($tag eq "CC")
    {
        # coordinating conjunction
        # examples: and, or
        $f{pos} = "conj";
        $f{subpos} = "coor";
    }
    elsif($tag eq "CD")
    {
        # cardinal number
        # examples: one, two, three
        $f{pos} = "num";
        $f{subpos} = "card";
        $f{synpos} = "attr";
        $f{definiteness} = "def";
    }
    elsif($tag eq "DT")
    {
        # determiner
        # examples: a, the, some
        $f{pos} = "adj";
        $f{subpos} = "det";
        $f{synpos} = "attr";
    }
    elsif($tag eq "EX")
    {
        # existential there
        # examples: there
        $f{pos} = "adv";
        $f{subpos} = "ex";
    }
    elsif($tag eq "FW")
    {
        # foreign word
        # examples: kašpárek
        $f{foreign} = "foreign";
    }
    elsif($tag eq "IN")
    {
        # preposition or subordinating conjunction
        # examples: in, on, because
        $f{pos} = "prep";
        # We could create array of "prep" and "conj/sub" but arrays generally complicate things and the benefit is uncertain.
    }
    elsif($tag eq "JJ")
    {
        # adjective
        # examples: good
        $f{pos} = "adj";
        $f{degree} = "pos";
    }
    elsif($tag eq "JJR")
    {
        # adjective, comparative
        # examples: better
        $f{pos} = "adj";
        $f{degree} = "comp";
    }
    elsif($tag eq "JJS")
    {
        # adjective, superlative
        # examples: best
        $f{pos} = "adj";
        $f{degree} = "sup";
    }
    elsif($tag eq "LS")
    {
        # list item marker
        # examples: 1., a), *
        $f{pos} = "punc";
        $f{subpos} = "ord";
    }
    elsif($tag eq "MD")
    {
        # modal
        # examples: can, must
        $f{pos} = "verb";
        $f{subpos} = "mod";
    }
    elsif($tag eq "NN")
    {
        # noun, singular or mass
        # examples: animal
        $f{pos} = "noun";
        $f{number} = "sing";
    }
    elsif($tag eq "NNS")
    {
        # noun, plural
        # examples: animals
        $f{pos} = "noun";
        $f{number} = "plu";
    }
    elsif($tag eq "NNP")
    {
        # proper noun, singular
        # examples: America
        $f{pos} = "noun";
        $f{subpos} = "prop";
        $f{number} = "sing";
    }
    elsif($tag eq "NNPS")
    {
        # proper noun, plural
        # examples: Americas
        $f{pos} = "noun";
        $f{subpos} = "prop";
        $f{number} = "plu";
    }
    elsif($tag eq "PDT")
    {
        # predeterminer
        # examples: "all" in "all the flowers" or "both" in "both his children"
        $f{pos} = "adj";
        $f{subpos} = "pdt";
    }
    elsif($tag eq "POS")
    {
        # possessive ending
        # examples: 's
        $f{pos} = "part";
        $f{poss} = "poss";
    }
    elsif($tag eq "PRP")
    {
        # personal pronoun
        # examples: I, you, he, she, it, we, they
        $f{pos} = "noun";
        $f{prontype} = "prs";
        $f{subpos} = "pers";
        $f{synpos} = "subst";
    }
    elsif($tag eq "PRP\$")
    {
        # possessive pronoun
        # examples: my, your, his, her, its, our, their
        $f{pos} = "adj";
        $f{prontype} = "prs";
        $f{poss} = "poss";
        $f{synpos} = "attr";
    }
    elsif($tag eq "RB")
    {
        # adverb
        # examples: here, tomorrow, easily
        $f{pos} = "adv";
    }
    elsif($tag eq "RBR")
    {
        # adverb, comparative
        # examples: more, less
        $f{pos} = "adv";
        $f{degree} = "comp";
    }
    elsif($tag eq "RBS")
    {
        # adverb, superlative
        # examples: most, least
        $f{pos} = "adv";
        $f{degree} = "sup";
    }
    elsif($tag eq "RP")
    {
        # particle
        # examples: up, on
        $f{pos} = "part";
    }
    elsif($tag eq "SYM")
    {
        # symbol
        $f{pos} = "punc";
        $f{punctype} = "symb";
    }
    elsif($tag eq "TO")
    {
        # to
        # examples: to
        $f{pos} = "part";
        $f{subpos} = "inf";
        $f{verbform} = "inf";
    }
    elsif($tag eq "UH")
    {
        # interjection
        # examples: uh
        $f{pos} = "int";
    }
    elsif($tag eq "VB")
    {
        # verb, base form
        # examples: do, go, see, walk
        $f{pos} = "verb";
        $f{verbform} = "inf";
    }
    elsif($tag eq "VBD")
    {
        # verb, past tense
        # examples: did, went, saw, walked
        $f{pos} = "verb";
        $f{verbform} = "fin";
        $f{tense} = "past";
    }
    elsif($tag eq "VBG")
    {
        # verb, gerund or present participle
        # examples: doing, going, seeing, walking
        $f{pos} = "verb";
        $f{verbform} = "part";
        $f{tense} = "pres";
        $f{aspect} = "imp";
    }
    elsif($tag eq "VBN")
    {
        # verb, past participle
        # examples: done, gone, seen, walked
        $f{pos} = "verb";
        $f{verbform} = "part";
        $f{tense} = "past";
        $f{aspect} = "perf";
    }
    elsif($tag eq "VBP")
    {
        # verb, non-3rd person singular present
        # examples: do, go, see, walk
        $f{pos} = "verb";
        $f{verbform} = "fin";
        $f{tense} = "pres";
        $f{number} = "sing";
        $f{person} = ["1", "2"];
    }
    elsif($tag eq "VBZ")
    {
        # verb, 3rd person singular present
        # examples: does, goes, sees, walks
        $f{pos} = "verb";
        $f{verbform} = "fin";
        $f{tense} = "pres";
        $f{number} = "sing";
        $f{person} = "3";
    }
    elsif($tag eq "WDT")
    {
        # wh-determiner
        # examples: which
        $f{pos} = "adj";
        $f{subpos} = "det";
        $f{synpos} = "attr";
        $f{prontype} = "int";
    }
    elsif($tag eq "WP")
    {
        # wh-pronoun
        # examples: who
        $f{pos} = "noun";
        $f{synpos} = "subst";
        $f{prontype} = "int";
    }
    elsif($tag eq "WP\$")
    {
        # possessive wh-pronoun
        # examples: whose
        $f{pos} = "adj";
        $f{poss} = "poss";
        $f{synpos} = "attr";
        $f{prontype} = "int";
    }
    elsif($tag eq "WRB")
    {
        # wh-adverb
        # examples: where, when, how
        $f{pos} = "adv";
        $f{prontype} = "int";
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
    # Map Interset word classes to Penn word classes (in particular, test pronouns only once - here).
    my $pos = $f{pos};
    if($pos =~ m/^(noun|adj)$/ && $f{prontype} ne "")
    {
        $pos = "pron";
    }
    my $tag;
    # foreign words without respect to part of speech
    if($f{foreign} eq "foreign")
    {
        $tag = "FW";
    }
    # noun: NN, NNS, NNP, NNPS
    elsif($pos eq "noun")
    {
        # special cases first, defaults last
        if($f{subpos} eq "prop")
        {
            if($f{number} eq "plu")
            {
                $tag = "NNPS";
            }
            else
            {
                $tag = "NNP";
            }
        }
        else
        {
            if($f{number} eq "plu")
            {
                $tag = "NNS";
            }
            else
            {
                $tag = "NN";
            }
        }
    }
    # adj:  JJ, JJR, JJS, PDT
    elsif($pos eq "adj")
    {
        # special cases first, defaults last
        if($f{subpos} eq "pdt")
        {
            $tag = "PDT";
        }
        elsif($f{subpos} eq "det" && $f{prontype} !~ m/^(int|rel)$/)
        {
            $tag = "DT";
        }
        elsif($f{degree} eq "comp")
        {
            $tag = "JJR";
        }
        elsif($f{degree} eq "sup")
        {
            $tag = "JJS";
        }
        else
        {
            $tag = "JJ";
        }
    }
    # pron: PRP, PRP$, WP, WP$, WDT
    elsif($pos eq "pron")
    {
        # special cases first, defaults last
        if($f{prontype} =~ m/^(rel|int)$/)
        {
            if($f{poss} eq "poss")
            {
                $tag = "WP\$";
            }
            elsif($f{pos} eq "adj")
            {
                $tag = "WDT";
            }
            else
            {
                $tag = "WP";
            }
        }
        else
        {
            if($f{poss} eq "poss")
            {
                $tag = "PRP\$";
            }
            else
            {
                $tag = "PRP";
            }
        }
    }
    # num:  CD, (WDT), (WRB), (JJ)
    elsif($f{pos} eq "num")
    {
        if($f{subpos} =~ m/^(digit|roman|card)$/)
        {
            $tag = "CD";
        }
        elsif($f{prontype} =~ m/^(rel|int)$/)
        {
            if($f{subpos} eq "mult")
            {
                $tag = "WRB";
            }
            else
            {
                $tag = "WDT";
            }
        }
        else
        {
            $tag = "JJ";
        }
    }
    # verb: VB, VBD, VBG, VBN, VBP, VBZ, MD
    elsif($f{pos} eq "verb")
    {
        # special cases first, defaults last
        if($f{subpos} eq "mod")
        {
            $tag = "MD";
        }
        elsif($f{verbform} eq "part")
        {
            if($f{tense} eq "pres")
            {
                $tag = "VBG";
            }
            else
            {
                $tag = "VBN";
            }
        }
        elsif($f{tense} eq "past")
        {
            $tag = "VBD";
        }
        elsif($f{tense} eq "pres" && $f{number} eq "sing")
        {
            if($f{person} eq "3")
            {
                $tag = "VBZ";
            }
            else
            {
                $tag = "VBP";
            }
        }
        else
        {
            $tag = "VB";
        }
    }
    # adv:  EX, RB, RBR, RBS, WRB
    elsif($f{pos} eq "adv")
    {
        # special cases first, defaults last
        if($f{subpos} eq "ex")
        {
            $tag = "EX";
        }
        elsif($f{prontype} =~ m/^(int|rel)$/)
        {
            $tag = "WRB";
        }
        elsif($f{degree} eq "comp")
        {
            $tag = "RBR";
        }
        elsif($f{degree} eq "sup")
        {
            $tag = "RBS";
        }
        else
        {
            $tag = "RB";
        }
    }
    # prep: IN, (TO)
    elsif($f{pos} eq "prep")
    {
        $tag = "IN";
    }
    # conj: CC, (IN)
    elsif($f{pos} eq "conj")
    {
        # special cases first, defaults last
        if($f{subpos} eq "sub")
        {
            $tag = "IN";
        }
        else
        {
            $tag = "CC";
        }
    }
    # part: RP, TO, POS
    elsif($f{pos} eq "part")
    {
        # special cases first, defaults last
        if($f{poss} eq "poss")
        {
            $tag = "POS";
        }
        elsif($f{verbform} eq "inf" || $f{subpos} eq "inf")
        {
            $tag = "TO";
        }
        else
        {
            $tag = "RP";
        }
    }
    # int:  UH
    elsif($f{pos} eq "int")
    {
        $tag = "UH";
    }
    # other: $, LS, SYM, #, ., ,
    elsif($f{tagset} eq "en::penn" && $f{other} eq "currency")
    {
        $tag = "\$";
    }
    elsif($f{pos} eq "punc")
    {
        if($f{subpos} eq "ord")
        {
            $tag = "LS";
        }
        elsif($f{tagset} eq "en::penn" && $f{other} eq "\#")
        {
            $tag = "\#";
        }
        elsif($f{punctype} =~ m/^(peri|qest|excl)$/)
        {
            $tag = ".";
        }
        elsif($f{punctype} eq "comm")
        {
            $tag = ",";
        }
        elsif($f{punctype} eq "brck")
        {
            if($f{puncside} eq "fin")
            {
                $tag = "-RRB-";
            }
            else
            {
                $tag = "-LRB-";
            }
        }
        elsif($f{punctype} eq "quot")
        {
            if($f{puncside} eq "fin")
            {
                $tag = "''";
            }
            else
            {
                $tag = "``";
            }
        }
        elsif($f{punctype} eq "symb")
        {
            $tag = "SYM";
        }
        else
        {
            $tag = ":";
        }
    }
    # punctuation and unknown elements
    else
    {
        $tag = "SYM";
    }
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
#
# cd /net/data/LDC/PennTreebank3/parsed/mrg/wsj
# foreach i (00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24)
#   cat $i/*.mrg >> /tmp/all.mrg
# end
# cat /tmp/all.mrg | perl -pe 's/\(([-\w]+)\s+[^\(\)]+\)/ $1 /g; s/\([-\w\*]+//g; s/[\(\)]/ /g; s/^\s+//; s/\s+$/\n/; s/\s+/\n/g;' | sort -u | wc -l
# rm /tmp/all.mrg
# 43
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
``
-LRB-
-RRB-
,
:
.
''
\$
#
CC
CD
DT
EX
FW
IN
JJ
JJR
JJS
LS
MD
NN
NNP
NNPS
NNS
PDT
POS
PRP
PRP\$
RB
RBR
RBS
RP
SYM
TO
UH
VB
VBD
VBG
VBN
VBP
VBZ
WDT
WP
WP\$
WRB
end_of_list
    ;
    my @list = split(/\r?\n/, $list);
    pop(@list) if($list[$#list] eq "");
    return \@list;
}



1;
