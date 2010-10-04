#!/usr/bin/perl
# Common functions for the drivers of the two tagsets of the Pražský mluvený korpus (Prague Spoken Corpus) of Czech.
# Copyright © 2009, 2010 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::cs::pmk;
use utf8;
use tagset::common;



#------------------------------------------------------------------------------
# Decodes gender (rod) and stores it in a feature structure.
# Occurs as the fifth number in noun tags.
# Occurs as the sixth number in adjectival tags.
# Occurs as the fourth number in pronoun tags.
# Occurs as the fourth number in numeral tags.
# Occurs as the ninth number in verbal tags, combined with grammatical number. ###!!! to chce samostatnou funkci
# Occurs as the fourth number in other-proper name tags.
#------------------------------------------------------------------------------
sub decode_gender
{
    my $pos = shift; # digit or letter from the physical tag
    my $gender = shift; # string
    my $f = shift; # reference to hash
    # Map differing number codes to one set first.
    my %map =
    (
        '1' => {'1'=>'M', '2'=>'I', '3'=>'F', '4'=>'N', '9'=>'X'},
        '2' => {'1'=>'M', '2'=>'I', '3'=>'F', '4'=>'N', '9'=>'X'},
        '3' => {'1'=>'M', '2'=>'I', '3'=>'F', '4'=>'N', '5'=>'B', '9'=>'X'},
        '4' => {'1'=>'M', '2'=>'I', '3'=>'F', '4'=>'N', '5'=>'B', '9'=>'X'},
        'P' => {'1'=>'M', '2'=>'I', '3'=>'F', '4'=>'N', '5'=>'X'}
    );
    $gender = $map{$pos}{$gender};
    if($gender eq 'M')
    {
        $f->{gender} = 'masc';
        $f->{animateness} = 'anim';
    }
    elsif($gender eq 'I')
    {
        $f->{gender} = 'masc';
        $f->{animateness} = 'inan';
    }
    elsif($gender eq 'F')
    {
        $f->{gender} = 'fem';
    }
    elsif($gender eq 'N')
    {
        $f->{gender} = 'neut';
    }
    elsif($gender eq 'B')
    {
        # Some pronouns ('já', 'ty') do not distinguish grammatical gender and have this value.
        $f->{other}{gender} = 'bezrodé';
    }
    # 9 => nelze určit / cannot specify => empty value
    return $f->{gender};
}



#------------------------------------------------------------------------------
# Encodes gender (rod) as a string.
#------------------------------------------------------------------------------
sub encode_gender
{
    my $pos = shift; # digit or letter from the physical tag
    my $f = shift; # reference to hash
    my $c;
    if($f->{gender} eq 'masc')
    {
        if($f->{animateness} eq 'inan')
        {
            $c = 'I';
        }
        else
        {
            $c = 'M';
        }
    }
    elsif($f->{gender} eq 'fem')
    {
        $c = 'F';
    }
    elsif($f->{gender} eq 'neut')
    {
        $c = 'N';
    }
    elsif($f->{tagset} eq 'cs::pmk' && $f->{other}{gender} eq 'bezrodé')
    {
        # Some pronouns ('já', 'ty') do not distinguish grammatical gender and have this value.
        $c = 'B';
    }
    else
    {
        $c = 'X';
    }
    # Map result to differing number codes of different parts of speech.
    my %map =
    (
        '1' => {'M'=>'1', 'I'=>'2', 'F'=>'3', 'N'=>'4', 'X'=>'9'},
        '2' => {'M'=>'1', 'I'=>'2', 'F'=>'3', 'N'=>'4', 'X'=>'9'},
        '3' => {'M'=>'1', 'I'=>'2', 'F'=>'3', 'N'=>'4', 'B'=>'5', 'X'=>'9'},
        '4' => {'M'=>'1', 'I'=>'2', 'F'=>'3', 'N'=>'4', 'B'=>'5', 'X'=>'9'},
        'P' => {'M'=>'1', 'I'=>'2', 'F'=>'3', 'N'=>'4', 'X'=>'5'}
    );
    $c = $map{$pos}{$c};
    return $c ? $c : 'X';
}



#------------------------------------------------------------------------------
# Decodes number (číslo) and stores it in a feature structure.
# Occurs as the sixth number in noun tags.
# Occurs as the seventh number in adjectival tags.
# Occurs as the fifth number in pronoun tags.
# Occurs as the fifth number in numeral tags.
# Occurs as the fifth number in other-proper name tags.
#------------------------------------------------------------------------------
sub decode_number
{
    my $pos = shift; # digit or letter from the physical tag
    my $number = shift; # string
    my $f = shift; # reference to hash
    # Map differing number codes to one set first.
    my %map =
    (
        '1' => {'1'=>'S', '2'=>'P', '3'=>'T', '4'=>'D', '5'=>'C', '9'=>'X'},
        '2' => {'1'=>'S', '2'=>'P', '3'=>'D', '4'=>'C', '9'=>'X'},
        '3' => {'1'=>'S', '2'=>'P', '3'=>'D', '4'=>'V', '9'=>'X'},
        '4' => {'1'=>'S', '2'=>'P', '3'=>'D', '4'=>'C', '9'=>'X'},
        'P' => {'1'=>'S', '2'=>'P', '3'=>'T', '4'=>'X'}
    );
    $number = $map{$pos}{$number};
    if($number eq 'S')
    {
        $f->{number} = 'sing';
    }
    elsif($number eq 'P')
    {
        $f->{number} = 'plu';
    }
    elsif($number eq 'T')
    {
        $f->{number} = 'ptan';
    }
    elsif($number eq 'D')
    {
        $f->{number} = 'dual';
    }
    elsif($number eq 'C')
    {
        $f->{number} = 'coll';
    }
    elsif($number eq 'V')
    {
        $f->{number} = 'plu';
        $f->{politeness} = 'pol';
    }
    # X => nelze určit / cannot specify => empty value
    return $f->{number};
}



#------------------------------------------------------------------------------
# Encodes number (číslo) as a string.
#------------------------------------------------------------------------------
sub encode_number
{
    my $pos = shift; # digit or letter from the physical tag
    my $f = shift; # reference to hash
    my $c;
    if($f->{number} eq 'sing')
    {
        $c = 'S';
    }
    elsif($f->{number} eq 'dual')
    {
        $c = 'D';
    }
    elsif($f->{number} eq 'plu')
    {
        if($f->{politeness} eq 'pol')
        {
            $c = 'V';
        }
        else
        {
            $c = 'P';
        }
    }
    elsif($f->{number} eq 'ptan')
    {
        $c = 'T';
    }
    elsif($f->{number} eq 'coll')
    {
        $c = 'C';
    }
    else
    {
        $c = 'X';
    }
    # Map result to differing number codes of different parts of speech.
    my %map =
    (
        '1' => {'S'=>'1', 'P'=>'2', 'T'=>'3', 'D'=>'4', 'C'=>'5', 'X'=>'9'},
        '2' => {'S'=>'1', 'P'=>'2', 'D'=>'3', 'C'=>'4', 'X'=>'9'},
        '3' => {'S'=>'1', 'P'=>'2', 'D'=>'3', 'V'=>'4', 'X'=>'9'},
        '4' => {'S'=>'1', 'P'=>'2', 'D'=>'3', 'C'=>'4', 'X'=>'9'},
        'P' => {'S'=>'1', 'P'=>'2', 'T'=>'3', 'X'=>'4'}
    );
    $c = $map{$pos}{$c};
    return $c ? $c : 'X';
}



#------------------------------------------------------------------------------
# Decodes gender (jmenný rod) and number (číslo) of participles and stores it
# in a feature structure.
# Occurs as the ninth number in verbal tags.
#------------------------------------------------------------------------------
sub decode_participle_gender_number
{
    my $number = shift; # string
    my $f = shift; # reference to hash
    if($number eq '1')
    {
        $f->{gender} = 'masc';
        $f->{animateness} = 'anim';
        $f->{number} = 'sing';
    }
    elsif($number eq '2')
    {
        $f->{gender} = 'masc';
        $f->{animateness} = 'inan';
        $f->{number} = 'sing';
    }
    elsif($number eq '3')
    {
        $f->{gender} = 'fem';
        $f->{number} = 'sing';
    }
    elsif($number eq '4')
    {
        $f->{gender} = 'neut';
        $f->{number} = 'sing';
    }
    elsif($number eq '5')
    {
        $f->{gender} = 'masc';
        $f->{animateness} = 'anim';
        $f->{number} = 'plu';
    }
    elsif($number eq '6')
    {
        $f->{gender} = 'masc';
        $f->{animateness} = 'inan';
        $f->{number} = 'plu';
    }
    elsif($number eq '7')
    {
        $f->{gender} = 'fem';
        $f->{number} = 'plu';
    }
    elsif($number eq '8')
    {
        $f->{gender} = 'neut';
        $f->{number} = 'plu';
    }
    # - -> neurčuje se / not specified => empty value
    # 9 => nelze určit / cannot specify => empty value
    elsif($number eq '-')
    {
        $f->{other}{gender} = '-';
    }
    elsif($number eq '9')
    {
        $f->{other}{gender} = '9';
    }
    return $f->{number};
}



#------------------------------------------------------------------------------
# Encodes gender (jmenný rod) and number (číslo) of participles as a string.
#------------------------------------------------------------------------------
sub encode_participle_gender_number
{
    my $f = shift; # reference to hash
    my $c;
    # If this is not a participle number may still be specified but will be encoded elsewhere; gender will be '-'.
    if($f->{tagset} eq 'cs::pmk' && $f->{other}{gender} eq '-')
    {
        $c = '-';
    }
    # It can also happen that person+number is 3rd+singular (5=3) and gender+number is unknown (9=9). Example: "nařízíno"
    elsif($f->{tagset} eq 'cs::pmk' && $f->{other}{gender} eq '9')
    {
        $c = '9';
    }
    elsif($f->{number} eq 'sing')
    {
        if($f->{gender} eq 'masc')
        {
            if($f->{animateness} eq 'inan')
            {
                $c = '2';
            }
            else
            {
                $c = '1';
            }
        }
        elsif($f->{gender} eq 'fem')
        {
            $c = '3';
        }
        else
        {
            $c = '4';
        }
    }
    elsif($f->{number} eq 'plu')
    {
        if($f->{gender} eq 'masc')
        {
            if($f->{animateness} eq 'inan')
            {
                $c = '6';
            }
            else
            {
                $c = '5';
            }
        }
        elsif($f->{gender} eq 'fem')
        {
            $c = '7';
        }
        else
        {
            $c = '8';
        }
    }
    else
    {
        $c = '9';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes person (osoba) and number (číslo) of verbs and stores it in a feature
# structure.
#------------------------------------------------------------------------------
sub decode_person_number
{
    my $person = shift; # string
    my $f = shift; # reference to hash
    if($person eq '1')
    {
        $f->{person} = '1';
        $f->{number} = 'sing';
    }
    elsif($person eq '2')
    {
        $f->{person} = '2';
        $f->{number} = 'sing';
    }
    elsif($person eq '3')
    {
        $f->{person} = '3';
        $f->{number} = 'sing';
    }
    elsif($person eq '4')
    {
        $f->{person} = '1';
        $f->{number} = 'plu';
    }
    elsif($person eq '5')
    {
        $f->{person} = '2';
        $f->{number} = 'plu';
    }
    elsif($person eq '6')
    {
        $f->{person} = '3';
        $f->{number} = 'plu';
    }
    elsif($person eq '7')
    {
        $f->{verbform} = 'inf';
        $f->{voice} = 'act';
    }
    elsif($person eq '8')
    {
        $f->{verbform} = 'inf';
        $f->{voice} = 'pass';
    }
    # "non-personal" (neosobní) usage of the third person
    # "říkalo se", "říká se": subject "ono" (it) is a filler that does not denote any semantic object
    elsif($person eq '9')
    {
        $f->{person} = '3';
        $f->{number} = 'sing';
        $f->{other}{nonpers} = 1;
    }
    # non-personal plural
    # only two occurrences in the whole corpus: "řikali", "hlásaj"
    elsif($person eq '0')
    {
        $f->{person} = '3';
        $f->{number} = 'plu';
        $f->{other}{nonpers} = 1;
    }
    # - -> neurčuje se / not specified => empty value
    # can conflict with participle gender+number
    elsif($person eq '-')
    {
        $f->{other}{person} = '-';
    }
    return $f->{person};
}



#------------------------------------------------------------------------------
# Encodes person (osoba) and number (číslo) of verbs as a string.
#------------------------------------------------------------------------------
sub encode_person_number
{
    my $f = shift; # reference to hash
    my $c;
    # - -> neurčuje se / not specified => empty value
    # can conflict with participle gender+number
    if($f->{tagset} eq 'cs::pmk' && $f->{other}{person} eq '-')
    {
        $c = '-';
    }
    elsif($f->{verbform} eq 'inf')
    {
        if($f->{voice} eq 'pass')
        {
            $c = '8';
        }
        else
        {
            $c = '7';
        }
    }
    elsif($f->{number} eq 'plu')
    {
        if($f->{person} == 1)
        {
            $c = '4';
        }
        elsif($f->{person} == 2)
        {
            $c = '5';
        }
        elsif($f->{tagset} eq 'cs::pmk' && $f->{other}{nonpers})
        {
            $c = '0';
        }
        else
        {
            $c = '6';
        }
    }
    elsif($f->{number} eq 'sing')
    {
        if($f->{person} == 1)
        {
            $c = '1';
        }
        elsif($f->{person} == 2)
        {
            $c = '2';
        }
        elsif($f->{tagset} eq 'cs::pmk' && $f->{other}{nonpers})
        {
            $c = '9';
        }
        else
        {
            $c = '3';
        }
    }
    else
    {
        $c = '-';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes case (pád) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_case
{
    my $case = shift; # string
    my $f = shift; # reference to hash
    if($case eq '1')
    {
        $f->{case} = 'nom';
    }
    elsif($case eq '2')
    {
        $f->{case} = 'gen';
    }
    elsif($case eq '3')
    {
        $f->{case} = 'dat';
    }
    elsif($case eq '4')
    {
        $f->{case} = 'acc';
    }
    elsif($case eq '5')
    {
        $f->{case} = 'voc';
    }
    elsif($case eq '6')
    {
        $f->{case} = 'loc';
    }
    elsif($case eq '7')
    {
        $f->{case} = 'ins';
    }
    return $f->{case};
}



#------------------------------------------------------------------------------
# Encodes case (pád) as a string.
#------------------------------------------------------------------------------
sub encode_case
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{case} eq 'nom')
    {
        $c = '1';
    }
    elsif($f->{case} eq 'gen')
    {
        $c = '2';
    }
    elsif($f->{case} eq 'dat')
    {
        $c = '3';
    }
    elsif($f->{case} eq 'acc')
    {
        $c = '4';
    }
    elsif($f->{case} eq 'voc')
    {
        $c = '5';
    }
    elsif($f->{case} eq 'loc')
    {
        $c = '6';
    }
    elsif($f->{case} eq 'ins')
    {
        $c = '7';
    }
    # valency-based case of prepositions: "other" = 8
    elsif($f->{pos} eq 'prep')
    {
        $c = '8';
    }
    # case of nouns, adjectives etc.: "cannot specify or indeclinable" = 9
    else
    {
        $c = '9';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes case of the counted noun phrase (pád počítané jmenné fráze) and
# stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_counted_case
{
    my $case = shift; # string
    my $f = shift; # reference to hash
    if($case eq '1')
    {
        $f->{other}{ccase} = 'nom';
    }
    elsif($case eq '2')
    {
        $f->{other}{ccase} = 'gen';
    }
    elsif($case eq '3')
    {
        $f->{other}{ccase} = 'dat';
    }
    elsif($case eq '4')
    {
        $f->{other}{ccase} = 'acc';
    }
    elsif($case eq '5')
    {
        $f->{other}{ccase} = 'voc';
    }
    elsif($case eq '6')
    {
        $f->{other}{ccase} = 'loc';
    }
    elsif($case eq '7')
    {
        $f->{other}{ccase} = 'ins';
    }
    return $f->{other}{ccase};
}



#------------------------------------------------------------------------------
# Encodes  case of the counted noun phrase (pád počítané jmenné fráze) as a
# string.
#------------------------------------------------------------------------------
sub encode_counted_case
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{other}{ccase} eq 'nom')
    {
        $c = '1';
    }
    elsif($f->{other}{ccase} eq 'gen')
    {
        $c = '2';
    }
    elsif($f->{other}{ccase} eq 'dat')
    {
        $c = '3';
    }
    elsif($f->{other}{ccase} eq 'acc')
    {
        $c = '4';
    }
    elsif($f->{other}{ccase} eq 'voc')
    {
        $c = '5';
    }
    elsif($f->{other}{ccase} eq 'loc')
    {
        $c = '6';
    }
    elsif($f->{other}{ccase} eq 'ins')
    {
        $c = '7';
    }
    # "cannot specify or indeclinable" = 9
    else
    {
        $c = '9';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes the degree of comparison (stupeň) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_degree
{
    my $degree = shift; # string
    my $f = shift; # reference to hash
    if($degree eq '-')
    {
        $f->{degree} = 'pos';
    }
    elsif($degree eq '2')
    {
        $f->{degree} = 'comp';
    }
    elsif($degree eq '3')
    {
        $f->{degree} = 'sup';
    }
    return $f->{degree};
}



#------------------------------------------------------------------------------
# Encodes degree of comparison (stupeň) as a string.
#------------------------------------------------------------------------------
sub encode_degree
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{degree} eq 'pos')
    {
        $c = '-';
    }
    elsif($f->{degree} eq 'comp')
    {
        $c = '2';
    }
    elsif($f->{degree} eq 'sup')
    {
        $c = '3';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes mood (způsob), tense (čas) and voice (slovesný rod) and stores it in
# a feature structure.
#------------------------------------------------------------------------------
sub decode_mood_tense_voice
{
    my $mood = shift; # string
    my $f = shift; # reference to hash
    if($mood eq '1')
    {
        $f->{verbform} = 'fin';
        $f->{mood} = 'ind';
        $f->{tense} = 'pres';
        $f->{voice} = 'act';
    }
    elsif($mood eq '2')
    {
        $f->{verbform} = 'fin';
        $f->{mood} = 'ind';
        $f->{tense} = 'pres';
        $f->{voice} = 'pass';
    }
    elsif($mood eq '3')
    {
        $f->{verbform} = 'fin';
        $f->{mood} = 'cnd';
        $f->{tense} = 'pres';
        $f->{voice} = 'act';
    }
    elsif($mood eq '4')
    {
        $f->{verbform} = 'fin';
        $f->{mood} = 'cnd';
        $f->{tense} = 'pres';
        $f->{voice} = 'pass';
    }
    elsif($mood eq '5')
    {
        $f->{verbform} = 'fin';
        $f->{mood} = 'ind';
        $f->{tense} = 'past';
        $f->{voice} = 'act';
    }
    elsif($mood eq '6')
    {
        $f->{verbform} = 'fin';
        $f->{mood} = 'ind';
        $f->{tense} = 'past';
        $f->{voice} = 'pass';
    }
    elsif($mood eq '7')
    {
        $f->{verbform} = 'fin';
        $f->{mood} = 'cnd';
        $f->{tense} = 'past';
        $f->{voice} = 'act';
    }
    elsif($mood eq '8')
    {
        $f->{verbform} = 'fin';
        $f->{mood} = 'cnd';
        $f->{tense} = 'past';
        $f->{voice} = 'pass';
    }
    elsif($mood eq '9')
    {
        $f->{verbform} = 'fin';
        $f->{mood} = 'ind';
        $f->{tense} = 'fut';
        $f->{voice} = 'act';
    }
    elsif($mood eq '0')
    {
        $f->{verbform} = 'fin';
        $f->{mood} = 'ind';
        $f->{tense} = 'fut';
        $f->{voice} = 'pass';
    }
    return $f->{tense};
}



#------------------------------------------------------------------------------
# Encodes mood (způsob), tense (čas) and voice (slovesný rod) as a string.
#------------------------------------------------------------------------------
sub encode_mood_tense_voice
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{verbform} eq 'trans')
    {
        $c = '-';
    }
    elsif($f->{mood} eq 'cnd')
    {
        if($f->{tense} eq 'past')
        {
            if($f->{voice} eq 'pass')
            {
                $c = '8';
            }
            else
            {
                $c = '7';
            }
        }
        else
        {
            if($f->{voice} eq 'pass')
            {
                $c = '4';
            }
            else
            {
                $c = '3';
            }
        }
    }
    elsif($f->{tense} eq 'fut')
    {
        if($f->{voice} eq 'pass')
        {
            $c = '0';
        }
        else
        {
            $c = '9';
        }
    }
    elsif($f->{tense} eq 'past')
    {
        if($f->{voice} eq 'pass')
        {
            $c = '6';
        }
        else
        {
            $c = '5';
        }
    }
    elsif($f->{tense} eq 'pres')
    {
        if($f->{voice} eq 'pass')
        {
            $c = '2';
        }
        else
        {
            $c = '1';
        }
    }
    else
    {
        $c = '-';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes imperative (rozkazovací způsob), participle (příčestí) and
# transgressive (přechodník) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_nonfinite_verb_form
{
    my $form = shift; # string
    my $f = shift; # reference to hash
    if($form eq '1')
    {
        $f->{verbform} = 'fin';
        $f->{mood} = 'imp';
        $f->{voice} = 'act';
    }
    elsif($form eq '2')
    {
        $f->{verbform} = 'fin';
        $f->{mood} = 'imp';
        $f->{voice} = 'pass';
    }
    elsif($form eq '3')
    {
        $f->{verbform} = 'part';
        $f->{voice} = 'pass';
    }
    elsif($form eq '4')
    {
        $f->{verbform} = 'trans';
        $f->{tense} = 'pres';
        $f->{voice} = 'act';
    }
    elsif($form eq '5')
    {
        $f->{verbform} = 'trans';
        $f->{tense} = 'pres';
        $f->{voice} = 'pass';
    }
    elsif($form eq '6')
    {
        $f->{verbform} = 'trans';
        $f->{tense} = 'past';
        $f->{voice} = 'act';
    }
    elsif($form eq '7')
    {
        $f->{verbform} = 'trans';
        $f->{tense} = 'past';
        $f->{voice} = 'pass';
    }
    return $f->{verbform};
}



#------------------------------------------------------------------------------
# Encodes imperative (rozkazovací způsob), participle (příčestí) and
# transgressive (přechodník) as a string.
#------------------------------------------------------------------------------
sub encode_nonfinite_verb_form
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{mood} eq 'imp')
    {
        if($f->{voice} eq 'pass')
        {
            $c = '2';
        }
        else
        {
            $c = '1';
        }
    }
    elsif($f->{verbform} eq 'part' && $f->{voice} eq 'pass')
    {
        $c = '3';
    }
    elsif($f->{verbform} eq 'trans')
    {
        if($f->{tense} eq 'past')
        {
            if($f->{voice} eq 'pass')
            {
                $c = '7';
            }
            else
            {
                $c = '6';
            }
        }
        else
        {
            if($f->{voice} eq 'pass')
            {
                $c = '5';
            }
            else
            {
                $c = '4';
            }
        }
    }
    else
    {
        $c = '-';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes negativeness (zápor) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_negativeness
{
    my $negativeness = shift; # string
    my $f = shift; # reference to hash
    if($negativeness eq '1')
    {
        $f->{negativeness} = 'pos';
    }
    elsif($negativeness eq '2')
    {
        $f->{negativeness} = 'neg';
    }
    return $f->{negativeness};
}



#------------------------------------------------------------------------------
# Encodes negativeness (zápor) as a string.
#------------------------------------------------------------------------------
sub encode_negativeness
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{negativeness} eq 'neg')
    {
        $c = '2';
    }
    else
    {
        $c = '1';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes style (styl) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_style
{
    my $style = shift; # string
    my $f = shift; # reference to hash
    if($style eq '1') # (základní, mluvený, neformální)
    {
        $f->{style} = 'coll';
    }
    elsif($style eq '2') # (neutrální, mluvený, psaný)
    {
        $f->{style} = 'norm';
    }
    elsif($style eq '3') # (knižní)
    {
        $f->{style} = 'form';
    }
    elsif($style eq '4') # (vulgární)
    {
        $f->{style} = 'vulg';
    }
    return $f->{style};
}



#------------------------------------------------------------------------------
# Encodes style (styl) as a string.
#------------------------------------------------------------------------------
sub encode_style
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{style} eq 'vulg')
    {
        $c = '4';
    }
    elsif($f->{style} eq 'form')
    {
        $c = '3';
    }
    elsif($f->{style} eq 'coll')
    {
        $c = '1';
    }
    else
    {
        $c = '2';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes noun type (druh) and stores it in a feature structure.
# Noun types in PMK mostly reflect how (from what part of speech) the noun was
# derived.
#------------------------------------------------------------------------------
sub decode_noun_type
{
    my $type = shift; # string
    my $f = shift; # reference to hash
    if($type eq '1') # (běžné: konstruktér, rodina, auto)
    {
        # this is default
    }
    elsif($type eq '2') # (adjektivní: ženská, vedoucí, nadřízenej)
    {
        $f->{other}{nountype} = 'adj';
    }
    elsif($type eq '3') # (zájmenné: naši, vaši)
    {
        $f->{other}{nountype} = 'pron';
    }
    elsif($type eq '4') # (číslovkové: dvojka, devítka, šestsettřináctka)
    {
        $f->{other}{nountype} = 'num';
    }
    elsif($type eq '5') # (slovesné: postavení, bití, chování)
    {
        $f->{other}{nountype} = 'verb';
    }
    elsif($type eq '6') # (slovesné zvratné: věnování se; note: the tag is assigned to 'věnování' while 'se' has an empty tag)
    {
        $f->{other}{nountype} = 'verb';
        $f->{reflex} = 'reflex';
    }
    elsif($type eq '7') # (zkratkové slovo: ó dé eska; note: the tag is assigned to 'ó' while 'dé' and 'eska' have empty tags)
    {
        # not the same as an abbreviated noun
        $f->{other}{nountype} = 'abbr';
    }
    elsif($type eq '9') # (nesklonné: apartmá, interview, gró)
    {
        $f->{other}{nountype} = 'indecl';
    }
    return $f->{prepcase};
}



#------------------------------------------------------------------------------
# Encodes noun type (druh) as a string.
#------------------------------------------------------------------------------
sub encode_noun_type
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{reflex} eq 'reflex')
    {
        $c = '6';
    }
    elsif($f->{tagset} eq 'cs::pmk')
    {
        if($f->{other}{nountype} eq 'adj')
        {
            $c = '2';
        }
        elsif($f->{other}{nountype} eq 'pron')
        {
            $c = '3';
        }
        elsif($f->{other}{nountype} eq 'num')
        {
            $c = '4';
        }
        elsif($f->{other}{nountype} eq 'verb')
        {
            $c = '5';
        }
        elsif($f->{other}{nountype} eq 'abbr')
        {
            $c = '7';
        }
        elsif($f->{other}{nountype} eq 'indecl')
        {
            $c = '9';
        }
        else
        {
            $c = '1';
        }
    }
    else
    {
        $c = '1';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes adjective type (druh) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_adjective_type
{
    my $type = shift; # string
    my $f = shift; # reference to hash
    if($type eq '1') # (nespecifické: jiný, prázdnej, řádová)
    {
        # this is default
    }
    elsif($type eq '2') # (slovesné: ovlivněný, skličující, vyspělý)
    {
        $f->{other}{adjtype} = 'verb';
    }
    elsif($type eq '3') # (přivlastňovací: Martinův, tátový, Klárčiny)
    {
        $f->{poss} = 'poss';
    }
    return $f->{other}{accom};
}



#------------------------------------------------------------------------------
# Encodes adjective type (druh) as a string.
#------------------------------------------------------------------------------
sub encode_adjective_type
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{poss} eq 'poss')
    {
        $c = '3';
    }
    elsif($f->{tagset} eq 'cs::pmk' && $f->{other}{adjtype} eq 'verb')
    {
        $c = '2';
    }
    else
    {
        $c = '1';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes adjective subtype (poddruh) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_adjective_subtype
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # (departicipiální prosté: přeloženej, shořelej, naloženej)
    {
        $f->{verbform} = 'part';
    }
    elsif($c eq '2') # (zvratné: blížícím se, se živícim, drolící se)
    {
        $f->{reflex} = 'reflex';
    }
    elsif($c eq '3') # (jmenná forma sg neutra: (chybná anotace???) prioritní, vytížený, obligátní)
    {
        $f->{variant} = 'short';
        $f->{gender} = 'neut';
        $f->{number} = 'sing';
    }
    elsif($c eq '4') # (jmenná forma jiná: schopni, ochotni, unaven)
    {
        $f->{variant} = 'short';
    }
    elsif($c eq '5') # (zvratné jmenná forma: si vědom)
    {
        $f->{variant} = 'short';
        $f->{reflex} = 'reflex';
    }
    elsif($c eq '0') # (ostatní: chybnejch, normální, hovorový)
    {
        # this is default
    }
    return $f->{other}{agglutination};
}



#------------------------------------------------------------------------------
# Encodes adjective subtype (poddruh) as a string.
#------------------------------------------------------------------------------
sub encode_adjective_subtype
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{variant} eq 'short')
    {
        if($f->{reflex} eq 'reflex')
        {
            $c = '5';
        }
        elsif($f->{gender} eq 'neut' && $f->{number} eq 'sing')
        {
            $c = '3';
        }
        else
        {
            $c = '4';
        }
    }
    elsif($f->{reflex} eq 'reflex')
    {
        $c = '2';
    }
    elsif($f->{verbform} eq 'part')
    {
        $c = '1';
    }
    else
    {
        $c = '0';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes pronoun type (druh) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_pronoun_type
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # (osobní: já, ty, on, ona, ono, my, vy, oni, ony)
    {
        $f->{prontype} = 'prs';
    }
    elsif($c eq '2') # (neurčité: všem, všechno, nějakou, ňáká, něco, některé, každý)
    {
        $f->{prontype} = 'ind';
    }
    elsif($c eq '3') # (zvratné osobní: sebe, sobě, se, si, sebou)
    {
        $f->{prontype} = 'prs';
        $f->{reflex} = 'reflex';
    }
    elsif($c eq '4') # (ukazovací: to, takový, tu, ten, tamto, té, tech)
    {
        $f->{prontype} = 'dem';
    }
    elsif($c eq '5') # (tázací: co, jaký, kdo, čim, komu, která)
    {
        $f->{prontype} = 'int';
    }
    elsif($c eq '6') # (vztažné: což, který, která, čeho, čehož, jakým)
    {
        $f->{prontype} = 'rel';
    }
    elsif($c eq '7') # (záporné: žádná, nic, žádný, žádnej, nikdo, nikomu)
    {
        $f->{prontype} = 'neg';
    }
    elsif($c eq '8') # (přivlastňovací: můj, tvůj, jeho, její, náš, váš, jejich)
    {
        $f->{prontype} = 'prs';
        $f->{poss} = 'poss';
    }
    elsif($c eq '9') # (zvratné přivlastňovací: své, svýmu, svými, svoje)
    {
        $f->{prontype} = 'prs';
        $f->{poss} = 'poss';
        $f->{reflex} = 'reflex';
    }
    elsif($c eq '0') # (víceslovné: nějaký takový, takový ňáký, nějaký ty, takovym tim)
    {
        $f->{prontype} = 'ind';
        $f->{other}{prontype} = 'víceslovné';
    }
    elsif($c eq '-') # (víceslovné vztažné: to co, "to, co", něco co, "ten, kdo")
    {
        $f->{prontype} = 'rel';
        $f->{other}{prontype} = 'víceslovné';
    }
    return $f->{prontype};
}



#------------------------------------------------------------------------------
# Encodes pronoun type (druh) as a string.
#------------------------------------------------------------------------------
sub encode_pronoun_type
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{prontype} eq 'prs')
    {
        if($f->{poss} eq 'poss')
        {
            if($f->{reflex} eq 'reflex')
            {
                $c = '9';
            }
            else
            {
                $c = '8';
            }
        }
        else
        {
            if($f->{reflex} eq 'reflex')
            {
                $c = '3';
            }
            else
            {
                $c = '1';
            }
        }
    }
    elsif($f->{prontype} eq 'ind')
    {
        if($f->{tagset} eq 'cs::pmk' && $f->{other}{prontype} eq 'víceslovné')
        {
            $c = '0';
        }
        else
        {
            $c = '2';
        }
    }
    elsif($f->{prontype} eq 'dem')
    {
        $c = '4';
    }
    elsif($f->{prontype} eq 'int')
    {
        $c = '5';
    }
    elsif($f->{prontype} eq 'rel')
    {
        if($f->{tagset} eq 'cs::pmk' && $f->{other}{prontype} eq 'víceslovné')
        {
            $c = '-';
        }
        else
        {
            $c = '6';
        }
    }
    elsif($f->{prontype} eq 'neg')
    {
        $c = '7';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes numeral type (druh) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_numeral_type
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # (základní: jeden, pět, jedný, deset, vosum)
    {
        $f->{numtype} = 'card';
    }
    elsif($c eq '2') # (řadová: druhej, prvnímu, poprvé, sedumdesátým)
    {
        $f->{numtype} = 'ord';
    }
    elsif($c eq '3') # (druhová: oboje, troje, vosmery, jedny, dvojího)
    {
        $f->{numtype} = 'gen';
    }
    elsif($c eq '4') # (násobná: dvakrát, mockrát, jednou, mnohokrát, čtyřikrát)
    {
        $f->{numtype} = 'mult';
    }
    elsif($c eq '5') # (neurčitá: několik, kolik, pár, tolik, několikrát)
    {
        $f->{prontype} = 'ind';
    }
    elsif($c eq '6') # (víceslovná základní: dvě stě, tři tisíce, deset tisíc, sedum set, čtyřista)
    {
        $f->{numtype} = 'card';
        $f->{other}{numtype} = 'víceslovná';
    }
    elsif($c eq '7') # (víceslovná řadová: sedumdesátym druhym, šedesátej vosmej, osmdesátém devátém)
    {
        $f->{numtype} = 'ord';
        $f->{other}{numtype} = 'víceslovná';
    }
    elsif($c eq '8') # (víceslovná druhová)
    {
        $f->{numtype} = 'gen';
        $f->{other}{numtype} = 'víceslovná';
    }
    elsif($c eq '9') # (víceslovná násobná)
    {
        $f->{numtype} = 'mult';
        $f->{other}{numtype} = 'víceslovná';
    }
    elsif($c eq '0') # (víceslovná neurčitá: "tolik, kolik", "tolik (ženskejch), kolik")
    {
        $f->{prontype} = 'ind';
        $f->{other}{numtype} = 'víceslovná';
    }
    return $f->{numtype};
}



#------------------------------------------------------------------------------
# Encodes numeral type (druh) as a string.
#------------------------------------------------------------------------------
sub encode_numeral_type
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{tagset} eq 'cs::pmk' && $f->{other}{numtype} eq 'víceslovná')
    {
        if($f->{prontype} eq 'ind')
        {
            $c = '0';
        }
        elsif($f->{numtype} eq 'mult')
        {
            $c = '9';
        }
        elsif($f->{numtype} eq 'gen')
        {
            $c = '8';
        }
        elsif($f->{numtype} eq 'ord')
        {
            $c = '7';
        }
        else
        {
            $c = '6';
        }
    }
    else
    {
        if($f->{prontype} eq 'ind')
        {
            $c = '5';
        }
        elsif($f->{numtype} eq 'mult')
        {
            $c = '4';
        }
        elsif($f->{numtype} eq 'gen')
        {
            $c = '3';
        }
        elsif($f->{numtype} eq 'ord')
        {
            $c = '2';
        }
        else
        {
            $c = '1';
        }
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes aspect (vid / druh) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_aspect
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # (imperfektivum: neměl, myslim, je, má, existují)
    {
        $f->{aspect} = 'imp';
    }
    elsif($c eq '2') # (perfektivum: uživí, udělat, zlepšit, rozvíst, vynechat)
    {
        $f->{aspect} = 'perf';
    }
    elsif($c eq '9') # (obouvidové: stačilo, absolvovali, algoritmizovat, analyzujou, nedokáží)
    {
        # empty value means both aspects are possible
    }
    return $f->{aspect};
}



#------------------------------------------------------------------------------
# Encodes aspect (vid / druh) as a string.
#------------------------------------------------------------------------------
sub encode_aspect
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{aspect} eq 'imp')
    {
        $c = '1';
    }
    elsif($f->{aspect} eq 'perf')
    {
        $c = '2';
    }
    else
    {
        $c = '9';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes adverb type (druh) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_adverb_type
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # (běžné nespecifické: materiálně, pak, finančně, moc, hrozně)
    {
        # this is default
    }
    elsif($c eq '2') # (predikativum: nelze, smutno, blízko, zima, horko)
    {
        $f->{synpos} = 'pred';
    }
    elsif($c eq '3') # (zájmenné nespojovací: tady, jak, tak, tehdy, teď, vždycky, kde, vodkaď, tam, tu, vodtaď, potom, přitom, někde...)
    {
        # In fact, this category contains several types of pronominal adverbs: indefinite, demonstrative, interrogative etc.
        # The main point is to set prontype to anything non-empty here to distinguish them from adjectival adverbs.
        $f->{prontype} = 'ind';
    }
    elsif($c eq '4') # (spojovací výraz jednoslovný: proč, kdy, kde, kam)
    {
        $f->{prontype} = 'rel';
    }
    elsif($c eq '5') # (spojovací výraz víceslovný: "tak, jak", "tak, že", "tak, aby", "tak jako", "tak (velký), aby")
    {
        # Typically, this is a pair of a demonstrative adverb ("tak") and a relative adverb ("jak") or conjunction ("že").
        # The tag appears at the demonstrative adverb while the rest has empty tag.
        $f->{prontype} = 'dem';
    }
    return $f;
}



#------------------------------------------------------------------------------
# Encodes adverb type (druh) as a string.
#------------------------------------------------------------------------------
sub encode_adverb_type
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{synpos} eq 'pred')
    {
        $c = '2';
    }
    elsif($f->{prontype} eq 'ind')
    {
        $c = '3';
    }
    elsif($f->{prontype} eq 'rel')
    {
        $c = '4';
    }
    elsif($f->{prontype} eq 'dem')
    {
        $c = '5';
    }
    else
    {
        $c = '1';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes preposition type (druh) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_preposition_type
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # (běžná vlastní: v, vod, na, z, se)
    {
        # default
    }
    elsif($c eq '2') # (nevlastní homonymní: vokolo, vedle, včetně, pomocí, během)
    {
        $f->{other}{preptype} = 'nevlastní';
    }
    elsif($c eq '3') # (víceslovná: z pohledů, na základě, na začátku, za účelem, v rámci)
    {
        $f->{other}{preptype} = 'víceslovná';
    }
    return $f;
}



#------------------------------------------------------------------------------
# Encodes preposition type (druh) as a string.
#------------------------------------------------------------------------------
sub encode_preposition_type
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{tagset} eq 'cs::pmk')
    {
        if($f->{other}{preptype} eq 'nevlastní')
        {
            $c = '2';
        }
        elsif($f->{other}{preptype} eq 'víceslovná')
        {
            $c = '3';
        }
        else
        {
            $c = '1';
        }
    }
    else
    {
        $c = '1';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes conjunction type (druh) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_conjunction_type
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # (souřadící jednoslovná: a, ale, nebo, jenomže, či)
    {
        $f->{subpos} = 'coor';
    }
    elsif($c eq '2') # (podřadící jednoslovná: jesli, protože, že, jako, než)
    {
        $f->{subpos} = 'sub';
    }
    elsif($c eq '3') # (souřadící víceslovná: buďto-anebo, i-i, ať už-anebo, buď-nebo, ať-nebo)
    {
        $f->{subpos} = 'coor';
        $f->{other}{multitoken} = 1;
    }
    elsif($c eq '4') # (podřadící víceslovná: jesli-tak, "na to, že", i když, i dyž, proto-že)
    {
        $f->{subpos} = 'sub';
        $f->{other}{multitoken} = 1;
    }
    elsif($c eq '5') # (jiná jednoslovná: v korpusu se nevyskytuje)
    {
        $f->{other}{conjtype} = 'other';
    }
    elsif($c eq '6') # (jiná víceslovná: v korpusu se nevyskytuje)
    {
        $f->{other}{conjtype} = 'other';
        $f->{other}{multitoken} = 1;
    }
    elsif($c eq '9') # (nelze určit: buď, jak, sice, jednak, buďto)
    {
        # default
    }
    return $f;
}



#------------------------------------------------------------------------------
# Encodes conjunction type (druh) as a string.
#------------------------------------------------------------------------------
sub encode_conjunction_type
{
    my $f = shift; # reference to hash
    my $c;
    my $multitoken;
    my $other;
    if($f->{tagset} eq 'cs::pmk')
    {
        $multitoken = $f->{other}{multitoken};
        $other = $f->{other}{conjtype} eq 'other';
    }
    if($f->{subpos} eq 'coor')
    {
        if($multitoken)
        {
            $c = '3';
        }
        else
        {
            $c = '1';
        }
    }
    elsif($f->{subpos} eq 'sub')
    {
        if($multitoken)
        {
            $c = '4';
        }
        else
        {
            $c = '2';
        }
    }
    elsif($other)
    {
        if($multitoken)
        {
            $c = '6';
        }
        else
        {
            $c = '5';
        }
    }
    else
    {
        $c = '9';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes interjection type (druh) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_interjection_type
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # (běžné původní: hm, nó, no jo, jé, aha)
    {
        # default
    }
    elsif($c eq '2') # (substantivní: škoda, čoveče, mami, bóže, hovno)
    {
        $f->{other}{intertype} = 'noun';
    }
    elsif($c eq '3') # (adjektivní: hotovo, bezva)
    {
        $f->{other}{intertype} = 'adj';
    }
    elsif($c eq '4') # (zájmenné: jo, ne, jó, né)
    {
        $f->{other}{intertype} = 'pron';
    }
    elsif($c eq '5') # (slovesné: neboj, sím, podivejte, hele, počkej)
    {
        $f->{other}{intertype} = 'verb';
    }
    elsif($c eq '6') # (adverbiální: vážně, jistě, takle, depak, rozhodně)
    {
        $f->{other}{intertype} = 'adv';
    }
    elsif($c eq '7') # (jiné: jaktože, pardón, zaplať pámbu, ahój, vůbec)
    {
        $f->{other}{intertype} = 'other';
    }
    elsif($c eq '0') # (víceslovné = frazém: v korpusu se nevyskytlo, resp. možná se vyskytlo a bylo označkováno jako frazém)
    {
        $f->{other}{intertype} = 'multitoken';
    }
    return $f;
}



#------------------------------------------------------------------------------
# Encodes interjection type (druh) as a string.
#------------------------------------------------------------------------------
sub encode_interjection_type
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{intertype}))
    {
        if($f->{other}{intertype} eq 'noun')
        {
            $c = '2';
        }
        elsif($f->{other}{intertype} eq 'adj')
        {
            $c = '3';
        }
        elsif($f->{other}{intertype} eq 'pron')
        {
            $c = '4';
        }
        elsif($f->{other}{intertype} eq 'verb')
        {
            $c = '5';
        }
        elsif($f->{other}{intertype} eq 'adv')
        {
            $c = '6';
        }
        elsif($f->{other}{intertype} eq 'other')
        {
            $c = '7';
        }
        elsif($f->{other}{intertype} eq 'multitoken')
        {
            $c = '0';
        }
        else
        {
            $c = '1';
        }
    }
    else
    {
        $c = '1';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes particle type (druh) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_particle_type
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # (vlastní nehomonymní: asi, právě, také, spíš, přece)
    {
        # default
    }
    elsif($c eq '2') # (adverbiální: prostě, hnedle, naopak, třeba, tak)
    {
        $f->{other}{parttype} = 'adv';
    }
    elsif($c eq '3') # (spojkové: teda, ani, jako, až, ale)
    {
        $f->{other}{parttype} = 'conj';
    }
    elsif($c eq '4') # (jiné: nó, zrovna, jo, vlastně, to)
    {
        $f->{other}{parttype} = 'other';
    }
    elsif($c eq '5') # (víceslovné nevětné: no tak, tak ňák, že jo, nebo co, jen tak)
    {
        $f->{other}{parttype} = 'multitoken';
    }
}



#------------------------------------------------------------------------------
# Encodes particle type (druh) as a string.
#------------------------------------------------------------------------------
sub encode_particle_type
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{parttype}))
    {
        if($f->{other}{parttype} eq 'adv')
        {
            $c = '2';
        }
        elsif($f->{other}{parttype} eq 'conj')
        {
            $c = '3';
        }
        elsif($f->{other}{parttype} eq 'other')
        {
            $c = '4';
        }
        elsif($f->{other}{parttype} eq 'multitoken')
        {
            $c = '5';
        }
        else
        {
            $c = '1';
        }
    }
    else
    {
        $c = '1';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes idiom type (druh) and stores it in a feature structure.
#
###!!!
# Perhaps we could reverse the priorities. Idiom type would be (mostly) decoded
# as $f->{pos}, and $f->{other} would record that this is an idiom.
#------------------------------------------------------------------------------
sub decode_idiom_type
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # (verbální: vyprdnout se na to, mít dojem, mít smysl, měli rádi, jít vzorem)
    {
        $f->{other}{idiomtype} = 'verb';
    }
    elsif($c eq '2') # (substantivní: hlava rodiny, žebříček hodnot, říjnový revoluci, diamantovou svatbou, českej člověk)
    {
        $f->{other}{idiomtype} = 'noun';
    }
    elsif($c eq '3') # (adjektivní: ten a ten, každym druhym, toho a toho, jako takovou, výše postavených)
    {
        $f->{other}{idiomtype} = 'adj';
    }
    elsif($c eq '4') # (adverbiální: u nás, v naší době, tak ňák, za chvíli, podle mýho názoru)
    {
        $f->{other}{idiomtype} = 'adv';
    }
    elsif($c eq '5') # (propoziční včetně interjekčních: to stálo vodříkání, to snad není možný, je to tím že, největší štěstí je)
    {
        $f->{other}{idiomtype} = 'prop';
    }
    elsif($c eq '6') # (jiné: samy za sebe, všechno možný, jak který, všech možnejch, jednoho vůči druhýmu)
    {
        $f->{other}{idiomtype} = 'other';
    }
}



#------------------------------------------------------------------------------
# Encodes idiom type (druh) as a string.
#------------------------------------------------------------------------------
sub encode_idiom_type
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{idiomtype}))
    {
        if($f->{other}{idiomtype} eq 'verb')
        {
            $c = '1';
        }
        elsif($f->{other}{idiomtype} eq 'noun')
        {
            $c = '2';
        }
        elsif($f->{other}{idiomtype} eq 'adj')
        {
            $c = '3';
        }
        elsif($f->{other}{idiomtype} eq 'adv')
        {
            $c = '4';
        }
        elsif($f->{other}{idiomtype} eq 'prop')
        {
            $c = '5';
        }
        else
        {
            $c = '6';
        }
    }
    else
    {
        $c = '6';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes other real type (skutečný druh) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_other_real_type
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq 'C') # (citátové výrazy cizojazyčné, zvláště víceslovné: go, skinheads, non plus ultra, madame, cleaner polish)
    {
        $f->{foreign} = 'foreign';
    }
    elsif($c eq 'Z') # (zkratky neslovní: ý, í, x, ČKD, EEG)
    {
        $f->{abbr} = 'abbr';
    }
    elsif($c eq 'P') # (propria: Kunratickou, Hrádek, Mirek, Roháčích, Vinnetou)
    {
        $f->{subpos} = 'prop';
    }
}



#------------------------------------------------------------------------------
# Encodes other real type (skutečný druh) as a string.
#------------------------------------------------------------------------------
sub encode_other_real_type
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{foreign} eq 'foreign')
    {
        $c = 'C';
    }
    elsif($f->{abbr} eq 'abbr')
    {
        $c = 'Z';
    }
    elsif($f->{subpos} eq 'prop')
    {
        $c = 'P';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes proper noun type (druh) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_proper_noun_type
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # (jednoslovné: Vinnetou, Rybanu, Tujunga, Brně, Praze)
    {
        # default
    }
    elsif($c eq '2') # (víceslovné: Zahradním Městě, u Andělů, Staroměstského náměstí, Český Štenberk, Lucinka Tomíčková)
    {
        $f->{other}{multitoken} = 1;
    }
}



#------------------------------------------------------------------------------
# Encodes proper noun type (druh) as a string.
#------------------------------------------------------------------------------
sub encode_proper_noun_type
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{multitoken}) && $f->{other}{multitoken})
    {
        $c = '2';
    }
    else
    {
        $c = '1';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes noun class (třída) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_noun_class
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # (osoba: holčička, maminku, blondýnka, bytost, rošťanda)
    {
        $f->{other}{nounclass} = 'person';
    }
    elsif($c eq '2') # (živočich: zvířata, vůl, had, krávám, psy)
    {
        $f->{other}{nounclass} = 'animal';
    }
    elsif($c eq '3') # (konkrétum: hlavou, vodu, nohy, auto, metru)
    {
        $f->{other}{nounclass} = 'concrete';
    }
    elsif($c eq '4') # (abstraktum: pocit, vzdělání, mezera, mládí, války)
    {
        $f->{other}{nounclass} = 'abstract';
    }
    elsif($c eq '9') # (jiné nejasné: sídlišti, chatu, továrnách, pracovně, ateliér)
    {
        $f->{other}{nounclass} = 'unclear';
    }
    return $f->{other}{nounclass};
}



#------------------------------------------------------------------------------
# Encodes noun class (třída) as a string.
#------------------------------------------------------------------------------
sub encode_noun_class
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{nounclass}))
    {
        if($f->{other}{nounclass} eq 'person')
        {
            $c = '1';
        }
        elsif($f->{other}{nounclass} eq 'animal')
        {
            $c = '2';
        }
        elsif($f->{other}{nounclass} eq 'concrete')
        {
            $c = '3';
        }
        elsif($f->{other}{nounclass} eq 'abstract')
        {
            $c = '4';
        }
        else
        {
            $c = '9';
        }
    }
    else
    {
        $c = '9';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes adjective class (třída) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_adjective_class
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # (deskriptivní: těsné, prožitej, vykonaný, starší, mladších)
    {
        $f->{other}{adjclass} = 'descr';
    }
    elsif($c eq '2') # (deskriptivní propriální: Zděnkový, Patriková, Romanovou, náchodskýcho, silvánského)
    {
        $f->{other}{adjclass} = 'prop';
    }
    elsif($c eq '3') # (evaluativní: blbej, nepříjemnej, hroznej, neuvěřitelný, šílený)
    {
        $f->{other}{adjclass} = 'eval';
    }
    elsif($c eq '4') # (intenzifikační: kratší, krátkou, delší, rychlý, malej, velká, nejhlubšího)
    {
        $f->{other}{adjclass} = 'intens';
    }
    elsif($c eq '5') # (restriktivní: celý, další, stejnej, specifický, určitý, jinýho)
    {
        $f->{other}{adjclass} = 'restr';
    }
    elsif($c eq '9') # (nelze určit: zato, myšlená, danej)
    {
        # default
    }
}



#------------------------------------------------------------------------------
# Encodes adjective class (třída) as a string.
#------------------------------------------------------------------------------
sub encode_adjective_class
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{adjclass}))
    {
        if($f->{other}{adjclass} eq 'descr')
        {
            $c = '1';
        }
        elsif($f->{other}{adjclass} eq 'prop')
        {
            $c = '2';
        }
        elsif($f->{other}{adjclass} eq 'eval')
        {
            $c = '3';
        }
        elsif($f->{other}{adjclass} eq 'intens')
        {
            $c = '4';
        }
        elsif($f->{other}{adjclass} eq 'restr')
        {
            $c = '5';
        }
        else
        {
            $c = '9';
        }
    }
    else
    {
        $c = '9';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes adverb class (třída) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_adverb_class
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '-') # (neurčuje se: takle, jak, tak, takhle, nějak)
    {
        # default
    }
    elsif($c eq '1') # (deskriptivní: spolu, prakticky, individuálně, citově, přesně)
    {
        $f->{other}{advclass} = 'descr';
    }
    elsif($c eq '2') # (evaluativní: strašně, různě, nespravedlivě, pořádně, prakticky)
    {
        $f->{other}{advclass} = 'eval';
    }
    elsif($c eq '3') # (intenzifikační: malinko, uplně, totálně, hodně, daleko)
    {
        $f->{other}{advclass} = 'intens';
    }
    elsif($c eq '4') # (restriktivní: většinou, jenom, podobně, stejně, výhradně)
    {
        $f->{other}{advclass} = 'restr';
    }
    elsif($c eq '5') # (deskriptivní časoprostorové: pořád, domů, dneska, tady, někam)
    {
        $f->{other}{advclass} = 'timespace';
    }
    elsif($c eq '6') # (nelze určit: no occurrence in corpus)
    {
        $f->{other}{advclass} = 'unknown';
    }
}



#------------------------------------------------------------------------------
# Encodes adverb class (třída) as a string.
#------------------------------------------------------------------------------
sub encode_adverb_class
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{advclass}))
    {
        if($f->{other}{advclass} eq 'descr')
        {
            $c = '1';
        }
        elsif($f->{other}{advclass} eq 'eval')
        {
            $c = '2';
        }
        elsif($f->{other}{advclass} eq 'intens')
        {
            $c = '3';
        }
        elsif($f->{other}{advclass} eq 'restr')
        {
            $c = '4';
        }
        elsif($f->{other}{advclass} eq 'timespace')
        {
            $c = '5';
        }
        elsif($f->{other}{advclass} eq 'unknown')
        {
            $c = '6';
        }
        else
        {
            $c = '-';
        }
    }
    else
    {
        $c = '-';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes preposition class (třída) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_preposition_class
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # (lokální: u, do, na, v, po)
    {
        $f->{advtype} = 'loc';
    }
    elsif($c eq '2') # (temporální: před, po, v, vod, do)
    {
        $f->{advtype} = 'tim';
    }
    elsif($c eq '3') # (jiná: vo, kvůli, ke, kromě, s)
    {
        # default
    }
    return $f->{advtype};
}



#------------------------------------------------------------------------------
# Encodes preposition class (třída) as a string.
#------------------------------------------------------------------------------
sub encode_preposition_class
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{advtype} eq 'loc')
    {
        $c = '1';
    }
    elsif($f->{advtype} eq 'tim')
    {
        $c = '2';
    }
    else
    {
        $c = '3';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes conjunction class (třída) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_conjunction_class
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # (kombinační (sluč./stup./vyluč./odpor.): a, ale, nebo, jenomže, ať)
    {
        $f->{other}{conjclass} = 'comb';
    }
    elsif($c eq '2') # (specifikační (obsah./kval./účin./účel.): aby, že, jesli)
    {
        $f->{other}{conjclass} = 'spec';
    }
    elsif($c eq '3') # (závislostní (kauz./důsl./podmín./příp./výjim.): pokuď, když, protože, takže, prže)
    {
        $f->{other}{conjclass} = 'dep';
    }
    elsif($c eq '4') # (časoprostorová: jakmile, než, co, jak, dyž)
    {
        $f->{other}{conjclass} = 'timespace';
    }
    elsif($c eq '5') # (jiná (podob./srov./způs./zřet.): než, jako)
    {
        $f->{other}{conjclass} = 'comp';
    }
    return $f->{other}{conjclass};
}



#------------------------------------------------------------------------------
# Encodes conjunction class (třída) as a string.
#------------------------------------------------------------------------------
sub encode_conjunction_class
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{conjclass}))
    {
        if($f->{other}{conjclass} eq 'comb')
        {
            $c = '1';
        }
        elsif($f->{other}{conjclass} eq 'spec')
        {
            $c = '2';
        }
        elsif($f->{other}{conjclass} eq 'dep')
        {
            $c = '3';
        }
        elsif($f->{other}{conjclass} eq 'timespace')
        {
            $c = '4';
        }
        elsif($f->{other}{conjclass} eq 'comp')
        {
            $c = '5';
        }
    }
    else
    {
        $c = '1';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes interjection class (třída) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_interjection_class
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # (faktuální: ee, ne, hm, á, eh)
    {
        $f->{other}{interclass} = 'fac';
    }
    elsif($c eq '2') # (voluntativní: no, jo, jasně, pozor, nene)
    {
        $f->{other}{interclass} = 'vol';
    }
    elsif($c eq '3') # (emocionální: sakra, jé, bóže, bezva, hrůza)
    {
        $f->{other}{interclass} = 'emo';
    }
    elsif($c eq '4') # (kontaktové: neboj, podivejte, na, hele, počkej)
    {
        $f->{other}{interclass} = 'con';
    }
    elsif($c eq '5') # (onomatopoické: hhh, checheche, cha, chachacha)
    {
        $f->{other}{interclass} = 'ono';
    }
    elsif($c eq '6') # (voluntativní kontaktové: vole)
    {
        $f->{other}{interclass} = 'volcon';
    }
    elsif($c eq '7') # (voluntativní emocionální: jaktože, ty, ále, chá, šlus)
    {
        $f->{other}{interclass} = 'volemo';
    }
    elsif($c eq '8') # (voluntativní onomatopoické: šup)
    {
        $f->{other}{interclass} = 'volono';
    }
    elsif($c eq '9') # (emocionální kontaktové: ano)
    {
        $f->{other}{interclass} = 'emocon';
    }
    elsif($c eq '0') # (jiné: no occurrence in corpus)
    {
        $f->{other}{interclass} = 'other';
    }
}



#------------------------------------------------------------------------------
# Encodes interjection class (třída) as a string.
#------------------------------------------------------------------------------
sub encode_interjection_class
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{interclass}))
    {
        if($f->{other}{interclass} eq 'fac')
        {
            $c = '1';
        }
        elsif($f->{other}{interclass} eq 'vol')
        {
            $c = '2';
        }
        elsif($f->{other}{interclass} eq 'emo')
        {
            $c = '3';
        }
        elsif($f->{other}{interclass} eq 'con')
        {
            $c = '4';
        }
        elsif($f->{other}{interclass} eq 'ono')
        {
            $c = '5';
        }
        elsif($f->{other}{interclass} eq 'volcon')
        {
            $c = '6';
        }
        elsif($f->{other}{interclass} eq 'volemo')
        {
            $c = '7';
        }
        elsif($f->{other}{interclass} eq 'volono')
        {
            $c = '8';
        }
        elsif($f->{other}{interclass} eq 'emocon')
        {
            $c = '9';
        }
        elsif($f->{other}{interclass} eq 'other')
        {
            $c = '0';
        }
    }
    else
    {
        $c = '0';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes particle class (třída) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_particle_class
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # (faktuální: tak, teda, asi, jako, řikám)
    {
        $f->{other}{partclass} = 'fact';
    }
    elsif($c eq '2') # (faktuální evaluativní: přitom, stejně, ovšem, potom, prakticky)
    {
        $f->{other}{partclass} = 'eval';
    }
    elsif($c eq '3') # (faktuální intenzifikační: i, specielně, hlavně, aspoň, už)
    {
        $f->{other}{partclass} = 'factintens';
    }
    elsif($c eq '4') # (voluntativní: řekněme)
    {
        $f->{other}{partclass} = 'vol';
    }
    elsif($c eq '5') # (voluntativní evaluativní: třeba)
    {
        $f->{other}{partclass} = 'voleval';
    }
    elsif($c eq '6') # (expresivní (+eval./intenz.): no, taky, tak)
    {
        $f->{other}{partclass} = 'expr';
    }
    elsif($c eq '7') # (emocionální (eval./intenz.): bohužel, normálně, eště, akorát, vyloženě)
    {
        $f->{other}{partclass} = 'emo';
    }
    elsif($c eq '8') # (faktuální expresivní (+eval.): prostě, nakonec, vono, ne, jenom)
    {
        $f->{other}{partclass} = 'factexpr';
    }
    elsif($c eq '9') # (jiné (kombinace): teprv, nó, no, jo, dejme tomu)
    {
        # default
    }
}



#------------------------------------------------------------------------------
# Encodes particle class (třída) as a string.
#------------------------------------------------------------------------------
sub encode_particle_class
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{partclass}))
    {
        if($f->{other}{partclass} eq 'fact')
        {
            $c = '1';
        }
        elsif($f->{other}{partclass} eq 'eval')
        {
            $c = '2';
        }
        elsif($f->{other}{partclass} eq 'factintens')
        {
            $c = '3';
        }
        elsif($f->{other}{partclass} eq 'vol')
        {
            $c = '4';
        }
        elsif($f->{other}{partclass} eq 'voleval')
        {
            $c = '5';
        }
        elsif($f->{other}{partclass} eq 'expr')
        {
            $c = '6';
        }
        elsif($f->{other}{partclass} eq 'emo')
        {
            $c = '7';
        }
        elsif($f->{other}{partclass} eq 'factexpr')
        {
            $c = '8';
        }
        else
        {
            $c = '9';
        }
    }
    else
    {
        $c = '9';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes valency (valence) and stores it in a feature structure.
# Note that valency, as it seems to be defined by the corpus annotation, does
# not distinguish obligatory arguments from optional adjuncts. It simply
# denotes the type of the dependent node in the particular sentence. It is thus
# a property of the word in context, rather than of the lexical unit.
#------------------------------------------------------------------------------
sub decode_valency
{
    my $pos = shift; # digit or letter from the physical tag
    my $c = shift; # string
    my $d = shift; # string
    my $f = shift; # reference to hash
    # nouns
    if($pos eq '1')
    {
        if($c eq '0') # (bez valence: zařazení, ohodnocení, vzdělání, věc, lidi)
        {
            # default
        }
        elsif($c eq '1') # (s bezpředložkovým pádem: fůra, května, rok, revizi, zdroje)
        {
            $f->{other}{valency} = 'npr';
        }
        elsif($c eq '2') # (s předložkou: díru, kamna, smlouva, subdodavatele, modernizace)
        {
            $f->{other}{valency} = 'pre';
        }
        elsif($c eq '3') # (se spojovacím výrazem (včetně relativ): práci, lazar, člověk, dlaždičky, mapy)
        {
            $f->{other}{valency} = 'con';
        }
        elsif($c eq '4') # (s infinitivem: možnost, příležitost, čas, rozdíl, snaha)
        {
            $f->{other}{valency} = 'inf';
        }
        elsif($c eq '5') # (s adverbiem: hodin (denně), životem (předtim), starost (navíc), moc (shora), prací (doma))
        {
            $f->{other}{valency} = 'adv';
        }
        elsif($c eq '6') # (se dvěma bezpředložkovými pády: stanice (metra Dejvická), přetížení (dětí učivem), věnování se (rodičů dětem))
        {
            $f->{other}{valency} = 'npr+npr';
        }
        elsif($c eq '7') # (s bezpředložkovým a předložkovým pádem: kontakt (dětí s vostatníma), výchovu (dětí v rodině), vztah (dítěte k rodině))
        {
            $f->{other}{valency} = 'npr+pre';
        }
        elsif($c eq '8') # (s bezpředložkovým pádem a spojkou: spolčení (jeden proti druhému, aby), podmínky (k tomu, aby), mládí (dítěte, kdy))
        {
            $f->{other}{valency} = 'npr+con';
        }
        elsif($c eq '9') # (jiné a vícečetné: příklad (, kdy), pracovník (, jako je..., kterej...), záruka (, že))
        {
            $f->{other}{valency} = 'oth';
        }
    }
    # adjectives
    elsif($pos eq '2')
    {
        if($c eq '0') # (bez valence v atributu: vysoká, šeredný, mladí, naprostou, nezkušený)
        {
            $f->{synpos} = 'attr';
        }
        elsif($c eq '1') # (bez valence v predikátu: dobrý, solidní, zlí, vobtížný, schopný)
        {
            $f->{synpos} = 'pred';
        }
        elsif($c eq '2') # (s pádem bez předložky v predikátu: vytvořený (závodem), vychovávaná (třicátníky), plný (jich), adekvátní (tomu))
        {
            $f->{synpos} = 'pred';
            $f->{other}{valency} = 'npr';
        }
        elsif($c eq '3') # (s předložkovým pádem v predikátu: spokojený (v práci), nevšímaví (ke všemu), spokojená (s prostředim))
        {
            $f->{synpos} = 'pred';
            $f->{other}{valency} = 'pre';
        }
        elsif($c eq '4') # (se spojkou: rádi (že), přesvědčená (že), hodnější (než), posuzovanej (jako), vyšší (než))
        {
            $f->{other}{valency} = 'con';
        }
        elsif($c eq '5') # (s infinitivem: nutný (vykonávat), možný (měnit), povolený (řikat), schopnej (říct), zvyklý (bejt))
        {
            $f->{other}{valency} = 'inf';
        }
        elsif($c eq '8') # (jiné nebo neurčitelné: otevřený, nemyslitelné, nového, nastudovaného, připravený)
        {
            $f->{other}{valency} = 'oth';
        }
    }
    # pronouns
    elsif($pos eq '3')
    {
        if($c eq '0') # (bez valence: sám, tom, my, všechno, jim)
        {
            # default
        }
        elsif($c eq '1') # (s bezpředložkovým pádem: tudle (otázku) (???), naše (společnost) (???), některý (ženský) (???))
        {
            $f->{other}{valency} = 'npr';
        }
        elsif($c eq '2') # (s předložkovým pádem: sám (vod sebe), každej (z nás), málokterý (z rodičů), málokdo (z nich), někoho (nad hrobem))
        {
            $f->{other}{valency} = 'pre';
        }
        elsif($c eq '3') # (s podřadící spojkou: tom (jesi), tom (kolik), takový (jak), toho (na jaký))
        {
            $f->{other}{valency} = 'con';
        }
        elsif($c eq '4') # (jiné: co, který, ten (že), čem, to (vo čem))
        {
            $f->{other}{valency} = 'oth';
        }
    }
    # numerals
    elsif($pos eq '4')
    {
        if($c eq '0') # (bez valence samostatná: tolik, druhejm, jednou, vobojí, jedno)
        {
            # default
        }
        elsif($c eq '1') # (s bezpředložkovým pádem: vosum (hodin), dva (buřty), tři (krajíce), jedenáct (let), čtyřiceti (letech))
        {
            $f->{other}{valency} = 'npr';
        }
        elsif($c eq '2') # (s předložkou: jedním (z důvodů), jednou (za čtyři roky), dvě (z možností), jeden (z kořenů), čtvrt (na devět))
        {
            $f->{other}{valency} = 'pre';
        }
        elsif($c eq '3') # (jiná: jedenáct (večer), jednou (tak velkej), (těch) devět (co jsme), pět (který), tří (v Praze))
        {
            $f->{other}{valency} = 'oth';
        }
    }
    # verbs and verbal idioms
    elsif($pos eq '5' || $pos eq 'F1')
    {
        if($c eq '1') # (nerealizovaná subjektová valence, zřejmě hlavně u infinitivů: vzdělávat se, dejchat, nehýřit, rozšířit, stihnout)
        {
        }
        elsif($c eq '2') # (nesubjektová valence s akuzativem)
        {
            if($d eq '-') # (jen akuzativ: dělat (tohleto), stihnout (to), mít (čas), vystudovat (školu), přijímat (procento))
            {
                $f->{other}{valency} = 'acc';
            }
            elsif($d eq '1') # (a genitiv: vodpovědět (bez přípravy na votázku), vymazat (to z třídní knihy), ušetřit (na auto z platu))
            {
                $f->{other}{valency} = 'acc+gen';
            }
            elsif($d eq '2') # (a instrumentál: dělat (něco s tim), dosáhnout (něco s nima), vyto (to před náma), získat (prostředky jinými formami))
            {
                $f->{other}{valency} = 'acc+ins';
            }
            elsif($d eq '3') # (a lokativ: vychovaj (lidi v tom), říct (todleto vo mně), postavit (manželství na základech), mluvit (vo tom hodinu))
            {
                $f->{other}{valency} = 'acc+loc';
            }
            elsif($d eq '4') # (a akuzativ: vést (dialog přes třetí osobu), máš (to samozřejmý), svádět (to na bolševiky), nabalovat (ty na kterej))
            {
                $f->{other}{valency} = 'acc+acc';
            }
            elsif($d eq '5') # (a dativ: věnovat (tomu čas), vysvětlit (to jim), přidat (někomu stovku), ubrat (herci stovku), hnát (lidi k tomu))
            {
                $f->{other}{valency} = 'acc+dat';
            }
            elsif($d eq '6') # (a adverbiále: udělat (cokoli kůli penězům), vyruš (policajta v sobotu), polapit (ho za vobojek), představit si (ženu tam))
            {
                $f->{other}{valency} = 'acc+adv';
            }
            elsif($d eq '7') # (a infinitiv: nenapadne (mě kouřit), nechat (děti vystudovat), baví (mladý poslouchat), nechat (se popíchat))
            {
                $f->{other}{valency} = 'acc+inf';
            }
            elsif($d eq '8') # (a spojka: rozvíjet (je jako), věřit (v to, že), postarat se (vo to, aby), nekouká se (na to, aby))
            {
                $f->{other}{valency} = 'acc+con';
            }
            elsif($d eq '9') # (a další 2 pády: dělat (něco vopravdu) (???); no other occurrences)
            {
                $f->{other}{valency} = 'acc+2';
            }
            elsif($d eq '0') # (jiné smíšené/trojmístné: dodělat (to částečně, než), sladit (si všechno barevně, jak chceš))
            {
                $f->{other}{valency} = 'acc+oth';
            }
        }
        elsif($c eq '3') # (nesubjektová valence s neakuzativem)
        {
            if($d eq '1') # (genitiv: ubývá (lásky), jít (do svazku), vodtrhnout se (vod většiny), nezbláznit se (do shonu), nadít se (pomoci))
            {
                $f->{other}{valency} = 'gen';
            }
            elsif($d eq '2') # (instrumentál: vrtět (ocasem), udělat se (vedoucím), rozptylovat (činností), zabývat se (situací))
            {
                $f->{other}{valency} = 'ins';
            }
            elsif($d eq '3') # (lokativ: záleží (na lidech), podílet se (na výchově), rozhodnout se (o tom), vydělávat (na tom))
            {
                $f->{other}{valency} = 'loc';
            }
            elsif($d eq '4') # (dativ: vadilo by (mně), přirovnat (k tomu), došlo (k rovnoprávnosti), pomoct (jí))
            {
                $f->{other}{valency} = 'dat';
            }
            elsif($d eq '5') # (genitiv a neakuzativ: usuzovat (z toho, že), oprostit (se vod všeho), bylo (vod předmětů až po stáje))
            {
                $f->{other}{valency} = 'gen+nac';
            }
            elsif($d eq '6') # (instrumentál a neakuzativ: učit se (s dětma do školy), mluvit (s nima vo věcech), plýtvat (nehospodárně čimkoliv))
            {
                $f->{other}{valency} = 'ins+nac';
            }
            elsif($d eq '7') # (lokativ a neakuzativ: píše se (vo tom v novinách), mluvit (vo tom víc), omezit (se v něčem))
            {
                $f->{other}{valency} = 'loc+nac';
            }
            elsif($d eq '8') # (dativ a neakuzativ: věnovat se (těmto cele), mluví se (mně blbě), nelíbilo se (tobě na Slapech))
            {
                $f->{other}{valency} = 'dat+nac';
            }
            elsif($d eq '9') # (nominativ včetně adjektiv: řídit (sama), bejt (podmínka), bejt (vohodnocená), bejt (hrdá))
            {
                $f->{other}{valency} = 'nom-nsb';
            }
            elsif($d eq '0') # (jiné smíšené/trojmístné: bejt (mně šedesát), vyrovnat se (způsobem sami ze sebou s tim))
            {
                $f->{other}{valency} = 'oth+nac';
            }
        }
        elsif($c eq '4') # (jiná nesubjektová valence)
        {
            if($d eq '1') # (adverbiále: zařadit (tim způsobem), zařadit se (někam), použít (v životě), žít (v úctě), žilo se (jak))
            {
                $f->{other}{valency} = 'adv';
            }
            elsif($d eq '2') # (infinitiv: mělo se (vyučovat), nechat si (brát), umět (pomoct), chodit (si zatrénovat))
            {
                $f->{other}{valency} = 'inf';
            }
            elsif($d eq '3') # (spojka: hodilo by se (abys), zdá se (že), představ si (že), uvažovat (že), myslelo se (že))
            {
                $f->{other}{valency} = 'con';
            }
            elsif($d eq '4') # (dvě adverbiále: chodí se (denně do práce), sednout si (zvlášť do místnosti), nepršelo (tady na Silvestra))
            {
                $f->{other}{valency} = 'adv+adv';
            }
            elsif($d eq '5') # (adverbiále a neakuzativ: vyprávělo se (o tom léta), pracovalo se (mi líp), hrát (nám tam))
            {
                $f->{other}{valency} = 'adv+nac';
            }
            elsif($d eq '6') # (adverbiále a infinitiv: jezdit (tam nakupovat), snažit se (tam vydat), nejde (už potom přitáhnout))
            {
                $f->{other}{valency} = 'adv+inf';
            }
            elsif($d eq '7') # (adverbiále a spojka: přečíst si (na pytliku, z čeho to je), uvádí se (nakonec, že), porovnávat (tolik, že))
            {
                $f->{other}{valency} = 'adv+con';
            }
            elsif($d eq '8') # (infinitiv a neakuzativ: nepodařilo se (mu naplnit), bát se (strašně mluvit), podařilo se (mi přivýst))
            {
                $f->{other}{valency} = 'inf+nac';
            }
            elsif($d eq '9') # (spojka a neakuzativ: myslej (tim, že), dokázat (si, že), říct (o okolí, že), vočekávat (vod ženy, že))
            {
                $f->{other}{valency} = 'con+nac';
            }
            elsif($d eq '0') # (jiné: říct (spousta), říct (já dělám...) [unquoted direct speech])
            {
                $f->{other}{valency} = 'oth';
            }
        }
        elsif($c eq '5') # (subjektová valence bez nesubjektové)
        {
            $f->{other}{valency} = 'nom';
        }
        elsif($c eq '6') # (subjektová a nesubjektová s akuzativem)
        {
            if($d eq '-') # (jen akuzativ)
            {
                $f->{other}{valency} = 'nom+acc';
            }
            elsif($d eq '1') # (a genitiv)
            {
                $f->{other}{valency} = 'nom+acc+gen';
            }
            elsif($d eq '2') # (a instrumentál)
            {
                $f->{other}{valency} = 'nom+acc+ins';
            }
            elsif($d eq '3') # (a lokativ)
            {
                $f->{other}{valency} = 'nom+acc+loc';
            }
            elsif($d eq '4') # (a akuzativ)
            {
                $f->{other}{valency} = 'nom+acc+acc';
            }
            elsif($d eq '5') # (a dativ)
            {
                $f->{other}{valency} = 'nom+acc+dat';
            }
            elsif($d eq '6') # (a adverbiále (včetně předložek))
            {
                $f->{other}{valency} = 'nom+acc+adv';
            }
            elsif($d eq '7') # (a infinitiv)
            {
                $f->{other}{valency} = 'nom+acc+inf';
            }
            elsif($d eq '8') # (a spojka)
            {
                $f->{other}{valency} = 'nom+acc+con';
            }
            elsif($d eq '9') # (a další 2 pády)
            {
                $f->{other}{valency} = 'nom+acc+2';
            }
            elsif($d eq '0') # (jiná (smíšená / trojmístná))
            {
                $f->{other}{valency} = 'nom+acc+oth';
            }
        }
        elsif($c eq '7') # (subjektová a nesubjektová s neakuzativem)
        {
            if($d eq '1') # (genitiv)
            {
                $f->{other}{valency} = 'nom+gen';
            }
            elsif($d eq '2') # (instrumentál (včetně adjektiv))
            {
                $f->{other}{valency} = 'nom+ins';
            }
            elsif($d eq '3') # (lokativ)
            {
                $f->{other}{valency} = 'nom+loc';
            }
            elsif($d eq '4') # (dativ)
            {
                $f->{other}{valency} = 'nom+dat';
            }
            elsif($d eq '5') # (genitiv a neakuzativ)
            {
                $f->{other}{valency} = 'nom+gen+nac';
            }
            elsif($d eq '6') # (instrumentál a neakuzativ)
            {
                $f->{other}{valency} = 'nom+ins+nac';
            }
            elsif($d eq '7') # (lokativ a neakuzativ)
            {
                $f->{other}{valency} = 'nom+loc+nac';
            }
            elsif($d eq '8') # (dativ a neakuzativ)
            {
                $f->{other}{valency} = 'nom+dat+nac';
            }
            elsif($d eq '9') # (nominativ (včetně adj. ap.))
            {
                $f->{other}{valency} = 'nom+nom';
            }
            elsif($d eq '0') # (jiné pády (smíšená, trojmístná))
            {
                $f->{other}{valency} = 'nom+othercase';
            }
        }
        elsif($c eq '8') # (subjektová a nesubjektová jiná)
        {
            if($d eq '1') # (adverbiále včetně předložkových frází)
            {
                $f->{other}{valency} = 'nom+adv';
            }
            elsif($d eq '2') # (infinitiv)
            {
                $f->{other}{valency} = 'nom+inf';
            }
            elsif($d eq '3') # (spojka)
            {
                $f->{other}{valency} = 'nom+con';
            }
            elsif($d eq '4') # (2 adverbiále)
            {
                $f->{other}{valency} = 'nom+adv+adv';
            }
            elsif($d eq '5') # (adverbiále a neakuzativ)
            {
                $f->{other}{valency} = 'nom+adv+nac';
            }
            elsif($d eq '6') # (adverbiále a infinitiv)
            {
                $f->{other}{valency} = 'nom+adv+inf';
            }
            elsif($d eq '7') # (adverbiále a spojka)
            {
                $f->{other}{valency} = 'nom+adv+con';
            }
            elsif($d eq '8') # (infinitiv a neakuzativ)
            {
                $f->{other}{valency} = 'nom+inf+nac';
            }
            elsif($d eq '9') # (spojka a neakuzativ)
            {
                $f->{other}{valency} = 'nom+con+nac';
            }
            elsif($d eq '0') # (jiné i přímá řeč)
            {
                $f->{other}{valency} = 'nom+oth';
            }
        }
    }
    # adverbs
    elsif($pos eq '6')
    {
        if($c eq '-') # (nespecifikovaná u slovesa: eště (a eště vydělali), napoprvý (nestřílím napoprvý), spolu, (kdyby spolu mladí lidé déle žili))
        {
            # default
        }
        elsif($c eq '1') # (kvantifikační nebo intenzifikační u slovesa: eště (Láďovi eště neni štyricet), absolutně (neplatí to absolutně))
        {
            $f->{other}{valency} = 'vrb-qnt';
        }
        elsif($c eq '2') # (nekvantifikační s bezpředložkovým pádem jména: akorát (měli akorát dvě ženský), přesně (mám přesně tydlety zkušenosti))
        {
            $f->{other}{valency} = 'npr-nqn';
        }
        elsif($c eq '3') # (kvantifikační s bezpředložkovým pádem jména: eště (eště vo víc dní), akorát (čuchala sem akorát olovo))
        {
            $f->{other}{valency} = 'npr-qnt';
        }
        elsif($c eq '4') # (nekvantifikační u substantiv bez předložky: akorát (akorát párek sme dostali), přesně (neseženeš přesně ty lidi))
        {
            # How the hell does this differ from '2'?
            $f->{other}{valency} = 'npr-nq4';
        }
        elsif($c eq '5') # (s adjektivem nebo adverbiem: eště (dyť sou malinký eště), fyzicky (fyzicky těžké práce))
        {
            $f->{other}{valency} = 'adj-adv';
        }
        elsif($c eq '6') # (s předložkou: zády (zády k ňákejm klukům), spolu (spolu s výchovou dětí))
        {
            $f->{other}{valency} = 'pre';
        }
        elsif($c eq '7') # (se spojkou nebo synsém.: přesně (přesně cejtěj to, co ty), dozelena (takovej ten dozelena))
        {
            $f->{other}{valency} = 'con';
        }
        elsif($c eq '8') # (s infinitivem: spolu (schopni spolu diskutovat), přesně (nemůžu přesně posoudit))
        {
            $f->{other}{valency} = 'inf';
        }
        elsif($c eq '9') # (s větou: možná (možná, že tím, dyby se zvýšily...))
        {
            $f->{other}{valency} = 'snt';
        }
        elsif($c eq '0') # (jiné (věta apod.): až (deset až patnáct tisíc ročně), možná (možná že bych se přikláněl))
        {
            $f->{other}{valency} = 'oth';
        }
    }
    # conjunctions
    elsif($pos eq '8')
    {
        if($c eq '1') # (vůči slovu: na zadek a dolu; rodičům nebo mýmu okolí; v nepříliš zralém věku, ale z objektivních příčin)
        {
            $f->{other}{valency} = 'wrd';
        }
        elsif($c eq '2') # (vůči větě: sme se sešli a řikali sme mu; povinnosti sou tvoje, ale já je dělám; budu s vámi běhat nebo pudu do soutěže)
        {
            $f->{other}{valency} = 'snt';
        }
        elsif($c eq '9') # (nelze určit: a pak vždycky ne; něco jim teda sdělit nebo ..; autorita, ale .. asi mmm)
        {
            $f->{other}{valency} = 'unk';
        }
    }
    # particles
    elsif($pos eq '0')
    {
        if($c eq '1') # (adpropoziční zač.: .. asi si ..; že taky nekoupí nic; spíš si myslim)
        {
            $f->{other}{valency} = 'pro-beg';
        }
        elsif($c eq '2') # (adpropoziční konc.: tak tam taky pudem, asi; to určitě přispělo k tomu taky; kolem sto čtyřiceti korun snad)
        {
            $f->{other}{valency} = 'pro-end';
        }
        elsif($c eq '3') # (adpropoziční jiná: to bych asi neměla; menčí taky kapacita plic; bojuje a snad částečně úspěšně)
        {
            $f->{other}{valency} = 'pro-oth';
        }
        elsif($c eq '4') # (adlexémová zač.: asi tisic dvě stě let; taky nekoupí; spíš pes a Tonda)
        {
            $f->{other}{valency} = 'lex-beg';
        }
        elsif($c eq '5') # (adlexémová konc.: matika taky; několik asi; ňáká francouzská značka snad)
        {
            $f->{other}{valency} = 'lex-end';
        }
        elsif($c eq '6') # (adlexémová jiná: dneska je asi důvod jiný; která je taky tabuizovaná; nebo spíš, spíš hudby)
        {
            $f->{other}{valency} = 'lex-oth';
        }
        elsif($c eq '7') # (jiná nebo neurčeno: asi jak chválit za něco; co se týče jazyků, taky asi, pokud teda)
        {
            $f->{other}{valency} = 'oth';
        }
    }
    # idioms: substantive valency
    elsif($pos eq 'F2')
    {
        if($c eq '0') # (bez valence: změny k lepšímu; zlatou svatbu; motor (hnací motor a stimul))
        {
            # default
        }
        elsif($c eq '1') # (pád bez předložky (???): mít vliv; mít k sobě blíž; být doma (= nepracovat); mít děti; obejít se bez něčeho)
        {
            $f->{other}{valency} = 'npr';
        }
        elsif($c eq '2') # (s předložkou: vzít sebou; pochopení pro mě; pudou nahoru; udělat něco pro ty děti)
        {
            $f->{other}{valency} = 'pre';
        }
        elsif($c eq '3') # (se spojkou (???): vývojem vědy a techniky; samozřejmostí správců učeben a správců laboratoří)
        {
            $f->{other}{valency} = 'con';
        }
        elsif($c eq '4') # (s infinitivem: dát pozor (???); mít právo, aby (???))
        {
            $f->{other}{valency} = 'inf';
        }
        elsif($c eq '5') # (s adverbiem: maj daleko; hodně dalších výskytů, ale jsou divné)
        {
            $f->{other}{valency} = 'adv';
        }
        elsif($c eq '6') # (bez předložky dva pády: má ráda Komárka; mám na mysli ten film; dám to trochu do pořádku)
        {
            $f->{other}{valency} = 'npr+npr';
        }
        elsif($c eq '7') # (pád a předložka: jí mám dát na zadek; ze kterejch by měl radost; to je na úkor té emancipace)
        {
            $f->{other}{valency} = 'npr+pre';
        }
        elsif($c eq '8') # (pád a spojka: nemáš, kdo by ti je držel; si říkaj za zády:; mohou říct, tak tohleto ten člověk vytvořil)
        {
            $f->{other}{valency} = 'npr+con';
        }
        elsif($c eq '9') # (jiné, 2 předložky nebo 3 pády: pro sebe a pro jiné tím pádem; tady u nich; a tak dále)
        {
            $f->{other}{valency} = 'oth';
        }
    }
    # idioms: adjectival valency
    elsif($pos eq 'F3')
    {
        if($c eq '0') # (bez valence v atributu: jako (vo ženu jako takovou); úrovni (na ňáký slušný úrovni); ten (pán ten a ten))
        {
            $f->{other}{valency} = 'atr';
        }
        elsif($c eq '1') # (bez valence v predikátu: života (je vodtržená vod života); zpitá (byla zpitá na mol); nahňácaný (sedíme na sebe nahňácaný))
        {
            $f->{other}{valency} = 'prd';
        }
        elsif($c eq '2') # (pád bez předložky v predikátu: žádný výskyt)
        {
            $f->{other}{valency} = 'prd-npr';
        }
        elsif($c eq '3') # (s předložkou v predikátu: žádný výskyt)
        {
            $f->{other}{valency} = 'prd-pre';
        }
        elsif($c eq '4') # (se spojkou: žádný výskyt)
        {
            $f->{other}{valency} = 'con';
        }
        elsif($c eq '5') # (s infinitivem: žádný výskyt)
        {
            $f->{other}{valency} = 'inf';
        }
        elsif($c eq '8') # (jiné: jako (vo systému jako takovym); pohled (taková roztomilá bytost na první pohled); takovej (strach jako takovej))
        {
            $f->{other}{valency} = 'oth';
        }
    }
    # idioms: adverbial valency
    elsif($pos eq 'F4')
    {
        if($c eq '-') # (nespecifikovaná u slovesa: způsobem (kerý se ňákym způsobem rozlišujou); u (zrovna tak je to u mě))
        {
            # default;
        }
        elsif($c eq '1') # (kvantifikační nebo intenzifikační u slovesa: životě (asi jednou v životě); případě (v každém případě dokážou))
        {
            $f->{other}{valency} = 'vrb-qnt';
        }
        elsif($c eq '2') # (nepředložkový pád, nekvantifikační: pohodě (my v krásný pohodě))
        {
            $f->{other}{valency} = 'npr-nqn';
        }
        elsif($c eq '3') # (kvantifikační u jmen: cenu (shonu po penězích za každou cenu); většině (ve většině rodinách))
        {
            $f->{other}{valency} = 'nou-qnt';
        }
        elsif($c eq '4') # (nekvantifikační u substantiv: u (to neni jenom u nás na podniku); podstatě (to je v podstatě prostředí školy))
        {
            $f->{other}{valency} = 'nou-nqn';
        }
        elsif($c eq '5') # (s adjektivem nebo adverbiem: způsobem (ňákym způsobem úspěšná); tak (tak ňák hezký))
        {
            $f->{other}{valency} = 'adj-adv';
        }
        elsif($c eq '6') # (s předložkou: u (mysliš u mě na pracovišti); podstatě (děti se vychovávaj v podstatě vod půl roku))
        {
            $f->{other}{valency} = 'pre';
        }
        elsif($c eq '7') # (se spojkou / synsém.: podstatě (v podstatě nic, nó to by); tak (dycky jich tak ňák je tak ňák to,))
        {
            $f->{other}{valency} = 'con';
        }
        elsif($c eq '8') # (s infinitivem: způsobem (nemaj ňákym způsobem možnost vybít); tak (tak a tak ta věc má vypadat))
        {
            $f->{other}{valency} = 'inf';
        }
        elsif($c eq '9') # (s větou: u (u mě teda byl v tom, že); podstatě (ale v podstatě na to nejsem zvyklá))
        {
            $f->{other}{valency} = 'snt';
        }
        elsif($c eq '0') # (jiné, věta aj.: tak (tý vteřiny, jo, nebo tak ňák, já vim); míře (nemyslim, že v takový míře, protože ty lidi))
        {
            $f->{other}{valency} = 'oth';
        }
    }
    # idioms: propositional valency
    elsif($pos eq 'F5')
    {
        if($c eq '1') # (bez valence k propozici: nevim (já nevim ten plán); no (no a jedno ke druhému))
        {
            # default
        }
        elsif($c eq '2') # (spojení s propozicí: je (jak u nás je známo, tak je to tak, že prostě))
        {
            $f->{other}{valency} = 'pro';
        }
    }
}



#------------------------------------------------------------------------------
# Encodes valency (valence) as a string.
# Note that valency, as it seems to be defined by the corpus annotation, does
# not distinguish obligatory arguments from optional adjuncts. It simply
# denotes the type of the dependent node in the particular sentence. It is thus
# a property of the word in context, rather than of the lexical unit.
#------------------------------------------------------------------------------
sub encode_valency
{
    my $pos = shift; # digit or letter from the physical tag
    my $f = shift; # reference to hash
    my $c;
    # nouns
    if($pos eq '1')
    {
        if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{valency}))
        {
            if($f->{other}{valency} eq 'npr') # (s bezpředložkovým pádem: fůra, května, rok, revizi, zdroje)
            {
                $c = '1';
            }
            elsif($f->{other}{valency} eq 'pre') # (s předložkou: díru, kamna, smlouva, subdodavatele, modernizace)
            {
                $c = '2';
            }
            elsif($f->{other}{valency} eq 'con') # (se spojovacím výrazem (včetně relativ): práci, lazar, člověk, dlaždičky, mapy)
            {
                $c = '3';
            }
            elsif($f->{other}{valency} eq 'inf') # (s infinitivem: možnost, příležitost, čas, rozdíl, snaha)
            {
                $c = '4';
            }
            elsif($f->{other}{valency} eq 'adv') # (s adverbiem: hodin (denně), životem (předtim), starost (navíc), moc (shora), prací (doma))
            {
                $c = '5';
            }
            elsif($f->{other}{valency} eq 'npr+npr') # (se dvěma bezpředložkovými pády: stanice (metra Dejvická), přetížení (dětí učivem), věnování se (rodičů dětem))
            {
                $c = '6';
            }
            elsif($f->{other}{valency} eq 'npr+pre') # (s bezpředložkovým a předložkovým pádem: kontakt (dětí s vostatníma), výchovu (dětí v rodině), vztah (dítěte k rodině))
            {
                $c = '7';
            }
            elsif($f->{other}{valency} eq 'npr+con') # (s bezpředložkovým pádem a spojkou: spolčení (jeden proti druhému, aby), podmínky (k tomu, aby), mládí (dítěte, kdy))
            {
                $c = '8';
            }
            elsif($f->{other}{valency} eq 'oth') # (jiné a vícečetné: příklad (, kdy), pracovník (, jako je..., kterej...), záruka (, že))
            {
                $c = '9';
            }
            else # (bez valence: zařazení, ohodnocení, vzdělání, věc, lidi)
            {
                $c = '0';
            }
        }
        else # $f->{other}{valency} undefined
        {
            $c = '0';
        }
    }
    # adjectives
    elsif($pos eq '2')
    {
        if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{valency}))
        {
            if($f->{other}{valency} eq 'npr') # (s pádem bez předložky v predikátu: vytvořený (závodem), vychovávaná (třicátníky), plný (jich), adekvátní (tomu))
            {
                $c = '2';
            }
            elsif($f->{other}{valency} eq 'pre') # (s předložkovým pádem v predikátu: spokojený (v práci), nevšímaví (ke všemu), spokojená (s prostředim))
            {
                $c = '3';
            }
            elsif($f->{other}{valency} eq 'con') # (se spojkou: rádi (že), přesvědčená (že), hodnější (než), posuzovanej (jako), vyšší (než))
            {
                $c = '4';
            }
            elsif($f->{other}{valency} eq 'inf') # (s infinitivem: nutný (vykonávat), možný (měnit), povolený (řikat), schopnej (říct), zvyklý (bejt))
            {
                $c = '5';
            }
            else # (jiné nebo neurčitelné: otevřený, nemyslitelné, nového, nastudovaného, připravený)
            {
                $c = '8';
            }
        }
        else # $f->{other}{valency} undefined
        {
            if($f->{synpos} eq 'pred') # (bez valence v predikátu: dobrý, solidní, zlí, vobtížný, schopný)
            {
                $c = '1';
            }
            else # (bez valence v atributu: vysoká, šeredný, mladí, naprostou, nezkušený)
            {
                $c = '0';
            }
        }
    }
    # pronouns
    elsif($pos eq '3')
    {
        if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{valency}))
        {
            if($f->{other}{valency} eq 'npr') # (s bezpředložkovým pádem: tudle (otázku) (???), naše (společnost) (???), některý (ženský) (???))
            {
                $c = '1';
            }
            elsif($f->{other}{valency} eq 'pre') # (s předložkovým pádem: sám (vod sebe), každej (z nás), málokterý (z rodičů), málokdo (z nich), někoho (nad hrobem))
            {
                $c = '2';
            }
            elsif($f->{other}{valency} eq 'con') # (s podřadící spojkou: tom (jesi), tom (kolik), takový (jak), toho (na jaký))
            {
                $c = '3';
            }
            elsif($f->{other}{valency} eq 'oth') # (jiné: co, který, ten (že), čem, to (vo čem))
            {
                $c = '4';
            }
        }
        else # (bez valence: sám, tom, my, všechno, jim)
        {
            $c = '0';
        }
    }
    # numerals
    elsif($pos eq '4')
    {
        if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{valency}))
        {
            if($f->{other}{valency} eq 'npr') # (s bezpředložkovým pádem: vosum (hodin), dva (buřty), tři (krajíce), jedenáct (let), čtyřiceti (letech))
            {
                $c = '1';
            }
            elsif($f->{other}{valency} eq 'pre') # (s předložkou: jedním (z důvodů), jednou (za čtyři roky), dvě (z možností), jeden (z kořenů), čtvrt (na devět))
            {
                $c = '2';
            }
            elsif($f->{other}{valency} eq 'oth') # (jiná: jedenáct (večer), jednou (tak velkej), (těch) devět (co jsme), pět (který), tří (v Praze))
            {
                $c = '3';
            }
        }
        else # (bez valence samostatná: tolik, druhejm, jednou, vobojí, jedno)
        {
            $c = '0';
        }
    }
    # verbs and verbal idioms
    elsif($pos eq '5' || $pos eq 'F1')
    {
        if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{valency}))
        {
            if($f->{other}{valency} eq 'acc') # (jen akuzativ: dělat (tohleto), stihnout (to), mít (čas), vystudovat (školu), přijímat (procento))
            {
                $c = '2-';
            }
            elsif($f->{other}{valency} eq 'acc+gen') # (a genitiv: vodpovědět (bez přípravy na votázku), vymazat (to z třídní knihy), ušetřit (na auto z platu))
            {
                $c = '21';
            }
            elsif($f->{other}{valency} eq 'acc+ins') # (a instrumentál: dělat (něco s tim), dosáhnout (něco s nima), vyto (to před náma), získat (prostředky jinými formami))
            {
                $c = '22';
            }
            elsif($f->{other}{valency} eq 'acc+loc') # (a lokativ: vychovaj (lidi v tom), říct (todleto vo mně), postavit (manželství na základech), mluvit (vo tom hodinu))
            {
                $c = '23';
            }
            elsif($f->{other}{valency} eq 'acc+acc') # (a akuzativ: vést (dialog přes třetí osobu), máš (to samozřejmý), svádět (to na bolševiky), nabalovat (ty na kterej))
            {
                $c = '24';
            }
            elsif($f->{other}{valency} eq 'acc+dat') # (a dativ: věnovat (tomu čas), vysvětlit (to jim), přidat (někomu stovku), ubrat (herci stovku), hnát (lidi k tomu))
            {
                $c = '25';
            }
            elsif($f->{other}{valency} eq 'acc+adv') # (a adverbiále: udělat (cokoli kůli penězům), vyruš (policajta v sobotu), polapit (ho za vobojek), představit si (ženu tam))
            {
                $c = '26';
            }
            elsif($f->{other}{valency} eq 'acc+inf') # (a infinitiv: nenapadne (mě kouřit), nechat (děti vystudovat), baví (mladý poslouchat), nechat (se popíchat))
            {
                $c = '27';
            }
            elsif($f->{other}{valency} eq 'acc+con') # (a spojka: rozvíjet (je jako), věřit (v to, že), postarat se (vo to, aby), nekouká se (na to, aby))
            {
                $c = '28';
            }
            elsif($f->{other}{valency} eq 'acc+2') # (a další 2 pády: dělat (něco vopravdu) (???); no other occurrences)
            {
                $c = '29';
            }
            elsif($f->{other}{valency} eq 'acc+oth') # (jiné smíšené/trojmístné: dodělat (to částečně, než), sladit (si všechno barevně, jak chceš))
            {
                $c = '20';
            }
            elsif($f->{other}{valency} eq 'gen') # (genitiv: ubývá (lásky), jít (do svazku), vodtrhnout se (vod většiny), nezbláznit se (do shonu), nadít se (pomoci))
            {
                $c = '31';
            }
            elsif($f->{other}{valency} eq 'ins') # (instrumentál: vrtět (ocasem), udělat se (vedoucím), rozptylovat (činností), zabývat se (situací))
            {
                $c = '32';
            }
            elsif($f->{other}{valency} eq 'loc') # (lokativ: záleží (na lidech), podílet se (na výchově), rozhodnout se (o tom), vydělávat (na tom))
            {
                $c = '33';
            }
            elsif($f->{other}{valency} eq 'dat') # (dativ: vadilo by (mně), přirovnat (k tomu), došlo (k rovnoprávnosti), pomoct (jí))
            {
                $c = '34';
            }
            elsif($f->{other}{valency} eq 'gen+nac') # (genitiv a neakuzativ: usuzovat (z toho, že), oprostit (se vod všeho), bylo (vod předmětů až po stáje))
            {
                $c = '35';
            }
            elsif($f->{other}{valency} eq 'ins+nac') # (instrumentál a neakuzativ: učit se (s dětma do školy), mluvit (s nima vo věcech), plýtvat (nehospodárně čimkoliv))
            {
                $c = '36';
            }
            elsif($f->{other}{valency} eq 'loc+nac') # (lokativ a neakuzativ: píše se (vo tom v novinách), mluvit (vo tom víc), omezit (se v něčem))
            {
                $c = '37';
            }
            elsif($f->{other}{valency} eq 'dat+nac') # (dativ a neakuzativ: věnovat se (těmto cele), mluví se (mně blbě), nelíbilo se (tobě na Slapech))
            {
                $c = '38';
            }
            elsif($f->{other}{valency} eq 'nom-nsb') # (nominativ včetně adjektiv: řídit (sama), bejt (podmínka), bejt (vohodnocená), bejt (hrdá))
            {
                $c = '39';
            }
            elsif($f->{other}{valency} eq 'oth+nac') # (jiné smíšené/trojmístné: bejt (mně šedesát), vyrovnat se (způsobem sami ze sebou s tim))
            {
                $c = '30';
            }
            elsif($f->{other}{valency} eq 'adv') # (adverbiále: zařadit (tim způsobem), zařadit se (někam), použít (v životě), žít (v úctě), žilo se (jak))
            {
                $c = '41';
            }
            elsif($f->{other}{valency} eq 'inf') # (infinitiv: mělo se (vyučovat), nechat si (brát), umět (pomoct), chodit (si zatrénovat))
            {
                $c = '42';
            }
            elsif($f->{other}{valency} eq 'con') # (spojka: hodilo by se (abys), zdá se (že), představ si (že), uvažovat (že), myslelo se (že))
            {
                $c = '43';
            }
            elsif($f->{other}{valency} eq 'adv+adv') # (dvě adverbiále: chodí se (denně do práce), sednout si (zvlášť do místnosti), nepršelo (tady na Silvestra))
            {
                $c = '44';
            }
            elsif($f->{other}{valency} eq 'adv+nac') # (adverbiále a neakuzativ: vyprávělo se (o tom léta), pracovalo se (mi líp), hrát (nám tam))
            {
                $c = '45';
            }
            elsif($f->{other}{valency} eq 'adv+inf') # (adverbiále a infinitiv: jezdit (tam nakupovat), snažit se (tam vydat), nejde (už potom přitáhnout))
            {
                $c = '46';
            }
            elsif($f->{other}{valency} eq 'adv+con') # (adverbiále a spojka: přečíst si (na pytliku, z čeho to je), uvádí se (nakonec, že), porovnávat (tolik, že))
            {
                $c = '47';
            }
            elsif($f->{other}{valency} eq 'inf+nac') # (infinitiv a neakuzativ: nepodařilo se (mu naplnit), bát se (strašně mluvit), podařilo se (mi přivýst))
            {
                $c = '48';
            }
            elsif($f->{other}{valency} eq 'con+nac') # (spojka a neakuzativ: myslej (tim, že), dokázat (si, že), říct (o okolí, že), vočekávat (vod ženy, že))
            {
                $c = '49';
            }
            elsif($f->{other}{valency} eq 'oth') # (jiné: říct (spousta), říct (já dělám...) [unquoted direct speech])
            {
                $c = '40';
            }
            elsif($f->{other}{valency} eq 'nom') # (subjektová valence bez nesubjektové)
            {
                $c = '5-';
            }
            elsif($f->{other}{valency} eq 'nom+acc') # (subjektová a nesubjektová s akuzativem)
            {
                $c = '6-';
            }
            elsif($f->{other}{valency} eq 'nom+acc+gen') # (subjekt, akuzativ a genitiv)
            {
                $c = '61';
            }
            elsif($f->{other}{valency} eq 'nom+acc+ins') # (subjekt, akuzativ a instrumentál)
            {
                $c = '62';
            }
            elsif($f->{other}{valency} eq 'nom+acc+loc') # (subjekt, akuzativ a lokativ)
            {
                $c = '63';
            }
            elsif($f->{other}{valency} eq 'nom+acc+acc') # (subjekt, akuzativ a akuzativ)
            {
                $c = '64';
            }
            elsif($f->{other}{valency} eq 'nom+acc+dat') # (subjekt, akuzativ a dativ)
            {
                $c = '65';
            }
            elsif($f->{other}{valency} eq 'nom+acc+adv') # (subjekt, akuzativ a adverbiále)
            {
                $c = '66';
            }
            elsif($f->{other}{valency} eq 'nom+acc+inf') # (subjekt, akuzativ a infinitiv)
            {
                $c = '67';
            }
            elsif($f->{other}{valency} eq 'nom+acc+con') # (subjekt, akuzativ a spojka)
            {
                $c = '68';
            }
            elsif($f->{other}{valency} eq 'nom+acc+2') # (subjekt, akuzativ a další 2 pády)
            {
                $c = '69';
            }
            elsif($f->{other}{valency} eq 'nom+acc+oth') # (subjekt, akuzativ a jiná, smíšená nebo trojmístná)
            {
                $c = '60';
            }
            elsif($f->{other}{valency} eq 'nom+gen') # (subjekt a genitiv)
            {
                $c = '71';
            }
            elsif($f->{other}{valency} eq 'nom+ins') # (subjekt a instrumentál)
            {
                $c = '72';
            }
            elsif($f->{other}{valency} eq 'nom+loc') # (subjekt a lokativ)
            {
                $c = '73';
            }
            elsif($f->{other}{valency} eq 'nom+dat') # (subjekt a dativ)
            {
                $c = '74';
            }
            elsif($f->{other}{valency} eq 'nom+gen+nac') # (subjekt, genitiv a neakuzativ)
            {
                $c = '75';
            }
            elsif($f->{other}{valency} eq 'nom+ins+nac') # (subjekt, instrumentál a neakuzativ)
            {
                $c = '76';
            }
            elsif($f->{other}{valency} eq 'nom+loc+nac') # (subjekt, lokativ a neakuzativ)
            {
                $c = '77';
            }
            elsif($f->{other}{valency} eq 'nom+dat+nac') # (subjekt, dativ a neakuzativ)
            {
                $c = '78';
            }
            elsif($f->{other}{valency} eq 'nom+nom') # (subjekt a nominativ)
            {
                $c = '79';
            }
            elsif($f->{other}{valency} eq 'nom+othercase') # (subjekt a jiné pády)
            {
                $c = '70';
            }
            elsif($f->{other}{valency} eq 'nom+adv') # (subjekt a adverbiále)
            {
                $c = '81';
            }
            elsif($f->{other}{valency} eq 'nom+inf') # (subjekt a infinitiv)
            {
                $c = '82';
            }
            elsif($f->{other}{valency} eq 'nom+con') # (subjekt a spojka)
            {
                $c = '83';
            }
            elsif($f->{other}{valency} eq 'nom+adv+adv') # (subjekt a 2 adverbiále)
            {
                $c = '84';
            }
            elsif($f->{other}{valency} eq 'nom+adv+nac') # (subjekt, adverbiále a neakuzativ)
            {
                $c = '85';
            }
            elsif($f->{other}{valency} eq 'nom+adv+inf') # (subjekt, adverbiále a infinitiv)
            {
                $c = '86';
            }
            elsif($f->{other}{valency} eq 'nom+adv+con') # (subjekt, adverbiále a spojka)
            {
                $c = '87';
            }
            elsif($f->{other}{valency} eq 'nom+inf+nac') # (subjekt, infinitiv a neakuzativ)
            {
                $c = '88';
            }
            elsif($f->{other}{valency} eq 'nom+con+nac') # (subjekt, spojka a neakuzativ)
            {
                $c = '89';
            }
            elsif($f->{other}{valency} eq 'nom+oth') # (subjekt a jiné, i přímá řeč)
            {
                $c = '80';
            }
        }
        else # (nerealizovaná subjektová valence, zřejmě hlavně u infinitivů: vzdělávat se, dejchat, nehýřit, rozšířit, stihnout)
        {
            $c = '1-';
        }
    }
    # adverbs
    elsif($pos eq '6')
    {
        if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{valency}))
        {
            if($f->{other}{valency} eq 'vrb-qnt') # (kvantifikační nebo intenzifikační u slovesa: eště (Láďovi eště neni štyricet), absolutně (neplatí to absolutně))
            {
                $c = '1';
            }
            elsif($f->{other}{valency} eq 'npr-nqn') # (nekvantifikační s bezpředložkovým pádem jména: akorát (měli akorát dvě ženský), přesně (mám přesně tydlety zkušenosti))
            {
                $c = '2';
            }
            elsif($f->{other}{valency} eq 'npr-qnt') # (kvantifikační s bezpředložkovým pádem jména: eště (eště vo víc dní), akorát (čuchala sem akorát olovo))
            {
                $c = '3';
            }
            elsif($f->{other}{valency} eq 'npr-nq4') # (nekvantifikační u substantiv bez předložky: akorát (akorát párek sme dostali), přesně (neseženeš přesně ty lidi))
            {
                $c = '4';
            }
            elsif($f->{other}{valency} eq 'adj-adv') # (s adjektivem nebo adverbiem: eště (dyť sou malinký eště), fyzicky (fyzicky těžké práce))
            {
                $c = '5';
            }
            elsif($f->{other}{valency} eq 'pre') # (s předložkou: zády (zády k ňákejm klukům), spolu (spolu s výchovou dětí))
            {
                $c = '6';
            }
            elsif($f->{other}{valency} eq 'con') # (se spojkou nebo synsém.: přesně (přesně cejtěj to, co ty), dozelena (takovej ten dozelena))
            {
                $c = '7';
            }
            elsif($f->{other}{valency} eq 'inf') # (s infinitivem: spolu (schopni spolu diskutovat), přesně (nemůžu přesně posoudit))
            {
                $c = '8';
            }
            elsif($f->{other}{valency} eq 'snt') # (s větou: možná (možná, že tím, dyby se zvýšily...))
            {
                $c = '9';
            }
            elsif($f->{other}{valency} eq 'oth') # (jiné (věta apod.): až (deset až patnáct tisíc ročně), možná (možná že bych se přikláněl))
            {
                $c = '0';
            }
        }
        else # (nespecifikovaná u slovesa: eště (a eště vydělali), napoprvý (nestřílím napoprvý), spolu, (kdyby spolu mladí lidé déle žili))
        {
            $c = '-';
        }
    }
    # conjunctions
    elsif($pos eq '8')
    {
        if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{valency}))
        {
            if($f->{other}{valency} eq 'wrd') # (vůči slovu: na zadek a dolu; rodičům nebo mýmu okolí; v nepříliš zralém věku, ale z objektivních příčin)
            {
                $c = '1';
            }
            elsif($f->{other}{valency} eq 'snt') # (vůči větě: sme se sešli a řikali sme mu; povinnosti sou tvoje, ale já je dělám; budu s vámi běhat nebo pudu do soutěže)
            {
                $c = '2';
            }
            elsif($f->{other}{valency} eq 'unk') # (nelze určit: a pak vždycky ne; něco jim teda sdělit nebo ..; autorita, ale .. asi mmm)
            {
                $c = '9';
            }
        }
        else # $f->{other}{valency} undefined
        {
            $c = '9';
        }
    }
    # particles
    elsif($pos eq '0')
    {
        if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{valency}))
        {
            if($f->{other}{valency} eq 'pro-beg') # (adpropoziční zač.: .. asi si ..; že taky nekoupí nic; spíš si myslim)
            {
                $c = '1';
            }
            elsif($f->{other}{valency} eq 'pro-end') # (adpropoziční konc.: tak tam taky pudem, asi; to určitě přispělo k tomu taky; kolem sto čtyřiceti korun snad)
            {
                $c = '2';
            }
            elsif($f->{other}{valency} eq 'pro-oth') # (adpropoziční jiná: to bych asi neměla; menčí taky kapacita plic; bojuje a snad částečně úspěšně)
            {
                $c = '3';
            }
            elsif($f->{other}{valency} eq 'lex-beg') # (adlexémová zač.: asi tisic dvě stě let; taky nekoupí; spíš pes a Tonda)
            {
                $c = '4';
            }
            elsif($f->{other}{valency} eq 'lex-end') # (adlexémová konc.: matika taky; několik asi; ňáká francouzská značka snad)
            {
                $c = '5';
            }
            elsif($f->{other}{valency} eq 'lex-oth') # (adlexémová jiná: dneska je asi důvod jiný; která je taky tabuizovaná; nebo spíš, spíš hudby)
            {
                $c = '6';
            }
            elsif($f->{other}{valency} eq 'oth') # (jiná nebo neurčeno: asi jak chválit za něco; co se týče jazyků, taky asi, pokud teda)
            {
                $c = '7';
            }
        }
        else # $f->{other}{valency} undefined
        {
            $c = '7';
        }
    }
    # verbal idioms
    # (same as verbs, see above)
    # substantival idioms
    elsif($pos eq 'F2')
    {
        if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{valency}))
        {
            if($f->{other}{valency} eq 'npr') # (pád bez předložky (???): mít vliv; mít k sobě blíž; být doma (= nepracovat); mít děti; obejít se bez něčeho)
            {
                $c = '1';
            }
            elsif($f->{other}{valency} eq 'pre') # (s předložkou: vzít sebou; pochopení pro mě; pudou nahoru; udělat něco pro ty děti)
            {
                $c = '2';
            }
            elsif($f->{other}{valency} eq 'con') # (se spojkou (???): vývojem vědy a techniky; samozřejmostí správců učeben a správců laboratoří)
            {
                $c = '3';
            }
            elsif($f->{other}{valency} eq 'inf') # (s infinitivem: dát pozor (???); mít právo, aby (???))
            {
                $c = '4';
            }
            elsif($f->{other}{valency} eq 'adv') # (s adverbiem: maj daleko; hodně dalších výskytů, ale jsou divné)
            {
                $c = '5';
            }
            elsif($f->{other}{valency} eq 'npr+npr') # (bez předložky dva pády: má ráda Komárka; mám na mysli ten film; dám to trochu do pořádku)
            {
                $c = '6';
            }
            elsif($f->{other}{valency} eq 'npr+pre') # (pád a předložka: jí mám dát na zadek; ze kterejch by měl radost; to je na úkor té emancipace)
            {
                $c = '7';
            }
            elsif($f->{other}{valency} eq 'npr+con') # (pád a spojka: nemáš, kdo by ti je držel; si říkaj za zády:; mohou říct, tak tohleto ten člověk vytvořil)
            {
                $c = '8';
            }
            elsif($f->{other}{valency} eq 'oth') # (jiné, 2 předložky nebo 3 pády: pro sebe a pro jiné tím pádem; tady u nich; a tak dále)
            {
                $c = '9';
            }
        }
        else # (bez valence: změny k lepšímu; zlatou svatbu; motor (hnací motor a stimul))
        {
            $c = '0';
        }
        $c .= '_';
    }
    # adjectival idioms
    elsif($pos eq 'F3')
    {
        if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{valency}))
        {
            if($f->{other}{valency} eq 'atr') # (bez valence v atributu: jako (vo ženu jako takovou); úrovni (na ňáký slušný úrovni); ten (pán ten a ten))
            {
                $c = '0';
            }
            elsif($f->{other}{valency} eq 'prd') # (bez valence v predikátu: života (je vodtržená vod života); zpitá (byla zpitá na mol); nahňácaný (sedíme na sebe nahňácaný))
            {
                $c = '1';
            }
            elsif($f->{other}{valency} eq 'prd-npr') # (pád bez předložky v predikátu: žádný výskyt)
            {
                $c = '2';
            }
            elsif($f->{other}{valency} eq 'prd-pre') # (s předložkou v predikátu: žádný výskyt)
            {
                $c = '3';
            }
            elsif($f->{other}{valency} eq 'con') # (se spojkou: žádný výskyt)
            {
                $c = '4';
            }
            elsif($f->{other}{valency} eq 'inf') # (s infinitivem: žádný výskyt)
            {
                $c = '5';
            }
            elsif($f->{other}{valency} eq 'oth') # (jiné: jako (vo systému jako takovym); pohled (taková roztomilá bytost na první pohled); takovej (strach jako takovej))
            {
                $c = '8';
            }
        }
        $c .= '_';
    }
    # adverbial idioms
    elsif($pos eq 'F4')
    {
        if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{valency}))
        {
            if($f->{other}{valency} eq 'vrb-qnt')
            {
                $c = '1';
            }
            elsif($f->{other}{valency} eq 'npr-nqn') # (nepředložkový pád, nekvantifikační: pohodě (my v krásný pohodě))
            {
                $c = '2';
            }
            elsif($f->{other}{valency} eq 'nou-qnt')
            {
                $c = '3';
            }
            elsif($f->{other}{valency} eq 'nou-nqn')
            {
                $c = '4';
            }
            elsif($f->{other}{valency} eq 'adj-adv') # (s adjektivem nebo adverbiem: způsobem (ňákym způsobem úspěšná); tak (tak ňák hezký))
            {
                $c = '5';
            }
            elsif($f->{other}{valency} eq 'pre') # (s předložkou: u (mysliš u mě na pracovišti); podstatě (děti se vychovávaj v podstatě vod půl roku))
            {
                $c = '6';
            }
            elsif($f->{other}{valency} eq 'con') # (se spojkou / synsém.: podstatě (v podstatě nic, nó to by); tak (dycky jich tak ňák je tak ňák to,))
            {
                $c = '7';
            }
            elsif($f->{other}{valency} eq 'inf') # (s infinitivem: způsobem (nemaj ňákym způsobem možnost vybít); tak (tak a tak ta věc má vypadat))
            {
                $c = '8';
            }
            elsif($f->{other}{valency} eq 'snt') # (s větou: u (u mě teda byl v tom, že); podstatě (ale v podstatě na to nejsem zvyklá))
            {
                $c = '9';
            }
            elsif($f->{other}{valency} eq 'oth') # (jiné, věta aj.: tak (tý vteřiny, jo, nebo tak ňák, já vim); míře (nemyslim, že v takový míře, protože ty lidi))
            {
                $c = '0';
            }
        }
        else # (nespecifikovaná u slovesa: způsobem (kerý se ňákym způsobem rozlišujou); u (zrovna tak je to u mě))
        {
            $c = '-';
        }
        $c .= '_';
    }
    # propositional idioms
    elsif($pos eq 'F5')
    {
        if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{valency}))
        {
            if($f->{other}{valency} eq 'pro') # (spojení s propozicí: je (jak u nás je známo, tak je to tak, že prostě))
            {
                $c = '2';
            }
        }
        else # (bez valence k propozici: nevim (já nevim ten plán); no (no a jedno ke druhému))
        {
            $c = '1';
        }
        $c .= '_';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes multiwordness (víceslovnost) and resultativeness (rezultativnost) and
# stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_multiwordness_and_resultativeness
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # jednoslovné: kradou, maj, sou
    {
        # default
    }
    elsif($c eq '2') # nezvratné složené: honorována (by honorována být neměla); nepršelo (by nepršelo); bylo (by bylo třeba usměrnit)
    {
        $f->{other}{compverb} = 'comp';
    }
    ###!!! We could also use the 'reflexiveness' feature to accommodate this particular value.
    elsif($c eq '3') # zvratné nesložené: myslim (si myslim); ptej (se ptej); neboj (se neboj)
    {
        $f->{other}{compverb} = 'rflx';
    }
    elsif($c eq '4') # zvratné složené: atestovat (se bude atestovat); stávalo (by se stávalo); měla (by se měla)
    {
        $f->{other}{compverb} = 'rflx-comp';
    }
    elsif($c eq '5') # rezultativ prézens: placeno (máme placeno); maji (maji tam napsáno); votevřeno (maji votevřeno)
    {
        $f->{other}{compverb} = 'res-pres';
    }
    elsif($c eq '6') # rezultativ minulý: feminizováno (sem měl pracoviště silně feminizováno); napsáno (měli napsáno); nařízíno (měl nařízíno)
    {
        $f->{other}{compverb} = 'res-past';
    }
    elsif($c eq '7') # rezultativ budoucí: žádný výskyt
    {
        $f->{other}{compverb} = 'res-fut';
    }
    elsif($c eq '8') # rezultativ v infinitivu: vyluxováno (snažím se tam mít vyluxováno); uklizíno (musim mít prostě uklizíno)
    {
        $f->{other}{compverb} = 'res-inf';
    }
    elsif($c eq '9') # rezultativ v kondicionálu: zakázáno (že bych měla zakázáno)
    {
        $f->{other}{compverb} = 'res-cnd';
    }
}



#------------------------------------------------------------------------------
# Encodes multiwordness (víceslovnost) and resultativeness (rezultativnost) as
# a string.
#------------------------------------------------------------------------------
sub encode_multiwordness_and_resultativeness
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{compverb}))
    {
        if($f->{other}{compverb} eq 'comp') # nezvratné složené: honorována (by honorována být neměla); nepršelo (by nepršelo); bylo (by bylo třeba usměrnit)
        {
            $c = '2';
        }
        elsif($f->{other}{compverb} eq 'rflx') # zvratné nesložené: myslim (si myslim); ptej (se ptej); neboj (se neboj)
        {
            $c = '3';
        }
        elsif($f->{other}{compverb} eq 'rflx-comp') # zvratné složené: atestovat (se bude atestovat); stávalo (by se stávalo); měla (by se měla)
        {
            $c = '4';
        }
        elsif($f->{other}{compverb} eq 'res-pres') # rezultativ prézens: placeno (máme placeno); maji (maji tam napsáno); votevřeno (maji votevřeno)
        {
            $c = '5';
        }
        elsif($f->{other}{compverb} eq 'res-past') # rezultativ minulý: feminizováno (sem měl pracoviště silně feminizováno); napsáno (měli napsáno); nařízíno (měl nařízíno)
        {
            $c = '6';
        }
        elsif($f->{other}{compverb} eq 'res-fut') # rezultativ budoucí: žádný výskyt
        {
            $c = '7';
        }
        elsif($f->{other}{compverb} eq 'res-inf') # rezultativ v infinitivu: vyluxováno (snažím se tam mít vyluxováno); uklizíno (musim mít prostě uklizíno)
        {
            $c = '8';
        }
        elsif($f->{other}{compverb} eq 'res-cnd') # rezultativ v kondicionálu: zakázáno (že bych měla zakázáno)
        {
            $c = '9';
        }
    }
    else # $f->{other}{compverb} undefined
    {
        $c = '1';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes sentential modus (modus věty) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_sentmod
{
    my $c = shift; # string
    my $f = shift; # reference to hash
    if($c eq '1') # konstatovací nebo oznamovací: asi; taky (že taky nekoupí nic); spíš (spíš si myslim)
    {
        $f->{other}{sentmod} = 'ind';
    }
    elsif($c eq '2') # tázací: asi (který by to mohly bejt, asi?); snad (chceš snad tvrdit, že); taky (Zuzana taky chtěla?)
    {
        $f->{other}{sentmod} = 'int';
    }
    elsif($c eq '3') # imperativní nebo zvolací: taky (no ty taky!); asi (voni asi určitě začnou!?); dyť (dyť si chtěla sama řídit, né?)
    {
        $f->{other}{sentmod} = 'imp';
    }
    elsif($c eq '4') # jiný nebo smíšený: snad (snad neni počůraná); tak (já nevim no, tak..); sotva (a sotva ta rovnoprávnost kdy bude)
    {
        # default
    }
}



#------------------------------------------------------------------------------
# Encodes sentential modus (modus věty) as a string.
#------------------------------------------------------------------------------
sub encode_sentmod
{
    my $f = shift; # reference to hash
    my $c;
    if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{sentmod}))
    {
        if($f->{other}{sentmod} eq 'ind') # konstatovací nebo oznamovací: asi; taky (že taky nekoupí nic); spíš (spíš si myslim)
        {
            $c = '1';
        }
        elsif($f->{other}{sentmod} eq 'int') # tázací: asi (který by to mohly bejt, asi?); snad (chceš snad tvrdit, že); taky (Zuzana taky chtěla?)
        {
            $c = '2';
        }
        elsif($f->{other}{sentmod} eq 'imp') # imperativní nebo zvolací: taky (no ty taky!); asi (voni asi určitě začnou!?); dyť (dyť si chtěla sama řídit, né?)
        {
            $c = '3';
        }
    }
    else # jiný nebo smíšený: snad (snad neni počůraná); tak (já nevim no, tak..); sotva (a sotva ta rovnoprávnost kdy bude)
    {
        $c = '4';
    }
    return $c;
}



#------------------------------------------------------------------------------
# Decodes function (funkce) and stores it in a feature structure.
#------------------------------------------------------------------------------
sub decode_function
{
    my $pos = shift; # digit or letter from the physical tag
    my $c = shift; # string
    my $f = shift; # reference to hash
    # nouns
    if($pos eq '1')
    {
        if($c eq '1') # subjekt: člověk (se člověk může dočíst)
        {
            $f->{other}{function} = 'subj';
        }
        elsif($c eq '2') # predikát (v širším pojetí adv. aj.): člověk (ty seš akční člověk)
        {
            $f->{other}{function} = 'pred';
        }
        elsif($c eq '3') # atribut neshodný: člověka (záleží na individualitě člověka)
        {
            $f->{other}{function} = 'atr';
        }
        elsif($c eq '4') # nevazebné příslovečné určení: kantor (jako vysokoškolskej kantor by si měla mít); partnera (u toho druhýho partnera najdou)
        {
            $f->{other}{function} = 'adv';
        }
        elsif($c eq '5') # věta vokativní: táto (povídej něco, táto taky)
        {
            $f->{other}{function} = 'vsent';
        }
        elsif($c eq '6') # věta nominativní: děda (a děda chudák, toho budou bolet nohy)
        {
            $f->{other}{function} = 'nsent';
        }
        elsif($c eq '7') # věta jiná: dědečka (ne z dědečka!)
        {
            $f->{other}{function} = 'osent';
        }
        elsif($c eq '8') # jiné: muž (má povinností mnohem víc než muž)
        {
            $f->{other}{function} = 'oth';
        }
        elsif($c eq '9') # samostatné: člověk (a člověk, dyž by vod nich něco potřeboval, tak pomalu by se jim bál něco říc)
        {
            $f->{other}{function} = 'sep';
        }
        elsif($c eq '-') # nelze určit: člověk (je prostě málo nad čim člověk tak: nebo málo co je upoutává)
        {
            # default
        }
    }
    # adjectives
    elsif($pos eq '2')
    {
        if($c eq '1') # atribut: mladej (to žádnej mladej člověk nesnáší)
        {
            $f->{other}{function} = 'atr';
        }
        elsif($c eq '2') # predikát: akční (ty seš akční člověk) (!!!)
        {
            $f->{other}{function} = 'pred';
        }
        elsif($c eq '3') # nelexikalizované v platnosti substantiva: mladší (ty mladší si řikaj)
        {
            $f->{other}{function} = 'noun';
        }
        elsif($c eq '4') # věta: vizuálnější (vizuálnější ..)
        {
            $f->{other}{function} = 'sent';
        }
        elsif($c eq '5') # jiné: svobodnej (no tak jako svobodnej, to by si se nesměl voženit a vzít si mě)
        {
            $f->{other}{function} = 'oth';
        }
    }
    # pronouns
    elsif($pos eq '3')
    {
        if($c eq '1') # samostatné: ten (a že teda ten, kterej to koupí)
        {
            $f->{other}{function} = 'sep';
        }
        elsif($c eq '2') # adjektivní: tom (záleží na tom pracovnim prostředí)
        {
            $f->{other}{function} = 'adj';
        }
        elsif($c eq '3') # v platnosti věty: to (to, co mu doposavad chybělo)
        {
            $f->{other}{function} = 'sent';
        }
        elsif($c eq '4') # jiné: tu (na tu, co má jenom jedny boty)
        {
            $f->{other}{function} = 'oth';
        }
    }
    # numerals
    elsif($pos eq '4')
    {
        if($c eq '1') # samostatná: jeden (má stálý místo jeden, dva, tři lidi; že jeden žije pro sebe)
        {
            $f->{other}{function} = 'sep';
        }
        elsif($c eq '2') # adjektivní: tři (bylo asi tři dny po pohřbu)
        {
            $f->{other}{function} = 'adj';
        }
        elsif($c eq '3') # adverbiální: tolik (muslimové maj tolik ženskejch, kolik jich uživí); čtvrt (reaguješ čtvrt vteřiny); jednou (byla jenom jednou); několikanásobně
        {
            $f->{other}{function} = 'adv';
        }
        elsif($c eq '4') # vztažná: žádný výskyt
        {
            $f->{other}{function} = 'rel';
        }
        elsif($c eq '5') # věta: žádný výskyt
        {
            $f->{other}{function} = 'sent';
        }
        elsif($c eq '6') # jiná: jedný (v půl jedný); šedesáti (úspěšnej život jinak než v šedesáti)
        {
            $f->{other}{function} = 'oth';
        }
    }
    # prepositions (left functional dependency)
    elsif($pos eq '7')
    {
        if($c eq '0') # bez řídícího výrazu: u (můžeš u toho žehlit)
        {
            $f->{other}{dependency} = 'sep';
        }
        elsif($c eq '1') # postverbální: do (pudu do soutěže); z (by se tam moh dostat z půllitru Jany); u (že by dělala u pece)
        {
            $f->{other}{dependency} = 'verb';
        }
        elsif($c eq '2') # postsubstantivní nebo postpronominální: z (skleničku, z který ráda piju); do (při cestě do malý země)
        {
            $f->{other}{dependency} = 'noun';
        }
        elsif($c eq '3') # postadjektivní: do (zašitej do peřiny); u (nepopulární u starších lidí); ze (pojišťovna nejbližší ze Žižkova)
        {
            $f->{other}{dependency} = 'adj';
        }
        elsif($c eq '4') # postadverbiální: do (potom do obchodní školy); vod (daleko vod toho autobusu); z (pryč z pracovního prostředí)
        {
            $f->{other}{dependency} = 'adv';
        }
        elsif($c eq '5') # jiná: u (jako u ženskejch); z (že z Horních); do (radši na Slapy než do Káranýho)
        {
            $f->{other}{dependency} = 'oth';
        }
    }
}



#------------------------------------------------------------------------------
# Encodes function (funkce) as a string.
#------------------------------------------------------------------------------
sub encode_function
{
    my $pos = shift; # digit or letter from the physical tag
    my $f = shift; # reference to hash
    my $c;
    # nouns
    if($pos eq '1')
    {
        if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{function}))
        {
            if($f->{other}{function} eq 'subj') # subjekt: člověk (se člověk může dočíst)
            {
                $c = '1';
            }
            elsif($f->{other}{function} eq 'pred') # predikát (v širším pojetí adv. aj.): člověk (ty seš akční člověk)
            {
                $c = '2';
            }
            elsif($f->{other}{function} eq 'atr') # atribut neshodný: člověka (záleží na individualitě člověka)
            {
                $c = '3';
            }
            elsif($f->{other}{function} eq 'adv') # nevazebné příslovečné určení: kantor (jako vysokoškolskej kantor by si měla mít); partnera (u toho druhýho partnera najdou)
            {
                $c = '4';
            }
            elsif($f->{other}{function} eq 'vsent') # věta vokativní: táto (povídej něco, táto taky)
            {
                $c = '5';
            }
            elsif($f->{other}{function} eq 'nsent') # věta nominativní: děda (a děda chudák, toho budou bolet nohy)
            {
                $c = '6';
            }
            elsif($f->{other}{function} eq 'osent') # věta jiná: dědečka (ne z dědečka!)
            {
                $c = '7';
            }
            elsif($f->{other}{function} eq 'oth') # jiné: muž (má povinností mnohem víc než muž)
            {
                $c = '8';
            }
            elsif($f->{other}{function} eq 'sep') # samostatné: člověk (a člověk, dyž by vod nich něco potřeboval, tak pomalu by se jim bál něco říc)
            {
                $c = '9';
            }
            else # nelze určit: člověk (je prostě málo nad čim člověk tak: nebo málo co je upoutává)
            {
                # default
                $c = '-';
            }
        }
    }
    # adjectives
    elsif($pos eq '2')
    {
        if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{function}))
        {
            if($f->{other}{function} eq 'atr') # atribut: mladej (to žádnej mladej člověk nesnáší)
            {
                $c = '1';
            }
            elsif($f->{other}{function} eq 'pred') # predikát: akční (ty seš akční člověk) (!!!)
            {
                $c = '2';
            }
            elsif($f->{other}{function} eq 'noun') # nelexikalizované v platnosti substantiva: mladší (ty mladší si řikaj)
            {
                $c = '3';
            }
            elsif($f->{other}{function} eq 'sent') # věta: vizuálnější (vizuálnější ..)
            {
                $c = '4';
            }
            elsif($f->{other}{function} eq 'oth') # jiné: svobodnej (no tak jako svobodnej, to by si se nesměl voženit a vzít si mě)
            {
                $c = '5';
            }
        }
    }
    # pronouns
    elsif($pos eq '3')
    {
        if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{function}))
        {
            if($f->{other}{function} eq 'sep') # samostatné: ten (a že teda ten, kterej to koupí)
            {
                $c = '1';
            }
            elsif($f->{other}{function} eq 'adj') # adjektivní: tom (záleží na tom pracovnim prostředí)
            {
                $c = '2';
            }
            elsif($f->{other}{function} eq 'sent') # v platnosti věty: to (to, co mu doposavad chybělo)
            {
                $c = '3';
            }
            elsif($f->{other}{function} eq 'oth') # jiné: tu (na tu, co má jenom jedny boty)
            {
                $c = '4';
            }
        }
    }
    # numerals
    elsif($pos eq '4')
    {
        if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{function}))
        {
            if($f->{other}{function} eq 'sep') # samostatná: jeden (má stálý místo jeden, dva, tři lidi; že jeden žije pro sebe)
            {
                $c = '1';
            }
            elsif($f->{other}{function} eq 'adj') # adjektivní: tři (bylo asi tři dny po pohřbu)
            {
                $c = '2';
            }
            elsif($f->{other}{function} eq 'adv') # adverbiální: tolik (muslimové maj tolik ženskejch, kolik jich uživí); čtvrt (reaguješ čtvrt vteřiny); jednou (byla jenom jednou); několikanásobně
            {
                $c = '3';
            }
            elsif($f->{other}{function} eq 'rel') # vztažná: žádný výskyt
            {
                $c = '4';
            }
            elsif($f->{other}{function} eq 'sent') # věta: žádný výskyt
            {
                $c = '5';
            }
            elsif($f->{other}{function} eq 'oth') # jiná: jedný (v půl jedný); šedesáti (úspěšnej život jinak než v šedesáti)
            {
                $c = '6';
            }
        }
    }
    # prepositions (left functional dependency)
    elsif($pos eq '7')
    {
        if($f->{tagset} eq 'cs::pmk' && exists($f->{other}{dependency}))
        {
            if($f->{other}{dependency} eq 'sep') # bez řídícího výrazu: u (můžeš u toho žehlit)
            {
                $c = '0';
            }
            elsif($f->{other}{dependency} eq 'verb') # postverbální: do (pudu do soutěže); z (by se tam moh dostat z půllitru Jany); u (že by dělala u pece)
            {
                $c = '1';
            }
            elsif($f->{other}{dependency} eq 'noun') # postsubstantivní nebo postpronominální: z (skleničku, z který ráda piju); do (při cestě do malý země)
            {
                $c = '2';
            }
            elsif($f->{other}{dependency} eq 'adj') # postadjektivní: do (zašitej do peřiny); u (nepopulární u starších lidí); ze (pojišťovna nejbližší ze Žižkova)
            {
                $c = '3';
            }
            elsif($f->{other}{dependency} eq 'adv') # postadverbiální: do (potom do obchodní školy); vod (daleko vod toho autobusu); z (pryč z pracovního prostředí)
            {
                $c = '4';
            }
            elsif($f->{other}{dependency} eq 'oth') # jiná: u (jako u ženskejch); z (že z Horních); do (radši na Slapy než do Káranýho)
            {
                $c = '5';
            }
        }
    }
}



1;
