#!/usr/bin/perl
# Driver for the CoNLL 2006 Arabic tagset.
# (c) 2007 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::ar::conll;
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
    $f{tagset} = "ar::conll";
    # three components: coarse-grained pos, fine-grained pos, features
    # example: N\tNC\tgender=neuter|number=sing|case=unmarked|def=indef
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    # pos: N Z A S Q V D P C F I G T Y X
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
    # X = non-alphabetic (also used for punctuation in UMH subcorpus)
    # We decode "G" as "punc" and "X" as "" (residual class).
    elsif($pos eq "G")
    {
        $f{pos} = "punc";
    }
    # Although not documented, the data contain the tag "-\t-\tdef=D".
    # It is always assigned to the definite article 'al' if separated from its noun or adjective.
    # Normally the article is not tokenized off and makes the definiteness feature of the noun.
    elsif($pos eq "-")
    {
        $f{pos} = 'adj';
        $f{subpos} = 'art';
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
        if($feature eq "gen")
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
        elsif($feature eq "num")
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
        elsif($feature eq "case")
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
        elsif($feature eq "def")
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
        elsif($feature eq "pers" && $value>=1 && $value<=3)
        {
            $f{person} = $value;
        }
        # mood = D|I|S
        elsif($feature eq "mood")
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
            # D = undecided between subjunctive and jussive
            elsif($value eq "D")
            {
                $f{verbform} = "fin";
                $f{mood} = "jus";
            }
        }
        # voice = P
        elsif($feature eq "voice")
        {
            if($value eq "P")
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
        $tag = "Y\tY";
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
        $tag = "S\tS";
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
    elsif($f{pos} eq "adj")
    {
        if($f{subpos} eq 'art')
        {
            $tag = "-\t-";
        }
        else
        {
            $tag = "A\tA";
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
        elsif($f{prontype} =~ m/^(int|rel)$/)
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
        $tag = "X\tX";
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
        elsif(!($f{tagset} =~ m/^ar::conll(2007)?$/ && $f{other} eq "empty-mood" ||
                $f{person} eq "3" && $f{gender} eq "fem" && $f{number} eq "plu"))
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
    if($f{pos} eq "verb" || $f{prontype} eq "prs")
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
    if($f{definiteness} eq "def" && $f{prontype} ne "dem")
    {
        push(@features, "def=D");
    }
    elsif($f{definiteness} eq "ind")
    {
        push(@features, "def=I");
    }
    elsif($f{definiteness} eq "red")
    {
        push(@features, "def=R");
    }
    elsif($f{definiteness} eq 'com')
    {
        push(@features, 'def=C');
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
# 241
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
A   A   _
A   A   case=1|def=D
A   A   case=1|def=I
A   A   case=1|def=R
A   A   case=2|def=D
A   A   case=2|def=I
A   A   case=2|def=R
A   A   case=4|def=D
A   A   case=4|def=I
A   A   case=4|def=R
A   A   def=D
A   A   gen=F|num=D|case=1|def=I
A   A   gen=F|num=D|case=2|def=D
A   A   gen=F|num=D|def=D
A   A   gen=F|num=P
A   A   gen=F|num=P|def=D
A   A   gen=F|num=S
A   A   gen=F|num=S|case=1|def=D
A   A   gen=F|num=S|case=1|def=I
A   A   gen=F|num=S|case=1|def=R
A   A   gen=F|num=S|case=2|def=D
A   A   gen=F|num=S|case=2|def=I
A   A   gen=F|num=S|case=2|def=R
A   A   gen=F|num=S|case=4|def=D
A   A   gen=F|num=S|case=4|def=I
A   A   gen=F|num=S|case=4|def=R
A   A   gen=F|num=S|def=D
A   A   gen=M|num=D|case=1|def=D
A   A   gen=M|num=D|case=1|def=I
A   A   gen=M|num=D|case=1|def=R
A   A   gen=M|num=D|case=2|def=D
A   A   gen=M|num=D|case=2|def=I
A   A   gen=M|num=D|case=4|def=D
A   A   gen=M|num=D|case=4|def=I
A   A   gen=M|num=D|def=D
A   A   gen=M|num=D|def=I
A   A   gen=M|num=P|case=1|def=D
A   A   gen=M|num=P|case=1|def=I
A   A   gen=M|num=P|case=1|def=R
A   A   gen=M|num=P|case=2|def=D
A   A   gen=M|num=P|case=2|def=I
A   A   gen=M|num=P|case=4|def=D
A   A   gen=M|num=P|case=4|def=I
A   A   gen=M|num=P|def=D
A   A   gen=M|num=P|def=I
A   A   gen=M|num=P|def=R
A   A   gen=M|num=S|case=4|def=I
C   C   _
D   D   _
D   D   case=4|def=R
D   D   gen=M|num=S|case=4|def=I
-   -   def=D
F   F   _
F   FI  _
F   FN  _
F   FN  case=1|def=R
F   FN  case=2|def=R
F   FN  case=4|def=R
G   G   _
I   I   _
I   I   gen=M|num=S|case=4|def=I
N   N   _
N   N   case=1|def=D
N   N   case=1|def=I
N   N   case=1|def=R
N   N   case=2|def=D
N   N   case=2|def=I
N   N   case=2|def=R
N   N   case=4|def=D
N   N   case=4|def=I
N   N   case=4|def=R
N   N   def=D
N   N   gen=F|num=D|case=1|def=D
N   N   gen=F|num=D|case=2|def=D
N   N   gen=F|num=D|case=2|def=I
N   N   gen=F|num=D|case=2|def=R
N   N   gen=F|num=D|case=4|def=D
N   N   gen=F|num=D|case=4|def=I
N   N   gen=F|num=D|case=4|def=R
N   N   gen=F|num=D|def=D
N   N   gen=F|num=D|def=I
N   N   gen=F|num=D|def=R
N   N   gen=F|num=P
N   N   gen=F|num=P|case=1|def=D
N   N   gen=F|num=P|case=1|def=I
N   N   gen=F|num=P|case=1|def=R
N   N   gen=F|num=P|case=2|def=D
N   N   gen=F|num=P|case=2|def=I
N   N   gen=F|num=P|case=2|def=R
N   N   gen=F|num=P|case=4|def=D
N   N   gen=F|num=P|case=4|def=I
N   N   gen=F|num=P|case=4|def=R
N   N   gen=F|num=P|def=D
N   N   gen=F|num=S
N   N   gen=F|num=S|case=1|def=D
N   N   gen=F|num=S|case=1|def=I
N   N   gen=F|num=S|case=1|def=R
N   N   gen=F|num=S|case=2|def=D
N   N   gen=F|num=S|case=2|def=I
N   N   gen=F|num=S|case=2|def=R
N   N   gen=F|num=S|case=4|def=D
N   N   gen=F|num=S|case=4|def=I
N   N   gen=F|num=S|case=4|def=R
N   N   gen=F|num=S|def=C
N   N   gen=F|num=S|def=D
N   N   gen=M|num=D|case=1|def=D
N   N   gen=M|num=D|case=1|def=I
N   N   gen=M|num=D|case=1|def=R
N   N   gen=M|num=D|case=2|def=D
N   N   gen=M|num=D|case=2|def=I
N   N   gen=M|num=D|case=2|def=R
N   N   gen=M|num=D|case=4|def=D
N   N   gen=M|num=D|case=4|def=I
N   N   gen=M|num=D|case=4|def=R
N   N   gen=M|num=D|def=D
N   N   gen=M|num=D|def=I
N   N   gen=M|num=D|def=R
N   N   gen=M|num=P|case=1|def=D
N   N   gen=M|num=P|case=1|def=I
N   N   gen=M|num=P|case=1|def=R
N   N   gen=M|num=P|case=2|def=D
N   N   gen=M|num=P|case=2|def=I
N   N   gen=M|num=P|case=2|def=R
N   N   gen=M|num=P|case=4|def=D
N   N   gen=M|num=P|case=4|def=I
N   N   gen=M|num=P|case=4|def=R
N   N   gen=M|num=P|def=D
N   N   gen=M|num=P|def=I
N   N   gen=M|num=P|def=R
N   N   gen=M|num=S|case=4|def=I
P   P   _
P   P   case=2
P   P   case=4
P   P   gen=F|num=S
Q   Q   _
S   SD  gen=F
S   SD  gen=F|num=S
S   SD  gen=M|num=D
S   SD  gen=M|num=P
S   SD  gen=M|num=S
S   S   pers=1|num=P
S   S   pers=1|num=P|case=1
S   S   pers=1|num=P|case=2
S   S   pers=1|num=P|case=4
S   S   pers=1|num=S
S   S   pers=1|num=S|case=2
S   S   pers=1|num=S|case=4
S   S   pers=2|gen=F|num=S
S   S   pers=2|gen=F|num=S|case=4
S   S   pers=2|gen=M|num=P
S   S   pers=2|gen=M|num=P|case=2
S   S   pers=3|gen=F|num=P
S   S   pers=3|gen=F|num=S
S   S   pers=3|gen=F|num=S|case=1
S   S   pers=3|gen=F|num=S|case=2
S   S   pers=3|gen=F|num=S|case=4
S   S   pers=3|gen=M|num=P
S   S   pers=3|gen=M|num=P|case=1
S   S   pers=3|gen=M|num=P|case=2
S   S   pers=3|gen=M|num=P|case=4
S   S   pers=3|gen=M|num=S
S   S   pers=3|gen=M|num=S|case=1
S   S   pers=3|gen=M|num=S|case=2
S   S   pers=3|gen=M|num=S|case=4
S   S   pers=3|num=D
S   S   pers=3|num=D|case=1
S   S   pers=3|num=D|case=2
S   S   pers=3|num=D|case=4
S   SR  _
V   VI  mood=D|pers=2|gen=M|num=P
V   VI  mood=D|pers=3|gen=M|num=D
V   VI  mood=D|pers=3|gen=M|num=P
V   VI  mood=I|pers=1|num=P
V   VI  mood=I|pers=1|num=S
V   VI  mood=I|pers=2|gen=M|num=P
V   VI  mood=I|pers=2|gen=M|num=S
V   VI  mood=I|pers=3|gen=F|num=D
V   VI  mood=I|pers=3|gen=F|num=S
V   VI  mood=I|pers=3|gen=M|num=D
V   VI  mood=I|pers=3|gen=M|num=P
V   VI  mood=I|pers=3|gen=M|num=S
V   VI  mood=I|voice=P|pers=3|gen=F|num=S
V   VI  mood=I|voice=P|pers=3|gen=M|num=S
V   VI  mood=S|pers=1|num=P
V   VI  mood=S|pers=1|num=S
V   VI  mood=S|pers=3|gen=F|num=S
V   VI  mood=S|pers=3|gen=M|num=S
V   VI  mood=S|voice=P|pers=3|gen=M|num=S
V   VI  pers=1|num=P
V   VI  pers=1|num=S
V   VI  pers=2|gen=M|num=S
V   VI  pers=3|gen=F|num=P
V   VI  pers=3|gen=F|num=S
V   VI  pers=3|gen=M|num=S
V   VI  voice=P|pers=3|gen=F|num=S
V   VI  voice=P|pers=3|gen=M|num=S
V   VP  pers=1|num=P
V   VP  pers=1|num=S
V   VP  pers=2|gen=M|num=P
V   VP  pers=3|gen=F|num=D
V   VP  pers=3|gen=F|num=P
V   VP  pers=3|gen=F|num=S
V   VP  pers=3|gen=M|num=D
V   VP  pers=3|gen=M|num=P
V   VP  pers=3|gen=M|num=S
V   VP  voice=P|pers=3|gen=F|num=S
V   VP  voice=P|pers=3|gen=M|num=P
V   VP  voice=P|pers=3|gen=M|num=S
X   X   _
Y   Y   _
Z   Z   _
Z   Z   case=1|def=D
Z   Z   case=1|def=I
Z   Z   case=1|def=R
Z   Z   case=2|def=D
Z   Z   case=2|def=I
Z   Z   case=2|def=R
Z   Z   case=4|def=D
Z   Z   case=4|def=R
Z   Z   def=D
Z   Z   gen=F|num=D|case=2|def=D
Z   Z   gen=F|num=P|case=1|def=D
Z   Z   gen=F|num=P|case=1|def=I
Z   Z   gen=F|num=P|case=2|def=D
Z   Z   gen=F|num=P|case=4|def=D
Z   Z   gen=F|num=P|case=4|def=I
Z   Z   gen=F|num=P|def=D
Z   Z   gen=F|num=S
Z   Z   gen=F|num=S|case=1|def=D
Z   Z   gen=F|num=S|case=1|def=R
Z   Z   gen=F|num=S|case=2|def=D
Z   Z   gen=F|num=S|case=2|def=I
Z   Z   gen=F|num=S|case=2|def=R
Z   Z   gen=F|num=S|case=4|def=R
Z   Z   gen=F|num=S|def=D
Z   Z   gen=M|num=D|case=1|def=D
Z   Z   gen=M|num=D|case=2|def=D
Z   Z   gen=M|num=P|case=1|def=D
Z   Z   gen=M|num=P|def=D
Z   Z   gen=M|num=P|def=I
Z   Z   gen=M|num=P|def=R
Z   Z   gen=M|num=S|case=4|def=I
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
    use tagset::common;
    # Store the hash reference in a global variable.
    $permitted = tagset::common::get_permitted_structures_joint(list(), \&decode);
}



1;
