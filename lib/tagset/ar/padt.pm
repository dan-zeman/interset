#!/usr/bin/perl
# Driver for the PADT 2.0 / ElixirFM Arabic positional tagset.
# Copyright © 2013 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::ar::padt;
use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');



my %postable =
(
    'N-' => ['pos' => 'noun'], # common noun
    'Z-' => ['pos' => 'noun', 'subpos' => 'prop'], # proper noun
    'A-' => ['pos' => 'adj'], # adjective
    'S-' => ['pos' => 'noun', 'prontype' => 'prs'], # pronoun (probably personal)
    'SP' => ['pos' => 'noun', 'prontype' => 'prs'], # personal pronoun
    'SD' => ['pos' => 'adj',  'prontype' => 'dem', 'synpos' => 'attr', 'definiteness' => 'def'], # demonstrative pronoun
    'SR' => ['pos' => 'noun', 'prontype' => 'rel'], # relative pronoun
    'Q-' => ['pos' => 'num', 'numform' => 'digit'], # numeral: number
    'QC' => ['pos' => 'num', 'numform' => 'word', 'other' => {'numvalue' => 100}], # numeral: hundred
    'QI' => ['pos' => 'num', 'numform' => 'word', 'numvalue' => 1], # numeral: one
    'QL' => ['pos' => 'num', 'numform' => 'word', 'other' => {'numvalue' => 20}], # numeral: twenty, thirty, ..., ninety
    'QM' => ['pos' => 'num', 'numform' => 'word', 'other' => {'numvalue' => 1000}], # numeral: thousand, million, billion, ...
    'QU' => ['pos' => 'num', 'numform' => 'word', 'other' => {'numvalue' => 15}], # numeral: -teen
    'QV' => ['pos' => 'num', 'numform' => 'word', 'numvalue' => 3], # numeral: three, four, ..., nine
    'QX' => ['pos' => 'num', 'numform' => 'word', 'other' => {'numvalue' => 10}], # numeral: ten
    'QY' => ['pos' => 'num', 'numform' => 'word', 'numvalue' => 2], # numeral: two
    'V-' => ['pos' => 'verb'], # verb
    'VI' => ['pos' => 'verb', 'aspect' => 'imp'], # imperfect verb
    'VP' => ['pos' => 'verb', 'aspect' => 'perf'], # perfect verb
    'VC' => ['pos' => 'verb', 'verbform' => 'fin', 'mood' => 'imp'], # verb imperative
    'D-' => ['pos' => 'adv'], # adverb
    'P-' => ['pos' => 'prep'], # preposition
    'PI' => ['pos' => 'prep'], # inflected preposition (nominative, genitive, accusative)
    'C-' => ['pos' => 'conj'], # conjunction or subjunction
    'F-' => ['pos' => 'part'], # function word, particle
    'FI' => ['pos' => 'part', 'prontype' => 'int'], # interrogative particle
    'FN' => ['pos' => 'part', 'negativeness' => 'neg'], # negative particle
    'I-' => ['pos' => 'int'], # interjection
    'Y-' => ['abbr' => 'abbr'], # abbreviation
    'T-' => ['typo' => 'typo'], # typo
    'G-' => ['pos' => 'punc'], # punctuation and other symbols
    'X-' => ['foreign' => 'foreign'], # non-Arabic script
    'U-' => [], # residual class for unknown words
    '_'  => [], # if empty tag occurs treat it as unknown word
);



my @featable =
(
    # 0 and 1 ... part of speech, see %postable above
    {},
    {},
    # 2 ... mood
    {
        'I' => ['verbform' => 'fin', 'mood' => 'ind'],
        'J' => ['verbform' => 'fin', 'mood' => 'jus'],
        'S' => ['verbform' => 'fin', 'mood' => 'sub'],
        'D' => ['verbform' => 'fin', 'mood' => ['sub', 'jus']]
    },
    # 3 ... voice
    {
        'A' => ['voice' => 'act'],
        'P' => ['voice' => 'pass']
    },
    # 4 ... ???
    {},
    # 5 ... person
    {
        '1' => ['person' => '1'],
        '2' => ['person' => '2'],
        '3' => ['person' => '3']
    },
    # 6 ... gender
    {
        'M' => ['gender' => 'masc'],
        'F' => ['gender' => 'fem']
    },
    # 7 ... number
    {
        'S' => ['number' => 'sing'],
        'D' => ['number' => 'dual'],
        'P' => ['number' => 'plu']
    },
    # 8 ... case
    {
        '1' => ['case' => 'nom'],
        '2' => ['case' => 'gen'],
        '4' => ['case' => 'acc']
    },
    # 9 ... definiteness
    {
        'I' => ['definiteness' => 'ind'],
        'D' => ['definiteness' => 'def'],
        'R' => ['definiteness' => 'red'],
        'C' => ['definiteness' => 'com']
    }
);



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = 'ar::padt';
    # The tags are positional, there are 10 character positions:
    # part of speech (2 characters), ###!!!
    my $pos = substr($tag, 0, 2);
    my $assignments = $postable{$pos};
    for(my $i = 0; $i<=$#{$assignments}; $i += 2)
    {
        $f{$assignments->[$i]} = $assignments->[$i+1];
    }
    my @features = split(//, $tag);
    for(my $i = 2; $i<=$#features; $i++)
    {
        my $value = $features[$i];
        my $valtable = $featable[$i];
        ###!!! DEBUG
        if($i==4 && $value ne '-')
        {
            die("PATA POZICE\t$tag");
        }
        ###!!! END OF DEBUG
        my $assignments = $valtable->{$value};
        for(my $j = 0; $j<=$#{$assignments}; $j += 2)
        {
            $f{$assignments->[$j]} = $assignments->[$j+1];
        }
    }
    ###!!!
    if(1)
    {
    }
    # Although not documented, the data contain the tag "-\t--\tdef=D".
    # It is always assigned to the definite article 'al' if separated from its noun or adjective.
    # Normally the article is not tokenized off and makes the definiteness feature of the noun.
    elsif($pos eq '-')
    {
        $f{pos} = 'adj';
        $f{subpos} = 'art';
    }
    # Default feature values. Used to improve collaboration with other drivers.
    if($f{pos} eq 'verb')
    {
        if($f{verbform} eq '')
        {
            if($f{person} ne '')
            {
                $f{verbform} = 'fin';
                if($f{mood} eq '')
                {
                    # Warning! Sometimes the mood is probably deliberately empty.
                    # While setting the default improves collaboration with other drivers,
                    # it hurts the encode(decode)=original condition. So we try to
                    # remember it, for the case we will be encoding into our own tagset again.
                    $f{mood} = 'ind';
                    $f{other} = 'empty-mood';
                }
            }
            else
            {
                $f{verbform} = 'inf';
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
    if($f{abbr} eq "abbr")
    {
        $tag = "Y\tY-";
    }
    elsif($f{prontype} eq "dem")
    {
        # SD = demonstrative pronoun
        $tag = "S\tSD";
    }
    elsif($f{prontype} =~ m/^(int|rel)$/ && $f{pos} ne "part")
    {
        # SR = relative pronoun
        $tag = "S\tSR";
    }
    elsif($f{prontype} ne "" && $f{pos} ne "part")
    {
        # S = pronoun
        $tag = "S\tS-";
    }
    elsif($f{pos} eq "noun")
    {
        # N = common noun
        # Z = proper noun
        if($f{subpos} eq "prop")
        {
            $tag = "Z\tZ-";
        }
        else
        {
            $tag = "N\tN-";
        }
    }
    elsif($f{pos} eq "adj")
    {
        if($f{subpos} eq 'art')
        {
            $tag = "-\t--";
        }
        else
        {
            $tag = "A\tA-";
        }
    }
    elsif($f{pos} eq "num")
    {
        # Q = numeral
        $tag = "Q\tQ-";
    }
    elsif($f{pos} eq "verb")
    {
        # VI = imperfect verb
        # VP = perfect verb
        # VC = imperative verb form
        if($f{mood} eq 'imp')
        {
            $tag = "V\tVC";
        }
        elsif($f{aspect} eq "perf")
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
        $tag = "D\tD-";
    }
    elsif($f{pos} eq "prep")
    {
        $tag = "P\tP-";
    }
    elsif($f{pos} eq "conj")
    {
        $tag = "C\tC-";
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
        elsif($f{prontype} =~ m/^(int|rel)$/)
        {
            $tag = "F\tFI";
        }
        else
        {
            $tag = "F\tF-";
        }
    }
    elsif($f{pos} eq "int")
    {
        # I = interjection
        $tag = "I\tI-";
    }
    elsif($f{pos} eq "punc")
    {
        # T = typo
        # G = punctuation
        # X = non-alphabetic
        $tag = "G\tG-";
    }
    else
    {
        $tag = "_\t_";
    }
    # Encode features.
    my @features;
    if($f{tagset} eq 'ar::conll2007' && $f{other} eq '11')
    {
        push(@features, '11');
    }
    # Only finite imperfect verbs have mood.
    if($f{pos} eq "verb" && $f{aspect} eq "imp" && $f{verbform} eq "fin")
    {
        if(tagset::common::iseq($f{mood}, ['sub', 'jus']))
        {
            push(@features, 'Mood=D');
        }
        elsif($f{mood} eq 'jus')
        {
            push(@features, 'Mood=J');
        }
        elsif($f{mood} eq "sub")
        {
            push(@features, "Mood=S");
        }
        elsif(!($f{tagset} =~ m/^ar::conll(2007)?$/ && $f{other} eq "empty-mood" ||
                $f{person} eq "3" && $f{gender} eq "fem" && $f{number} eq "plu"))
        {
            push(@features, "Mood=I");
        }
    }
    # Only verbs have voice and only passive voice is explicitely encoded.
    if($f{pos} eq "verb")
    {
        if($f{voice} eq 'pass')
        {
            push(@features, 'Voice=P');
        }
        elsif($f{voice} eq 'act')
        {
            push(@features, 'Voice=A');
        }
    }
    # Non-demonstrative non-relative pronouns and verbs have person.
    if($f{pos} eq "verb" || $f{prontype} eq "prs")
    {
        if($f{person} =~ m/^[123]$/)
        {
            push(@features, "Person=$f{person}");
        }
    }
    # Gender.
    if($f{gender} eq "masc")
    {
        push(@features, "Gender=M");
    }
    elsif($f{gender} eq "fem")
    {
        push(@features, "Gender=F");
    }
    # Number.
    if($f{number} eq "sing")
    {
        push(@features, "Number=S");
    }
    elsif($f{number} eq "dual")
    {
        push(@features, "Number=D");
    }
    elsif($f{number} eq "plu")
    {
        push(@features, "Number=P");
    }
    # Case.
    if($f{case} eq "nom")
    {
        push(@features, "Case=1");
    }
    elsif($f{case} eq "gen")
    {
        push(@features, "Case=2");
    }
    elsif($f{case} eq "acc")
    {
        push(@features, "Case=4");
    }
    # Definiteness.
    # Do not show explicitly for demonstrative pronouns.
    if($f{definiteness} eq "def" && $f{prontype} ne "dem")
    {
        push(@features, "Defin=D");
    }
    elsif($f{definiteness} eq "ind")
    {
        push(@features, "Defin=I");
    }
    elsif($f{definiteness} eq "red")
    {
        push(@features, "Defin=R");
    }
    elsif($f{definiteness} eq 'com')
    {
        push(@features, 'Defin=C');
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
# cat /net/data/conll/2007/ar/*.conll |\
#   perl -pe '@x = split(/\s+/, $_); $_ = "$x[3]\t$x[4]\t$x[5]\n"' |\
#   sort -u | wc -l
# 297
#------------------------------------------------------------------------------
sub list
{
    return ['C---------']; ###!!!
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
