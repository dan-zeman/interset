#!/usr/bin/perl
# Driver for the CoNLL 2006 Portuguese tagset.
# Copyright © 2007-2009 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::pt::conll;
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
    $f{tagset} = "pt::conll";
    # three components: coarse-grained pos, fine-grained pos, features
    # example: v\tv-fin\tPR|3S|IND
    # types in CoNLL 2006 data:
    # 149 features
    # 879 tags (coarse+fine+features)
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    # pos: ? adj adv art conj ec in n num pp pron prop prp punc v vp
    # n = common noun # example: revivalismo
    if($pos eq "n")
    {
        $f{pos} = "noun";
    }
    # prop = proper noun # example: Castro_Verde, João_Pedro_Henriques
    elsif($pos eq "prop")
    {
        $f{pos} = "noun";
        $f{subpos} = "prop";
    }
    # adj = adjective # example: refrescante, algarvio
    elsif($pos eq "adj")
    {
        $f{pos} = "adj";
    }
    # art = article # example: a, as, o, os, uma, um
    elsif($pos eq "art")
    {
        $f{pos} = "adj";
        $f{subpos} = "art";
    }
    # pron = pronoun # example: que, outro, ela, certo, o, algum, todo, nós
    elsif($pos eq "pron")
    {
        $f{pos} = "pron";
        # pron-pers = personal # example: ela, elas, ele, eles, eu, nós, se, tu, você, vós
        if($subpos eq "pron-pers")
        {
            $f{pos} = "noun";
            $f{prontype} = "prs";
        }
        # pron-det = determiner # example: algo, ambos, bastante, demais, este, menos, nosso, o, que, todo_o
        elsif($subpos eq "pron-det")
        {
            $f{pos} = "adj";
            $f{prontype} = "ind";
            $f{subpos} = "det";
        }
        # pron-indp = independent # example: algo, aquilo, cada_qual, o, o_que, que, todo_o_mundo, um_pouco
        elsif($subpos eq "pron-indp")
        {
            $f{pos} = "noun";
            $f{prontype} = "ind";
        }
    }
    # num = number # example: 0,05, cento_e_quatro, cinco, setenta_e_dois, um, zero
    elsif($pos eq "num")
    {
        $f{pos} = "num";
    }
    # v = verb
    elsif($pos eq "v")
    {
        $f{pos} = "verb";
        # v-inf = infinitive # example: abafar, abandonar, abastecer...
        if($subpos eq "v-inf")
        {
            $f{verbform} = "inf";
        }
        # v-fin = finite # example: abafaram, abalou, abandonará...
        elsif($subpos eq "v-fin")
        {
            $f{verbform} = "fin";
        }
        # v-pcp = participle # example: abafado, abalada, abandonadas...
        elsif($subpos eq "v-pcp")
        {
            $f{verbform} = "part";
        }
        # v-ger = gerund # example: abraçando, abrindo, acabando...
        elsif($subpos eq "v-ger")
        {
            $f{verbform} = "ger";
        }
    }
    # vp = verb phrase # 1 occurrence in CoNLL 2006 data ("existente"), looks like an error
    elsif($pos eq "vp")
    {
        $f{pos} = "adj";
        $f{other} = "vp";
    }
    # adv = adverb # example: 20h45, abaixo, abertamente, a_bordo...
    elsif($pos eq "adv")
    {
        $f{pos} = "adv";
    }
    # pp = prepositional phrase # example: ao_mesmo_tempo, de_acordo, por_último...
    elsif($pos eq "pp")
    {
        $f{pos} = "adv";
        $f{other}{pp}++;
    }
    # prp = preposition # example: a, abaixo_de, ao, com, de, em, por, que...
    elsif($pos eq "prp")
    {
        $f{pos} = "prep";
    }
    # conj = conjunction # example: e, enquanto_que, mas, nem, ou, que...
    elsif($pos eq "conj")
    {
        $f{pos} = "conj";
        # coordinating conjunction # example: e, mais, mas, nem, ou, quer, tampouco, tanto
        if($subpos eq "conj-c")
        {
            $f{subpos} = "coor";
        }
        # subordinating conjunction # example: a_fim_de_que, como, desde_que, para_que, que...
        elsif($subpos eq "conj-s")
        {
            $f{subpos} = "sub";
        }
    }
    # in = interjection # example: adeus, ai, alô
    elsif($pos eq "in")
    {
        $f{pos} = "int";
    }
    # ec = partial word # example: anti-, ex-, pós, pré-
    elsif($pos eq "ec")
    {
        $f{pos} = "part";
        $f{hyph} = "hyph";
    }
    # punc = punctuation # example: --, -, ,, ;, :, !, ?:?...
    elsif($pos eq "punc")
    {
        $f{pos} = "punc";
    }
    # ? = unknown # 2 occurrences in CoNLL 2006 data
    elsif($pos eq "?")
    {
        $f{pos} = "";
    }
    # Decode feature values.
    my @features = split(/\|/, $features);
    foreach my $feature (@features)
    {
        # gender = F|F/M|M|M/F
        if($feature eq "F")
        {
            $f{gender} = "fem";
        }
        elsif($feature eq "F/M")
        {
            $f{gender} = ["fem", "masc"];
        }
        elsif($feature eq "M")
        {
            $f{gender} = "masc";
        }
        elsif($feature eq "M/F")
        {
            $f{gender} = ["masc", "fem"];
        }
        # number = P|S|S/P
        elsif($feature eq "S")
        {
            $f{number} = "sing";
        }
        elsif($feature eq "S/P")
        {
            $f{number} = ["sing", "plu"];
        }
        elsif($feature eq "P")
        {
            $f{number} = "plu";
        }
        # case = ACC|ACC/DAT|DAT|NOM|NOM/PIV|PIV
        elsif($feature eq "NOM")
        {
            $f{case} = "nom";
        }
        elsif($feature eq "NOM/PIV")
        {
            $f{case} = ["nom", "acc"];
            $f{prepcase} = ["", "pre"];
        }
        elsif($feature eq "DAT")
        {
            $f{case} = "dat";
        }
        elsif($feature eq "ACC/DAT")
        {
            $f{case} = ["acc", "dat"];
        }
        elsif($feature eq "ACC")
        {
            $f{case} = "acc";
        }
        elsif($feature eq "PIV")
        {
            # Note: PIV also occurs as the syntactic tag of prepositions heading prepositional objects.
            $f{case} = "acc";
            $f{prepcase} = "pre";
        }
        # person+number = 1/3S|1S|1P|2S|2P|3S|3S/P|3P
        elsif($feature =~ m/^1\/3S>?$/)
        {
            $f{person} = [1, 3];
            if($f{poss} eq "poss")
            {
                $f{possnumber} = "sing";
            }
            else
            {
                $f{number} = "sing";
            }
        }
        elsif($feature =~ m/^1S>?$/)
        {
            $f{person} = 1;
            if($f{poss} eq "poss")
            {
                $f{possnumber} = "sing";
            }
            else
            {
                $f{number} = "sing";
            }
        }
        elsif($feature =~ m/^1P>?$/)
        {
            $f{person} = 1;
            if($f{poss} eq "poss")
            {
                $f{possnumber} = "plu";
            }
            else
            {
                $f{number} = "plu";
            }
        }
        elsif($feature =~ m/^2S>?$/)
        {
            $f{person} = 2;
            if($f{poss} eq "poss")
            {
                $f{possnumber} = "sing";
            }
            else
            {
                $f{number} = "sing";
            }
        }
        elsif($feature =~ m/^2P>?$/)
        {
            $f{person} = 2;
            if($f{poss} eq "poss")
            {
                $f{possnumber} = "plu";
            }
            else
            {
                $f{number} = "plu";
            }
        }
        elsif($feature =~ m/^3S>?$/)
        {
            $f{person} = 3;
            if($f{poss} eq "poss")
            {
                $f{possnumber} = "sing";
            }
            else
            {
                $f{number} = "sing";
            }
        }
        elsif($feature =~ m/^3S\/P>?$/)
        {
            $f{person} = 3;
            if($f{poss} eq "poss")
            {
                $f{possnumber} = ["sing", "plu"];
            }
            else
            {
                $f{number} = ["sing", "plu"];
            }
        }
        elsif($feature =~ m/^3P>?$/)
        {
            $f{person} = 3;
            if($f{poss} eq "poss")
            {
                $f{possnumber} = "plu";
            }
            else
            {
                $f{number} = "plu";
            }
        }
        # tense/mood = COND|FUT|IMP|IMPF|IND|MQP|PR|PR/PS|PS|PS/MQP|SUBJ
        # indicative
        elsif($feature eq "IND")
        {
            $f{mood} = "ind";
        }
        # imperative
        elsif($feature eq "IMP")
        {
            $f{mood} = "imp";
        }
        # present
        elsif($feature eq "PR")
        {
            $f{tense} = "pres";
        }
        # past or present
        elsif($feature eq "PR/PS")
        {
            $f{tense} = ["pres", "past"];
        }
        # past
        elsif($feature eq "PS")
        {
            $f{tense} = "past";
        }
        # imperfect past
        elsif($feature eq "IMPF")
        {
            $f{tense} = "past";
            $f{subtense} = "imp";
        }
        # past or pluperfect past
        elsif($feature eq "PS/MQP")
        {
            $f{tense} = "past";
            $f{subtense} = ["imp", "ppq"];
        }
        # pluperfect
        elsif($feature eq "MQP")
        {
            $f{tense} = "past";
            $f{subtense} = "ppq";
        }
        # future
        elsif($feature eq "FUT")
        {
            $f{tense} = "fut";
        }
        # conditional
        elsif($feature eq "COND")
        {
            $f{mood} = "cnd";
        }
        # subjunctive
        elsif($feature eq "SUBJ")
        {
            $f{mood} = "sub";
        }
        # Features in angle brackets are secondary tags, word subclasses etc.
        elsif($feature eq "<ALT>")
        {
            $f{typo} = "typo";
        }
        # Derivation by prefixation.
        elsif($feature eq "<DERP>")
        {
            $f{other}{$feature}++;
        }
        # Derivation by suffixation.
        elsif($feature eq "<DERS>")
        {
            $f{other}{$feature}++;
        }
        # Comparative degree.
        elsif($feature eq "<KOMP>")
        {
            $f{degree} = "comp";
        }
        # Superlative degree.
        elsif($feature eq "<SUP>")
        {
            $f{degree} = "sup";
        }
        # Ordinal number (subclass of adjectives).
        elsif($feature eq "<NUM-ord>")
        {
            $f{numtype} = "ord";
        }
        # Cardinal number.
        elsif($feature eq "<card>")
        {
            # This can co-occur with subpos=prop (proper noun).
            # If it is the case, keep "prop" and discard "card".
            unless($f{subpos} eq "prop")
            {
                $f{numtype} = "card";
            }
        }
        # Definite article.
        # Occurs with pron-det as well, so do not set subpos = art, or we cannot distinguish the original pos = art.
        # Set other instead, to preserve the <artd> feature.
        elsif($feature eq "<artd>")
        {
            $f{definiteness} = "def";
            $f{other}{"<artd>"}++;
        }
        # Indefinite article.
        # Occurs with pron-det as well, so do not set subpos = art, or we cannot distinguish the original pos = art.
        # Set other instead, to preserve the <arti> feature.
        elsif($feature eq "<arti>")
        {
            $f{definiteness} = "ind";
            $f{other}{"<arti>"}++;
        }
        # Kind of nodes coordinated by this conjunction.
        elsif($feature =~ m/^<co-(acc|advl|advo|advs|app|fmc|ger|inf|oc|pass|pcv|piv|postad|postnom|pred|prenom|prparg|sc|subj|vfin)>$/)
        {
            $f{other}{$feature}++;
        }
        # Collective reflexive pronoun (reunir-se, associar-se).
        elsif($feature eq "<coll>")
        {
            $f{other}{"<coll>"}++;
        }
        # Demonstrative pronoun or adverb.
        elsif($feature eq "<dem>")
        {
            $f{prontype} = "dem";
        }
        # Interrogative pronoun or adverb.
        elsif($feature eq "<interr>")
        {
            $f{prontype} = "int";
        }
        # Relative pronoun or adverb.
        elsif($feature eq "<rel>")
        {
            $f{prontype} = "rel";
        }
        # Possessive determiner pronoun.
        elsif($feature eq "<poss")
        {
            $f{prontype} = "prs";
            $f{poss} = "poss";
        }
        # (Indefinite) quantifier pronoun or adverb.
        # independent pronouns: algo, tudo, nada
        # independent relative pronouns: todo_o_que
        # determiners (pronouns): algum, alguma, alguns, algumas, uns, umas, vários, várias,
        #    qualquer, pouco, poucos, muitos, mais,
        #    todo, todo_o, todos, todas, ambos, ambas
        # adverbs: pouco, menos, muito, mais, mais_de, quase, tanto, mesmo, demais, bastante, suficiente, bem
        # demonstrative adverbs: t~ao
        # This is not the class of indefinite pronouns. This class contains pronouns and adverbs of quantity.
        # The pronouns and adverbs in this class can be indefinite (algo), total (todo), negative (nada), demonstrative (tanto, tao),
        # interrogative (quanto), relative (todo_o_que). Many are indefinite, but not all.
        elsif($feature eq "<quant>")
        {
            $f{prontype} = "ind" unless($f{prontype});
            $f{numtype} = "card";
        }
        # Reciprocal reflexive (amar-se).
        elsif($feature eq "<reci>")
        {
            $f{prontype} = "rcp";
        }
        # Reflexive pronoun.
        elsif($feature eq "<refl>")
        {
            $f{reflex} = "reflex";
        }
        # Reflexive usage of 3rd person possessive (seu, seus, sua, suas).
        elsif($feature eq "<si>")
        {
            $f{reflex} = "reflex";
            $f{poss} = "poss";
            $f{person} = 3;
        }
        # Differentiator (mesmo, outro, semelhante, tal).
        # Identifier pronoun (mesmo, próprio).
        # Annotation or processing error.
        # Verb heading finite main clause.
        # Focus marker, adverb or pronoun.
        # First part in contracted word.
        # Second part in contracted word.
        elsif($feature =~ m/^<(diff|ident|error|fmc|foc|sam-|-sam)>$/)
        {
            $f{other}{$feature}++;
        }
        # Hyphenated prefix, usually of reflexive verbs.
        elsif($feature eq "<hyfen>")
        {
            $f{hyph} = "hyph";
        }
        # Words used as word classes other than those they belong to.
        elsif($feature =~ m/^<(det|kc|ks|n|prop|prp)>$/)
        {
            $f{other}{$feature}++;
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
    if($f{pos} eq "part" && $f{hyph} eq "hyph")
    {
        $tag = "ec\tec";
    }
    elsif($f{pos} eq "noun")
    {
        if($f{prontype} =~ m/^(prs|rcp)$/)
        {
            $tag = "pron\tpron-pers";
        }
        elsif($f{prontype} ne "")
        {
            $tag = "pron\tpron-indp";
        }
        elsif($f{subpos} eq "prop")
        {
            $tag = "prop\tprop";
        }
        else
        {
            $tag = "n\tn";
        }
    }
    elsif($f{pos} eq "adj")
    {
        if($f{subpos} eq "art")
        {
            $tag = "art\tart";
        }
        elsif($f{prontype} ne "" || $f{subpos} eq "det")
        {
            $tag = "pron\tpron-det";
        }
        else
        {
            $tag = "adj\tadj";
        }
    }
    elsif($f{pos} eq "num")
    {
        $tag = "num\tnum";
    }
    elsif($f{pos} eq "verb")
    {
        if($f{verbform} eq "ger")
        {
            $tag = "v\tv-ger";
        }
        elsif($f{verbform} eq "part")
        {
            $tag = "v\tv-pcp";
        }
        elsif($f{verbform} eq "fin")
        {
            $tag = "v\tv-fin";
        }
        else
        {
            $tag = "v\tv-inf";
        }
    }
    elsif($f{pos} eq "adv")
    {
        if($f{tagset} eq "pt::conll" && $f{other}{pp})
        {
            $tag = "pp\tpp";
        }
        else
        {
            $tag = "adv\tadv";
        }
    }
    elsif($f{pos} eq "prep")
    {
        $tag = "prp\tprp";
    }
    elsif($f{pos} eq "conj")
    {
        if($f{subpos} eq "sub")
        {
            $tag = "conj\tconj-s";
        }
        else
        {
            $tag = "conj\tconj-c";
        }
    }
    elsif($f{pos} eq "int")
    {
        $tag = "in\tin";
    }
    elsif($f{pos} eq "punc")
    {
        $tag = "punc\tpunc";
    }
    else
    {
        $tag = "?\t?";
    }
    # Encode features.
    my @features;
    # Other features.
    if($f{typo} eq "typo")
    {
        push(@features, "<ALT>");
    }
    if($f{hyph} eq "hyph" && $f{pos} ne "part")
    {
        push(@features, "<hyfen>");
    }
    if($f{tagset} eq "pt::conll")
    {
        foreach my $feature ("sam-", "kc", "-sam")
        {
            my $feature1 = "<$feature>";
            if($f{other}{$feature1})
            {
                push(@features, $feature1);
            }
        }
    }
    if($f{prontype} eq "prs" && $f{poss} eq "poss")
    {
        push(@features, "<poss");
        if($f{person}==1)
        {
            if($f{possnumber} eq "plu")
            {
                push(@features, "1P>");
            }
            else
            {
                push(@features, "1S>");
            }
        }
        elsif($f{person}==2)
        {
            if($f{possnumber} eq "plu")
            {
                push(@features, "2P>");
            }
            else
            {
                push(@features, "2S>");
            }
        }
        else
        {
            if(tagset::common::iseq($f{possnumber}, ["sing", "plu"]))
            {
                push(@features, "3S/P>");
            }
            elsif($f{possnumber} eq "plu")
            {
                push(@features, "3P>");
            }
            else
            {
                push(@features, "3S>");
            }
        }
    }
    if($f{reflex} eq "reflex")
    {
        if($f{poss} eq "poss" && $f{person}==3)
        {
            push(@features, "<si>");
        }
        else
        {
            push(@features, "<refl>");
        }
    }
    if($f{tagset} eq "pt::conll" && $f{other}{"<coll>"})
    {
        push(@features, "<coll>");
    }
    elsif($f{prontype} eq "int")
    {
        push(@features, "<interr>");
    }
    elsif($f{prontype} eq "rel")
    {
        push(@features, "<rel>");
    }
    elsif($f{prontype} eq "rcp")
    {
        push(@features, "<reci>");
    }
    if($f{tagset} eq "pt::conll")
    {
        foreach my $feature qw(DERP DERS ident error fmc ks n prop prp diff)
        {
            my $feature1 = "<$feature>";
            if($f{other}{$feature1})
            {
                push(@features, $feature1);
            }
        }
        foreach my $coord qw(acc advl advo advs app ger inf oc pass pcv piv postad postnom pred prenom prparg sc subj vfin fmc)
        {
            my $feature = "<co-$coord>";
            if($f{other}{$feature})
            {
                push(@features, $feature);
            }
        }
    }
    if($f{prontype} eq "dem")
    {
        push(@features, "<dem>");
    }
    if($f{prontype} && $f{numtype} eq "card")
    {
        push(@features, "<quant>");
    }
    if($f{tagset} eq "pt::conll" && $f{other}{"<det>"})
    {
        push(@features, "<det>");
    }
    if($f{tagset} eq "pt::conll" && $f{other}{"<foc>"})
    {
        push(@features, "<foc>");
    }
    if($f{degree} eq "comp")
    {
        push(@features, "<KOMP>");
    }
    elsif($f{degree} eq "sup")
    {
        push(@features, "<SUP>");
    }
    if($f{pos} eq "num" && $f{numtype} eq "card")
    {
        push(@features, "<card>");
    }
    elsif($f{numtype} eq "ord")
    {
        push(@features, "<NUM-ord>");
    }
    if($f{tagset} eq "pt::conll")
    {
        if($f{other}{"<artd>"})
        {
            push(@features, "<artd>");
        }
        elsif($f{other}{"<arti>"})
        {
            push(@features, "<arti>");
        }
    }
    # Gender.
    if($f{gender} eq "fem")
    {
        push(@features, "F");
    }
    elsif(tagset::common::iseq($f{gender}, ["fem", "masc"]))
    {
        push(@features, "M/F");
    }
    elsif($f{gender} eq "masc")
    {
        push(@features, "M");
    }
    # Number.
    if(!(
        $f{pos} eq "verb" && $f{verbform} ne "part" ||
        $f{prontype} =~ m/^(prs|rcp)$/ && $f{poss} ne "poss" ||
        $f{pos} eq "int" && $f{person} # viu ... interjectionalized verb
      ))
    {
        if($f{number} eq "sing")
        {
            push(@features, "S");
        }
        elsif(tagset::common::iseq($f{number}, ["sing", "plu"]))
        {
            push(@features, "S/P");
        }
        elsif($f{number} eq "plu")
        {
            push(@features, "P");
        }
    }
    # Tense and imperative and conditional mood (other moods processed later).
    if($f{tense} eq "fut")
    {
        push(@features, "FUT");
    }
    elsif($f{tense} eq "past")
    {
        if($f{subtense} eq "ppq")
        {
            push(@features, "MQP");
        }
        elsif($f{subtense} eq "imp")
        {
            push(@features, "IMPF");
        }
        elsif(ref($f{subtense}) eq "ARRAY" && join(", ", @{$f{subtense}}) eq "imp, ppq")
        {
            push(@features, "PS/MQP");
        }
        else
        {
            push(@features, "PS");
        }
    }
    elsif(ref($f{tense}) eq "ARRAY" && (join(", ", @{$f{tense}}) eq "pres, past" || join(", ", @{$f{tense}}) eq "past, pres"))
    {
        push(@features, "PR/PS");
    }
    elsif($f{tense} eq "pres")
    {
        push(@features, "PR");
    }
    elsif($f{mood} eq "imp")
    {
        push(@features, "IMP");
    }
    elsif($f{mood} eq "cnd")
    {
        push(@features, "COND");
    }
    # Person and number.
    unless($f{poss} eq "poss")
    {
        if(ref($f{person}) eq "ARRAY" && join(", ", @{$f{person}}) eq "1, 3" && $f{number} eq "sing")
        {
            push(@features, "1/3S");
        }
        elsif($f{person}==1)
        {
            if($f{number} eq "plu")
            {
                push(@features, "1P");
            }
            else
            {
                push(@features, "1S");
            }
        }
        elsif($f{person}==2)
        {
            if($f{number} eq "plu")
            {
                push(@features, "2P");
            }
            else
            {
                push(@features, "2S");
            }
        }
        elsif($f{person}==3)
        {
            if(tagset::common::iseq($f{number}, ["sing", "plu"]))
            {
                push(@features, "3S/P");
            }
            elsif($f{number} eq "plu")
            {
                push(@features, "3P");
            }
            else
            {
                push(@features, "3S");
            }
        }
    }
    # Case.
    if($f{case} eq "nom")
    {
        push(@features, "NOM");
    }
    elsif(tagset::common::iseq($f{case}, ["nom", "acc"]))
    {
        push(@features, "NOM/PIV");
    }
    elsif($f{case} eq "dat")
    {
        push(@features, "DAT");
    }
    elsif(tagset::common::iseq($f{case}, ["acc", "dat"]))
    {
        push(@features, "ACC/DAT");
    }
    elsif($f{case} eq "acc")
    {
        if($f{prepcase} eq "pre")
        {
            push(@features, "PIV");
        }
        else
        {
            push(@features, "ACC");
        }
    }
    # Mood except for imperative and conditional (processed earlier).
    if($f{mood} eq "sub")
    {
        push(@features, "SUBJ");
    }
    elsif($f{mood} eq "ind")
    {
        push(@features, "IND");
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
# cat train.conll test.conll |\
#   perl -pe '@x = split(/\s+/, $_); $_ = "$x[3]\t$x[4]\t$x[5]\n"' |\
#   sort -u | wc -l
# 880
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
?	?	_
adj	adj	_
adj	adj	<ALT>|F|P
adj	adj	<ALT>|F|S
adj	adj	<ALT>|M|S
adj	adj	<ALT>|<SUP>|M|S
adj	adj	<DERP>|<DERS>|F|S
adj	adj	<DERP>|F|P
adj	adj	<DERP>|F|S
adj	adj	<DERP>|M|P
adj	adj	<DERP>|M|S
adj	adj	<DERP>|<n>|M|P
adj	adj	<DERS>|F|P
adj	adj	<DERS>|F|S
adj	adj	<DERS>|M|P
adj	adj	<DERS>|M|S
adj	adj	<DERS>|<n>|M|P
adj	adj	<error>|M|S
adj	adj	F|P
adj	adj	F|S
adj	adj	<hyfen>|F|P
adj	adj	<KOMP>|F|P
adj	adj	<KOMP>|F|S
adj	adj	<KOMP>|M/F|S
adj	adj	<KOMP>|M|P
adj	adj	<KOMP>|M|S
adj	adj	M/F|P
adj	adj	M/F|S
adj	adj	M/F|S/P
adj	adj	M|P
adj	adj	M|S
adj	adj	<n>
adj	adj	<n>|F|P
adj	adj	<n>|F|S
adj	adj	<n>|<KOMP>|F|P
adj	adj	<n>|<KOMP>|F|S
adj	adj	<n>|<KOMP>|M|P
adj	adj	<n>|<KOMP>|M|S
adj	adj	<n>|M/F|P
adj	adj	<n>|M/F|S
adj	adj	<n>|M|P
adj	adj	<n>|M|S
adj	adj	<n>|<NUM-ord>|F|P
adj	adj	<n>|<NUM-ord>|F|S
adj	adj	<n>|<NUM-ord>|M|P
adj	adj	<n>|<NUM-ord>|M|S
adj	adj	<n>|<SUP>|F|P
adj	adj	<n>|<SUP>|F|S
adj	adj	<n>|<SUP>|M|P
adj	adj	<n>|<SUP>|M|S
adj	adj	<NUM-ord>|F|P
adj	adj	<NUM-ord>|F|S
adj	adj	<NUM-ord>|M/F|S
adj	adj	<NUM-ord>|M|P
adj	adj	<NUM-ord>|M|S
adj	adj	<prop>|F|P
adj	adj	<prop>|F|S
adj	adj	<prop>|M/F|S
adj	adj	<prop>|M|P
adj	adj	<prop>|M|S
adj	adj	<prop>|<NUM-ord>|M|S
adj	adj	<SUP>|F|P
adj	adj	<SUP>|F|S
adj	adj	<SUP>|M|P
adj	adj	<SUP>|M|S
adv	adv	_
adv	adv	<ALT>
adv	adv	<co-acc>
adv	adv	<co-advl>
adv	adv	<co-prparg>
adv	adv	<co-sc>
adv	adv	<dem>
adv	adv	<dem>|<quant>
adv	adv	<dem>|<quant>|<KOMP>
adv	adv	<DERP>|<DERS>
adv	adv	<DERS>
adv	adv	<error>
adv	adv	<foc>
adv	adv	<interr>
adv	adv	<interr>|<ks>
adv	adv	<interr>|<quant>
adv	adv	<kc>
adv	adv	<kc>|<co-acc>
adv	adv	<kc>|<co-advl>
adv	adv	<kc>|<co-pass>
adv	adv	<kc>|<co-piv>
adv	adv	<kc>|<foc>
adv	adv	<kc>|<KOMP>
adv	adv	<kc>|<-sam>
adv	adv	<KOMP>
adv	adv	<ks>
adv	adv	M|P
adv	adv	M|S
adv	adv	<n>|<KOMP>
adv	adv	<prp>
adv	adv	<quant>
adv	adv	<quant>|<det>
adv	adv	<quant>|<KOMP>
adv	adv	<quant>|<KOMP>|F|P
adv	adv	<rel>
adv	adv	<rel>|<ks>
adv	adv	<rel>|<ks>|<quant>
adv	adv	<rel>|<prp>
adv	adv	<rel>|<prp>|<co-advl>
adv	adv	<rel>|<quant>
adv	adv	<-sam>
adv	adv	<sam->
adv	adv	<SUP>
art	art	<ALT>|<artd>|F|S
art	art	<artd>
art	art	<artd>|F|P
art	art	<artd>|F|S
art	art	<artd>|M|P
art	art	<artd>|M|S
art	art	<arti>|F|S
art	art	<arti>|M|S
art	art	<dem>|F|S
art	art	<dem>|M|S
art	art	<error>|<arti>|F|S
art	art	F|S
art	art	<-sam>|<artd>|F|P
art	art	<-sam>|<artd>|F|S
art	art	<-sam>|<artd>|M|P
art	art	<-sam>|<artd>|M|S
art	art	<-sam>|<artd>|P
art	art	<-sam>|<artd>|S
art	art	<-sam>|<arti>|F|S
art	art	<-sam>|<arti>|M|S
art	art	<-sam>|F|P
art	art	<-sam>|F|S
art	art	<-sam>|M|S
conj	conj-c	_
conj	conj-c	<co-acc>
conj	conj-c	<co-advl>
conj	conj-c	<co-advo>
conj	conj-c	<co-advs>
conj	conj-c	<co-app>
conj	conj-c	<co-fmc>
conj	conj-c	<co-ger>
conj	conj-c	<co-inf>
conj	conj-c	<co-inf>|<co-fmc>
conj	conj-c	<co-oc>
conj	conj-c	<co-pass>
conj	conj-c	<co-pcv>
conj	conj-c	<co-piv>
conj	conj-c	<co-postad>
conj	conj-c	<co-postnom>
conj	conj-c	<co-pred>
conj	conj-c	<co-prenom>
conj	conj-c	<co-prparg>
conj	conj-c	<co-sc>
conj	conj-c	<co-subj>
conj	conj-c	<co-vfin>
conj	conj-c	<co-vfin>|<co-fmc>
conj	conj-c	<quant>|<KOMP>
conj	conj-c	<fmc>
conj	conj-s	_
conj	conj-s	<co-prparg>
conj	conj-s	<kc>
conj	conj-s	<prp>
conj	conj-s	<rel>
ec	ec	_
in	in	_
in	in	F|S
in	in	M|S
in	in	PS|3S|IND
?	?	_
n	n	_
n	n	<ALT>|F|S
n	n	<ALT>|M|P
n	n	<ALT>|M|S
n	n	<co-prparg>|M|P
n	n	<DERP>|<DERS>|F|P
n	n	<DERP>|<DERS>|M|P
n	n	<DERP>|<DERS>|M|S
n	n	<DERP>|F|P
n	n	<DERP>|F|S
n	n	<DERP>|M|P
n	n	<DERP>|M|S
n	n	<DERS>|F|P
n	n	<DERS>|F|S
n	n	<DERS>|M|P
n	n	<DERS>|M|S
n	n	<error>|F|P
n	n	F
n	n	<fmc>|F|S
n	n	F|P
n	n	F|S
n	n	F|S/P
n	n	<hyfen>|F|S
n	n	<hyfen>|M|P
n	n	<hyfen>|M|S
n	n	M/F|P
n	n	M/F|S
n	n	M|P
n	n	M|S
n	n	M|S/P
n	n	<n>|M|P
n	n	<n>|M|S
n	n	<n>|<NUM-ord>|F|S
n	n	<prop>|F|P
n	n	<prop>|F|S
n	n	<prop>|M/F|S
n	n	<prop>|M|P
n	n	<prop>|M|S
num	num	_
num	num	<ALT>|<card>|M|P
num	num	<card>|F|P
num	num	<card>|F|S
num	num	<card>|M/F|P
num	num	<card>|M/F|S
num	num	<card>|M|P
num	num	<card>|M|S
num	num	<card>|M|S/P
num	num	F|P
num	num	M/F|P
num	num	M|P
num	num	M|S
num	num	<n>|<card>|M|P
num	num	<n>|<card>|M|S
num	num	<n>|M|P
num	num	<prop>|<card>|F|P
num	num	<prop>|<card>|M|P
num	num	<-sam>|<card>|M|S
num	num	<-sam>|M|S
pp	pp	_
pp	pp	F|S
pp	pp	<sam->
pron	pron-det	<artd>|F|P
pron	pron-det	<artd>|F|S
pron	pron-det	<artd>|M|P
pron	pron-det	<artd>|M|S
pron	pron-det	<arti>|F|S
pron	pron-det	<arti>|M|S
pron	pron-det	<dem>|<foc>|M|S
pron	pron-det	<dem>|F|P
pron	pron-det	<dem>|F|S
pron	pron-det	<dem>|<KOMP>|F|P
pron	pron-det	<dem>|<KOMP>|M|P
pron	pron-det	<dem>|M|P
pron	pron-det	<dem>|M|S
pron	pron-det	<dem>|<quant>|F|S
pron	pron-det	<dem>|<quant>|M|S
pron	pron-det	<diff>|F|P
pron	pron-det	<diff>|F|S
pron	pron-det	<diff>|<KOMP>|F|P
pron	pron-det	<diff>|<KOMP>|F|S
pron	pron-det	<diff>|<KOMP>|M/F|S
pron	pron-det	<diff>|<KOMP>|M|P
pron	pron-det	<diff>|<KOMP>|M|S
pron	pron-det	<diff>|M/F|S
pron	pron-det	<diff>|M|P
pron	pron-det	<diff>|M|S
pron	pron-det	F|P
pron	pron-det	F|S
pron	pron-det	<ident>|F|P
pron	pron-det	<ident>|F|S
pron	pron-det	<ident>|M|P
pron	pron-det	<ident>|M|S
pron	pron-det	<interr>|F|P
pron	pron-det	<interr>|F|S
pron	pron-det	<interr>|M/F|S
pron	pron-det	<interr>|M/F|S/P
pron	pron-det	<interr>|M|P
pron	pron-det	<interr>|M|S
pron	pron-det	<interr>|<quant>|F|P
pron	pron-det	<interr>|<quant>|M|P
pron	pron-det	<interr>|<quant>|M|S
pron	pron-det	<KOMP>|M|S
pron	pron-det	M|P
pron	pron-det	M|S
pron	pron-det	<n>|<dem>|M|S
pron	pron-det	<n>|<diff>|<KOMP>|F|S
pron	pron-det	<n>|<diff>|<KOMP>|M|P
pron	pron-det	<poss|1P>|F|P
pron	pron-det	<poss|1P>|F|S
pron	pron-det	<poss|1P>|M|P
pron	pron-det	<poss|1P>|M|S
pron	pron-det	<poss|1S>|F|P
pron	pron-det	<poss|1S>|F|S
pron	pron-det	<poss|1S>|M|P
pron	pron-det	<poss|1S>|M|S
pron	pron-det	<poss|2P>|F|S
pron	pron-det	<poss|2P>|M|S
pron	pron-det	<poss|2S>|M|S
pron	pron-det	<poss|3P>|F|S
pron	pron-det	<poss|3P>|M|P
pron	pron-det	<poss|3P>|M|S
pron	pron-det	<poss|3P>|<si>|F|P
pron	pron-det	<poss|3P>|<si>|F|S
pron	pron-det	<poss|3P>|<si>|M|P
pron	pron-det	<poss|3P>|<si>|M|S
pron	pron-det	<poss|3S>|F|P
pron	pron-det	<poss|3S>|F|S
pron	pron-det	<poss|3S>|M|P
pron	pron-det	<poss|3S>|M|S
pron	pron-det	<poss|3S/P>|F|S
pron	pron-det	<poss|3S/P>|M|P
pron	pron-det	<poss|3S/P>|<si>|F|S
pron	pron-det	<poss|3S/P>|<si>|M|S
pron	pron-det	<poss|3S>|<si>|F|P
pron	pron-det	<poss|3S>|<si>|F|S
pron	pron-det	<poss|3S>|<si>|M|P
pron	pron-det	<poss|3S>|<si>|M|S
pron	pron-det	<quant>
pron	pron-det	<quant>|F|P
pron	pron-det	<quant>|F|S
pron	pron-det	<quant>|<KOMP>|F|P
pron	pron-det	<quant>|<KOMP>|F|S
pron	pron-det	<quant>|<KOMP>|M/F|S/P
pron	pron-det	<quant>|<KOMP>|M|P
pron	pron-det	<quant>|<KOMP>|M|S
pron	pron-det	<quant>|M/F|P
pron	pron-det	<quant>|M/F|S
pron	pron-det	<quant>|M/F|S/P
pron	pron-det	<quant>|M|P
pron	pron-det	<quant>|M|S
pron	pron-det	<quant>|<SUP>|M|S
pron	pron-det	<rel>|F|P
pron	pron-det	<rel>|F|S
pron	pron-det	<rel>|M|P
pron	pron-det	<rel>|M|S
pron	pron-det	<-sam>|<artd>|F|P
pron	pron-det	<-sam>|<artd>|F|S
pron	pron-det	<-sam>|<artd>|M|P
pron	pron-det	<-sam>|<artd>|M|S
pron	pron-det	<-sam>|<artd>|M|S/P
pron	pron-det	<-sam>|<arti>|F|S
pron	pron-det	<-sam>|<arti>|M|S
pron	pron-det	<-sam>|<dem>|F|P
pron	pron-det	<-sam>|<dem>|F|S
pron	pron-det	<-sam>|<dem>|M|P
pron	pron-det	<-sam>|<dem>|M|S
pron	pron-det	<-sam>|<diff>|F|P
pron	pron-det	<-sam>|<diff>|F|S
pron	pron-det	<-sam>|<diff>|M|P
pron	pron-det	<-sam>|<diff>|M|S
pron	pron-det	<-sam>|F|P
pron	pron-det	<-sam>|F|S
pron	pron-det	<-sam>|M|P
pron	pron-det	<-sam>|M|S
pron	pron-det	<-sam>|<quant>|F|P
pron	pron-det	<-sam>|<quant>|M|P
pron	pron-indp	<ALT>|<rel>|F|S
pron	pron-indp	<artd>|F|S
pron	pron-indp	<artd>|M|S
pron	pron-indp	<dem>|M/F|S/P
pron	pron-indp	<dem>|M|S
pron	pron-indp	<diff>|M|S
pron	pron-indp	F|S
pron	pron-indp	<interr>|F|P
pron	pron-indp	<interr>|F|S
pron	pron-indp	<interr>|M/F|P
pron	pron-indp	<interr>|M/F|S
pron	pron-indp	<interr>|M/F|S/P
pron	pron-indp	<interr>|M|P
pron	pron-indp	<interr>|M|S
pron	pron-indp	M/F|S
pron	pron-indp	M/F|S/P
pron	pron-indp	M|P
pron	pron-indp	M|S
pron	pron-indp	M|S/P
pron	pron-indp	<quant>
pron	pron-indp	<quant>|M/F|S
pron	pron-indp	<quant>|M|S
pron	pron-indp	<rel>
pron	pron-indp	<rel>|F|P
pron	pron-indp	<rel>|F|S
pron	pron-indp	<rel>|M/F|P
pron	pron-indp	<rel>|M/F|S
pron	pron-indp	<rel>|M/F|S/P
pron	pron-indp	<rel>|M|P
pron	pron-indp	<rel>|M|S
pron	pron-indp	<-sam>|<dem>|M|S
pron	pron-indp	<-sam>|<rel>|F|P
pron	pron-indp	<-sam>|<rel>|F|S
pron	pron-indp	<-sam>|<rel>|M|P
pron	pron-indp	<-sam>|<rel>|M|S
pron	pron-pers	<coll>|F|3P|ACC
pron	pron-pers	<coll>|M|3P|ACC
pron	pron-pers	<coll>|M|3S|ACC
pron	pron-pers	F|1P|NOM/PIV
pron	pron-pers	F|1S|ACC
pron	pron-pers	F|1S|NOM
pron	pron-pers	F|1S|PIV
pron	pron-pers	F|3P|ACC
pron	pron-pers	F|3P|DAT
pron	pron-pers	F|3P|NOM
pron	pron-pers	F|3P|NOM/PIV
pron	pron-pers	F|3P|PIV
pron	pron-pers	F|3S|ACC
pron	pron-pers	F|3S|DAT
pron	pron-pers	F|3S|NOM
pron	pron-pers	F|3S|NOM/PIV
pron	pron-pers	F|3S/P|ACC
pron	pron-pers	F|3S|PIV
pron	pron-pers	<hyfen>|F|3S|ACC
pron	pron-pers	<hyfen>|M|3S|ACC
pron	pron-pers	<hyfen>|M|3S|DAT
pron	pron-pers	<hyfen>|M/F|3S/P|ACC
pron	pron-pers	<hyfen>|<refl>|F|3S|ACC
pron	pron-pers	<hyfen>|<refl>|M/F|1S|DAT
pron	pron-pers	M|1P|ACC
pron	pron-pers	M|1P|DAT
pron	pron-pers	M|1P|NOM
pron	pron-pers	M|1P|NOM/PIV
pron	pron-pers	M|1S|ACC
pron	pron-pers	M|1S|DAT
pron	pron-pers	M|1S|NOM
pron	pron-pers	M|1S|PIV
pron	pron-pers	M|2S|ACC
pron	pron-pers	M|2S|PIV
pron	pron-pers	M|3P|ACC
pron	pron-pers	M|3P|DAT
pron	pron-pers	M|3P|NOM
pron	pron-pers	M|3P|NOM/PIV
pron	pron-pers	M|3P|PIV
pron	pron-pers	M|3S
pron	pron-pers	M|3S|ACC
pron	pron-pers	M|3S|DAT
pron	pron-pers	M|3S|NOM
pron	pron-pers	M|3S|NOM/PIV
pron	pron-pers	M|3S/P|ACC
pron	pron-pers	M|3S|PIV
pron	pron-pers	M/F|1P|ACC
pron	pron-pers	M/F|1P|DAT
pron	pron-pers	M/F|1P|NOM
pron	pron-pers	M/F|1P|NOM/PIV
pron	pron-pers	M/F|1P|PIV
pron	pron-pers	M/F|1S|ACC
pron	pron-pers	M/F|1S|DAT
pron	pron-pers	M/F|1S|NOM
pron	pron-pers	M/F|1S|PIV
pron	pron-pers	M/F|2P|ACC
pron	pron-pers	M/F|2P|NOM
pron	pron-pers	M/F|3P|ACC
pron	pron-pers	M/F|3P|DAT
pron	pron-pers	M/F|3P|NOM
pron	pron-pers	M/F|3S|ACC
pron	pron-pers	M/F|3S|DAT
pron	pron-pers	M/F|3S|NOM
pron	pron-pers	M/F|3S|NOM/PIV
pron	pron-pers	M/F|3S/P|ACC
pron	pron-pers	<reci>|F|3P|ACC
pron	pron-pers	<reci>|M|3P|ACC
pron	pron-pers	<refl>|<coll>|F|3P|ACC
pron	pron-pers	<refl>|<coll>|M|3P|ACC
pron	pron-pers	<refl>|<coll>|M|3S|ACC
pron	pron-pers	<refl>|<coll>|M/F|3P|ACC
pron	pron-pers	<refl>|F|1S|ACC
pron	pron-pers	<refl>|F|1S|DAT
pron	pron-pers	<refl>|F|3P|ACC
pron	pron-pers	<refl>|F|3S|ACC
pron	pron-pers	<refl>|F|3S|DAT
pron	pron-pers	<refl>|F|3S|PIV
pron	pron-pers	<refl>|M/F|3S/P|ACC
pron	pron-pers	<refl>|M|1P|ACC
pron	pron-pers	<refl>|M|1P|DAT
pron	pron-pers	<refl>|M|1S|ACC
pron	pron-pers	<refl>|M|1S|DAT
pron	pron-pers	<refl>|M|2S|ACC
pron	pron-pers	<refl>|M|3P|ACC
pron	pron-pers	<refl>|M|3P|DAT
pron	pron-pers	<refl>|M|3P|PIV
pron	pron-pers	<refl>|M|3S|ACC
pron	pron-pers	<refl>|M|3S|DAT
pron	pron-pers	<refl>|M|3S/P|ACC
pron	pron-pers	<refl>|M|3S|PIV
pron	pron-pers	<refl>|M/F|1P|ACC
pron	pron-pers	<refl>|M/F|1P|ACC/DAT
pron	pron-pers	<refl>|M/F|1P|DAT
pron	pron-pers	<refl>|M/F|1S|ACC
pron	pron-pers	<refl>|M/F|1S|DAT
pron	pron-pers	<refl>|M/F|2P|DAT
pron	pron-pers	<refl>|M/F|3P|ACC
pron	pron-pers	<refl>|M/F|3S|ACC
pron	pron-pers	<refl>|M/F|3S/P|ACC
pron	pron-pers	<refl>|M/F|3S/P|ACC/DAT
pron	pron-pers	<refl>|M/F|3S/P|DAT
pron	pron-pers	<refl>|M/F|3S|PIV
pron	pron-pers	<refl>|M/F|3S/P|PIV
pron	pron-pers	<-sam>|F|1P|PIV
pron    pron-pers   F|1P|PIV
pron	pron-pers	<-sam>|F|1S|PIV
pron	pron-pers	<-sam>|F|3P|NOM
pron	pron-pers	<-sam>|F|3P|NOM/PIV
pron	pron-pers	<-sam>|F|3P|PIV
pron	pron-pers	<-sam>|F|3S|ACC
pron	pron-pers	<-sam>|F|3S|NOM/PIV
pron	pron-pers	<-sam>|F|3S|PIV
pron	pron-pers	<-sam>|M|3P|NOM
pron	pron-pers	<-sam>|M|3P|NOM/PIV
pron	pron-pers	<-sam>|M|3P|PIV
pron	pron-pers	<-sam>|M|3S|ACC
pron	pron-pers	<-sam>|M|3S|NOM
pron	pron-pers	<-sam>|M|3S|NOM/PIV
pron	pron-pers	<-sam>|M|3S|PIV
pron	pron-pers	<-sam>|M/F|2P|PIV
pron	pron-pers	<sam->|M/F|3S|DAT
pron	pron-pers	<-sam>|<refl>|F|3S|PIV
pron	pron-pers	<-sam>|<refl>|M|3S|PIV
prop	prop	_
prop	prop	<ALT>|F|S
prop	prop	<ALT>|M|S
prop	prop	<DERS>|M|S
prop	prop	M/F|S
prop	prop	F|P
prop	prop	F|S
prop	prop	<hyfen>|F|P
prop	prop	<hyfen>|F|S
prop	prop	<hyfen>|M|S
prop	prop	M/F|P
prop	prop	M/F|S
prop	prop	M/F|S/P
prop	prop	M|P
prop	prop	M|S
prop	prop	<prop>|F|S
prop	prop	<prop>|M|P
prop	prop	<prop>|M|S
prp	prp	_
prp	prp	<ALT>
prp	prp	<co-prparg>
prp	prp	<error>
prp	prp	F|S
prp	prp	<kc>
prp	prp	<kc>|<co-acc>
prp	prp	<kc>|<co-prparg>
prp	prp	<ks>
prp	prp	M|S
prp	prp	<quant>
prp	prp	<rel>
prp	prp	<rel>|<ks>
prp	prp	<rel>|<prp>
prp	prp	<-sam>
prp	prp	<sam->
prp	prp	<sam->|<co-acc>
prp	prp	<sam->|<kc>
punc	punc	_
v	v-fin	_
v	v-fin	<ALT>|IMPF|3S|IND
v	v-fin	<ALT>|IMPF|3S|SUBJ
v	v-fin	<ALT>|PR|3S|IND
v	v-fin	<ALT>|PS|3S|IND
v	v-fin	<ALT>|PS|3S|SUBJ
v	v-fin	COND|1/3S
v	v-fin	COND|1P
v	v-fin	COND|1S
v	v-fin	COND|3P
v	v-fin	COND|3S
v	v-fin	<DERP>|<DERS>|IMPF|3S|SUBJ
v	v-fin	<DERP>|PR|1S|IND
v	v-fin	<DERP>|PR|3P|IND
v	v-fin	<DERP>|PR|3S|IND
v	v-fin	<DERP>|PS|3S|IND
v	v-fin	<fmc>|PR|3S|SUBJ
v	v-fin	FUT|1/3S|SUBJ
v	v-fin	FUT|1P|IND
v	v-fin	FUT|1P|SUBJ
v	v-fin	FUT|1S|IND
v	v-fin	FUT|1S|SUBJ
v	v-fin	FUT|2S|IND
v	v-fin	FUT|3P|IND
v	v-fin	FUT|3P|SUBJ
v	v-fin	FUT|3S|IND
v	v-fin	FUT|3S|SUBJ
v	v-fin	<hyfen>|COND|1S
v	v-fin	<hyfen>|COND|3S
v	v-fin	<hyfen>|<DERP>|PR|3S|IND
v	v-fin	<hyfen>|FUT|3S|IND
v	v-fin	<hyfen>|IMPF|1S|IND
v	v-fin	<hyfen>|IMPF|3P|IND
v	v-fin	<hyfen>|IMPF|3S|IND
v	v-fin	<hyfen>|MQP|1/3S|IND
v	v-fin	<hyfen>|MQP|3S|IND
v	v-fin	<hyfen>|PR|1/3S|SUBJ
v	v-fin	<hyfen>|PR|1P|IND
v	v-fin	<hyfen>|PR|1S|IND
v	v-fin	<hyfen>|PR|3P|IND
v	v-fin	<hyfen>|PR|3P|SUBJ
v	v-fin	<hyfen>|PR|3S|IND
v	v-fin	<hyfen>|PR|3S|SUBJ
v	v-fin	<hyfen>|PS|1S|IND
v	v-fin	<hyfen>|PS|2S|IND
v	v-fin	<hyfen>|PS|3P|IND
v	v-fin	<hyfen>|PS|3S|IND
v	v-fin	<hyfen>|PS/MQP|3P|IND
v	v-fin	IMP|2S
v	v-fin	IMPF|1/3S|IND
v	v-fin	IMPF|1/3S|SUBJ
v	v-fin	IMPF|1P|IND
v	v-fin	IMPF|1P|SUBJ
v	v-fin	IMPF|1S|IND
v	v-fin	IMPF|1S|SUBJ
v	v-fin	IMPF|3P|IND
v	v-fin	IMPF|3P|SUBJ
v	v-fin	IMPF|3S|IND
v	v-fin	IMPF|3S|SUBJ
v	v-fin	MQP|1/3S|IND
v	v-fin	MQP|1S|IND
v	v-fin	MQP|3P|IND
v	v-fin	MQP|3S|IND
v	v-fin	<n>|PR|3S|IND
v	v-fin	PR|1/3S|SUBJ
v	v-fin	PR|1P|IND
v	v-fin	PR|1P|SUBJ
v	v-fin	PR|1S|IND
v	v-fin	PR|1S|SUBJ
v	v-fin	PR|2P|IND
v	v-fin	PR|2S|IND
v	v-fin	PR|2S|SUBJ
v	v-fin	PR|3P|IND
v	v-fin	PR|3P|SUBJ
v	v-fin	PR|3S
v	v-fin	PR|3S|IND
v	v-fin	PR|3S|SUBJ
v	v-fin	PR/PS|1P|IND
v	v-fin	PS|1/3S|IND
v	v-fin	PS|1P|IND
v	v-fin	PS|1S|IND
v	v-fin	PS|2S|IND
v	v-fin	PS|3P|IND
v	v-fin	PS|3S|IND
v	v-fin	PS/MQP|3P|IND
v	v-fin	<sam->|PR|3S|IND
v	v-ger	_
v	v-ger	<ALT>
v	v-ger	<hyfen>
v	v-inf	_
v	v-inf	1/3S
v	v-inf	1P
v	v-inf	1S
v	v-inf	3P
v	v-inf	3S
v	v-inf	<DERP>
v	v-inf	<DERS>
v	v-inf	FUT|3S|IND
v	v-inf	<hyfen>
v	v-inf	<hyfen>|1S
v	v-inf	<hyfen>|3P
v	v-inf	<hyfen>|3S
v	v-inf	<n>
v	v-inf	<n>|3S
v	v-pcp	_
v	v-pcp	<ALT>|F|S
v	v-pcp	<DERP>|<DERS>|M|S
v	v-pcp	<DERP>|M|P
v	v-pcp	<DERS>|F|P
v	v-pcp	<DERS>|M|S
v	v-pcp	F|P
v	v-pcp	F|S
v	v-pcp	M|P
v	v-pcp	M|S
v	v-pcp	<n>|F|P
v	v-pcp	<n>|F|S
v	v-pcp	<n>|M|P
v	v-pcp	<n>|M|S
v	v-pcp	<prop>|F|S
v	v-pcp	<prop>|M|P
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
