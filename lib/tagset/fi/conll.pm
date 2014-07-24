#!/usr/bin/perl
# Driver for the Finnish tagset from the Turku Dependency Treebank.
# We work with the CoNLL conversion of the treebank, further processed by Dan so that the original tag is in the FEAT field,
# while the CPOS and POS fields contain short values completely derived from the FEAT field.
# Nevertheless, we still expect the application to supply all three CoNLL fields separated by tabulators.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::fi::conll;
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
    $f{tagset} = 'fi::conll';
    # three components: coarse-grained pos, fine-grained pos, features
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    # We will ignore $pos and $subpos because it is derived from $features.
    # The features are simple words, not attribute=value assignments.
    # Some of them define part of speech, others number, case etc.
    # http://www2.lingsoft.fi/doc/fintwol/intro/tags.html
    # http://en.wikipedia.org/wiki/Finnish_grammar
    my @features = split(/\|/, $features);
    foreach my $feature (@features)
    {
        if($feature eq 'A')
        {
            $f{pos} = 'adj';
        }
        elsif($feature eq 'ABBR')
        {
            $f{abbr} = 'abbr';
        }
        elsif($feature eq 'AD-A')
        {
            # see e.g. http://archives.conlang.info/pei/juenchen/phaelbhaduen.html for what ad-adjective is
            $f{pos} = 'adv';
            $f{subpos} = 'adadj';
        }
        elsif($feature eq 'ADV')
        {
            $f{pos} = 'adv';
        }
        elsif($feature eq 'ART')
        {
            $f{pos} = 'adj';
            $f{subpos} = 'art';
        }
        elsif($feature eq 'C')
        {
            $f{pos} = 'conj';
        }
        elsif($feature eq 'INTJ')
        {
            $f{pos} = 'int';
        }
        elsif($feature eq 'N')
        {
            $f{pos} = 'noun';
        }
        elsif($feature eq 'NUM')
        {
            $f{pos} = 'num';
        }
        # PP = post- or preposition (jälkeen, ennen)
        # PREP = foreign preposition (de)
        # PSP = postposition (vieressä)
        elsif($feature =~ m/^(PP|PREP|PSP)$/)
        {
            $f{pos} = 'prep';
        }
        # PRON = pronoun (sinä)
        elsif($feature eq 'PRON')
        {
            $f{pos} = 'noun';
            $f{prontype} = 'prs';
        }
        elsif($feature eq 'V')
        {
            $f{pos} = 'verb';
        }
        # Comparation: POS CMP SUP
        # positive (kuuma, hyvä)
        elsif($feature eq 'POS')
        {
            $f{degree} = 'pos';
        }
        # comparative (kuumempi, parempi)
        elsif($feature eq 'CMP')
        {
            $f{degree} = 'comp';
        }
        # superlative (kuumin, paras)
        elsif($feature eq 'SUP')
        {
            $f{degree} = 'sup';
        }
        # Case: NOM GEN PTV ESS TRA INE ELA ILL ADE ABL ALL ABE CMT INS
        # nominative (koira)
        elsif($feature eq 'NOM')
        {
            $f{case} = 'nom';
        }
        # genitive (koiran)
        elsif($feature eq 'GEN')
        {
            $f{case} = 'gen';
        }
        # partitive (koiraa)
        elsif($feature eq 'PTV')
        {
            $f{case} = 'par';
        }
        # essive (koirana)
        elsif($feature eq 'ESS')
        {
            $f{case} = 'ess';
        }
        # translative (koiraksi)
        elsif($feature eq 'TRA')
        {
            $f{case} = 'tra';
        }
        # inessive (koirassa)
        elsif($feature eq 'INE')
        {
            $f{case} = 'ine';
        }
        # elative (koirasta)
        elsif($feature eq 'ELA')
        {
            $f{case} = 'ela';
        }
        # illative (koiraan)
        elsif($feature eq 'ILL')
        {
            $f{case} = 'ill';
        }
        # adessive (koiralla)
        elsif($feature eq 'ADE')
        {
            $f{case} = 'ade';
        }
        # ablative (koiralta)
        elsif($feature eq 'ABL')
        {
            $f{case} = 'abl';
        }
        # allative (koiralle)
        elsif($feature eq 'ALL')
        {
            $f{case} = 'all';
        }
        # abessive (koiratta)
        elsif($feature eq 'ABE')
        {
            $f{case} = 'abe';
        }
        # comitative (koirineen)
        elsif($feature eq 'CMT')
        {
            $f{case} = 'com';
        }
        # instructive (koirin)
        elsif($feature eq 'INS')
        {
            # 'ins' is already used for instrumental.
            $f{case} = 'ist';
        }
        # accusative: only with a few pronouns (meidät = us, sinut = thee, hänet = him, minut = me, heidät = them)
        elsif($feature eq 'ACC')
        {
            $f{case} = 'acc';
        }
        # Number: SG PL
        # singular (kala)
        elsif($feature eq 'SG')
        {
            $f{number} = 'sing';
        }
        # plural (kalat)
        elsif($feature eq 'PL')
        {
            $f{number} = 'plu';
        }
        # Possessive suffixes: 1SG 2SG 3 1PL 2PL
        # 1st person singular (my) (tyttäreni)
        elsif($feature eq '1SG')
        {
            $f{poss} = 'poss';
            $f{person} = 1;
            $f{possnumber} = 'sing';
        }
        # 2nd person singular (your) (tyttäresi)
        elsif($feature eq '2SG')
        {
            $f{poss} = 'poss';
            $f{person} = 2;
            $f{possnumber} = 'sing';
        }
        # 3rd person singular or plural (his, her, its, their) (tyttärensä)
        elsif($feature eq '3')
        {
            $f{poss} = 'poss';
            $f{person} = 3;
        }
        # 1st person plural (our) (tyttäremme)
        elsif($feature eq '1PL')
        {
            $f{poss} = 'poss';
            $f{person} = 1;
            $f{possnumber} = 'plu';
        }
        # 2nd person plural (your) (tyttärenne)
        elsif($feature eq '2PL')
        {
            $f{poss} = 'poss';
            $f{person} = 2;
            $f{possnumber} = 'plu';
        }
        # Mood: IMPV COND POTN
        # There is no feature for indicative forms (lukee, menee).
        # imperative (lue, mene)
        elsif($feature eq 'IMPV')
        {
            $f{verbform} = 'fin';
            $f{mood} = 'imp';
        }
        # conditional (lukisi, menisi)
        elsif($feature eq 'COND')
        {
            $f{verbform} = 'fin';
            $f{mood} = 'cnd';
        }
        # potential (lukenee, mennee)
        elsif($feature eq 'POTN')
        {
            $f{verbform} = 'fin';
            $f{mood} = 'pot';
        }
        # Tense: PRES PAST
        # present (haluan)
        elsif($feature eq 'PRES')
        {
            $f{tense} = 'pres';
        }
        # past (halusin)
        elsif($feature eq 'PAST')
        {
            $f{tense} = 'past';
        }
        # Voice: ACT PSS
        # active (uin)
        elsif($feature eq 'ACT')
        {
            $f{voice} = 'act';
        }
        # passive (uidaan)
        elsif($feature eq 'PSS')
        {
            $f{voice} = 'pass';
        }
        # Person: SG1 SG2 SG3 PL1 PL2 PL3 PE4
        # 1st person singular (menen)
        elsif($feature eq 'SG1')
        {
            $f{number} = 'sing';
            $f{person} = 1;
        }
        # 2nd person singular (menet)
        elsif($feature eq 'SG2')
        {
            $f{number} = 'sing';
            $f{person} = 2;
        }
        # 3rd person singular (menee)
        elsif($feature eq 'SG3')
        {
            $f{number} = 'sing';
            $f{person} = 3;
        }
        # 1st person plural (menemme)
        elsif($feature eq 'PL1')
        {
            $f{number} = 'plu';
            $f{person} = 1;
        }
        # 2nd person plural (menette)
        elsif($feature eq 'PL2')
        {
            $f{number} = 'plu';
            $f{person} = 2;
        }
        # 3rd person plural (menevät)
        elsif($feature eq 'PL3')
        {
            $f{number} = 'plu';
            $f{person} = 3;
        }
        # passive ending (mennään)
        # In modern colloquial Finnish, the passive form of the verb is used instead of the active first person plural indicative and imperative.
        elsif($feature eq 'PE4')
        {
            $f{number} = 'plu';
            $f{person} = 1;
            $f{style} = 'coll';
        }
        # Negative: NEGV NEG
        # negative verb (en, et, ei)
        elsif($feature eq 'NEGV')
        {
            $f{pos} = 'verb';
            $f{negativeness} = 'neg';
        }
        # negative form (en tehnyt)
        elsif($feature eq 'NEG')
        {
            $f{negativeness} = 'neg';
        }
        # Infinitives: INF1 INF2 INF3 INF5
        # The 4th infinitive (tuleminen) is interpreted as a noun.
        # 1st infinitive (tulla, tullakseni)
        elsif($feature eq 'INF1')
        {
            $f{verbform} = 'inf';
        }
        # 2nd infinitive (tullessaan, tullessa)
        elsif($feature eq 'INF2')
        {
            $f{verbform} = 'inf';
            $f{variant} = 2;
        }
        # 3rd infinitive (tulemaan)
        elsif($feature eq 'INF3')
        {
            $f{verbform} = 'ger';
        }
        # 5th infinitive (tulemaisillaan)
        elsif($feature eq 'INF5')
        {
            $f{verbform} = 'inf';
            $f{variant} = 5;
        }
        # Participles: PCP1 PCP2
        # 1st participle (lentävä, lennettävä)
        elsif($feature eq 'PCP1')
        {
            $f{verbform} = 'part';
        }
        # 2nd participle (lentänyt, lennetty)
        elsif($feature eq 'PCP2')
        {
            $f{verbform} = 'part';
            $f{variant} = 2;
        }
        # Clitics: hAn kA kAAn kin kO pA s
        # Appealing clitic -han/-hän (poikahan).
        # This clitic is to appeal to the listener:
        # Olethan kävellyt?
        # You have walked, right?
        elsif($feature eq 'hAn')
        {
        }
        # Copulative clitic -ka/-kä (eikä).
        # This clitic is used in negative forms to work as copula:
        # en juokse enkä kävele
        # I don't run nor (do I) walk.
        elsif($feature eq 'kA')
        {
        }
        # -kaan/-kään (poikakaan)
        elsif($feature eq 'kAAn')
        {
        }
        # -kin (poikakin)
        elsif($feature eq 'kin')
        {
        }
        # -ko/-kö (oletko)
        elsif($feature eq 'kO')
        {
        }
        # -kohan/-köhän (miksiköhän = I wonder why, olisikohan = I wonder if)
        elsif($feature eq 'kOhAn')
        {
        }
        # -pa/-pä (oletpa)
        elsif($feature eq 'pA')
        {
        }
        # Emphatic (zdůrazňovací) clitic -s (onpas)
        elsif($feature eq 's')
        {
        }
        # Other: FORGN PROP pi
        # foreign word (British)
        elsif($feature eq 'FORGN')
        {
            $f{foreign} = 'foreign';
        }
        # proper noun (Mikko)
        elsif($feature eq 'PROP')
        {
            $f{subpos} = 'prop';
        }
        # -pi (ompi) ???
        elsif($feature eq 'pi')
        {
        }
        # Other features occur in data although they are not documented.
        # Pronoun types: PERS DEM REL Q REFL/Q
        # Of these, only 'Q' appears in the documentation:
        # Q = quantifier (moni = many, much)
        # In the data, it is usually (always?) with PRON, i.e. 'Q|PRON'. Examples (translation by Google):
        # missään (anywhere), samalla (at the same time), toisen (next), kaikkia (all), jokaista (every), ainoa (only), samaan (same), molemmat (both)
        elsif($feature eq 'Q')
        {
            $f{prontype} = 'ind';
        }
        # REFL/Q = reflexive quantifying pronoun (itseään = sám = self)
        elsif($feature eq 'REFL/Q')
        {
            $f{reflex} = 'reflex';
            $f{prontype} = 'ind';
        }
        # PERS = personal pronoun (meidät = us)
        elsif($feature eq 'PERS')
        {
            $f{prontype} = 'prs';
        }
        # DEM = demonstrative pronoun (se = that, tuolla = there)
        elsif($feature eq 'DEM')
        {
            $f{prontype} = 'dem';
        }
        # REL = relative pronoun (mihin = where, mitä = what, joka = which)
        elsif($feature eq 'REL')
        {
            $f{prontype} = 'rel';
        }
        # INTG = interrogative pronoun (kuka = who, mikä = what)
        elsif($feature eq 'INTG')
        {
            $f{prontype} = 'int';
        }
        # Numeral types: ORD
        # ordinal numeral (ensimmäinen = first, toinen = second, kolmas = third)
        elsif($feature eq 'ORD')
        {
            $f{numtype} = 'ord';
        }
        # Number formats: digit roman
        elsif($feature eq 'digit')
        {
            $f{numform} = 'digit';
        }
        elsif($feature eq 'roman')
        {
            $f{numform} = 'roman';
        }
        # Copula verb: COP (olla = to be)
        elsif($feature eq 'COP')
        {
            $f{subpos} = 'cop';
        }
        # LAT ???
        # Typically occurs with the first infinitive (LAT|INF1|V).
        # Could it be a light verb?
        elsif($feature eq 'LAT')
        {
        }
        # REF ???
        # A very rare feature of verbs. Reflexivity?
        elsif($feature eq 'REF')
        {
        }
        # TEMP ???
        # Rare feature of PAST|ACT verbs ending in -tua, -tyä, -tuaan.
        # Maybe it expresses "after doing the action of the verb"?
        elsif($feature eq 'TEMP')
        {
        }
        # Adverb type: MAN INTERR
        # manner adverb (rohkeasti = boldly, hitaasti = slowly, henkisesti = mentally)
        elsif($feature eq 'MAN')
        {
            $f{advtype} = 'man';
        }
        # interrogative adverb or adjective (kuinka = how, millainen = which, milloin = when, miksei = why not)
        elsif($feature eq 'INTERR')
        {
            $f{prontype} = 'int';
        }
        # Conjunction type: COORD SUB
        # coordinating conjunction (ja, että, vai, sekä, mutta)
        elsif($feature eq 'COORD')
        {
            $f{subpos} = 'coor';
        }
        # subordinating conjunction (kun, vaikka, ettei, jos, koska)
        elsif($feature eq 'SUB')
        {
            $f{subpos} = 'sub';
        }
        # comparating conjunction (kuin = as)
        elsif($feature eq 'CMPR')
        {
            $f{subpos} = 'comp';
        }
        # up: is the first letter of the word form uppercase?
        elsif($feature eq 'up')
        {
            $f{other}{uppercase} = 1;
        }
        # TrunCo seems to mark hyphenated prefixes occurring separately.
        elsif($feature eq 'TrunCo')
        {
            $f{hyph} = 'hyph';
        }
        # PUNCT = punctuation
        elsif($feature eq 'PUNCT')
        {
            $f{pos} = 'punc';
        }
        # DASH|PUNCT, PUNCT|QUOTE, PUNCT|ENDASH...
        elsif($feature =~ m/^(E[MN])?DASH$/)
        {
            $f{punctype} = 'dash';
        }
        elsif($feature eq 'QUOTE')
        {
            $f{punctype} = 'quot';
        }
        # Style: st-arch st-cllq st-derog st-slang st-vrnc st-hi
        # archaic colloquial derogative slang vernacular hi?
        # zastaralý hovorový hanlivý slang nářečí knižní?
        elsif($feature eq 'st-arch')
        {
            $f{style} = 'arch';
        }
        elsif($feature eq 'st-cllq')
        {
            $f{style} = 'coll';
        }
        elsif($feature eq 'st-derog')
        {
            $f{style} = 'derg';
        }
        elsif($feature eq 'st-slang')
        {
            $f{style} = 'slng';
        }
        elsif($feature eq 'st-vrnc')
        {
            $f{style} = 'vrnc';
        }
        elsif($feature eq 'st-hi')
        {
            $f{style} = 'form';
        }
        # Deverbatives? And what is the resulting part of speech? A noun?
        # DV-NEISUUS      5
        # DV-NTI  49
        # DV-NA   2
        # DV-VAINEN       38
        # DV-MATON        51
        # DV-JA   594
        # DV-SKELE        5
        # DV-MINEN        382
        # DV-MA   142
        # DV-UTTA 1
        # DV-NTAA 40
        # DV-NTA  98
        # DV-ELE  176
        # DV-TTA  259
        # DV-US   643
        # DV-U    505
        # DV-ILE  63
        # DV-UTU  46
        elsif($feature =~ m/^DV-[A-Z]+$/)
        {
            $f{pos} = 'noun' unless($f{pos});
        }
        # Denominatives. Unlike deverbatives, they usually have their resulting part of speech specified, mostly A or ADV.
        # DN-INEN 44
        # DN-ITTAIN       34
        # DN-LAINEN       168
        # DN-LLINEN       329
        # DN-MAINEN       17
        # DN-TAR  1
        # DN-TON  40
        elsif($feature =~ m/^DN-[A-Z]+$/)
        {
            $f{pos} = 'adj' unless($f{pos});
        }
        # Deadjectives. They usually have their resulting part of speech specified, mostly N.
        # DA-US 101 ... sairaus = illness, rakkaus = love
        # DA-UUS 280 ... varmuus = affirmation, tyhjyys = emptiness
        elsif($feature =~ m/^DA-[A-Z]+$/)
        {
            $f{pos} = 'noun' unless($f{pos});
        }
        # Word form not found in lexicon: NON-TWOL.
        elsif($feature eq 'NON-TWOL')
        {
            # Do nothing.
        }
        # *null* node inserted instead of ellided token; always verb (V|NULL).
        elsif($feature eq 'NULL')
        {
            # Do nothing.
        }
        # S mysteriously occurs with a few foreign words (child, monkey, death).
        elsif($feature eq 'S')
        {
            # Do nothing.
        }
        # The 't-EUparl' "feature" is probably a bug in data preparation / tagging.
        # It occurs only once, with the word 'europarlamenttivaaleissa' (= EU Parliament polls).
        # There are several other similar.
        elsif($feature =~ m/^t-(EUparl|MSilocat|MSasiakirja|EU-vk|MSolocat|MSlukumäärä)$/)
        {
            # Do nothing.
        }
        else
        {
            print STDERR ("Warning: Unknown Finnish feature $feature.\n");
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
