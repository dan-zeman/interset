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
