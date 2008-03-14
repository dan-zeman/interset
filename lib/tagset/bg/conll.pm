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
    # three components: coarse-grained pos, fine-grained pos, features
    # example: N\tNC\tgender=neuter|number=sing|case=unmarked|def=indef
    # This tag set is really a damn masterpiece. The "gen" feature can occur twice
    # in a tag for possessive pronouns! If that happens, the first occurrence
    # denotes the gender of the owned, the second one denotes the gender of the
    # owner. We start with renaming the second to avoid later confusion.
    $tag =~ s/\|gen=(.\|.*)\|gen=/\|gen=$1\|possgen=/;
    # Also, if number is plural, there is only one gender but it is the possessor's.
    $tag =~ s/\|num=p\|(.*)\|gen=/\|num=p\|$1\|possgen=/;
    # Also, all indefinite pronouns start with def=i and there can (but need not) be another def at the end.
    $tag =~ s/Pf\tdef=i\|/Pf\t/;
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    # pos: N H A P M V D R C T I
    # N = noun
    if($pos eq "N")
    {
        $f{pos} = "noun";
        # subpos: N Nc Nm Np
        # N  = indeclinable foreign noun
        # Nc = common noun
        # Np = proper noun
        if($subpos eq "N")
        {
            $f{foreign} = "foreign";
        }
        elsif($subpos eq "Np")
        {
            $f{subpos} = "prop";
        }
        # Nm = typo? (The only example is "lv." ("leva"). There are other abbreviations tagged as Nc. Even "lv." occurs many other times tagged as Nc!)
        elsif($subpos eq "Nm")
        {
            $f{other}{subpos} = "Nm";
        }
    }
    # H = hybrid between noun and adjective (surnames, names of villages - Ivanov, Ivanovo)
    elsif($pos eq "H")
    {
        $f{pos} = "noun";
        $f{other}{pos} = "hybrid";
        # subpos: H Hf Hm Hn - duplicity! The second character actually encodes gender!
        if($subpos eq "H")
        {
            $f{other}{subpos} = "H";
        }
    }
    # A = adjective
    elsif($pos eq "A")
    {
        $f{pos} = "adj";
        # subpos: A Af Am An
        # The second character encodes gender.
        # If there is no second character, it is plural, which is genderless.
        # We do not decode the gender/number here, we are waiting for the features.
        # We have to preserve tags like "A Am _" where the gender is not in the features.
        if($subpos eq "A")
        {
            $f{other}{subpos} = "A";
        }
        elsif($subpos eq "Am")
        {
            $f{other}{subpos} = "Am";
        }
        elsif($subpos eq "Af")
        {
            $f{other}{subpos} = "Af";
        }
        elsif($subpos eq "An")
        {
            $f{other}{subpos} = "An";
        }
    }
    # P = pronoun
    elsif($pos eq "P")
    {
        $f{pos} = "pron";
        # subpos: P Pc Pd Pf Pi Pn Pp Pr Ps
        # P = probably error; the only example is "za_razlika_ot" ("in contrast to")
        if($subpos eq "P")
        {
            $f{other}{subpos} = "P";
        }
        # Pp = personal pronoun
        elsif($subpos eq "Pp")
        {
            $f{subpos} = "pers";
            $f{prontype} = "prs";
        }
        # Ps = possessive pronoun
        elsif($subpos eq "Ps")
        {
            $f{prontype} = "prs";
            $f{poss} = "poss";
        }
        # Pd = demonstrative pronoun
        elsif($subpos eq "Pd")
        {
            $f{prontype} = "dem";
        }
        # Pi = interrogative pronoun
        elsif($subpos eq "Pi")
        {
            $f{prontype} = "int";
            $f{definiteness} = "int";
        }
        # Pr = relative pronoun
        elsif($subpos eq "Pr")
        {
            $f{prontype} = "rel";
            $f{definiteness} = "rel";
        }
        # Pc = collective pronoun
        elsif($subpos eq "Pc")
        {
            $f{prontype} = "tot";
            $f{definiteness} = "col";
        }
        # Pf = indefinite pronoun
        elsif($subpos eq "Pf")
        {
            $f{prontype} = "ind";
        }
        # Pn = negative pronoun
        elsif($subpos eq "Pn")
        {
            $f{prontype} = "neg";
            $f{negativeness} = "neg";
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
        # This does not mean that there are no "P Pf ref=q". There are. Examples: "nekolcina", "njakolko".
        elsif($subpos eq "Md")
        {
            # poveče, malko, mnogo, măničko
            $f{subpos} = "card";
            $f{prontype} = "ind";
            $f{other}{subpos} = "Md";
        }
        # My = fuzzy numerals about people
        # Only two varieties:
        # M\tMy\t_
        # M\tMy\tdef=i
        # This is unlike N\tNc which either has "_" features, or always at least number, mostly also gender, in addition to definiteness.
        elsif($subpos eq "My")
        {
            # malcina = few people, mnozina = many people
            # seems more like a noun (noun phrase) than a numeral
            $f{pos} = "noun";
            $f{other}{subpos} = "My";
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
            $f{other}{subpos} = "nonpers";
            $f{aspect} = "imp";
        }
        # Vnp = non-personal perfective
        elsif($subpos eq "Vnp")
        {
            $f{other}{subpos} = "nonpers";
            $f{aspect} = "perf";
        }
        # Vpi = personal imperfective
        elsif($subpos eq "Vpi")
        {
            $f{other}{subpos} = "pers";
            $f{aspect} = "imp";
        }
        # Vpp = personal perfective
        elsif($subpos eq "Vpp")
        {
            $f{other}{subpos} = "pers";
            $f{aspect} = "perf";
        }
        # Vxi = "săm" imperfective
        elsif($subpos eq "Vxi")
        {
            $f{subpos} = "aux";
            $f{other}{subpos} = "săm";
            $f{aspect} = "imp";
        }
        # Vyp = "băda" perfective
        elsif($subpos eq "Vyp")
        {
            $f{subpos} = "aux";
            $f{other}{subpos} = "băda";
            $f{aspect} = "perf";
        }
        # Vii = "bivam" imperfective
        elsif($subpos eq "Vii")
        {
            $f{subpos} = "aux";
            $f{other}{subpos} = "bivam";
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
            $f{other}{subpos} = "rep";
        }
        # Cp = single and repetitive coordinative conjunction
        # i = and
        elsif($subpos eq "Cp")
        {
            $f{subpos} = "coor";
            $f{other}{subpos} = "srep";
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
            $f{other}{subpos} = "verb";
        }
        # Te = emphasis particle
        # daže = even
        elsif($subpos eq "Te")
        {
            $f{subpos} = "emp";
        }
        # Tg = gradable particle
        # naj = most
        elsif($subpos eq "Tg")
        {
            $f{other}{subpos} = "naj";
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
                # We cannot use $f{variant} = "short" because it would collide with the form feature of pronouns.
                $f{other}{definiteness} = "f";
            }
            elsif($value eq "h")
            {
                # short definite article of masculines
                $f{definiteness} = "def";
                # We cannot use $f{variant} = "short" because it would collide with the form feature of pronouns.
                $f{other}{definiteness} = "h";
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
                $f{subcat} = "intr";
            }
            elsif($value eq "t")
            {
                $f{subcat} = "tran";
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
            # corresponds to the singular genitive ussage in Russian ("tri časa")
            # we encode it as dual
            elsif($value eq "t")
            {
                $f{number} = "dual";
            }
            # pia_tantum = pluralia tantum (nouns that only appear in plural: "The Alps")
            elsif($value eq "pia_tantum")
            {
                $f{number} = "plu";
                $f{other}{number} = "pluralia tantum";
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
        # possgen = m|f
        # This was originally called "gen". We do not like two "gen"s in one tag, so we renamed it in the beginning of decoding.
        elsif($feature eq "possgen")
        {
            if($value eq "m")
            {
                $f{possgender} = "masc";
            }
            elsif($value eq "f")
            {
                $f{possgender} = "fem";
            }
            elsif($value eq "n")
            {
                $f{possgender} = "neut";
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
            # not normal possessive pronouns (my, his, our) but relative/indefinite/negative (whose, someone's, nobody's)
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
                $f{subtense} = "aor";
            }
            # m = imperfect; PROBLEM: verbs classified as perfect occur (although rarely) in the imperfect past tense
            # Bulgarian has lexical aspect and grammatical aspect.
            # Lexical aspect is inherent in verb lemma.
            # Grammatical: imperfect tenses, perfect tenses, and aorist (aspect-neutral).
            # Main clause: perfective verb with perfect tense or aorist; imperfective with imperfect or aorist.
            # Relative clause: perfective verb can occur in imperfect tense, and vice versa.
            # triple specification of aspect:
            # detailed part of speech = Vpp (verb personal perfective)
            # aspect = p (perfective)
            # tense = m (imperfect)
            elsif($value eq "m")
            {
                $f{tense} = "past";
                $f{subtense} = "imp";
            }
        }
        # trans = i|t
        elsif($feature eq "trans")
        {
            # i = intransitive verb
            if($value eq "i")
            {
                $f{subcat} = "intr";
            }
            # t = transitive verb
            elsif($value eq "t")
            {
                $f{subcat} = "tran";
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
    my $f0 = shift;
    my $nonstrict = shift; # strict is default
    $strict = !$nonstrict;
    # Modify the feature structure so that it contains values expected by this
    # driver.
    my $f = tagset::common::enforce_permitted_joint($f0, $permitted);
    my %f = %{$f}; # This is not a deep copy but $f already refers to a deep copy of the original %{$f0}.
    my $tag;
    # pos and subpos
    if($f{foreign} eq "foreign")
    {
        $tag = "N\tN";
    }
    elsif($f{pos} eq "noun")
    {
        # N = normal noun
        # H = hybrid adjectival noun (Ivanov, Ivanovo)
        if($f{tagset} eq "bgconll" && $f{other}{pos} eq "hybrid" ||
           $f{tagset} ne "bgconll" && $f{gender} eq "fem" && $f{number} eq "sing" && $f{definiteness} eq "ind")
        {
            # Hm = masculine
            # Hf = feminine
            # Hn = neuter
            if($f{tagset} eq "bgconll" && $f{other}{subpos} eq "H")
            {
                $tag = "H\tH";
            }
            elsif($f{gender} eq "masc")
            {
                $tag = "H\tHm";
            }
            elsif($f{gender} eq "fem")
            {
                $tag = "H\tHf";
            }
            else
            {
                $tag = "H\tHn";
            }
        }
        else
        {
            # N  = indeclinable, usually foreign noun ("bug", "US_Oupăn", "Bi_Bi_Si", "Partido_popular")
            # Nc = common noun
            # Np = proper noun
            # Nm ... typo, nonsensical tag?
            # My ... "melcina" (Czech: "menšina")
            if($f{tagset} eq "bgconll" && $f{other}{subpos} eq "Nm")
            {
                $tag = "N\tNm";
            }
            elsif($f{tagset} eq "bgconll" && $f{other}{subpos} eq "My" ||
                  $f{definiteness} ne "" && $f{number} eq "")
            {
                $tag = "M\tMy";
            }
            elsif($f{subpos} eq "prop")
            {
                $tag = "N\tNp";
            }
            else
            {
                $tag = "N\tNc";
            }
        }
    }
    elsif($f{pos} =~ m/^(adj|det)$/)
    {
        # A  = plural
        # Am = masculine
        # Af = feminine
        # An = neuter
        if($f{gender} eq "masc" || $f{tagset} eq "bgconll" && $f{other}{subpos} eq "Am")
        {
            $tag = "A\tAm";
        }
        elsif($f{gender} eq "fem" || $f{tagset} eq "bgconll" && $f{other}{subpos} eq "Af")
        {
            $tag = "A\tAf";
        }
        elsif($f{gender} eq "neut" || $f{tagset} eq "bgconll" && $f{other}{subpos} eq "An")
        {
            $tag = "A\tAn";
        }
        else
        {
            $tag = "A\tA";
        }
    }
    elsif($f{pos} eq "pron" || $f{prontype} ne "")
    {
        # P  = "za_razlika_ot"
        # Pp = personal pronoun
        # Ps = possessive pronoun
        # Pd = demonstrative pronoun
        # Pi = interrogative pronoun
        # Pr = relative pronoun
        # Pc = collective pronoun
        # Pf = indefinite pronoun
        # Pn = negative pronoun
        if($f{tagset} eq "bgconll" && $f{other}{subpos} eq "P")
        {
            $tag = "P\tP";
        }
        elsif($f{prontype} eq "prs")
        {
            if($f{poss} eq "poss")
            {
                $tag = "P\tPs";
            }
            else
            {
                $tag = "P\tPp";
            }
        }
        elsif($f{prontype} eq "int")
        {
            $tag = "P\tPi";
        }
        elsif($f{prontype} eq "rel")
        {
            $tag = "P\tPr";
        }
        elsif($f{prontype} eq "neg")
        {
            $tag = "P\tPn";
        }
        elsif($f{prontype} eq "ind")
        {
            if($f{subpos} eq "card")
            {
                $tag = "M\tMd";
            }
            else
            {
                $tag = "P\tPf";
            }
        }
        elsif($f{prontype} eq "dem")
        {
            $tag = "P\tPd";
        }
        elsif($f{prontype} eq "tot")
        {
            $tag = "P\tPc";
        }
        elsif($f{definiteness} =~ m/^(wh|rel)$/)
        {
            $tag = "P\tPr";
        }
        elsif($f{definiteness} eq "int")
        {
            $tag = "P\tPi";
        }
        elsif($f{negativeness} eq "neg")
        {
            $tag = "P\tPn";
        }
        elsif($f{poss} eq "poss" && ($f{possnumber} ne "" || $f{reflex} eq "reflex"))
        {
            $tag = "P\tPs";
        }
        elsif($f{definiteness} eq "def")
        {
            $tag = "P\tPd";
        }
        elsif($f{definiteness} eq "col")
        {
            $tag = "P\tPc";
        }
        else
        {
            $tag = "P\tPp";
        }
    }
    elsif($f{pos} eq "num")
    {
        # Mc = cardinal number
        # Mo = ordinal number
        # Md = adverbial numeral (poveče, malko, mnogo, măničko)
        # My = fuzzy numerals about people (malcina, mnozina)
        if($f{definiteness} eq "rel")
        {
            $tag = "P\tPr";
        }
        elsif($f{definiteness} eq "int")
        {
            $tag = "P\tPi";
        }
        elsif($f{tagset} eq "bgconll" && $f{other}{subpos} eq "My")
        {
            $tag = "M\tMy";
        }
        elsif($f{subpos} eq "card" && $f{prontype} eq "ind")
        {
            $tag = "M\tMd";
        }
        elsif($f{subpos} eq "ord")
        {
            $tag = "M\tMo";
        }
        else
        {
            $tag = "M\tMc";
        }
    }
    elsif($f{pos} eq "verb")
    {
        # V   = ? (but aspect is not set)
        # Vpi = personal imperfect verb
        # Vpp = personal perfect verb
        # Vni = nonpersonal imperfect verb
        # Vnp = nonpersonal perfect verb
        # Vii = imperfect auxiliary verb bivam
        # Vxi = imperfect auxiliary verb săm
        # Vyp = perfect auxiliary verb băda
        if($f{aspect} eq "")
        {
            $tag = "V\tV";
        }
        elsif($f{subpos} eq "aux")
        {
            if($f{tagset} eq "bgconll" && $f{other}{subpos} eq "băda")
            {
                $tag = "V\tVyp";
            }
            elsif($f{tagset} eq "bgconll" && $f{other}{subpos} eq "bivam")
            {
                $tag = "V\tVii";
            }
            else
            {
                $tag = "V\tVxi";
            }
        }
        elsif($f{tagset} eq "bgconll" && $f{other}{subpos} eq "nonpers")
        {
            if($f{aspect} eq "perf")
            {
                $tag = "V\tVnp";
            }
            else
            {
                $tag = "V\tVni";
            }
        }
        else
        {
            if($f{aspect} eq "perf")
            {
                $tag = "V\tVpp";
            }
            else
            {
                $tag = "V\tVpi";
            }
        }
    }
    elsif($f{pos} eq "adv")
    {
        # Dm = adverb of manner
        # Dl = adverb of location
        # Dt = adverb of time
        # Dq = adverb of quantity or degree
        # Dd = adverb of modal nature
        if($f{definiteness} eq "rel")
        {
            $tag = "P\tPr";
        }
        elsif($f{definiteness} eq "int")
        {
            $tag = "P\tPi";
        }
        elsif($f{definiteness} eq "ind")
        {
            $tag = "P\tPf";
        }
        elsif($f{negativeness} eq "neg")
        {
            $tag = "P\tPn";
        }
        elsif($f{subpos} eq "man")
        {
            $tag = "D\tDm";
        }
        elsif($f{subpos} eq "loc")
        {
            $tag = "D\tDl";
        }
        elsif($f{subpos} eq "tim")
        {
            $tag = "D\tDt";
        }
        elsif($f{subpos} eq "deg")
        {
            $tag = "D\tDq";
        }
        elsif($f{subpos} eq "mod")
        {
            $tag = "D\tDd";
        }
        else
        {
            $tag = "D\tD";
        }
    }
    elsif($f{pos} eq "prep")
    {
        $tag = "R\tR";
    }
    elsif($f{pos} eq "conj")
    {
        # Cc = coordinative conjunction
        # Cs = subordinative conjunction
        # Cr = repetitive coordinative conjunction
        # Cp = single and repetitive coordinative conjunction
        if($f{subpos} eq "sub")
        {
            $tag = "C\tCs";
        }
        else
        {
            if($f{tagset} eq "bgconll" && $f{other}{subpos} eq "rep")
            {
                $tag = "C\tCr";
            }
            elsif($f{tagset} eq "bgconll" && $f{other}{subpos} eq "srep")
            {
                $tag = "C\tCp";
            }
            else
            {
                $tag = "C\tCc";
            }
        }
    }
    elsif($f{pos} eq "inf")
    {
        # Note that this occurs only in values from foreign tagsets.
        # Bulgarian "da/Tx" is not decoded as "inf" because "Tx" is also used for non-infinitival particle "šte".
        # auxiliary particle
        $tag = "T\tTx";
    }
    elsif($f{pos} eq "part")
    {
        # Ta = affirmative particle
        if($f{negativeness} eq "pos")
        {
            $tag = "T\tTa";
        }
        # Tn = negative particle
        elsif($f{negativeness} eq "neg")
        {
            $tag = "T\tTn";
        }
        # Ti = interrogative particle
        elsif($f{definiteness} =~ m/^(wh|int|rel)$/)
        {
            $tag = "T\tTi";
        }
        # Tx = auxiliary particle
        elsif($f{subpos} eq "aux")
        {
            $tag = "T\tTx";
        }
        # Tm = modal particle
        # Tv = verbal particle
        elsif($f{subpos} eq "mod")
        {
            if($f{tagset} eq "bgconll" && $f{other}{subpos} eq "verb")
            {
                $tag = "T\tTv";
            }
            else
            {
                $tag = "T\tTm";
            }
        }
        # Tg = gradable particle
        elsif($f{tagset} eq "bgconll" && $f{other}{subpos} eq "naj")
        {
            $tag = "T\tTg";
        }
        # Te = emphasis particle
        else
        {
            $tag = "T\tTe";
        }
    }
    elsif($f{pos} eq "int")
    {
        # I = interjection
        $tag = "I\tI";
    }
    else
    {
        # Punct = punctuation
        $tag = "Punct\tPunct";
    }
    # Encode features.
    my @features;
    # type of verbs
    if($f{pos} eq "verb")
    {
        if($f{subpos} eq "aux")
        {
            push(@features, "type=aux");
        }
        # aspect
        if($f{subpos} eq "aux" && !($f{tagset} eq "bgconll" && $f{other}{subpos} =~ m/^(săm|bivam)$/) ||
           $f{aspect} eq "perf" && !($f{tagset} eq "bgconll" && $f{other}{subpos} eq "nonpers") && $f{subcat} ne "")
        {
            if($f{aspect} eq "imp")
            {
                push(@features, "aspect=i");
            }
            elsif($f{aspect} eq "perf")
            {
                push(@features, "aspect=p");
            }
        }
        # transitivity of verbs
        my $prefix;
        if($f{tagset} eq "bgconll" && $f{other}{subpos} eq "nonpers" && $f{aspect} eq "imp")
        {
            $prefix = "im";
        }
        if($f{subcat} eq "intr")
        {
            push(@features, "${prefix}trans=i");
        }
        elsif($f{subcat} eq "tran")
        {
            push(@features, "${prefix}trans=t");
        }
        # vform
        if($f{verbform} eq "part")
        {
            push(@features, "vform=c");
        }
        elsif($f{verbform} eq "trans")
        {
            push(@features, "vform=g");
        }
        # mood
        if($f{mood} eq "ind")
        {
            push(@features, "mood=i");
        }
        elsif($f{mood} eq "imp")
        {
            push(@features, "mood=z");
        }
        elsif($f{mood} eq "sub")
        {
            push(@features, "mood=u");
        }
        # voice
        if($f{voice} eq "act")
        {
            push(@features, "voice=a");
        }
        elsif($f{voice} eq "pass")
        {
            push(@features, "voice=v");
        }
        # tense
        if($f{tense} eq "pres")
        {
            push(@features, "tense=r");
        }
        elsif($f{tense} eq "past")
        {
            if($f{subtense} eq "imp")
            {
                push(@features, "tense=m");
            }
            elsif($f{tagset} eq "bgconll" && $f{other}{subpos} eq "săm" && $f{mood} ne "sub")
            {
                push(@features, "past");
            }
            else
            {
                push(@features, "tense=o");
            }
        }
    }
    # def1
    # The features of indefinite pronouns (Pf) always begin with "def=i".
    # Another definiteness can occur at the end, this time not necessarily indefinite!
    # Examples: edin i i, edinja i h, edinjat i f, ednata i d, nekolcina i i, nešta i i, neštata i d, njakolko i i.
    if($f{prontype} eq "ind" && !($f{tagset} eq "bgconll" && $f{other}{subpos} eq "Md"))
    {
        push(@features, "def=i");
    }
    # ref
    if($f{reflex} eq "reflex")
    {
        push(@features, "ref=r");
    }
    elsif($f{poss} eq "poss")
    {
        if($f{possnumber} eq "sing")
        {
            push(@features, "ref=op");
        }
        elsif($f{possnumber} eq "plu")
        {
            push(@features, "ref=mp");
        }
        elsif($f{prontype} ne "prs")
        {
            push(@features, "ref=p");
        }
    }
    elsif($f{pos} eq "num" && $f{prontype} ne "" && !($f{tagset} eq "bgconll" && $f{other}{subpos} eq "Md"))
    {
        push(@features, "ref=q");
    }
    elsif($f{subpos} eq "loc" && $f{prontype} ne "")
    {
        push(@features, "ref=l");
    }
    elsif($f{subpos} eq "tim" && $f{prontype} ne "")
    {
        push(@features, "ref=t");
    }
    elsif($f{subpos} eq "man" && $f{prontype} ne "")
    {
        push(@features, "ref=m");
    }
    elsif($f{subpos} eq "cau")
    {
        push(@features, "cause");
    }
    elsif($f{synpos} eq "subst")
    {
        push(@features, "ref=e");
    }
    elsif($f{synpos} eq "attr" && $f{prontype} ne "")
    {
        push(@features, "ref=a");
    }
    # form of pronouns
    if($f{pos} eq "pron")
    {
        if($f{variant} eq "long")
        {
            if($f{style} eq "arch")
            {
                push(@features, "form=ext");
            }
            else
            {
                push(@features, "form=f");
            }
        }
        elsif($f{variant} eq "short")
        {
            push(@features, "form=s");
        }
    }
    # person of verbs comes here
    if($f{pos} eq "verb")
    {
        if($f{person} =~ m/^[123]$/)
        {
            push(@features, "pers=$f{person}");
        }
    }
    # case of pronouns
    unless($f{pos} eq "noun")
    {
        if($f{case} eq "nom")
        {
            push(@features, "case=n");
        }
        elsif($f{case} eq "gen")
        {
            push(@features, "case=dp");
        }
        elsif($f{case} eq "dat")
        {
            push(@features, "case=d");
        }
        elsif($f{case} eq "acc")
        {
            push(@features, "case=a");
        }
    }
    # gender of nouns, adjectives and numerals
    if($f{pos} =~ m/^(noun|adj|num)$/ && $f{prontype} eq "")
    {
        if($f{gender} eq "masc")
        {
            push(@features, "gen=m");
        }
        elsif($f{gender} eq "fem")
        {
            push(@features, "gen=f");
        }
        elsif($f{gender} eq "neut")
        {
            push(@features, "gen=n");
        }
    }
    # number
    if($f{number} eq "sing")
    {
        push(@features, "num=s");
    }
    elsif($f{number} eq "dual")
    {
        push(@features, "num=t");
    }
    elsif($f{number} eq "plu")
    {
        if($f{tagset} eq "bgconll" && $f{other}{number} eq "pluralia tantum" ||
           $f{tagset} ne "bgconll" && $f{pos} eq "noun" && $f{gender} eq "")
        {
            push(@features, "num=pia_tantum");
        }
        else
        {
            push(@features, "num=p");
        }
    }
    # case of nouns
    if($f{pos} eq "noun")
    {
        if($f{case} eq "nom")
        {
            push(@features, "case=n");
        }
        elsif($f{case} eq "gen")
        {
            push(@features, "case=dp");
        }
        elsif($f{case} eq "dat")
        {
            push(@features, "case=d");
        }
        elsif($f{case} eq "acc")
        {
            push(@features, "case=a");
        }
        elsif($f{case} eq "voc")
        {
            push(@features, "case=v");
        }
    }
    # form of adjectives
    if($f{pos} eq "adj")
    {
        if($f{style} eq "arch")
        {
            push(@features, "form=ext");
        }
    }
    # person of pronouns comes here
    if($f{pos} eq "pron")
    {
        if($f{person} =~ m/^[123]$/)
        {
            push(@features, "pers=$f{person}");
        }
    }
    # gender of pronouns
    unless($f{pos} =~ m/^(noun|adj|num)$/ && $f{prontype} eq "")
    {
        if($f{gender} eq "masc")
        {
            push(@features, "gen=m");
        }
        elsif($f{gender} eq "fem")
        {
            push(@features, "gen=f");
        }
        elsif($f{gender} eq "neut")
        {
            push(@features, "gen=n");
        }
    }
    # definiteness
    unless($f{pos} eq "adv")
    {
        if($f{definiteness} eq "ind")
        {
            push(@features, "def=i");
        }
        elsif($f{definiteness} eq "def")
        {
            if($f{tagset} eq "bgconll" && $f{other}{definiteness} eq "f" ||
               $f{tagset} ne "bgconll" && $f{gender} eq "masc" && $f{number} eq "sing")
            {
                push(@features, "def=f");
            }
            elsif($f{tagset} eq "bgconll" && $f{other}{definiteness} eq "h")
            {
                # shoft definite article
                # We cannot use $f{variant} = "short" because it would collide with the form feature of pronouns.
                push(@features, "def=h");
            }
            else
            {
                push(@features, "def=d");
            }
        }
    }
    # possgender
    # Due to the endless wisdom of the creators of this tag set, the possessor's gender is encoded as a second "gen" at the end of the tag.
    if($f{possgender} eq "masc")
    {
        push(@features, "gen=m");
    }
    elsif($f{possgender} eq "fem")
    {
        push(@features, "gen=f");
    }
    elsif($f{possgender} eq "neut")
    {
        push(@features, "gen=n");
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
A\tA\t_
A\tAf\t_
A\tAf\tgen=f|num=s|def=d
A\tAf\tgen=f|num=s|def=i
A\tAm\t_
A\tAm\tgen=m|num=s|def=f
A\tAm\tgen=m|num=s|def=h
A\tAm\tgen=m|num=s|def=i
A\tAm\tgen=m|num=s|form=ext
A\tAn\tgen=n|num=s|def=d
A\tAn\tgen=n|num=s|def=i
A\tA\tnum=p|def=d
A\tA\tnum=p|def=i
C\tCc\t_
C\tCp\t_
C\tCr\t_
C\tCs\t_
D\tD\t_
D\tDd\t_
D\tDl\t_
D\tDm\t_
D\tDq\t_
D\tDt\t_
H\tHf\tgen=f|num=s|def=i
H\tHm\tgen=m|num=s|def=f
H\tHm\tgen=m|num=s|def=i
H\tHn\tgen=n|num=s|def=i
H\tH\tnum=p|def=i
I\tI\t_
M\tMc\t_
M\tMc\tdef=d
M\tMc\tdef=i
M\tMc\tgen=f|def=d
M\tMc\tgen=f|def=i
M\tMc\tgen=f|num=s|def=d
M\tMc\tgen=f|num=s|def=i
M\tMc\tgen=m|def=d
M\tMc\tgen=m|def=i
M\tMc\tgen=m|num=s|def=f
M\tMc\tgen=m|num=s|def=i
M\tMc\tgen=n|def=d
M\tMc\tgen=n|def=i
M\tMc\tgen=n|num=s|def=d
M\tMc\tgen=n|num=s|def=i
M\tMd\t_
M\tMd\tdef=d
M\tMd\tdef=i
M\tMo\tgen=f|num=s|def=d
M\tMo\tgen=f|num=s|def=i
M\tMo\tgen=m|num=s|def=f
M\tMo\tgen=m|num=s|def=h
M\tMo\tgen=m|num=s|def=i
M\tMo\tgen=n|num=s|def=d
M\tMo\tgen=n|num=s|def=i
M\tMo\tnum=p|def=d
M\tMo\tnum=p|def=i
M\tMy\t_
M\tMy\tdef=i
N\tN\t_
N\tNc\t_
N\tNc\tgen=f|num=p|def=d
N\tNc\tgen=f|num=p|def=i
N\tNc\tgen=f|num=s|case=v
N\tNc\tgen=f|num=s|def=d
N\tNc\tgen=m|num=p|def=d
N\tNc\tgen=m|num=p|def=i
N\tNc\tgen=m|num=s|case=v
N\tNc\tgen=m|num=s|def=d
N\tNc\tgen=m|num=s|def=f
N\tNc\tgen=m|num=s|def=h
N\tNc\tgen=m|num=s|def=i
N\tNc\tgen=m|num=t
N\tNc\tgen=n|num=p|def=d
N\tNc\tgen=n|num=p|def=i
N\tNc\tgen=n|num=s|def=d
N\tNc\tgen=n|num=s|def=i
N\tNc\tnum=pia_tantum|def=d
N\tNc\tnum=pia_tantum|def=i
N\tNm\t_
N\tNp\t_
N\tNp\tgen=f|num=p|def=d
N\tNp\tgen=f|num=p|def=i
N\tNp\tgen=f|num=s|case=v
N\tNp\tgen=f|num=s|def=i
N\tNp\tgen=m|num=p|def=d
N\tNp\tgen=m|num=p|def=i
N\tNp\tgen=m|num=s|case=a
N\tNp\tgen=m|num=s|case=v
N\tNp\tgen=m|num=s|def=f
N\tNp\tgen=m|num=s|def=h
N\tNp\tgen=m|num=s|def=i
N\tNp\tgen=n|num=p|def=d
N\tNp\tgen=n|num=p|def=i
N\tNp\tgen=n|num=s|def=d
N\tNp\tgen=n|num=s|def=i
N\tNp\tnum=pia_tantum|def=i
P\tP\t_
P\tPc\tref=a|num=p
P\tPc\tref=a|num=s|gen=f
P\tPc\tref=a|num=s|gen=m
P\tPc\tref=a|num=s|gen=n
P\tPc\tref=e|case=a|num=s|gen=m
P\tPc\tref=e|case=n|num=p
P\tPc\tref=e|case=n|num=s|gen=f
P\tPc\tref=e|case=n|num=s|gen=m
P\tPc\tref=e|case=n|num=s|gen=n
P\tPc\tref=l
P\tPc\tref=q|num=p|def=d
P\tPc\tref=q|num=s|gen=n|def=d
P\tPc\tref=t
P\tPd\t_
P\tPd\tref=a|num=p
P\tPd\tref=a|num=s|gen=f
P\tPd\tref=a|num=s|gen=n
P\tPd\tref=e|case=n|num=p
P\tPd\tref=e|case=n|num=s|gen=f
P\tPd\tref=e|case=n|num=s|gen=m
P\tPd\tref=e|case=n|num=s|gen=n
P\tPd\tref=l
P\tPd\tref=m
P\tPd\tref=q
P\tPd\tref=t
P\tPf\tdef=i|ref=a|num=p
P\tPf\tdef=i|ref=a|num=s|gen=f
P\tPf\tdef=i|ref=a|num=s|gen=m
P\tPf\tdef=i|ref=a|num=s|gen=n
P\tPf\tdef=i|ref=e|case=a|num=s|gen=m
P\tPf\tdef=i|ref=e|case=d|num=s|gen=m
P\tPf\tdef=i|ref=e|case=n|num=p
P\tPf\tdef=i|ref=e|case=n|num=p|def=d
P\tPf\tdef=i|ref=e|case=n|num=p|def=i
P\tPf\tdef=i|ref=e|case=n|num=s|gen=f
P\tPf\tdef=i|ref=e|case=n|num=s|gen=f|def=d
P\tPf\tdef=i|ref=e|case=n|num=s|gen=f|def=i
P\tPf\tdef=i|ref=e|case=n|num=s|gen=m
P\tPf\tdef=i|ref=e|case=n|num=s|gen=m|def=f
P\tPf\tdef=i|ref=e|case=n|num=s|gen=m|def=h
P\tPf\tdef=i|ref=e|case=n|num=s|gen=m|def=i
P\tPf\tdef=i|ref=e|case=n|num=s|gen=n
P\tPf\tdef=i|ref=e|case=n|num=s|gen=n|def=d
P\tPf\tdef=i|ref=e|case=n|num=s|gen=n|def=i
P\tPf\tdef=i|ref=l
P\tPf\tdef=i|ref=m
P\tPf\tdef=i|ref=p|num=p
P\tPf\tdef=i|ref=q|def=i
P\tPf\tdef=i|ref=t
P\tPi\tcause
P\tPi\tref=a|num=p
P\tPi\tref=a|num=s|gen=f
P\tPi\tref=a|num=s|gen=m
P\tPi\tref=a|num=s|gen=n
P\tPi\tref=e|case=a|num=s|gen=m
P\tPi\tref=e|case=n|num=p
P\tPi\tref=e|case=n|num=s|gen=f
P\tPi\tref=e|case=n|num=s|gen=m
P\tPi\tref=e|case=n|num=s|gen=n
P\tPi\tref=l
P\tPi\tref=m
P\tPi\tref=p|num=s|gen=f
P\tPi\tref=p|num=s|gen=m
P\tPi\tref=q
P\tPi\tref=t
P\tPn\t_
P\tPn\tref=a|num=p
P\tPn\tref=a|num=s|gen=f
P\tPn\tref=a|num=s|gen=m
P\tPn\tref=a|num=s|gen=n
P\tPn\tref=e|case=a|num=s|gen=m
P\tPn\tref=e|case=d|num=s|gen=m
P\tPn\tref=e|case=n|num=s|gen=f
P\tPn\tref=e|case=n|num=s|gen=m
P\tPn\tref=e|case=n|num=s|gen=n
P\tPn\tref=e|case=n|num=s|gen=n|def=d
P\tPn\tref=l
P\tPn\tref=m
P\tPn\tref=p|num=s|gen=f
P\tPn\tref=t
P\tPp\t_
P\tPp\tref=e|case=n|num=p|pers=1
P\tPp\tref=e|case=n|num=p|pers=2
P\tPp\tref=e|case=n|num=p|pers=3
P\tPp\tref=e|case=n|num=s|pers=1
P\tPp\tref=e|case=n|num=s|pers=2
P\tPp\tref=e|case=n|num=s|pers=3|gen=f
P\tPp\tref=e|case=n|num=s|pers=3|gen=m
P\tPp\tref=e|case=n|num=s|pers=3|gen=n
P\tPp\tref=e|form=f|case=a|num=p|pers=1
P\tPp\tref=e|form=f|case=a|num=p|pers=2
P\tPp\tref=e|form=f|case=a|num=p|pers=3
P\tPp\tref=e|form=f|case=a|num=s|pers=1
P\tPp\tref=e|form=f|case=a|num=s|pers=2
P\tPp\tref=e|form=f|case=a|num=s|pers=3|gen=f
P\tPp\tref=e|form=f|case=a|num=s|pers=3|gen=m
P\tPp\tref=e|form=f|case=a|num=s|pers=3|gen=n
P\tPp\tref=e|form=f|case=d|num=p|pers=1
P\tPp\tref=e|form=f|case=d|num=s|pers=1
P\tPp\tref=e|form=f|case=d|num=s|pers=2
P\tPp\tref=e|form=f|case=d|num=s|pers=3|gen=m
P\tPp\tref=e|form=s|case=a|num=p|pers=1
P\tPp\tref=e|form=s|case=a|num=p|pers=2
P\tPp\tref=e|form=s|case=a|num=p|pers=3
P\tPp\tref=e|form=s|case=a|num=s|pers=1
P\tPp\tref=e|form=s|case=a|num=s|pers=2
P\tPp\tref=e|form=s|case=a|num=s|pers=3|gen=f
P\tPp\tref=e|form=s|case=a|num=s|pers=3|gen=m
P\tPp\tref=e|form=s|case=a|num=s|pers=3|gen=n
P\tPp\tref=e|form=s|case=d|num=p|pers=1
P\tPp\tref=e|form=s|case=d|num=p|pers=2
P\tPp\tref=e|form=s|case=d|num=p|pers=3
P\tPp\tref=e|form=s|case=d|num=s|pers=1
P\tPp\tref=e|form=s|case=d|num=s|pers=2
P\tPp\tref=e|form=s|case=d|num=s|pers=3|gen=f
P\tPp\tref=e|form=s|case=d|num=s|pers=3|gen=m
P\tPp\tref=e|form=s|case=d|num=s|pers=3|gen=n
P\tPp\tref=e|form=s|case=dp|num=p|pers=1
P\tPp\tref=e|form=s|case=dp|num=p|pers=2
P\tPp\tref=e|form=s|case=dp|num=p|pers=3
P\tPp\tref=e|form=s|case=dp|num=s|pers=1
P\tPp\tref=e|form=s|case=dp|num=s|pers=2
P\tPp\tref=e|form=s|case=dp|num=s|pers=3|gen=f
P\tPp\tref=e|form=s|case=dp|num=s|pers=3|gen=m
P\tPp\tref=r|form=f|case=a
P\tPp\tref=r|form=s|case=a
P\tPp\tref=r|form=s|case=d
P\tPp\tref=r|form=s|case=dp
P\tPr\t_
P\tPr\tref=a|num=p
P\tPr\tref=a|num=s|gen=f
P\tPr\tref=a|num=s|gen=m
P\tPr\tref=a|num=s|gen=n
P\tPr\tref=e|case=a|num=s|gen=m
P\tPr\tref=e|case=d|num=s|gen=m
P\tPr\tref=e|case=n|num=p
P\tPr\tref=e|case=n|num=s|gen=f
P\tPr\tref=e|case=n|num=s|gen=m
P\tPr\tref=e|case=n|num=s|gen=n
P\tPr\tref=e|num=s
P\tPr\tref=l
P\tPr\tref=m
P\tPr\tref=p|num=p
P\tPr\tref=p|num=s|gen=f
P\tPr\tref=p|num=s|gen=m
P\tPr\tref=p|num=s|gen=n
P\tPr\tref=q
P\tPr\tref=t
P\tPs\t_
P\tPs\tref=mp|form=f|num=p|pers=1|def=d
P\tPs\tref=mp|form=f|num=p|pers=1|def=i
P\tPs\tref=mp|form=f|num=p|pers=2|def=d
P\tPs\tref=mp|form=f|num=p|pers=3|def=d
P\tPs\tref=mp|form=f|num=p|pers=3|def=i
P\tPs\tref=mp|form=f|num=s|pers=1|gen=f|def=d
P\tPs\tref=mp|form=f|num=s|pers=1|gen=f|def=i
P\tPs\tref=mp|form=f|num=s|pers=1|gen=m|def=f
P\tPs\tref=mp|form=f|num=s|pers=1|gen=m|def=h
P\tPs\tref=mp|form=f|num=s|pers=1|gen=m|def=i
P\tPs\tref=mp|form=f|num=s|pers=1|gen=n|def=d
P\tPs\tref=mp|form=f|num=s|pers=1|gen=n|def=i
P\tPs\tref=mp|form=f|num=s|pers=2|gen=f|def=d
P\tPs\tref=mp|form=f|num=s|pers=2|gen=f|def=i
P\tPs\tref=mp|form=f|num=s|pers=2|gen=m|def=h
P\tPs\tref=mp|form=f|num=s|pers=2|gen=m|def=i
P\tPs\tref=mp|form=f|num=s|pers=2|gen=n|def=d
P\tPs\tref=mp|form=f|num=s|pers=2|gen=n|def=i
P\tPs\tref=mp|form=f|num=s|pers=3|gen=f|def=d
P\tPs\tref=mp|form=f|num=s|pers=3|gen=f|def=i
P\tPs\tref=mp|form=f|num=s|pers=3|gen=m|def=f
P\tPs\tref=mp|form=f|num=s|pers=3|gen=m|def=h
P\tPs\tref=mp|form=f|num=s|pers=3|gen=m|def=i
P\tPs\tref=mp|form=f|num=s|pers=3|gen=n|def=d
P\tPs\tref=mp|form=f|num=s|pers=3|gen=n|def=i
P\tPs\tref=mp|form=s|pers=1
P\tPs\tref=mp|form=s|pers=2
P\tPs\tref=mp|form=s|pers=3
P\tPs\tref=op|form=f|num=p|pers=1|def=d
P\tPs\tref=op|form=f|num=p|pers=1|def=i
P\tPs\tref=op|form=f|num=p|pers=2|def=d
P\tPs\tref=op|form=f|num=p|pers=3|def=d|gen=f
P\tPs\tref=op|form=f|num=p|pers=3|def=d|gen=m
P\tPs\tref=op|form=f|num=p|pers=3|def=d|gen=n
P\tPs\tref=op|form=f|num=p|pers=3|def=i|gen=f
P\tPs\tref=op|form=f|num=p|pers=3|def=i|gen=m
P\tPs\tref=op|form=f|num=s|pers=1|gen=f|def=d
P\tPs\tref=op|form=f|num=s|pers=1|gen=f|def=i
P\tPs\tref=op|form=f|num=s|pers=1|gen=m|def=f
P\tPs\tref=op|form=f|num=s|pers=1|gen=m|def=h
P\tPs\tref=op|form=f|num=s|pers=1|gen=m|def=i
P\tPs\tref=op|form=f|num=s|pers=1|gen=n|def=d
P\tPs\tref=op|form=f|num=s|pers=1|gen=n|def=i
P\tPs\tref=op|form=f|num=s|pers=2|gen=f|def=d
P\tPs\tref=op|form=f|num=s|pers=2|gen=f|def=i
P\tPs\tref=op|form=f|num=s|pers=2|gen=n|def=i
P\tPs\tref=op|form=f|num=s|pers=3|gen=f|def=d|gen=f
P\tPs\tref=op|form=f|num=s|pers=3|gen=f|def=d|gen=m
P\tPs\tref=op|form=f|num=s|pers=3|gen=f|def=d|gen=n
P\tPs\tref=op|form=f|num=s|pers=3|gen=f|def=i|gen=f
P\tPs\tref=op|form=f|num=s|pers=3|gen=f|def=i|gen=m
P\tPs\tref=op|form=f|num=s|pers=3|gen=m|def=f|gen=f
P\tPs\tref=op|form=f|num=s|pers=3|gen=m|def=f|gen=m
P\tPs\tref=op|form=f|num=s|pers=3|gen=m|def=h|gen=f
P\tPs\tref=op|form=f|num=s|pers=3|gen=m|def=h|gen=m
P\tPs\tref=op|form=f|num=s|pers=3|gen=m|def=h|gen=n
P\tPs\tref=op|form=f|num=s|pers=3|gen=m|def=i|gen=f
P\tPs\tref=op|form=f|num=s|pers=3|gen=m|def=i|gen=m
P\tPs\tref=op|form=f|num=s|pers=3|gen=m|def=i|gen=n
P\tPs\tref=op|form=f|num=s|pers=3|gen=n|def=d|gen=f
P\tPs\tref=op|form=f|num=s|pers=3|gen=n|def=d|gen=m
P\tPs\tref=op|form=f|num=s|pers=3|gen=n|def=d|gen=n
P\tPs\tref=op|form=f|num=s|pers=3|gen=n|def=i|gen=f
P\tPs\tref=op|form=f|num=s|pers=3|gen=n|def=i|gen=m
P\tPs\tref=op|form=f|num=s|pers=3|gen=n|def=i|gen=n
P\tPs\tref=op|form=s|pers=1
P\tPs\tref=op|form=s|pers=2
P\tPs\tref=op|form=s|pers=3|gen=f
P\tPs\tref=op|form=s|pers=3|gen=m
P\tPs\tref=op|form=s|pers=3|gen=n
P\tPs\tref=r|form=f|case=n|num=p|def=d
P\tPs\tref=r|form=f|case=n|num=p|def=i
P\tPs\tref=r|form=f|case=n|num=s|gen=f|def=d
P\tPs\tref=r|form=f|case=n|num=s|gen=m|def=h
P\tPs\tref=r|form=f|case=n|num=s|gen=m|def=i
P\tPs\tref=r|form=f|case=n|num=s|gen=n|def=d
P\tPs\tref=r|form=f|case=n|num=s|gen=n|def=i
P\tPs\tref=r|form=s|case=n
Punct\tPunct\t_
R\tR\t_
T\tTa\t_
T\tTe\t_
T\tTg\t_
T\tTi\t_
T\tTm\t_
T\tTn\t_
T\tTv\t_
T\tTx\t_
V\tV\t_
V\tVii\ttype=aux|trans=t|mood=i|tense=r|pers=3|num=p
V\tVii\ttype=aux|trans=t|mood=i|tense=r|pers=3|num=s
V\tVni\timtrans=i|mood=i|tense=m|pers=3|num=s
V\tVni\timtrans=i|mood=i|tense=o|pers=3|num=s
V\tVni\timtrans=i|mood=i|tense=r|pers=3|num=s
V\tVni\timtrans=i|vform=c|voice=a|tense=m|num=s|gen=n|def=i
V\tVni\timtrans=i|vform=c|voice=a|tense=o|num=s|gen=n|def=i
V\tVni\timtrans=t|mood=i|tense=m|pers=3|num=s
V\tVni\timtrans=t|mood=i|tense=o|pers=3|num=s
V\tVni\timtrans=t|mood=i|tense=r|pers=3|num=s
V\tVni\timtrans=t|vform=c|voice=a|tense=m|num=s|gen=n|def=i
V\tVni\timtrans=t|vform=c|voice=a|tense=o|num=s|gen=n|def=i
V\tVnp\ttrans=i|mood=i|tense=o|pers=3|num=s
V\tVnp\ttrans=i|mood=i|tense=r|pers=3|num=s
V\tVnp\ttrans=i|vform=c|voice=a|tense=o|num=s|gen=n|def=i
V\tVnp\ttrans=t|mood=i|tense=m|pers=3|num=s
V\tVnp\ttrans=t|vform=c|voice=a|tense=o|num=s|gen=n|def=i
V\tVpi\t_
V\tVpi\ttrans=i|mood=i|tense=m|pers=1|num=p
V\tVpi\ttrans=i|mood=i|tense=m|pers=1|num=s
V\tVpi\ttrans=i|mood=i|tense=m|pers=2|num=s
V\tVpi\ttrans=i|mood=i|tense=m|pers=3|num=p
V\tVpi\ttrans=i|mood=i|tense=m|pers=3|num=s
V\tVpi\ttrans=i|mood=i|tense=o|pers=1|num=p
V\tVpi\ttrans=i|mood=i|tense=o|pers=1|num=s
V\tVpi\ttrans=i|mood=i|tense=o|pers=3|num=p
V\tVpi\ttrans=i|mood=i|tense=o|pers=3|num=s
V\tVpi\ttrans=i|mood=i|tense=r|pers=1|num=p
V\tVpi\ttrans=i|mood=i|tense=r|pers=1|num=s
V\tVpi\ttrans=i|mood=i|tense=r|pers=2|num=p
V\tVpi\ttrans=i|mood=i|tense=r|pers=2|num=s
V\tVpi\ttrans=i|mood=i|tense=r|pers=3|num=p
V\tVpi\ttrans=i|mood=i|tense=r|pers=3|num=s
V\tVpi\ttrans=i|mood=z|pers=2|num=p
V\tVpi\ttrans=i|mood=z|pers=2|num=s
V\tVpi\ttrans=i|vform=c|voice=a|tense=m|num=p|def=i
V\tVpi\ttrans=i|vform=c|voice=a|tense=m|num=s|gen=f|def=i
V\tVpi\ttrans=i|vform=c|voice=a|tense=m|num=s|gen=m|def=i
V\tVpi\ttrans=i|vform=c|voice=a|tense=m|num=s|gen=n|def=i
V\tVpi\ttrans=i|vform=c|voice=a|tense=o|num=p|def=d
V\tVpi\ttrans=i|vform=c|voice=a|tense=o|num=p|def=i
V\tVpi\ttrans=i|vform=c|voice=a|tense=o|num=s|gen=f|def=i
V\tVpi\ttrans=i|vform=c|voice=a|tense=o|num=s|gen=m|def=f
V\tVpi\ttrans=i|vform=c|voice=a|tense=o|num=s|gen=m|def=i
V\tVpi\ttrans=i|vform=c|voice=a|tense=o|num=s|gen=n|def=i
V\tVpi\ttrans=i|vform=c|voice=a|tense=r|num=p|def=d
V\tVpi\ttrans=i|vform=c|voice=a|tense=r|num=p|def=i
V\tVpi\ttrans=i|vform=c|voice=a|tense=r|num=s|gen=f|def=d
V\tVpi\ttrans=i|vform=c|voice=a|tense=r|num=s|gen=f|def=i
V\tVpi\ttrans=i|vform=c|voice=a|tense=r|num=s|gen=m|def=f
V\tVpi\ttrans=i|vform=c|voice=a|tense=r|num=s|gen=m|def=h
V\tVpi\ttrans=i|vform=c|voice=a|tense=r|num=s|gen=m|def=i
V\tVpi\ttrans=i|vform=c|voice=a|tense=r|num=s|gen=n|def=d
V\tVpi\ttrans=i|vform=c|voice=a|tense=r|num=s|gen=n|def=i
V\tVpi\ttrans=i|vform=g
V\tVpi\ttrans=t|mood=i|tense=m|pers=1|num=p
V\tVpi\ttrans=t|mood=i|tense=m|pers=1|num=s
V\tVpi\ttrans=t|mood=i|tense=m|pers=2|num=p
V\tVpi\ttrans=t|mood=i|tense=m|pers=2|num=s
V\tVpi\ttrans=t|mood=i|tense=m|pers=3|num=p
V\tVpi\ttrans=t|mood=i|tense=m|pers=3|num=s
V\tVpi\ttrans=t|mood=i|tense=o|pers=1|num=p
V\tVpi\ttrans=t|mood=i|tense=o|pers=1|num=s
V\tVpi\ttrans=t|mood=i|tense=o|pers=2|num=p
V\tVpi\ttrans=t|mood=i|tense=o|pers=2|num=s
V\tVpi\ttrans=t|mood=i|tense=o|pers=3|num=p
V\tVpi\ttrans=t|mood=i|tense=o|pers=3|num=s
V\tVpi\ttrans=t|mood=i|tense=r|pers=1|num=p
V\tVpi\ttrans=t|mood=i|tense=r|pers=1|num=s
V\tVpi\ttrans=t|mood=i|tense=r|pers=2|num=p
V\tVpi\ttrans=t|mood=i|tense=r|pers=2|num=s
V\tVpi\ttrans=t|mood=i|tense=r|pers=3|num=p
V\tVpi\ttrans=t|mood=i|tense=r|pers=3|num=s
V\tVpi\ttrans=t|mood=z|pers=2|num=p
V\tVpi\ttrans=t|mood=z|pers=2|num=s
V\tVpi\ttrans=t|vform=c|voice=a|tense=m|num=p|def=i
V\tVpi\ttrans=t|vform=c|voice=a|tense=m|num=s|gen=f|def=i
V\tVpi\ttrans=t|vform=c|voice=a|tense=m|num=s|gen=m|def=i
V\tVpi\ttrans=t|vform=c|voice=a|tense=m|num=s|gen=n|def=i
V\tVpi\ttrans=t|vform=c|voice=a|tense=o|num=p|def=i
V\tVpi\ttrans=t|vform=c|voice=a|tense=o|num=s|gen=f|def=i
V\tVpi\ttrans=t|vform=c|voice=a|tense=o|num=s|gen=m|def=i
V\tVpi\ttrans=t|vform=c|voice=a|tense=o|num=s|gen=n|def=i
V\tVpi\ttrans=t|vform=c|voice=a|tense=r|num=p|def=d
V\tVpi\ttrans=t|vform=c|voice=a|tense=r|num=p|def=i
V\tVpi\ttrans=t|vform=c|voice=a|tense=r|num=s|gen=f|def=d
V\tVpi\ttrans=t|vform=c|voice=a|tense=r|num=s|gen=f|def=i
V\tVpi\ttrans=t|vform=c|voice=a|tense=r|num=s|gen=m|def=f
V\tVpi\ttrans=t|vform=c|voice=a|tense=r|num=s|gen=m|def=h
V\tVpi\ttrans=t|vform=c|voice=a|tense=r|num=s|gen=n|def=d
V\tVpi\ttrans=t|vform=c|voice=a|tense=r|num=s|gen=n|def=i
V\tVpi\ttrans=t|vform=c|voice=v|num=p|def=d
V\tVpi\ttrans=t|vform=c|voice=v|num=p|def=i
V\tVpi\ttrans=t|vform=c|voice=v|num=s|gen=f|def=d
V\tVpi\ttrans=t|vform=c|voice=v|num=s|gen=f|def=i
V\tVpi\ttrans=t|vform=c|voice=v|num=s|gen=m|def=f
V\tVpi\ttrans=t|vform=c|voice=v|num=s|gen=m|def=h
V\tVpi\ttrans=t|vform=c|voice=v|num=s|gen=m|def=i
V\tVpi\ttrans=t|vform=c|voice=v|num=s|gen=n|def=d
V\tVpi\ttrans=t|vform=c|voice=v|num=s|gen=n|def=i
V\tVpi\ttrans=t|vform=g
V\tVpp\t_
V\tVpp\taspect=p|trans=i|mood=i|tense=m|pers=3|num=p
V\tVpp\taspect=p|trans=i|mood=i|tense=m|pers=3|num=s
V\tVpp\taspect=p|trans=i|mood=i|tense=o|pers=1|num=p
V\tVpp\taspect=p|trans=i|mood=i|tense=o|pers=1|num=s
V\tVpp\taspect=p|trans=i|mood=i|tense=o|pers=2|num=p
V\tVpp\taspect=p|trans=i|mood=i|tense=o|pers=2|num=s
V\tVpp\taspect=p|trans=i|mood=i|tense=o|pers=3|num=p
V\tVpp\taspect=p|trans=i|mood=i|tense=o|pers=3|num=s
V\tVpp\taspect=p|trans=i|mood=i|tense=r|pers=1|num=p
V\tVpp\taspect=p|trans=i|mood=i|tense=r|pers=1|num=s
V\tVpp\taspect=p|trans=i|mood=i|tense=r|pers=2|num=p
V\tVpp\taspect=p|trans=i|mood=i|tense=r|pers=2|num=s
V\tVpp\taspect=p|trans=i|mood=i|tense=r|pers=3|num=p
V\tVpp\taspect=p|trans=i|mood=i|tense=r|pers=3|num=s
V\tVpp\taspect=p|trans=i|mood=z|pers=2|num=p
V\tVpp\taspect=p|trans=i|mood=z|pers=2|num=s
V\tVpp\taspect=p|trans=i|vform=c|voice=a|tense=m|num=s|gen=n|def=i
V\tVpp\taspect=p|trans=i|vform=c|voice=a|tense=o|num=p|def=d
V\tVpp\taspect=p|trans=i|vform=c|voice=a|tense=o|num=p|def=i
V\tVpp\taspect=p|trans=i|vform=c|voice=a|tense=o|num=s|gen=f|def=d
V\tVpp\taspect=p|trans=i|vform=c|voice=a|tense=o|num=s|gen=f|def=i
V\tVpp\taspect=p|trans=i|vform=c|voice=a|tense=o|num=s|gen=m|def=f
V\tVpp\taspect=p|trans=i|vform=c|voice=a|tense=o|num=s|gen=m|def=h
V\tVpp\taspect=p|trans=i|vform=c|voice=a|tense=o|num=s|gen=m|def=i
V\tVpp\taspect=p|trans=i|vform=c|voice=a|tense=o|num=s|gen=n|def=d
V\tVpp\taspect=p|trans=i|vform=c|voice=a|tense=o|num=s|gen=n|def=i
V\tVpp\taspect=p|trans=t|mood=i|tense=m|pers=1|num=p
V\tVpp\taspect=p|trans=t|mood=i|tense=m|pers=1|num=s
V\tVpp\taspect=p|trans=t|mood=i|tense=m|pers=3|num=p
V\tVpp\taspect=p|trans=t|mood=i|tense=m|pers=3|num=s
V\tVpp\taspect=p|trans=t|mood=i|tense=o|pers=1|num=p
V\tVpp\taspect=p|trans=t|mood=i|tense=o|pers=1|num=s
V\tVpp\taspect=p|trans=t|mood=i|tense=o|pers=2|num=p
V\tVpp\taspect=p|trans=t|mood=i|tense=o|pers=2|num=s
V\tVpp\taspect=p|trans=t|mood=i|tense=o|pers=3|num=p
V\tVpp\taspect=p|trans=t|mood=i|tense=o|pers=3|num=s
V\tVpp\taspect=p|trans=t|mood=i|tense=r|pers=1|num=p
V\tVpp\taspect=p|trans=t|mood=i|tense=r|pers=1|num=s
V\tVpp\taspect=p|trans=t|mood=i|tense=r|pers=2|num=p
V\tVpp\taspect=p|trans=t|mood=i|tense=r|pers=2|num=s
V\tVpp\taspect=p|trans=t|mood=i|tense=r|pers=3|num=p
V\tVpp\taspect=p|trans=t|mood=i|tense=r|pers=3|num=s
V\tVpp\taspect=p|trans=t|mood=z|pers=2|num=p
V\tVpp\taspect=p|trans=t|mood=z|pers=2|num=s
V\tVpp\taspect=p|trans=t|vform=c|voice=a|tense=m|num=s|gen=m|def=i
V\tVpp\taspect=p|trans=t|vform=c|voice=a|tense=o|num=p|def=d
V\tVpp\taspect=p|trans=t|vform=c|voice=a|tense=o|num=p|def=i
V\tVpp\taspect=p|trans=t|vform=c|voice=a|tense=o|num=s|gen=f|def=d
V\tVpp\taspect=p|trans=t|vform=c|voice=a|tense=o|num=s|gen=f|def=i
V\tVpp\taspect=p|trans=t|vform=c|voice=a|tense=o|num=s|gen=m|def=h
V\tVpp\taspect=p|trans=t|vform=c|voice=a|tense=o|num=s|gen=m|def=i
V\tVpp\taspect=p|trans=t|vform=c|voice=a|tense=o|num=s|gen=n|def=d
V\tVpp\taspect=p|trans=t|vform=c|voice=a|tense=o|num=s|gen=n|def=i
V\tVpp\taspect=p|trans=t|vform=c|voice=v|num=p|def=d
V\tVpp\taspect=p|trans=t|vform=c|voice=v|num=p|def=i
V\tVpp\taspect=p|trans=t|vform=c|voice=v|num=s|gen=f|def=d
V\tVpp\taspect=p|trans=t|vform=c|voice=v|num=s|gen=f|def=i
V\tVpp\taspect=p|trans=t|vform=c|voice=v|num=s|gen=m|def=h
V\tVpp\taspect=p|trans=t|vform=c|voice=v|num=s|gen=m|def=i
V\tVpp\taspect=p|trans=t|vform=c|voice=v|num=s|gen=n|def=d
V\tVpp\taspect=p|trans=t|vform=c|voice=v|num=s|gen=n|def=i
V\tVxi\ttype=aux|trans=t|mood=i|past|pers=1|num=p
V\tVxi\ttype=aux|trans=t|mood=i|past|pers=1|num=s
V\tVxi\ttype=aux|trans=t|mood=i|past|pers=2|num=p
V\tVxi\ttype=aux|trans=t|mood=i|past|pers=2|num=s
V\tVxi\ttype=aux|trans=t|mood=i|past|pers=3|num=p
V\tVxi\ttype=aux|trans=t|mood=i|past|pers=3|num=s
V\tVxi\ttype=aux|trans=t|mood=i|tense=r|pers=1|num=p
V\tVxi\ttype=aux|trans=t|mood=i|tense=r|pers=1|num=s
V\tVxi\ttype=aux|trans=t|mood=i|tense=r|pers=2|num=p
V\tVxi\ttype=aux|trans=t|mood=i|tense=r|pers=2|num=s
V\tVxi\ttype=aux|trans=t|mood=i|tense=r|pers=3|num=p
V\tVxi\ttype=aux|trans=t|mood=i|tense=r|pers=3|num=s
V\tVxi\ttype=aux|trans=t|mood=u|tense=o|pers=1|num=p
V\tVxi\ttype=aux|trans=t|mood=u|tense=o|pers=1|num=s
V\tVxi\ttype=aux|trans=t|mood=u|tense=o|pers=2|num=p
V\tVxi\ttype=aux|trans=t|mood=u|tense=o|pers=2|num=s
V\tVxi\ttype=aux|trans=t|mood=u|tense=o|pers=3|num=p
V\tVxi\ttype=aux|trans=t|mood=u|tense=o|pers=3|num=s
V\tVxi\ttype=aux|trans=t|vform=c|voice=a|past|num=p|def=i
V\tVxi\ttype=aux|trans=t|vform=c|voice=a|past|num=s|gen=f|def=i
V\tVxi\ttype=aux|trans=t|vform=c|voice=a|past|num=s|gen=m|def=i
V\tVxi\ttype=aux|trans=t|vform=c|voice=a|past|num=s|gen=n|def=i
V\tVyp\ttype=aux|aspect=p|trans=t|mood=i|tense=o|pers=3|num=s
V\tVyp\ttype=aux|aspect=p|trans=t|mood=i|tense=r|pers=1|num=p
V\tVyp\ttype=aux|aspect=p|trans=t|mood=i|tense=r|pers=1|num=s
V\tVyp\ttype=aux|aspect=p|trans=t|mood=i|tense=r|pers=2|num=p
V\tVyp\ttype=aux|aspect=p|trans=t|mood=i|tense=r|pers=2|num=s
V\tVyp\ttype=aux|aspect=p|trans=t|mood=i|tense=r|pers=3|num=p
V\tVyp\ttype=aux|aspect=p|trans=t|mood=i|tense=r|pers=3|num=s
V\tVyp\ttype=aux|aspect=p|trans=t|mood=z|pers=2|num=s
end_of_list
    ;
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
