#!/usr/bin/perl
# Driver for the CoNLL 2006 Bulgarian tagset.
# (Documentation at http://www.bultreebank.org/TechRep/BTB-TR03.pdf)
# (c) 2007 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::bg::conll;
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
    $f{tagset} = "bgconll";
    $f{other} = $tag;
    # three components: coarse-grained pos, fine-grained pos, features
    # example: N\tNC\tgender=neuter|number=sing|case=unmarked|def=indef
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    # pos: N H A P M V D R C T I
    # N = noun
    if($pos eq "N")
    {
        $f{pos} = "noun";
        # subpos: N Nc Nm Np
        # Nc = common noun
        # Np = proper noun
        if($subpos eq "Np")
        {
            $f{subpos} = "prop";
        }
        # Nm = typo? (The only example is "lv." ("leva"). There are other abbreviations tagged as Nc. Even "lv." occurs many other times tagged as Nc!)
    }
    # H = hybrid between noun and adjective (surnames, names of villages - Ivanov, Ivanovo)
    elsif($pos eq "H")
    {
        $f{pos} = "noun";
        $f{other} = "hybrid";
        # subpos: H Hf Hm Hn - duplicity! The second character actually encodes gender!
    }
    # A = adjective
    elsif($pos eq "A")
    {
        $f{pos} = "adj";
        # subpos: A Af Am An - The second character encodes gender, which may or may not be also encoded in features.
        if($subpos eq "Am")
        {
            $f{gender} = "masc";
        }
        elsif($subpos eq "Af")
        {
            $f{gender} = "fem";
        }
        elsif($subpos eq "An")
        {
            $f{gender} = "neut";
        }
    }
    # P = pronoun
    elsif($pos eq "P")
    {
        $f{pos} = "pron";
        # subpos: P Pc Pd Pf Pi Pn Pp Pr Ps
        # Pp = personal pronoun
        if($subpos eq "Pp")
        {
            $f{subpos} = "pers";
        }
        # Ps = possessive pronoun
        elsif($subpos eq "Ps")
        {
            $f{poss} = "poss";
        }
        # Pd = demonstrative pronoun
        elsif($subpos eq "Pd")
        {
            $f{definiteness} = "def";
        }
        # Pi = interrogative pronoun
        elsif($subpos eq "Pi")
        {
            $f{definiteness} = "int";
        }
        # Pr = relative pronoun
        elsif($subpos eq "Pr")
        {
            $f{definiteness} = "rel";
        }
        # Pc = collective pronoun
        elsif($subpos eq "Pc")
        {
            $f{definiteness} = "col";
        }
        # Pf = indefinite pronoun
        elsif($subpos eq "Pf")
        {
            $f{definiteness} = "ind";
        }
        # Pn = negative pronoun
        elsif($subpos eq "Pn")
        {
            $f{definiteness} = "neg";
        }
    }
    # M = number
    elsif($pos eq "M")
    {
        $f{pos} = "num";
        # subpos: Mc Mo Md My
        # Mc = cardinals
        if($subpos eq "Mc")
        {
            $f{subpos} = "card";
        }
        # Mo = ordinals
        elsif($subpos eq "Mo")
        {
            $f{subpos} = "ord";
            $f{synpos} = "attr";
        }
        # Md = adverbial numerals
        # not what interset calls synpos=adv!
        elsif($subpos eq "Md")
        {
            # poveče, malko, mnogo, măničko
            $f{subpos} = "card";
            $f{definiteness} = "ind";
        }
        # My = fuzzy numerals about people
        elsif($subpos eq "My")
        {
            # malcina = few people, mnozina = many people
            # seems more like a noun (noun phrase) than a numeral
            $f{pos} = "noun";
            $f{other} = "My";
        }
    }
    # V = verb
    elsif($pos eq "V")
    {
        $f{pos} = "verb";
        # V Vii Vni Vnp Vpi Vpp Vxi Vyp
        # Vni = non-personal (has 3rd person only) imperfective verb
        if($subpos eq "Vni")
        {
            $f{other} = "nonpers";
            $f{aspect} = "imp";
        }
        # Vnp = non-personal perfective
        elsif($subpos eq "Vnp")
        {
            $f{other} = "nonpers";
            $f{aspect} = "perf";
        }
        # Vpi = personal imperfective
        elsif($subpos eq "Vpi")
        {
            $f{other} = "pers";
            $f{aspect} = "imp";
        }
        # Vpp = personal perfective
        elsif($subpos eq "Vpp")
        {
            $f{other} = "pers";
            $f{aspect} = "perf";
        }
        # Vxi = "săm" imperfective
        elsif($subpos eq "Vxi")
        {
            $f{other} = "săm";
            $f{aspect} = "imp";
        }
        # Vyp = "băda" perfective
        elsif($subpos eq "Vyp")
        {
            $f{other} = "băda";
            $f{aspect} = "perf";
        }
        # Vii = "bivam" imperfective
        elsif($subpos eq "Vii")
        {
            $f{other} = "bivam";
            $f{aspect} = "imp";
        }
    }
    # D = adverb
    elsif($pos eq "D")
    {
        $f{pos} = "adv";
        # D Dm Dt Dl Dq Dd
        # Dm = adverb of manner
        if($subpos eq "Dm")
        {
            $f{subpos} = "man";
        }
        # Dl = adverb of location
        elsif($subpos eq "Dl")
        {
            $f{subpos} = "loc";
        }
        # Dt = adverb of time
        elsif($subpos eq "Dt")
        {
            $f{subpos} = "tim";
        }
        # Dq = adverb of quantity or degree
        elsif($subpos eq "Dq")
        {
            $f{subpos} = "deg";
        }
        # Dd = adverb of modal nature
        elsif($subpos eq "Dd")
        {
            $f{subpos} = "mod";
        }
    }
    # R = preposition
    elsif($pos eq "R")
    {
        $f{pos} = "prep";
    }
    # C = conjunction
    elsif($pos eq "C")
    {
        $f{pos} = "conj";
        # Cc Cs Cr Cp
        # Cc = coordinative conjunction
        if($subpos eq "Cc")
        {
            $f{subpos} = "coor";
        }
        # Cs = subordinative conjunction
        elsif($subpos eq "Cs")
        {
            $f{subpos} = "sub";
        }
        # Cr = repetitive coordinative conjunction
        # hem ... hem = either ... or
        elsif($subpos eq "Cr")
        {
            $f{subpos} = "coor";
            $f{other} = "rep";
        }
        # Cp = single and repetitive coordinative conjunction
        # i = and
        elsif($subpos eq "Cp")
        {
            $f{subpos} = "coor";
            $f{other} = "srep";
        }
    }
    # T = particle
    elsif($pos eq "T")
    {
        $f{pos} = "part";
        # Ta Te Tg Ti Tm Tn Tv Tx
        # Ta = affirmative particle
        # da = yes
        if($subpos eq "Ta")
        {
            $f{negativeness} = "pos";
        }
        # Tn = negative particle
        # ne = no
        elsif($subpos eq "Tn")
        {
            $f{negativeness} = "neg";
        }
        # Ti = interrogative particle
        # li = question particle
        elsif($subpos eq "Ti")
        {
            $f{definiteness} = "int";
        }
        # Tx = auxiliary particle
        # da = to
        # šte = will
        elsif($subpos eq "Tx")
        {
            $f{subpos} = "aux";
        }
        # Tm = modal particle
        # maj = possibly
        elsif($subpos eq "Tm")
        {
            $f{subpos} = "mod";
        }
        # Tv = verbal particle
        # neka = let
        elsif($subpos eq "Tv")
        {
            $f{subpos} = "mod";
            $f{other} = "verb";
        }
        # Te = emphasis particle
        # daže = even
        elsif($subpos eq "Te")
        {
            $f{subpos} = "emp";
        }
    }
    # I = interjection
    # mjau = miao
    # lele = gosh
    elsif($pos eq "I")
    {
        $f{pos} = "int";
    }
    # Punct = punctuation
    elsif($pos eq "Punct")
    {
        $f{pos} = "punc";
    }
    # Decode the features.
    my @features = split(/\|/, $features);
    foreach my $feature (@features)
    {
        my $value;
        if($feature =~ m/(.*)=(.*)/)
        {
            $feature = $1;
            $value = $2;
        }
        # aspect = p
        if($feature eq "aspect")
        {
            if($value eq "p")
            {
                $f{aspect} = "perf";
            }
        }
        # case = a|d|dp|n|v
        elsif($feature eq "case")
        {
            if($value eq "n")
            {
                $f{case} = "nom";
            }
            elsif($value eq "dp")
            {
                # dp = dative possessive case of pronouns
                # We encode it as genitive.
                $f{case} = "gen";
            }
            elsif($value eq "d")
            {
                $f{case} = "dat";
            }
            elsif($value eq "a")
            {
                $f{case} = "acc";
            }
            elsif($value eq "v")
            {
                $f{case} = "voc";
            }
        }
        # cause: interrogative "pronouns" (in fact adverbs) of cause: "zašto" = "why"
        elsif($feature eq "cause")
        {
            $f{pos} = "adv";
            $f{subpos} = "cau";
        }
        # def = d|f|h|i
        elsif($feature eq "def")
        {
            if($value eq "d")
            {
                $f{definiteness} = "def";
            }
            elsif($value eq "f")
            {
                # full definite article of masculines
                $f{definiteness} = "def";
                $f{variant} = "0";
            }
            elsif($value eq "h")
            {
                # short definite article of masculines
                $f{definiteness} = "def";
                $f{variant} = "short";
            }
            elsif($value eq "i")
            {
                $f{definiteness} = "ind";
            }
        }
        # form = ext|f|s
        elsif($feature eq "form")
        {
            # archaic long form of adjective
            if($value eq "ext")
            {
                $f{style} = "arch";
                $f{variant} = "long";
            }
            # full form of personal or possessive pronoun
            elsif($value eq "f")
            {
                $f{variant} = "long";
            }
            # short form (clitic) of personal or possessive pronoun
            elsif($value eq "s")
            {
                $f{variant} = "short";
            }
        }
        # gender = f|m|n
        elsif($feature eq "gen")
        {
            if($value eq "m")
            {
                $f{gender} = "masc";
            }
            elsif($value eq "f")
            {
                $f{gender} = "fem";
            }
            elsif($value eq "n")
            {
                $f{gender} = "neut";
            }
        }
        # imtrans = i|t
        elsif($feature eq "imtrans")
        {
            if($value eq "i")
            {
                $f{subpos} = "intr";
            }
            elsif($value eq "t")
            {
                $f{subpos} = "tran";
            }
        }
        # mood = i|u|z
        elsif($feature eq "mood")
        {
            if($value eq "i")
            {
                $f{verbform} = "fin";
                $f{mood} = "ind";
            }
            elsif($value eq "z")
            {
                $f{verbform} = "fin";
                $f{mood} = "imp";
            }
            elsif($value eq "u")
            {
                $f{verbform} = "fin";
                $f{mood} = "sub";
            }
        }
        # number = p|pia_tantum|s|t
        elsif($feature eq "num")
        {
            if($value eq "s")
            {
                $f{number} = "sing";
            }
            elsif($value eq "p")
            {
                $f{number} = "plu";
            }
            # t = count form
            # special ending for plural of inanimate nouns in counted noun phrases
            # corresponds to the singular genitive ussage in Russian ("tri časa"), so we encode it as plural+genitive
            elsif($value eq "t")
            {
                $f{number} = "plu";
                $f{case} = "gen";
            }
            # pia_tantum = pluralia tantum (nouns that only appear in plural: "The Alps")
            elsif($value eq "pia_tantum")
            {
                $f{number} = "plu";
                $f{other} = "pluralia tantum";
            }
        }
        # past
        elsif($feature eq "past")
        {
            $f{tense} = "past";
        }
        # person = 1|2|3
        elsif($feature eq "pers")
        {
            if($value =~ m/^[123]$/)
            {
                $f{person} = $value;
            }
        }
        # ref = e|r|a|p|op|mp|q|l|t|m ... some pronouns are in fact numerals or adverbs
        elsif($feature eq "ref")
        {
            # e = entity
            if($value eq "e")
            {
                $f{synpos} = "subst";
            }
            # r = reflexive
            elsif($value eq "r")
            {
                $f{reflex} = "reflex";
            }
            # a = attribute
            elsif($value eq "a")
            {
                $f{synpos} = "attr";
            }
            # p = possessor
            elsif($value eq "p")
            {
                $f{poss} = "poss";
            }
            # op = one possessor
            elsif($value eq "op")
            {
                $f{poss} = "poss";
                $f{possnumber} = "sing";
            }
            # mp = many possessors
            elsif($value eq "mp")
            {
                $f{poss} = "poss";
                $f{possnumber} = "plu";
            }
            # q = quantity or degree
            elsif($value eq "q")
            {
                $f{pos} = "num";
            }
            # l = location
            elsif($value eq "l")
            {
                $f{pos} = "adv";
                $f{subpos} = "loc";
            }
            # t = time
            elsif($value eq "t")
            {
                $f{pos} = "adv";
                $f{subpos} = "tim";
            }
            # m = manner
            elsif($value eq "m")
            {
                $f{pos} = "adv";
                $f{subpos} = "man";
            }
        }
        # tense = m|o|r
        elsif($feature eq "tense")
        {
            # r = present
            if($value eq "r")
            {
                $f{tense} = "pres";
            }
            # o = aorist (past tense that is neither perfect, nor imperfect)
            elsif($value eq "o")
            {
                $f{tense} = "past";
            }
            # m = imperfect; PROBLEM: verbs classified as perfect occur (although rarely) in the imperfect past tense
            # triple specification of aspect:
            # detailed part of speech = Vpp (verb personal perfective)
            # aspect = p (perfective)
            # tense = m (imperfect)
            elsif($value eq "m")
            {
                $f{tense} = "past";
                if($f{aspect} eq "perf")
                {
                    $f{other} = "aspect=p|tense=m";
                }
                $f{aspect} = "imp";
            }
        }
        # trans = i|t
        elsif($feature eq "trans")
        {
            # i = intransitive verb
            if($value eq "i")
            {
                $f{subpos} = "intr";
            }
            # t = transitive verb
            elsif($value eq "t")
            {
                $f{subpos} = "tran";
            }
        }
        # type = aux
        elsif($feature eq "type")
        {
            # aux = auxiliary verb
            if($value eq "aux")
            {
                $f{subpos} = "aux";
            }
        }
        # vform = c|g
        elsif($feature eq "vform")
        {
            # c = participle: izbiran, navăršil, izkazanite, priet, dejstvašt
            if($value eq "c")
            {
                $f{verbform} = "part";
            }
            # g = gerund: prevărtajki, demonstrirajki, stradajki, pišejki, otčitajki, izključaja
            # what bultreebank calls gerund is in fact adverbial participle (called present transgressive in Czech)
            elsif($value eq "g")
            {
                $f{verbform} = "trans";
            }
        }
        # voice = a|v
        elsif($feature eq "voice")
        {
            if($value eq "a")
            {
                $f{voice} = "act";
            }
            elsif($value eq "v")
            {
                $f{voice} = "pass";
            }
        }
    }
    # Default feature values. Used to improve collaboration with other drivers.
    if($f{pos} eq "verb")
    {
        if($f{verbform} eq "")
        {
            if($f{person} ne "")
            {
                $f{verbform} = "fin";
                if($f{mood} eq "")
                {
                    $f{mood} = "ind";
                }
            }
            else
            {
                $f{verbform} = "inf";
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
    my $f = shift;
    my %f = %{$f}; # this is not a deep copy! We must not modify the contents!
    my $nonstrict = shift; # strict is default
    $strict = !$nonstrict;
    my $tag;
    # pos and subpos
    if($f{abbr} eq "abbr")
    {
        $tag = "Y\tY";
    }
    elsif($f{pos} eq "noun")
    {
        # N = common noun
        # Z = proper noun
        if($f{subpos} eq "prop")
        {
            $tag = "Z\tZ";
        }
        else
        {
            $tag = "N\tN";
        }
    }
    elsif($f{pos} =~ m/^(adj|det)$/)
    {
        $tag = "A\tA";
    }
    elsif($f{pos} eq "pron")
    {
        # SD = demonstrative pronoun
        # SR = relative pronoun
        # S = other pronoun
        if($f{definiteness} eq "def")
        {
            $tag = "S\tSD";
        }
        elsif($f{definiteness} =~ m/^(wh|int|rel)$/)
        {
            $tag = "S\tSR";
        }
        else
        {
            $tag = "S\tS";
        }
    }
    elsif($f{pos} eq "num")
    {
        # Q = numeral
        $tag = "Q\tQ";
    }
    elsif($f{pos} eq "verb")
    {
        # VI = imperfect verb
        # VP = perfect verb
        if($f{aspect} eq "perf")
        {
            $tag = "V\tVP";
        }
        else
        {
            $tag = "V\tVI";
        }
    }
    elsif($f{pos} eq "adv")
    {
        $tag = "D\tD";
    }
    elsif($f{pos} eq "prep")
    {
        $tag = "P\tP";
    }
    elsif($f{pos} eq "conj")
    {
        $tag = "C\tC";
    }
    elsif($f{pos} =~ m/^(inf|part)$/)
    {
        # FI = interrogative particle
        # FN = negative particle
        # F = function word or particle
        if($f{negativeness} eq "neg")
        {
            $tag = "F\tFN";
        }
        elsif($f{definiteness} =~ m/^(wh|int|rel)$/)
        {
            $tag = "F\tFI";
        }
        else
        {
            $tag = "F\tF";
        }
    }
    elsif($f{pos} eq "int")
    {
        # I = interjection
        $tag = "I\tI";
    }
    elsif($f{pos} eq "punc")
    {
        # T = typo
        # G = punctuation
        # X = non-alphabetic
        $tag = "G\tG";
    }
    else
    {
        if($f{tagset} eq "arconll" && $f{other} eq "-")
        {
            $tag = "-\t-";
        }
        else
        {
            $tag = "X\tX";
        }
    }
    # Encode features.
    my @features;
    # Only finite imperfect verbs have mood.
    if($f{pos} eq "verb" && $f{aspect} eq "imp" && $f{verbform} eq "fin")
    {
        if($f{mood} eq "jus")
        {
            push(@features, "mood=D");
        }
        elsif($f{mood} eq "sub")
        {
            push(@features, "mood=S");
        }
        else
        {
            push(@features, "mood=I");
        }
    }
    # Only verbs have voice and only passive voice is explicitely encoded.
    if($f{pos} eq "verb")
    {
        if($f{voice} eq "pass")
        {
            push(@features, "voice=P");
        }
    }
    # Non-demonstrative non-relative pronouns and verbs have person.
    if($f{pos} =~ m/^(pron|verb)$/)
    {
        if($f{person} =~ m/^[123]$/)
        {
            push(@features, "pers=$f{person}");
        }
    }
    # Gender.
    if($f{gender} eq "masc")
    {
        push(@features, "gen=M");
    }
    elsif($f{gender} eq "fem")
    {
        push(@features, "gen=F");
    }
    # Number.
    if($f{number} eq "sing")
    {
        push(@features, "num=S");
    }
    elsif($f{number} eq "dual")
    {
        push(@features, "num=D");
    }
    elsif($f{number} eq "plu")
    {
        push(@features, "num=P");
    }
    # Case.
    if($f{case} eq "nom")
    {
        push(@features, "case=1");
    }
    elsif($f{case} eq "gen")
    {
        push(@features, "case=2");
    }
    elsif($f{case} eq "acc")
    {
        push(@features, "case=4");
    }
    # Definiteness.
    # Do not show explicitly for demonstrative pronouns.
    if($f{definiteness} eq "def" && $f{pos} ne "pron")
    {
        if($f{tagset} eq "arconll" && $f{other} eq "def=C")
        {
            push(@features, "def=C");
        }
        else
        {
            push(@features, "def=D");
        }
    }
    elsif($f{definiteness} eq "ind")
    {
        push(@features, "def=I");
    }
    elsif($f{definiteness} eq "red")
    {
        push(@features, "def=R");
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
# cat bgtrain.conll bgtest.conll |\
#   perl -pe '@x = split(/\s+/, $_); $_ = "$x[3]\t$x[4]\t$x[5]\n"' |\
#   sort -u | wc -l
# 528
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
A   A   _
A   Af  _
A   Af  gen=f|num=s|def=d
A   Af  gen=f|num=s|def=i
A   Am  _
A   Am  gen=m|num=s|def=f
A   Am  gen=m|num=s|def=h
A   Am  gen=m|num=s|def=i
A   Am  gen=m|num=s|form=ext
A   An  gen=n|num=s|def=d
A   An  gen=n|num=s|def=i
A   A   num=p|def=d
A   A   num=p|def=i
C   Cc  _
C   Cp  _
C   Cr  _
C   Cs  _
D   D   _
D   Dd  _
D   Dl  _
D   Dm  _
D   Dq  _
D   Dt  _
H   Hf  gen=f|num=s|def=i
H   Hm  gen=m|num=s|def=f
H   Hm  gen=m|num=s|def=i
H   Hn  gen=n|num=s|def=i
H   H   num=p|def=i
I   I   _
M   Mc  _
M   Mc  def=d
M   Mc  def=i
M   Mc  gen=f|def=d
M   Mc  gen=f|def=i
M   Mc  gen=f|num=s|def=d
M   Mc  gen=f|num=s|def=i
M   Mc  gen=m|def=d
M   Mc  gen=m|def=i
M   Mc  gen=m|num=s|def=f
M   Mc  gen=m|num=s|def=i
M   Mc  gen=n|def=d
M   Mc  gen=n|def=i
M   Mc  gen=n|num=s|def=d
M   Mc  gen=n|num=s|def=i
M   Md  _
M   Md  def=d
M   Md  def=i
M   Mo  gen=f|num=s|def=d
M   Mo  gen=f|num=s|def=i
M   Mo  gen=m|num=s|def=f
M   Mo  gen=m|num=s|def=h
M   Mo  gen=m|num=s|def=i
M   Mo  gen=n|num=s|def=d
M   Mo  gen=n|num=s|def=i
M   Mo  num=p|def=d
M   Mo  num=p|def=i
M   My  _
M   My  def=i
N   N   _
N   Nc  _
N   Nc  gen=f|num=p|def=d
N   Nc  gen=f|num=p|def=i
N   Nc  gen=f|num=s|case=v
N   Nc  gen=f|num=s|def=d
N   Nc  gen=m|num=p|def=d
N   Nc  gen=m|num=p|def=i
N   Nc  gen=m|num=s|case=v
N   Nc  gen=m|num=s|def=d
N   Nc  gen=m|num=s|def=f
N   Nc  gen=m|num=s|def=h
N   Nc  gen=m|num=s|def=i
N   Nc  gen=m|num=t
N   Nc  gen=n|num=p|def=d
N   Nc  gen=n|num=p|def=i
N   Nc  gen=n|num=s|def=d
N   Nc  gen=n|num=s|def=i
N   Nc  num=pia_tantum|def=d
N   Nc  num=pia_tantum|def=i
N   Nm  _
N   Np  _
N   Np  gen=f|num=p|def=d
N   Np  gen=f|num=p|def=i
N   Np  gen=f|num=s|case=v
N   Np  gen=f|num=s|def=i
N   Np  gen=m|num=p|def=d
N   Np  gen=m|num=p|def=i
N   Np  gen=m|num=s|case=a
N   Np  gen=m|num=s|case=v
N   Np  gen=m|num=s|def=f
N   Np  gen=m|num=s|def=h
N   Np  gen=m|num=s|def=i
N   Np  gen=n|num=p|def=d
N   Np  gen=n|num=p|def=i
N   Np  gen=n|num=s|def=d
N   Np  gen=n|num=s|def=i
N   Np  num=pia_tantum|def=i
P   P   _
P   Pc  ref=a|num=p
P   Pc  ref=a|num=s|gen=f
P   Pc  ref=a|num=s|gen=m
P   Pc  ref=a|num=s|gen=n
P   Pc  ref=e|case=a|num=s|gen=m
P   Pc  ref=e|case=n|num=p
P   Pc  ref=e|case=n|num=s|gen=f
P   Pc  ref=e|case=n|num=s|gen=m
P   Pc  ref=e|case=n|num=s|gen=n
P   Pc  ref=l
P   Pc  ref=q|num=p|def=d
P   Pc  ref=q|num=s|gen=n|def=d
P   Pc  ref=t
P   Pd  _
P   Pd  ref=a|num=p
P   Pd  ref=a|num=s|gen=f
P   Pd  ref=a|num=s|gen=n
P   Pd  ref=e|case=n|num=p
P   Pd  ref=e|case=n|num=s|gen=f
P   Pd  ref=e|case=n|num=s|gen=m
P   Pd  ref=e|case=n|num=s|gen=n
P   Pd  ref=l
P   Pd  ref=m
P   Pd  ref=q
P   Pd  ref=t
P   Pf  def=i|ref=a|num=p
P   Pf  def=i|ref=a|num=s|gen=f
P   Pf  def=i|ref=a|num=s|gen=m
P   Pf  def=i|ref=a|num=s|gen=n
P   Pf  def=i|ref=e|case=a|num=s|gen=m
P   Pf  def=i|ref=e|case=d|num=s|gen=m
P   Pf  def=i|ref=e|case=n|num=p
P   Pf  def=i|ref=e|case=n|num=p|def=d
P   Pf  def=i|ref=e|case=n|num=p|def=i
P   Pf  def=i|ref=e|case=n|num=s|gen=f
P   Pf  def=i|ref=e|case=n|num=s|gen=f|def=d
P   Pf  def=i|ref=e|case=n|num=s|gen=f|def=i
P   Pf  def=i|ref=e|case=n|num=s|gen=m
P   Pf  def=i|ref=e|case=n|num=s|gen=m|def=f
P   Pf  def=i|ref=e|case=n|num=s|gen=m|def=h
P   Pf  def=i|ref=e|case=n|num=s|gen=m|def=i
P   Pf  def=i|ref=e|case=n|num=s|gen=n
P   Pf  def=i|ref=e|case=n|num=s|gen=n|def=d
P   Pf  def=i|ref=e|case=n|num=s|gen=n|def=i
P   Pf  def=i|ref=l
P   Pf  def=i|ref=m
P   Pf  def=i|ref=p|num=p
P   Pf  def=i|ref=q|def=i
P   Pf  def=i|ref=t
P   Pi  cause
P   Pi  ref=a|num=p
P   Pi  ref=a|num=s|gen=f
P   Pi  ref=a|num=s|gen=m
P   Pi  ref=a|num=s|gen=n
P   Pi  ref=e|case=a|num=s|gen=m
P   Pi  ref=e|case=n|num=p
P   Pi  ref=e|case=n|num=s|gen=f
P   Pi  ref=e|case=n|num=s|gen=m
P   Pi  ref=e|case=n|num=s|gen=n
P   Pi  ref=l
P   Pi  ref=m
P   Pi  ref=p|num=s|gen=f
P   Pi  ref=p|num=s|gen=m
P   Pi  ref=q
P   Pi  ref=t
P   Pn  _
P   Pn  ref=a|num=p
P   Pn  ref=a|num=s|gen=f
P   Pn  ref=a|num=s|gen=m
P   Pn  ref=a|num=s|gen=n
P   Pn  ref=e|case=a|num=s|gen=m
P   Pn  ref=e|case=d|num=s|gen=m
P   Pn  ref=e|case=n|num=s|gen=f
P   Pn  ref=e|case=n|num=s|gen=m
P   Pn  ref=e|case=n|num=s|gen=n
P   Pn  ref=e|case=n|num=s|gen=n|def=d
P   Pn  ref=l
P   Pn  ref=m
P   Pn  ref=p|num=s|gen=f
P   Pn  ref=t
P   Pp  _
P   Pp  ref=e|case=n|num=p|pers=1
P   Pp  ref=e|case=n|num=p|pers=2
P   Pp  ref=e|case=n|num=p|pers=3
P   Pp  ref=e|case=n|num=s|pers=1
P   Pp  ref=e|case=n|num=s|pers=2
P   Pp  ref=e|case=n|num=s|pers=3|gen=f
P   Pp  ref=e|case=n|num=s|pers=3|gen=m
P   Pp  ref=e|case=n|num=s|pers=3|gen=n
P   Pp  ref=e|form=f|case=a|num=p|pers=1
P   Pp  ref=e|form=f|case=a|num=p|pers=2
P   Pp  ref=e|form=f|case=a|num=p|pers=3
P   Pp  ref=e|form=f|case=a|num=s|pers=1
P   Pp  ref=e|form=f|case=a|num=s|pers=2
P   Pp  ref=e|form=f|case=a|num=s|pers=3|gen=f
P   Pp  ref=e|form=f|case=a|num=s|pers=3|gen=m
P   Pp  ref=e|form=f|case=a|num=s|pers=3|gen=n
P   Pp  ref=e|form=f|case=d|num=p|pers=1
P   Pp  ref=e|form=f|case=d|num=s|pers=1
P   Pp  ref=e|form=f|case=d|num=s|pers=2
P   Pp  ref=e|form=f|case=d|num=s|pers=3|gen=m
P   Pp  ref=e|form=s|case=a|num=p|pers=1
P   Pp  ref=e|form=s|case=a|num=p|pers=2
P   Pp  ref=e|form=s|case=a|num=p|pers=3
P   Pp  ref=e|form=s|case=a|num=s|pers=1
P   Pp  ref=e|form=s|case=a|num=s|pers=2
P   Pp  ref=e|form=s|case=a|num=s|pers=3|gen=f
P   Pp  ref=e|form=s|case=a|num=s|pers=3|gen=m
P   Pp  ref=e|form=s|case=a|num=s|pers=3|gen=n
P   Pp  ref=e|form=s|case=d|num=p|pers=1
P   Pp  ref=e|form=s|case=d|num=p|pers=2
P   Pp  ref=e|form=s|case=d|num=p|pers=3
P   Pp  ref=e|form=s|case=d|num=s|pers=1
P   Pp  ref=e|form=s|case=d|num=s|pers=2
P   Pp  ref=e|form=s|case=d|num=s|pers=3|gen=f
P   Pp  ref=e|form=s|case=d|num=s|pers=3|gen=m
P   Pp  ref=e|form=s|case=d|num=s|pers=3|gen=n
P   Pp  ref=e|form=s|case=dp|num=p|pers=1
P   Pp  ref=e|form=s|case=dp|num=p|pers=2
P   Pp  ref=e|form=s|case=dp|num=p|pers=3
P   Pp  ref=e|form=s|case=dp|num=s|pers=1
P   Pp  ref=e|form=s|case=dp|num=s|pers=2
P   Pp  ref=e|form=s|case=dp|num=s|pers=3|gen=f
P   Pp  ref=e|form=s|case=dp|num=s|pers=3|gen=m
P   Pp  ref=r|form=f|case=a
P   Pp  ref=r|form=s|case=a
P   Pp  ref=r|form=s|case=d
P   Pp  ref=r|form=s|case=dp
P   Pr  _
P   Pr  ref=a|num=p
P   Pr  ref=a|num=s|gen=f
P   Pr  ref=a|num=s|gen=m
P   Pr  ref=a|num=s|gen=n
P   Pr  ref=e|case=a|num=s|gen=m
P   Pr  ref=e|case=d|num=s|gen=m
P   Pr  ref=e|case=n|num=p
P   Pr  ref=e|case=n|num=s|gen=f
P   Pr  ref=e|case=n|num=s|gen=m
P   Pr  ref=e|case=n|num=s|gen=n
P   Pr  ref=e|num=s
P   Pr  ref=l
P   Pr  ref=m
P   Pr  ref=p|num=p
P   Pr  ref=p|num=s|gen=f
P   Pr  ref=p|num=s|gen=m
P   Pr  ref=p|num=s|gen=n
P   Pr  ref=q
P   Pr  ref=t
P   Ps  _
P   Ps  ref=mp|form=f|num=p|pers=1|def=d
P   Ps  ref=mp|form=f|num=p|pers=1|def=i
P   Ps  ref=mp|form=f|num=p|pers=2|def=d
P   Ps  ref=mp|form=f|num=p|pers=3|def=d
P   Ps  ref=mp|form=f|num=p|pers=3|def=i
P   Ps  ref=mp|form=f|num=s|pers=1|gen=f|def=d
P   Ps  ref=mp|form=f|num=s|pers=1|gen=f|def=i
P   Ps  ref=mp|form=f|num=s|pers=1|gen=m|def=f
P   Ps  ref=mp|form=f|num=s|pers=1|gen=m|def=h
P   Ps  ref=mp|form=f|num=s|pers=1|gen=m|def=i
P   Ps  ref=mp|form=f|num=s|pers=1|gen=n|def=d
P   Ps  ref=mp|form=f|num=s|pers=1|gen=n|def=i
P   Ps  ref=mp|form=f|num=s|pers=2|gen=f|def=d
P   Ps  ref=mp|form=f|num=s|pers=2|gen=f|def=i
P   Ps  ref=mp|form=f|num=s|pers=2|gen=m|def=h
P   Ps  ref=mp|form=f|num=s|pers=2|gen=m|def=i
P   Ps  ref=mp|form=f|num=s|pers=2|gen=n|def=d
P   Ps  ref=mp|form=f|num=s|pers=2|gen=n|def=i
P   Ps  ref=mp|form=f|num=s|pers=3|gen=f|def=d
P   Ps  ref=mp|form=f|num=s|pers=3|gen=f|def=i
P   Ps  ref=mp|form=f|num=s|pers=3|gen=m|def=f
P   Ps  ref=mp|form=f|num=s|pers=3|gen=m|def=h
P   Ps  ref=mp|form=f|num=s|pers=3|gen=m|def=i
P   Ps  ref=mp|form=f|num=s|pers=3|gen=n|def=d
P   Ps  ref=mp|form=f|num=s|pers=3|gen=n|def=i
P   Ps  ref=mp|form=s|pers=1
P   Ps  ref=mp|form=s|pers=2
P   Ps  ref=mp|form=s|pers=3
P   Ps  ref=op|form=f|num=p|pers=1|def=d
P   Ps  ref=op|form=f|num=p|pers=1|def=i
P   Ps  ref=op|form=f|num=p|pers=2|def=d
P   Ps  ref=op|form=f|num=p|pers=3|def=d|gen=f
P   Ps  ref=op|form=f|num=p|pers=3|def=d|gen=m
P   Ps  ref=op|form=f|num=p|pers=3|def=d|gen=n
P   Ps  ref=op|form=f|num=p|pers=3|def=i|gen=f
P   Ps  ref=op|form=f|num=p|pers=3|def=i|gen=m
P   Ps  ref=op|form=f|num=s|pers=1|gen=f|def=d
P   Ps  ref=op|form=f|num=s|pers=1|gen=f|def=i
P   Ps  ref=op|form=f|num=s|pers=1|gen=m|def=f
P   Ps  ref=op|form=f|num=s|pers=1|gen=m|def=h
P   Ps  ref=op|form=f|num=s|pers=1|gen=m|def=i
P   Ps  ref=op|form=f|num=s|pers=1|gen=n|def=d
P   Ps  ref=op|form=f|num=s|pers=1|gen=n|def=i
P   Ps  ref=op|form=f|num=s|pers=2|gen=f|def=d
P   Ps  ref=op|form=f|num=s|pers=2|gen=f|def=i
P   Ps  ref=op|form=f|num=s|pers=2|gen=n|def=i
P   Ps  ref=op|form=f|num=s|pers=3|gen=f|def=d|gen=f
P   Ps  ref=op|form=f|num=s|pers=3|gen=f|def=d|gen=m
P   Ps  ref=op|form=f|num=s|pers=3|gen=f|def=d|gen=n
P   Ps  ref=op|form=f|num=s|pers=3|gen=f|def=i|gen=f
P   Ps  ref=op|form=f|num=s|pers=3|gen=f|def=i|gen=m
P   Ps  ref=op|form=f|num=s|pers=3|gen=m|def=f|gen=f
P   Ps  ref=op|form=f|num=s|pers=3|gen=m|def=f|gen=m
P   Ps  ref=op|form=f|num=s|pers=3|gen=m|def=h|gen=f
P   Ps  ref=op|form=f|num=s|pers=3|gen=m|def=h|gen=m
P   Ps  ref=op|form=f|num=s|pers=3|gen=m|def=h|gen=n
P   Ps  ref=op|form=f|num=s|pers=3|gen=m|def=i|gen=f
P   Ps  ref=op|form=f|num=s|pers=3|gen=m|def=i|gen=m
P   Ps  ref=op|form=f|num=s|pers=3|gen=m|def=i|gen=n
P   Ps  ref=op|form=f|num=s|pers=3|gen=n|def=d|gen=f
P   Ps  ref=op|form=f|num=s|pers=3|gen=n|def=d|gen=m
P   Ps  ref=op|form=f|num=s|pers=3|gen=n|def=d|gen=n
P   Ps  ref=op|form=f|num=s|pers=3|gen=n|def=i|gen=f
P   Ps  ref=op|form=f|num=s|pers=3|gen=n|def=i|gen=m
P   Ps  ref=op|form=f|num=s|pers=3|gen=n|def=i|gen=n
P   Ps  ref=op|form=s|pers=1
P   Ps  ref=op|form=s|pers=2
P   Ps  ref=op|form=s|pers=3|gen=f
P   Ps  ref=op|form=s|pers=3|gen=m
P   Ps  ref=op|form=s|pers=3|gen=n
P   Ps  ref=r|form=f|case=n|num=p|def=d
P   Ps  ref=r|form=f|case=n|num=p|def=i
P   Ps  ref=r|form=f|case=n|num=s|gen=f|def=d
P   Ps  ref=r|form=f|case=n|num=s|gen=m|def=h
P   Ps  ref=r|form=f|case=n|num=s|gen=m|def=i
P   Ps  ref=r|form=f|case=n|num=s|gen=n|def=d
P   Ps  ref=r|form=f|case=n|num=s|gen=n|def=i
P   Ps  ref=r|form=s|case=n
Punct   Punct   _
R   R   _
T   Ta  _
T   Te  _
T   Tg  _
T   Ti  _
T   Tm  _
T   Tn  _
T   Tv  _
T   Tx  _
V   V   _
V   Vii type=aux|trans=t|mood=i|tense=r|pers=3|num=p
V   Vii type=aux|trans=t|mood=i|tense=r|pers=3|num=s
V   Vni imtrans=i|mood=i|tense=m|pers=3|num=s
V   Vni imtrans=i|mood=i|tense=o|pers=3|num=s
V   Vni imtrans=i|mood=i|tense=r|pers=3|num=s
V   Vni imtrans=i|vform=c|voice=a|tense=m|num=s|gen=n|def=i
V   Vni imtrans=i|vform=c|voice=a|tense=o|num=s|gen=n|def=i
V   Vni imtrans=t|mood=i|tense=m|pers=3|num=s
V   Vni imtrans=t|mood=i|tense=o|pers=3|num=s
V   Vni imtrans=t|mood=i|tense=r|pers=3|num=s
V   Vni imtrans=t|vform=c|voice=a|tense=m|num=s|gen=n|def=i
V   Vni imtrans=t|vform=c|voice=a|tense=o|num=s|gen=n|def=i
V   Vnp trans=i|mood=i|tense=o|pers=3|num=s
V   Vnp trans=i|mood=i|tense=r|pers=3|num=s
V   Vnp trans=i|vform=c|voice=a|tense=o|num=s|gen=n|def=i
V   Vnp trans=t|mood=i|tense=m|pers=3|num=s
V   Vnp trans=t|vform=c|voice=a|tense=o|num=s|gen=n|def=i
V   Vpi _
V   Vpi trans=i|mood=i|tense=m|pers=1|num=p
V   Vpi trans=i|mood=i|tense=m|pers=1|num=s
V   Vpi trans=i|mood=i|tense=m|pers=2|num=s
V   Vpi trans=i|mood=i|tense=m|pers=3|num=p
V   Vpi trans=i|mood=i|tense=m|pers=3|num=s
V   Vpi trans=i|mood=i|tense=o|pers=1|num=p
V   Vpi trans=i|mood=i|tense=o|pers=1|num=s
V   Vpi trans=i|mood=i|tense=o|pers=3|num=p
V   Vpi trans=i|mood=i|tense=o|pers=3|num=s
V   Vpi trans=i|mood=i|tense=r|pers=1|num=p
V   Vpi trans=i|mood=i|tense=r|pers=1|num=s
V   Vpi trans=i|mood=i|tense=r|pers=2|num=p
V   Vpi trans=i|mood=i|tense=r|pers=2|num=s
V   Vpi trans=i|mood=i|tense=r|pers=3|num=p
V   Vpi trans=i|mood=i|tense=r|pers=3|num=s
V   Vpi trans=i|mood=z|pers=2|num=p
V   Vpi trans=i|mood=z|pers=2|num=s
V   Vpi trans=i|vform=c|voice=a|tense=m|num=p|def=i
V   Vpi trans=i|vform=c|voice=a|tense=m|num=s|gen=f|def=i
V   Vpi trans=i|vform=c|voice=a|tense=m|num=s|gen=m|def=i
V   Vpi trans=i|vform=c|voice=a|tense=m|num=s|gen=n|def=i
V   Vpi trans=i|vform=c|voice=a|tense=o|num=p|def=d
V   Vpi trans=i|vform=c|voice=a|tense=o|num=p|def=i
V   Vpi trans=i|vform=c|voice=a|tense=o|num=s|gen=f|def=i
V   Vpi trans=i|vform=c|voice=a|tense=o|num=s|gen=m|def=f
V   Vpi trans=i|vform=c|voice=a|tense=o|num=s|gen=m|def=i
V   Vpi trans=i|vform=c|voice=a|tense=o|num=s|gen=n|def=i
V   Vpi trans=i|vform=c|voice=a|tense=r|num=p|def=d
V   Vpi trans=i|vform=c|voice=a|tense=r|num=p|def=i
V   Vpi trans=i|vform=c|voice=a|tense=r|num=s|gen=f|def=d
V   Vpi trans=i|vform=c|voice=a|tense=r|num=s|gen=f|def=i
V   Vpi trans=i|vform=c|voice=a|tense=r|num=s|gen=m|def=f
V   Vpi trans=i|vform=c|voice=a|tense=r|num=s|gen=m|def=h
V   Vpi trans=i|vform=c|voice=a|tense=r|num=s|gen=m|def=i
V   Vpi trans=i|vform=c|voice=a|tense=r|num=s|gen=n|def=d
V   Vpi trans=i|vform=c|voice=a|tense=r|num=s|gen=n|def=i
V   Vpi trans=i|vform=g
V   Vpi trans=t|mood=i|tense=m|pers=1|num=p
V   Vpi trans=t|mood=i|tense=m|pers=1|num=s
V   Vpi trans=t|mood=i|tense=m|pers=2|num=p
V   Vpi trans=t|mood=i|tense=m|pers=2|num=s
V   Vpi trans=t|mood=i|tense=m|pers=3|num=p
V   Vpi trans=t|mood=i|tense=m|pers=3|num=s
V   Vpi trans=t|mood=i|tense=o|pers=1|num=p
V   Vpi trans=t|mood=i|tense=o|pers=1|num=s
V   Vpi trans=t|mood=i|tense=o|pers=2|num=p
V   Vpi trans=t|mood=i|tense=o|pers=2|num=s
V   Vpi trans=t|mood=i|tense=o|pers=3|num=p
V   Vpi trans=t|mood=i|tense=o|pers=3|num=s
V   Vpi trans=t|mood=i|tense=r|pers=1|num=p
V   Vpi trans=t|mood=i|tense=r|pers=1|num=s
V   Vpi trans=t|mood=i|tense=r|pers=2|num=p
V   Vpi trans=t|mood=i|tense=r|pers=2|num=s
V   Vpi trans=t|mood=i|tense=r|pers=3|num=p
V   Vpi trans=t|mood=i|tense=r|pers=3|num=s
V   Vpi trans=t|mood=z|pers=2|num=p
V   Vpi trans=t|mood=z|pers=2|num=s
V   Vpi trans=t|vform=c|voice=a|tense=m|num=p|def=i
V   Vpi trans=t|vform=c|voice=a|tense=m|num=s|gen=f|def=i
V   Vpi trans=t|vform=c|voice=a|tense=m|num=s|gen=m|def=i
V   Vpi trans=t|vform=c|voice=a|tense=m|num=s|gen=n|def=i
V   Vpi trans=t|vform=c|voice=a|tense=o|num=p|def=i
V   Vpi trans=t|vform=c|voice=a|tense=o|num=s|gen=f|def=i
V   Vpi trans=t|vform=c|voice=a|tense=o|num=s|gen=m|def=i
V   Vpi trans=t|vform=c|voice=a|tense=o|num=s|gen=n|def=i
V   Vpi trans=t|vform=c|voice=a|tense=r|num=p|def=d
V   Vpi trans=t|vform=c|voice=a|tense=r|num=p|def=i
V   Vpi trans=t|vform=c|voice=a|tense=r|num=s|gen=f|def=d
V   Vpi trans=t|vform=c|voice=a|tense=r|num=s|gen=f|def=i
V   Vpi trans=t|vform=c|voice=a|tense=r|num=s|gen=m|def=f
V   Vpi trans=t|vform=c|voice=a|tense=r|num=s|gen=m|def=h
V   Vpi trans=t|vform=c|voice=a|tense=r|num=s|gen=n|def=d
V   Vpi trans=t|vform=c|voice=a|tense=r|num=s|gen=n|def=i
V   Vpi trans=t|vform=c|voice=v|num=p|def=d
V   Vpi trans=t|vform=c|voice=v|num=p|def=i
V   Vpi trans=t|vform=c|voice=v|num=s|gen=f|def=d
V   Vpi trans=t|vform=c|voice=v|num=s|gen=f|def=i
V   Vpi trans=t|vform=c|voice=v|num=s|gen=m|def=f
V   Vpi trans=t|vform=c|voice=v|num=s|gen=m|def=h
V   Vpi trans=t|vform=c|voice=v|num=s|gen=m|def=i
V   Vpi trans=t|vform=c|voice=v|num=s|gen=n|def=d
V   Vpi trans=t|vform=c|voice=v|num=s|gen=n|def=i
V   Vpi trans=t|vform=g
V   Vpp _
V   Vpp aspect=p|trans=i|mood=i|tense=m|pers=3|num=p
V   Vpp aspect=p|trans=i|mood=i|tense=m|pers=3|num=s
V   Vpp aspect=p|trans=i|mood=i|tense=o|pers=1|num=p
V   Vpp aspect=p|trans=i|mood=i|tense=o|pers=1|num=s
V   Vpp aspect=p|trans=i|mood=i|tense=o|pers=2|num=p
V   Vpp aspect=p|trans=i|mood=i|tense=o|pers=2|num=s
V   Vpp aspect=p|trans=i|mood=i|tense=o|pers=3|num=p
V   Vpp aspect=p|trans=i|mood=i|tense=o|pers=3|num=s
V   Vpp aspect=p|trans=i|mood=i|tense=r|pers=1|num=p
V   Vpp aspect=p|trans=i|mood=i|tense=r|pers=1|num=s
V   Vpp aspect=p|trans=i|mood=i|tense=r|pers=2|num=p
V   Vpp aspect=p|trans=i|mood=i|tense=r|pers=2|num=s
V   Vpp aspect=p|trans=i|mood=i|tense=r|pers=3|num=p
V   Vpp aspect=p|trans=i|mood=i|tense=r|pers=3|num=s
V   Vpp aspect=p|trans=i|mood=z|pers=2|num=p
V   Vpp aspect=p|trans=i|mood=z|pers=2|num=s
V   Vpp aspect=p|trans=i|vform=c|voice=a|tense=m|num=s|gen=n|def=i
V   Vpp aspect=p|trans=i|vform=c|voice=a|tense=o|num=p|def=d
V   Vpp aspect=p|trans=i|vform=c|voice=a|tense=o|num=p|def=i
V   Vpp aspect=p|trans=i|vform=c|voice=a|tense=o|num=s|gen=f|def=d
V   Vpp aspect=p|trans=i|vform=c|voice=a|tense=o|num=s|gen=f|def=i
V   Vpp aspect=p|trans=i|vform=c|voice=a|tense=o|num=s|gen=m|def=f
V   Vpp aspect=p|trans=i|vform=c|voice=a|tense=o|num=s|gen=m|def=h
V   Vpp aspect=p|trans=i|vform=c|voice=a|tense=o|num=s|gen=m|def=i
V   Vpp aspect=p|trans=i|vform=c|voice=a|tense=o|num=s|gen=n|def=d
V   Vpp aspect=p|trans=i|vform=c|voice=a|tense=o|num=s|gen=n|def=i
V   Vpp aspect=p|trans=t|mood=i|tense=m|pers=1|num=p
V   Vpp aspect=p|trans=t|mood=i|tense=m|pers=1|num=s
V   Vpp aspect=p|trans=t|mood=i|tense=m|pers=3|num=p
V   Vpp aspect=p|trans=t|mood=i|tense=m|pers=3|num=s
V   Vpp aspect=p|trans=t|mood=i|tense=o|pers=1|num=p
V   Vpp aspect=p|trans=t|mood=i|tense=o|pers=1|num=s
V   Vpp aspect=p|trans=t|mood=i|tense=o|pers=2|num=p
V   Vpp aspect=p|trans=t|mood=i|tense=o|pers=2|num=s
V   Vpp aspect=p|trans=t|mood=i|tense=o|pers=3|num=p
V   Vpp aspect=p|trans=t|mood=i|tense=o|pers=3|num=s
V   Vpp aspect=p|trans=t|mood=i|tense=r|pers=1|num=p
V   Vpp aspect=p|trans=t|mood=i|tense=r|pers=1|num=s
V   Vpp aspect=p|trans=t|mood=i|tense=r|pers=2|num=p
V   Vpp aspect=p|trans=t|mood=i|tense=r|pers=2|num=s
V   Vpp aspect=p|trans=t|mood=i|tense=r|pers=3|num=p
V   Vpp aspect=p|trans=t|mood=i|tense=r|pers=3|num=s
V   Vpp aspect=p|trans=t|mood=z|pers=2|num=p
V   Vpp aspect=p|trans=t|mood=z|pers=2|num=s
V   Vpp aspect=p|trans=t|vform=c|voice=a|tense=m|num=s|gen=m|def=i
V   Vpp aspect=p|trans=t|vform=c|voice=a|tense=o|num=p|def=d
V   Vpp aspect=p|trans=t|vform=c|voice=a|tense=o|num=p|def=i
V   Vpp aspect=p|trans=t|vform=c|voice=a|tense=o|num=s|gen=f|def=d
V   Vpp aspect=p|trans=t|vform=c|voice=a|tense=o|num=s|gen=f|def=i
V   Vpp aspect=p|trans=t|vform=c|voice=a|tense=o|num=s|gen=m|def=h
V   Vpp aspect=p|trans=t|vform=c|voice=a|tense=o|num=s|gen=m|def=i
V   Vpp aspect=p|trans=t|vform=c|voice=a|tense=o|num=s|gen=n|def=d
V   Vpp aspect=p|trans=t|vform=c|voice=a|tense=o|num=s|gen=n|def=i
V   Vpp aspect=p|trans=t|vform=c|voice=v|num=p|def=d
V   Vpp aspect=p|trans=t|vform=c|voice=v|num=p|def=i
V   Vpp aspect=p|trans=t|vform=c|voice=v|num=s|gen=f|def=d
V   Vpp aspect=p|trans=t|vform=c|voice=v|num=s|gen=f|def=i
V   Vpp aspect=p|trans=t|vform=c|voice=v|num=s|gen=m|def=h
V   Vpp aspect=p|trans=t|vform=c|voice=v|num=s|gen=m|def=i
V   Vpp aspect=p|trans=t|vform=c|voice=v|num=s|gen=n|def=d
V   Vpp aspect=p|trans=t|vform=c|voice=v|num=s|gen=n|def=i
V   Vxi type=aux|trans=t|mood=i|past|pers=1|num=p
V   Vxi type=aux|trans=t|mood=i|past|pers=1|num=s
V   Vxi type=aux|trans=t|mood=i|past|pers=2|num=p
V   Vxi type=aux|trans=t|mood=i|past|pers=2|num=s
V   Vxi type=aux|trans=t|mood=i|past|pers=3|num=p
V   Vxi type=aux|trans=t|mood=i|past|pers=3|num=s
V   Vxi type=aux|trans=t|mood=i|tense=r|pers=1|num=p
V   Vxi type=aux|trans=t|mood=i|tense=r|pers=1|num=s
V   Vxi type=aux|trans=t|mood=i|tense=r|pers=2|num=p
V   Vxi type=aux|trans=t|mood=i|tense=r|pers=2|num=s
V   Vxi type=aux|trans=t|mood=i|tense=r|pers=3|num=p
V   Vxi type=aux|trans=t|mood=i|tense=r|pers=3|num=s
V   Vxi type=aux|trans=t|mood=u|tense=o|pers=1|num=p
V   Vxi type=aux|trans=t|mood=u|tense=o|pers=1|num=s
V   Vxi type=aux|trans=t|mood=u|tense=o|pers=2|num=p
V   Vxi type=aux|trans=t|mood=u|tense=o|pers=2|num=s
V   Vxi type=aux|trans=t|mood=u|tense=o|pers=3|num=p
V   Vxi type=aux|trans=t|mood=u|tense=o|pers=3|num=s
V   Vxi type=aux|trans=t|vform=c|voice=a|past|num=p|def=i
V   Vxi type=aux|trans=t|vform=c|voice=a|past|num=s|gen=f|def=i
V   Vxi type=aux|trans=t|vform=c|voice=a|past|num=s|gen=m|def=i
V   Vxi type=aux|trans=t|vform=c|voice=a|past|num=s|gen=n|def=i
V   Vyp type=aux|aspect=p|trans=t|mood=i|tense=o|pers=3|num=s
V   Vyp type=aux|aspect=p|trans=t|mood=i|tense=r|pers=1|num=p
V   Vyp type=aux|aspect=p|trans=t|mood=i|tense=r|pers=1|num=s
V   Vyp type=aux|aspect=p|trans=t|mood=i|tense=r|pers=2|num=p
V   Vyp type=aux|aspect=p|trans=t|mood=i|tense=r|pers=2|num=s
V   Vyp type=aux|aspect=p|trans=t|mood=i|tense=r|pers=3|num=p
V   Vyp type=aux|aspect=p|trans=t|mood=i|tense=r|pers=3|num=s
V   Vyp type=aux|aspect=p|trans=t|mood=z|pers=2|num=s
end_of_list
    ;
    # Protect from editors that replace tabs by spaces.
    $list =~ s/ \s+/\t/sg;
    my @list = split(/\r?\n/, $list);
    pop(@list) if($list[$#list] eq "");
    return \@list;
}



1;
