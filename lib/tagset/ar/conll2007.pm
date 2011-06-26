#!/usr/bin/perl
# Driver for the CoNLL 2006 Arabic tagset.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::ar::conll2007;
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
    $f{tagset} = "ar::conll2007";
    # three components: coarse-grained pos, fine-grained pos, features
    # example: N\tNC\tgender=neuter|number=sing|case=unmarked|def=indef
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    # pos: N Z A S Q V D P C F I G T Y _
    # N = common noun
    if($pos eq "N")
    {
        $f{pos} = "noun";
    }
    # Z = proper noun
    elsif($pos eq "Z")
    {
        $f{pos} = "noun";
        $f{subpos} = "prop";
    }
    # A = adjective
    elsif($pos eq "A")
    {
        $f{pos} = "adj";
    }
    # S = pronoun
    elsif($pos eq "S")
    {
        $f{pos} = "noun";
        # SD = demonstrative
        if($subpos eq "SD")
        {
            $f{synpos} = "attr";
            $f{definiteness} = "def";
            $f{prontype} = "dem";
        }
        # SR = relative
        elsif($subpos eq "SR")
        {
            $f{prontype} = "rel";
        }
        # S = personal or possessive
        else
        {
            $f{prontype} = "prs";
        }
    }
    # Q = number
    elsif($pos eq "Q")
    {
        $f{pos} = "num";
    }
    # V = verb
    elsif($pos eq "V")
    {
        $f{pos} = "verb";
        # VI = imperfect
        if($subpos eq "VI")
        {
            $f{aspect} = "imp";
        }
        # VP = perfect
        elsif($subpos eq "VP")
        {
            $f{aspect} = "perf";
        }
        # VC = imperative
        elsif($subpos eq 'VC')
        {
            $f{verbform} = 'fin';
            $f{mood} = 'imp';
        }
    }
    # D = adverb
    elsif($pos eq "D")
    {
        $f{pos} = "adv";
    }
    # P = preposition
    elsif($pos eq "P")
    {
        $f{pos} = "prep";
    }
    # C = conjunction or subjunction
    elsif($pos eq "C")
    {
        $f{pos} = "conj";
    }
    # F = function word, particle
    elsif($pos eq "F")
    {
        $f{pos} = "part";
        # FI = interrogative particle
        if($subpos eq "FI")
        {
            $f{prontype} = "int";
        }
        # FN = negative particle
        elsif($subpos eq "FN")
        {
            $f{negativeness} = "neg";
        }
    }
    # I = interjection
    elsif($pos eq "I")
    {
        $f{pos} = "int";
    }
    # Y = abbreviation
    elsif($pos eq "Y")
    {
        $f{abbr} = "abbr";
    }
    # T = typo
    # there is no special feature encoding typos
    # G = punctuation (not used in UMH subcorpus)
    # _ = former X? Unknown tokens etc.
    # We decode "G" as "punc" and "_" as "" (residual class).
    elsif($pos eq "G")
    {
        $f{pos} = "punc";
    }
    # Although not documented, the data contain the tag "-\t--\tdef=D".
    # It is always assigned to the definite article 'al' if separated from its noun or adjective.
    # Normally the article is not tokenized off and makes the definiteness feature of the noun.
    elsif($pos eq '-')
    {
        $f{pos} = 'adj';
        $f{subpos} = 'art';
    }
    elsif($features eq '11')
    {
        $f{other} = '11';
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
        # gender = M|F
        if($feature eq "Gender")
        {
            if($value eq "M")
            {
                $f{gender} = "masc";
            }
            elsif($value eq "F")
            {
                $f{gender} = "fem";
            }
        }
        # number = S|D|P
        elsif($feature eq "Number")
        {
            if($value eq "S")
            {
                $f{number} = "sing";
            }
            elsif($value eq "D")
            {
                $f{number} = "dual";
            }
            elsif($value eq "P")
            {
                $f{number} = "plu";
            }
        }
        # case = 1|2|4
        elsif($feature eq "Case")
        {
            if($value eq "1")
            {
                $f{case} = "nom";
            }
            elsif($value eq "2")
            {
                $f{case} = "gen";
            }
            elsif($value eq "4")
            {
                $f{case} = "acc";
            }
        }
        # def = D|I|R|C
        elsif($feature eq "Defin")
        {
            if($value eq "D") # definite
            {
                $f{definiteness} = "def";
            }
            elsif($value eq "I") # indefinite
            {
                $f{definiteness} = "ind";
            }
            elsif($value eq "R") # reduced
            {
                $f{definiteness} = "red";
            }
            elsif($value eq "C") # complex
            {
                $f{definiteness} = "com";
            }
        }
        # person = 1|2|3
        elsif($feature eq "Person" && $value>=1 && $value<=3)
        {
            $f{person} = $value;
        }
        # mood = D|I|J|S
        elsif($feature eq "Mood")
        {
            # I = indicative
            if($value eq "I")
            {
                $f{verbform} = "fin";
                $f{mood} = "ind";
            }
            # S = subjunctive
            elsif($value eq "S")
            {
                $f{verbform} = "fin";
                $f{mood} = "sub";
            }
            # J = jussive
            elsif($value eq 'J')
            {
                $f{verbform} = 'fin';
                $f{mood} = 'jus';
            }
            # D = undecided between subjunctive and jussive
            elsif($value eq 'D')
            {
                $f{verbform} = 'fin';
                $f{mood} = ['sub', 'jus'];
            }
        }
        # voice = A|P
        elsif($feature eq 'Voice')
        {
            if($value eq 'A')
            {
                $f{voice} = 'act';
            }
            elsif($value eq 'P')
            {
                $f{voice} = 'pass';
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
                    # Warning! Sometimes the mood is probably deliberately empty.
                    # While setting the default improves collaboration with other drivers,
                    # it hurts the encode(decode)=original condition. So we try to
                    # remember it, for the case we will be encoding into our own tagset again.
                    $f{mood} = "ind";
                    $f{other} = "empty-mood";
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
    my $list = <<end_of_list
-	--	Defin=D
A	A-	Case=1|Defin=D
A	A-	Case=1|Defin=I
A	A-	Case=1|Defin=R
A	A-	Case=2|Defin=C
A	A-	Case=2|Defin=D
A	A-	Case=2|Defin=I
A	A-	Case=2|Defin=R
A	A-	Case=4|Defin=C
A	A-	Case=4|Defin=D
A	A-	Case=4|Defin=I
A	A-	Case=4|Defin=R
A	A-	Defin=C
A	A-	Defin=D
A	A-	Gender=F|Number=D|Case=1|Defin=D
A	A-	Gender=F|Number=D|Case=1|Defin=I
A	A-	Gender=F|Number=D|Case=2|Defin=D
A	A-	Gender=F|Number=D|Case=2|Defin=I
A	A-	Gender=F|Number=D|Case=4|Defin=D
A	A-	Gender=F|Number=D|Case=4|Defin=I
A	A-	Gender=F|Number=P
A	A-	Gender=F|Number=P|Case=1|Defin=D
A	A-	Gender=F|Number=P|Case=1|Defin=I
A	A-	Gender=F|Number=P|Case=2|Defin=D
A	A-	Gender=F|Number=P|Case=2|Defin=I
A	A-	Gender=F|Number=P|Case=2|Defin=R
A	A-	Gender=F|Number=P|Case=4|Defin=D
A	A-	Gender=F|Number=P|Case=4|Defin=I
A	A-	Gender=F|Number=P|Defin=D
A	A-	Gender=F|Number=S
A	A-	Gender=F|Number=S|Case=1|Defin=D
A	A-	Gender=F|Number=S|Case=1|Defin=I
A	A-	Gender=F|Number=S|Case=1|Defin=R
A	A-	Gender=F|Number=S|Case=2|Defin=C
A	A-	Gender=F|Number=S|Case=2|Defin=D
A	A-	Gender=F|Number=S|Case=2|Defin=I
A	A-	Gender=F|Number=S|Case=2|Defin=R
A	A-	Gender=F|Number=S|Case=4|Defin=C
A	A-	Gender=F|Number=S|Case=4|Defin=D
A	A-	Gender=F|Number=S|Case=4|Defin=I
A	A-	Gender=F|Number=S|Case=4|Defin=R
A	A-	Gender=F|Number=S|Defin=C
A	A-	Gender=F|Number=S|Defin=D
A	A-	Gender=M|Number=D|Case=1|Defin=D
A	A-	Gender=M|Number=D|Case=1|Defin=I
A	A-	Gender=M|Number=D|Case=2|Defin=D
A	A-	Gender=M|Number=D|Case=2|Defin=I
A	A-	Gender=M|Number=D|Case=2|Defin=R
A	A-	Gender=M|Number=D|Case=4|Defin=D
A	A-	Gender=M|Number=D|Case=4|Defin=I
A	A-	Gender=M|Number=P|Case=1|Defin=D
A	A-	Gender=M|Number=P|Case=1|Defin=I
A	A-	Gender=M|Number=P|Case=1|Defin=R
A	A-	Gender=M|Number=P|Case=2|Defin=D
A	A-	Gender=M|Number=P|Case=2|Defin=I
A	A-	Gender=M|Number=P|Case=2|Defin=R
A	A-	Gender=M|Number=P|Case=4|Defin=D
A	A-	Gender=M|Number=P|Case=4|Defin=I
A	A-	Gender=M|Number=P|Case=4|Defin=R
A	A-	Gender=M|Number=S|Case=4|Defin=I
A	A-	_
C	C-	_
D	D-	Case=4|Defin=I
D	D-	Case=4|Defin=R
D	D-	Gender=M|Number=S|Case=4|Defin=I
D	D-	_
F	F-	_
F	FI	Case=2|Defin=R
F	FI	_
F	FN	Case=1|Defin=R
F	FN	Case=2|Defin=R
F	FN	Case=4|Defin=R
F	FN	_
G	G-	_
I	I-	Case=4|Defin=I
I	I-	Case=4|Defin=R
I	I-	Gender=M|Number=S|Case=4|Defin=I
I	I-	_
N	N-	Case=1|Defin=C
N	N-	Case=1|Defin=D
N	N-	Case=1|Defin=I
N	N-	Case=1|Defin=R
N	N-	Case=2|Defin=C
N	N-	Case=2|Defin=D
N	N-	Case=2|Defin=I
N	N-	Case=2|Defin=R
N	N-	Case=4|Defin=C
N	N-	Case=4|Defin=D
N	N-	Case=4|Defin=I
N	N-	Case=4|Defin=R
N	N-	Defin=D
N	N-	Defin=R
N	N-	Gender=F|Number=D|Case=1|Defin=D
N	N-	Gender=F|Number=D|Case=1|Defin=I
N	N-	Gender=F|Number=D|Case=1|Defin=R
N	N-	Gender=F|Number=D|Case=2|Defin=D
N	N-	Gender=F|Number=D|Case=2|Defin=I
N	N-	Gender=F|Number=D|Case=2|Defin=R
N	N-	Gender=F|Number=D|Case=4|Defin=D
N	N-	Gender=F|Number=D|Case=4|Defin=I
N	N-	Gender=F|Number=D|Case=4|Defin=R
N	N-	Gender=F|Number=P
N	N-	Gender=F|Number=P|Case=1|Defin=D
N	N-	Gender=F|Number=P|Case=1|Defin=I
N	N-	Gender=F|Number=P|Case=1|Defin=R
N	N-	Gender=F|Number=P|Case=2|Defin=D
N	N-	Gender=F|Number=P|Case=2|Defin=I
N	N-	Gender=F|Number=P|Case=2|Defin=R
N	N-	Gender=F|Number=P|Case=4|Defin=D
N	N-	Gender=F|Number=P|Case=4|Defin=I
N	N-	Gender=F|Number=P|Case=4|Defin=R
N	N-	Gender=F|Number=P|Defin=D
N	N-	Gender=F|Number=S
N	N-	Gender=F|Number=S|Case=1|Defin=D
N	N-	Gender=F|Number=S|Case=1|Defin=I
N	N-	Gender=F|Number=S|Case=1|Defin=R
N	N-	Gender=F|Number=S|Case=2|Defin=C
N	N-	Gender=F|Number=S|Case=2|Defin=D
N	N-	Gender=F|Number=S|Case=2|Defin=I
N	N-	Gender=F|Number=S|Case=2|Defin=R
N	N-	Gender=F|Number=S|Case=4|Defin=C
N	N-	Gender=F|Number=S|Case=4|Defin=D
N	N-	Gender=F|Number=S|Case=4|Defin=I
N	N-	Gender=F|Number=S|Case=4|Defin=R
N	N-	Gender=F|Number=S|Defin=D
N	N-	Gender=M|Number=D|Case=1|Defin=D
N	N-	Gender=M|Number=D|Case=1|Defin=I
N	N-	Gender=M|Number=D|Case=1|Defin=R
N	N-	Gender=M|Number=D|Case=2|Defin=D
N	N-	Gender=M|Number=D|Case=2|Defin=I
N	N-	Gender=M|Number=D|Case=2|Defin=R
N	N-	Gender=M|Number=D|Case=4|Defin=D
N	N-	Gender=M|Number=D|Case=4|Defin=I
N	N-	Gender=M|Number=D|Case=4|Defin=R
N	N-	Gender=M|Number=P|Case=1|Defin=D
N	N-	Gender=M|Number=P|Case=1|Defin=I
N	N-	Gender=M|Number=P|Case=1|Defin=R
N	N-	Gender=M|Number=P|Case=2|Defin=D
N	N-	Gender=M|Number=P|Case=2|Defin=I
N	N-	Gender=M|Number=P|Case=2|Defin=R
N	N-	Gender=M|Number=P|Case=4|Defin=D
N	N-	Gender=M|Number=P|Case=4|Defin=I
N	N-	Gender=M|Number=P|Case=4|Defin=R
N	N-	Gender=M|Number=S|Case=4|Defin=I
N	N-	_
P	P-	Gender=F|Number=S
P	P-	_
Q	Q-	_
S	S-	Person=1|Number=P|Case=1
S	S-	Person=1|Number=P|Case=2
S	S-	Person=1|Number=P|Case=4
S	S-	Person=1|Number=S|Case=1
S	S-	Person=1|Number=S|Case=2
S	S-	Person=1|Number=S|Case=4
S	S-	Person=2|Gender=F|Number=S|Case=2
S	S-	Person=2|Gender=M|Number=P|Case=2
S	S-	Person=2|Gender=M|Number=P|Case=4
S	S-	Person=2|Gender=M|Number=S|Case=2
S	S-	Person=2|Gender=M|Number=S|Case=4
S	S-	Person=3|Gender=F|Number=P|Case=2
S	S-	Person=3|Gender=F|Number=P|Case=4
S	S-	Person=3|Gender=F|Number=S|Case=1
S	S-	Person=3|Gender=F|Number=S|Case=2
S	S-	Person=3|Gender=F|Number=S|Case=4
S	S-	Person=3|Gender=M|Number=P|Case=1
S	S-	Person=3|Gender=M|Number=P|Case=2
S	S-	Person=3|Gender=M|Number=P|Case=4
S	S-	Person=3|Gender=M|Number=S|Case=1
S	S-	Person=3|Gender=M|Number=S|Case=2
S	S-	Person=3|Gender=M|Number=S|Case=4
S	S-	Person=3|Number=D|Case=1
S	S-	Person=3|Number=D|Case=2
S	S-	Person=3|Number=D|Case=4
S	SD	Gender=F
S	SD	Gender=F|Number=D
S	SD	Gender=F|Number=S
S	SD	Gender=M|Number=D
S	SD	Gender=M|Number=P
S	SD	Gender=M|Number=S
S	SR	_
V	VC	Person=2|Gender=M|Number=P
V	VC	Person=2|Gender=M|Number=S
V	VI	Mood=D|Person=3|Gender=F|Number=D
V	VI	Mood=D|Person=3|Gender=M|Number=D
V	VI	Mood=D|Person=3|Gender=M|Number=P
V	VI	Mood=D|Voice=A|Person=3|Gender=F|Number=D
V	VI	Mood=D|Voice=A|Person=3|Gender=M|Number=D
V	VI	Mood=D|Voice=A|Person=3|Gender=M|Number=P
V	VI	Mood=D|Voice=P|Person=3|Gender=M|Number=D
V	VI	Mood=D|Voice=P|Person=3|Gender=M|Number=P
V	VI	Mood=I|Person=1|Number=P
V	VI	Mood=I|Person=1|Number=S
V	VI	Mood=I|Person=2|Gender=M|Number=S
V	VI	Mood=I|Person=3|Gender=F|Number=D
V	VI	Mood=I|Person=3|Gender=F|Number=S
V	VI	Mood=I|Person=3|Gender=M|Number=D
V	VI	Mood=I|Person=3|Gender=M|Number=P
V	VI	Mood=I|Person=3|Gender=M|Number=S
V	VI	Mood=I|Voice=A|Person=1|Number=P
V	VI	Mood=I|Voice=A|Person=1|Number=S
V	VI	Mood=I|Voice=A|Person=2|Gender=M|Number=P
V	VI	Mood=I|Voice=A|Person=2|Number=D
V	VI	Mood=I|Voice=A|Person=3|Gender=F|Number=D
V	VI	Mood=I|Voice=A|Person=3|Gender=F|Number=S
V	VI	Mood=I|Voice=A|Person=3|Gender=M|Number=D
V	VI	Mood=I|Voice=A|Person=3|Gender=M|Number=P
V	VI	Mood=I|Voice=A|Person=3|Gender=M|Number=S
V	VI	Mood=I|Voice=P|Person=3|Gender=F|Number=S
V	VI	Mood=I|Voice=P|Person=3|Gender=M|Number=P
V	VI	Mood=I|Voice=P|Person=3|Gender=M|Number=S
V	VI	Mood=J|Voice=A|Person=1|Number=P
V	VI	Mood=J|Voice=A|Person=1|Number=S
V	VI	Mood=J|Voice=A|Person=3|Gender=F|Number=S
V	VI	Mood=J|Voice=A|Person=3|Gender=M|Number=P
V	VI	Mood=J|Voice=A|Person=3|Gender=M|Number=S
V	VI	Mood=J|Voice=P|Person=3|Gender=F|Number=S
V	VI	Mood=J|Voice=P|Person=3|Gender=M|Number=S
V	VI	Mood=S|Person=1|Number=P
V	VI	Mood=S|Person=1|Number=S
V	VI	Mood=S|Person=3|Gender=F|Number=S
V	VI	Mood=S|Person=3|Gender=M|Number=S
V	VI	Mood=S|Voice=A|Person=1|Number=P
V	VI	Mood=S|Voice=A|Person=1|Number=S
V	VI	Mood=S|Voice=A|Person=2|Gender=M|Number=S
V	VI	Mood=S|Voice=A|Person=3|Gender=F|Number=S
V	VI	Mood=S|Voice=A|Person=3|Gender=M|Number=S
V	VI	Mood=S|Voice=P|Person=3|Gender=F|Number=S
V	VI	Mood=S|Voice=P|Person=3|Gender=M|Number=S
V	VI	Person=1|Number=P
V	VI	Person=1|Number=S
V	VI	Person=2|Gender=M|Number=S
V	VI	Person=3|Gender=F|Number=P
V	VI	Person=3|Gender=F|Number=S
V	VI	Person=3|Gender=M|Number=S
V	VI	Voice=A|Person=3|Gender=F|Number=P
V	VI	Voice=A|Person=3|Gender=M|Number=S
V	VI	Voice=P|Person=3|Gender=F|Number=S
V	VI	Voice=P|Person=3|Gender=M|Number=S
V	VP	Person=1|Number=P
V	VP	Person=1|Number=S
V	VP	Person=2|Gender=M|Number=S
V	VP	Person=3|Gender=F|Number=D
V	VP	Person=3|Gender=F|Number=P
V	VP	Person=3|Gender=F|Number=S
V	VP	Person=3|Gender=M|Number=D
V	VP	Person=3|Gender=M|Number=P
V	VP	Person=3|Gender=M|Number=S
V	VP	Voice=A|Person=1|Number=P
V	VP	Voice=A|Person=1|Number=S
V	VP	Voice=A|Person=2|Gender=M|Number=S
V	VP	Voice=A|Person=3|Gender=F|Number=D
V	VP	Voice=A|Person=3|Gender=F|Number=P
V	VP	Voice=A|Person=3|Gender=F|Number=S
V	VP	Voice=A|Person=3|Gender=M|Number=D
V	VP	Voice=A|Person=3|Gender=M|Number=P
V	VP	Voice=A|Person=3|Gender=M|Number=S
V	VP	Voice=P|Person=1|Number=P
V	VP	Voice=P|Person=3|Gender=F|Number=S
V	VP	Voice=P|Person=3|Gender=M|Number=D
V	VP	Voice=P|Person=3|Gender=M|Number=P
V	VP	Voice=P|Person=3|Gender=M|Number=S
Y	Y-	Defin=D
Y	Y-	_
Z	Z-	Case=1|Defin=D
Z	Z-	Case=1|Defin=I
Z	Z-	Case=1|Defin=R
Z	Z-	Case=2|Defin=D
Z	Z-	Case=2|Defin=I
Z	Z-	Case=2|Defin=R
Z	Z-	Case=4|Defin=D
Z	Z-	Case=4|Defin=I
Z	Z-	Case=4|Defin=R
Z	Z-	Defin=D
Z	Z-	Gender=F|Number=D|Case=2|Defin=D
Z	Z-	Gender=F|Number=P
Z	Z-	Gender=F|Number=P|Case=1|Defin=D
Z	Z-	Gender=F|Number=P|Case=1|Defin=I
Z	Z-	Gender=F|Number=P|Case=2|Defin=D
Z	Z-	Gender=F|Number=P|Case=4|Defin=D
Z	Z-	Gender=F|Number=P|Case=4|Defin=I
Z	Z-	Gender=F|Number=P|Defin=D
Z	Z-	Gender=F|Number=S
Z	Z-	Gender=F|Number=S|Case=1|Defin=D
Z	Z-	Gender=F|Number=S|Case=1|Defin=I
Z	Z-	Gender=F|Number=S|Case=1|Defin=R
Z	Z-	Gender=F|Number=S|Case=2|Defin=D
Z	Z-	Gender=F|Number=S|Case=2|Defin=I
Z	Z-	Gender=F|Number=S|Case=2|Defin=R
Z	Z-	Gender=F|Number=S|Case=4|Defin=D
Z	Z-	Gender=F|Number=S|Case=4|Defin=I
Z	Z-	Gender=F|Number=S|Case=4|Defin=R
Z	Z-	Gender=F|Number=S|Defin=D
Z	Z-	Gender=M|Number=D|Case=2|Defin=D
Z	Z-	Gender=M|Number=P|Case=2|Defin=R
Z	Z-	_
_	_	11
_	_	_
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
