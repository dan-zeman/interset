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
A	A	A
A	A	A|2SG|SG|POS|GEN
A	A	A|3|ADE|PL|SUP
A	A	A|3|ADE|POS|PL
A	A	A|3|ADE|SG|POS
A	A	A|ABL|POS|PL
A	A	A|ABL|SG|DN-INEN|POS
A	A	A|ABL|SG|DV-MATON|POS
A	A	A|ACT|PCP1|SUP|PTV|PL
A	A	A|ACT|PCP2|SUP|PTV|PL
A	A	A|ADE|DN-INEN|POS|PL
A	A	A|ADE|PL|CMP
A	A	A|ADE|POS|PL
A	A	A|ADE|SG|CMP
A	A	A|ADE|SG|POS
A	A	A|ADE|SG|SUP
A	A	A|ADE|SG|kin|CMP
A	A	A|ADE|SG|up|CMP
A	A	A|ALL|DV-MATON|POS|PL
A	A	A|ALL|PL|CMP
A	A	A|ALL|PL|SUP
A	A	A|ALL|POS|PL
A	A	A|ALL|SG|CMP
A	A	A|ALL|SG|POS
A	A	A|ALL|up|SG|CMP
A	A	A|ALL|up|SG|POS
A	A	A|CMT|POS
A	A	A|COP|ELA|PCP2|POS|ACT|PL
A	A	A|COP|PCP2|POS|ACT|GEN|PL
A	A	A|COP|PCP2|POS|ACT|PTV|PL
A	A	A|DN-INEN|POS|PL|GEN
A	A	A|DN-LLINEN|ADE|SG|POS
A	A	A|DN-LLINEN|ALL|POS|PL
A	A	A|DN-LLINEN|ALL|SG|POS
A	A	A|DN-LLINEN|ELA|PL|SUP
A	A	A|DN-LLINEN|ELA|POS|PL
A	A	A|DN-LLINEN|ELA|SG|POS
A	A	A|DN-LLINEN|ESS|POS|PL
A	A	A|DN-LLINEN|POS|ILL|PL
A	A	A|DN-LLINEN|POS|PL|GEN
A	A	A|DN-LLINEN|SG|ILL|CMP
A	A	A|DN-LLINEN|SG|POS|GEN
A	A	A|DN-LLINEN|SG|POS|ILL
A	A	A|DV-MATON|POS|DV-U|INE|PL
A	A	A|DV-MATON|POS|DV-U|SG|GEN
A	A	A|DV-MATON|POS|PL|GEN
A	A	A|DV-NTA|POS|DN-LLINEN|GEN|PL
A	A	A|DV-US|POS|DN-LLINEN|PTV|PL
A	A	A|DV-US|POS|DN-LLINEN|SG|GEN
A	A	A|DV-US|POS|DV-TTA|DN-LLINEN|PTV|PL
A	A	A|ELA|DN-MAINEN|POS|PL
A	A	A|ELA|DV-MATON|POS|PL
A	A	A|ELA|PCP1|ACT|SUP|PL
A	A	A|ELA|PCP2|SUP|PSS|PL
A	A	A|ELA|PCP2|SUP|PSS|SG
A	A	A|ELA|PL|CMP
A	A	A|ELA|PL|SUP
A	A	A|ELA|POS|PL
A	A	A|ELA|SG|CMP
A	A	A|ELA|SG|POS
A	A	A|ELA|SG|POS|INTERR
A	A	A|ELA|SG|SUP
A	A	A|ELA|SG|kin|SUP
A	A	A|ELA|up|PL|CMP
A	A	A|ESS|DV-VAINEN|PL|POS
A	A	A|ESS|PCP2|SUP|PSS|SG
A	A	A|ESS|POS|PL
A	A	A|ESS|POS|PL|kin
A	A	A|ESS|SG|DV-MATON|POS
A	A	A|FORGN
A	A	A|FORGN|up
A	A	A|GEN|PL|CMP
A	A	A|GEN|PL|SUP
A	A	A|ILL|DV-MATON|POS|PL
A	A	A|ILL|PCP2|SUP|PSS|PL
A	A	A|ILL|PL|CMP
A	A	A|ILL|PL|SUP
A	A	A|ILL|POS|PL
A	A	A|ILL|SG|CMP
A	A	A|ILL|SG|POS
A	A	A|ILL|SG|POS|kin
A	A	A|ILL|up|POS|PL
A	A	A|ILL|up|SG|CMP
A	A	A|ILL|up|SG|POS
A	A	A|INE|DN-LLINEN|POS|PL
A	A	A|INE|DN-LLINEN|SG|POS
A	A	A|INE|DN-MAINEN|POS|PL
A	A	A|INE|DV-VAINEN|PL|POS
A	A	A|INE|PL|CMP
A	A	A|INE|POS|PL
A	A	A|INE|SG|CMP
A	A	A|INE|SG|DN-INEN|POS
A	A	A|INE|SG|DV-MATON|POS
A	A	A|INE|SG|POS
A	A	A|INE|SG|POS|kin
A	A	A|INE|SG|SUP
A	A	A|INE|t-EUparl|POS|PL
A	A	A|INE|up|POS|PL
A	A	A|INE|up|SG|POS
A	A	A|INS|PL|CMP
A	A	A|NOM|1SG|POS|PL
A	A	A|NOM|3|SG|POS
A	A	A|NOM|3|SG|SUP
A	A	A|NOM|ACT|PCP1|SUP|PL
A	A	A|NOM|ACT|PCP1|SUP|SG
A	A	A|NOM|ACT|PCP2|SUP|SG
A	A	A|NOM|DN-INEN|POS|PL
A	A	A|NOM|DN-LLINEN|POS|PL
A	A	A|NOM|DN-LLINEN|SG|POS
A	A	A|NOM|DN-LLINEN|SG|SUP
A	A	A|NOM|DV-MATON|POS|PL
A	A	A|NOM|DV-US|POS|DN-LLINEN|SG
A	A	A|NOM|PCP1|ACT|SG|CMP
A	A	A|NOM|PCP1|SUP|PSS|SG
A	A	A|NOM|PCP2|ACT|PL|CMP
A	A	A|NOM|PCP2|SUP|PSS|DV-ELE|SG
A	A	A|NOM|PCP2|SUP|PSS|SG
A	A	A|NOM|PL|CMP
A	A	A|NOM|PL|SUP
A	A	A|NOM|POS|DN-LLINEN|kin|SG
A	A	A|NOM|POS|PL
A	A	A|NOM|SG|CMP
A	A	A|NOM|SG|DN-INEN|POS
A	A	A|NOM|SG|DN-INEN|SUP
A	A	A|NOM|SG|DN-MAINEN|POS
A	A	A|NOM|SG|DV-MATON|POS
A	A	A|NOM|SG|DV-VAINEN|POS
A	A	A|NOM|SG|POS
A	A	A|NOM|SG|POS|1PL
A	A	A|NOM|SG|POS|CMP
A	A	A|NOM|SG|POS|INTERR
A	A	A|NOM|SG|POS|TrunCo
A	A	A|NOM|SG|POS|kin
A	A	A|NOM|SG|SUP
A	A	A|NOM|SG|kAAn|SUP
A	A	A|NOM|kin|PL|CMP
A	A	A|NOM|up|1SG|POS|SG
A	A	A|NOM|up|ACT|PCP1|SUP|SG
A	A	A|NOM|up|ACT|PCP2|SUP|SG
A	A	A|NOM|up|DN-INEN|POS|SG
A	A	A|NOM|up|PCP2|SUP|PSS|SG
A	A	A|NOM|up|PL|CMP
A	A	A|NOM|up|PL|SUP
A	A	A|NOM|up|POS|DN-INEN|PL
A	A	A|NOM|up|POS|DN-LLINEN|PL
A	A	A|NOM|up|POS|DN-LLINEN|SG
A	A	A|NOM|up|POS|INTERR|SG
A	A	A|NOM|up|POS|PL
A	A	A|NOM|up|SG|CMP
A	A	A|NOM|up|SG|POS
A	A	A|NOM|up|SG|SUP
A	A	A|NOM|up|kO|POS|PL
A	A	A|NOM|up|st-cllq|POS|SG
A	A	A|PCP1|ACT|PTV|SG|CMP
A	A	A|PCP1|PTV|PSS|PL|CMP
A	A	A|PCP2|SUP|PSS|SG|GEN
A	A	A|PL|POS|INTERR|GEN
A	A	A|POS|DN-LLINEN|kin|PTV|SG
A	A	A|POS|PL|GEN
A	A	A|POS|PL|INS
A	A	A|PTV|1SG|POS|PL
A	A	A|PTV|3|POS|PL
A	A	A|PTV|3|SG|POS
A	A	A|PTV|DN-INEN|POS|PL
A	A	A|PTV|DN-LLINEN|POS|PL
A	A	A|PTV|DN-LLINEN|SG|CMP
A	A	A|PTV|DN-LLINEN|SG|POS
A	A	A|PTV|DV-MATON|POS|PL
A	A	A|PTV|DV-UTU|POS|PL
A	A	A|PTV|DV-VAINEN|PL|POS
A	A	A|PTV|PL|CMP
A	A	A|PTV|PL|SUP
A	A	A|PTV|POS|INTERR|PL
A	A	A|PTV|POS|PL
A	A	A|PTV|SG|CMP
A	A	A|PTV|SG|DN-INEN|POS
A	A	A|PTV|SG|DN-MAINEN|POS
A	A	A|PTV|SG|DV-MATON|POS
A	A	A|PTV|SG|DV-MATON|SUP
A	A	A|PTV|SG|POS
A	A	A|PTV|SG|POS|DV-TTA
A	A	A|PTV|SG|POS|INTERR
A	A	A|PTV|SG|POS|TrunCo
A	A	A|PTV|SG|POS|kin
A	A	A|PTV|SG|SUP
A	A	A|PTV|SG|kin|CMP
A	A	A|PTV|up|PL|SUP
A	A	A|PTV|up|POS|PL
A	A	A|PTV|up|SG|POS
A	A	A|PTV|up|SG|SUP
A	A	A|SG|ABL|CMP
A	A	A|SG|ABL|POS
A	A	A|SG|ABL|SUP
A	A	A|SG|ADE|DN-INEN|POS
A	A	A|SG|ALL|DN-INEN|POS
A	A	A|SG|DN-INEN|POS|GEN
A	A	A|SG|DN-LLINEN|ABL|POS
A	A	A|SG|DN-LLINEN|ESS|POS
A	A	A|SG|DN-LLINEN|ESS|SUP
A	A	A|SG|DN-MAINEN|POS|GEN
A	A	A|SG|DV-MATON|POS|GEN
A	A	A|SG|ELA|DN-MAINEN|POS
A	A	A|SG|ELA|DV-MATON|POS
A	A	A|SG|ESS|CMP
A	A	A|SG|ESS|POS
A	A	A|SG|ESS|POS|INTERR
A	A	A|SG|ESS|SUP
A	A	A|SG|GEN|CMP
A	A	A|SG|GEN|SUP
A	A	A|SG|ILL|DN-INEN|POS
A	A	A|SG|ILL|DV-MATON|POS
A	A	A|SG|POS|GEN
A	A	A|SG|POS|INTERR|GEN
A	A	A|SG|up|ESS|POS
A	A	A|SG|up|ESS|SUP
A	A	A|SUP|PCP2|PTV|PSS|PL
A	A	A|TRA|3|SG|POS
A	A	A|TRA|DN-INEN|POS|PL
A	A	A|TRA|DN-LLINEN|PL|CMP
A	A	A|TRA|DN-LLINEN|POS|PL
A	A	A|TRA|DN-LLINEN|SG|POS
A	A	A|TRA|DV-MATON|POS|PL
A	A	A|TRA|DV-VAINEN|PL|POS
A	A	A|TRA|POS|PL
A	A	A|TRA|SG|CMP
A	A	A|TRA|SG|DN-INEN|POS
A	A	A|TRA|SG|DN-MAINEN|POS
A	A	A|TRA|SG|POS
A	A	A|TRA|SG|SUP
A	A	A|TRA|SG|kin|CMP
A	A	A|TRA|up|SG|POS
A	A	A|TRA|up|SG|SUP
A	A	A|TrunCo
A	A	A|TrunCo|up
A	A	A|kAAn|ADE|SG|POS
A	A	A|kin|SG|POS|GEN
A	A	A|st-cllq|NOM|SG|SUP
A	A	A|st-cllq|POS|PL|NOM
A	A	A|st-cllq|POS|PL|PTV
A	A	A|st-cllq|SG|POS|GEN
A	A	A|st-cllq|SG|POS|NOM
A	A	A|st-cllq|SG|POS|PTV
A	A	A|up
A	A	A|up|3|ADE|SUP|PL
A	A	A|up|ABL|3|PL|CMP
A	A	A|up|ADE|POS|PL
A	A	A|up|ADE|SG|POS
A	A	A|up|ELA|POS|PL
A	A	A|up|ELA|SG|POS
A	A	A|up|GEN|PL|CMP
A	A	A|up|ILL|POS|DN-LLINEN|SG
A	A	A|up|POS|3|ADE|SG
A	A	A|up|POS|ADE|kin|SG
A	A	A|up|POS|DN-LLINEN|GEN|PL
A	A	A|up|POS|DN-LLINEN|INE|SG
A	A	A|up|POS|DN-LLINEN|PTV|PL
A	A	A|up|POS|DN-LLINEN|PTV|SG
A	A	A|up|POS|DN-LLINEN|SG|GEN
A	A	A|up|POS|DN-MAINEN|PTV|SG
A	A	A|up|POS|DN-TON|SG|GEN
A	A	A|up|POS|PL|GEN
A	A	A|up|SG|GEN|CMP
A	A	A|up|SG|GEN|SUP
A	A	A|up|SG|POS|GEN
A	A	A|up|TRA|POS|DN-LLINEN|SG
A	A	DN-TON|A|ELA|SG|POS
A	A	DN-TON|A|ILL|SG|POS
A	A	DN-TON|A|POS|PL|GEN
A	A	DN-TON|A|POS|PL|NOM
A	A	DN-TON|A|POS|PL|PTV
A	A	DN-TON|A|SG|ESS|POS
A	A	DN-TON|A|SG|POS|GEN
A	A	DN-TON|A|SG|POS|INE
A	A	DN-TON|A|SG|POS|NOM
A	A	DN-TON|A|SG|POS|PTV
A	A	DN-TON|A|SG|TRA|POS
A	A	DV-NTAA|A|SG|POS|GEN
A	A	DV-U|A|ELA|POS|PL
A	A	DV-U|A|ILL|POS|PL
A	A	DV-U|A|POS|PL|PTV
A	A	digit|A|ALL|POS|PL
A	A	digit|A|ELA|SG|POS
A	A	digit|A|POS|PL|GEN
A	A	digit|A|POS|PL|NOM
A	A	digit|A|SG|ESS|POS
A	A	digit|A|SG|POS|GEN
A	A	digit|A|SG|POS|NOM
A	A	digit|A|SG|POS|PTV
A	ART	FORGN|ART
A	ART	FORGN|ART|up
A	NUM	ADE|NUM|SG
A	NUM	ALL|NUM|SG
A	NUM	ELA|NUM|SG
A	NUM	ELA|NUM|SG|up
A	NUM	ILL|NUM|PL
A	NUM	ILL|NUM|SG
A	NUM	ILL|NUM|SG|up
A	NUM	INE|NUM|SG
A	NUM	INE|NUM|SG|up
A	NUM	INE|ORD|NUM|SG
A	NUM	INE|ORD|NUM|SG|up
A	NUM	NOM|NUM|PL
A	NUM	NOM|NUM|SG
A	NUM	NOM|NUM|SG|up
A	NUM	NOM|ORD|NUM|PL
A	NUM	NOM|ORD|NUM|SG
A	NUM	NOM|ORD|NUM|SG|up
A	NUM	NOM|ORD|NUM|up|PL
A	NUM	NUM|GEN|PL
A	NUM	NUM|SG|GEN
A	NUM	ORD|NUM|SG|ALL
A	NUM	ORD|NUM|SG|GEN
A	NUM	ORD|NUM|SG|ILL
A	NUM	PTV|NUM|PL
A	NUM	PTV|NUM|SG
A	NUM	PTV|NUM|SG|up
A	NUM	PTV|ORD|NUM|PL
A	NUM	PTV|ORD|NUM|SG
A	NUM	PTV|ORD|NUM|SG|up
A	NUM	SG|NUM|ABL
A	NUM	SG|NUM|ESS
A	NUM	SG|ORD|NUM|ADE
A	NUM	SG|ORD|NUM|ESS
A	NUM	SG|ORD|NUM|ESS|up
A	NUM	TRA|NUM|SG
A	NUM	TRA|ORD|NUM|SG
A	NUM	TRA|ORD|NUM|SG|up
A	NUM	up|NUM|SG|GEN
A	NUM	up|ORD|NUM|SG|GEN
A	PCP1	ADE|SG|POS|PCP1|ACT
A	PCP1	ALL|PL|POS|PCP1|ACT
A	PCP1	ALL|POS|PCP1|ACT|DV-U|PL
A	PCP1	ALL|SG|POS|PCP1|ACT
A	PCP1	CMT|POS|PCP1|ACT
A	PCP1	COP|ELA|POS|PCP1|ACT|PL
A	PCP1	COP|ELA|POS|PCP1|ACT|SG
A	PCP1	COP|ILL|POS|PCP1|ACT|SG
A	PCP1	COP|NOM|POS|PCP1|3|ACT|SG
A	PCP1	COP|NOM|POS|PCP1|ACT|PL
A	PCP1	COP|NOM|POS|PCP1|ACT|SG
A	PCP1	COP|POS|PCP1|ACT|PTV|SG
A	PCP1	COP|POS|PCP1|ACT|SG|GEN
A	PCP1	COP|TRA|POS|PCP1|ACT|PL
A	PCP1	DV-ILE|POS|PCP1|ACT|INE|SG
A	PCP1	DV-ILE|POS|PCP1|ACT|PTV|SG
A	PCP1	DV-ILE|POS|PCP1|ACT|SG|GEN
A	PCP1	ELA|PL|POS|PCP1|ACT
A	PCP1	ELA|POS|PCP1|ACT|DV-U|SG
A	PCP1	ELA|SG|POS|PCP1|ACT
A	PCP1	ESS|DV-ILE|POS|PCP1|DV-TTA|ACT|PL
A	PCP1	GEN|PL|POS|PCP1|ACT
A	PCP1	GEN|SG|POS|PCP1|ACT
A	PCP1	ILL|PL|POS|PCP1|ACT
A	PCP1	ILL|POS|PCP1|ACT|DV-U|SG
A	PCP1	ILL|SG|POS|PCP1|ACT
A	PCP1	INE|PL|POS|PCP1|ACT
A	PCP1	INE|SG|POS|PCP1|ACT
A	PCP1	NOM|1SG|POS|PCP1|ACT|SG
A	PCP1	NOM|PL|POS|PCP1|ACT
A	PCP1	NOM|POS|PCP1|3|ACT|SG
A	PCP1	NOM|POS|PCP1|ACT|DV-ELE|SG
A	PCP1	NOM|POS|PCP1|ACT|DV-U|PL
A	PCP1	NOM|POS|PCP1|ACT|DV-U|SG
A	PCP1	NOM|POS|PCP1|DV-TTA|ACT|PL
A	PCP1	NOM|POS|PCP1|DV-TTA|ACT|SG
A	PCP1	NOM|POS|PCP1|DV-TTA|PSS|DV-ELE|PL
A	PCP1	NOM|POS|PCP1|DV-TTA|PSS|SG
A	PCP1	NOM|POS|PCP1|DV-UTU|ACT|PL
A	PCP1	NOM|POS|PCP1|st-hi|ACT|SG
A	PCP1	NOM|SG|POS|PCP1|ACT
A	PCP1	NOM|up|POS|PCP1|ACT|DV-U|SG
A	PCP1	NOM|up|POS|PCP1|ACT|SG
A	PCP1	NOM|up|POS|PCP1|PSS|SG
A	PCP1	NOM|up|POS|PCP1|kin|ACT|SG
A	PCP1	PL|ABL|POS|PCP1|ACT
A	PCP1	POS|PCP1|ACT|DV-ELE|SG|GEN
A	PCP1	POS|PCP1|ACT|DV-U|INE|SG
A	PCP1	POS|PCP1|ACT|DV-U|SG|GEN
A	PCP1	POS|PCP1|DV-TTA|ACT|PTV|SG
A	PCP1	POS|PCP1|DV-TTA|ACT|SG|GEN
A	PCP1	POS|PCP1|DV-TTA|PSS|SG|GEN
A	PCP1	POS|PCP1|DV-UTU|ACT|PTV|SG
A	PCP1	POS|PCP1|DV-UTU|ACT|SG|GEN
A	PCP1	PSS|ADE|POS|PCP1|PL
A	PCP1	PSS|ADE|SG|POS|PCP1
A	PCP1	PSS|ALL|SG|POS|PCP1
A	PCP1	PSS|ELA|SG|POS|PCP1
A	PCP1	PSS|ILL|SG|POS|PCP1
A	PCP1	PSS|PL|POS|PCP1|INE
A	PCP1	PSS|PL|POS|PCP1|NOM
A	PCP1	PSS|PL|POS|PCP1|PTV
A	PCP1	PSS|SG|ESS|POS|PCP1
A	PCP1	PSS|SG|POS|PCP1|GEN
A	PCP1	PSS|SG|POS|PCP1|INE
A	PCP1	PSS|SG|POS|PCP1|NOM
A	PCP1	PSS|SG|POS|PCP1|PTV
A	PCP1	PTV|PL|POS|PCP1|ACT
A	PCP1	PTV|SG|POS|PCP1|ACT
A	PCP1	SG|ABL|POS|PCP1|ACT
A	PCP1	SG|ESS|POS|PCP1|ACT
A	PCP1	TRA|PL|POS|PCP1|ACT
A	PCP1	TRA|POS|PCP1|3|PSS|SG
A	PCP1	TRA|POS|PCP1|DV-TTA|ACT|PL
A	PCP1	TRA|POS|PCP1|DV-TTA|PSS|PL
A	PCP1	TRA|PSS|POS|PCP1|PL
A	PCP1	TRA|PSS|SG|POS|PCP1
A	PCP1	TRA|SG|POS|PCP1|ACT
A	PCP1	up|POS|PCP1|ACT|PTV|SG
A	PCP1	up|POS|PCP1|ACT|SG|GEN
A	PCP2	ALL|POS|PCP2|ACT|DV-ELE|SG
A	PCP2	ALL|POS|PCP2|ACT|DV-U|PL
A	PCP2	COP|NOM|PCP2|POS|ACT|PL
A	PCP2	COP|NOM|PCP2|POS|ACT|SG
A	PCP2	COP|PCP2|POS|ACT|PTV|SG
A	PCP2	COP|PCP2|POS|ACT|SG|GEN
A	PCP2	DV-ILE|PCP2|POS|PSS|GEN|PL
A	PCP2	DV-ILE|PCP2|POS|PSS|SG|GEN
A	PCP2	DV-NTAA|PCP2|POS|PTV|PSS|SG
A	PCP2	DV-NTAA|POS|PCP2|ACT|SG|GEN
A	PCP2	ELA|PCP2|DV-TTA|POS|PSS|DV-ELE|PL
A	PCP2	ELA|POS|PCP2|ACT|DV-U|PL
A	PCP2	ELA|POS|PCP2|ACT|DV-U|SG
A	PCP2	ESS|DV-ILE|PCP2|POS|PSS|SG
A	PCP2	ESS|PCP2|POS|PSS|DV-ELE|SG
A	PCP2	ESS|POS|PCP2|DV-UTU|ACT|SG
A	PCP2	NOM|DV-ILE|PCP2|POS|PSS|SG
A	PCP2	NOM|DV-ILE|POS|PCP2|ACT|SG
A	PCP2	NOM|PCP2|DV-TTA|POS|PSS|DV-ELE|SG
A	PCP2	NOM|PCP2|DV-TTA|POS|PSS|PL
A	PCP2	NOM|PCP2|DV-TTA|POS|PSS|SG
A	PCP2	NOM|PCP2|POS|DV-U|PSS|SG
A	PCP2	NOM|PCP2|POS|PSS|DV-ELE|SG
A	PCP2	NOM|POS|DV-TTA|PCP2|ACT|DV-ELE|SG
A	PCP2	NOM|POS|DV-TTA|PCP2|ACT|PL
A	PCP2	NOM|POS|DV-TTA|PCP2|ACT|SG
A	PCP2	NOM|POS|PCP2|3|ACT|DV-U|SG
A	PCP2	NOM|POS|PCP2|3|ACT|SG
A	PCP2	NOM|POS|PCP2|ACT|DV-ELE|PL
A	PCP2	NOM|POS|PCP2|ACT|DV-ELE|SG
A	PCP2	NOM|POS|PCP2|ACT|DV-U|PL
A	PCP2	NOM|POS|PCP2|ACT|DV-U|SG
A	PCP2	NOM|POS|PCP2|DV-UTU|ACT|PL
A	PCP2	NOM|POS|PCP2|DV-UTU|ACT|SG
A	PCP2	NOM|POS|PCP2|kin|ACT|DV-U|SG
A	PCP2	NOM|POS|PCP2|kin|ACT|SG
A	PCP2	NOM|st-cllq|PCP2|POS|ACT|SG
A	PCP2	NOM|st-cllq|PCP2|POS|PSS|SG
A	PCP2	NOM|up|DV-ILE|PCP2|POS|PSS|SG
A	PCP2	NOM|up|PCP2|POS|PSS|PL
A	PCP2	NOM|up|PCP2|POS|PSS|SG
A	PCP2	NOM|up|POS|PCP2|ACT|PL
A	PCP2	NOM|up|POS|PCP2|ACT|SG
A	PCP2	PCP2|DV-TTA|POS|ADE|PSS|SG
A	PCP2	PCP2|DV-TTA|POS|PSS|DV-ELE|GEN|PL
A	PCP2	PCP2|DV-TTA|POS|PTV|PSS|SG
A	PCP2	PCP2|POS|3|PTV|DV-U|PSS|SG
A	PCP2	PCP2|POS|3|PTV|PSS|SG
A	PCP2	PCP2|POS|DV-UTU|PTV|PSS|SG
A	PCP2	PCP2|POS|PTV|DV-U|PSS|SG
A	PCP2	POS|ADE|PCP2|PL|ACT
A	PCP2	POS|ADE|SG|PCP2|ACT
A	PCP2	POS|ALL|PCP2|PL|ACT
A	PCP2	POS|ALL|SG|PCP2|ACT
A	PCP2	POS|DV-TTA|PCP2|ACT|SG|GEN
A	PCP2	POS|ELA|PCP2|PL|ACT
A	PCP2	POS|ELA|SG|PCP2|ACT
A	PCP2	POS|ESS|PCP2|PL|ACT
A	PCP2	POS|GEN|PCP2|PL|ACT
A	PCP2	POS|GEN|SG|PCP2|ACT
A	PCP2	POS|ILL|SG|PCP2|ACT
A	PCP2	POS|INE|PCP2|PL|ACT
A	PCP2	POS|INE|SG|PCP2|ACT
A	PCP2	POS|NOM|PCP2|PL|ACT
A	PCP2	POS|NOM|SG|PCP2|ACT
A	PCP2	POS|PCP2|ACT|DV-ELE|SG|GEN
A	PCP2	POS|PCP2|ACT|DV-U|GEN|PL
A	PCP2	POS|PCP2|ACT|DV-U|INE|PL
A	PCP2	POS|PCP2|ACT|DV-U|INE|SG
A	PCP2	POS|PCP2|ACT|DV-U|PTV|PL
A	PCP2	POS|PCP2|ACT|DV-U|PTV|SG
A	PCP2	POS|PCP2|ACT|DV-U|SG|GEN
A	PCP2	POS|PCP2|DV-UTU|ACT|PTV|SG
A	PCP2	POS|PTV|PCP2|PL|ACT
A	PCP2	POS|PTV|SG|PCP2|ACT
A	PCP2	POS|SG|ABL|PCP2|ACT
A	PCP2	POS|SG|ESS|PCP2|ACT
A	PCP2	PSS|ADE|PCP2|PL|POS
A	PCP2	PSS|ADE|SG|PCP2|POS
A	PCP2	PSS|ALL|SG|PCP2|POS
A	PCP2	PSS|ELA|PCP2|PL|POS
A	PCP2	PSS|ELA|SG|PCP2|POS
A	PCP2	PSS|ESS|PCP2|PL|POS
A	PCP2	PSS|GEN|PCP2|PL|POS
A	PCP2	PSS|GEN|SG|PCP2|POS
A	PCP2	PSS|ILL|PCP2|PL|POS
A	PCP2	PSS|ILL|SG|PCP2|POS
A	PCP2	PSS|INE|PCP2|PL|POS
A	PCP2	PSS|INE|SG|PCP2|POS
A	PCP2	PSS|NOM|PCP2|PL|POS
A	PCP2	PSS|NOM|SG|PCP2|POS
A	PCP2	PSS|PTV|PCP2|PL|POS
A	PCP2	PSS|PTV|SG|PCP2|POS
A	PCP2	PSS|SG|ABL|PCP2|POS
A	PCP2	PSS|SG|ESS|PCP2|POS
A	PCP2	TRA|PCP2|POS|3|PSS|SG
A	PCP2	TRA|POS|PCP2|ACT|DV-U|SG
A	PCP2	TRA|POS|SG|PCP2|ACT
A	PCP2	TRA|PSS|PCP2|PL|POS
A	PCP2	TRA|PSS|SG|PCP2|POS
A	PCP2	up|ELA|PCP2|POS|PSS|PL
A	PCP2	up|ELA|PCP2|POS|PSS|SG
A	PCP2	up|ESS|PCP2|POS|PSS|PL
A	PCP2	up|PCP2|POS|3|PTV|DV-U|PSS|SG
A	PCP2	up|PCP2|POS|3|PTV|PSS|SG
A	PCP2	up|PCP2|POS|INE|PSS|SG
A	PCP2	up|PCP2|POS|PSS|GEN|PL
A	PCP2	up|PCP2|POS|PSS|SG|GEN
A	PCP2	up|PCP2|POS|PTV|PSS|PL
A	PCP2	up|POS|PCP2|ACT|SG|GEN
A	PCP2	up|TRA|PCP2|POS|3|PSS|SG
A	Q	Q|PRON|1PL|PL|PTV
A	Q	Q|PRON|3|ABL|PL
A	Q	Q|PRON|3|ELA|PL
A	Q	Q|PRON|3|GEN|PL
A	Q	Q|PRON|3|PL|PTV
A	Q	Q|PRON|ABL|PL
A	Q	Q|PRON|ADE|PL
A	Q	Q|PRON|ADE|SG
A	Q	Q|PRON|ADE|SG|kin
A	Q	Q|PRON|ADE|SG|up
A	Q	Q|PRON|ALL|3|PL
A	Q	Q|PRON|ALL|PL
A	Q	Q|PRON|ALL|SG
A	Q	Q|PRON|ELA|PL
A	Q	Q|PRON|ELA|SG
A	Q	Q|PRON|ELA|SG|up
A	Q	Q|PRON|ELA|up|PL
A	Q	Q|PRON|ESS|PL
A	Q	Q|PRON|GEN|PL
A	Q	Q|PRON|GEN|PL|kin
A	Q	Q|PRON|ILL|3|PL
A	Q	Q|PRON|ILL|PL
A	Q	Q|PRON|ILL|SG
A	Q	Q|PRON|ILL|SG|kin
A	Q	Q|PRON|ILL|up|PL
A	Q	Q|PRON|ILL|up|SG
A	Q	Q|PRON|NOM
A	Q	Q|PRON|PL|INE
A	Q	Q|PRON|PL|NOM
A	Q	Q|PRON|PL|PTV
A	Q	Q|PRON|SG|ABL
A	Q	Q|PRON|SG|ESS
A	Q	Q|PRON|SG|GEN
A	Q	Q|PRON|SG|INE
A	Q	Q|PRON|SG|NOM
A	Q	Q|PRON|SG|PTV
A	Q	Q|PRON|SG|TRA
A	Q	Q|PRON|SG|kAAn|PTV
A	Q	Q|PRON|SG|kin|NOM
A	Q	Q|PRON|SG|up|ESS
A	Q	Q|PRON|SG|up|TRA
A	Q	Q|PRON|kin|PL|INE
A	Q	Q|PRON|kin|PL|PTV
A	Q	Q|PRON|up|GEN|PL
A	Q	Q|PRON|up|NOM
A	Q	Q|PRON|up|PL|INE
A	Q	Q|PRON|up|PL|INS
A	Q	Q|PRON|up|PL|NOM
A	Q	Q|PRON|up|PL|PTV
A	Q	Q|PRON|up|SG|GEN
A	Q	Q|PRON|up|SG|INE
A	Q	Q|PRON|up|SG|NOM
A	Q	Q|PRON|up|SG|PTV
A	Q	Q|PRON|up|hAn|NOM
A	TrunCo	TrunCo
A	TrunCo	TrunCo|up
A	TrunCo	digit|NOM|SG|ABBR|TrunCo
A	digit	digit|ABBR
A	digit	digit|ELA|SG|ABBR
A	digit	digit|ILL|SG|ABBR
A	digit	digit|INE|SG|ABBR
A	digit	digit|NOM|SG|ABBR
A	digit	digit|NOM|up|SG|ABBR
A	digit	digit|PTV|SG|ABBR
A	digit	digit|SG|ABBR|GEN
A	digit	digit|SG|ABL|ABBR
A	digit	digit|up|SG|ABBR|GEN
A	roman	roman|ALL|up|SG|ABBR
A	roman	roman|INE|up|SG|ABBR
A	roman	roman|NOM|up|SG|ABBR
A	roman	roman|PTV|up|SG|ABBR
A	roman	roman|SG|up|ABL|ABBR
A	roman	roman|up|SG|ABBR|GEN
D	AD-A	AD-A
D	AD-A	AD-A|kin
D	AD-A	up|AD-A
D	ADV	ADV
D	ADV	ADV|3
D	ADV	ADV|3|ADE
D	ADV	ADV|3|ADE|up
D	ADV	ADV|ABBR
D	ADV	ADV|ABL
D	ADV	ADV|ADE
D	ADV	ADV|ADE|CMP
D	ADV	ADV|ADE|kin
D	ADV	ADV|ADE|up
D	ADV	ADV|ALL
D	ADV	ADV|ALL|3
D	ADV	ADV|ALL|kin
D	ADV	ADV|ALL|up
D	ADV	ADV|DN-INEN|POS|MAN
D	ADV	ADV|DN-ITTAIN
D	ADV	ADV|DN-ITTAIN|DV-JA
D	ADV	ADV|DN-ITTAIN|up
D	ADV	ADV|DN-LLINEN|POS|MAN
D	ADV	ADV|DN-LLINEN|up|POS|MAN
D	ADV	ADV|DN-MAINEN|POS|MAN
D	ADV	ADV|DV-MATON|POS|MAN
D	ADV	ADV|DV-US|MAN|DN-LLINEN|POS
D	ADV	ADV|ELA
D	ADV	ADV|ESS|CMP
D	ADV	ADV|ESS|kin|CMP
D	ADV	ADV|ILL
D	ADV	ADV|ILL|3
D	ADV	ADV|ILL|kin
D	ADV	ADV|ILL|up
D	ADV	ADV|INE
D	ADV	ADV|INE|3
D	ADV	ADV|INE|up
D	ADV	ADV|INTERR
D	ADV	ADV|MAN
D	ADV	ADV|MAN|CMP
D	ADV	ADV|MAN|DV-VAINEN|CMP
D	ADV	ADV|MAN|POS|PCP1|ACT
D	ADV	ADV|MAN|SUP
D	ADV	ADV|MAN|up|SUP
D	ADV	ADV|PCP2|POS|ACT|DV-U|MAN
D	ADV	ADV|POS|MAN
D	ADV	ADV|POS|MAN|PCP2|ACT
D	ADV	ADV|PSS|MAN|PCP2|POS
D	ADV	ADV|PSS|POS|PCP1|MAN
D	ADV	ADV|PTV|CMP
D	ADV	ADV|REL
D	ADV	ADV|SG3|NEGV|INTERR|V
D	ADV	ADV|hAn
D	ADV	ADV|kAAn
D	ADV	ADV|kAAn|ADE
D	ADV	ADV|kin
D	ADV	ADV|pA
D	ADV	ADV|pA|up
D	ADV	ADV|st-cllq|ALL
D	ADV	ADV|st-cllq|POS|MAN
D	ADV	ADV|up
D	ADV	ADV|up|ABBR
D	ADV	ADV|up|ABL
D	ADV	ADV|up|INTERR
D	ADV	ADV|up|MAN
D	ADV	ADV|up|POS|MAN
D	ADV	ADV|up|POS|PCP1|PSS|MAN
D	ADV	ADV|up|SG3|NEGV|INTERR|V
D	ADV	ADV|up|hAn
D	ADV	ADV|up|kin
D	ADV	DN-TON|ADV|POS|MAN
J	C	C
J	C	CMPR|C
J	C	C|COORD
J	C	C|FORGN
J	C	C|NEGV|SG3|COORD|V
J	C	C|NEGV|SUB|PL1|V
J	C	C|PL3|NEGV|kA|COORD|V
J	C	C|SG1|NEGV|kA|COORD|V
J	C	C|SUB
J	C	C|SUB|NEGV|SG3|kO|V
J	C	C|SUB|SG1|NEGV|kO|V
J	C	C|SUB|kin
J	C	C|pA|SUB
J	C	C|st-arch|COORD
J	C	C|up|COORD
J	C	C|up|SUB
J	C	C|up|SUB|SG3|NEGV|V
J	C	C|up|SUB|kin
J	C	PL3|C|NEGV|SUB|V
J	C	SG1|C|NEGV|SUB|V
J	C	SG3|C|NEGV|SUB|V
J	C	kA|SG3|NEGV|C|COORD|V
J	C	kA|up|SG3|NEGV|C|COORD|V
N	N	1PL|DV-ILE|ELA|N|DV-U|SG
N	N	1SG|ADE|SG|N
N	N	1SG|ALL|SG|N
N	N	1SG|DA-UUS|NOM|SG|N
N	N	1SG|DV-TTA|N|ADE|DV-ELE|SG
N	N	1SG|DV-US|ADE|SG|N
N	N	1SG|ELA|SG|N
N	N	1SG|ELA|SG|up|N
N	N	1SG|GEN|PL|N
N	N	1SG|ILL|SG|DV-JA|N
N	N	1SG|ILL|SG|N
N	N	1SG|INE|SG|N
N	N	1SG|NOM|DV-US|SG|N
N	N	1SG|NOM|SG|N
N	N	1SG|NOM|SG|kin|N
N	N	1SG|NOM|up|SG|N
N	N	1SG|PTV|SG|N
N	N	1SG|SG|GEN|N
N	N	1SG|st-cllq|ELA|SG|N
N	N	1SG|st-cllq|ILL|SG|N
N	N	1SG|st-cllq|NOM|SG|N
N	N	3|ABL|PL|N
N	N	3|ADE|PL|N
N	N	3|ADE|SG|N
N	N	3|ADE|up|PL|N
N	N	3|CMT|DV-JA|N
N	N	3|CMT|DV-NTI|N
N	N	3|CMT|N
N	N	3|ELA|PL|N
N	N	3|ELA|SG|DV-JA|N
N	N	3|ELA|SG|N
N	N	3|ESS|DV-JA|PL|N
N	N	3|ESS|PL|N
N	N	3|GEN|PL|N
N	N	3|N|SG|GEN|DA-US
N	N	3|SG|GEN|N
N	N	3|up|ESS|PL|N
N	N	ABL|PL|N
N	N	ABL|SG|DV-MINEN|N
N	N	ABL|SG|DV-NTA|1PL|N
N	N	ADE|DV-JA|PL|N
N	N	ADE|N|SG|DA-US
N	N	ADE|PL|N
N	N	ADE|SG|1PL|N
N	N	ADE|SG|DV-JA|DV-TTA|N
N	N	ADE|SG|DV-JA|N
N	N	ADE|SG|N
N	N	ADE|SG|kin|N
N	N	ADE|SG|up|N
N	N	ADE|up|PL|N
N	N	ALL|1SG|PL|N
N	N	ALL|3|DV-JA|PL|N
N	N	ALL|3|PL|N
N	N	ALL|DV-ELE|DV-JA|PL|N
N	N	ALL|DV-JA|PL|N
N	N	ALL|DV-NTA|PL|N
N	N	ALL|N|SG|DA-US
N	N	ALL|PL|DV-JA|DV-TTA|N
N	N	ALL|PL|N
N	N	ALL|SG|3|N
N	N	ALL|SG|DV-JA|N
N	N	ALL|SG|N
N	N	ALL|SG|kin|N
N	N	ALL|up|3|PL|N
N	N	ALL|up|DV-JA|PL|N
N	N	ALL|up|PL|N
N	N	ALL|up|SG|N
N	N	ALL|up|SG|kin|N
N	N	CMT|up|N
N	N	DA-US|PCP2|N|PTV|PSS|SG
N	N	DA-UUS|3|ABL|PL|N
N	N	DA-UUS|3|INE|SG|N
N	N	DA-UUS|3|N|DN-LLINEN|PTV|SG
N	N	DA-UUS|ABL|3|N|DN-LLINEN|SG
N	N	DA-UUS|ADE|SG|DV-VAINEN|N
N	N	DA-UUS|ADE|SG|N
N	N	DA-UUS|DN-LLINEN|ELA|SG|N
N	N	DA-UUS|DN-LLINEN|INE|PL|N
N	N	DA-UUS|DN-LLINEN|NOM|SG|N
N	N	DA-UUS|DN-LLINEN|PTV|PL|N
N	N	DA-UUS|DN-LLINEN|PTV|SG|N
N	N	DA-UUS|DN-LLINEN|SG|GEN|N
N	N	DA-UUS|DN-LLINEN|SG|ILL|N
N	N	DA-UUS|ELA|PCP1|N|ACT|SG
N	N	DA-UUS|ELA|PL|N
N	N	DA-UUS|ELA|SG|DV-VAINEN|N
N	N	DA-UUS|ELA|SG|N
N	N	DA-UUS|ELA|SG|up|N
N	N	DA-UUS|GEN|PL|N
N	N	DA-UUS|GEN|SG|DV-VAINEN|N
N	N	DA-UUS|ILL|PCP1|N|ACT|SG
N	N	DA-UUS|ILL|PL|N
N	N	DA-UUS|ILL|SG|DV-MATON|N
N	N	DA-UUS|ILL|SG|DV-VAINEN|N
N	N	DA-UUS|ILL|SG|N
N	N	DA-UUS|ILL|up|SG|N
N	N	DA-UUS|INE|SG|DV-VAINEN|N
N	N	DA-UUS|INE|SG|N
N	N	DA-UUS|INE|SG|up|N
N	N	DA-UUS|NOM|PL|N
N	N	DA-UUS|NOM|SG|DV-VAINEN|N
N	N	DA-UUS|NOM|SG|N
N	N	DA-UUS|NOM|SG|up|N
N	N	DA-UUS|NOM|up|PL|N
N	N	DA-UUS|PCP1|N|3|ACT|DV-U|PTV|SG
N	N	DA-UUS|PCP1|N|ACT|DV-U|SG|GEN
N	N	DA-UUS|PCP1|N|ACT|PTV|SG
N	N	DA-UUS|PCP1|N|ACT|SG|GEN
N	N	DA-UUS|PCP1|N|PTV|PSS|PL
N	N	DA-UUS|PCP1|N|PTV|PSS|SG
N	N	DA-UUS|PTV|PL|N
N	N	DA-UUS|PTV|SG|DV-VAINEN|N
N	N	DA-UUS|PTV|SG|N
N	N	DA-UUS|PTV|SG|up|N
N	N	DA-UUS|PTV|kin|PL|N
N	N	DA-UUS|PTV|up|PL|N
N	N	DA-UUS|SG|ABL|3|N
N	N	DA-UUS|SG|ABL|N
N	N	DA-UUS|SG|DV-MATON|ESS|N
N	N	DA-UUS|SG|ESS|N
N	N	DA-UUS|SG|GEN|N
N	N	DA-UUS|SG|NOM|DN-INEN|N
N	N	DA-UUS|SG|NOM|DV-MATON|N
N	N	DA-UUS|SG|PTV|DN-INEN|N
N	N	DA-UUS|SG|PTV|DV-MATON|N
N	N	DA-UUS|TrunCo|SG|GEN|N
N	N	DA-UUS|up|SG|GEN|N
N	N	DN-TON|DA-UUS|ELA|PL|N
N	N	DN-TON|DA-UUS|ELA|SG|N
N	N	DN-TON|DA-UUS|ILL|PL|N
N	N	DN-TON|DA-UUS|ILL|SG|N
N	N	DN-TON|DA-UUS|INE|PL|N
N	N	DN-TON|DA-UUS|INE|SG|N
N	N	DN-TON|DA-UUS|NOM|SG|N
N	N	DN-TON|DA-UUS|PTV|PL|N
N	N	DN-TON|DA-UUS|PTV|SG|N
N	N	DN-TON|DA-UUS|SG|GEN|N
N	N	DV-ELE|SG|GEN|N
N	N	DV-ILE|N|3|DV-U|PTV|SG
N	N	DV-MATON|1PL|DA-UUS|N|SG|GEN
N	N	DV-MINEN|GEN|PL|N
N	N	DV-NA|NOM|SG|N
N	N	DV-NA|PTV|SG|N
N	N	DV-NTAA|DV-US|SG|GEN|N
N	N	DV-NTAA|DV-US|up|N|PTV|SG
N	N	DV-NTAA|NOM|DV-US|SG|N
N	N	DV-NTAA|NOM|SG|DV-MINEN|N
N	N	DV-NTAA|PTV|DV-US|PL|N
N	N	DV-NTAA|PTV|SG|DV-MINEN|N
N	N	DV-NTAA|SG|GEN|N
N	N	DV-NTAA|SG|ILL|DV-MINEN|N
N	N	DV-NTAA|TRA|SG|DV-MINEN|N
N	N	DV-TTA|N|DV-MINEN|PTV|DV-ELE|SG
N	N	DV-TTA|N|DV-U|DV-ELE|SG|GEN
N	N	DV-US|3|ALL|PL|N
N	N	DV-US|3|ILL|PL|N
N	N	DV-US|3|SG|GEN|N
N	N	DV-US|ADE|PL|N
N	N	DV-US|ADE|SG|N
N	N	DV-US|ADE|SG|up|N
N	N	DV-US|ALL|PL|N
N	N	DV-US|CMT|3|N
N	N	DV-US|ELA|3|PL|N
N	N	DV-US|ELA|PL|N
N	N	DV-US|ELA|SG|DV-TTA|N
N	N	DV-US|ELA|SG|N
N	N	DV-US|ELA|SG|up|N
N	N	DV-US|ESS|PL|N
N	N	DV-US|GEN|PL|N
N	N	DV-US|ILL|N|TrunCo|3|SG
N	N	DV-US|ILL|PL|N
N	N	DV-US|INS|PL|N
N	N	DV-US|PL|ILL|DV-TTA|N
N	N	DV-US|SG|ALL|DV-TTA|N
N	N	DV-US|SG|ALL|N
N	N	DV-US|SG|GEN|DV-TTA|N
N	N	DV-US|SG|GEN|N
N	N	DV-US|SG|ILL|N
N	N	DV-US|up|DV-TTA|N|INE|SG
N	N	DV-US|up|DV-TTA|N|SG|GEN
N	N	DV-US|up|ESS|PL|N
N	N	DV-US|up|GEN|PL|N
N	N	DV-US|up|SG|GEN|N
N	N	DV-US|up|SG|ILL|N
N	N	DV-US|up|TRA|DV-TTA|N|SG
N	N	DV-UTTA|ELA|DV-US|PL|N
N	N	DV-U|ADE|DV-ELE|SG|N
N	N	DV-U|ALL|DV-ELE|SG|N
N	N	DV-U|ALL|PL|N
N	N	DV-U|ALL|SG|N
N	N	DV-U|DV-ELE|GEN|PL|N
N	N	DV-U|DV-ELE|SG|GEN|N
N	N	DV-U|ELA|DV-ELE|SG|N
N	N	DV-U|ELA|PL|N
N	N	DV-U|ELA|SG|N
N	N	DV-U|ELA|SG|up|N
N	N	DV-U|GEN|PL|N
N	N	DV-U|ILL|PL|N
N	N	DV-U|ILL|SG|N
N	N	DV-U|ILL|up|SG|N
N	N	DV-U|INE|DV-ELE|PL|N
N	N	DV-U|INE|DV-ELE|SG|N
N	N	DV-U|INE|N|SG|DV-ILE
N	N	DV-U|INE|PL|N
N	N	DV-U|INE|SG|N
N	N	DV-U|INE|up|PL|N
N	N	DV-U|INE|up|SG|N
N	N	DV-U|NOM|3|SG|N
N	N	DV-U|NOM|DV-ELE|PL|N
N	N	DV-U|NOM|DV-ELE|SG|N
N	N	DV-U|NOM|DV-SKELE|SG|N
N	N	DV-U|NOM|N|PL|DV-ILE
N	N	DV-U|NOM|N|SG|DV-ILE
N	N	DV-U|NOM|PL|N
N	N	DV-U|NOM|SG|DV-MINEN|N
N	N	DV-U|NOM|SG|DV-TTA|N
N	N	DV-U|NOM|SG|N
N	N	DV-U|NOM|TrunCo|SG|N
N	N	DV-U|NOM|up|PL|N
N	N	DV-U|NOM|up|SG|N
N	N	DV-U|N|SG|GEN|DV-ILE
N	N	DV-U|N|SG|GEN|DV-NEISUUS
N	N	DV-U|PTV|3|PL|N
N	N	DV-U|PTV|3|SG|N
N	N	DV-U|PTV|DV-ELE|PL|N
N	N	DV-U|PTV|DV-ELE|SG|N
N	N	DV-U|PTV|DV-JA|PL|N
N	N	DV-U|PTV|DV-SKELE|SG|N
N	N	DV-U|PTV|N|PL|DV-ILE
N	N	DV-U|PTV|N|SG|DV-NEISUUS
N	N	DV-U|PTV|PL|N
N	N	DV-U|PTV|SG|DV-MINEN|N
N	N	DV-U|PTV|SG|N
N	N	DV-U|PTV|up|PL|N
N	N	DV-U|PTV|up|SG|N
N	N	DV-U|SG|DV-MINEN|GEN|N
N	N	DV-U|SG|ELA|DV-MINEN|N
N	N	DV-U|SG|GEN|N
N	N	DV-U|SG|ILL|DV-MINEN|N
N	N	DV-U|SG|N|ABL|DV-ILE
N	N	DV-U|SG|up|ESS|N
N	N	DV-U|TRA|SG|DV-MINEN|N
N	N	DV-U|TRA|SG|N
N	N	DV-U|TRA|up|SG|N
N	N	DV-U|up|SG|GEN|N
N	N	ELA|1SG|PL|N
N	N	ELA|DV-JA|PL|N
N	N	ELA|N|3|PL|DA-US
N	N	ELA|N|PL|DA-US
N	N	ELA|N|PL|st-slang
N	N	ELA|N|SG|DA-US
N	N	ELA|N|SG|DV-NEISUUS
N	N	ELA|N|SG|up|DA-US
N	N	ELA|PCP2|N|DA-US|PSS|SG
N	N	ELA|PL|DV-JA|DV-TTA|N
N	N	ELA|PL|N
N	N	ELA|SG|1PL|N
N	N	ELA|SG|2PL|N
N	N	ELA|SG|DV-JA|N
N	N	ELA|SG|N
N	N	ELA|SG|up|N
N	N	ELA|up|PL|N
N	N	ESS|DV-JA|DV-TTA|N|DV-ELE|PL
N	N	ESS|DV-JA|PL|N
N	N	ESS|PL|N
N	N	ESS|SG|DV-MINEN|N
N	N	FORGN|N
N	N	FORGN|SG|GEN|N
N	N	FORGN|up|N
N	N	GEN|3|DV-JA|PL|N
N	N	GEN|3|SG|DV-JA|N
N	N	GEN|DV-ELE|SG|DV-JA|N
N	N	GEN|DV-JA|PL|N
N	N	GEN|N|DV-JA|PL|DV-ILE
N	N	GEN|PL|DV-JA|DV-TTA|N
N	N	GEN|PL|N
N	N	GEN|SG|DV-JA|DV-TTA|N
N	N	GEN|SG|DV-JA|N
N	N	GEN|up|DV-JA|PL|N
N	N	GEN|up|SG|DV-JA|N
N	N	ILL|1PL|PL|N
N	N	ILL|1SG|PL|N
N	N	ILL|2SG|PL|N
N	N	ILL|3|PL|N
N	N	ILL|DV-JA|PL|N
N	N	ILL|DV-MINEN|PL|N
N	N	ILL|DV-TTA|N|DV-U|DV-ELE|PL
N	N	ILL|N|3|DV-MINEN|DV-U|SG
N	N	ILL|N|PL|DA-US
N	N	ILL|N|SG|3|DA-US
N	N	ILL|N|SG|DA-US
N	N	ILL|N|SG|DV-ILE
N	N	ILL|PL|DV-JA|DV-TTA|N
N	N	ILL|PL|DV-TTA|N
N	N	ILL|PL|N
N	N	ILL|SG|1PL|N
N	N	ILL|SG|3|N
N	N	ILL|SG|DV-JA|DV-TTA|N
N	N	ILL|SG|DV-JA|N
N	N	ILL|SG|DV-TTA|N
N	N	ILL|SG|N
N	N	ILL|SG|kin|N
N	N	ILL|up|PL|N
N	N	ILL|up|SG|3|N
N	N	ILL|up|SG|DV-JA|N
N	N	ILL|up|SG|N
N	N	INE|1PL|PL|N
N	N	INE|3|DV-NTA|PL|N
N	N	INE|3|N|SG|DA-US
N	N	INE|3|PL|N
N	N	INE|3|SG|N
N	N	INE|3|up|PL|N
N	N	INE|3|up|SG|N
N	N	INE|DV-JA|PL|N
N	N	INE|DV-US|3|PL|N
N	N	INE|DV-US|PL|DV-TTA|N
N	N	INE|DV-US|PL|N
N	N	INE|DV-US|SG|3|N
N	N	INE|DV-US|SG|DV-TTA|N
N	N	INE|DV-US|SG|N
N	N	INE|DV-US|TrunCo|SG|N
N	N	INE|DV-US|up|PL|N
N	N	INE|DV-US|up|SG|N
N	N	INE|DV-UTU|PL|N
N	N	INE|FORGN|SG|up|N
N	N	INE|N|SG|DA-US
N	N	INE|N|SG|up|DA-US
N	N	INE|N|up|PL|DV-ILE
N	N	INE|PL|N
N	N	INE|SG|1PL|N
N	N	INE|SG|DV-JA|N
N	N	INE|SG|DV-MINEN|N
N	N	INE|SG|DV-NTA|N
N	N	INE|SG|DV-NTI|N
N	N	INE|SG|DV-TTA|N
N	N	INE|SG|DV-UTU|DV-MINEN|N
N	N	INE|SG|N
N	N	INE|SG|kin|N
N	N	INE|SG|up|DV-MINEN|N
N	N	INE|SG|up|DV-NTA|N
N	N	INE|TrunCo|PL|N
N	N	INE|TrunCo|SG|N
N	N	INE|kin|PL|N
N	N	INE|up|PL|N
N	N	INE|up|SG|DV-TTA|N
N	N	INE|up|SG|N
N	N	INE|up|SG|kin|N
N	N	INS|PL|N
N	N	INS|kin|PL|N
N	N	INS|up|PL|N
N	N	NOM|1PL|PL|N
N	N	NOM|1SG|DA-UUS|PCP1|N|PSS|SG
N	N	NOM|2SG|SG|DV-JA|N
N	N	NOM|2SG|SG|N
N	N	NOM|2SG|SG|kin|N
N	N	NOM|3|N|SG|DA-US
N	N	NOM|3|PL|N
N	N	NOM|3|SG|DV-JA|N
N	N	NOM|3|SG|N
N	N	NOM|3|SG|kin|N
N	N	NOM|3|TrunCo|SG|N
N	N	NOM|3|up|SG|N
N	N	NOM|DA-UUS|DV-VAINEN|N|3|SG
N	N	NOM|DA-UUS|PCP1|N|ACT|SG
N	N	NOM|DA-UUS|PCP1|N|PSS|SG
N	N	NOM|DV-ELE|SG|DV-JA|N
N	N	NOM|DV-JA|PL|N
N	N	NOM|DV-MINEN|PL|N
N	N	NOM|DV-NTA|PL|N
N	N	NOM|DV-US|3|PL|N
N	N	NOM|DV-US|DV-TTA|N|TrunCo|SG
N	N	NOM|DV-US|PL|DV-TTA|N
N	N	NOM|DV-US|PL|N
N	N	NOM|DV-US|SG|2PL|N
N	N	NOM|DV-US|SG|3|N
N	N	NOM|DV-US|SG|DV-TTA|N
N	N	NOM|DV-US|SG|N
N	N	NOM|DV-US|TrunCo|SG|N
N	N	NOM|DV-US|up|DV-TTA|N|SG
N	N	NOM|DV-US|up|N|TrunCo|SG
N	N	NOM|DV-US|up|PL|N
N	N	NOM|DV-US|up|SG|N
N	N	NOM|DV-UTU|DV-MINEN|PL|N
N	N	NOM|DV-UTU|SG|N
N	N	NOM|FORGN|SG|N
N	N	NOM|FORGN|SG|up|N
N	N	NOM|N|3|DV-U|DV-ELE|SG
N	N	NOM|N|NUM|ORD|SG|GEN
N	N	NOM|N|PL|DA-US
N	N	NOM|N|SG|DA-US
N	N	NOM|N|SG|DV-ILE
N	N	NOM|N|SG|DV-JA|st-slang
N	N	NOM|N|SG|st-slang
N	N	NOM|N|SG|up|DA-US
N	N	NOM|N|SG|up|DV-NEISUUS
N	N	NOM|N|SG|up|st-slang
N	N	NOM|PCP2|N|DA-US|PSS|SG
N	N	NOM|PL|DV-JA|DV-TTA|N
N	N	NOM|PL|DV-TTA|N
N	N	NOM|PL|N
N	N	NOM|SG|1PL|N
N	N	NOM|SG|DV-JA|DN-TAR|N
N	N	NOM|SG|DV-JA|DV-TTA|N
N	N	NOM|SG|DV-JA|N
N	N	NOM|SG|DV-MINEN|3|N
N	N	NOM|SG|DV-MINEN|N
N	N	NOM|SG|DV-NTA|1PL|N
N	N	NOM|SG|DV-NTA|3|N
N	N	NOM|SG|DV-NTA|N
N	N	NOM|SG|DV-NTI|N
N	N	NOM|SG|DV-NTI|kAAn|N
N	N	NOM|SG|DV-TTA|N
N	N	NOM|SG|DV-UTU|DV-MINEN|N
N	N	NOM|SG|N
N	N	NOM|SG|TrunCo|DV-MINEN|N
N	N	NOM|SG|TrunCo|DV-NTA|N
N	N	NOM|SG|TrunCo|DV-NTI|N
N	N	NOM|SG|hAn|N
N	N	NOM|SG|kin|N
N	N	NOM|SG|up|DV-MINEN|N
N	N	NOM|SG|up|DV-NTA|N
N	N	NOM|SG|up|DV-NTI|N
N	N	NOM|SG|up|st-hi|N
N	N	NOM|TrunCo|N|SG|DA-US
N	N	NOM|TrunCo|PL|N
N	N	NOM|TrunCo|SG|DV-JA|N
N	N	NOM|TrunCo|SG|N
N	N	NOM|TrunCo|up|SG|N
N	N	NOM|kin|DV-JA|PL|N
N	N	NOM|kin|PL|N
N	N	NOM|t-MSilocat|SG|N
N	N	NOM|t-MSilocat|SG|up|N
N	N	NOM|up|DA-UUS|DV-VAINEN|N|SG
N	N	NOM|up|DA-UUS|N|DN-INEN|SG
N	N	NOM|up|DA-UUS|N|DN-LLINEN|SG
N	N	NOM|up|DA-UUS|N|DN-TON|PL
N	N	NOM|up|DA-UUS|N|DN-TON|SG
N	N	NOM|up|DA-UUS|PCP1|N|ACT|SG
N	N	NOM|up|DV-ILE|N|DV-U|SG
N	N	NOM|up|DV-JA|N|DV-UTU|SG
N	N	NOM|up|DV-JA|PL|N
N	N	NOM|up|N|DV-MINEN|DV-U|SG
N	N	NOM|up|N|DV-U|DV-ELE|PL
N	N	NOM|up|N|DV-U|DV-ELE|SG
N	N	NOM|up|PL|N
N	N	NOM|up|SG|DV-JA|N
N	N	NOM|up|SG|DV-TTA|N
N	N	NOM|up|SG|N
N	N	NOM|up|SG|hAn|N
N	N	NOM|up|SG|kin|N
N	N	NOM|up|SG|st-arch|N
N	N	NOM|up|kin|PL|N
N	N	NOM|up|st-cllq|N|TrunCo|SG
N	N	N|3|DV-U|INE|DV-ELE|SG
N	N	N|GEN|PL|DA-US
N	N	N|SG|GEN|DA-US
N	N	N|SG|GEN|DV-ILE
N	N	N|SG|GEN|DV-NEISUUS
N	N	N|SG|GEN|st-derog
N	N	PCP2|N|DA-US|PSS|SG|GEN
N	N	PL|GEN|DV-TTA|N
N	N	PTV|1PL|PL|N
N	N	PTV|1SG|PL|N
N	N	PTV|3|DV-ELE|PL|N
N	N	PTV|3|N|SG|DA-US
N	N	PTV|3|PL|N
N	N	PTV|3|SG|N
N	N	PTV|3|TrunCo|SG|N
N	N	PTV|DV-ELE|SG|N
N	N	PTV|DV-JA|PL|N
N	N	PTV|DV-MINEN|PL|N
N	N	PTV|DV-NTI|PL|N
N	N	PTV|DV-US|3|PL|N
N	N	PTV|DV-US|PL|DV-TTA|N
N	N	PTV|DV-US|PL|N
N	N	PTV|DV-US|SG|DV-TTA|N
N	N	PTV|DV-US|SG|N
N	N	PTV|DV-US|up|PL|N
N	N	PTV|DV-US|up|SG|N
N	N	PTV|DV-UTU|SG|N
N	N	PTV|FORGN|PL|N
N	N	PTV|FORGN|SG|up|N
N	N	PTV|N|DV-JA|PL|st-slang
N	N	PTV|N|PL|DA-US
N	N	PTV|N|PL|DV-ILE
N	N	PTV|N|SG|DA-US
N	N	PTV|PL|DV-JA|DV-TTA|N
N	N	PTV|PL|DV-TTA|N
N	N	PTV|PL|N
N	N	PTV|SG|1PL|N
N	N	PTV|SG|DV-ELE|DV-MINEN|N
N	N	PTV|SG|DV-JA|DV-TTA|N
N	N	PTV|SG|DV-JA|N
N	N	PTV|SG|DV-MINEN|3|N
N	N	PTV|SG|DV-MINEN|N
N	N	PTV|SG|DV-NTA|N
N	N	PTV|SG|DV-NTI|N
N	N	PTV|SG|DV-TTA|N
N	N	PTV|SG|DV-UTU|DV-MINEN|N
N	N	PTV|SG|N
N	N	PTV|SG|kin|N
N	N	PTV|SG|up|DV-NTA|N
N	N	PTV|TrunCo|PL|N
N	N	PTV|TrunCo|SG|N
N	N	PTV|up|DV-JA|PL|N
N	N	PTV|up|PL|N
N	N	PTV|up|SG|1PL|N
N	N	PTV|up|SG|N
N	N	SG|3|ABL|N
N	N	SG|3|ADE|DV-NTA|N
N	N	SG|3|DV-NTA|GEN|N
N	N	SG|3|ELA|DV-MINEN|N
N	N	SG|3|ESS|DV-JA|N
N	N	SG|3|ESS|N
N	N	SG|3|N|ABL|DA-US
N	N	SG|3|up|ABL|N
N	N	SG|ABE|N
N	N	SG|ABL|DV-JA|N
N	N	SG|ABL|N
N	N	SG|ADE|DV-MINEN|N
N	N	SG|ADE|DV-NTA|up|N
N	N	SG|ADE|DV-NTI|N
N	N	SG|ALL|DV-MINEN|N
N	N	SG|ALL|DV-NTA|N
N	N	SG|ALL|up|DV-MINEN|N
N	N	SG|ALL|up|st-hi|N
N	N	SG|DV-ELE|ESS|DV-JA|N
N	N	SG|DV-MINEN|GEN|N
N	N	SG|DV-NTA|GEN|N
N	N	SG|DV-NTI|GEN|N
N	N	SG|DV-US|ABL|3|N
N	N	SG|DV-US|ESS|N
N	N	SG|DV-US|up|ABL|N
N	N	SG|DV-US|up|ESS|N
N	N	SG|DV-UTU|DV-MINEN|GEN|N
N	N	SG|ELA|DV-MINEN|N
N	N	SG|ELA|DV-NTA|N
N	N	SG|ELA|DV-NTI|N
N	N	SG|ELA|DV-NTI|up|N
N	N	SG|ELA|DV-UTU|DV-MINEN|N
N	N	SG|ESS|DV-JA|DV-TTA|N
N	N	SG|ESS|DV-JA|N
N	N	SG|ESS|N
N	N	SG|ESS|kin|N
N	N	SG|FORGN|ESS|N
N	N	SG|GEN|DV-TTA|N
N	N	SG|GEN|N
N	N	SG|GEN|hAn|N
N	N	SG|ILL|DV-MINEN|N
N	N	SG|ILL|DV-NTA|3|N
N	N	SG|ILL|DV-NTA|N
N	N	SG|ILL|DV-NTI|N
N	N	SG|ILL|t-EUparl|N
N	N	SG|ILL|up|DV-NTA|N
N	N	SG|N|ABL|DA-US
N	N	SG|up|ABL|N
N	N	SG|up|DV-MINEN|GEN|N
N	N	SG|up|DV-NTA|GEN|N
N	N	SG|up|DV-NTI|GEN|N
N	N	SG|up|ESS|N
N	N	SG|up|st-hi|GEN|N
N	N	TRA|3|PL|N
N	N	TRA|3|SG|DV-JA|N
N	N	TRA|3|SG|N
N	N	TRA|3|up|SG|N
N	N	TRA|DA-UUS|PCP1|N|PSS|PL
N	N	TRA|DA-UUS|SG|DV-MATON|N
N	N	TRA|DA-UUS|SG|N
N	N	TRA|DV-JA|PL|N
N	N	TRA|DV-US|SG|N
N	N	TRA|N|PL|DA-US
N	N	TRA|N|SG|DA-US
N	N	TRA|PL|N
N	N	TRA|SG|DV-JA|N
N	N	TRA|SG|DV-MINEN|N
N	N	TRA|SG|DV-NTA|N
N	N	TRA|SG|N
N	N	TRA|st-cllq|DV-US|SG|N
N	N	TRA|st-cllq|SG|N
N	N	TRA|up|SG|DV-JA|N
N	N	TRA|up|SG|N
N	N	TrunCo|3|ADE|SG|N
N	N	TrunCo|ADE|SG|N
N	N	TrunCo|ALL|SG|N
N	N	TrunCo|DV-US|ELA|PL|N
N	N	TrunCo|DV-US|SG|GEN|N
N	N	TrunCo|DV-US|SG|ILL|N
N	N	TrunCo|ELA|PL|N
N	N	TrunCo|ELA|SG|N
N	N	TrunCo|GEN|PL|N
N	N	TrunCo|ILL|SG|N
N	N	TrunCo|SG|GEN|N
N	N	TrunCo|up|SG|GEN|N
N	N	digit|ADE|PL|N
N	N	digit|ADE|SG|N
N	N	digit|ADE|SG|kin|N
N	N	digit|ADE|SG|up|N
N	N	digit|ALL|SG|N
N	N	digit|INE|SG|N
N	N	digit|NOM|SG|N
N	N	digit|PTV|3|PL|N
N	N	digit|PTV|SG|N
N	N	digit|SG|ABL|N
N	N	digit|SG|GEN|N
N	N	kAAn|ADE|SG|DV-JA|N
N	N	kAAn|ADE|SG|N
N	N	kAAn|ILL|SG|N
N	N	kin|GEN|PL|N
N	N	kin|SG|GEN|N
N	N	roman|INE|up|PL|N
N	N	roman|NOM|up|SG|N
N	N	roman|up|SG|GEN|N
N	N	st-cllq|3|INE|PL|N
N	N	st-cllq|3|NOM|SG|N
N	N	st-cllq|ADE|SG|N
N	N	st-cllq|ADE|SG|up|N
N	N	st-cllq|ALL|up|SG|N
N	N	st-cllq|ELA|SG|N
N	N	st-cllq|ELA|up|PL|N
N	N	st-cllq|ESS|PL|N
N	N	st-cllq|GEN|PL|N
N	N	st-cllq|ILL|PL|N
N	N	st-cllq|ILL|SG|3|N
N	N	st-cllq|ILL|SG|N
N	N	st-cllq|ILL|up|SG|N
N	N	st-cllq|INE|SG|N
N	N	st-cllq|INS|PL|N
N	N	st-cllq|NOM|PL|N
N	N	st-cllq|NOM|SG|N
N	N	st-cllq|NOM|SG|up|N
N	N	st-cllq|NOM|up|PL|N
N	N	st-cllq|PTV|PL|N
N	N	st-cllq|PTV|SG|N
N	N	st-cllq|PTV|SG|up|N
N	N	st-cllq|SG|ABL|N
N	N	st-cllq|SG|GEN|N
N	N	st-cllq|SG|NOM|DV-MINEN|N
N	N	st-vrnc|SG|GEN|N
N	N	t-EU-vk|INE|SG|N
N	N	t-EU-vk|SG|GEN|N
N	N	t-MSasiakirja|NOM|PL|N
N	N	t-MSasiakirja|PTV|PL|N
N	N	t-MSilocat|SG|GEN|N
N	N	t-MSlukumäärä|PTV|SG|N
N	N	t-MSolocat|ADE|PL|N
N	N	up|ABL|PL|N
N	N	up|ADE|DV-JA|PL|N
N	N	up|DA-UUS|DV-VAINEN|N|PTV|SG
N	N	up|DA-UUS|N|3|INE|SG
N	N	up|DA-UUS|N|DN-LLINEN|PTV|SG
N	N	up|DA-UUS|N|DN-TON|SG|GEN
N	N	up|DA-UUS|PCP1|N|PTV|PSS|PL
N	N	up|DV-ELE|SG|GEN|N
N	N	up|DV-ILE|N|DV-U|PTV|PL
N	N	up|DV-ILE|N|DV-U|SG|GEN
N	N	up|DV-TTA|N|DV-U|PTV|DV-ELE|PL
N	N	up|ELA|DV-JA|PL|N
N	N	up|ELA|N|DV-U|DV-ELE|SG
N	N	up|ELA|SG|DV-JA|N
N	N	up|ESS|PL|N
N	N	up|FORGN|SG|GEN|N
N	N	up|GEN|PL|N
N	N	up|ILL|N|DV-MINEN|DV-U|SG
N	N	up|INS|kin|PL|N
N	N	up|N|3|DV-MINEN|PTV|SG
N	N	up|N|DV-UTU|DV-MINEN|SG|GEN
N	N	up|N|DV-U|DV-ELE|SG|GEN
N	N	up|N|DV-U|INE|DV-ELE|PL
N	N	up|N|GEN|PL|DA-US
N	N	up|N|SG|GEN|DA-US
N	N	up|N|SG|GEN|st-derog
N	N	up|N|SG|GEN|st-slang
N	N	up|SG|ABE|N
N	N	up|SG|GEN|N
N	N	up|st-arch|st-derog|N|SG|GEN
N	N	up|st-hi|GEN|PL|N
N	N	up|t-EUparl|GEN|PL|N
N	PROP	ADE|N|SG|up|PROP
N	PROP	ADE|N|up|PL|PROP
N	PROP	ALL|N|SG|up|PROP
N	PROP	ALL|N|up|PL|PROP
N	PROP	A|ABL|POS|DN-LAINEN|PROP|PL
N	PROP	A|ABL|POS|DN-LAINEN|PROP|SG
N	PROP	A|ALL|POS|DN-LAINEN|PROP|PL
N	PROP	A|ALL|POS|DN-LAINEN|PROP|SG
N	PROP	A|ELA|POS|DN-LAINEN|PROP|PL
N	PROP	A|ELA|POS|DN-LAINEN|PROP|SG
N	PROP	A|ESS|POS|DN-LAINEN|PROP|SG
N	PROP	A|ILL|POS|DN-LAINEN|PROP|PL
N	PROP	A|ILL|POS|DN-LAINEN|PROP|SG
N	PROP	A|NOM|POS|DN-LAINEN|PROP|PL
N	PROP	A|NOM|POS|DN-LAINEN|PROP|SG
N	PROP	A|NOM|up|POS|DN-LAINEN|PROP|PL
N	PROP	A|NOM|up|POS|DN-LAINEN|PROP|SG
N	PROP	A|POS|DN-LAINEN|ADE|PROP|SG
N	PROP	A|POS|DN-LAINEN|INE|PROP|PL
N	PROP	A|POS|DN-LAINEN|INE|PROP|SG
N	PROP	A|POS|DN-LAINEN|PROP|GEN|PL
N	PROP	A|POS|DN-LAINEN|PROP|SG|GEN
N	PROP	A|POS|DN-LAINEN|PTV|PROP|PL
N	PROP	A|POS|DN-LAINEN|PTV|PROP|SG
N	PROP	A|TRA|POS|DN-LAINEN|PROP|SG
N	PROP	A|up|ESS|POS|DN-LAINEN|PROP|SG
N	PROP	A|up|POS|DN-LAINEN|ADE|PROP|SG
N	PROP	A|up|POS|DN-LAINEN|INE|PROP|PL
N	PROP	A|up|POS|DN-LAINEN|PROP|GEN|PL
N	PROP	A|up|POS|DN-LAINEN|PROP|SG|GEN
N	PROP	A|up|POS|DN-LAINEN|PTV|PROP|SG
N	PROP	DA-UUS|ELA|N|DN-LAINEN|SG|PROP
N	PROP	DA-UUS|N|DN-LAINEN|SG|GEN|PROP
N	PROP	ELA|N|SG|up|PROP
N	PROP	ELA|N|up|PL|PROP
N	PROP	ILL|N|SG|PROP
N	PROP	ILL|N|SG|up|PROP
N	PROP	ILL|N|up|PL|PROP
N	PROP	INE|N|SG|PROP
N	PROP	INE|N|SG|up|PROP
N	PROP	INE|N|up|PL|PROP
N	PROP	NOM|DA-UUS|N|DN-LAINEN|SG|PROP
N	PROP	NOM|N|DN-LAINEN|PL|PROP
N	PROP	NOM|N|SG|PROP
N	PROP	NOM|N|SG|up|PROP
N	PROP	NOM|N|up|PL|PROP
N	PROP	NOM|up|1PL|N|PROP|SG
N	PROP	NOM|up|N|3|PROP|SG
N	PROP	NOM|up|N|FORGN|PROP|PL
N	PROP	NOM|up|N|FORGN|PROP|SG
N	PROP	NOM|up|N|TrunCo|PROP|SG
N	PROP	NOM|up|N|kin|PROP|SG
N	PROP	NOM|up|kAAn|N|PROP|SG
N	PROP	N|ABL|up|PL|PROP
N	PROP	N|DN-LAINEN|SG|ALL|PROP
N	PROP	N|DN-LAINEN|SG|GEN|PROP
N	PROP	N|FORGN|up|PROP
N	PROP	N|SG|GEN|PROP
N	PROP	N|up|PROP
N	PROP	PROP
N	PROP	PTV|N|DN-LAINEN|SG|PROP
N	PROP	PTV|N|SG|up|PROP
N	PROP	SG|N|ABL|up|PROP
N	PROP	SG|N|ESS|up|PROP
N	PROP	up|ABL|N|3|PROP|PL
N	PROP	up|ABL|N|3|PROP|SG
N	PROP	up|ILL|N|3|PROP|SG
N	PROP	up|N|GEN|PL|PROP
N	PROP	up|N|PL|INS|PROP
N	PROP	up|N|SG|ABE|PROP
N	PROP	up|N|SG|GEN|PROP
N	PROP	up|N|kin|INE|PROP|SG
N	PROP	up|PROP
N	PROP	up|TRA|N|3|PROP|SG
N	PROP	up|hAn|ILL|N|3|PROP|SG
P	PRON	1SG|PRON|ALL|REFL/Q|SG
P	PRON	1SG|PRON|REFL/Q|SG|NOM
P	PRON	1SG|PRON|REFL/Q|SG|PTV
P	PRON	NOM|up|PRON|kin|SG|DEM
P	PRON	PERS|PRON|ABL|PL
P	PRON	PERS|PRON|ADE|PL
P	PRON	PERS|PRON|ADE|SG
P	PRON	PERS|PRON|ADE|SG|up
P	PRON	PERS|PRON|ADE|up|PL
P	PRON	PERS|PRON|ALL|PL
P	PRON	PERS|PRON|ALL|SG
P	PRON	PERS|PRON|ALL|up|PL
P	PRON	PERS|PRON|ALL|up|SG
P	PRON	PERS|PRON|ELA|PL
P	PRON	PERS|PRON|ELA|SG
P	PRON	PERS|PRON|GEN|PL
P	PRON	PERS|PRON|ILL|PL
P	PRON	PERS|PRON|ILL|SG
P	PRON	PERS|PRON|PL|ACC
P	PRON	PERS|PRON|PL|NOM
P	PRON	PERS|PRON|PL|PTV
P	PRON	PERS|PRON|SG|ABL
P	PRON	PERS|PRON|SG|ACC
P	PRON	PERS|PRON|SG|GEN
P	PRON	PERS|PRON|SG|GEN|kin
P	PRON	PERS|PRON|SG|INE
P	PRON	PERS|PRON|SG|NOM
P	PRON	PERS|PRON|SG|PTV
P	PRON	PERS|PRON|SG|kin|NOM
P	PRON	PERS|PRON|kin|PL|NOM
P	PRON	PERS|PRON|pA|SG|NOM
P	PRON	PERS|PRON|up|GEN|PL
P	PRON	PERS|PRON|up|PL|NOM
P	PRON	PERS|PRON|up|PL|PTV
P	PRON	PERS|PRON|up|SG|ACC
P	PRON	PERS|PRON|up|SG|GEN
P	PRON	PERS|PRON|up|SG|NOM
P	PRON	PERS|PRON|up|SG|PTV
P	PRON	PRON|3|REFL/Q|SG|INE
P	PRON	PRON|3|REFL/Q|SG|NOM
P	PRON	PRON|3|REFL/Q|SG|PTV
P	PRON	PRON|ADE|DEM|PL
P	PRON	PRON|ADE|DEM|PL|kin
P	PRON	PRON|ADE|REFL/Q|SG|3
P	PRON	PRON|ADE|SG|DEM
P	PRON	PRON|ADE|SG|DEM|kin
P	PRON	PRON|ADE|SG|REL
P	PRON	PRON|ALL|DEM|PL
P	PRON	PRON|ALL|REFL/Q|SG|1PL
P	PRON	PRON|ALL|REFL/Q|SG|3
P	PRON	PRON|ALL|REFL/Q|SG|kin
P	PRON	PRON|ALL|SG|DEM
P	PRON	PRON|ALL|SG|DEM|kin
P	PRON	PRON|ALL|SG|REL
P	PRON	PRON|DEM|PL|GEN
P	PRON	PRON|DEM|PL|INE
P	PRON	PRON|DEM|PL|NOM
P	PRON	PRON|DEM|PL|PTV
P	PRON	PRON|ELA|DEM|PL
P	PRON	PRON|ELA|REFL/Q|SG|1PL
P	PRON	PRON|ELA|REFL/Q|SG|3
P	PRON	PRON|ELA|REL
P	PRON	PRON|ELA|SG|DEM
P	PRON	PRON|ELA|SG|DEM|kin
P	PRON	PRON|ELA|SG|REL
P	PRON	PRON|ELA|up|REL
P	PRON	PRON|GEN|REL
P	PRON	PRON|GEN|REL|PL
P	PRON	PRON|ILL|DEM|PL
P	PRON	PRON|ILL|PL|REL
P	PRON	PRON|ILL|REFL/Q|SG|1PL
P	PRON	PRON|ILL|REFL/Q|SG|3
P	PRON	PRON|ILL|REL
P	PRON	PRON|ILL|SG|DEM
P	PRON	PRON|ILL|SG|REL
P	PRON	PRON|ILL|up|DEM|PL
P	PRON	PRON|ILL|up|REL
P	PRON	PRON|ILL|up|SG|DEM
P	PRON	PRON|INTG|SG|NOM
P	PRON	PRON|INTG|SG|s|NOM
P	PRON	PRON|INTG|pA|SG|NOM
P	PRON	PRON|INTG|s|PTV
P	PRON	PRON|PL|REL|NOM
P	PRON	PRON|PL|REL|PTV
P	PRON	PRON|REFL/Q|SG|1PL|PTV
P	PRON	PRON|REFL/Q|SG|NOM
P	PRON	PRON|REFL/Q|SG|kin|NOM
P	PRON	PRON|REFL/Q|SG|up|NOM
P	PRON	PRON|REL|INE
P	PRON	PRON|REL|PTV
P	PRON	PRON|SG|ABL|DEM
P	PRON	PRON|SG|DEM|GEN
P	PRON	PRON|SG|DEM|INE
P	PRON	PRON|SG|DEM|NOM
P	PRON	PRON|SG|DEM|PTV
P	PRON	PRON|SG|DEM|hAn|NOM
P	PRON	PRON|SG|ESS|DEM
P	PRON	PRON|SG|ESS|DEM|kAAn
P	PRON	PRON|SG|ESS|DEM|kin
P	PRON	PRON|SG|GEN|REL
P	PRON	PRON|SG|REFL/Q|ABL|3
P	PRON	PRON|SG|REFL/Q|ESS|3
P	PRON	PRON|SG|REL|INE
P	PRON	PRON|SG|REL|NOM
P	PRON	PRON|SG|REL|PTV
P	PRON	PRON|SG|up|ESS|DEM
P	PRON	PRON|kin|DEM|PL|INE
P	PRON	PRON|kin|DEM|PL|PTV
P	PRON	PRON|kin|SG|DEM|NOM
P	PRON	PRON|up|DEM|PL|GEN
P	PRON	PRON|up|DEM|PL|INE
P	PRON	PRON|up|DEM|PL|NOM
P	PRON	PRON|up|DEM|PL|PTV
P	PRON	PRON|up|REL|PTV
P	PRON	PRON|up|SG|DEM|GEN
P	PRON	PRON|up|SG|DEM|INE
P	PRON	PRON|up|SG|DEM|NOM
P	PRON	PRON|up|SG|DEM|PTV
P	PRON	PRON|up|SG|REL|NOM
P	PRON	REFL/Q|1SG|PRON|ADE|up|SG
P	PRON	TRA|PRON|INTG|kOhAn
P	PRON	TRA|PRON|REL
P	PRON	TRA|PRON|SG|DEM
P	PRON	TRA|PRON|up|REL
P	PRON	up|ESS|kAAn|PRON|DEM|SG
P	PRON	up|PRON|ADE|SG|DEM
P	PRON	up|PRON|ELA|DEM|PL
P	PRON	up|PRON|ELA|SG|DEM
P	PRON	up|PRON|pA|DEM|INE|SG
P	PRON	up|hAn|PRON|DEM|SG|GEN
R	PP	PP
R	PP	PP|3
R	PP	PP|ADE|3
R	PP	PP|FORGN
R	PP	PP|kin
R	PP	PP|up
R	PSP	1SG|PSP|ABL
R	PSP	INE|PSP
R	PSP	PSP
R	PSP	PSP|1SG|ILL
R	PSP	PSP|3
R	PSP	PSP|ADE|1SG
R	PSP	PSP|ALL|3
R	PSP	PSP|ILL|1PL
R	PSP	PSP|ILL|3
R	PSP	PSP|up|1SG|ALL
V	V	ACT|COND|PL1|DV-TTA|V
V	V	ACT|COND|PL1|V
V	V	ACT|DV-ELE|INF2|INS|V
V	V	ACT|DV-ELE|PL3|PRES|V
V	V	ACT|DV-UTU|PL3|PRES|V
V	V	ACT|IMPV|PL1|V
V	V	ACT|IMPV|SG2|V
V	V	ACT|IMPV|up|SG2|V
V	V	ACT|INF2|INS|V
V	V	ACT|PL1|PRES|V
V	V	ACT|PL2|PRES|V
V	V	ACT|PL3|PRES|DV-TTA|V
V	V	ACT|PL3|PRES|V
V	V	ACT|PL3|up|PRES|V
V	V	ACT|SG3|DV-ELE|COND|V
V	V	ACT|SG3|DV-ELE|PRES|V
V	V	ACT|SG3|DV-UTU|PRES|V
V	V	ACT|SG3|V|PRES|DV-ILE
V	V	ACT|V|INF2|INS|DV-ILE
V	V	ADE|DV-ELE|INF3|DV-TTA|V
V	V	ADE|DV-ELE|INF3|V
V	V	ADE|INF3|DV-TTA|V
V	V	ADE|INF3|V
V	V	ADE|INF3|up|V
V	V	COP|1SG|V|ACT|INE|INF2
V	V	COP|ACT|COND|PL1|V
V	V	COP|ACT|COND|PL3|V
V	V	COP|ACT|NEG|PRES|V
V	V	COP|ACT|PL1|PRES|V
V	V	COP|ACT|PL3|PRES|V
V	V	COP|ADE|INF3|V
V	V	COP|ILL|INF3|V
V	V	COP|INE|ACT|INF2|V
V	V	COP|INE|INF3|V
V	V	COP|NEG|ACT|COND|V
V	V	COP|NEG|V|PAST|ACT|PL
V	V	COP|NEG|V|PAST|ACT|SG
V	V	COP|NEG|V|kAAn|ACT|PRES
V	V	COP|NEG|V|kAAn|PAST|ACT|SG
V	V	COP|NEG|V|kin|ACT|PRES
V	V	COP|PL3|V|PAST|kin|ACT
V	V	COP|PL3|V|kO|PAST|ACT
V	V	COP|PL3|V|kin|ACT|PRES
V	V	COP|SG1|V|kin|ACT|PRES
V	V	COP|SG2|ACT|PRES|V
V	V	COP|SG3|ACT|COND|V
V	V	COP|SG3|ACT|POTN|V
V	V	COP|SG3|ACT|PRES|V
V	V	COP|SG3|V|COND|kin|ACT
V	V	COP|SG3|V|PAST|kin|ACT
V	V	COP|SG3|V|kO|ACT|PRES
V	V	COP|SG3|V|kO|COND|ACT
V	V	COP|SG3|V|kin|ACT|PRES
V	V	COP|V|up|IMPV|SG2|ACT
V	V	COP|kAAn|SG3|V|ACT|PRES
V	V	COP|up|PL1|V|ACT|PRES
V	V	COP|up|PL1|V|PAST|ACT
V	V	COP|up|PL3|V|kO|ACT|PRES
V	V	COP|up|SG1|V|ACT|PRES
V	V	COP|up|SG1|V|PAST|ACT
V	V	COP|up|SG1|V|kO|ACT|PRES
V	V	COP|up|SG3|V|ACT|PRES
V	V	COP|up|SG3|V|COND|ACT|kOhAn
V	V	COP|up|SG3|V|PAST|ACT
V	V	COP|up|SG3|V|kO|ACT|PRES
V	V	COP|up|SG3|V|kO|COND|ACT
V	V	COP|up|SG3|V|kO|PAST|ACT
V	V	COP|up|hAn|SG3|V|ACT|PRES
V	V	DV-ILE|NEG|ACT|PAST|V|SG
V	V	DV-ILE|SG3|V|DV-TTA|ACT|PRES
V	V	DV-NTAA|ILL|INF3|V
V	V	DV-NTAA|LAT|DV-ELE|INF1|V
V	V	DV-NTAA|LAT|INF1|V
V	V	DV-NTAA|NEG|ACT|PRES|V
V	V	DV-NTAA|NEG|V|PAST|ACT|SG
V	V	DV-NTAA|PAST|ACT|PL3|V
V	V	DV-NTAA|PAST|PSS|PE4|V
V	V	DV-NTAA|PAST|SG3|ACT|V
V	V	DV-NTAA|SG3|ACT|PRES|V
V	V	DV-NTAA|SG3|V|kin|ACT|PRES
V	V	DV-NTAA|up|V|INE|PSS|INF2
V	V	DV-U|ACT|COND|PL1|V
V	V	DV-U|ACT|INF2|INS|V
V	V	DV-U|ACT|PL1|PRES|V
V	V	DV-U|ACT|PL3|PRES|V
V	V	DV-U|ADE|INF3|V
V	V	DV-U|ILL|INF3|V
V	V	DV-U|INE|ACT|INF2|V
V	V	DV-U|INE|INF3|V
V	V	DV-U|LAT|INF1|V
V	V	DV-U|NEG|ACT|COND|V
V	V	DV-U|NEG|ACT|PRES|V
V	V	DV-U|PAST|ACT|PL3|V
V	V	DV-U|PAST|PSS|PE4|V
V	V	DV-U|PAST|SG3|ACT|V
V	V	DV-U|PSS|PE4|PRES|V
V	V	DV-U|SG3|ACT|COND|V
V	V	DV-U|SG3|ACT|PRES|V
V	V	ELA|INF3|V
V	V	ILL|DV-ELE|INF3|V
V	V	ILL|DV-SKELE|INF3|V
V	V	ILL|INF3|DV-TTA|V
V	V	ILL|INF3|V
V	V	ILL|V|INF3|DV-ILE
V	V	ILL|up|INF3|V
V	V	INE|3|ACT|INF2|V
V	V	INE|ACT|INF2|1PL|V
V	V	INE|ACT|INF2|DV-TTA|V
V	V	INE|ACT|INF2|V
V	V	INE|DV-ELE|INF3|V
V	V	INE|INF3|V
V	V	INE|up|INF3|V
V	V	INF3|ABE|1PL|V
V	V	INF3|ABE|V
V	V	LAT|COP|INF1|V
V	V	LAT|DV-ELE|INF1|DV-TTA|V
V	V	LAT|DV-ELE|INF1|V
V	V	LAT|DV-UTU|INF1|V
V	V	LAT|INF1|DV-TTA|V
V	V	LAT|INF1|V
V	V	LAT|V|INF1|DV-ILE
V	V	LAT|kAAn|INF1|V
V	V	LAT|kin|INF1|V
V	V	LAT|st-cllq|INF1|V
V	V	LAT|st-cllq|V|INF1|DV-ILE
V	V	MAN|COP|ACT|INF2|V
V	V	NEGV|PL1|V
V	V	NEG|ACT|COND|DV-TTA|V
V	V	NEG|ACT|COND|V
V	V	NEG|ACT|COND|kAAn|V
V	V	NEG|ACT|PRES|DV-TTA|V
V	V	NEG|ACT|PRES|V
V	V	NEG|ACT|kAAn|PRES|V
V	V	NEG|V|DV-TTA|PAST|ACT|SG
V	V	NEG|V|PAST|ACT|DV-ELE|SG
V	V	NEG|V|PAST|ACT|DV-U|PL
V	V	NEG|V|PAST|ACT|DV-U|SG
V	V	NEG|V|kAAn|DV-TTA|COND|ACT
V	V	NEG|V|kAAn|PAST|ACT|SG
V	V	PAST|3|ACT|TEMP|V
V	V	PAST|ACT|PL1|V
V	V	PAST|ACT|PL3|DV-TTA|V
V	V	PAST|ACT|PL3|V
V	V	PAST|ACT|PL3|kin|V
V	V	PAST|ACT|SG2|V
V	V	PAST|ACT|TEMP|DV-TTA|V
V	V	PAST|ACT|TEMP|V
V	V	PAST|ACT|up|PL1|V
V	V	PAST|ACT|up|TEMP|V
V	V	PAST|COP|ACT|PL3|V
V	V	PAST|COP|ACT|SG1|V
V	V	PAST|COP|PSS|NEG|V
V	V	PAST|COP|SG3|ACT|V
V	V	PAST|DV-ELE|PL1|ACT|V
V	V	PAST|DV-ELE|PL3|ACT|V
V	V	PAST|DV-SKELE|PL3|ACT|V
V	V	PAST|DV-UTU|PL3|ACT|V
V	V	PAST|NEG|ACT|PL|V
V	V	PAST|NEG|ACT|SG|V
V	V	PAST|PSS|DV-ELE|PE4|V
V	V	PAST|PSS|NEG|V
V	V	PAST|PSS|PE4|DV-TTA|V
V	V	PAST|PSS|PE4|V
V	V	PAST|PSS|PE4|kO|V
V	V	PAST|PSS|PE4|kin|V
V	V	PAST|PSS|REF|V
V	V	PAST|PSS|V|PE4|DV-ILE
V	V	PAST|PSS|up|REF|V
V	V	PAST|SG1|ACT|DV-TTA|V
V	V	PAST|SG1|ACT|V
V	V	PAST|SG1|ACT|kin|V
V	V	PAST|SG1|ACT|up|V
V	V	PAST|SG1|DV-ELE|ACT|V
V	V	PAST|SG1|V|ACT|DV-ILE
V	V	PAST|SG3|ACT|DV-TTA|V
V	V	PAST|SG3|ACT|V
V	V	PAST|SG3|ACT|hAn|V
V	V	PAST|SG3|ACT|kin|V
V	V	PAST|SG3|ACT|up|V
V	V	PAST|SG3|DV-ELE|ACT|V
V	V	PAST|SG3|DV-UTU|ACT|V
V	V	PAST|SG3|V|ACT|DV-ILE
V	V	PAST|V|PL3|ACT|DV-ILE
V	V	PAST|kAAn|SG3|ACT|V
V	V	PAST|st-cllq|ACT|PL1|V
V	V	PAST|st-cllq|ACT|PL2|V
V	V	PAST|st-cllq|SG3|ACT|V
V	V	PE4|COP|PSS|PRES|V
V	V	PE4|DV-TTA|PAST|V|PSS|DV-ELE
V	V	PE4|POTN|PSS|V
V	V	PE4|PSS|COND|V
V	V	PE4|PSS|COND|kin|V
V	V	PE4|PSS|DV-ELE|PRES|V
V	V	PE4|PSS|PRES|DV-TTA|V
V	V	PE4|PSS|PRES|V
V	V	PE4|PSS|V|PRES|DV-ILE
V	V	PE4|PSS|kin|PRES|V
V	V	PE4|PSS|up|PRES|V
V	V	PE4|st-cllq|PSS|PRES|V
V	V	PL3|ACT|COND|V
V	V	PL3|ACT|COND|kin|V
V	V	PL3|NEGV|V
V	V	PL3|V|kO|ACT|DV-U|PRES
V	V	POTN|ACT|PL3|V
V	V	PSS|DV-ELE|NEG|PRES|V
V	V	PSS|INE|INF2|V
V	V	PSS|NEG|COND|V
V	V	PSS|NEG|PRES|V
V	V	PSS|REF|PRES|V
V	V	PSS|V|NEG|PRES|DV-ILE
V	V	SG1|ACT|COND|V
V	V	SG1|ACT|COND|kin|V
V	V	SG1|ACT|COND|up|V
V	V	SG1|ACT|PRES|V
V	V	SG1|ACT|up|PRES|V
V	V	SG1|COP|ACT|COND|V
V	V	SG1|COP|ACT|PRES|V
V	V	SG1|NEGV|V
V	V	SG1|POTN|ACT|up|V
V	V	SG1|V|PAST|kin|ACT|DV-ELE
V	V	SG1|st-cllq|ACT|PRES|V
V	V	SG1|up|NEGV|V
V	V	SG2|ACT|PRES|V
V	V	SG2|ACT|up|PRES|V
V	V	SG2|NEGV|V
V	V	SG2|NEGV|up|V
V	V	SG3|ACT|COND|V
V	V	SG3|ACT|COND|up|V
V	V	SG3|ACT|PRES|DV-TTA|V
V	V	SG3|ACT|PRES|V
V	V	SG3|ACT|hAn|PRES|V
V	V	SG3|ACT|kO|PRES|V
V	V	SG3|ACT|kin|PRES|V
V	V	SG3|ACT|up|PRES|V
V	V	SG3|NEGV|V
V	V	SG3|V|DV-TTA|PAST|ACT|DV-ELE
V	V	SG3|up|NEGV|V
V	V	TEMP|V|PAST|3|ACT|DV-U
V	V	TRA|3|INF1|DV-TTA|V
V	V	TRA|3|INF1|V
V	V	TRA|COP|3|INF1|V
V	V	V|3|ACT|INE|DV-ELE|INF2
V	V	V|INF3|ABE|DV-ILE
V	V	V|NULL
V	V	V|up|IMPV|SG2|DV-TTA|ACT
V	V	V|up|IMPV|SG2|kin|ACT
V	V	kAAn|INF3|ABE|V
V	V	kAAn|SG3|ACT|COND|V
V	V	kAAn|SG3|ACT|PRES|V
V	V	kO|ACT|COND|PL1|V
V	V	kO|ACT|PL3|PRES|V
V	V	kO|PL3|up|NEGV|V
V	V	kO|SG3|ACT|COND|V
V	V	kO|SG3|NEGV|V
V	V	kO|SG3|up|NEGV|V
V	V	kin|ACT|PL1|PRES|V
V	V	st-cllq|ACT|PL3|PRES|V
V	V	st-cllq|SG3|ACT|PRES|V
V	V	st-vrnc|INF3|ILL|V
V	V	up|1SG|V|ACT|INE|INF2
V	V	up|ACT|IMPV|PL2|V
V	V	up|ACT|PL1|PRES|V
V	V	up|ACT|PL2|PRES|V
V	V	up|DV-ILE|SG1|ACT|PAST|kin|V
V	V	up|IMPV|SG3|V|DV-TTA|ACT
V	V	up|INE|ACT|INF2|V
V	V	up|NEGV|PL1|V
V	V	up|NEG|DV-TTA|PAST|V|PSS
V	V	up|PL1|V|ACT|DV-U|PRES
V	V	up|PL1|V|kO|ACT|PRES
V	V	up|PL2|V|kO|ACT|PRES
V	V	up|PL2|hAn|V|ACT|PRES
V	V	up|PL3|V|kO|ACT|PRES
V	V	up|PL3|V|kO|PAST|ACT
V	V	up|SG1|V|ACT|DV-ELE|PRES
V	V	up|SG1|V|DV-TTA|ACT|PRES
V	V	up|SG1|V|PAST|ACT|DV-ELE
V	V	up|SG1|V|PAST|ACT|DV-U
V	V	up|SG1|V|kO|ACT|PRES
V	V	up|SG1|V|pA|ACT|PRES
V	V	up|SG1|st-cllq|V|ACT|PRES
V	V	up|SG3|V|ACT|DV-U|PRES
V	V	up|SG3|V|kO|ACT|PRES
V	V	up|SG3|V|kO|COND|ACT
V	V	up|TEMP|V|PAST|3|ACT
V	V	up|TEMP|V|PAST|3|ACT|DV-U
V	V	up|V|3|ACT|INE|INF2
V	V	up|hAn|SG3|V|ACT|PRES
X	ABBR	ABBR
X	ABBR	ADE|SG|ABBR
X	ABBR	ALL|up|SG|ABBR
X	ABBR	INE|up|SG|ABBR
X	ABBR	NOM|3|up|SG|ABBR
X	ABBR	NOM|SG|ABBR
X	ABBR	NOM|SG|ABBR|TrunCo
X	ABBR	NOM|up|SG|ABBR
X	ABBR	PTV|up|SG|ABBR
X	ABBR	SG|ABBR|GEN
X	ABBR	SG|up|ABL|ABBR
X	ABBR	SG|up|ESS|ABBR
X	ABBR	up|ABBR
X	ABBR	up|ADE|SG|ABBR
X	ABBR	up|ELA|SG|ABBR
X	ABBR	up|SG|ABBR|GEN
X	DV-MA	DV-MA|1SG|ALL|SG
X	DV-MA	DV-MA|3|ELA|PL
X	DV-MA	DV-MA|3|SG|GEN
X	DV-MA	DV-MA|ADE|SG
X	DV-MA	DV-MA|ALL|PL
X	DV-MA	DV-MA|ALL|SG
X	DV-MA	DV-MA|ELA|PL
X	DV-MA	DV-MA|ELA|SG
X	DV-MA	DV-MA|GEN|PL
X	DV-MA	DV-MA|ILL|1SG|PL
X	DV-MA	DV-MA|ILL|PL
X	DV-MA	DV-MA|ILL|SG
X	DV-MA	DV-MA|ILL|SG|3
X	DV-MA	DV-MA|INE|3|SG
X	DV-MA	DV-MA|INE|PL
X	DV-MA	DV-MA|INE|SG
X	DV-MA	DV-MA|NOM|1SG|SG
X	DV-MA	DV-MA|NOM|3|SG
X	DV-MA	DV-MA|NOM|PL
X	DV-MA	DV-MA|NOM|SG
X	DV-MA	DV-MA|PL|INS
X	DV-MA	DV-MA|PTV|1SG|SG
X	DV-MA	DV-MA|PTV|3|PL
X	DV-MA	DV-MA|PTV|3|PL|DV-TTA
X	DV-MA	DV-MA|PTV|3|SG
X	DV-MA	DV-MA|PTV|PL
X	DV-MA	DV-MA|PTV|SG
X	DV-MA	DV-MA|SG|ESS
X	DV-MA	DV-MA|SG|GEN
X	DV-MA	DV-MA|TRA|SG
X	DV-MA	DV-MA|up|PL|INS
X	DV-MA	DV-U|DV-MA|ALL|SG
X	DV-MA	DV-U|DV-MA|PL|INE
X	FORGN	FORGN
X	FORGN	FORGN|up
X	FORGN	S|FORGN
X	FORGN	S|FORGN|up
X	INTJ	INTJ
X	INTJ	st-cllq|up|INTJ
X	INTJ	up|INTJ
X	NON-TWOL	NON-TWOL
X	NON-TWOL	TrunCo|NON-TWOL
X	NON-TWOL	TrunCo|up|NON-TWOL
X	NON-TWOL	up|NON-TWOL
X	X	GEN|PL
X	X	PTV|PL
Z	PUNCT	DASH|PUNCT
Z	PUNCT	PUNCT
Z	PUNCT	PUNCT|EMDASH
Z	PUNCT	PUNCT|ENDASH
Z	PUNCT	PUNCT|QUOTE
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
