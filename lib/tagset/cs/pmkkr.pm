#!/usr/bin/perl
# Driver for the short version of the tagset of the Pražský mluvený korpus (Prague Spoken Corpus) of Czech.
# Copyright © 2009, 2010 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::cs::pmkkr;
use utf8;
use tagset::common;
use tagset::cs::pmk;



# We take as one tag the section of XML where features of one word are described.
# It is a string without whitespace characters.
# It begins with '<i1>'. It typically ends with '</i11>' (the '_dl' part of the
# corpus) or '</i4>' (the '_kr' part of the corpus). Every <iN> element contains
# a value of one feature; the values are mostly numbers, sometimes also letters.
# Example: '<i1>1</i1><i2>1</i2><i3>1</i3><i4>1</i4>' means "noun, common, person,
# no valency".



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = 'cs::pmk';
    # Convert the tag to an array of values.
    my $tag1 = $tag;
    my @values;
    while($tag1 =~ s/^<i(\d+)>(.*?)<\/i\1>//)
    {
        my $position = $1;
        my $value = $2;
        $values[$position] = $value;
    }
    # pos
    my $pos = $values[1];
    # substantivum = noun
    if($pos==1)
    {
        $f{pos} = 'noun';
        # 2. druh
        tagset::cs::pmk::decode_noun_type($values[2], \%f);
        # 3. rod
        tagset::cs::pmk::decode_gender($pos, $values[3], \%f);
        # 4. styl
        tagset::cs::pmk::decode_style($values[4], \%f);
    }
    # adjektivum = adjective
    elsif($pos==2)
    {
        $f{pos} = 'adj';
        # 2. druh
        tagset::cs::pmk::decode_adjective_type($values[2], \%f);
        # 3. poddruh
        tagset::cs::pmk::decode_adjective_subtype($values[3], \%f);
        # 4. styl
        tagset::cs::pmk::decode_style($values[4], \%f);
    }
    # zájmeno = pronoun
    elsif($pos==3)
    {
        $f{pos} = 'noun';
        $f{prontype} = 'prs';
        # 2. druh
        tagset::cs::pmk::decode_pronoun_type($values[2], \%f);
        # 3. _
        # 4. styl
        tagset::cs::pmk::decode_style($values[4], \%f);
    }
    # číslovka = numeral
    elsif($pos==4)
    {
        $f{pos} = 'num';
        # 2. druh
        tagset::cs::pmk::decode_numeral_type($values[2], \%f);
        # 3. _
        # 4. styl
        tagset::cs::pmk::decode_style($values[4], \%f);
    }
    # sloveso = verb
    elsif($pos==5)
    {
        $f{pos} = 'verb';
        # 2. víceslovnost a rezultativnost
        tagset::cs::pmk::decode_multiwordness_and_resultativeness($values[2], \%f);
        # 3. zápor
        tagset::cs::pmk::decode_negativeness($values[3], \%f);
        # 4. styl
        tagset::cs::pmk::decode_style($values[4], \%f);
    }
    # adverbium = adverb
    elsif($pos==6)
    {
        $f{pos} = 'adv';
        # 2. druh
        tagset::cs::pmk::decode_adverb_type($values[2], \%f);
        # 3. _
        # 4. styl
        tagset::cs::pmk::decode_style($values[4], \%f);
    }
    # předložka = preposition
    elsif($pos==7)
    {
        $f{pos} = 'prep';
        # 2. druh
        tagset::cs::pmk::decode_preposition_type($values[2], \%f);
        # 3. _
        # 4. styl
        tagset::cs::pmk::decode_style($values[4], \%f);
    }
    # spojka = conjunction
    elsif($pos==8)
    {
        $f{pos} = 'conj';
        # 2. druh
        tagset::cs::pmk::decode_conjunction_type($values[2], \%f);
        # 3. _
        # 4. styl
        tagset::cs::pmk::decode_style($values[4], \%f);
    }
    # citoslovce = interjection
    elsif($pos==9)
    {
        $f{pos} = 'int';
        # 2. druh
        tagset::cs::pmk::decode_interjection_type($values[2], \%f);
        # 3. _
        # 4. styl
        tagset::cs::pmk::decode_style($values[4], \%f);
    }
    # částice = particle
    elsif($pos eq '0')
    {
        $f{pos} = 'part';
        # 2. druh
        tagset::cs::pmk::decode_particle_type($values[2], \%f);
        # 3. _
        # 4. styl
        tagset::cs::pmk::decode_style($values[4], \%f);
    }
    # idiom a frazém = idiom and set phrase
    elsif($pos eq 'F')
    {
        $f{other}{pos} = 'F';
        # 2. druh
        tagset::cs::pmk::decode_idiom_type($values[2], \%f);
        # 3. _
        # 4. styl
        tagset::cs::pmk::decode_style($values[4], \%f);
    }
    # jiné = other
    elsif($pos eq 'J') # $pos eq 'J'
    {
        $f{other}{pos} = 'J';
        # 2. skutečný druh: CZP
        tagset::cs::pmk::decode_other_real_type($values[2], \%f);
        # 3. for 'JP' druh, otherwise '_'
        if($values[2] eq 'P')
        {
            tagset::cs::pmk::decode_proper_noun_type($values[3], \%f);
        }
        # 4. styl
        tagset::cs::pmk::decode_style($values[4], \%f);
    }
    # untagged tokens in multi-word expressions have empty tags like this:
    # <i1></i1><i2></i2><i3></i3><i4></i4>
    else
    {
        $f{other}{pos} = 'untagged';
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
    if($f0->{tagset} eq 'cs::pmk')
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
    # Features are numbered from 1; the 0th element of the array will remain empty.
    my @values;
    # Part of speech (the first letter of the tag) specifies which features follow.
    my $pos = $f{pos};
    # substantivum = noun
    if($pos eq 'noun')
    {
        # substantivum = noun
        if($f{prontype} eq '')
        {
            $values[1] = 1;
            # 2. druh
            $values[2] = tagset::cs::pmk::encode_noun_type($f);
            # 3. rod
            $values[3] = tagset::cs::pmk::encode_gender(1, $f);
            # 4. styl
            $values[4] = tagset::cs::pmk::encode_style($f);
        }
        # zájmeno = pronoun
        else
        {
            $values[1] = 3;
            # 2. druh
            $values[2] = tagset::cs::pmk::encode_pronoun_type($f);
            $values[3] = '_';
            # 4. styl
            $values[4] = tagset::cs::pmk::encode_style($f);
        }
    }
    # adjektivum = adjective
    elsif($pos eq 'adj')
    {
        $values[1] = 2;
        # 2. druh
        $values[2] = tagset::cs::pmk::encode_adjective_type($f);
        # 3. poddruh
        $values[3] = tagset::cs::pmk::encode_adjective_subtype($f);
        # 4. styl
        $values[4] = tagset::cs::pmk::encode_style($f);
    }
    # číslovka = numeral
    elsif($pos eq 'num')
    {
        $values[1] = 4;
        # 2. druh
        $values[2] = tagset::cs::pmk::encode_numeral_type($f);
        $values[3] = '_';
        # 4. styl
        $values[4] = tagset::cs::pmk::encode_style($f);
    }
    # sloveso = verb
    elsif($pos eq 'verb')
    {
        $values[1] = 5;
        # 2. víceslovnost a rezultativnost
        $values[2] = tagset::cs::pmk::encode_multiwordness_and_resultativeness($f);
        # 3. zápor
        $values[3] = tagset::cs::pmk::encode_negativeness($f);
        # 4. styl
        $values[4] = tagset::cs::pmk::encode_style($f);
    }
    # adverbium = adverb
    elsif($pos eq 'adv')
    {
        $values[1] = 6;
        # 2. druh
        $values[2] = tagset::cs::pmk::encode_adverb_type($f);
        $values[3] = '_';
        # 4. styl
        $values[4] = tagset::cs::pmk::encode_style($f);
    }
    # předložka = preposition
    elsif($pos eq 'prep')
    {
        $values[1] = 7;
        # 2. druh
        $values[2] = tagset::cs::pmk::encode_preposition_type($f);
        $values[3] = '_';
        # 4. styl
        $values[4] = tagset::cs::pmk::encode_style($f);
    }
    # spojka = conjunction
    elsif($pos eq 'conj')
    {
        $values[1] = 8;
        # 2. druh
        $values[2] = tagset::cs::pmk::encode_conjunction_type($f);
        $values[3] = '_';
        # 4. styl
        $values[4] = tagset::cs::pmk::encode_style($f);
    }
    # citoslovce = interjection
    elsif($pos eq 'int')
    {
        $values[1] = 9;
        # 2. druh
        $values[2] = tagset::cs::pmk::encode_interjection_type($f);
        $values[3] = '_';
        # 4. styl
        $values[4] = tagset::cs::pmk::encode_style($f);
    }
    # částice = particle
    elsif($pos eq 'part')
    {
        $values[1] = 0;
        # 2. druh
        $values[2] = tagset::cs::pmk::encode_particle_type($f);
        $values[3] = '_';
        # 4. styl
        $values[4] = tagset::cs::pmk::encode_style($f);
    }
    # idiom a frazém = idiom and set phrase
    elsif($f{tagset} eq 'cs::pmk' && $f{other}{pos} eq 'F')
    {
        $values[1] = 'F';
        # 2. druh
        $values[2] = tagset::cs::pmk::encode_idiom_type($f);
        $values[3] = '_';
        # 4. styl
        $values[4] = tagset::cs::pmk::encode_style($f);
    }
    # untagged tokens in multi-word expressions have empty tags like this:
    # <i1></i1><i2></i2><i3></i3><i4></i4>
    elsif($f{tagset} eq 'cs::pmk' && $f{other}{pos} eq 'untagged')
    {
        # leave $values[1..4] empty
    }
    # jiné = other
    else
    {
        $values[1] = 'J';
        # 2. skutečný druh: CZP
        $values[2] = tagset::cs::pmk::encode_other_real_type($f);
        # 3. druh (JP only)
        if($values[2] eq 'P')
        {
            $values[3] = tagset::cs::pmk::encode_proper_noun_type($f);
        }
        else
        {
            $values[3] = '_';
        }
        # 4. styl
        $values[4] = tagset::cs::pmk::encode_style($f);
    }
    # Convert the array of values to a tag in the XML format.
    my $tag;
    for(my $i = 1; $i<=4; $i++)
    {
        $tag .= "<i$i>$values[$i]</i$i>";
    }
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# 236 (pmk_kr.xml), after cleaning: 212
# 10900 (pmk_dl.xml), after cleaning: 10813
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
<i1>0</i1><i2>1</i2><i3>_</i3><i4>1</i4>
<i1>0</i1><i2>1</i2><i3>_</i3><i4>2</i4>
<i1>0</i1><i2>1</i2><i3>_</i3><i4>3</i4>
<i1>0</i1><i2>2</i2><i3>_</i3><i4>1</i4>
<i1>0</i1><i2>2</i2><i3>_</i3><i4>2</i4>
<i1>0</i1><i2>2</i2><i3>_</i3><i4>3</i4>
<i1>0</i1><i2>3</i2><i3>_</i3><i4>1</i4>
<i1>0</i1><i2>3</i2><i3>_</i3><i4>2</i4>
<i1>0</i1><i2>4</i2><i3>_</i3><i4>1</i4>
<i1>0</i1><i2>4</i2><i3>_</i3><i4>2</i4>
<i1>0</i1><i2>4</i2><i3>_</i3><i4>3</i4>
<i1>0</i1><i2>5</i2><i3>_</i3><i4>1</i4>
<i1>0</i1><i2>5</i2><i3>_</i3><i4>2</i4>
<i1>1</i1><i2>1</i2><i3>1</i3><i4>1</i4>
<i1>1</i1><i2>1</i2><i3>1</i3><i4>2</i4>
<i1>1</i1><i2>1</i2><i3>1</i3><i4>4</i4>
<i1>1</i1><i2>1</i2><i3>2</i3><i4>1</i4>
<i1>1</i1><i2>1</i2><i3>2</i3><i4>2</i4>
<i1>1</i1><i2>1</i2><i3>2</i3><i4>4</i4>
<i1>1</i1><i2>1</i2><i3>3</i3><i4>1</i4>
<i1>1</i1><i2>1</i2><i3>3</i3><i4>2</i4>
<i1>1</i1><i2>1</i2><i3>3</i3><i4>4</i4>
<i1>1</i1><i2>1</i2><i3>4</i3><i4>1</i4>
<i1>1</i1><i2>1</i2><i3>4</i3><i4>2</i4>
<i1>1</i1><i2>1</i2><i3>4</i3><i4>4</i4>
<i1>1</i1><i2>2</i2><i3>1</i3><i4>1</i4>
<i1>1</i1><i2>2</i2><i3>1</i3><i4>2</i4>
<i1>1</i1><i2>2</i2><i3>2</i3><i4>1</i4>
<i1>1</i1><i2>2</i2><i3>3</i3><i4>1</i4>
<i1>1</i1><i2>2</i2><i3>3</i3><i4>2</i4>
<i1>1</i1><i2>2</i2><i3>4</i3><i4>1</i4>
<i1>1</i1><i2>3</i2><i3>1</i3><i4>1</i4>
<i1>1</i1><i2>4</i2><i3>1</i3><i4>1</i4>
<i1>1</i1><i2>4</i2><i3>2</i3><i4>1</i4>
<i1>1</i1><i2>4</i2><i3>3</i3><i4>1</i4>
<i1>1</i1><i2>4</i2><i3>3</i3><i4>2</i4>
<i1>1</i1><i2>4</i2><i3>4</i3><i4>1</i4>
<i1>1</i1><i2>4</i2><i3>4</i3><i4>2</i4>
<i1>1</i1><i2>5</i2><i3>2</i3><i4>1</i4>
<i1>1</i1><i2>5</i2><i3>4</i3><i4>1</i4>
<i1>1</i1><i2>5</i2><i3>4</i3><i4>2</i4>
<i1>1</i1><i2>6</i2><i3>4</i3><i4>1</i4>
<i1>1</i1><i2>6</i2><i3>4</i3><i4>2</i4>
<i1>1</i1><i2>7</i2><i3>1</i3><i4>1</i4>
<i1>1</i1><i2>7</i2><i3>2</i3><i4>1</i4>
<i1>1</i1><i2>7</i2><i3>3</i3><i4>1</i4>
<i1>1</i1><i2>7</i2><i3>4</i3><i4>1</i4>
<i1>1</i1><i2>9</i2><i3>2</i3><i4>1</i4>
<i1>1</i1><i2>9</i2><i3>3</i3><i4>1</i4>
<i1>1</i1><i2>9</i2><i3>4</i3><i4>1</i4>
<i1>1</i1><i2>9</i2><i3>4</i3><i4>2</i4>
<i1>2</i1><i2>1</i2><i3>0</i3><i4>1</i4>
<i1>2</i1><i2>1</i2><i3>0</i3><i4>2</i4>
<i1>2</i1><i2>1</i2><i3>0</i3><i4>3</i4>
<i1>2</i1><i2>1</i2><i3>1</i3><i4>1</i4>
<i1>2</i1><i2>1</i2><i3>2</i3><i4>1</i4>
<i1>2</i1><i2>1</i2><i3>3</i3><i4>1</i4>
<i1>2</i1><i2>1</i2><i3>4</i3><i4>1</i4>
<i1>2</i1><i2>1</i2><i3>4</i3><i4>2</i4>
<i1>2</i1><i2>1</i2><i3>4</i3><i4>3</i4>
<i1>2</i1><i2>2</i2><i3>1</i3><i4>1</i4>
<i1>2</i1><i2>2</i2><i3>1</i3><i4>2</i4>
<i1>2</i1><i2>2</i2><i3>1</i3><i4>4</i4>
<i1>2</i1><i2>2</i2><i3>2</i3><i4>1</i4>
<i1>2</i1><i2>2</i2><i3>2</i3><i4>2</i4>
<i1>2</i1><i2>2</i2><i3>3</i3><i4>2</i4>
<i1>2</i1><i2>2</i2><i3>4</i3><i4>1</i4>
<i1>2</i1><i2>2</i2><i3>4</i3><i4>2</i4>
<i1>2</i1><i2>2</i2><i3>4</i3><i4>3</i4>
<i1>2</i1><i2>2</i2><i3>5</i3><i4>2</i4>
<i1>2</i1><i2>3</i2><i3>0</i3><i4>1</i4>
<i1>2</i1><i2>3</i2><i3>3</i3><i4>1</i4>
<i1>2</i1><i2>3</i2><i3>4</i3><i4>1</i4>
<i1>2</i1><i2>3</i2><i3>4</i3><i4>2</i4>
<i1>3</i1><i2>-</i2><i3>_</i3><i4>1</i4>
<i1>3</i1><i2>-</i2><i3>_</i3><i4>2</i4>
<i1>3</i1><i2>0</i2><i3>_</i3><i4>1</i4>
<i1>3</i1><i2>0</i2><i3>_</i3><i4>2</i4>
<i1>3</i1><i2>1</i2><i3>_</i3><i4>1</i4>
<i1>3</i1><i2>1</i2><i3>_</i3><i4>2</i4>
<i1>3</i1><i2>2</i2><i3>_</i3><i4>1</i4>
<i1>3</i1><i2>2</i2><i3>_</i3><i4>2</i4>
<i1>3</i1><i2>2</i2><i3>_</i3><i4>3</i4>
<i1>3</i1><i2>3</i2><i3>_</i3><i4>1</i4>
<i1>3</i1><i2>3</i2><i3>_</i3><i4>2</i4>
<i1>3</i1><i2>4</i2><i3>_</i3><i4>1</i4>
<i1>3</i1><i2>4</i2><i3>_</i3><i4>2</i4>
<i1>3</i1><i2>5</i2><i3>_</i3><i4>1</i4>
<i1>3</i1><i2>5</i2><i3>_</i3><i4>2</i4>
<i1>3</i1><i2>6</i2><i3>_</i3><i4>1</i4>
<i1>3</i1><i2>6</i2><i3>_</i3><i4>2</i4>
<i1>3</i1><i2>7</i2><i3>_</i3><i4>1</i4>
<i1>3</i1><i2>7</i2><i3>_</i3><i4>2</i4>
<i1>3</i1><i2>8</i2><i3>_</i3><i4>1</i4>
<i1>3</i1><i2>8</i2><i3>_</i3><i4>2</i4>
<i1>3</i1><i2>9</i2><i3>_</i3><i4>1</i4>
<i1>3</i1><i2>9</i2><i3>_</i3><i4>2</i4>
<i1>4</i1><i2>0</i2><i3>_</i3><i4>1</i4>
<i1>4</i1><i2>1</i2><i3>_</i3><i4>1</i4>
<i1>4</i1><i2>1</i2><i3>_</i3><i4>2</i4>
<i1>4</i1><i2>2</i2><i3>_</i3><i4>1</i4>
<i1>4</i1><i2>2</i2><i3>_</i3><i4>2</i4>
<i1>4</i1><i2>3</i2><i3>_</i3><i4>1</i4>
<i1>4</i1><i2>3</i2><i3>_</i3><i4>2</i4>
<i1>4</i1><i2>4</i2><i3>_</i3><i4>1</i4>
<i1>4</i1><i2>4</i2><i3>_</i3><i4>2</i4>
<i1>4</i1><i2>5</i2><i3>_</i3><i4>1</i4>
<i1>4</i1><i2>5</i2><i3>_</i3><i4>2</i4>
<i1>4</i1><i2>6</i2><i3>_</i3><i4>1</i4>
<i1>4</i1><i2>6</i2><i3>_</i3><i4>2</i4>
<i1>4</i1><i2>7</i2><i3>_</i3><i4>1</i4>
<i1>5</i1><i2>1</i2><i3>1</i3><i4>1</i4>
<i1>5</i1><i2>1</i2><i3>1</i3><i4>2</i4>
<i1>5</i1><i2>1</i2><i3>1</i3><i4>3</i4>
<i1>5</i1><i2>1</i2><i3>1</i3><i4>4</i4>
<i1>5</i1><i2>1</i2><i3>2</i3><i4>1</i4>
<i1>5</i1><i2>1</i2><i3>2</i3><i4>2</i4>
<i1>5</i1><i2>1</i2><i3>2</i3><i4>3</i4>
<i1>5</i1><i2>1</i2><i3>2</i3><i4>4</i4>
<i1>5</i1><i2>2</i2><i3>1</i3><i4>1</i4>
<i1>5</i1><i2>2</i2><i3>1</i3><i4>2</i4>
<i1>5</i1><i2>2</i2><i3>1</i3><i4>3</i4>
<i1>5</i1><i2>2</i2><i3>1</i3><i4>4</i4>
<i1>5</i1><i2>2</i2><i3>2</i3><i4>1</i4>
<i1>5</i1><i2>2</i2><i3>2</i3><i4>2</i4>
<i1>5</i1><i2>2</i2><i3>2</i3><i4>3</i4>
<i1>5</i1><i2>3</i2><i3>1</i3><i4>1</i4>
<i1>5</i1><i2>3</i2><i3>1</i3><i4>2</i4>
<i1>5</i1><i2>3</i2><i3>1</i3><i4>3</i4>
<i1>5</i1><i2>3</i2><i3>1</i3><i4>4</i4>
<i1>5</i1><i2>3</i2><i3>2</i3><i4>1</i4>
<i1>5</i1><i2>3</i2><i3>2</i3><i4>2</i4>
<i1>5</i1><i2>4</i2><i3>1</i3><i4>1</i4>
<i1>5</i1><i2>4</i2><i3>1</i3><i4>2</i4>
<i1>5</i1><i2>4</i2><i3>2</i3><i4>1</i4>
<i1>5</i1><i2>4</i2><i3>2</i3><i4>2</i4>
<i1>5</i1><i2>5</i2><i3>1</i3><i4>1</i4>
<i1>5</i1><i2>5</i2><i3>1</i3><i4>2</i4>
<i1>5</i1><i2>5</i2><i3>2</i3><i4>1</i4>
<i1>5</i1><i2>5</i2><i3>2</i3><i4>2</i4>
<i1>5</i1><i2>6</i2><i3>1</i3><i4>1</i4>
<i1>5</i1><i2>6</i2><i3>1</i3><i4>2</i4>
<i1>5</i1><i2>7</i2><i3>1</i3><i4>1</i4>
<i1>5</i1><i2>7</i2><i3>1</i3><i4>2</i4>
<i1>6</i1><i2>1</i2><i3>_</i3><i4>1</i4>
<i1>6</i1><i2>1</i2><i3>_</i3><i4>2</i4>
<i1>6</i1><i2>1</i2><i3>_</i3><i4>3</i4>
<i1>6</i1><i2>2</i2><i3>_</i3><i4>1</i4>
<i1>6</i1><i2>2</i2><i3>_</i3><i4>2</i4>
<i1>6</i1><i2>3</i2><i3>_</i3><i4>1</i4>
<i1>6</i1><i2>3</i2><i3>_</i3><i4>2</i4>
<i1>6</i1><i2>4</i2><i3>_</i3><i4>1</i4>
<i1>6</i1><i2>4</i2><i3>_</i3><i4>2</i4>
<i1>6</i1><i2>4</i2><i3>_</i3><i4>3</i4>
<i1>6</i1><i2>5</i2><i3>_</i3><i4>1</i4>
<i1>6</i1><i2>5</i2><i3>_</i3><i4>2</i4>
<i1>7</i1><i2>1</i2><i3>_</i3><i4>1</i4>
<i1>7</i1><i2>1</i2><i3>_</i3><i4>2</i4>
<i1>7</i1><i2>2</i2><i3>_</i3><i4>1</i4>
<i1>7</i1><i2>2</i2><i3>_</i3><i4>2</i4>
<i1>7</i1><i2>3</i2><i3>_</i3><i4>1</i4>
<i1>7</i1><i2>3</i2><i3>_</i3><i4>2</i4>
<i1>8</i1><i2>1</i2><i3>_</i3><i4>1</i4>
<i1>8</i1><i2>1</i2><i3>_</i3><i4>2</i4>
<i1>8</i1><i2>1</i2><i3>_</i3><i4>3</i4>
<i1>8</i1><i2>2</i2><i3>_</i3><i4>1</i4>
<i1>8</i1><i2>2</i2><i3>_</i3><i4>2</i4>
<i1>8</i1><i2>2</i2><i3>_</i3><i4>3</i4>
<i1>8</i1><i2>3</i2><i3>_</i3><i4>1</i4>
<i1>8</i1><i2>3</i2><i3>_</i3><i4>2</i4>
<i1>8</i1><i2>3</i2><i3>_</i3><i4>3</i4>
<i1>8</i1><i2>4</i2><i3>_</i3><i4>1</i4>
<i1>8</i1><i2>4</i2><i3>_</i3><i4>2</i4>
<i1>8</i1><i2>9</i2><i3>_</i3><i4>1</i4>
<i1>8</i1><i2>9</i2><i3>_</i3><i4>2</i4>
<i1>9</i1><i2>1</i2><i3>_</i3><i4>1</i4>
<i1>9</i1><i2>1</i2><i3>_</i3><i4>2</i4>
<i1>9</i1><i2>2</i2><i3>_</i3><i4>1</i4>
<i1>9</i1><i2>3</i2><i3>_</i3><i4>1</i4>
<i1>9</i1><i2>4</i2><i3>_</i3><i4>1</i4>
<i1>9</i1><i2>5</i2><i3>_</i3><i4>1</i4>
<i1>9</i1><i2>6</i2><i3>_</i3><i4>1</i4>
<i1>9</i1><i2>6</i2><i3>_</i3><i4>2</i4>
<i1>9</i1><i2>7</i2><i3>_</i3><i4>1</i4>
<i1></i1><i2></i2><i3></i3><i4></i4>
<i1>F</i1><i2>1</i2><i3>_</i3><i4>1</i4>
<i1>F</i1><i2>1</i2><i3>_</i3><i4>2</i4>
<i1>F</i1><i2>1</i2><i3>_</i3><i4>4</i4>
<i1>F</i1><i2>2</i2><i3>_</i3><i4>1</i4>
<i1>F</i1><i2>2</i2><i3>_</i3><i4>2</i4>
<i1>F</i1><i2>2</i2><i3>_</i3><i4>4</i4>
<i1>F</i1><i2>3</i2><i3>_</i3><i4>1</i4>
<i1>F</i1><i2>3</i2><i3>_</i3><i4>2</i4>
<i1>F</i1><i2>3</i2><i3>_</i3><i4>3</i4>
<i1>F</i1><i2>4</i2><i3>_</i3><i4>1</i4>
<i1>F</i1><i2>4</i2><i3>_</i3><i4>2</i4>
<i1>F</i1><i2>5</i2><i3>_</i3><i4>1</i4>
<i1>F</i1><i2>5</i2><i3>_</i3><i4>2</i4>
<i1>F</i1><i2>5</i2><i3>_</i3><i4>3</i4>
<i1>F</i1><i2>5</i2><i3>_</i3><i4>4</i4>
<i1>F</i1><i2>6</i2><i3>_</i3><i4>1</i4>
<i1>F</i1><i2>6</i2><i3>_</i3><i4>2</i4>
<i1>F</i1><i2>6</i2><i3>_</i3><i4>4</i4>
<i1>J</i1><i2>C</i2><i3>_</i3><i4>1</i4>
<i1>J</i1><i2>C</i2><i3>_</i3><i4>2</i4>
<i1>J</i1><i2>C</i2><i3>_</i3><i4>4</i4>
<i1>J</i1><i2>P</i2><i3>1</i3><i4>1</i4>
<i1>J</i1><i2>P</i2><i3>1</i3><i4>2</i4>
<i1>J</i1><i2>P</i2><i3>2</i3><i4>1</i4>
<i1>J</i1><i2>P</i2><i3>2</i3><i4>2</i4>
<i1>J</i1><i2>Z</i2><i3>_</i3><i4>1</i4>
<i1>J</i1><i2>Z</i2><i3>_</i3><i4>2</i4>
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
