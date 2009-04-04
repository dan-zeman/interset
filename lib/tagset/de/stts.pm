#!/usr/bin/perl
# Driver for the Stuttgart-Tübingen Tagset.
# (c) 2008 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::de::stts;
use utf8;



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = "de::stts";
    # There are the following 54 tags:
    # ADJA ADJD
    # ADV
    # APPR APPRART APPO APZR
    # ART
    # CARD
    # FM
    # ITJ
    # KOUI KOUS KON KOKOM
    # NN NE
    # PDS PDAT PIS PIAT PIDAT PPER PPOSS PPOSAT PRELS PRELAT PRF PWS PWAT PWAV PAV
    # PTKZU PTKNEG PTKVZ PTKANT PTKA
    # TRUNC
    # VVFIN VVIMP VVINF VVIZU VVPP VAFIN VAIMP VAINF VAPP VMFIN VMINF VMPP
    # XY
    # $, $. $(
    if($tag eq "NN")
    {
        # common noun / normales Nomen
        $f{pos} = "noun";
    }
    elsif($tag eq "NE")
    {
        # proper noun / Eigenname
        $f{pos} = "noun";
        $f{subpos} = "prop";
    }
    elsif($tag eq "TRUNC")
    {
        # truncated first part of a compound / Kompositions-Erstglied
        # "be- [und entladen]", "Ein- [und Ausgang]", "Damen- [und Herrenbekleidung]"
        $f{hyph} = "hyph";
    }
    elsif($tag eq "ADJA")
    {
        # attributive adjective / attributives Adjektiv
        # modifies a noun
        # all inflected adjectives belong here; some uninflected as well
        $f{pos} = "adj";
        $f{synpos} = "attr";
    }
    elsif($tag eq "ADJD")
    {
        # predicative or adverbial adjective / prädikatives oder adverbiales Adjektiv
        # also if modifying another adjective
        $f{pos} = "adj";
        $f{synpos} = "pred";
    }
    elsif($tag eq "ART")
    {
        # article / Artikel
        $f{pos} = "adj";
        $f{subpos} = "det";
    }
    elsif($tag =~ m/^P[PDWRIA]/)
    {
        # pronoun / Pronomen
        if($tag eq "PPER")
        {
            # irreflexive personal pronoun / irreflexives Personalpronomen
            # "ich", "du", "er", "sie", "es", "wir", "ihr"
            # "mir", "mich", "dir", ... when used irreflexively ("er begegnet mir hier")
            # "meiner", ... when it is genitive of "ich" (and not a possessive pronoun)
            $f{pos} = "noun";
            $f{prontype} = "prs";
        }
        elsif($tag eq "PRF")
        {
            # reflexive personal pronoun / reflexives Personalpronomen
            # "mir", "mich", "dir", "dich", ... when used reflexively ("ich freue mich daran")
            # "einander" ("sie mögen sich einander")
            $f{pos} = "noun";
            $f{prontype} = "prs";
            $f{reflex} = "reflex";
        }
        else
        {
            if($tag =~ m/S$/)
            {
                # substitutive pronoun / substituierendes Pronomen
                # occurs instead of a noun phrase
                $f{pos} = "noun";
            }
            elsif($tag =~ m/AT$/)
            {
                # attributive pronoun / attribuierendes Pronomen
                # occurs inside a noun phrase
                $f{pos} = "adj";
            }
            elsif($tag =~ m/AV$/)
            {
                # adverbial pronoun or pronominal adverb / Adverbialpronomen oder Pronominaladverb
                $f{pos} = "adv";
            }
            if($tag =~ m/^PPOS/)
            {
                # possessive pronoun / Possessivpronomen
                # PPOSAT: "mein", "dein", "sein", "ihr", "unser", "euer" ... "ihr Kleid", "euer Auto"
                # PPOSS: "[das ist] meins"
                $f{prontype} = "prs";
                $f{poss} = "poss";
            }
            elsif($tag =~ m/^PD/ || $tag eq "PAV")
            {
                # demonstrative pronoun / Demonstrativpronomen
                # PDS: "dies [ist ein Buch]", "jenes [ist schwierig]"
                # PDAT: "dieses [Buch]", "jene [Frage]"
                # (demonstrative) pronominal adverb / (Demonstrativ-) Pronominaladverb
                # PAV: "darauf", "hierzu", "deswegen", "außerdem"
                $f{prontype} = "dem";
            }
            elsif($tag =~ m/^PW/)
            {
                # interrogative pronoun / Interrogativpronomen
                # PWS: "wer", "was" ... "was ist los?", "wer ist da?"
                # PWAT: "wessen", "welche", ...
                # PWAV: "wann", "wo", "warum", "worüber", "weshalb" ...
                $f{prontype} = "int";
            }
            elsif($tag =~ m/^PREL/)
            {
                # relative pronoun / Relativpronomen
                # PRELS: "was", "welcher" ... "[derjenige], welcher", "[das], was"
                # PRELAT: "dessen" ... "[der Mann,] dessen [Hut]"
                $f{prontype} = "rel";
            }
            elsif($tag =~ m/^PI/)
            {
                # indefinite pronoun / Indefinitpronomen
                # PIS: "etwas", "nichts", "irgendwas", "man"
                # PIAT: "etliche [Dinge]", "zuviele [Fragen]", "etwas [Schokolade]"
                # PIDAT: with determiner: "all [die Bücher]", "solch [eine Frage]", "beide [Fragen]", "viele [Leute]"
                $f{prontype} = "ind";
                if($tag =~ m/^PID/)
                {
                    # equivalent to predeterminers in English
                    $f{subpos} = "pdt";
                }
            }
        }
    }
    elsif($tag eq "CARD")
    {
        # cardinal number / Kardinalzahl
        $f{pos} = "num";
        $f{numtype} = "card";
    }
    elsif($tag =~ m/^V(.)(.*)/)
    {
        my $verbclass = $1;
        my $verbform = $2;
        # verb / Verb
        $f{pos} = "verb";
        if($verbclass eq "A")
        {
            $f{subpos} = "aux";
        }
        elsif($verbclass eq "M")
        {
            $f{subpos} = "mod";
        }
        # verbform
        if($verbform eq "FIN")
        {
            $f{verbform} = "fin";
            $f{mood} = "ind";
        }
        elsif($verbform eq "IMP")
        {
            $f{verbform} = "fin";
            $f{mood} = "imp";
        }
        elsif($verbform eq "INF")
        {
            $f{verbform} = "inf";
        }
        elsif($verbform eq "IZU")
        {
            # infinitive with "zu": "abzukommen"
            $f{verbform} = "inf";
            $f{subpos} = "inf";
        }
        elsif($verbform eq "PP")
        {
            # perfect participle / Partizip Perfekt
            $f{verbform} = "part";
            $f{aspect} = "perf";
        }
    }
    elsif($tag eq "ADV")
    {
        # adverb / Adverb
        # "dort", "da", "heute", "dann", "gerne", "sehr", "darum", "sonst", "ja", "aber", "denn"
        # "miteinander", "nebeneinander", ...
        # "erstens", "zweitens", "drittens", ...
        # "einmal", "zweimal", "dreimal", ...
        # "bzw.", "u.a.", "z.B."
        $f{pos} = "adv";
    }
    elsif($tag =~ m/^AP/)
    {
        # adposition / Adposition
        # APPR APPRART APPO APZR
        $f{pos} = "prep";
        if($tag eq "APPRART")
        {
            # preposition with article / Präposition mit Artikel
            # "zum", "zur", "aufs", "vom", "im"
            $f{subpos} = "det";
        }
        elsif($tag eq "APPO")
        {
            # postposition / Postposition
            # "[der Straße] entlang"
            # beware: same word in "entlang [der Straße]" is preposition
            $f{subpos} = "post";
        }
        elsif($tag eq "APZR")
        {
            # second part of circumposition / zweiter Teil einer Zirkumposition
            # (the first part is tagged as preposition)
            # "[von dieser Stelle] an"
            $f{subpos} = "circ";
        }
    }
    elsif($tag =~ m/^KO/)
    {
        # conjunction / Konjunktion
        # KOUI KOUS KON KOKOM
        $f{pos} = "conj";
        if($tag eq "KOUI")
        {
            # subordinating conjunction with infinitive / unterordnende Konjunktion mit Infinitiv
            # "ohne [zu]", "statt [zu]"
            $f{subpos} = "sub";
            $f{other} = "zu";
        }
        elsif($tag eq "KOUS")
        {
            # subordinating conjunction with sentence / unterordnende Konjunktion mit Satz
            # "daß", "weil", "wenn", "obwohl", "als", "damit"
            $f{subpos} = "sub";
        }
        elsif($tag eq "KON")
        {
            # coordinating conjunction / nebenordnende Konjunktion
            # "und", "oder", "entweder ... oder", "weder ... noch", "denn", "aber", "doch", "jedoch"
            $f{subpos} = "coor";
        }
        elsif($tag eq "KOKOM")
        {
            # comparative particle without sentence / Vergleichspartikel ohne Satz
            # "als", "wie"
            $f{subpos} = "comp";
        }
    }
    elsif($tag =~ m/^PTK/)
    {
        # particle / Partikel
        # PTKZU PTKNEG PTKVZ PTKA PTKANT
        $f{pos} = "part";
        if($tag eq "PTKZU")
        {
            # "zu" before infinitive or future participle / "zu" vor Infinitiv oder Partizipien Futur
            # "[ohne] zu [wollen]", "[in der] zu [zerstörenden Stadt]"
            $f{subpos} = "inf";
        }
        elsif($tag eq "PTKNEG")
        {
            # negation particle / Negationspartikel
            # "nicht"
            $f{negativeness} = "neg";
        }
        elsif($tag eq "PTKVZ")
        {
            # separated verb prefix / abgetrennter Verbzusatz
            # "[er hört] auf", "[er kommt] herbei"
            $f{subpos} = "vbp";
        }
        elsif($tag eq "PTKA")
        {
            # particle with adjective or adverb / Partikel bei Adjektiv oder Adverb
            # "am [besten]", "[er ist] zu [groß]", "[er fährt] zu [schnell]"
            # $f{subpos} = ""; # default;
        }
        elsif($tag eq "PTKANT")
        {
            # response particle / Antwortpartikel
            # "ja", "nein", "danke", "bitte", "doch"
            $f{subpos} = "res";
        }
    }
    elsif($tag eq "ITJ")
    {
        # interjection / Interjektion
        $f{pos} = "int";
    }
    elsif($tag =~ m/^\$/)
    {
        # punctuation / Interpunktion
        $f{pos} = "punc";
        if($tag eq "\$,")
        {
            # comma / Komma
            $f{punctype} = "comm";
        }
        elsif($tag eq "\$(")
        {
            # sentence-internal, non-comma / satzintern, nicht Komma
            # ( ) [ ] { } "
            $f{punctype} = "brck";
        }
        elsif($tag eq "\$.")
        {
            # sentence-final
            # . ! ? : ;
            $f{punctype} = "peri";
        }
    }
    elsif($tag eq "FM")
    {
        # foreign-language material / Fremdsprachliches Material
        # "[der spanische Film] Mujer de [Benjamin]"
        $f{foreign} = "foreign";
    }
    elsif($tag eq "XY")
    {
        # non-word / Nichtwort
        # "[das Modell] DX3E"
        # $f{pos} = ""; # default
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
    # Modify the feature structure so that it contains values expected by this
    # driver.
    my $f = tagset::common::enforce_permitted_joint($f0, $permitted);
    my %f = %{$f}; # This is not a deep copy but $f already refers to a deep copy of the original %{$f0}.
    my $nonstrict = shift; # strict is default
    $strict = !$nonstrict;
    my $tag;
    # There are the following 54 tags:
    # ADJA ADJD
    # ADV
    # APPR APPRART APPO APZR
    # ART
    # CARD
    # FM
    # ITJ
    # KOUI KOUS KON KOKOM
    # NN NE
    # PDS PDAT PIS PIAT PIDAT PPER PPOSS PPOSAT PRELS PRELAT PRF PWS PWAT PWAV PAV
    # PTKZU PTKNEG PTKVZ PTKANT PTKA
    # TRUNC
    # VVFIN VVIMP VVINF VVIZU VVPP VAFIN VAIMP VAINF VAPP VMFIN VMINF VMPP
    # XY
    # $, $. $(
    # foreign words without respect to part of speech
    if($f{foreign} eq "foreign")
    {
        $tag = "FM";
    }
    # hyphenated prefix without respect to part of speech
    elsif($f{hyph} eq "hyph")
    {
        $tag = "TRUNC";
    }
    # Grab pronouns before their base part of speech (noun, adj, adv) can influence the result.
    # pronoun: PPER, PRF, PPOSS, PPOSAT, PDS, PDAT, PAV, PWS, PWAT, PWAV, PRELS, PRELAT, PIS, PIAT, PIDAT
    elsif($f{prontype} ne "")
    {
        if($f{prontype} eq "prs")
        {
            if($f{poss} eq "poss")
            {
                # PPOSAT is default
                if($f{pos} eq "noun")
                {
                    $tag = "PPOSS";
                }
                else
                {
                    $tag = "PPOSAT";
                }
            }
            elsif($f{reflex} eq "reflex")
            {
                $tag = "PRF";
            }
            else
            {
                $tag = "PPER";
            }
        }
        elsif($f{prontype} eq "rcp")
        {
            $tag = "PRF";
        }
        else
        {
            if($f{prontype} eq "dem")
            {
                if($f{pos} eq "adv")
                {
                    $tag = "PAV";
                }
                else
                {
                    $tag = "PD";
                }
            }
            elsif($f{prontype} eq "int")
            {
                $tag = "PW";
                if($f{pos} eq "adv")
                {
                    $tag .= "AV";
                }
            }
            elsif($f{prontype} eq "rel")
            {
                $tag = "PREL";
            }
            else # ind, neg, tot
            {
                $tag = "PI";
                if($f{subpos} eq "pdt")
                {
                    $tag .= "DAT";
                }
            }
            # Distinguish substitutive pronouns from attributive ones.
            if($tag !~ m/^(PAV|PWAV|PIDAT)$/)
            {
                if($f{pos} eq "noun")
                {
                    $tag .= "S";
                }
                else
                {
                    $tag .= "AT";
                }
            }
        }
    }
    # noun: NN, NE
    elsif($f{pos} eq "noun")
    {
        # special cases first, defaults last
        if($f{subpos} eq "prop")
        {
            $tag = "NE";
        }
        else
        {
            $tag = "NN";
        }
    }
    # adj:  ADJA, ADJD, ART
    elsif($f{pos} eq "adj")
    {
        # special cases first, defaults last
        if($f{subpos} eq "det")
        {
            $tag = "ART";
        }
        elsif($f{synpos} eq "attr")
        {
            $tag = "ADJA";
        }
        else
        {
            $tag = "ADJD";
        }
    }
    # num:  CARD (, ADJA)
    elsif($f{pos} eq "num")
    {
        if($f{numtype} eq "card")
        {
            $tag = "CARD";
        }
        else
        {
            $tag = "ADJA";
        }
    }
    # verb: VVINF, VVIZU, VVFIN, VVIMP, VVPP, VAINF, VAFIN, VAIMP, VMINF, VMFIN, VMPP
    elsif($f{pos} eq "verb")
    {
        # special cases first, defaults last
        if($f{subpos} eq "mod")
        {
            $tag = "VM";
        }
        elsif($f{subpos} eq "aux")
        {
            $tag = "VA";
        }
        else
        {
            $tag = "VV";
        }
        # verbform and mood
        if($f{mood} eq "imp")
        {
            $tag .= "IMP";
        }
        elsif($f{mood} eq "ind")
        {
            $tag .= "FIN";
        }
        elsif($f{verbform} eq "part")
        {
            $tag .= "PP";
        }
        elsif($f{subpos} eq "inf")
        {
            $tag .= "IZU";
        }
        else
        {
            $tag .= "INF";
        }
    }
    # adv: ADV
    elsif($f{pos} eq "adv")
    {
        $tag = "ADV";
    }
    # prep: APPR, APPRART, APPO, APZR
    elsif($f{pos} eq "prep")
    {
        # special cases first, defaults last
        if($f{subpos} eq "post")
        {
            $tag = "APPO";
        }
        elsif($f{subpos} eq "circ")
        {
            $tag = "APZR";
        }
        elsif($f{subpos} eq "det")
        {
            $tag = "APPRART";
        }
        else
        {
            $tag = "APPR";
        }
    }
    # conj: KOUI, KOUS, KON, KOKOM
    elsif($f{pos} eq "conj")
    {
        # special cases first, defaults last
        if($f{subpos} eq "sub")
        {
            if($f{tagset} eq "de::stts" && $f{other} eq "zu")
            {
                $tag = "KOUI";
            }
            else
            {
                $tag = "KOUS";
            }
        }
        elsif($f{subpos} eq "comp")
        {
            $tag = "KOKOM";
        }
        else
        {
            $tag = "KON";
        }
    }
    # part: PTKZU, PTKNEG, PTKVZ, PTKANT, PTKA
    elsif($f{pos} eq "part")
    {
        # special cases first, defaults last
        if($f{subpos} eq "inf")
        {
            $tag = "PTKZU";
        }
        elsif($f{negativeness} eq "neg")
        {
            $tag = "PTKNEG";
        }
        elsif($f{subpos} eq "vbp")
        {
            $tag = "PTKVZ";
        }
        elsif($f{subpos} eq "res")
        {
            $tag = "PTKANT";
        }
        else
        {
            $tag = "PTKA";
        }
    }
    # int: ITJ
    elsif($f{pos} eq "int")
    {
        $tag = "ITJ";
    }
    # punc: $,, $(, $.
    elsif($f{pos} eq "punc")
    {
        if($f{punctype} eq "comm")
        {
            $tag = "\$,";
        }
        elsif($f{punctype} =~ m/^(peri|qest|excl|colo|semi)$/)
        {
            $tag = "\$.";
        }
        else
        {
            $tag = "\$(";
        }
    }
    # unknown elements
    else
    {
        $tag = "XY";
    }
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# This is the complete list, not just a subset found in a corpus as with other
# drivers.
#
# 54
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
ADJA
ADJD
ADV
APPR
APPRART
APPO
APZR
ART
CARD
FM
ITJ
KOUI
KOUS
KON
KOKOM
NN
NE
PDS
PDAT
PIS
PIAT
PIDAT
PPER
PPOSS
PPOSAT
PRELS
PRELAT
PRF
PWS
PWAT
PWAV
PAV
PTKZU
PTKNEG
PTKVZ
PTKANT
PTKA
TRUNC
VVFIN
VVIMP
VVINF
VVIZU
VVPP
VAFIN
VAIMP
VAINF
VAPP
VMFIN
VMINF
VMPP
XY
\$,
\$.
\$(
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
