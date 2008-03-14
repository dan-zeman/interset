#!/usr/bin/perl
# Driver for the CoNLL 2006 Chinese tagset.
# (Documentation in Huang, Chen, Lin: Corpus on Web: Introducing the First Tagged and Balanced Chinese Corpus)
# (c) 2007 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::zh::conll;
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
    $f{tagset} = "zhconll";
    # three components: coarse-grained pos, fine-grained pos, features
    # features always "_" for Chinese
    # example: N\tNhaa\t_
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    # Sinica subparts of speech are too detailed. Always store them in the "other" feature.
    $f{other} = $subpos;
    # pos: N Ne Ng A V D DE DM C P T I Str Head
    # N = noun
    if($pos eq "N")
    {
        $f{pos} = "noun";
        # Subpos can be longer than 2 characters. We categorize subposes according to the first two characters.
        # subpos: Na Nb Nc Nd Nf Nh Nv
        # Na = common noun
        # Nb = proper noun
        # Nc = location noun
        # Nd = time noun
        # Nf = classifier (measure word)
        # Nh = pronoun
        # Nv = ?
        if($subpos eq "Na")
        {
            $f{subpos} = "";
        }
        elsif($subpos eq "Nb")
        {
            $f{subpos} = "prop";
        }
        elsif($subpos eq "Nc")
        {
            # Location nouns include also some proper nouns, e.g. Feizhou = Africa.
            $f{subpos} = "loc";
        }
        elsif($subpos eq "Nd")
        {
            $f{subpos} = "tim";
        }
        elsif($subpos eq "Nf")
        {
            $f{subpos} = "class";
        }
        elsif($subpos eq "Nh")
        {
            $f{pos} = "pron";
            $f{prontype} = "prs";
        }
        elsif($subpos eq "Nv")
        {
            $f{other}{subpos} = "Nv";
        }
    }
    # A = adjective
    elsif($pos eq "A")
    {
        $f{pos} = "adj";
    }
    # Ne = determiner (zhe = this) or cardinal number (yi = one)
    elsif($pos eq "Ne")
    {
        $f{pos} = "adj";
        # Subpos can be longer than 3 characters. We categorize subposes according to the third character.
        # subpos: Nep Neq Nes Neu
        # Nep = anaforic determiner (this, that)
        # Neq = classifying determiner (much, half)
        # Nes = specific determiner (you, shang, ge=every)
        # Neu = numeric determiner (one, two, three...)
        if($subpos =~ m/^Nep/)
        {
            $f{pos} = "adj";
            $f{prontype} = "dem";
        }
        elsif($subpos =~ m/^Ne[qs]/)
        {
            $f{pos} = "adj";
        }
        elsif($subpos =~ m/^Neu/)
        {
            $f{pos} = "num";
        }
    }
    # V = verb
    elsif($pos eq "V")
    {
        $f{pos} = "verb";
    }
    # D = adverb
    elsif($pos eq "D")
    {
        $f{pos} = "adv";
    }
    # DM = measure word, quantifier
    elsif($pos eq "DM")
    {
        ###!!! There ought to be a better solution but from the examples from the corpus I seem unable to grasp the nature of these words.
        $f{pos} = "adv";
    }
    # Ng = postposition (qian = before)
    elsif($pos eq "Ng")
    {
        $f{pos} = "prep";
    }
    # P = preposition (66 kinds)
    elsif($pos eq "P")
    {
        $f{pos} = "prep";
    }
    # C = conjunction
    elsif($pos eq "C")
    {
        $f{pos} = "conj";
    }
    # DE = "de" particle (two kinds)
    elsif($pos eq "DE")
    {
        $f{pos} = "part";
    }
    # T = particle
    elsif($pos eq "T")
    {
        $f{pos} = "part";
    }
    # I = interjection
    elsif($pos eq "I")
    {
        $f{pos} = "int";
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
    # pos
    if($f{pos} eq "noun")
    {
        $tag = "N";
    }
    elsif($f{pos} =~ m/^(adj|det)$/)
    {
        $tag = "A";
    }
    elsif($f{pos} eq "pron")
    {
        $tag = "N";
    }
    elsif($f{pos} eq "num")
    {
        $tag = "Ne";
    }
    elsif($f{pos} eq "verb")
    {
        $tag = "V";
    }
    elsif($f{pos} eq "adv")
    {
        $tag = "D";
    }
    elsif($f{pos} eq "prep")
    {
        $tag = "P";
    }
    elsif($f{pos} eq "conj")
    {
        $tag = "C";
    }
    elsif($f{pos} eq "part")
    {
        $tag = "T";
    }
    elsif($f{pos} eq "int")
    {
        $tag = "I";
    }
    else
    {
        $tag = "Str";
    }
    # Encode the detailed part of speech. Only if the original tag set was Chinese CoNLL as well.
    if($f{tagset} eq "zhconll")
    {
        # Some detailed parts of speech imply a different main part of speech.
        if($f{other} eq "Head")
        {
            $tag = "Head\tHead";
        }
        elsif($f{other} eq "Str")
        {
            $tag = "Str\tStr";
        }
        # Ne = determiner
        elsif($f{other} =~ m/^Ne/)
        {
            $tag = "Ne\t$f{other}";
        }
        # Ng = postposition
        elsif($f{other} =~ m/^Ng/)
        {
            $tag = "Ng\t$f{other}";
        }
        # DE = some prominent particles
        elsif($f{other} =~ m/^D[Ei]$/)
        {
            $tag = "DE\t$f{other}";
        }
        # DM = measure word
        elsif($f{other} eq "DM")
        {
            $tag = "DM\tDM";
        }
        else
        {
            $tag .= "\t$f{other}";
        }
    }
    else
    {
        # We have to attach pick some subpos so that the resulting tag is known in the Chinese tagset.
        if($f{pos} eq "noun")
        {
            $tag .= "\tNaa";
        }
        elsif($f{pos} =~ m/^(adj|det)$/)
        {
            $tag .= "\tA";
        }
        elsif($f{pos} eq "pron")
        {
            $tag .= "\tNhaa";
        }
        elsif($f{pos} eq "num")
        {
            $tag .= "\tNeu";
        }
        elsif($f{pos} eq "verb")
        {
            $tag .= "\tVA";
        }
        elsif($f{pos} eq "adv")
        {
            $tag .= "\tDaa";
        }
        elsif($f{pos} eq "prep")
        {
            $tag .= "\tP01";
        }
        elsif($f{pos} eq "conj")
        {
            $tag .= "\tCaa";
        }
        elsif($f{pos} eq "part")
        {
            $tag .= "\tTa";
        }
        elsif($f{pos} eq "int")
        {
            $tag .= "\tI";
        }
        else
        {
            $tag .= "\tStr";
        }
    }
    # CoNLL features are empty for Chinese.
    $tag .= "\t_";
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
C\tCaa\t_
C\tCaa[P1]\t_
C\tCaa[P1}\t_
C\tCaa[+P2]\t_
C\tCaa[P2]\t_
C\tCaa[P2}\t_
C\tCab\t_
C\tCbaa\t_
C\tCbab\t_
C\tCbba\t_
C\tCbbb\t_
C\tCbca\t_
C\tCbcb\t_
D\tDaa\t_
D\tDab\t_
D\tDbaa\t_
D\tDbab\t_
D\tDbb\t_
D\tDbc\t_
D\tDc\t_
D\tDd\t_
D\tDfa\t_
D\tDfb\t_
D\tDg\t_
D\tDh\t_
D\tDj\t_
D\tDk\t_
DE\tDE\t_
DE\tDi\t_
DM\tDM\t_
Head\tHead\t_
I\tI\t_
Ne\tNep\t_
Ne\tNeqa\t_
Ne\tNeqb\t_
Ne\tNes\t_
Ne\tNeu\t_
Ng\tNg\t_
N\tNaa\t_
N\tNaa[+SPO]\t_
N\tNab\t_
N\tNab[+SPO]\t_
N\tNac\t_
N\tNac[+SPO]\t_
N\tNad\t_
N\tNad[+SPO]\t_
N\tNaea\t_
N\tNaeb\t_
N\tNba\t_
N\tNbc\t_
N\tNca\t_
N\tNcb\t_
N\tNcc\t_
N\tNcda\t_
N\tNcdb\t_
N\tNce\t_
N\tNdaaa\t_
N\tNdaab\t_
N\tNdaac\t_
N\tNdaad\t_
N\tNdaba\t_
N\tNdabb\t_
N\tNdabc\t_
N\tNdabd\t_
N\tNdabe\t_
N\tNdabf\t_
N\tNdbb\t_
N\tNdc\t_
N\tNdda\t_
N\tNddb\t_
N\tNddc\t_
N\tNfa\t_
N\tNfc\t_
N\tNfd\t_
N\tNfe\t_
N\tNfg\t_
N\tNfh\t_
N\tNfi\t_
N\tNhaa\t_
N\tNhab\t_
N\tNhac\t_
N\tNhb\t_
N\tNhc\t_
N\tNv1\t_
N\tNv2\t_
N\tNv3\t_
N\tNv4\t_
P\tP01\t_
P\tP02\t_
P\tP03\t_
P\tP04\t_
P\tP06\t_
P\tP06[P1]\t_
P\tP06[P2]\t_
P\tP06[+part]\t_
P\tP07\t_
P\tP08\t_
P\tP08[+part]\t_
P\tP09\t_
P\tP10\t_
P\tP11\t_
P\tP11[P1]\t_
P\tP11[P2]\t_
P\tP11[+part]\t_
P\tP12\t_
P\tP13\t_
P\tP14\t_
P\tP15\t_
P\tP16\t_
P\tP17\t_
P\tP18\t_
P\tP18[+part]\t_
P\tP19\t_
P\tP19[P1]\t_
P\tP19[P2]\t_
P\tP19[+part]\t_
P\tP20\t_
P\tP20[+part]\t_
P\tP21\t_
P\tP21[+part]\t_
P\tP22\t_
P\tP23\t_
P\tP24\t_
P\tP25\t_
P\tP26\t_
P\tP27\t_
P\tP28\t_
P\tP29\t_
P\tP30\t_
P\tP31\t_
P\tP31[+P1]\t_
P\tP31[P1]\t_
P\tP31[+P2]\t_
P\tP31[P2]\t_
P\tP31[+part]\t_
P\tP31[part]\t_
P\tP32\t_
P\tP32[+part]\t_
P\tP35\t_
P\tP35[+part]\t_
P\tP36\t_
P\tP37\t_
P\tP38\t_
P\tP39\t_
P\tP40\t_
P\tP41\t_
P\tP42\t_
P\tP42[+part]\t_
P\tP43\t_
P\tP44\t_
P\tP45\t_
P\tP46\t_
P\tP46[+part]\t_
P\tP47\t_
P\tP48\t_
P\tP48[+part]\t_
P\tP49\t_
P\tP50\t_
P\tP51\t_
P\tP52\t_
P\tP53\t_
P\tP54\t_
P\tP55\t_
P\tP55[+part]\t_
P\tP58\t_
P\tP59\t_
P\tP59[+part]\t_
P\tP60\t_
P\tP61\t_
P\tP62\t_
P\tP63\t_
P\tP64\t_
P\tP65\t_
P\tP66\t_
Str\tStr\t_
T\tTa\t_
T\tTb\t_
T\tTc\t_
T\tTd\t_
V\tV_11\t_
V\tV_12\t_
V\tV_2\t_
V\tVA\t_
V\tVA11\t_
V\tVA11[+ASP]\t_
V\tVA11[+NEG]\t_
V\tVA12\t_
V\tVA12[+NEG]\t_
V\tVA12[+SPV]\t_
V\tVA13\t_
V\tVA13[+ASP]\t_
V\tVA2\t_
V\tVA2[+ASP]\t_
V\tVA2[+SPV]\t_
V\tVA3\t_
V\tVA3[+ASP]\t_
V\tVA4\t_
V\tVA4[+ASP]\t_
V\tVA4[+NEG]\t_
V\tVA4[+NEG,+ASP]\t_
V\tVA4[+SPV]\t_
V\tVB11\t_
V\tVB11[+ASP]\t_
V\tVB11[+DE]\t_
V\tVB11[+NEG]\t_
V\tVB11[+SPV]\t_
V\tVB12\t_
V\tVB12[+ASP]\t_
V\tVB12[+NEG]\t_
V\tVB2\t_
V\tVB2[+ASP]\t_
V\tVB2[+NEG]\t_
V\tVC1\t_
V\tVC1[+NEG]\t_
V\tVC1[+SPV]\t_
V\tVC2\t_
V\tVC2[+ASP]\t_
V\tVC2[+DE]\t_
V\tVC2[+NEG]\t_
V\tVC2[+SPV]\t_
V\tVC31\t_
V\tVC31[+ASP]\t_
V\tVC31[+DE]\t_
V\tVC31[+DE,+ASP]\t_
V\tVC31[+NEG]\t_
V\tVC31[+SPV]\t_
V\tVC32\t_
V\tVC32[+DE]\t_
V\tVC32[+SPV]\t_
V\tVC33\t_
V\tVD1\t_
V\tVD2\t_
V\tVD2[+NEG]\t_
V\tVE11\t_
V\tVE12\t_
V\tVE2\t_
V\tVE2[+DE]\t_
V\tVE2[+NEG]\t_
V\tVE2[+SPV]\t_
V\tVF1\t_
V\tVF2\t_
V\tVG1\t_
V\tVG1[+NEG]\t_
V\tVG2\t_
V\tVG2[+DE]\t_
V\tVG2[+NEG]\t_
V\tVH11\t_
V\tVH11[+asp]\t_
V\tVH11[+ASP]\t_
V\tVH11[+DE]\t_
V\tVH11[+NEG]\t_
V\tVH11[+SPV]\t_
V\tVH12\t_
V\tVH12[+ASP]\t_
V\tVH13\t_
V\tVH14\t_
V\tVH15\t_
V\tVH15[+NEG]\t_
V\tVH16\t_
V\tVH16[+ASP]\t_
V\tVH16[+NEG]\t_
V\tVH16[+SPV]\t_
V\tVH17\t_
V\tVH21\t_
V\tVH21[+ASP]\t_
V\tVH21[+Dbab]\t_
V\tVH21[+DE]\t_
V\tVH21[+NEG]\t_
V\tVH22\t_
V\tVI1\t_
V\tVI2\t_
V\tVI2[+ASP]\t_
V\tVI3\t_
V\tVJ1\t_
V\tVJ1[+DE]\t_
V\tVJ1[+NEG]\t_
V\tVJ2\t_
V\tVJ2[+NEG]\t_
V\tVJ2[+SPV]\t_
V\tVJ3\t_
V\tVJ3[+DE]\t_
V\tVJ3[+NEG]\t_
V\tVK1\t_
V\tVK1[+ASP]\t_
V\tVK1[+DE]\t_
V\tVK1[+NEG]\t_
V\tVK2\t_
V\tVK2[+NEG]\t_
V\tVL1\t_
V\tVL2\t_
V\tVL3\t_
V\tVL4\t_
V\tVP\t_
end_of_list
    ;
    my @list = split(/\r?\n/, $list);
    pop(@list) if($list[$#list] eq "");
    return \@list;
}



1;
