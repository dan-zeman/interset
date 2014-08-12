#!/usr/bin/perl
# Driver for the CoNLL 2006 Slovene tagset.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::sl::conll;
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
    $f{tagset} = "sl::conll";
    # three components: coarse-grained pos, fine-grained pos, features
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    # pos: Abbreviation Adjective Adposition Adverb Conjunction Interjection Noun Numeral PUNC Particle Pronoun Verb
    # example: V-B
    if($pos eq 'Abbreviation')
    {
        $f{abbr} = 'abbr';
    }
    # example: mali
    elsif($pos eq 'Adjective')
    {
        $f{pos} = 'adj';
        # subpos: ordinal, possessive, qualificative
        # example ordinal: mali, partijske, zunanjim, srednjih, azijskimi
        # example qualificative: boljše, kasnejšimi, revnejših, pomembnejše, močnejšo
        # example possessive: O'Brienovih, Časnikovih, nageljnovimi, dečkovih, starčeve
        # Ordinal adjectives, unlike qualificative, cannot be graded. Interset currently does not provide for this distinction.
        if($subpos eq 'Adjective-possessive')
        {
            $f{poss} = 'poss';
        }
        elsif($subpos eq 'Adjective-ordinal')
        {
            $f{other}{subpos} = 'ordinal';
        }
    }
    # example: nanj, v, proti
    elsif($pos eq 'Adposition')
    {
        $f{pos} = 'prep';
        # subpos: preposition
    }
    # example: več, hitro, najbolj
    elsif($pos eq 'Adverb')
    {
        $f{pos} = 'adv';
        # subpos: general
    }
    # example: in, da
    elsif($pos eq 'Conjunction')
    {
        $f{pos} = 'conj';
        # subpos: coordinating, subordinating
        if($subpos eq 'Conjunction-coordinating')
        {
            $f{subpos} = 'coor';
        }
        else
        {
            $f{subpos} = 'sub';
        }
    }
    # example: oh
    elsif($pos eq 'Interjection')
    {
        $f{pos} = 'int';
    }
    # example: ploščici, sil, neznankama, stvari, prsi
    elsif($pos eq 'Noun')
    {
        $f{pos} = 'noun';
        # subpos: common, proper
        if($subpos eq 'Noun-proper')
        {
            $f{subpos} = 'prop';
        }
    }
    # example: 1984, dve
    elsif($pos eq 'Numeral')
    {
        $f{pos} = 'num';
        # subpos: cardinal, multiple, ordinal, special
        # example cardinal: eno, dve, tri
        # example multiple: dvojno
        # example ordinal: prvi, drugi, tretje, devetnajstega
        # example special: dvoje, enkratnem
        if($subpos eq 'Numeral-cardinal')
        {
            $f{numtype} = 'card';
        }
        elsif($subpos eq 'Numeral-multiple')
        {
            $f{numtype} = 'mult';
        }
        elsif($subpos eq 'Numeral-ordinal')
        {
            $f{numtype} = 'ord';
        }
        elsif($subpos eq 'Numeral-special')
        {
            $f{numtype} = 'gen';
        }
    }
    # example: ,
    elsif($pos eq 'PUNC')
    {
        $f{pos} = 'punc';
    }
    # example: ne
    elsif($pos eq 'Particle')
    {
        $f{pos} = 'part';
    }
    # example: take, tem, tistih, teh, takimi
    elsif($pos eq 'Pronoun')
    {
        $f{pos} = 'noun';
        # subpos: demonstrative, general, indefinite, interrogative, negative, personal, possessive, reflexive, relative
        # example demonstrative: take, tem, tistih, teh, takimi
        # example general: vsakdo, obe, vse, vsemi, vsakih
        # example indefinite: koga, nekoga, nekatere, druge, isti
        # example interrogative: koga, česa, čem, kaj, koliko
        # example negative: nič, nikakršne, nobeni, nobenega, nobenem
        # example personal: jaz, ti, on, ona, mi, vi, oni
        # example possessive: moj, tvoj, njegove, naše, vašo, njihove
        # example reflexive: sebe, se, sebi, si, seboj, svoj, svoja
        # example relative: kar, česar, čimer, kdorkoli, katerih, kakršna, kolikor
        if($subpos eq 'Pronoun-demonstrative')
        {
            $f{prontype} = 'dem';
        }
        elsif($subpos eq 'Pronoun-general')
        {
            $f{prontype} = 'tot';
        }
        elsif($subpos eq 'Pronoun-indefinite')
        {
            $f{prontype} = 'ind';
        }
        elsif($subpos eq 'Pronoun-interrogative')
        {
            $f{prontype} = 'int';
        }
        elsif($subpos eq 'Pronoun-negative')
        {
            $f{prontype} = 'neg';
        }
        elsif($subpos eq 'Pronoun-personal')
        {
            $f{prontype} = 'prs';
        }
        elsif($subpos eq 'Pronoun-possessive')
        {
            $f{prontype} = 'prs';
            $f{poss} = 'poss';
        }
        elsif($subpos eq 'Pronoun-reflexive')
        {
            $f{prontype} = 'prs';
            $f{reflex} = 'reflex';
            if($features =~ m/Referent-Type=possessive/)
            {
                $f{poss} = 'poss';
            }
        }
        elsif($subpos eq 'Pronoun-relative')
        {
            $f{prontype} = 'rel';
        }
    }
    # example: bi, bova, bomo, bom, boste
    elsif($pos eq 'Verb')
    {
        $f{pos} = 'verb';
        # subpos: copula, main, modal
        # example copula: bi, bova, bomo, bom, boste, boš, bosta, bodo, bo, sva, smo, nismo, sem, nisem, ste, si, nisi, sta, nista, so, niso, je, ni, bili, bila, bile, bil, bilo
        # example main: vzemiva, dajmo, krčite, bodi, greva
        # example modal: moremo, hočem, želiš, dovoljene, mogla
        if($subpos eq 'Verb-copula')
        {
            $f{subpos} = 'cop';
        }
        elsif($subpos eq 'Verb-modal')
        {
            $f{subpos} = 'mod';
        }
    }
    # Decode feature values.
    # Degree=positive|comparative|superlative
    # Gender=feminine|masculine|neuter
    # Number=dual|plural|singular
    # Case=nominative|accusative|dative|genitive|instrumental|locative
    # Formation=compound|simple (Adposition)
    # Form=digit|letter (Numeral)
    # Syntactic-Type=adjectival|nominal (Pronoun)
    # Clitic=yes|no (Pronoun)
    # Owner-Number=plural|singular|dual
    # Owner-Gender=feminine|masculine
    # Referent-Type=personal|possessive (Pronoun-reflexive)
    # VForm=conditional|indicative|participle|imperative|supine
    # Tense=future|present|past
    # Person=first|second|third
    # Negative=no|yes
    # Voice=active|passive
    my @features = split(/\|/, $features);
    foreach my $fv (@features)
    {
        my ($feature, $value) = split(/=/, $fv);
        if($feature eq 'Degree') # positive|comparative|superlative
        {
            if($value eq 'positive')
            {
                $f{degree} = 'pos';
            }
            elsif($value eq 'comparative')
            {
                $f{degree} = 'comp';
            }
            elsif($value eq 'superlative')
            {
                $f{degree} = 'sup';
            }
        }
        elsif($feature eq 'Gender') # masculine|feminine|neuter
        {
            if($value eq 'masculine')
            {
                $f{gender} = 'masc';
            }
            elsif($value eq 'feminine')
            {
                $f{gender} = 'fem';
            }
            elsif($value eq 'neuter')
            {
                $f{gender} = 'neut';
            }
        }
        elsif($feature eq 'Number') # singular|dual|plural
        {
            if($value eq 'singular')
            {
                $f{number} = 'sing';
            }
            elsif($value eq 'dual')
            {
                $f{number} = 'dual';
            }
            elsif($value eq 'plural')
            {
                $f{number} = 'plu'
            }
        }
        elsif($feature eq 'Case') # nominative|genitive|dative|accusative|locative|instrumental
        {
            $f{case} = substr($value, 0, 3);
        }
        elsif($feature eq 'Formation') # simple|compound (adpositions)
        {
            if($value eq 'compound')
            {
                $f{subpos} = 'comprep';
            }
        }
        elsif($feature eq 'Form') # digit|letter
        {
            if($value eq 'digit')
            {
                $f{numform} = 'digit';
            }
            elsif($value eq 'letter')
            {
                $f{numform} = 'word';
            }
        }
        elsif($feature eq 'Syntactic-Type') # nominal|adjectival
        {
            if($value eq 'nominal')
            {
                $f{synpos} = 'subst';
            }
            elsif($value eq 'adjectival')
            {
                $f{synpos} = 'attr';
            }
        }
        elsif($feature eq 'Clitic') # yes|no
        {
            # no examples:  mene meni tebe njiju njih njo njej nje njega njemu sebe sebi
            # yes examples: me   mi   te   ju    jih  jo  ji   je  ga    mu    se   si
            if($value eq 'yes')
            {
                # I am taking the same approach as in cs::pdt.
                # In future we may prefer to introduce $f{clitic} = 'clitic' in Interset.
                $f{variant} = 'short';
            }
        }
        elsif($feature eq 'Owner-Number') # singular|dual|plural
        {
            if($value eq 'singular')
            {
                $f{possnumber} = 'sing';
            }
            elsif($value eq 'dual')
            {
                $f{possnumber} = 'dual';
            }
            elsif($value eq 'plural')
            {
                $f{possnumber} = 'plu';
            }
        }
        elsif($feature eq 'Owner-Gender') # masculine|feminine
        {
            if($value eq 'masculine')
            {
                $f{possgender} = 'masc';
            }
            elsif($value eq 'feminine')
            {
                $f{possgender} = 'fem';
            }
        }
        elsif($feature eq 'Referent-Type') # personal|possessive
        {
            # Used to subclassify pronouns, nothing left to do here.
        }
        elsif($feature eq 'VForm') # infinitive|indicative|imperative|conditional|participle|supine
        {
            if($value eq 'infinitive')
            {
                $f{verbform} = 'inf';
            }
            elsif($value eq 'indicative')
            {
                $f{verbform} = 'fin';
                $f{mood} = 'ind';
            }
            elsif($value eq 'imperative')
            {
                $f{verbform} = 'fin';
                $f{mood} = 'imp';
            }
            elsif($value eq 'conditional')
            {
                $f{verbform} = 'fin';
                $f{mood} = 'cnd';
            }
            elsif($value eq 'participle')
            {
                $f{verbform} = 'part';
            }
            elsif($value eq 'supine')
            {
                $f{verbform} = 'sup';
            }
        }
        elsif($feature eq 'Tense') # past|present|future
        {
            if($value eq 'past')
            {
                $f{tense} = 'past';
            }
            elsif($value eq 'present')
            {
                $f{tense} = 'pres';
            }
            elsif($value eq 'future')
            {
                $f{tense} = 'fut';
            }
        }
        elsif($feature eq 'Person') # first|second|third
        {
            if($value eq 'first')
            {
                $f{person} = 1;
            }
            elsif($value eq 'second')
            {
                $f{person} = 2;
            }
            elsif($value eq 'third')
            {
                $f{person} = 3;
            }
        }
        elsif($feature eq 'Negative') # yes|no
        {
            if($value eq 'yes')
            {
                $f{negativeness} = 'neg';
            }
            elsif($value eq 'no')
            {
                $f{negativeness} = 'pos';
            }
        }
        elsif($feature eq 'Voice') # active|passive
        {
            if($value eq 'active')
            {
                $f{voice} = 'act';
            }
            elsif($value eq 'passive')
            {
                $f{voice} = 'pass';
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
    # Add the features to the part of speech.
    my @features;
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
# 671 after cleaning and adding 'other'-resistant tags
#------------------------------------------------------------------------------
sub list
{
    my $list = <<end_of_list
Abbreviation	Abbreviation	_
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=dual|Case=nominative
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=plural|Case=accusative
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=plural|Case=dative
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=plural|Case=genitive
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=plural|Case=instrumental
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=plural|Case=locative
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=plural|Case=nominative
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=singular|Case=accusative
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=singular|Case=dative
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=singular|Case=genitive
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=singular|Case=instrumental
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=singular|Case=locative
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=singular|Case=nominative
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=dual|Case=nominative
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=plural|Case=accusative
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=plural|Case=genitive
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=plural|Case=instrumental
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=plural|Case=locative
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=plural|Case=nominative
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=singular|Case=accusative|Animate=no
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=singular|Case=accusative|Animate=yes
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=singular|Case=genitive
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=singular|Case=instrumental
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=singular|Case=locative
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=singular|Case=nominative
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=plural|Case=accusative
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=plural|Case=genitive
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=plural|Case=instrumental
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=plural|Case=nominative
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=singular|Case=accusative
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=singular|Case=dative
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=singular|Case=genitive
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=singular|Case=instrumental
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=singular|Case=locative
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=singular|Case=nominative
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=dual|Case=genitive
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=plural|Case=genitive
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=plural|Case=instrumental
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=plural|Case=locative
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=plural|Case=nominative
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=singular|Case=accusative
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=singular|Case=genitive
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=singular|Case=locative
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=singular|Case=nominative
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=plural|Case=accusative
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=plural|Case=genitive
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=plural|Case=locative
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=singular|Case=accusative|Animate=no
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=singular|Case=accusative|Animate=yes
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=singular|Case=dative
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=singular|Case=genitive
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=singular|Case=instrumental
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=singular|Case=locative
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=singular|Case=nominative
Adjective	Adjective-possessive	Degree=positive|Gender=neuter|Number=plural|Case=accusative
Adjective	Adjective-possessive	Degree=positive|Gender=neuter|Number=singular|Case=accusative
Adjective	Adjective-possessive	Degree=positive|Gender=neuter|Number=singular|Case=instrumental
Adjective	Adjective-possessive	Degree=positive|Gender=neuter|Number=singular|Case=nominative
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=plural|Case=accusative
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=plural|Case=instrumental
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=plural|Case=locative
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=plural|Case=nominative
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=singular|Case=accusative
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=singular|Case=dative
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=singular|Case=genitive
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=singular|Case=instrumental
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=singular|Case=locative
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=singular|Case=nominative
Adjective	Adjective-qualificative	Degree=comparative|Gender=masculine|Number=plural|Case=accusative
Adjective	Adjective-qualificative	Degree=comparative|Gender=masculine|Number=plural|Case=genitive
Adjective	Adjective-qualificative	Degree=comparative|Gender=masculine|Number=plural|Case=nominative
Adjective	Adjective-qualificative	Degree=comparative|Gender=masculine|Number=singular|Case=accusative|Animate=no
Adjective	Adjective-qualificative	Degree=comparative|Gender=masculine|Number=singular|Case=accusative|Animate=yes
Adjective	Adjective-qualificative	Degree=comparative|Gender=masculine|Number=singular|Case=genitive
Adjective	Adjective-qualificative	Degree=comparative|Gender=masculine|Number=singular|Case=locative
Adjective	Adjective-qualificative	Degree=comparative|Gender=masculine|Number=singular|Case=nominative
Adjective	Adjective-qualificative	Degree=comparative|Gender=neuter|Number=plural|Case=accusative
Adjective	Adjective-qualificative	Degree=comparative|Gender=neuter|Number=singular|Case=accusative
Adjective	Adjective-qualificative	Degree=comparative|Gender=neuter|Number=singular|Case=locative
Adjective	Adjective-qualificative	Degree=comparative|Gender=neuter|Number=singular|Case=nominative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=dual|Case=accusative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=dual|Case=nominative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=plural|Case=accusative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=plural|Case=dative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=plural|Case=genitive
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=plural|Case=instrumental
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=plural|Case=locative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=plural|Case=nominative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=singular|Case=accusative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=singular|Case=dative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=singular|Case=genitive
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=singular|Case=instrumental
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=singular|Case=locative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=singular|Case=nominative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=dual|Case=accusative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=dual|Case=genitive
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=dual|Case=instrumental
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=dual|Case=nominative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=plural|Case=accusative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=plural|Case=dative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=plural|Case=genitive
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=plural|Case=instrumental
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=plural|Case=locative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=plural|Case=nominative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=accusative|Animate=yes
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=accusative|Definiteness=no|Animate=no
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=accusative|Definiteness=yes|Animate=no
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=dative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=genitive
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=instrumental
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=locative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=nominative|Definiteness=no
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=nominative|Definiteness=yes
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=plural|Case=accusative
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=plural|Case=genitive
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=plural|Case=instrumental
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=plural|Case=locative
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=plural|Case=nominative
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=singular|Case=accusative
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=singular|Case=dative
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=singular|Case=genitive
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=singular|Case=instrumental
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=singular|Case=locative
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=singular|Case=nominative
Adjective	Adjective-qualificative	Degree=superlative|Gender=feminine|Number=singular|Case=accusative
Adjective	Adjective-qualificative	Degree=superlative|Gender=feminine|Number=singular|Case=genitive
Adjective	Adjective-qualificative	Degree=superlative|Gender=feminine|Number=singular|Case=nominative
Adjective	Adjective-qualificative	Degree=superlative|Gender=masculine|Number=plural|Case=genitive
Adjective	Adjective-qualificative	Degree=superlative|Gender=masculine|Number=plural|Case=locative
Adjective	Adjective-qualificative	Degree=superlative|Gender=masculine|Number=singular|Case=accusative|Animate=no
Adjective	Adjective-qualificative	Degree=superlative|Gender=masculine|Number=singular|Case=genitive
Adjective	Adjective-qualificative	Degree=superlative|Gender=masculine|Number=singular|Case=locative
Adjective	Adjective-qualificative	Degree=superlative|Gender=masculine|Number=singular|Case=nominative
Adjective	Adjective-qualificative	Degree=superlative|Gender=neuter|Number=singular|Case=genitive
Adjective	Adjective-qualificative	Degree=superlative|Gender=neuter|Number=singular|Case=nominative
Adposition	Adposition-preposition	Formation=compound
Adposition	Adposition-preposition	Formation=simple|Case=accusative
Adposition	Adposition-preposition	Formation=simple|Case=dative
Adposition	Adposition-preposition	Formation=simple|Case=genitive
Adposition	Adposition-preposition	Formation=simple|Case=instrumental
Adposition	Adposition-preposition	Formation=simple|Case=locative
Adverb	Adverb-general	Degree=comparative
Adverb	Adverb-general	Degree=positive
Adverb	Adverb-general	Degree=superlative
Conjunction	Conjunction-coordinating	Formation=simple
Conjunction	Conjunction-subordinating	Formation=simple
Interjection	Interjection	_
Noun	Noun-common	Gender=feminine|Number=dual|Case=accusative
Noun	Noun-common	Gender=feminine|Number=dual|Case=genitive
Noun	Noun-common	Gender=feminine|Number=dual|Case=instrumental
Noun	Noun-common	Gender=feminine|Number=dual|Case=nominative
Noun	Noun-common	Gender=feminine|Number=plural|Case=accusative
Noun	Noun-common	Gender=feminine|Number=plural|Case=dative
Noun	Noun-common	Gender=feminine|Number=plural|Case=genitive
Noun	Noun-common	Gender=feminine|Number=plural|Case=instrumental
Noun	Noun-common	Gender=feminine|Number=plural|Case=locative
Noun	Noun-common	Gender=feminine|Number=plural|Case=nominative
Noun	Noun-common	Gender=feminine|Number=singular|Case=accusative
Noun	Noun-common	Gender=feminine|Number=singular|Case=dative
Noun	Noun-common	Gender=feminine|Number=singular|Case=genitive
Noun	Noun-common	Gender=feminine|Number=singular|Case=instrumental
Noun	Noun-common	Gender=feminine|Number=singular|Case=locative
Noun	Noun-common	Gender=feminine|Number=singular|Case=nominative
Noun	Noun-common	Gender=masculine|Number=dual|Case=accusative
Noun	Noun-common	Gender=masculine|Number=dual|Case=dative
Noun	Noun-common	Gender=masculine|Number=dual|Case=instrumental
Noun	Noun-common	Gender=masculine|Number=dual|Case=locative
Noun	Noun-common	Gender=masculine|Number=dual|Case=nominative
Noun	Noun-common	Gender=masculine|Number=plural|Case=accusative
Noun	Noun-common	Gender=masculine|Number=plural|Case=dative
Noun	Noun-common	Gender=masculine|Number=plural|Case=genitive
Noun	Noun-common	Gender=masculine|Number=plural|Case=instrumental
Noun	Noun-common	Gender=masculine|Number=plural|Case=locative
Noun	Noun-common	Gender=masculine|Number=plural|Case=nominative
Noun	Noun-common	Gender=masculine|Number=singular
Noun	Noun-common	Gender=masculine|Number=singular|Case=accusative|Animate=no
Noun	Noun-common	Gender=masculine|Number=singular|Case=accusative|Animate=yes
Noun	Noun-common	Gender=masculine|Number=singular|Case=dative
Noun	Noun-common	Gender=masculine|Number=singular|Case=genitive
Noun	Noun-common	Gender=masculine|Number=singular|Case=instrumental
Noun	Noun-common	Gender=masculine|Number=singular|Case=locative
Noun	Noun-common	Gender=masculine|Number=singular|Case=nominative
Noun	Noun-common	Gender=neuter|Number=dual|Case=accusative
Noun	Noun-common	Gender=neuter|Number=dual|Case=genitive
Noun	Noun-common	Gender=neuter|Number=dual|Case=locative
Noun	Noun-common	Gender=neuter|Number=dual|Case=nominative
Noun	Noun-common	Gender=neuter|Number=plural|Case=accusative
Noun	Noun-common	Gender=neuter|Number=plural|Case=dative
Noun	Noun-common	Gender=neuter|Number=plural|Case=genitive
Noun	Noun-common	Gender=neuter|Number=plural|Case=instrumental
Noun	Noun-common	Gender=neuter|Number=plural|Case=locative
Noun	Noun-common	Gender=neuter|Number=plural|Case=nominative
Noun	Noun-common	Gender=neuter|Number=singular|Case=accusative
Noun	Noun-common	Gender=neuter|Number=singular|Case=dative
Noun	Noun-common	Gender=neuter|Number=singular|Case=genitive
Noun	Noun-common	Gender=neuter|Number=singular|Case=instrumental
Noun	Noun-common	Gender=neuter|Number=singular|Case=locative
Noun	Noun-common	Gender=neuter|Number=singular|Case=nominative
Noun	Noun-proper	Gender=feminine|Number=singular|Case=accusative
Noun	Noun-proper	Gender=feminine|Number=singular|Case=genitive
Noun	Noun-proper	Gender=feminine|Number=singular|Case=instrumental
Noun	Noun-proper	Gender=feminine|Number=singular|Case=locative
Noun	Noun-proper	Gender=feminine|Number=singular|Case=nominative
Noun	Noun-proper	Gender=masculine|Number=plural|Case=genitive
Noun	Noun-proper	Gender=masculine|Number=singular|Case=accusative|Animate=no
Noun	Noun-proper	Gender=masculine|Number=singular|Case=accusative|Animate=yes
Noun	Noun-proper	Gender=masculine|Number=singular|Case=dative
Noun	Noun-proper	Gender=masculine|Number=singular|Case=genitive
Noun	Noun-proper	Gender=masculine|Number=singular|Case=instrumental
Noun	Noun-proper	Gender=masculine|Number=singular|Case=locative
Noun	Noun-proper	Gender=masculine|Number=singular|Case=nominative
Noun	Noun-proper	Gender=neuter|Number=singular|Case=genitive
Noun	Noun-proper	Gender=neuter|Number=singular|Case=locative
Numeral	Numeral-cardinal	Form=digit
Numeral	Numeral-cardinal	Gender=feminine|Number=dual|Case=accusative|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=dual|Case=genitive|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=dual|Case=instrumental|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=dual|Case=nominative|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=plural|Case=accusative|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=plural|Case=genitive|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=plural|Case=instrumental|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=plural|Case=locative|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=plural|Case=nominative|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=singular|Case=accusative|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=singular|Case=dative|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=singular|Case=genitive|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=singular|Case=instrumental|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=singular|Case=locative|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=singular|Case=nominative|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=dual|Case=accusative|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=dual|Case=instrumental|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=dual|Case=nominative|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=plural|Case=accusative|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=plural|Case=instrumental|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=plural|Case=locative|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=plural|Case=nominative|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=singular|Case=accusative|Form=letter|Animate=no
Numeral	Numeral-cardinal	Gender=masculine|Number=singular|Case=accusative|Form=letter|Animate=yes
Numeral	Numeral-cardinal	Gender=masculine|Number=singular|Case=genitive|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=singular|Case=instrumental|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=singular|Case=locative|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=singular|Case=nominative|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=dual|Case=accusative|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=dual|Case=genitive|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=dual|Case=locative|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=plural|Case=accusative|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=plural|Case=genitive|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=plural|Case=instrumental|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=plural|Case=locative|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=plural|Case=nominative|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=singular|Case=accusative|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=singular|Case=genitive|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=singular|Case=instrumental|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=singular|Case=locative|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=singular|Case=nominative|Form=letter
Numeral	Numeral-multiple	Gender=feminine|Number=singular|Case=instrumental|Form=letter
Numeral	Numeral-ordinal	Form=digit
Numeral	Numeral-ordinal	Gender=feminine|Number=plural|Case=accusative|Form=letter
Numeral	Numeral-ordinal	Gender=feminine|Number=plural|Case=genitive|Form=letter
Numeral	Numeral-ordinal	Gender=feminine|Number=singular|Case=accusative|Form=letter
Numeral	Numeral-ordinal	Gender=feminine|Number=singular|Case=genitive|Form=letter
Numeral	Numeral-ordinal	Gender=feminine|Number=singular|Case=locative|Form=letter
Numeral	Numeral-ordinal	Gender=feminine|Number=singular|Case=nominative|Form=letter
Numeral	Numeral-ordinal	Gender=masculine|Number=singular|Case=accusative|Form=letter|Animate=no
Numeral	Numeral-ordinal	Gender=masculine|Number=singular|Case=genitive|Form=letter
Numeral	Numeral-ordinal	Gender=masculine|Number=singular|Case=instrumental|Form=letter
Numeral	Numeral-ordinal	Gender=masculine|Number=singular|Case=locative|Form=letter
Numeral	Numeral-ordinal	Gender=masculine|Number=singular|Case=nominative|Form=letter
Numeral	Numeral-ordinal	Gender=neuter|Number=plural|Case=accusative|Form=letter
Numeral	Numeral-ordinal	Gender=neuter|Number=plural|Case=genitive|Form=letter
Numeral	Numeral-ordinal	Gender=neuter|Number=plural|Case=locative|Form=letter
Numeral	Numeral-ordinal	Gender=neuter|Number=singular|Case=accusative|Form=letter
Numeral	Numeral-ordinal	Gender=neuter|Number=singular|Case=genitive|Form=letter
Numeral	Numeral-ordinal	Gender=neuter|Number=singular|Case=instrumental|Form=letter
Numeral	Numeral-ordinal	Gender=neuter|Number=singular|Case=locative|Form=letter
Numeral	Numeral-ordinal	Gender=neuter|Number=singular|Case=nominative|Form=letter
Numeral	Numeral-special	Gender=feminine|Number=plural|Case=accusative|Form=letter
Numeral	Numeral-special	Gender=masculine|Number=singular|Case=locative|Form=letter
PUNC	PUNC	_
Particle	Particle	_
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=plural|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=plural|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=plural|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=singular|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=singular|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=singular|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=adjectival|Animate=yes
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=nominal|Animate=no
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=dative|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=dative|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=locative|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Case=dative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=feminine|Number=dual|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=dual|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=feminine|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=plural|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=feminine|Number=plural|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=plural|Case=locative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=feminine|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=plural|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=locative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=dual|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=masculine|Number=dual|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=dual|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=masculine|Number=dual|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=masculine|Number=plural|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=masculine|Number=plural|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=plural|Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=masculine|Number=plural|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=adjectival|Animate=yes
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=nominal|Animate=no
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=dual|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=neuter|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=dative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Case=dative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=feminine|Number=dual|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=dative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=masculine|Number=dual|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=adjectival|Animate=yes
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=nominal|Animate=yes
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=locative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=neuter|Number=dual|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=neuter|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=neuter|Number=singular|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=neuter|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=neuter|Number=singular|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=neuter|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=neuter|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=neuter|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=neuter|Number=singular|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Syntactic-Type=adjectival
Pronoun	Pronoun-interrogative	Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-interrogative	Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-interrogative	Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-interrogative	Case=locative|Syntactic-Type=nominal
Pronoun	Pronoun-interrogative	Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-interrogative	Gender=feminine|Number=plural|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-interrogative	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-interrogative	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-interrogative	Gender=masculine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-interrogative	Gender=masculine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-interrogative	Gender=neuter|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-interrogative	Gender=neuter|Number=singular|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-interrogative	Gender=neuter|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-interrogative	Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-negative	Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-negative	Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-negative	Gender=feminine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=feminine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=masculine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=masculine|Number=singular|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=masculine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=masculine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=masculine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=neuter|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=neuter|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=neuter|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Syntactic-Type=adjectival
Pronoun	Pronoun-personal	Person=first|Number=dual|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=plural|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=plural|Case=genitive|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=plural|Case=nominative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=singular|Case=accusative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=singular|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=singular|Case=dative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=singular|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=singular|Case=genitive|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=singular|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=singular|Case=nominative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=plural|Case=accusative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=plural|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=plural|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=plural|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=plural|Case=nominative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=singular|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=singular|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=singular|Case=genitive|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=singular|Case=genitive|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=singular|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=singular|Case=locative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=singular|Case=nominative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=dual|Case=accusative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=dual|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=dual|Case=genitive|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=dual|Case=nominative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=plural|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=plural|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=plural|Case=genitive|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=plural|Case=genitive|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=accusative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=dative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=genitive|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=genitive|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=locative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=nominative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=dual|Case=accusative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=dual|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=dual|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=dual|Case=genitive|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=dual|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=plural|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=plural|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=plural|Case=genitive|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=plural|Case=genitive|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=plural|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=plural|Case=locative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=accusative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=dative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=genitive|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=genitive|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=locative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=nominative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=neuter|Number=plural|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=neuter|Number=singular|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=neuter|Number=singular|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=neuter|Number=singular|Case=locative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-possessive	Person=first|Gender=feminine|Number=plural|Case=nominative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=feminine|Number=singular|Case=genitive|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=feminine|Number=singular|Case=genitive|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=feminine|Number=singular|Case=locative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=feminine|Number=singular|Case=nominative|Owner-Number=dual|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=feminine|Number=singular|Case=nominative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=feminine|Number=singular|Case=nominative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=masculine|Number=dual|Case=nominative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=masculine|Number=plural|Case=genitive|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=masculine|Number=plural|Case=locative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=masculine|Number=singular|Case=accusative|Owner-Number=dual|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-possessive	Person=first|Gender=masculine|Number=singular|Case=locative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=masculine|Number=singular|Case=nominative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=neuter|Number=plural|Case=accusative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=neuter|Number=plural|Case=nominative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=neuter|Number=singular|Case=locative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=neuter|Number=singular|Case=nominative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=feminine|Number=plural|Case=instrumental|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=feminine|Number=plural|Case=locative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=feminine|Number=singular|Case=accusative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=feminine|Number=singular|Case=locative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=feminine|Number=singular|Case=nominative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=masculine|Number=plural|Case=accusative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=masculine|Number=singular|Case=accusative|Owner-Number=singular|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-possessive	Person=second|Gender=masculine|Number=singular|Case=genitive|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=masculine|Number=singular|Case=locative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=masculine|Number=singular|Case=nominative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=neuter|Number=singular|Case=genitive|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=neuter|Number=singular|Case=locative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=neuter|Number=singular|Case=nominative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=accusative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=accusative|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=accusative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=dative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=genitive|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=genitive|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=instrumental|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=locative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=nominative|Owner-Number=dual|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=nominative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=nominative|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=nominative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=accusative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=accusative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=dative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=genitive|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=genitive|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=genitive|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=instrumental|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=locative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=nominative|Owner-Number=dual|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=nominative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=nominative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=nominative|Owner-Number=singular|Owner-Gender=neuter|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=dual|Case=locative|Owner-Number=dual|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=accusative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=genitive|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=genitive|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=genitive|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=instrumental|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=instrumental|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=locative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=locative|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=nominative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=nominative|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=nominative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=accusative|Owner-Number=dual|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=accusative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=genitive|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=genitive|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=genitive|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=instrumental|Owner-Number=dual|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=instrumental|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=locative|Owner-Number=dual|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=locative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=nominative|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=nominative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=plural|Case=accusative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=plural|Case=accusative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=plural|Case=genitive|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=plural|Case=genitive|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=plural|Case=locative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=plural|Case=nominative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=plural|Case=nominative|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=plural|Case=nominative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=accusative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=accusative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=dative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=genitive|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=instrumental|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=locative|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=locative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=nominative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=nominative|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=nominative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Case=accusative|Clitic=no|Referent-Type=personal|Syntactic-Type=nominal
Pronoun	Pronoun-reflexive	Case=accusative|Clitic=yes|Referent-Type=personal|Syntactic-Type=nominal
Pronoun	Pronoun-reflexive	Case=dative|Clitic=no|Referent-Type=personal|Syntactic-Type=nominal
Pronoun	Pronoun-reflexive	Case=dative|Clitic=yes|Referent-Type=personal|Syntactic-Type=nominal
Pronoun	Pronoun-reflexive	Case=genitive|Clitic=no|Referent-Type=personal|Syntactic-Type=nominal
Pronoun	Pronoun-reflexive	Case=instrumental|Clitic=no|Referent-Type=personal|Syntactic-Type=nominal
Pronoun	Pronoun-reflexive	Case=locative|Clitic=no|Referent-Type=personal|Syntactic-Type=nominal
Pronoun	Pronoun-reflexive	Clitic=yes
Pronoun	Pronoun-reflexive	Gender=feminine|Number=plural|Case=accusative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=plural|Case=dative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=plural|Case=genitive|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=plural|Case=instrumental|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=plural|Case=locative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=singular|Case=accusative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=singular|Case=dative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=singular|Case=genitive|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=singular|Case=instrumental|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=singular|Case=locative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=masculine|Number=plural|Case=accusative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=masculine|Number=plural|Case=genitive|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=masculine|Number=plural|Case=instrumental|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=masculine|Number=plural|Case=locative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=masculine|Number=singular|Case=accusative|Referent-Type=possessive|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-reflexive	Gender=masculine|Number=singular|Case=accusative|Referent-Type=possessive|Syntactic-Type=adjectival|Animate=yes
Pronoun	Pronoun-reflexive	Gender=masculine|Number=singular|Case=genitive|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=masculine|Number=singular|Case=instrumental|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=masculine|Number=singular|Case=locative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=neuter|Number=plural|Case=accusative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=neuter|Number=plural|Case=locative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=neuter|Number=singular|Case=accusative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=neuter|Number=singular|Case=genitive|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=neuter|Number=singular|Case=locative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-relative	Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-relative	Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-relative	Case=locative|Syntactic-Type=nominal
Pronoun	Pronoun-relative	Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-relative	Gender=feminine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=feminine|Number=plural|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=feminine|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=feminine|Number=singular|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=feminine|Number=singular|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=feminine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=feminine|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=feminine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=masculine|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=masculine|Number=plural|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=masculine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=masculine|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=adjectival|Animate=yes
Pronoun	Pronoun-relative	Gender=masculine|Number=singular|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=masculine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=masculine|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=masculine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=neuter|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=neuter|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=neuter|Number=singular|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=neuter|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=neuter|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=neuter|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Syntactic-Type=adjectival
Verb	Verb-copula	VForm=conditional
Verb	Verb-copula	VForm=indicative|Tense=future|Person=first|Number=dual
Verb	Verb-copula	VForm=indicative|Tense=future|Person=first|Number=plural
Verb	Verb-copula	VForm=indicative|Tense=future|Person=first|Number=singular
Verb	Verb-copula	VForm=indicative|Tense=future|Person=second|Number=plural
Verb	Verb-copula	VForm=indicative|Tense=future|Person=second|Number=singular
Verb	Verb-copula	VForm=indicative|Tense=future|Person=third|Number=dual
Verb	Verb-copula	VForm=indicative|Tense=future|Person=third|Number=plural
Verb	Verb-copula	VForm=indicative|Tense=future|Person=third|Number=singular
Verb	Verb-copula	VForm=indicative|Tense=present|Person=first|Number=dual|Negative=no
Verb	Verb-copula	VForm=indicative|Tense=present|Person=first|Number=plural|Negative=no
Verb	Verb-copula	VForm=indicative|Tense=present|Person=first|Number=plural|Negative=yes
Verb	Verb-copula	VForm=indicative|Tense=present|Person=first|Number=singular|Negative=no
Verb	Verb-copula	VForm=indicative|Tense=present|Person=first|Number=singular|Negative=yes
Verb	Verb-copula	VForm=indicative|Tense=present|Person=second|Number=plural|Negative=no
Verb	Verb-copula	VForm=indicative|Tense=present|Person=second|Number=singular|Negative=no
Verb	Verb-copula	VForm=indicative|Tense=present|Person=second|Number=singular|Negative=yes
Verb	Verb-copula	VForm=indicative|Tense=present|Person=third|Number=dual|Negative=no
Verb	Verb-copula	VForm=indicative|Tense=present|Person=third|Number=dual|Negative=yes
Verb	Verb-copula	VForm=indicative|Tense=present|Person=third|Number=plural|Negative=no
Verb	Verb-copula	VForm=indicative|Tense=present|Person=third|Number=plural|Negative=yes
Verb	Verb-copula	VForm=indicative|Tense=present|Person=third|Number=singular|Negative=no
Verb	Verb-copula	VForm=indicative|Tense=present|Person=third|Number=singular|Negative=yes
Verb	Verb-copula	VForm=participle|Tense=past|Number=dual|Gender=feminine|Voice=active
Verb	Verb-copula	VForm=participle|Tense=past|Number=dual|Gender=masculine|Voice=active
Verb	Verb-copula	VForm=participle|Tense=past|Number=dual|Gender=neuter|Voice=active
Verb	Verb-copula	VForm=participle|Tense=past|Number=plural|Gender=feminine|Voice=active
Verb	Verb-copula	VForm=participle|Tense=past|Number=plural|Gender=masculine|Voice=active
Verb	Verb-copula	VForm=participle|Tense=past|Number=plural|Gender=neuter|Voice=active
Verb	Verb-copula	VForm=participle|Tense=past|Number=singular|Gender=feminine|Voice=active
Verb	Verb-copula	VForm=participle|Tense=past|Number=singular|Gender=masculine|Voice=active
Verb	Verb-copula	VForm=participle|Tense=past|Number=singular|Gender=neuter|Voice=active
Verb	Verb-main	VForm=imperative|Tense=present|Person=first|Number=dual
Verb	Verb-main	VForm=imperative|Tense=present|Person=first|Number=plural
Verb	Verb-main	VForm=imperative|Tense=present|Person=second|Number=plural
Verb	Verb-main	VForm=imperative|Tense=present|Person=second|Number=singular
Verb	Verb-main	VForm=indicative|Tense=present|Person=first|Number=dual|Negative=no
Verb	Verb-main	VForm=indicative|Tense=present|Person=first|Number=plural|Negative=no
Verb	Verb-main	VForm=indicative|Tense=present|Person=first|Number=plural|Negative=yes
Verb	Verb-main	VForm=indicative|Tense=present|Person=first|Number=singular|Negative=no
Verb	Verb-main	VForm=indicative|Tense=present|Person=first|Number=singular|Negative=yes
Verb	Verb-main	VForm=indicative|Tense=present|Person=second|Number=plural|Negative=no
Verb	Verb-main	VForm=indicative|Tense=present|Person=second|Number=plural|Negative=yes
Verb	Verb-main	VForm=indicative|Tense=present|Person=second|Number=singular|Negative=no
Verb	Verb-main	VForm=indicative|Tense=present|Person=second|Number=singular|Negative=yes
Verb	Verb-main	VForm=indicative|Tense=present|Person=third|Number=dual|Negative=no
Verb	Verb-main	VForm=indicative|Tense=present|Person=third|Number=plural|Negative=no
Verb	Verb-main	VForm=indicative|Tense=present|Person=third|Number=singular|Negative=no
Verb	Verb-main	VForm=infinitive
Verb	Verb-main	VForm=participle|Number=dual|Gender=masculine|Voice=passive
Verb	Verb-main	VForm=participle|Number=dual|Gender=neuter|Voice=passive
Verb	Verb-main	VForm=participle|Number=plural|Gender=feminine|Voice=passive
Verb	Verb-main	VForm=participle|Number=plural|Gender=masculine|Voice=passive
Verb	Verb-main	VForm=participle|Number=plural|Gender=neuter|Voice=passive
Verb	Verb-main	VForm=participle|Number=singular|Gender=feminine|Voice=passive
Verb	Verb-main	VForm=participle|Number=singular|Gender=masculine|Voice=passive
Verb	Verb-main	VForm=participle|Number=singular|Gender=neuter|Voice=passive
Verb	Verb-main	VForm=participle|Tense=past|Number=dual|Gender=feminine|Voice=active
Verb	Verb-main	VForm=participle|Tense=past|Number=dual|Gender=masculine|Voice=active
Verb	Verb-main	VForm=participle|Tense=past|Number=plural|Gender=feminine|Voice=active
Verb	Verb-main	VForm=participle|Tense=past|Number=plural|Gender=masculine|Voice=active
Verb	Verb-main	VForm=participle|Tense=past|Number=plural|Gender=neuter|Voice=active
Verb	Verb-main	VForm=participle|Tense=past|Number=singular|Gender=feminine|Voice=active
Verb	Verb-main	VForm=participle|Tense=past|Number=singular|Gender=masculine|Voice=active
Verb	Verb-main	VForm=participle|Tense=past|Number=singular|Gender=neuter|Voice=active
Verb	Verb-main	VForm=supine
Verb	Verb-modal	VForm=indicative|Tense=present|Person=first|Number=plural|Negative=no
Verb	Verb-modal	VForm=indicative|Tense=present|Person=first|Number=singular|Negative=no
Verb	Verb-modal	VForm=indicative|Tense=present|Person=second|Number=plural|Negative=no
Verb	Verb-modal	VForm=indicative|Tense=present|Person=second|Number=singular|Negative=no
Verb	Verb-modal	VForm=indicative|Tense=present|Person=third|Number=dual|Negative=no
Verb	Verb-modal	VForm=indicative|Tense=present|Person=third|Number=plural|Negative=no
Verb	Verb-modal	VForm=indicative|Tense=present|Person=third|Number=singular|Negative=no
Verb	Verb-modal	VForm=participle|Number=plural|Gender=feminine|Voice=passive
Verb	Verb-modal	VForm=participle|Number=singular|Gender=neuter|Voice=passive
Verb	Verb-modal	VForm=participle|Tense=past|Number=plural|Gender=feminine|Voice=active
Verb	Verb-modal	VForm=participle|Tense=past|Number=plural|Gender=masculine|Voice=active
Verb	Verb-modal	VForm=participle|Tense=past|Number=singular|Gender=feminine|Voice=active
Verb	Verb-modal	VForm=participle|Tense=past|Number=singular|Gender=masculine|Voice=active
Verb	Verb-modal	VForm=participle|Tense=past|Number=singular|Gender=neuter|Voice=active
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
    #$permitted = tagset::common::get_permitted_structures_joint(list(), \&decode);
}



1;
