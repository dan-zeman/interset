#!/usr/bin/perl
# Driver for the tagset of the Korpus Języka Polskiego IPI PAN for Polish.
# Copyright © 2009 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::pl::ipipan;
use utf8;
use tagset::common;



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = 'pl::ipipan';
    my @values = split(/:/, $tag);
    # pos
    my $pos = shift(@values);
    # rzeczownik = noun
    if($pos eq 'subst')
    {
        $f{pos} = 'noun';
        decode_number(shift(@values), \%f);
        decode_case(shift(@values), \%f);
        decode_gender(shift(@values), \%f);
    }
    # rzeczownik deprecjatywny = depreciative noun
    # (possible explanation:)
    # This paper deals with the Polish construction �iść w sołdaty [be drafted; lit. become a sołdat (solider)]�,
    # which is grammatically atypical: it is not clear what the value of its noun constituent�s case is. The point
    # of departure for the analysis is Igor Mel'čuk�s paper about the parallel Russian construction. (The Polish
    # construction was borrowed from Russian during the Russian rule on Polish territory.) The solution is similar
    # to that for Russian: �sołdaty� in this expression is an atypical (non-virile or depreciative) accusative form.
    # Additionally, some similar expressions consisting of a preposition and a noun form analogous to �sołdaty� are
    # discussed. It is possible to see in them a trace of a new case in Polish (post-prepositional Accusative).
    elsif($pos eq 'depr')
    {
        $f{pos} = 'noun';
        $f{other}{pos} = 'depr';
        decode_number(shift(@values), \%f);
        decode_case(shift(@values), \%f);
        decode_gender(shift(@values), \%f);
    }
    # liczebnik główny = main numeral (kilka, czterdziestu, sto, tyle, dwanaście)
    # liczebnik zbiorowy = collective numeral (should be 'numcol'; not found any examples!)
    elsif($pos eq 'num')
    {
        $f{pos} = 'num';
        decode_number(shift(@values), \%f);
        decode_case(shift(@values), \%f);
        decode_gender(shift(@values), \%f);
        decode_accommodability(shift(@values), \%f);
    }
    # przymiotnik = adjective ((Feliks) Koneczny, znakomitego, dzisiejszego, liczne, Polskim)
    elsif($pos eq 'adj')
    {
        $f{pos} = 'adj';
        decode_number(shift(@values), \%f);
        decode_case(shift(@values), \%f);
        decode_gender(shift(@values), \%f);
        decode_degree(shift(@values), \%f);
    }
    # przymiotnik przyprzym. = adjective hyphen-connected to another adjective (Chrześcijańsko(-Demokratycznym))
    # occurred in version 1 of corpus, does not occur in version 2 ("Chrześcijańsko" has new tag "ign")
    elsif($pos eq 'adja')
    {
        $f{pos} = 'adj';
        $f{hyph} = 'hyph';
    }
    # przymiotnik poprzyim. = adjective after preposition "po", forming together an adverbial ("po prostu": [prosty:adjp])
    elsif($pos eq 'adjp')
    {
        $f{pos} = 'adj';
        $f{prepcase} = 'pre';
    }
    # przysłówek = adverb (naukowo, szybko, codziennie, ciężko, lepiej)
    elsif($pos eq 'adv')
    {
        $f{pos} = 'adv';
        decode_degree(shift(@values), \%f);
    }
    # zaimek nietrzecioosobowy = non-3rd person personal pronoun (mi, ja, mnie, nam, nas)
    elsif($pos eq 'ppron12')
    {
        $f{pos} = 'noun';
        $f{prontype} = 'prs';
        decode_number(shift(@values), \%f);
        decode_case(shift(@values), \%f);
        decode_gender(shift(@values), \%f);
        decode_person(shift(@values), \%f);
        decode_accentability(shift(@values), \%f);
    }
    # zaimek trzecioosobowy = 3rd person personal pronoun (nich, ich, ją, nim, ona)
    elsif($pos eq 'ppron3')
    {
        $f{pos} = 'noun';
        $f{prontype} = 'prs';
        decode_number(shift(@values), \%f);
        decode_case(shift(@values), \%f);
        decode_gender(shift(@values), \%f);
        decode_person(shift(@values), \%f);
        decode_accentability(shift(@values), \%f);
        decode_prepcase(shift(@values), \%f);
    }
    # zaimek SIEBIE = pronoun SIEBIE (sobie, siebie, sobą)
    elsif($pos eq 'siebie')
    {
        $f{pos} = 'noun';
        $f{prontype} = 'prs';
        $f{reflex} = 'reflex';
        decode_case(shift(@values), \%f);
    }
    # forma nieprzeszła = finite verb form (jestem, mówią, mówi, występuje, ma)
    elsif($pos eq 'fin')
    {
        $f{pos} = 'verb';
        $f{verbform} = 'fin';
        $f{mood} = 'ind';
        $f{tense} = 'pres';
        decode_number(shift(@values), \%f);
        decode_person(shift(@values), \%f);
        decode_aspect(shift(@values), \%f);
    }
    # forma przyszła BYĆ = future form of the verb "to be", BYĆ (będę, będzie, będziesz, będziemy)
    elsif($pos eq 'bedzie')
    {
        $f{pos} = 'verb';
        $f{subpos} = 'aux';
        $f{verbform} = 'fin';
        $f{mood} = 'ind';
        $f{tense} = 'fut';
        decode_number(shift(@values), \%f);
        decode_person(shift(@values), \%f);
        decode_aspect(shift(@values), \%f);
    }
    # aglutynant BYĆ = agglutinative morpheme of "to be", BYĆ (em, śmy)
    # in text attached to the preceding verb participle, split during tokenization
    elsif($pos eq 'aglt')
    {
        $f{pos} = 'verb';
        $f{subpos} = 'aux';
        $f{verbform} = 'fin';
        $f{mood} = 'ind';
        $f{tense} = 'pres';
        decode_number(shift(@values), \%f);
        decode_person(shift(@values), \%f);
        decode_aspect(shift(@values), \%f);
        decode_vocalicity(shift(@values), \%f);
    }
    # pseudoimiesłów = past tense verb (wyjechał, otrzymała, zaczęła, byli, mieszkali)
    # occurs before the agglutinative morpheme or independently
    elsif($pos eq 'praet')
    {
        $f{pos} = 'verb';
        $f{verbform} = 'fin';
        $f{mood} = 'ind';
        $f{tense} = 'past';
        decode_number(shift(@values), \%f);
        decode_gender(shift(@values), \%f);
        decode_aspect(shift(@values), \%f);
        decode_agglutination(shift(@values), \%f);
    }
    # rozkaźnik = verb imperative (ładuj, krępuj, powiedz, trzymaj, oślep)
    elsif($pos eq 'impt')
    {
        $f{pos} = 'verb';
        $f{verbform} = 'fin';
        $f{mood} = 'imp';
        decode_number(shift(@values), \%f);
        decode_person(shift(@values), \%f);
        decode_aspect(shift(@values), \%f);
    }
    # bezosobnik = verb passive participle, impersonate (odpowiedziano, urządzano, odmówiono, wykryto, napisano)
    elsif($pos eq 'imps')
    {
        $f{pos} = 'verb';
        $f{verbform} = 'part';
        $f{voice} = 'pass';
        $f{number} = 'sing';
        $f{gender} = 'neut';
        $f{case} = 'nom';
        $f{negativeness} = 'pos';
        $f{other}{pos} = 'imps';
        decode_aspect(shift(@values), \%f);
    }
    # bezokolicznik = verb infinitive (pracować, wytrzymać, pozwolić, sprężyć, pokazać)
    elsif($pos eq 'inf')
    {
        $f{pos} = 'verb';
        $f{verbform} = 'inf';
        decode_aspect(shift(@values), \%f);
    }
    # im. przys. współczesny = transgressive present (posapując, wiedząc, zapraszając, wyjeżdżając, będąc)
    elsif($pos eq 'pcon')
    {
        $f{pos} = 'verb';
        $f{verbform} = 'trans';
        $f{tense} = 'pres';
        decode_aspect(shift(@values), \%f);
    }
    # im. przys. uprzedni = transgressive past (usłyszawszy, zostawiwszy, zrobiwszy, upewniwszy, włożywszy)
    elsif($pos eq 'pant')
    {
        $f{pos} = 'verb';
        $f{verbform} = 'trans';
        $f{tense} = 'past';
        decode_aspect(shift(@values), \%f);
    }
    # odsłownik = gerund (uparcie, ustąpieniu, wprowadzeniu, odcięciu, tłumaczenia)
    elsif($pos eq 'ger')
    {
        $f{pos} = 'verb';
        $f{synpos} = 'subst';
        $f{verbform} = 'ger';
        decode_number(shift(@values), \%f);
        decode_case(shift(@values), \%f);
        decode_gender(shift(@values), \%f);
        decode_aspect(shift(@values), \%f);
        decode_negativeness(shift(@values), \%f);
    }
    # im. przym. czynny = active present participle (mieszkającej, śpiącego, wzruszające, kuszącej, kusząca)
    elsif($pos eq 'pact')
    {
        $f{pos} = 'verb';
        $f{synpos} = 'attr';
        $f{verbform} = 'part';
        $f{tense} = 'pres';
        $f{voice} = 'act';
        decode_number(shift(@values), \%f);
        decode_case(shift(@values), \%f);
        decode_gender(shift(@values), \%f);
        decode_aspect(shift(@values), \%f);
        decode_negativeness(shift(@values), \%f);
    }
    # im. przym. bierny = passive participle (położonej, otoczony, zwodzony, afiliowanym, wybrany)
    elsif($pos eq 'ppas')
    {
        $f{pos} = 'verb';
        $f{synpos} = 'attr';
        $f{verbform} = 'part';
        $f{voice} = 'pass';
        decode_number(shift(@values), \%f);
        decode_case(shift(@values), \%f);
        decode_gender(shift(@values), \%f);
        decode_aspect(shift(@values), \%f);
        decode_negativeness(shift(@values), \%f);
    }
    # winien (word 'winien' and its relatives considered a hybrid between verbs and adjectives) (powinien, winien, powinno, winny)
    elsif($pos eq 'winien')
    {
        $f{pos} = 'adj';
        $f{other}{pos} = 'winien';
        decode_number(shift(@values), \%f);
        decode_gender(shift(@values), \%f);
        decode_aspect(shift(@values), \%f);
    }
    # predykatyw = predicative (to, można, wiadomo, warto, potrzeba)
    # non-verb part of speech (demonstrative pronoun, adverb etc.) replacing clause-main verb (and sometimes the subject at the same time)
    elsif($pos eq 'pred')
    {
        $f{pos} = 'verb';
        $f{other}{pos} = 'pred';
    }
    # przyimek = preposition (na, w, z, do, po)
    elsif($pos eq 'prep')
    {
        $f{pos} = 'prep';
        decode_case(shift(@values), \%f);
        decode_vocalicity(shift(@values), \%f);
    }
    # spójnik = conjunction (i, jak, gdy, a, ale)
    elsif($pos eq 'conj')
    {
        $f{pos} = 'conj';
    }
    # kublik = particle, interjection, indeclinable adjective etc. (wówczas, gdzie, się, też, wkrótce)
    elsif($pos eq 'qub')
    {
        $f{pos} = 'part';
    }
    # ciało obce nominalne (no occurrences found)
    elsif($pos eq 'xxs')
    {
        $f{pos} = '';
        $f{foreign} = 'foreign';
        $f{other}{pos} = 'xxs';
        decode_number(shift(@values), \%f);
        decode_case(shift(@values), \%f);
        decode_gender(shift(@values), \%f);
    }
    # ciało obce luźne = foreign word (International, European, investment, Office, Deutsche)
    elsif($pos eq 'xxx')
    {
        $f{pos} = '';
        $f{foreign} = 'foreign';
    }
    # forma nierozpoznana = unrecognized form (1985, Wandzia, Queens, University, Rodera)
    elsif($pos eq 'ign')
    {
        $f{pos} = '';
    }
    # interpunkcja = punctuation (, . : � !)
    elsif($pos eq 'interp')
    {
        $f{pos} = 'punc';
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
    # driver. Do not do that if this was also the source tagset (because the
    # modification would damage tags using 'other'). However, in any case
    # create a deep copy of the original feature structure so that it is
    # protected from changes during encoding.
    my $f;
    if($f0->{tagset} eq 'pl::ipipan')
    {
        $f = tagset::common::duplicate($f0);
    }
    else
    {
        $f = tagset::common::enforce_permitted_joint($f0, $permitted);
    }
    my %f = %{$f};
    my $nonstrict = shift; # strict is default
    $strict = !$nonstrict;
    my $tag;
    # Part of speech (the first letter of the tag) specifies which features follow.
    my $pos = $f{pos};
    if($f{foreign} eq 'foreign')
    {
        # ciało obce nominalne (no occurrences found)
        if($f{tagset} eq 'pl::ipipan' && $f{other}{pos} eq 'xxs')
        {
            $tag = 'xxs';
            $tag .= ':'.encode_number($f);
            $tag .= ':'.encode_case($f);
            $tag .= ':'.encode_gender($f);
        }
        # ciało obce luźne = foreign word (International, European, investment, Office, Deutsche)
        else
        {
            $tag = 'xxx';
        }
    }
    # rzeczownik = noun
    elsif($pos eq 'noun')
    {
        if($f{prontype} eq 'prs')
        {
            # zaimek SIEBIE = pronoun SIEBIE (sobie, siebie, sobą)
            if($f{reflex} eq 'reflex')
            {
                $tag = 'siebie';
                $tag .= ':'.encode_case($f);
            }
            # zaimek trzecioosobowy = 3rd person personal pronoun (nich, ich, ją, nim, ona)
            elsif($f{person} == 3)
            {
                $tag = 'ppron3';
                $tag .= ':'.encode_number($f);
                $tag .= ':'.encode_case($f);
                $tag .= ':'.encode_gender($f);
                $tag .= ':'.encode_person($f);
                $tag .= ':'.encode_accentability($f);
                $tag .= ':'.encode_prepcase($f);
            }
            # zaimek nietrzecioosobowy = non-3rd person personal pronoun (mi, ja, mnie, nam, nas)
            else
            {
                $tag = 'ppron12';
                $tag .= ':'.encode_number($f);
                $tag .= ':'.encode_case($f);
                $tag .= ':'.encode_gender($f);
                $tag .= ':'.encode_person($f);
                my $accentability = encode_accentability($f);
                if($accentability)
                {
                    $tag .= ':'.$accentability;
                }
            }
        }
        else
        {
            if($f{tagset} eq 'pl::ipipan' && $f{other}{pos} eq 'depr')
            {
                $tag = 'depr';
            }
            else
            {
                $tag = 'subst';
            }
            $tag .= ':'.encode_number($f);
            $tag .= ':'.encode_case($f);
            $tag .= ':'.encode_gender($f);
        }
    }
    # liczebnik główny = main numeral (kilka, czterdziestu, sto, tyle, dwanaście)
    # liczebnik zbiorowy = collective numeral (should be 'numcol'; not found any examples!)
    elsif($pos eq 'num')
    {
        $tag = 'num';
        $tag .= ':'.encode_number($f);
        $tag .= ':'.encode_case($f);
        $tag .= ':'.encode_gender($f);
        my $accommodability = encode_accommodability($f);
        if($accommodability)
        {
            $tag .= ':'.$accommodability;
        }
    }
    # przymiotnik = adjective ((Feliks) Koneczny, znakomitego, dzisiejszego, liczne, Polskim)
    elsif($pos eq 'adj')
    {
        if($f{tagset} eq 'pl::ipipan' && $f{other}{pos} eq 'winien')
        {
            $tag = 'winien';
            $tag .= ':'.encode_number($f);
            $tag .= ':'.encode_gender($f);
            $tag .= ':'.encode_aspect($f);
        }
        elsif($f{hyph} eq 'hyph')
        {
            $tag = 'adja';
        }
        elsif($f{prepcase} eq 'pre')
        {
            $tag = 'adjp';
        }
        else
        {
            $tag = 'adj';
            $tag .= ':'.encode_number($f);
            $tag .= ':'.encode_case($f);
            $tag .= ':'.encode_gender($f);
            $tag .= ':'.encode_degree($f);
        }
    }
    # przysłówek = adverb (naukowo, szybko, codziennie, ciężko, lepiej)
    elsif($pos eq 'adv')
    {
        $tag = 'adv';
        $tag .= ':'.encode_degree($f);
    }
    # verb forms
    elsif($pos eq 'verb')
    {
        # predykatyw = predicative (to, można, wiadomo, warto, potrzeba)
        # non-verb part of speech (demonstrative pronoun, adverb etc.) replacing clause-main verb (and sometimes the subject at the same time)
        if($f{tagset} eq 'pl::ipipan' && $f{other}{pos} eq 'pred')
        {
            $tag = 'pred';
        }
        # odsłownik = gerund (uparcie, ustąpieniu, wprowadzeniu, odcięciu, tłumaczenia)
        elsif($f{verbform} eq 'ger')
        {
            $tag = 'ger';
            $tag .= ':'.encode_number($f);
            $tag .= ':'.encode_case($f);
            $tag .= ':'.encode_gender($f);
            $tag .= ':'.encode_aspect($f);
            $tag .= ':'.encode_negativeness($f);
        }
        elsif($f{verbform} eq 'part')
        {
            if($f{voice} eq 'pass')
            {
                # bezosobnik = verb passive participle, impersonate (odpowiedziano, urządzano, odmówiono, wykryto, napisano)
                if($f{tagset} eq 'pl::ipipan' && $f{other}{pos} eq 'imps')
                {
                    $tag = 'imps';
                    $tag .= ':'.encode_aspect($f);
                }
                # im. przym. bierny = passive participle (położonej, otoczony, zwodzony, afiliowanym, wybrany)
                else
                {
                    $tag = 'ppas';
                    $tag .= ':'.encode_number($f);
                    $tag .= ':'.encode_case($f);
                    $tag .= ':'.encode_gender($f);
                    $tag .= ':'.encode_aspect($f);
                    $tag .= ':'.encode_negativeness($f);
                }
            }
            # im. przym. czynny = active present participle (mieszkającej, śpiącego, wzruszające, kuszącej, kusząca)
            else
            {
                $tag = 'pact';
                $tag .= ':'.encode_number($f);
                $tag .= ':'.encode_case($f);
                $tag .= ':'.encode_gender($f);
                $tag .= ':'.encode_aspect($f);
                $tag .= ':'.encode_negativeness($f);
            }
        }
        elsif($f{verbform} eq 'trans')
        {
            # im. przys. uprzedni = transgressive past (usłyszawszy, zostawiwszy, zrobiwszy, upewniwszy, włożywszy)
            if($f{tense} eq 'past')
            {
                $tag = 'pant';
                $tag .= ':'.encode_aspect($f);
            }
            # im. przys. współczesny = transgressive present (posapując, wiedząc, zapraszając, wyjeżdżając, będąc)
            else
            {
                $tag = 'pcon';
                $tag .= ':'.encode_aspect($f);
            }
        }
        # rozkaźnik = verb imperative (ładuj, krępuj, powiedz, trzymaj, oślep)
        elsif($f{mood} eq 'imp')
        {
            $tag = 'impt';
            $tag .= ':'.encode_number($f);
            $tag .= ':'.encode_person($f);
            $tag .= ':'.encode_aspect($f);
        }
        elsif($f{subpos} eq 'aux')
        {
            # forma przyszła BYĆ = future form of the verb "to be", BYĆ (będę, będzie, będziesz, będziemy)
            if($f{tense} eq 'fut')
            {
                $tag = 'bedzie';
                $tag .= ':'.encode_number($f);
                $tag .= ':'.encode_person($f);
                $tag .= ':'.encode_aspect($f);
            }
            # aglutynant BYĆ = agglutinative morpheme of "to be", BYĆ (em, śmy)
            else
            {
                $tag = 'aglt';
                $tag .= ':'.encode_number($f);
                $tag .= ':'.encode_person($f);
                $tag .= ':'.encode_aspect($f);
                $tag .= ':'.encode_vocalicity($f);
            }
        }
        elsif($f{verbform} eq 'fin')
        {
            # pseudoimiesłów = past tense verb (wyjechał, otrzymała, zaczęła, byli, mieszkali)
            if($f{tense} eq 'past')
            {
                $tag = 'praet';
                $tag .= ':'.encode_number($f);
                $tag .= ':'.encode_gender($f);
                $tag .= ':'.encode_aspect($f);
                my $agglutination = encode_agglutination($f);
                if($agglutination)
                {
                    $tag .= ':'.$agglutination;
                }
            }
            # forma nieprzeszła = finite verb form (jestem, mówią, mówi, występuje, ma)
            else
            {
                $tag = 'fin';
                $tag .= ':'.encode_number($f);
                $tag .= ':'.encode_person($f);
                $tag .= ':'.encode_aspect($f);
            }
        }
        # bezokolicznik = verb infinitive (pracować, wytrzymać, pozwolić, sprężyć, pokazać)
        else
        {
            $tag = 'inf';
            $tag .= ':'.encode_aspect($f);
        }
    }
    # przyimek = preposition (na, w, z, do, po)
    elsif($pos eq 'prep')
    {
        $tag = 'prep';
        $tag .= ':'.encode_case($f);
        my $vocalicity = encode_vocalicity($f);
        if($vocalicity)
        {
            $tag .= ':'.$vocalicity;
        }
    }
    # spójnik = conjunction (i, jak, gdy, a, ale)
    elsif($pos eq 'conj')
    {
        $tag = 'conj';
    }
    # kublik = particle, interjection, indeclinable adjective etc. (wówczas, gdzie, się, też, wkrótce)
    elsif($pos eq 'part')
    {
        $tag = 'qub';
    }
    # interpunkcja = punctuation (, . : � !)
    elsif($pos eq 'punc')
    {
        $tag = 'interp';
    }
    # forma nierozpoznana = unrecognized form (1985, Wandzia, Queens, University, Rodera)
    else
    {
        $tag = 'ign';
    }
    return $tag;
}



#------------------------------------------------------------------------------
# Decodes gender (rodzaj) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_gender
{
    my $gender = shift; # string
    my $f = shift; # reference to hash
    if($gender eq 'm1')
    {
        $f->{gender} = 'masc';
        $f->{animateness} = 'anim';
    }
    elsif($gender eq 'm2')
    {
        $f->{gender} = 'masc';
        $f->{animateness} = 'nhum';
    }
    elsif($gender eq 'm3')
    {
        $f->{gender} = 'masc';
        $f->{animateness} = 'inan';
    }
    elsif($gender eq 'f')
    {
        $f->{gender} = 'fem';
    }
    elsif($gender eq 'n')
    {
        $f->{gender} = 'neut';
    }
    return $f->{gender};
}



#------------------------------------------------------------------------------
# Encodes gender (rodzaj) as a string.
#------------------------------------------------------------------------------
sub encode_gender
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{gender} eq 'masc')
    {
        if($f->{animateness} eq 'nhum')
        {
            $c = 'm2';
        }
        elsif($f->{animateness} eq 'inan')
        {
            $c = 'm3';
        }
        else
        {
            $c = 'm1';
        }
    }
    elsif($f->{gender} eq 'fem')
    {
        $c = 'f';
    }
    elsif($f->{gender} eq 'neut')
    {
        $c = 'n';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes number (liczba) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_number
{
    my $number = shift; # string
    my $f = shift; # reference to hash
    if($number eq 'sg')
    {
        $f->{number} = 'sing';
    }
    elsif($number eq 'pl')
    {
        $f->{number} = 'plu';
    }
    return $f->{number};
}



#------------------------------------------------------------------------------
# Encodes number (liczba) as a string.
#------------------------------------------------------------------------------
sub encode_number
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{number} eq 'sing')
    {
        $c = 'sg';
    }
    elsif($f->{number} eq 'plu')
    {
        $c = 'pl';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes case (przypadek) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_case
{
    my $case = shift; # string
    my $f = shift; # reference to hash
    if($case eq 'nom')
    {
        $f->{case} = 'nom';
    }
    elsif($case eq 'gen')
    {
        $f->{case} = 'gen';
    }
    elsif($case eq 'dat')
    {
        $f->{case} = 'dat';
    }
    elsif($case eq 'acc')
    {
        $f->{case} = 'acc';
    }
    elsif($case eq 'voc')
    {
        $f->{case} = 'voc';
    }
    elsif($case eq 'loc')
    {
        $f->{case} = 'loc';
    }
    elsif($case eq 'inst')
    {
        $f->{case} = 'ins';
    }
    return $f->{case};
}



#------------------------------------------------------------------------------
# Encodes case (przypadek) as a string.
#------------------------------------------------------------------------------
sub encode_case
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{case} eq 'nom')
    {
        $c = 'nom';
    }
    elsif($f->{case} eq 'gen')
    {
        $c = 'gen';
    }
    elsif($f->{case} eq 'dat')
    {
        $c = 'dat';
    }
    elsif($f->{case} eq 'acc')
    {
        $c = 'acc';
    }
    elsif($f->{case} eq 'voc')
    {
        $c = 'voc';
    }
    elsif($f->{case} eq 'loc')
    {
        $c = 'loc';
    }
    elsif($f->{case} eq 'ins')
    {
        $c = 'inst';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes person (osoba) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_person
{
    my $person = shift; # string
    my $f = shift; # reference to hash
    if($person eq 'pri')
    {
        $f->{person} = '1';
    }
    elsif($person eq 'sec')
    {
        $f->{person} = '2';
    }
    elsif($person eq 'ter')
    {
        $f->{person} = '3';
    }
    return $f->{person};
}



#------------------------------------------------------------------------------
# Encodes person (osoba) as a string.
#------------------------------------------------------------------------------
sub encode_person
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{person} == 1)
    {
        $c = 'pri';
    }
    elsif($f->{person} == 2)
    {
        $c = 'sec';
    }
    elsif($f->{person} == 3)
    {
        $c = 'ter';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes the degree of comparison (stopień) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_degree
{
    my $degree = shift; # string
    my $f = shift; # reference to hash
    if($degree eq 'pos')
    {
        $f->{degree} = 'pos';
    }
    elsif($degree eq 'comp')
    {
        $f->{degree} = 'comp';
    }
    elsif($degree eq 'sup')
    {
        $f->{degree} = 'sup';
    }
    return $f->{degree};
}



#------------------------------------------------------------------------------
# Encodes degree of comparison (stopień) as a string.
#------------------------------------------------------------------------------
sub encode_degree
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{degree} eq 'pos')
    {
        $c = 'pos';
    }
    elsif($f->{degree} eq 'comp')
    {
        $c = 'comp';
    }
    elsif($f->{degree} eq 'sup')
    {
        $c = 'sup';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes aspect (aspekt) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_aspect
{
    my $aspect = shift; # string
    my $f = shift; # reference to hash
    if($aspect eq 'imperf')
    {
        $f->{aspect} = 'imp';
    }
    elsif($aspect eq 'perf')
    {
        $f->{aspect} = 'perf';
    }
    return $f->{aspect};
}



#------------------------------------------------------------------------------
# Encodes aspect (aspekt) as a string.
#------------------------------------------------------------------------------
sub encode_aspect
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{aspect} eq 'imp')
    {
        $c = 'imperf';
    }
    elsif($f->{aspect} eq 'perf')
    {
        $c = 'perf';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes negativeness (zanegowanie) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_negativeness
{
    my $negativeness = shift; # string
    my $f = shift; # reference to hash
    if($negativeness eq 'aff')
    {
        $f->{negativeness} = 'pos';
    }
    elsif($negativeness eq 'neg')
    {
        $f->{negativeness} = 'neg';
    }
    return $f->{negativeness};
}



#------------------------------------------------------------------------------
# Encodes negativeness (zanegowanie) as a string.
#------------------------------------------------------------------------------
sub encode_negativeness
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{negativeness} eq 'pos')
    {
        $c = 'aff';
    }
    elsif($f->{negativeness} eq 'neg')
    {
        $c = 'neg';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes accentability (akcentowość) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_accentability
{
    my $accentness = shift; # string
    my $f = shift; # reference to hash
    if($accentness eq 'akc') # (jego, niego, tobie)
    {
        $f->{variant} = 'long';
    }
    elsif($accentness eq 'nakc') # (go, -ń, ci)
    {
        $f->{variant} = 'short';
    }
    return $f->{variant};
}



#------------------------------------------------------------------------------
# Encodes accentability (akcentowość) as a string.
#------------------------------------------------------------------------------
sub encode_accentability
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{variant} eq 'short')
    {
        $c = 'nakc';
    }
    elsif($f->{variant} eq 'long')
    {
        $c = 'akc';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes special form after preposition (poprzyimkowość) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_prepcase
{
    my $prepcase = shift; # string
    my $f = shift; # reference to hash
    if($prepcase eq 'praep') # (niego, -ń)
    {
        $f->{prepcase} = 'pre';
    }
    elsif($prepcase eq 'npraep') # (jego, go)
    {
        $f->{prepcase} = 'npr';
    }
    return $f->{prepcase};
}



#------------------------------------------------------------------------------
# Encodes special form after preposition (poprzyimkowość) as a string.
#------------------------------------------------------------------------------
sub encode_prepcase
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{prepcase} eq 'pre')
    {
        $c = 'praep';
    }
    else
    {
        $c = 'npraep';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes accommodability (akomodacyjność) and stores it in a feature structure.
# This is a strange feature that deals with case of numerals. I do not know
# exactly what it encodes. Some numerals govern the counted nouns and force
# them to genitive plural (pięciu mych współpracowników), some agree with the
# counted nouns in case (trzech wileńskich i dwóch warszawskich). This also
# happens in Czech. However, it does not seem to be THE distinction. Both
# above examples appear with accommodability=rec. However, in Polish, sometimes
# the numeral itself is in genitive plural, despite the counted noun (wszyci
# trzej prowadzili; dwaj synowie; czterej profesorowie głosowali). These cases
# have accommodability=congr. Moreover, the accommodability attribute is often
# empty. It only occurs with numerals in plural nominative masculine human
# gender (and it need not occur even there).
#
# Note: accommodability=congr seems to only apply to numerical values 2-4:
# dwaj, obaj, obydwaj, trzej, czterej.
# dwaj [dwa:num:pl:nom:m1:congr]
## jacyś  	 dwaj [dwa:num:pl:nom:m1:congr]  	 szesnastolatkowie znaleźli
# dwóch [dwa:num:pl:nom:m1:rec]
## jeden gra na grzebieniu,  	 dwóch [dwa:num:pl:nom:m1:rec]  	 rzuca w siebie papierowymi strzałami
# for num:pl:nom:m1, without accommodability set, the following lemmas have been observed:
# dwoje, czworo, kilkoro, jedenaścioro
## Kiedy  	 dwoje [dwoje:num:pl:nom:m1]  	 ludzi mówi
#------------------------------------------------------------------------------
sub decode_accommodability
{
    my $accom = shift; # string
    my $f = shift; # reference to hash
    if($accom eq 'congr')
    {
        $f->{other}{accom} = 'congr';
    }
    elsif($accom eq 'rec')
    {
        $f->{other}{accom} = 'rec';
    }
    return $f->{other}{accom};
}



#------------------------------------------------------------------------------
# Encodes accommodability (akomodacyjność) as a string.
#------------------------------------------------------------------------------
sub encode_accommodability
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{tagset} eq 'pl::ipipan')
    {
        if($f->{other}{accom} eq 'congr')
        {
            $c = 'congr';
        }
        elsif($f->{other}{accom} eq 'rec')
        {
            $c = 'rec';
        }
    }
    else
    {
        $c = '';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes whether there is an attached (although split by tokenization)
# agglutinative morpheme (clitic?) of the verb "być" ("to be") and stores it in
# a feature structure (aglutynacyjność).
#------------------------------------------------------------------------------
sub decode_agglutination
{
    # nagl: niósł
    # agl:  niosł- (e.g. niosłem, niosłeś)
    # DZ Interset does not have a corresponding feature.
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq 'nagl')
    {
        $f->{other}{agglutination} = 'nagl';
    }
    elsif($c eq 'agl')
    {
        $f->{other}{agglutination} = 'agl';
    }
    return $f->{other}{agglutination};
}



#------------------------------------------------------------------------------
# Encodes agglutination (aglutynacyjność) as a string.
#------------------------------------------------------------------------------
sub encode_agglutination
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{tagset} eq 'pl::ipipan')
    {
        $c = $f->{other}{agglutination};
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes vocalicity (wokaliczność) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_vocalicity
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq 'wok')
    {
        $f->{variant} = 'long';
    }
    elsif($c eq 'nwok')
    {
        $f->{variant} = 'short';
    }
    return $f->{variant};
}



#------------------------------------------------------------------------------
# Encodes vocalicity (wokaliczność) as a string.
#------------------------------------------------------------------------------
sub encode_vocalicity
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{variant} eq 'long')
    {
        $c = 'wok';
    }
    elsif($f->{variant} eq 'short')
    {
        $c = 'nwok';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# 1282
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
adj:pl:acc:f:comp
adj:pl:acc:f:pos
adj:pl:acc:f:sup
adj:pl:acc:m1:comp
adj:pl:acc:m1:pos
adj:pl:acc:m1:sup
adj:pl:acc:m2:comp
adj:pl:acc:m2:pos
adj:pl:acc:m2:sup
adj:pl:acc:m3:comp
adj:pl:acc:m3:pos
adj:pl:acc:m3:sup
adj:pl:acc:n:comp
adj:pl:acc:n:pos
adj:pl:acc:n:sup
adj:pl:dat:f:comp
adj:pl:dat:f:pos
adj:pl:dat:f:sup
adj:pl:dat:m1:comp
adj:pl:dat:m1:pos
adj:pl:dat:m1:sup
adj:pl:dat:m2:comp
adj:pl:dat:m2:pos
adj:pl:dat:m2:sup
adj:pl:dat:m3:comp
adj:pl:dat:m3:pos
adj:pl:dat:m3:sup
adj:pl:dat:n:comp
adj:pl:dat:n:pos
adj:pl:dat:n:sup
adj:pl:gen:f:comp
adj:pl:gen:f:pos
adj:pl:gen:f:sup
adj:pl:gen:m1:comp
adj:pl:gen:m1:pos
adj:pl:gen:m1:sup
adj:pl:gen:m2:comp
adj:pl:gen:m2:pos
adj:pl:gen:m2:sup
adj:pl:gen:m3:comp
adj:pl:gen:m3:pos
adj:pl:gen:m3:sup
adj:pl:gen:n:comp
adj:pl:gen:n:pos
adj:pl:gen:n:sup
adj:pl:inst:f:comp
adj:pl:inst:f:pos
adj:pl:inst:f:sup
adj:pl:inst:m1:comp
adj:pl:inst:m1:pos
adj:pl:inst:m1:sup
adj:pl:inst:m2:comp
adj:pl:inst:m2:pos
adj:pl:inst:m2:sup
adj:pl:inst:m3:comp
adj:pl:inst:m3:pos
adj:pl:inst:m3:sup
adj:pl:inst:n:comp
adj:pl:inst:n:pos
adj:pl:inst:n:sup
adj:pl:loc:f:comp
adj:pl:loc:f:pos
adj:pl:loc:f:sup
adj:pl:loc:m1:comp
adj:pl:loc:m1:pos
adj:pl:loc:m1:sup
adj:pl:loc:m2:comp
adj:pl:loc:m2:pos
adj:pl:loc:m2:sup
adj:pl:loc:m3:comp
adj:pl:loc:m3:pos
adj:pl:loc:m3:sup
adj:pl:loc:n:comp
adj:pl:loc:n:pos
adj:pl:loc:n:sup
adj:pl:nom:f:comp
adj:pl:nom:f:pos
adj:pl:nom:f:sup
adj:pl:nom:m1:comp
adj:pl:nom:m1:pos
adj:pl:nom:m1:sup
adj:pl:nom:m2:comp
adj:pl:nom:m2:pos
adj:pl:nom:m2:sup
adj:pl:nom:m3:comp
adj:pl:nom:m3:pos
adj:pl:nom:m3:sup
adj:pl:nom:n:comp
adj:pl:nom:n:pos
adj:pl:nom:n:sup
adj:sg:acc:f:comp
adj:sg:acc:f:pos
adj:sg:acc:f:sup
adj:sg:acc:m1:comp
adj:sg:acc:m1:pos
adj:sg:acc:m1:sup
adj:sg:acc:m2:comp
adj:sg:acc:m2:pos
adj:sg:acc:m2:sup
adj:sg:acc:m3:comp
adj:sg:acc:m3:pos
adj:sg:acc:m3:sup
adj:sg:acc:n:comp
adj:sg:acc:n:pos
adj:sg:acc:n:sup
adj:sg:dat:f:comp
adj:sg:dat:f:pos
adj:sg:dat:f:sup
adj:sg:dat:m1:comp
adj:sg:dat:m1:pos
adj:sg:dat:m1:sup
adj:sg:dat:m2:comp
adj:sg:dat:m2:pos
adj:sg:dat:m2:sup
adj:sg:dat:m3:comp
adj:sg:dat:m3:pos
adj:sg:dat:m3:sup
adj:sg:dat:n:comp
adj:sg:dat:n:pos
adj:sg:dat:n:sup
adj:sg:gen:f:comp
adj:sg:gen:f:pos
adj:sg:gen:f:sup
adj:sg:gen:m1:comp
adj:sg:gen:m1:pos
adj:sg:gen:m1:sup
adj:sg:gen:m2:comp
adj:sg:gen:m2:pos
adj:sg:gen:m2:sup
adj:sg:gen:m3:comp
adj:sg:gen:m3:pos
adj:sg:gen:m3:sup
adj:sg:gen:n:comp
adj:sg:gen:n:pos
adj:sg:gen:n:sup
adj:sg:inst:f:comp
adj:sg:inst:f:pos
adj:sg:inst:f:sup
adj:sg:inst:m1:comp
adj:sg:inst:m1:pos
adj:sg:inst:m1:sup
adj:sg:inst:m2:comp
adj:sg:inst:m2:pos
adj:sg:inst:m2:sup
adj:sg:inst:m3:comp
adj:sg:inst:m3:pos
adj:sg:inst:m3:sup
adj:sg:inst:n:comp
adj:sg:inst:n:pos
adj:sg:inst:n:sup
adj:sg:loc:f:comp
adj:sg:loc:f:pos
adj:sg:loc:f:sup
adj:sg:loc:m1:comp
adj:sg:loc:m1:pos
adj:sg:loc:m1:sup
adj:sg:loc:m2:comp
adj:sg:loc:m2:pos
adj:sg:loc:m2:sup
adj:sg:loc:m3:comp
adj:sg:loc:m3:pos
adj:sg:loc:m3:sup
adj:sg:loc:n:comp
adj:sg:loc:n:pos
adj:sg:loc:n:sup
adj:sg:nom:f:comp
adj:sg:nom:f:pos
adj:sg:nom:f:sup
adj:sg:nom:m1:comp
adj:sg:nom:m1:pos
adj:sg:nom:m1:sup
adj:sg:nom:m2:comp
adj:sg:nom:m2:pos
adj:sg:nom:m2:sup
adj:sg:nom:m3:comp
adj:sg:nom:m3:pos
adj:sg:nom:m3:sup
adj:sg:nom:n:comp
adj:sg:nom:n:pos
adj:sg:nom:n:sup
adjp
adv:comp
adv:pos
adv:sup
aglt:pl:pri:imperf:nwok
aglt:pl:sec:imperf:nwok
aglt:sg:pri:imperf:nwok
aglt:sg:pri:imperf:wok
aglt:sg:sec:imperf:nwok
aglt:sg:sec:imperf:wok
bedzie:pl:pri:imperf
bedzie:pl:sec:imperf
bedzie:pl:ter:imperf
bedzie:sg:pri:imperf
bedzie:sg:sec:imperf
bedzie:sg:ter:imperf
conj
depr:pl:nom:m2
depr:pl:voc:m2
fin:pl:pri:imperf
fin:pl:pri:perf
fin:pl:sec:imperf
fin:pl:sec:perf
fin:pl:ter:imperf
fin:pl:ter:perf
fin:sg:pri:imperf
fin:sg:pri:perf
fin:sg:sec:imperf
fin:sg:sec:perf
fin:sg:ter:imperf
fin:sg:ter:perf
ger:sg:acc:n:imperf:aff
ger:sg:acc:n:imperf:neg
ger:sg:acc:n:perf:aff
ger:sg:acc:n:perf:neg
ger:sg:dat:n:imperf:aff
ger:sg:dat:n:imperf:neg
ger:sg:dat:n:perf:aff
ger:sg:dat:n:perf:neg
ger:sg:gen:n:imperf:aff
ger:sg:gen:n:imperf:neg
ger:sg:gen:n:perf:aff
ger:sg:gen:n:perf:neg
ger:sg:inst:n:imperf:aff
ger:sg:inst:n:imperf:neg
ger:sg:inst:n:perf:aff
ger:sg:inst:n:perf:neg
ger:sg:loc:n:imperf:aff
ger:sg:loc:n:imperf:neg
ger:sg:loc:n:perf:aff
ger:sg:loc:n:perf:neg
ger:sg:nom:n:imperf:aff
ger:sg:nom:n:imperf:neg
ger:sg:nom:n:perf:aff
ger:sg:nom:n:perf:neg
ign
imps:imperf
imps:perf
impt:pl:pri:imperf
impt:pl:pri:perf
impt:pl:sec:imperf
impt:pl:sec:perf
impt:sg:sec:imperf
impt:sg:sec:perf
inf:imperf
inf:perf
interp
num:pl:acc:f
num:pl:acc:m1
num:pl:acc:m2
num:pl:acc:m3
num:pl:acc:n
num:pl:dat:f
num:pl:dat:m1
num:pl:dat:m2
num:pl:dat:m3
num:pl:dat:n
num:pl:gen:f
num:pl:gen:m1
num:pl:gen:m2
num:pl:gen:m3
num:pl:gen:n
num:pl:inst:f
num:pl:inst:m1
num:pl:inst:m2
num:pl:inst:m3
num:pl:inst:n
num:pl:loc:f
num:pl:loc:m1
num:pl:loc:m2
num:pl:loc:m3
num:pl:loc:n
num:pl:nom:f
num:pl:nom:m1
num:pl:nom:m1:congr
num:pl:nom:m1:rec
num:pl:nom:m2
num:pl:nom:m3
num:pl:nom:n
num:pl:voc:f
num:pl:voc:m1
num:pl:voc:m2
num:pl:voc:m3
num:pl:voc:n
pact:pl:acc:f:imperf:aff
pact:pl:acc:f:imperf:neg
pact:pl:acc:f:perf:aff
pact:pl:acc:f:perf:neg
pact:pl:acc:m1:imperf:aff
pact:pl:acc:m1:imperf:neg
pact:pl:acc:m1:perf:aff
pact:pl:acc:m1:perf:neg
pact:pl:acc:m2:imperf:aff
pact:pl:acc:m2:imperf:neg
pact:pl:acc:m2:perf:aff
pact:pl:acc:m2:perf:neg
pact:pl:acc:m3:imperf:aff
pact:pl:acc:m3:imperf:neg
pact:pl:acc:m3:perf:aff
pact:pl:acc:m3:perf:neg
pact:pl:acc:n:imperf:aff
pact:pl:acc:n:imperf:neg
pact:pl:acc:n:perf:aff
pact:pl:acc:n:perf:neg
pact:pl:dat:f:imperf:aff
pact:pl:dat:f:imperf:neg
pact:pl:dat:f:perf:aff
pact:pl:dat:f:perf:neg
pact:pl:dat:m1:imperf:aff
pact:pl:dat:m1:imperf:neg
pact:pl:dat:m1:perf:aff
pact:pl:dat:m1:perf:neg
pact:pl:dat:m2:imperf:aff
pact:pl:dat:m2:imperf:neg
pact:pl:dat:m2:perf:aff
pact:pl:dat:m2:perf:neg
pact:pl:dat:m3:imperf:aff
pact:pl:dat:m3:imperf:neg
pact:pl:dat:m3:perf:aff
pact:pl:dat:m3:perf:neg
pact:pl:dat:n:imperf:aff
pact:pl:dat:n:imperf:neg
pact:pl:dat:n:perf:aff
pact:pl:dat:n:perf:neg
pact:pl:gen:f:imperf:aff
pact:pl:gen:f:imperf:neg
pact:pl:gen:f:perf:aff
pact:pl:gen:f:perf:neg
pact:pl:gen:m1:imperf:aff
pact:pl:gen:m1:imperf:neg
pact:pl:gen:m1:perf:aff
pact:pl:gen:m1:perf:neg
pact:pl:gen:m2:imperf:aff
pact:pl:gen:m2:imperf:neg
pact:pl:gen:m2:perf:aff
pact:pl:gen:m2:perf:neg
pact:pl:gen:m3:imperf:aff
pact:pl:gen:m3:imperf:neg
pact:pl:gen:m3:perf:aff
pact:pl:gen:m3:perf:neg
pact:pl:gen:n:imperf:aff
pact:pl:gen:n:imperf:neg
pact:pl:gen:n:perf:aff
pact:pl:gen:n:perf:neg
pact:pl:inst:f:imperf:aff
pact:pl:inst:f:imperf:neg
pact:pl:inst:f:perf:aff
pact:pl:inst:f:perf:neg
pact:pl:inst:m1:imperf:aff
pact:pl:inst:m1:imperf:neg
pact:pl:inst:m1:perf:aff
pact:pl:inst:m1:perf:neg
pact:pl:inst:m2:imperf:aff
pact:pl:inst:m2:imperf:neg
pact:pl:inst:m2:perf:aff
pact:pl:inst:m2:perf:neg
pact:pl:inst:m3:imperf:aff
pact:pl:inst:m3:imperf:neg
pact:pl:inst:m3:perf:aff
pact:pl:inst:m3:perf:neg
pact:pl:inst:n:imperf:aff
pact:pl:inst:n:imperf:neg
pact:pl:inst:n:perf:aff
pact:pl:inst:n:perf:neg
pact:pl:loc:f:imperf:aff
pact:pl:loc:f:imperf:neg
pact:pl:loc:f:perf:aff
pact:pl:loc:f:perf:neg
pact:pl:loc:m1:imperf:aff
pact:pl:loc:m1:imperf:neg
pact:pl:loc:m1:perf:aff
pact:pl:loc:m1:perf:neg
pact:pl:loc:m2:imperf:aff
pact:pl:loc:m2:imperf:neg
pact:pl:loc:m2:perf:aff
pact:pl:loc:m2:perf:neg
pact:pl:loc:m3:imperf:aff
pact:pl:loc:m3:imperf:neg
pact:pl:loc:m3:perf:aff
pact:pl:loc:m3:perf:neg
pact:pl:loc:n:imperf:aff
pact:pl:loc:n:imperf:neg
pact:pl:loc:n:perf:aff
pact:pl:loc:n:perf:neg
pact:pl:nom:f:imperf:aff
pact:pl:nom:f:imperf:neg
pact:pl:nom:f:perf:aff
pact:pl:nom:f:perf:neg
pact:pl:nom:m1:imperf:aff
pact:pl:nom:m1:imperf:neg
pact:pl:nom:m1:perf:aff
pact:pl:nom:m1:perf:neg
pact:pl:nom:m2:imperf:aff
pact:pl:nom:m2:imperf:neg
pact:pl:nom:m2:perf:aff
pact:pl:nom:m2:perf:neg
pact:pl:nom:m3:imperf:aff
pact:pl:nom:m3:imperf:neg
pact:pl:nom:m3:perf:aff
pact:pl:nom:m3:perf:neg
pact:pl:nom:n:imperf:aff
pact:pl:nom:n:imperf:neg
pact:pl:nom:n:perf:aff
pact:pl:nom:n:perf:neg
pact:sg:acc:f:imperf:aff
pact:sg:acc:f:imperf:neg
pact:sg:acc:f:perf:aff
pact:sg:acc:f:perf:neg
pact:sg:acc:m1:imperf:aff
pact:sg:acc:m1:imperf:neg
pact:sg:acc:m1:perf:aff
pact:sg:acc:m1:perf:neg
pact:sg:acc:m2:imperf:aff
pact:sg:acc:m2:imperf:neg
pact:sg:acc:m2:perf:aff
pact:sg:acc:m2:perf:neg
pact:sg:acc:m3:imperf:aff
pact:sg:acc:m3:imperf:neg
pact:sg:acc:m3:perf:aff
pact:sg:acc:m3:perf:neg
pact:sg:acc:n:imperf:aff
pact:sg:acc:n:imperf:neg
pact:sg:acc:n:perf:aff
pact:sg:acc:n:perf:neg
pact:sg:dat:f:imperf:aff
pact:sg:dat:f:imperf:neg
pact:sg:dat:f:perf:aff
pact:sg:dat:f:perf:neg
pact:sg:dat:m1:imperf:aff
pact:sg:dat:m1:imperf:neg
pact:sg:dat:m1:perf:aff
pact:sg:dat:m1:perf:neg
pact:sg:dat:m2:imperf:aff
pact:sg:dat:m2:imperf:neg
pact:sg:dat:m2:perf:aff
pact:sg:dat:m2:perf:neg
pact:sg:dat:m3:imperf:aff
pact:sg:dat:m3:imperf:neg
pact:sg:dat:m3:perf:aff
pact:sg:dat:m3:perf:neg
pact:sg:dat:n:imperf:aff
pact:sg:dat:n:imperf:neg
pact:sg:dat:n:perf:aff
pact:sg:dat:n:perf:neg
pact:sg:gen:f:imperf:aff
pact:sg:gen:f:imperf:neg
pact:sg:gen:f:perf:aff
pact:sg:gen:f:perf:neg
pact:sg:gen:m1:imperf:aff
pact:sg:gen:m1:imperf:neg
pact:sg:gen:m1:perf:aff
pact:sg:gen:m1:perf:neg
pact:sg:gen:m2:imperf:aff
pact:sg:gen:m2:imperf:neg
pact:sg:gen:m2:perf:aff
pact:sg:gen:m2:perf:neg
pact:sg:gen:m3:imperf:aff
pact:sg:gen:m3:imperf:neg
pact:sg:gen:m3:perf:aff
pact:sg:gen:m3:perf:neg
pact:sg:gen:n:imperf:aff
pact:sg:gen:n:imperf:neg
pact:sg:gen:n:perf:aff
pact:sg:gen:n:perf:neg
pact:sg:inst:f:imperf:aff
pact:sg:inst:f:imperf:neg
pact:sg:inst:f:perf:aff
pact:sg:inst:f:perf:neg
pact:sg:inst:m1:imperf:aff
pact:sg:inst:m1:imperf:neg
pact:sg:inst:m1:perf:aff
pact:sg:inst:m1:perf:neg
pact:sg:inst:m2:imperf:aff
pact:sg:inst:m2:imperf:neg
pact:sg:inst:m2:perf:aff
pact:sg:inst:m2:perf:neg
pact:sg:inst:m3:imperf:aff
pact:sg:inst:m3:imperf:neg
pact:sg:inst:m3:perf:aff
pact:sg:inst:m3:perf:neg
pact:sg:inst:n:imperf:aff
pact:sg:inst:n:imperf:neg
pact:sg:inst:n:perf:aff
pact:sg:inst:n:perf:neg
pact:sg:loc:f:imperf:aff
pact:sg:loc:f:imperf:neg
pact:sg:loc:f:perf:aff
pact:sg:loc:f:perf:neg
pact:sg:loc:m1:imperf:aff
pact:sg:loc:m1:imperf:neg
pact:sg:loc:m1:perf:aff
pact:sg:loc:m1:perf:neg
pact:sg:loc:m2:imperf:aff
pact:sg:loc:m2:imperf:neg
pact:sg:loc:m2:perf:aff
pact:sg:loc:m2:perf:neg
pact:sg:loc:m3:imperf:aff
pact:sg:loc:m3:imperf:neg
pact:sg:loc:m3:perf:aff
pact:sg:loc:m3:perf:neg
pact:sg:loc:n:imperf:aff
pact:sg:loc:n:imperf:neg
pact:sg:loc:n:perf:aff
pact:sg:loc:n:perf:neg
pact:sg:nom:f:imperf:aff
pact:sg:nom:f:imperf:neg
pact:sg:nom:f:perf:aff
pact:sg:nom:f:perf:neg
pact:sg:nom:m1:imperf:aff
pact:sg:nom:m1:imperf:neg
pact:sg:nom:m1:perf:aff
pact:sg:nom:m1:perf:neg
pact:sg:nom:m2:imperf:aff
pact:sg:nom:m2:imperf:neg
pact:sg:nom:m2:perf:aff
pact:sg:nom:m2:perf:neg
pact:sg:nom:m3:imperf:aff
pact:sg:nom:m3:imperf:neg
pact:sg:nom:m3:perf:aff
pact:sg:nom:m3:perf:neg
pact:sg:nom:n:imperf:aff
pact:sg:nom:n:imperf:neg
pact:sg:nom:n:perf:aff
pact:sg:nom:n:perf:neg
pant:imperf
pant:perf
pcon:imperf
pcon:perf
ppas:pl:acc:f:imperf:aff
ppas:pl:acc:f:imperf:neg
ppas:pl:acc:f:perf:aff
ppas:pl:acc:f:perf:neg
ppas:pl:acc:m1:imperf:aff
ppas:pl:acc:m1:imperf:neg
ppas:pl:acc:m1:perf:aff
ppas:pl:acc:m1:perf:neg
ppas:pl:acc:m2:imperf:aff
ppas:pl:acc:m2:imperf:neg
ppas:pl:acc:m2:perf:aff
ppas:pl:acc:m2:perf:neg
ppas:pl:acc:m3:imperf:aff
ppas:pl:acc:m3:imperf:neg
ppas:pl:acc:m3:perf:aff
ppas:pl:acc:m3:perf:neg
ppas:pl:acc:n:imperf:aff
ppas:pl:acc:n:imperf:neg
ppas:pl:acc:n:perf:aff
ppas:pl:acc:n:perf:neg
ppas:pl:dat:f:imperf:aff
ppas:pl:dat:f:imperf:neg
ppas:pl:dat:f:perf:aff
ppas:pl:dat:f:perf:neg
ppas:pl:dat:m1:imperf:aff
ppas:pl:dat:m1:imperf:neg
ppas:pl:dat:m1:perf:aff
ppas:pl:dat:m1:perf:neg
ppas:pl:dat:m2:imperf:aff
ppas:pl:dat:m2:imperf:neg
ppas:pl:dat:m2:perf:aff
ppas:pl:dat:m2:perf:neg
ppas:pl:dat:m3:imperf:aff
ppas:pl:dat:m3:imperf:neg
ppas:pl:dat:m3:perf:aff
ppas:pl:dat:m3:perf:neg
ppas:pl:dat:n:imperf:aff
ppas:pl:dat:n:imperf:neg
ppas:pl:dat:n:perf:aff
ppas:pl:dat:n:perf:neg
ppas:pl:gen:f:imperf:aff
ppas:pl:gen:f:imperf:neg
ppas:pl:gen:f:perf:aff
ppas:pl:gen:f:perf:neg
ppas:pl:gen:m1:imperf:aff
ppas:pl:gen:m1:imperf:neg
ppas:pl:gen:m1:perf:aff
ppas:pl:gen:m1:perf:neg
ppas:pl:gen:m2:imperf:aff
ppas:pl:gen:m2:imperf:neg
ppas:pl:gen:m2:perf:aff
ppas:pl:gen:m2:perf:neg
ppas:pl:gen:m3:imperf:aff
ppas:pl:gen:m3:imperf:neg
ppas:pl:gen:m3:perf:aff
ppas:pl:gen:m3:perf:neg
ppas:pl:gen:n:imperf:aff
ppas:pl:gen:n:imperf:neg
ppas:pl:gen:n:perf:aff
ppas:pl:gen:n:perf:neg
ppas:pl:inst:f:imperf:aff
ppas:pl:inst:f:imperf:neg
ppas:pl:inst:f:perf:aff
ppas:pl:inst:f:perf:neg
ppas:pl:inst:m1:imperf:aff
ppas:pl:inst:m1:imperf:neg
ppas:pl:inst:m1:perf:aff
ppas:pl:inst:m1:perf:neg
ppas:pl:inst:m2:imperf:aff
ppas:pl:inst:m2:imperf:neg
ppas:pl:inst:m2:perf:aff
ppas:pl:inst:m2:perf:neg
ppas:pl:inst:m3:imperf:aff
ppas:pl:inst:m3:imperf:neg
ppas:pl:inst:m3:perf:aff
ppas:pl:inst:m3:perf:neg
ppas:pl:inst:n:imperf:aff
ppas:pl:inst:n:imperf:neg
ppas:pl:inst:n:perf:aff
ppas:pl:inst:n:perf:neg
ppas:pl:loc:f:imperf:aff
ppas:pl:loc:f:imperf:neg
ppas:pl:loc:f:perf:aff
ppas:pl:loc:f:perf:neg
ppas:pl:loc:m1:imperf:aff
ppas:pl:loc:m1:imperf:neg
ppas:pl:loc:m1:perf:aff
ppas:pl:loc:m1:perf:neg
ppas:pl:loc:m2:imperf:aff
ppas:pl:loc:m2:imperf:neg
ppas:pl:loc:m2:perf:aff
ppas:pl:loc:m2:perf:neg
ppas:pl:loc:m3:imperf:aff
ppas:pl:loc:m3:imperf:neg
ppas:pl:loc:m3:perf:aff
ppas:pl:loc:m3:perf:neg
ppas:pl:loc:n:imperf:aff
ppas:pl:loc:n:imperf:neg
ppas:pl:loc:n:perf:aff
ppas:pl:loc:n:perf:neg
ppas:pl:nom:f:imperf:aff
ppas:pl:nom:f:imperf:neg
ppas:pl:nom:f:perf:aff
ppas:pl:nom:f:perf:neg
ppas:pl:nom:m1:imperf:aff
ppas:pl:nom:m1:imperf:neg
ppas:pl:nom:m1:perf:aff
ppas:pl:nom:m1:perf:neg
ppas:pl:nom:m2:imperf:aff
ppas:pl:nom:m2:imperf:neg
ppas:pl:nom:m2:perf:aff
ppas:pl:nom:m2:perf:neg
ppas:pl:nom:m3:imperf:aff
ppas:pl:nom:m3:imperf:neg
ppas:pl:nom:m3:perf:aff
ppas:pl:nom:m3:perf:neg
ppas:pl:nom:n:imperf:aff
ppas:pl:nom:n:imperf:neg
ppas:pl:nom:n:perf:aff
ppas:pl:nom:n:perf:neg
ppas:sg:acc:f:imperf:aff
ppas:sg:acc:f:imperf:neg
ppas:sg:acc:f:perf:aff
ppas:sg:acc:f:perf:neg
ppas:sg:acc:m1:imperf:aff
ppas:sg:acc:m1:imperf:neg
ppas:sg:acc:m1:perf:aff
ppas:sg:acc:m1:perf:neg
ppas:sg:acc:m2:imperf:aff
ppas:sg:acc:m2:imperf:neg
ppas:sg:acc:m2:perf:aff
ppas:sg:acc:m2:perf:neg
ppas:sg:acc:m3:imperf:aff
ppas:sg:acc:m3:imperf:neg
ppas:sg:acc:m3:perf:aff
ppas:sg:acc:m3:perf:neg
ppas:sg:acc:n:imperf:aff
ppas:sg:acc:n:imperf:neg
ppas:sg:acc:n:perf:aff
ppas:sg:acc:n:perf:neg
ppas:sg:dat:f:imperf:aff
ppas:sg:dat:f:imperf:neg
ppas:sg:dat:f:perf:aff
ppas:sg:dat:f:perf:neg
ppas:sg:dat:m1:imperf:aff
ppas:sg:dat:m1:imperf:neg
ppas:sg:dat:m1:perf:aff
ppas:sg:dat:m1:perf:neg
ppas:sg:dat:m2:imperf:aff
ppas:sg:dat:m2:imperf:neg
ppas:sg:dat:m2:perf:aff
ppas:sg:dat:m2:perf:neg
ppas:sg:dat:m3:imperf:aff
ppas:sg:dat:m3:imperf:neg
ppas:sg:dat:m3:perf:aff
ppas:sg:dat:m3:perf:neg
ppas:sg:dat:n:imperf:aff
ppas:sg:dat:n:imperf:neg
ppas:sg:dat:n:perf:aff
ppas:sg:dat:n:perf:neg
ppas:sg:gen:f:imperf:aff
ppas:sg:gen:f:imperf:neg
ppas:sg:gen:f:perf:aff
ppas:sg:gen:f:perf:neg
ppas:sg:gen:m1:imperf:aff
ppas:sg:gen:m1:imperf:neg
ppas:sg:gen:m1:perf:aff
ppas:sg:gen:m1:perf:neg
ppas:sg:gen:m2:imperf:aff
ppas:sg:gen:m2:imperf:neg
ppas:sg:gen:m2:perf:aff
ppas:sg:gen:m2:perf:neg
ppas:sg:gen:m3:imperf:aff
ppas:sg:gen:m3:imperf:neg
ppas:sg:gen:m3:perf:aff
ppas:sg:gen:m3:perf:neg
ppas:sg:gen:n:imperf:aff
ppas:sg:gen:n:imperf:neg
ppas:sg:gen:n:perf:aff
ppas:sg:gen:n:perf:neg
ppas:sg:inst:f:imperf:aff
ppas:sg:inst:f:imperf:neg
ppas:sg:inst:f:perf:aff
ppas:sg:inst:f:perf:neg
ppas:sg:inst:m1:imperf:aff
ppas:sg:inst:m1:imperf:neg
ppas:sg:inst:m1:perf:aff
ppas:sg:inst:m1:perf:neg
ppas:sg:inst:m2:imperf:aff
ppas:sg:inst:m2:imperf:neg
ppas:sg:inst:m2:perf:aff
ppas:sg:inst:m2:perf:neg
ppas:sg:inst:m3:imperf:aff
ppas:sg:inst:m3:imperf:neg
ppas:sg:inst:m3:perf:aff
ppas:sg:inst:m3:perf:neg
ppas:sg:inst:n:imperf:aff
ppas:sg:inst:n:imperf:neg
ppas:sg:inst:n:perf:aff
ppas:sg:inst:n:perf:neg
ppas:sg:loc:f:imperf:aff
ppas:sg:loc:f:imperf:neg
ppas:sg:loc:f:perf:aff
ppas:sg:loc:f:perf:neg
ppas:sg:loc:m1:imperf:aff
ppas:sg:loc:m1:imperf:neg
ppas:sg:loc:m1:perf:aff
ppas:sg:loc:m1:perf:neg
ppas:sg:loc:m2:imperf:aff
ppas:sg:loc:m2:imperf:neg
ppas:sg:loc:m2:perf:aff
ppas:sg:loc:m2:perf:neg
ppas:sg:loc:m3:imperf:aff
ppas:sg:loc:m3:imperf:neg
ppas:sg:loc:m3:perf:aff
ppas:sg:loc:m3:perf:neg
ppas:sg:loc:n:imperf:aff
ppas:sg:loc:n:imperf:neg
ppas:sg:loc:n:perf:aff
ppas:sg:loc:n:perf:neg
ppas:sg:nom:f:imperf:aff
ppas:sg:nom:f:imperf:neg
ppas:sg:nom:f:perf:aff
ppas:sg:nom:f:perf:neg
ppas:sg:nom:m1:imperf:aff
ppas:sg:nom:m1:imperf:neg
ppas:sg:nom:m1:perf:aff
ppas:sg:nom:m1:perf:neg
ppas:sg:nom:m2:imperf:aff
ppas:sg:nom:m2:imperf:neg
ppas:sg:nom:m2:perf:aff
ppas:sg:nom:m2:perf:neg
ppas:sg:nom:m3:imperf:aff
ppas:sg:nom:m3:imperf:neg
ppas:sg:nom:m3:perf:aff
ppas:sg:nom:m3:perf:neg
ppas:sg:nom:n:imperf:aff
ppas:sg:nom:n:imperf:neg
ppas:sg:nom:n:perf:aff
ppas:sg:nom:n:perf:neg
ppron12:pl:acc:f:pri
ppron12:pl:acc:f:sec
ppron12:pl:acc:m1:pri
ppron12:pl:acc:m1:sec
ppron12:pl:acc:m2:pri
ppron12:pl:acc:m2:sec
ppron12:pl:acc:m3:pri
ppron12:pl:acc:m3:sec
ppron12:pl:acc:n:pri
ppron12:pl:acc:n:sec
ppron12:pl:dat:f:pri
ppron12:pl:dat:f:sec
ppron12:pl:dat:m1:pri
ppron12:pl:dat:m1:sec
ppron12:pl:dat:m2:pri
ppron12:pl:dat:m2:sec
ppron12:pl:dat:m3:pri
ppron12:pl:dat:m3:sec
ppron12:pl:dat:n:pri
ppron12:pl:dat:n:sec
ppron12:pl:gen:f:pri
ppron12:pl:gen:f:sec
ppron12:pl:gen:m1:pri
ppron12:pl:gen:m1:sec
ppron12:pl:gen:m2:pri
ppron12:pl:gen:m2:sec
ppron12:pl:gen:m3:pri
ppron12:pl:gen:m3:sec
ppron12:pl:gen:n:pri
ppron12:pl:gen:n:sec
ppron12:pl:inst:f:pri
ppron12:pl:inst:f:sec
ppron12:pl:inst:m1:pri
ppron12:pl:inst:m1:sec
ppron12:pl:inst:m2:pri
ppron12:pl:inst:m2:sec
ppron12:pl:inst:m3:pri
ppron12:pl:inst:m3:sec
ppron12:pl:inst:n:pri
ppron12:pl:inst:n:sec
ppron12:pl:loc:f:pri
ppron12:pl:loc:f:sec
ppron12:pl:loc:m1:pri
ppron12:pl:loc:m1:sec
ppron12:pl:loc:m2:pri
ppron12:pl:loc:m2:sec
ppron12:pl:loc:m3:pri
ppron12:pl:loc:m3:sec
ppron12:pl:loc:n:pri
ppron12:pl:loc:n:sec
ppron12:pl:nom:f:pri
ppron12:pl:nom:f:sec
ppron12:pl:nom:m1:pri
ppron12:pl:nom:m1:sec
ppron12:pl:nom:m2:pri
ppron12:pl:nom:m2:sec
ppron12:pl:nom:m3:pri
ppron12:pl:nom:m3:sec
ppron12:pl:nom:n:pri
ppron12:pl:nom:n:sec
ppron12:sg:acc:f:pri:akc
ppron12:sg:acc:f:pri:nakc
ppron12:sg:acc:f:sec:akc
ppron12:sg:acc:f:sec:nakc
ppron12:sg:acc:m1:pri:akc
ppron12:sg:acc:m1:pri:nakc
ppron12:sg:acc:m1:sec:akc
ppron12:sg:acc:m1:sec:nakc
ppron12:sg:acc:m2:pri:akc
ppron12:sg:acc:m2:pri:nakc
ppron12:sg:acc:m2:sec:akc
ppron12:sg:acc:m2:sec:nakc
ppron12:sg:acc:m3:pri:akc
ppron12:sg:acc:m3:pri:nakc
ppron12:sg:acc:m3:sec:akc
ppron12:sg:acc:m3:sec:nakc
ppron12:sg:acc:n:pri:akc
ppron12:sg:acc:n:pri:nakc
ppron12:sg:acc:n:sec:akc
ppron12:sg:acc:n:sec:nakc
ppron12:sg:dat:f:pri:akc
ppron12:sg:dat:f:pri:nakc
ppron12:sg:dat:f:sec:akc
ppron12:sg:dat:f:sec:nakc
ppron12:sg:dat:m1:pri:akc
ppron12:sg:dat:m1:pri:nakc
ppron12:sg:dat:m1:sec:akc
ppron12:sg:dat:m1:sec:nakc
ppron12:sg:dat:m2:pri:akc
ppron12:sg:dat:m2:pri:nakc
ppron12:sg:dat:m2:sec:akc
ppron12:sg:dat:m2:sec:nakc
ppron12:sg:dat:m3:pri:akc
ppron12:sg:dat:m3:pri:nakc
ppron12:sg:dat:m3:sec:akc
ppron12:sg:dat:m3:sec:nakc
ppron12:sg:dat:n:pri:akc
ppron12:sg:dat:n:pri:nakc
ppron12:sg:dat:n:sec:akc
ppron12:sg:dat:n:sec:nakc
ppron12:sg:gen:f:pri:akc
ppron12:sg:gen:f:pri:nakc
ppron12:sg:gen:f:sec:akc
ppron12:sg:gen:f:sec:nakc
ppron12:sg:gen:m1:pri:akc
ppron12:sg:gen:m1:pri:nakc
ppron12:sg:gen:m1:sec:akc
ppron12:sg:gen:m1:sec:nakc
ppron12:sg:gen:m2:pri:akc
ppron12:sg:gen:m2:pri:nakc
ppron12:sg:gen:m2:sec:akc
ppron12:sg:gen:m2:sec:nakc
ppron12:sg:gen:m3:pri:akc
ppron12:sg:gen:m3:pri:nakc
ppron12:sg:gen:m3:sec:akc
ppron12:sg:gen:m3:sec:nakc
ppron12:sg:gen:n:pri:akc
ppron12:sg:gen:n:pri:nakc
ppron12:sg:gen:n:sec:akc
ppron12:sg:gen:n:sec:nakc
ppron12:sg:inst:f:pri
ppron12:sg:inst:f:sec
ppron12:sg:inst:m1:pri
ppron12:sg:inst:m1:sec
ppron12:sg:inst:m2:pri
ppron12:sg:inst:m2:sec
ppron12:sg:inst:m3:pri
ppron12:sg:inst:m3:sec
ppron12:sg:inst:n:pri
ppron12:sg:inst:n:sec
ppron12:sg:loc:f:pri
ppron12:sg:loc:f:sec
ppron12:sg:loc:m1:pri
ppron12:sg:loc:m1:sec
ppron12:sg:loc:m2:pri
ppron12:sg:loc:m2:sec
ppron12:sg:loc:m3:pri
ppron12:sg:loc:m3:sec
ppron12:sg:loc:n:pri
ppron12:sg:loc:n:sec
ppron12:sg:nom:f:pri
ppron12:sg:nom:f:sec
ppron12:sg:nom:m1:pri
ppron12:sg:nom:m1:sec
ppron12:sg:nom:m2:pri
ppron12:sg:nom:m2:sec
ppron12:sg:nom:m3:pri
ppron12:sg:nom:m3:sec
ppron12:sg:nom:n:pri
ppron12:sg:nom:n:sec
ppron3:pl:acc:f:ter:akc:npraep
ppron3:pl:acc:f:ter:akc:praep
ppron3:pl:acc:f:ter:nakc:npraep
ppron3:pl:acc:f:ter:nakc:praep
ppron3:pl:acc:m1:ter:akc:npraep
ppron3:pl:acc:m1:ter:akc:praep
ppron3:pl:acc:m1:ter:nakc:npraep
ppron3:pl:acc:m1:ter:nakc:praep
ppron3:pl:acc:m2:ter:akc:npraep
ppron3:pl:acc:m2:ter:akc:praep
ppron3:pl:acc:m2:ter:nakc:npraep
ppron3:pl:acc:m2:ter:nakc:praep
ppron3:pl:acc:m3:ter:akc:npraep
ppron3:pl:acc:m3:ter:akc:praep
ppron3:pl:acc:m3:ter:nakc:npraep
ppron3:pl:acc:m3:ter:nakc:praep
ppron3:pl:acc:n:ter:akc:npraep
ppron3:pl:acc:n:ter:akc:praep
ppron3:pl:acc:n:ter:nakc:npraep
ppron3:pl:acc:n:ter:nakc:praep
ppron3:pl:dat:f:ter:akc:npraep
ppron3:pl:dat:f:ter:akc:praep
ppron3:pl:dat:f:ter:nakc:npraep
ppron3:pl:dat:f:ter:nakc:praep
ppron3:pl:dat:m1:ter:akc:npraep
ppron3:pl:dat:m1:ter:akc:praep
ppron3:pl:dat:m1:ter:nakc:npraep
ppron3:pl:dat:m1:ter:nakc:praep
ppron3:pl:dat:m2:ter:akc:npraep
ppron3:pl:dat:m2:ter:akc:praep
ppron3:pl:dat:m2:ter:nakc:npraep
ppron3:pl:dat:m2:ter:nakc:praep
ppron3:pl:dat:m3:ter:akc:npraep
ppron3:pl:dat:m3:ter:akc:praep
ppron3:pl:dat:m3:ter:nakc:npraep
ppron3:pl:dat:m3:ter:nakc:praep
ppron3:pl:dat:n:ter:akc:npraep
ppron3:pl:dat:n:ter:akc:praep
ppron3:pl:dat:n:ter:nakc:npraep
ppron3:pl:dat:n:ter:nakc:praep
ppron3:pl:gen:f:ter:akc:npraep
ppron3:pl:gen:f:ter:akc:praep
ppron3:pl:gen:f:ter:nakc:npraep
ppron3:pl:gen:f:ter:nakc:praep
ppron3:pl:gen:m1:ter:akc:npraep
ppron3:pl:gen:m1:ter:akc:praep
ppron3:pl:gen:m1:ter:nakc:npraep
ppron3:pl:gen:m1:ter:nakc:praep
ppron3:pl:gen:m2:ter:akc:npraep
ppron3:pl:gen:m2:ter:akc:praep
ppron3:pl:gen:m2:ter:nakc:npraep
ppron3:pl:gen:m2:ter:nakc:praep
ppron3:pl:gen:m3:ter:akc:npraep
ppron3:pl:gen:m3:ter:akc:praep
ppron3:pl:gen:m3:ter:nakc:npraep
ppron3:pl:gen:m3:ter:nakc:praep
ppron3:pl:gen:n:ter:akc:npraep
ppron3:pl:gen:n:ter:akc:praep
ppron3:pl:gen:n:ter:nakc:npraep
ppron3:pl:gen:n:ter:nakc:praep
ppron3:pl:inst:f:ter:akc:npraep
ppron3:pl:inst:f:ter:akc:praep
ppron3:pl:inst:f:ter:nakc:npraep
ppron3:pl:inst:f:ter:nakc:praep
ppron3:pl:inst:m1:ter:akc:npraep
ppron3:pl:inst:m1:ter:akc:praep
ppron3:pl:inst:m1:ter:nakc:npraep
ppron3:pl:inst:m1:ter:nakc:praep
ppron3:pl:inst:m2:ter:akc:npraep
ppron3:pl:inst:m2:ter:akc:praep
ppron3:pl:inst:m2:ter:nakc:npraep
ppron3:pl:inst:m2:ter:nakc:praep
ppron3:pl:inst:m3:ter:akc:npraep
ppron3:pl:inst:m3:ter:akc:praep
ppron3:pl:inst:m3:ter:nakc:npraep
ppron3:pl:inst:m3:ter:nakc:praep
ppron3:pl:inst:n:ter:akc:npraep
ppron3:pl:inst:n:ter:akc:praep
ppron3:pl:inst:n:ter:nakc:npraep
ppron3:pl:inst:n:ter:nakc:praep
ppron3:pl:loc:f:ter:akc:praep
ppron3:pl:loc:f:ter:nakc:praep
ppron3:pl:loc:m1:ter:akc:praep
ppron3:pl:loc:m1:ter:nakc:praep
ppron3:pl:loc:m2:ter:akc:praep
ppron3:pl:loc:m2:ter:nakc:praep
ppron3:pl:loc:m3:ter:akc:praep
ppron3:pl:loc:m3:ter:nakc:praep
ppron3:pl:loc:n:ter:akc:praep
ppron3:pl:loc:n:ter:nakc:praep
ppron3:pl:nom:f:ter:akc:npraep
ppron3:pl:nom:f:ter:akc:praep
ppron3:pl:nom:f:ter:nakc:npraep
ppron3:pl:nom:f:ter:nakc:praep
ppron3:pl:nom:m1:ter:akc:npraep
ppron3:pl:nom:m1:ter:akc:praep
ppron3:pl:nom:m1:ter:nakc:npraep
ppron3:pl:nom:m1:ter:nakc:praep
ppron3:pl:nom:m2:ter:akc:npraep
ppron3:pl:nom:m2:ter:akc:praep
ppron3:pl:nom:m2:ter:nakc:npraep
ppron3:pl:nom:m2:ter:nakc:praep
ppron3:pl:nom:m3:ter:akc:npraep
ppron3:pl:nom:m3:ter:akc:praep
ppron3:pl:nom:m3:ter:nakc:npraep
ppron3:pl:nom:m3:ter:nakc:praep
ppron3:pl:nom:n:ter:akc:npraep
ppron3:pl:nom:n:ter:akc:praep
ppron3:pl:nom:n:ter:nakc:npraep
ppron3:pl:nom:n:ter:nakc:praep
ppron3:sg:acc:f:ter:akc:npraep
ppron3:sg:acc:f:ter:akc:praep
ppron3:sg:acc:f:ter:nakc:npraep
ppron3:sg:acc:f:ter:nakc:praep
ppron3:sg:acc:m1:ter:akc:npraep
ppron3:sg:acc:m1:ter:akc:praep
ppron3:sg:acc:m1:ter:nakc:npraep
ppron3:sg:acc:m1:ter:nakc:praep
ppron3:sg:acc:m2:ter:akc:npraep
ppron3:sg:acc:m2:ter:akc:praep
ppron3:sg:acc:m2:ter:nakc:npraep
ppron3:sg:acc:m2:ter:nakc:praep
ppron3:sg:acc:m3:ter:akc:npraep
ppron3:sg:acc:m3:ter:akc:praep
ppron3:sg:acc:m3:ter:nakc:npraep
ppron3:sg:acc:m3:ter:nakc:praep
ppron3:sg:acc:n:ter:akc:npraep
ppron3:sg:acc:n:ter:akc:praep
ppron3:sg:acc:n:ter:nakc:npraep
ppron3:sg:acc:n:ter:nakc:praep
ppron3:sg:dat:f:ter:akc:npraep
ppron3:sg:dat:f:ter:akc:praep
ppron3:sg:dat:f:ter:nakc:npraep
ppron3:sg:dat:f:ter:nakc:praep
ppron3:sg:dat:m1:ter:akc:npraep
ppron3:sg:dat:m1:ter:akc:praep
ppron3:sg:dat:m1:ter:nakc:npraep
ppron3:sg:dat:m1:ter:nakc:praep
ppron3:sg:dat:m2:ter:akc:npraep
ppron3:sg:dat:m2:ter:akc:praep
ppron3:sg:dat:m2:ter:nakc:npraep
ppron3:sg:dat:m2:ter:nakc:praep
ppron3:sg:dat:m3:ter:akc:npraep
ppron3:sg:dat:m3:ter:akc:praep
ppron3:sg:dat:m3:ter:nakc:npraep
ppron3:sg:dat:m3:ter:nakc:praep
ppron3:sg:dat:n:ter:akc:npraep
ppron3:sg:dat:n:ter:akc:praep
ppron3:sg:dat:n:ter:nakc:npraep
ppron3:sg:dat:n:ter:nakc:praep
ppron3:sg:gen:f:ter:akc:npraep
ppron3:sg:gen:f:ter:akc:praep
ppron3:sg:gen:f:ter:nakc:npraep
ppron3:sg:gen:f:ter:nakc:praep
ppron3:sg:gen:m1:ter:akc:npraep
ppron3:sg:gen:m1:ter:akc:praep
ppron3:sg:gen:m1:ter:nakc:npraep
ppron3:sg:gen:m1:ter:nakc:praep
ppron3:sg:gen:m2:ter:akc:npraep
ppron3:sg:gen:m2:ter:akc:praep
ppron3:sg:gen:m2:ter:nakc:npraep
ppron3:sg:gen:m2:ter:nakc:praep
ppron3:sg:gen:m3:ter:akc:npraep
ppron3:sg:gen:m3:ter:akc:praep
ppron3:sg:gen:m3:ter:nakc:npraep
ppron3:sg:gen:m3:ter:nakc:praep
ppron3:sg:gen:n:ter:akc:npraep
ppron3:sg:gen:n:ter:akc:praep
ppron3:sg:gen:n:ter:nakc:npraep
ppron3:sg:inst:f:ter:akc:praep
ppron3:sg:inst:f:ter:nakc:praep
ppron3:sg:inst:m1:ter:akc:npraep
ppron3:sg:inst:m1:ter:akc:praep
ppron3:sg:inst:m1:ter:nakc:npraep
ppron3:sg:inst:m1:ter:nakc:praep
ppron3:sg:inst:m2:ter:akc:npraep
ppron3:sg:inst:m2:ter:akc:praep
ppron3:sg:inst:m2:ter:nakc:npraep
ppron3:sg:inst:m2:ter:nakc:praep
ppron3:sg:inst:m3:ter:akc:npraep
ppron3:sg:inst:m3:ter:akc:praep
ppron3:sg:inst:m3:ter:nakc:npraep
ppron3:sg:inst:m3:ter:nakc:praep
ppron3:sg:inst:n:ter:akc:npraep
ppron3:sg:inst:n:ter:akc:praep
ppron3:sg:inst:n:ter:nakc:npraep
ppron3:sg:inst:n:ter:nakc:praep
ppron3:sg:loc:f:ter:akc:npraep
ppron3:sg:loc:f:ter:akc:praep
ppron3:sg:loc:f:ter:nakc:npraep
ppron3:sg:loc:f:ter:nakc:praep
ppron3:sg:loc:m1:ter:akc:npraep
ppron3:sg:loc:m1:ter:akc:praep
ppron3:sg:loc:m1:ter:nakc:npraep
ppron3:sg:loc:m1:ter:nakc:praep
ppron3:sg:loc:m2:ter:akc:npraep
ppron3:sg:loc:m2:ter:akc:praep
ppron3:sg:loc:m2:ter:nakc:npraep
ppron3:sg:loc:m2:ter:nakc:praep
ppron3:sg:loc:m3:ter:akc:npraep
ppron3:sg:loc:m3:ter:akc:praep
ppron3:sg:loc:m3:ter:nakc:npraep
ppron3:sg:loc:m3:ter:nakc:praep
ppron3:sg:loc:n:ter:akc:npraep
ppron3:sg:loc:n:ter:akc:praep
ppron3:sg:loc:n:ter:nakc:npraep
ppron3:sg:loc:n:ter:nakc:praep
ppron3:sg:nom:f:ter:akc:npraep
ppron3:sg:nom:f:ter:akc:praep
ppron3:sg:nom:f:ter:nakc:npraep
ppron3:sg:nom:f:ter:nakc:praep
ppron3:sg:nom:m1:ter:akc:npraep
ppron3:sg:nom:m1:ter:akc:praep
ppron3:sg:nom:m1:ter:nakc:npraep
ppron3:sg:nom:m1:ter:nakc:praep
ppron3:sg:nom:m2:ter:akc:npraep
ppron3:sg:nom:m2:ter:akc:praep
ppron3:sg:nom:m2:ter:nakc:npraep
ppron3:sg:nom:m2:ter:nakc:praep
ppron3:sg:nom:m3:ter:akc:npraep
ppron3:sg:nom:m3:ter:akc:praep
ppron3:sg:nom:m3:ter:nakc:npraep
ppron3:sg:nom:m3:ter:nakc:praep
ppron3:sg:nom:n:ter:akc:npraep
ppron3:sg:nom:n:ter:akc:praep
ppron3:sg:nom:n:ter:nakc:npraep
ppron3:sg:nom:n:ter:nakc:praep
praet:pl:f:imperf
praet:pl:f:perf
praet:pl:m1:imperf
praet:pl:m1:perf
praet:pl:m2:imperf
praet:pl:m2:perf
praet:pl:m3:imperf
praet:pl:m3:perf
praet:pl:n:imperf
praet:pl:n:perf
praet:sg:f:imperf
praet:sg:f:perf
praet:sg:m1:imperf
praet:sg:m1:imperf:agl
praet:sg:m1:imperf:nagl
praet:sg:m1:perf
praet:sg:m1:perf:agl
praet:sg:m1:perf:nagl
praet:sg:m2:imperf
praet:sg:m2:imperf:agl
praet:sg:m2:imperf:nagl
praet:sg:m2:perf
praet:sg:m2:perf:agl
praet:sg:m2:perf:nagl
praet:sg:m3:imperf
praet:sg:m3:imperf:agl
praet:sg:m3:imperf:nagl
praet:sg:m3:perf
praet:sg:m3:perf:agl
praet:sg:m3:perf:nagl
praet:sg:n:imperf
praet:sg:n:perf
pred
prep:acc
prep:acc:nwok
prep:acc:wok
prep:dat
prep:dat:nwok
prep:gen
prep:gen:nwok
prep:gen:wok
prep:inst
prep:inst:nwok
prep:inst:wok
prep:loc
prep:loc:nwok
prep:loc:wok
prep:nom
prep:nom:nwok
prep:voc:nwok
qub
siebie:acc
siebie:dat
siebie:gen
siebie:inst
siebie:loc
subst:pl:acc:f
subst:pl:acc:m1
subst:pl:acc:m2
subst:pl:acc:m3
subst:pl:acc:n
subst:pl:dat:f
subst:pl:dat:m1
subst:pl:dat:m2
subst:pl:dat:m3
subst:pl:dat:n
subst:pl:gen:f
subst:pl:gen:m1
subst:pl:gen:m2
subst:pl:gen:m3
subst:pl:gen:n
subst:pl:inst:f
subst:pl:inst:m1
subst:pl:inst:m2
subst:pl:inst:m3
subst:pl:inst:n
subst:pl:loc:f
subst:pl:loc:m1
subst:pl:loc:m2
subst:pl:loc:m3
subst:pl:loc:n
subst:pl:nom:f
subst:pl:nom:m1
subst:pl:nom:m2
subst:pl:nom:m3
subst:pl:nom:n
subst:pl:voc:f
subst:pl:voc:m1
subst:pl:voc:m2
subst:pl:voc:m3
subst:pl:voc:n
subst:sg:acc:f
subst:sg:acc:m1
subst:sg:acc:m2
subst:sg:acc:m3
subst:sg:acc:n
subst:sg:dat:f
subst:sg:dat:m1
subst:sg:dat:m2
subst:sg:dat:m3
subst:sg:dat:n
subst:sg:gen:f
subst:sg:gen:m1
subst:sg:gen:m2
subst:sg:gen:m3
subst:sg:gen:n
subst:sg:inst:f
subst:sg:inst:m1
subst:sg:inst:m2
subst:sg:inst:m3
subst:sg:inst:n
subst:sg:loc:f
subst:sg:loc:m1
subst:sg:loc:m2
subst:sg:loc:m3
subst:sg:loc:n
subst:sg:nom:f
subst:sg:nom:m1
subst:sg:nom:m2
subst:sg:nom:m3
subst:sg:nom:n
subst:sg:voc:f
subst:sg:voc:m1
subst:sg:voc:m2
subst:sg:voc:m3
subst:sg:voc:n
winien:pl:f:imperf
winien:pl:m1:imperf
winien:pl:m2:imperf
winien:pl:m3:imperf
winien:pl:n:imperf
winien:sg:f:imperf
winien:sg:m1:imperf
winien:sg:m2:imperf
winien:sg:m3:imperf
winien:sg:n:imperf
xxx
end_of_list
    ;
    my @list = split(/\r?\n/, $list);
    pop(@list) if($list[$#list] eq '');
    return \@list;
}



#------------------------------------------------------------------------------
# Create trie of permitted feature structures. This will be needed for strict
# encoding. This BEGIN block cannot appear before the definition of the list()
# function.
#------------------------------------------------------------------------------
BEGIN
{
    # When scanning tags for permitted feature structures, do not consider tags
    # that require setting the 'other' feature.
    my $no_other = 1;
    # Store the hash reference in a global variable.
    $permitted = tagset::common::get_permitted_structures_joint(list(), \&decode, $no_other);
}



1;
