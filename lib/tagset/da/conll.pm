#!/usr/bin/perl
# Driver for the Danish tagset from CoNLL-06 shared task (derived from Danish Parole tagset).
# (c) 2006 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::da::conll;
use utf8;



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = "da::conll";
    # three components: coarse-grained pos, fine-grained pos, features
    # example: N\tNC\tgender=neuter|number=sing|case=unmarked|def=indef
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    # pos: N A P V RG SP C U I X
    if($pos eq "N")
    {
        $f{pos} = "noun";
        if($subpos eq "NP")
        {
            $f{subpos} = "prop";
        }
    }
    elsif($pos eq "A")
    {
        # numerals are encoded as adjectives
        if($subpos eq "AC")
        {
            $f{pos} = "num";
            $f{subpos} = "card";
            $f{synpos} = "attr";
        }
        elsif($subpos eq "AO")
        {
            $f{pos} = "num";
            $f{subpos} = "ord";
            $f{synpos} = "attr";
        }
        else
        {
            $f{pos} = "adj";
        }
    }
    elsif($pos eq "P")
    {
        # PP = personal
        if($subpos eq "PP")
        {
            $f{pos} = "noun";
            $f{prontype} = "prs";
            $f{subpos} = "pers";
            $f{synpos} = "subst";
        }
        # PO = possessive
        elsif($subpos eq "PO")
        {
            $f{pos} = "adj";
            $f{prontype} = "prs";
            $f{poss} = "poss";
            $f{synpos} = "attr";
        }
        # PC = reciprocal
        elsif($subpos eq "PC")
        {
            $f{pos} = "noun";
            $f{prontype} = "rcp";
            $f{synpos} = "subst";
        }
        # PD = demonstrative
        elsif($subpos eq "PD")
        {
            $f{pos} = "adj";
            $f{prontype} = "dem";
            $f{synpos} = "attr";
            $f{definiteness} = "def";
        }
        # PI = indefinite
        elsif($subpos eq "PI")
        {
            $f{pos} = "noun";
            $f{prontype} = "ind";
            $f{synpos} = "attr";
            $f{definiteness} = "ind";
        }
        # PT = interrogative / relative
        elsif($subpos eq "PT")
        {
            $f{pos} = "noun";
            $f{prontype} = "int";
        }
    }
    elsif($pos eq "V")
    {
        $f{pos} = "verb";
        # A = main verb
        # E = medial verb
        #     - deponent verb
        #     - reciprocal verb
        #     (medial verbs are passive in form and active in meaning)
        if($subpos eq "VE")
        {
            $f{other} = "medial";
        }
    }
    elsif($pos eq "RG")
    {
        $f{pos} = "adv";
    }
    elsif($pos eq "SP")
    {
        $f{pos} = "prep";
    }
    elsif($pos eq "C")
    {
        $f{pos} = "conj";
        # CC coordinating
        if($subpos eq "CC")
        {
            $f{subpos} = "coor";
        }
        # CS subordinating
        elsif($subpos eq "CS")
        {
            $f{subpos} = "sub";
        }
    }
    elsif($pos eq "U")
    {
        # U = unique
        # ... infinitivmarkøren "at"
        # ... "som"
        # ... "der"
        # We cannot distinguish those three without seeing the actual word.
        # Since infinitive is the most important and most frequent of them, we
        # will choose infinitive.
        $f{pos} = "part";
        $f{subpos} = "inf";
    }
    elsif($pos eq "I")
    {
        $f{pos} = "int";
    }
    elsif($pos eq "X")
    {
        # X = residual
        if($subpos eq "XA")
        {
            $f{abbr} = "abbr";
        }
        elsif($subpos eq "XF")
        {
            $f{foreign} = "foreign";
        }
        elsif($subpos eq "XP")
        {
            $f{pos} = "punc";
        }
        elsif($subpos eq "XS")
        {
            # symbol, e.g. "+"
            $f{pos} = "punc";
            $f{other} = "symbol";
        }
        elsif($subpos eq "XR")
        {
            # formulae, e.g. "U-21"
            # nothing to do - same as other
            $f{other} = "formula";
        }
        elsif($subpos eq "XX")
        {
            # other
            # nothing to do
        }
    }
    my @features = split(/\|/, $features);
    foreach my $feature (@features)
    {
        my $value;
        if($feature =~ m/(.*)=(.*)/)
        {
            $feature = $1;
            $value = $2;
        }
        # transcat = adject|adject/adverb/unmarked|adverb|adverbial|unmarked
        # Transcat applies to adjectives and verbs.
        if($feature eq "transcat")
        {
            if($value eq "adject")
            {
                $f{synpos} = "attr";
            }
            elsif($value =~ m/^adverb(ial)?$/)
            {
                $f{synpos} = "adv";
            }
        }
        # gender = common|common/neuter|neuter
        elsif($feature eq "gender")
        {
            if($value eq "common")
            {
                $f{gender} = "com";
            }
            elsif($value eq "neuter")
            {
                $f{gender} = "neut";
            }
        }
        # number = plur|sing|sing/plur
        elsif($feature eq "number")
        {
            if($value eq "sing")
            {
                $f{number} = "sing";
            }
            elsif($value eq "plur")
            {
                $f{number} = "plu";
            }
        }
        # case = gen|nom|unmarked
        elsif($feature eq "case")
        {
            if($value eq "nom")
            {
                $f{case} = "nom";
            }
            elsif($value eq "gen")
            {
                $f{case} = "gen";
            }
        }
        # def = def|def/indef|indef
        # definiteness = def|def/indef|indef
        elsif($feature =~ m/^def(initeness)?$/)
        {
            if($value eq "def")
            {
                $f{definiteness} = "def";
            }
            elsif($value eq "indef")
            {
                $f{definiteness} = "ind";
            }
        }
        # degree = abs|comp|pos|sup|unmarked
        elsif($feature eq "degree")
        {
            if($value eq "pos")
            {
                $f{degree} = "pos";
            }
            elsif($value eq "comp")
            {
                $f{degree} = "comp";
            }
            elsif($value eq "sup")
            {
                $f{degree} = "sup";
            }
            elsif($value eq "abs")
            {
                $f{degree} = "abs";
            }
        }
        # reflexive = no|yes|yes/no
        elsif($feature eq "reflexive")
        {
            if($value eq "yes")
            {
                $f{reflex} = "reflex";
            }
        }
        # register = formal|obsolete|polite|unmarked
        elsif($feature eq "register")
        {
            if($value eq "polite")
            {
                $f{politeness} = "pol";
            }
            elsif($value eq "formal")
            {
                $f{style} = "form";
            }
            elsif($value eq "obsolete")
            {
                $f{style} = "arch";
            }
        }
        # person = 1|2|3
        elsif($feature eq "person" && $value>=1 && $value<=3)
        {
            $f{person} = $value;
        }
        # possessor = plur|sing|sing/plur
        elsif($feature eq "possessor")
        {
            if($value eq "sing")
            {
                $f{possnumber} = "sing";
            }
            elsif($value eq "plur")
            {
                $f{possnumber} = "plu";
            }
        }
        # mood = gerund|imper|indic|infin|partic
        elsif($feature eq "mood")
        {
            if($value eq "indic")
            {
                $f{verbform} = "fin";
                $f{mood} = "ind";
            }
            elsif($value eq "imper")
            {
                $f{verbform} = "fin";
                $f{mood} = "imp";
            }
            elsif($value eq "infin")
            {
                $f{verbform} = "inf";
            }
            elsif($value eq "partic")
            {
                $f{verbform} = "part";
            }
            elsif($value eq "gerund")
            {
                $f{verbform} = "ger";
            }
        }
        # tense = past|present
        elsif($feature eq "tense")
        {
            if($value eq "past")
            {
                $f{tense} = "past";
            }
            elsif($value eq "present")
            {
                $f{tense} = "pres";
            }
        }
        # voice = active|passive
        elsif($feature eq "voice")
        {
            if($value eq "active")
            {
                $f{voice} = "act";
            }
            elsif($value eq "passive")
            {
                $f{voice} = "pass";
            }
        }
    }
    # some pronoun forms can be declared accusative/oblique case
    if($f{pos} eq "pron" && $f{subpos} eq "pers" &&
       !($f{person}==3 && $f{number} eq "sing" && $f{gender} =~ m/^(com|neut)$/) &&
       $f{case} eq "")
    {
        $f{case} = "acc";
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
    # Map Interset word classes to Danish Parole word classes (in particular, test pronouns only once - here).
    my $pos = $f{pos};
    if($pos =~ m/^(noun|adj)$/ && $f{prontype} ne "")
    {
        $pos = "pron";
    }
    my $tag;
    # pos and subpos
    if($f{foreign} eq "foreign")
    {
        $tag = "X\tXF";
    }
    elsif($f{abbr} eq "abbr")
    {
        $tag = "X\tXA";
    }
    elsif($pos eq "noun")
    {
        # NC = common noun
        # NP = proper noun
        if($f{subpos} eq "prop")
        {
            $tag = "N\tNP";
        }
        else
        {
            $tag = "N\tNC";
        }
    }
    elsif($pos eq "adj")
    {
        # AN = normal adjective
        # AC = cardinal number
        # AO = ordinal number
        $tag = "A\tAN";
    }
    elsif($pos eq "pron")
    {
        # PP = personal pronoun
        # PO = possessive pronoun
        # PC = reciprocal pronoun
        # PD = demonstrative pronoun
        # PI = indefinite pronoun
        # PT = interrogative or relative pronoun
        if($f{poss} eq "poss")
        {
            $tag = "P\tPO";
        }
        elsif($f{prontype} eq "prs")
        {
            $tag = "P\tPP";
        }
        elsif($f{prontype} eq "rcp")
        {
            $tag = "P\tPC";
        }
        elsif($f{prontype} =~ m/^(int|rel)$/)
        {
            $tag = "P\tPT";
        }
        elsif($f{prontype} eq "dem")
        {
            $tag = "P\tPD";
        }
        else
        {
            $tag = "P\tPI";
        }
    }
    elsif($f{pos} eq "num")
    {
        # numerals do not have their own code
        if($f{subpos} =~ m/^(digit|roman|card)$/)
        {
            $tag = "A\tAC";
        }
        elsif($f{subpos} eq "ord")
        {
            $tag = "A\tAO";
        }
        elsif($f{synpos} eq "subst")
        {
            $tag = "N\tNC";
        }
        elsif($f{synpos} eq "adv")
        {
            $tag = "RG\tRG";
        }
        else
        {
            $tag = "A\tAN";
        }
    }
    elsif($f{pos} eq "verb")
    {
        # VA = main verb
        # VE = medial verb
        if($f{tagset} eq "da::conll" && $f{other} eq "medial" ||
           $f{verbform} eq "part" && $f{tense} eq "past" && $f{number} !~ m/^(sing|plu)$/)
        {
            $tag = "V\tVE";
        }
        else
        {
            $tag = "V\tVA";
        }
    }
    elsif($f{pos} eq "adv")
    {
        $tag = "RG\tRG";
    }
    elsif($f{pos} eq "prep")
    {
        $tag = "SP\tSP";
    }
    elsif($f{pos} eq "conj")
    {
        # CC = coordinating conjunction
        # CS = subordinating conjunction
        if($f{subpos} eq "sub")
        {
            $tag = "C\tCS";
        }
        else
        {
            $tag = "C\tCC";
        }
    }
    elsif($f{pos} eq "part")
    {
        # U = unique
        $tag = "U\tU";
    }
    elsif($f{pos} eq "int")
    {
        # I = interjection
        $tag = "I\tI";
    }
    elsif($f{pos} eq "punc")
    {
        # XF = foreign word
        # XA = abbreviation
        # XR = formulae ("U-231")
        # XS = symbol ("+", "$")
        # XP = punctuation
        # XX = other
        if($f{tagset} eq "da::conll" && $f{other} eq "symbol")
        {
            $tag = "X\tXS";
        }
        else
        {
            $tag = "X\tXP";
        }
    }
    else
    {
        if($f{tagset} eq "da::conll" && $f{other} eq "formula")
        {
            $tag = "X\tXR";
        }
        else
        {
            $tag = "X\tXX";
        }
    }
    # Encode features.
    my @features;
    if($f{pos} eq "verb")
    {
        # mood
        if($f{verbform} eq "inf")
        {
            push(@features, "mood=infin");
        }
        elsif($f{mood} eq "ind")
        {
            push(@features, "mood=indic");
        }
        elsif($f{mood} eq "imp")
        {
            push(@features, "mood=imper");
        }
        elsif($f{verbform} eq "part")
        {
            push(@features, "mood=partic");
        }
        elsif($f{verbform} eq "ger")
        {
            push(@features, "mood=gerund");
        }
        # tense
        if($f{tense} eq "pres")
        {
            push(@features, "tense=present");
        }
        elsif($f{tense} eq "past")
        {
            push(@features, "tense=past");
        }
        # voice
        if($f{voice} eq "act")
        {
            push(@features, "voice=active");
        }
        elsif($f{voice} eq "pass")
        {
            push(@features, "voice=passive");
        }
    }
    # number: some tags have it before gender
    if($f{pos} eq "verb")
    {
        if($f{number} eq "sing")
        {
            push(@features, "number=sing");
        }
        elsif($f{number} eq "plu")
        {
            push(@features, "number=plur");
        }
        elsif($f{pos} eq "verb" && $f{verbform} eq "part" && $f{synpos} ne "adv")
        {
            push(@features, "number=sing/plur");
        }
    }
    # person
    if($f{person} =~ m/^[123]$/)
    {
        push(@features, "person=$f{person}");
    }
    # degree
    if($f{degree} eq "pos")
    {
        push(@features, "degree=pos");
    }
    elsif($f{degree} eq "comp")
    {
        push(@features, "degree=comp");
    }
    elsif($f{degree} eq "sup")
    {
        push(@features, "degree=sup");
    }
    elsif($f{degree} eq "abs")
    {
        push(@features, "degree=abs");
    }
    elsif($f{pos} eq "adv")
    {
        push(@features, "degree=unmarked");
    }
    # gender
    if($f{gender} eq "com")
    {
        push(@features, "gender=common");
    }
    elsif($f{gender} eq "neut")
    {
        push(@features, "gender=neuter");
    }
    elsif($pos eq "verb" && $f{verbform} eq "part" && $f{synpos} ne "adv" ||
          $pos eq "pron" && $f{prontype} ne "rcp" ||
          $pos eq "noun" && $f{subpos} ne "prop" ||
          $pos eq "adj" && $f{synpos} ne "adv")
    {
        push(@features, "gender=common/neuter");
    }
    # number: some tags have it after gender
    if($f{pos} ne "verb")
    {
        if($f{number} eq "sing")
        {
            push(@features, "number=sing");
        }
        elsif($f{number} eq "plu")
        {
            push(@features, "number=plur");
        }
        elsif($pos eq "verb" && $f{verbform} eq "part" && $f{synpos} ne "adv" ||
              $pos eq "pron" ||
              $pos eq "noun" && $f{subpos} ne "prop" ||
              $pos eq "adj" && $f{synpos} ne "adv")
        {
            push(@features, "number=sing/plur");
        }
    }
    # definiteness of verbs
    unless($pos =~ m/^(noun|adj|pron)$/)
    {
        if($f{definiteness} eq "ind")
        {
            push(@features, "definiteness=indef");
        }
        elsif($f{definiteness} eq "def")
        {
            push(@features, "definiteness=def");
        }
        elsif($f{pos} eq "verb" && $f{verbform} eq "part" && $f{synpos} ne "adv")
        {
            push(@features, "definiteness=def/indef");
        }
    }
    # transcat of verbs
    if($f{pos} eq "verb")
    {
        if($f{synpos} eq "attr")
        {
            push(@features, "transcat=adject");
        }
        elsif($f{synpos} eq "adv")
        {
            push(@features, "transcat=adverb");
        }
        elsif($f{pos} eq "verb" && $f{verbform} eq "part")
        {
            push(@features, "transcat=adject/adverb/unmarked");
        }
    }
    # case
    if($f{case} eq "nom")
    {
        push(@features, "case=nom");
    }
    elsif($f{case} eq "gen")
    {
        push(@features, "case=gen");
    }
    elsif($pos eq "verb" && $f{verbform} eq "part" && $f{synpos} ne "adv" || $f{verbform} eq "ger" ||
          $pos =~ m/^(pron|noun|num)$/ ||
          $pos eq "adj" && $f{synpos} ne "adv")
    {
        push(@features, "case=unmarked");
    }
    # definiteness of nouns and adjectives
    if($pos =~ m/^(noun|adj)$/)
    {
        if($f{definiteness} eq "ind")
        {
            push(@features, "def=indef");
        }
        elsif($f{definiteness} eq "def")
        {
            push(@features, "def=def");
        }
        elsif($f{subpos} ne "prop" && $f{synpos} ne "adv")
        {
            push(@features, "def=def/indef");
        }
    }
    # possessor
    if($f{possnumber} eq "sing")
    {
        push(@features, "possessor=sing");
    }
    elsif($f{possnumber} eq "plu")
    {
        push(@features, "possessor=plur");
    }
    elsif($pos eq "pron" && $f{poss} eq "poss")
    {
        push(@features, "possessor=sing/plur");
    }
    # reflexive
    if($pos eq "pron" && ($f{subpos} eq "pers" || $f{poss} eq "poss"))
    {
        if($f{reflex} eq "reflex")
        {
            push(@features, "reflexive=yes");
        }
        elsif($f{person}<3 && $f{case} ne "nom" && $f{poss} ne "poss")
        {
            push(@features, "reflexive=yes/no");
        }
        else
        {
            push(@features, "reflexive=no");
        }
    }
    # register
    if($f{politeness} eq "pol")
    {
        push(@features, "register=polite");
    }
    elsif($f{style} eq "form")
    {
        push(@features, "register=formal");
    }
    elsif($f{style} eq "arch")
    {
        push(@features, "register=obsolete");
    }
    elsif($pos eq "pron" && $f{prontype} ne "rcp")
    {
        push(@features, "register=unmarked");
    }
    # transcat of adjectives
    if($pos eq "adj")
    {
        if($f{synpos} eq "attr")
        {
            push(@features, "transcat=adject");
        }
        elsif($f{synpos} eq "adv")
        {
            push(@features, "transcat=adverbial");
        }
        else
        {
            push(@features, "transcat=unmarked");
        }
    }
    # Add the features to the part of speech.
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
# cat danish_ddt_train.conll ../test/danish_ddt_test.conll |\
#   perl -pe '@x = split(/\s+/, $_); $_ = "$x[3]\t$x[4]\t$x[5]\n"' |\
#   sort -u | wc -l
# 144
#------------------------------------------------------------------------------
sub list()
{
    my $list = <<end_of_list
A       AC      case=unmarked
A       AN      degree=abs|gender=common/neuter|number=sing/plur|case=unmarked|def=def|transcat=unmarked
A       AN      degree=abs|transcat=adverbial
A       AN      degree=comp|gender=common/neuter|number=plur|case=unmarked|def=def/indef|transcat=unmarked
A       AN      degree=comp|gender=common/neuter|number=sing|case=unmarked|def=indef|transcat=unmarked
A       AN      degree=comp|gender=common/neuter|number=sing/plur|case=gen|def=def/indef|transcat=unmarked
A       AN      degree=comp|gender=common/neuter|number=sing/plur|case=unmarked|def=def/indef|transcat=unmarked
A       AN      degree=comp|transcat=adverbial
A       AN      degree=pos|gender=common/neuter|number=plur|case=gen|def=def/indef|transcat=unmarked
A       AN      degree=pos|gender=common/neuter|number=plur|case=unmarked|def=def/indef|transcat=unmarked
A       AN      degree=pos|gender=common/neuter|number=sing|case=gen|def=def|transcat=unmarked
A       AN      degree=pos|gender=common/neuter|number=sing|case=unmarked|def=def/indef|transcat=unmarked
A       AN      degree=pos|gender=common/neuter|number=sing|case=unmarked|def=def|transcat=unmarked
A       AN      degree=pos|gender=common/neuter|number=sing|case=unmarked|def=indef|transcat=unmarked
A       AN      degree=pos|gender=common/neuter|number=sing/plur|case=unmarked|def=def/indef|transcat=unmarked
A       AN      degree=pos|gender=common|number=sing|case=unmarked|def=def/indef|transcat=unmarked
A       AN      degree=pos|gender=common|number=sing|case=unmarked|def=indef|transcat=unmarked
A       AN      degree=pos|gender=neuter|number=sing|case=unmarked|def=def/indef|transcat=unmarked
A       AN      degree=pos|gender=neuter|number=sing|case=unmarked|def=indef|transcat=unmarked
A       AN      degree=pos|transcat=adverbial
A       AN      degree=sup|gender=common/neuter|number=plur|case=unmarked|def=def/indef|transcat=unmarked
A       AN      degree=sup|gender=common/neuter|number=plur|case=unmarked|def=def|transcat=unmarked
A       AN      degree=sup|gender=common/neuter|number=sing|case=unmarked|def=def|transcat=unmarked
A       AN      degree=sup|gender=common/neuter|number=sing|case=unmarked|def=indef|transcat=unmarked
A       AN      degree=sup|gender=common/neuter|number=sing/plur|case=unmarked|def=def/indef|transcat=unmarked
A       AN      degree=sup|gender=common/neuter|number=sing/plur|case=unmarked|def=def|transcat=unmarked
A       AN      degree=sup|transcat=adverbial
A       AO      case=unmarked
C       CC      _
C       CS      _
I       I       _
N       NC      gender=common/neuter|number=plur|case=unmarked|def=def
N       NC      gender=common/neuter|number=plur|case=unmarked|def=indef
N       NC      gender=common/neuter|number=sing|case=unmarked|def=indef
N       NC      gender=common/neuter|number=sing/plur|case=gen|def=def/indef
N       NC      gender=common/neuter|number=sing/plur|case=unmarked|def=def/indef
N       NC      gender=common/neuter|number=sing/plur|case=unmarked|def=indef
N       NC      gender=common|number=plur|case=gen|def=def
N       NC      gender=common|number=plur|case=gen|def=indef
N       NC      gender=common|number=plur|case=unmarked|def=def
N       NC      gender=common|number=plur|case=unmarked|def=def/indef
N       NC      gender=common|number=plur|case=unmarked|def=indef
N       NC      gender=common|number=sing|case=gen|def=def
N       NC      gender=common|number=sing|case=gen|def=indef
N       NC      gender=common|number=sing|case=unmarked|def=def
N       NC      gender=common|number=sing|case=unmarked|def=indef
N       NC      gender=neuter|number=plur|case=gen|def=def
N       NC      gender=neuter|number=plur|case=gen|def=indef
N       NC      gender=neuter|number=plur|case=unmarked|def=def
N       NC      gender=neuter|number=plur|case=unmarked|def=indef
N       NC      gender=neuter|number=sing|case=gen|def=def
N       NC      gender=neuter|number=sing|case=gen|def=indef
N       NC      gender=neuter|number=sing|case=unmarked|def=def
N       NC      gender=neuter|number=sing|case=unmarked|def=indef
N       NP      case=gen
N       NP      case=unmarked
P       PC      number=plur|case=gen
P       PC      number=plur|case=unmarked
P       PD      gender=common/neuter|number=plur|case=unmarked|register=unmarked
P       PD      gender=common/neuter|number=sing/plur|case=unmarked|register=unmarked
P       PD      gender=common|number=sing|case=gen|register=unmarked
P       PD      gender=common|number=sing|case=unmarked|register=unmarked
P       PD      gender=neuter|number=sing|case=unmarked|register=unmarked
P       PI      gender=common/neuter|number=plur|case=gen|register=unmarked
P       PI      gender=common/neuter|number=plur|case=unmarked|register=obsolete
P       PI      gender=common/neuter|number=plur|case=unmarked|register=unmarked
P       PI      gender=common|number=sing|case=gen|register=unmarked
P       PI      gender=common|number=sing|case=unmarked|register=unmarked
P       PI      gender=common|number=sing/plur|case=nom|register=unmarked
P       PI      gender=neuter|number=sing|case=unmarked|register=unmarked
P       PO      person=1|gender=common/neuter|number=plur|case=unmarked|possessor=plur|reflexive=no|register=formal
P       PO      person=1|gender=common/neuter|number=plur|case=unmarked|possessor=sing|reflexive=no|register=unmarked
P       PO      person=1|gender=common/neuter|number=sing/plur|case=unmarked|possessor=plur|reflexive=no|register=unmarked
P       PO      person=1|gender=common|number=sing|case=unmarked|possessor=plur|reflexive=no|register=formal
P       PO      person=1|gender=common|number=sing|case=unmarked|possessor=sing|reflexive=no|register=unmarked
P       PO      person=1|gender=neuter|number=sing|case=unmarked|possessor=plur|reflexive=no|register=formal
P       PO      person=1|gender=neuter|number=sing|case=unmarked|possessor=sing|reflexive=no|register=unmarked
P       PO      person=2|gender=common/neuter|number=plur|case=unmarked|possessor=sing|reflexive=no|register=unmarked
P       PO      person=2|gender=common/neuter|number=sing/plur|case=unmarked|possessor=plur|reflexive=no|register=unmarked
P       PO      person=2|gender=common/neuter|number=sing/plur|case=unmarked|possessor=sing/plur|reflexive=no|register=polite
P       PO      person=2|gender=common|number=sing|case=unmarked|possessor=sing|reflexive=no|register=unmarked
P       PO      person=2|gender=neuter|number=sing|case=unmarked|possessor=sing|reflexive=no|register=unmarked
P       PO      person=3|gender=common/neuter|number=plur|case=unmarked|possessor=sing|reflexive=yes|register=unmarked
P       PO      person=3|gender=common/neuter|number=sing/plur|case=unmarked|possessor=plur|reflexive=no|register=unmarked
P       PO      person=3|gender=common/neuter|number=sing/plur|case=unmarked|possessor=sing|reflexive=no|register=unmarked
P       PO      person=3|gender=common|number=sing|case=unmarked|possessor=sing|reflexive=yes|register=unmarked
P       PO      person=3|gender=neuter|number=sing|case=unmarked|possessor=sing|reflexive=yes|register=unmarked
P       PP      person=1|gender=common|number=plur|case=nom|reflexive=no|register=unmarked
P       PP      person=1|gender=common|number=plur|case=unmarked|reflexive=yes/no|register=unmarked
P       PP      person=1|gender=common|number=sing|case=nom|reflexive=no|register=unmarked
P       PP      person=1|gender=common|number=sing|case=unmarked|reflexive=yes/no|register=unmarked
P       PP      person=2|gender=common|number=plur|case=nom|reflexive=no|register=unmarked
P       PP      person=2|gender=common|number=plur|case=unmarked|reflexive=yes/no|register=unmarked
P       PP      person=2|gender=common|number=sing|case=nom|reflexive=no|register=unmarked
P       PP      person=2|gender=common|number=sing|case=unmarked|reflexive=yes/no|register=unmarked
P       PP      person=2|gender=common|number=sing/plur|case=nom|reflexive=no|register=polite
P       PP      person=2|gender=common|number=sing/plur|case=unmarked|reflexive=yes/no|register=polite
P       PP      person=3|gender=common/neuter|number=plur|case=nom|reflexive=no|register=unmarked
P       PP      person=3|gender=common/neuter|number=plur|case=unmarked|reflexive=no|register=unmarked
P       PP      person=3|gender=common/neuter|number=sing/plur|case=unmarked|reflexive=yes|register=unmarked
P       PP      person=3|gender=common|number=sing|case=nom|reflexive=no|register=unmarked
P       PP      person=3|gender=common|number=sing|case=unmarked|reflexive=no|register=unmarked
P       PP      person=3|gender=neuter|number=sing|case=unmarked|reflexive=no|register=unmarked
P       PT      gender=common/neuter|number=plur|case=unmarked|register=unmarked
P       PT      gender=common/neuter|number=sing|case=unmarked|register=unmarked
P       PT      gender=common/neuter|number=sing/plur|case=gen|register=unmarked
P       PT      gender=common|number=sing|case=unmarked|register=unmarked
P       PT      gender=common|number=sing/plur|case=unmarked|register=unmarked
P       PT      gender=neuter|number=sing|case=unmarked|register=unmarked
RG      RG      degree=abs
RG      RG      degree=comp
RG      RG      degree=pos
RG      RG      degree=sup
RG      RG      degree=unmarked
SP      SP      _
U       U       _
V       VA      mood=gerund|number=sing|gender=common|definiteness=indef|case=unmarked
V       VA      mood=imper
V       VA      mood=indic|tense=past|voice=active
V       VA      mood=indic|tense=past|voice=passive
V       VA      mood=indic|tense=present|voice=active
V       VA      mood=indic|tense=present|voice=passive
V       VA      mood=infin|voice=active
V       VA      mood=infin|voice=passive
V       VA      mood=partic|tense=past|number=plur|gender=common/neuter|definiteness=def/indef|transcat=adject|case=gen
V       VA      mood=partic|tense=past|number=plur|gender=common/neuter|definiteness=def/indef|transcat=adject|case=unmarked
V       VA      mood=partic|tense=past|number=sing|gender=common|definiteness=def|transcat=adject|case=unmarked
V       VA      mood=partic|tense=past|number=sing|gender=common/neuter|definiteness=def|transcat=adject|case=unmarked
V       VA      mood=partic|tense=past|number=sing|gender=common/neuter|definiteness=indef|transcat=adject/adverb/unmarked|case=unmarked
V       VA      mood=partic|tense=past|number=sing|gender=common/neuter|definiteness=indef|transcat=adject|case=unmarked
V       VA      mood=partic|tense=present|number=sing/plur|gender=common/neuter|definiteness=def/indef|transcat=adject/adverb/unmarked|case=unmarked
V       VA      mood=partic|tense=present|number=sing/plur|gender=common/neuter|definiteness=def/indef|transcat=adject|case=unmarked
V       VA      mood=partic|tense=present|transcat=adverb
V       VE      mood=indic|tense=past|voice=active
V       VE      mood=indic|tense=present|voice=active
V       VE      mood=infin|voice=active
V       VE      mood=partic|tense=past|number=sing/plur|gender=common/neuter|definiteness=def/indef|transcat=adject/adverb/unmarked|case=unmarked
X       XA      _
X       XF      _
X       XP      _
X       XR      _
X       XS      _
X       XX      _
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
    $permitted = tagset::common::get_permitted_structures_joint(list(), \&decode);
}



1;
