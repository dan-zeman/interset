#!/usr/bin/perl
# Driver for the CoNLL 2006 Japanese tagset.
# Copyright © 2011-2012 Dan Zeman <zeman@ufal.mff.cuni.cz>, Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::ja::conll;
use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");



# /net/data/conll/2006/ja/doc/fine2coarse.table
my %postable =
(
    '--'         => [], # to, su, shi, o, i; e.g. "to" could be also ITJ, P, PQ, Pcnj, PSSa
    '.'          => ['pos' => 'punc', 'punctype' => 'peri'], # sentence-final punctuation (.)
    ','          => ['pos' => 'punc', 'punctype' => 'comm'], # comma (,)
    '?'          => ['pos' => 'punc', 'punctype' => 'qest'], # question mark (?)
    'ADJ'        => ['pos' => 'adj'], # adjective other (onaji, iroNna, taishita, iroirona, korekorekouiu)
    'ADJdem'     => ['pos' => 'adj', 'prontype' => 'dem'], # adjective demonstrative (sono, kono, koNna, soNna, ano)
    'ADJicnd'    => ['pos' => 'adj'], # adjective conditional (-reba, -tara) (yoroshikereba, nakereba, yokereba, chikakereba, takakunakereba) [yoroshikereba = if you please]
    'ADJifin'    => ['pos' => 'adj'], # i-adjective, -i ending (yoroshii, ii, nai, chikai, osoi) [yoroshii = good]
    # Finite adjective can also occur with the feature "ta" (yokatta, yoroshikatta, tookatta, nakatta) [yokatta = was good].
    'ADJiku'     => ['pos' => 'adv'], # i-adjective, -ku ending (yoroshiku, arigatou, ohayou, hayaku, yoku) [adverb; yoroshiku = well, properly; best regards ("please treat me favourably")]
    'ADJite'     => ['pos' => 'adj'], # i-adjective, -kute ending (nakute, chikakute, yasukute, takakute, yokute) [transgressive form of adjective; str. 74]
    'ADJ_n'      => ['pos' => 'adj'], # n-adjective, concatenating "-na; PV" (daijoubu, kekkou, beNri, hajimete, muri) [daijoubu = safe; all right; kekkou = nice, fine]
    'ADJsf'      => ['pos' => 'adj'], # adjectival suffix "na" (na) [dame na = bad]
    'ADJteki'    => ['pos' => 'adj'], # adjective, -teki ending (jikaNteki, gutaiteki, kojiNteki, nedaNteki, nitteiteki) [-teki = -like; jikaNteki = time-like, temporal]
    'ADJwh'      => ['pos' => 'adj', 'prontype' => 'int'], # adjective interrogative (dono, doNna, douitta, douiu) [dono = which, what, how]
    'ADV'        => ['pos' => 'adv'], # adverb (chotto, mou, mata, dekireba, daitai) [chotto = just a minute; mou = more, already; mata = moreover]
    'ADVdem'     => ['pos' => 'adv', 'prontype' => 'dem'], # adverb demonstrative (sou, kou, so) [sou = so]
    'ADVdgr'     => ['pos' => 'adv', 'advtype' => 'deg'], # adverb of degree (ichibaN, sukoshi, chotto, amari, soNnani) [ichibaN = best, first]
    'ADVtmp'     => ['pos' => 'adv', 'advtype' => 'tim'], # adverb of time, not numeric (mazu, sassoku, sakihodo, sakki, toriaezu) [mazu = first; sassoku = immediately; sakihodo = not long ago, just now]
    'ADVwh'      => ['pos' => 'adv', 'prontype' => 'int'], # adverb interrogative (dou, ikaga, doushite) [dou, ikaga = how, in what way]
    'CD'         => ['pos' => 'num', 'numtype' => 'card'], # cardinal numeral (ichi, ni, saN, hyaku) [ichi = one, ni = two, saN = three]
    'CDU'        => ['pos' => 'num', 'numtype' => 'card'], # cardinal numeral with unit [CD-shitsu, biN, kiro] (mitsu, hitotsu, ichinichi, futatsu, ichido)
    'CDdate'     => ['pos' => 'adv', 'advtype' => 'tim'], # cardinal numeral with date unit (juugatsu, juuninichi, nigatsu, tooka, mikka) [juugatsu = ten-month, October; juuninichi = twelve-day, twelfth day of the month]
    'CDtime'     => ['pos' => 'adv', 'advtype' => 'tim'], # cardinal numeral with time unit (gojuppuN, juuichiji, juuji, saNjuugofuN, juugofuN) [gojuppuN = fifty minutes; juuichiji = eleven o'clock]
    'CNJ'        => ['pos' => 'conj'], # conjunction, sentence-initial or between nominals (dewa, de, soredewa, ato, soshitara) [soredewa = now, so; ato = after]
    'GR'         => ['pos' => 'int'], # greeting [koNnichiwa = hello; otsukaresama = thank you very much; sayounara = good bye]
    'ITJ'        => ['pos' => 'int'], # interjection (hai, ee, to, e, a) [hai = yes]
    'NF'         => ['pos' => 'noun'], # formal noun (hou, no, koto, nano, naN) [watakushi no hou = on my part, my way (watakushi = I)]
    'NN'         => ['pos' => 'noun'], # common noun (hoteru = hotel, biN = jar, hikouki = airplane, shiNguru = single, kaeri = return)
    'Ndem'       => ['pos' => 'noun', 'prontype' => 'dem'], # demonstrative pronoun (sore = that, kochira = here, sochira = there, kore = this, soko = there)
    'Nsf'        => ['pos' => 'prep', 'subpos' => 'post'], # suffix to nominal phrase (hatsu, chaku, gurai, keiyu, hodo) [hatsu = departure, chaku = arrival, keiyu = via] [NP(furaNkufuruto/NAMEloc/COMP keiyu/Nsf/HD) = via Frankfurt]
    'Ntmp'       => ['pos' => 'noun', 'advtype' => 'tim'], # temporal noun (ima = now, hi = day, asa = morning, yuugata = evening, koNdo = this time)
    'Nwh'        => ['pos' => 'noun', 'prontype' => 'int'], # interrogative pronoun (dochira = where, itsu = when, naNji = what time, dore = which, docchi = which way, which one)
    'PRON'       => ['pos' => 'noun', 'prontype' => 'prs'], # personal pronoun (watashi = I, watakushi = I, boku = I, atashi = I, atakushi = I)
    'VN'         => ['pos' => 'noun'], # verbal (predicative) noun, VN-suru = make-VN (onegai, shuppatsu, yoyaku, kaNkou, shuchhou) [onegai = please; shuppatsu = departure; yoyaku = reservation]
    'NAME'       => ['pos' => 'noun', 'subpos' => 'prop'], # proper noun (doNjobaNni = Don Giovanni, kurisumasu, zeNnikkuubiN, omamori, nihoNkoukuubiN)
    'NAMEloc'    => ['pos' => 'noun', 'subpos' => 'prop'], # name of location (hanoofaa = Hannover, doitsu = Germany, kaNkuu = Kansai International Airport, furaNkufuruto = Frankfurt, roNdoN = London)
    'NAMEorg'    => ['pos' => 'noun', 'subpos' => 'prop'], # name of organization (rufutohaNza = Lufthansa; jaru = JAL, Japan Airlines; rufutohaNzakoukuu, nihoNkoukuu, zeNnikkuu)
    'NAMEper'    => ['pos' => 'noun', 'subpos' => 'prop'], # name of person (matsumoto, miyake, kitahara, yoshikawa, tsutsui)
    'NT'         => ['pos' => 'noun', 'advtype' => 'tim'], # another tag for temporal noun? (kayoubi = Tuesday, getsuyoubi = Monday, suiyoubi = Wednesday, gogo = afternoon, kiNyoubi = Friday)
    'P'          => ['pos' => 'prep', 'subpos' => 'post'], # postposition / particle [np];[pp] (ni, de, kara, made, to)
    'PADJ'       => ['pos' => 'prep', 'subpos' => 'post'], # adjectival particle [vp];[ap] (youna, you, mitai, rashii, sou)
    # PADJ also occurs with the feature 'kute' (the only form is rashikute)
    'PADV'       => ['pos' => 'prep', 'subpos' => 'post'], # adverbial particle [vp];[ap] (youni, fuuni, shidai, nagara, hodo)
    'PNsf'       => ['pos' => 'noun'], # (saN = Mr./Ms., sama)
    'PQ'         => ['pos' => 'prep', 'subpos' => 'post'], # particle of quotation (to, te, naNte, toka, ka, tte)
    'Pacc'       => ['pos' => 'prep', 'subpos' => 'post', 'case' => 'acc'], # accusative particle [np] (o)
    'Pcnj'       => ['pos' => 'conj', 'subpos' => 'coor'], # coordinating conjunction / particle (to = and; ka, ya = or; toka, nari)
    'Pfoc'       => ['pos' => 'prep', 'subpos' => 'post'], # focus particle (wa, mo, demo, koso, nara, sae)
    'Pgen'       => ['pos' => 'prep', 'subpos' => 'post', 'case' => 'gen'], # genitive particle [np] (no)
    'Pnom'       => ['pos' => 'prep', 'subpos' => 'post', 'case' => 'nom'], # nominative particle [np] (ga)
    'PSE'        => ['pos' => 'part'], # S-end (clause-final) particle (ka, ne, yo, na, kana)
    'PSSa'       => ['pos' => 'part'], # S-conjunctive particle "and" (node, to, shi, kara, nanode)
    'PSSb'       => ['pos' => 'part'], # S-conjunctive particle "but" (ga, keredomo, kedo, kedomo, keredo)
    'PSSq'       => ['pos' => 'part'], # S-conjunctive particle question (ka)
    # What they call "particle verb" is regarded by other authors a copula ("to be").
    'PVcnd'      => ['pos' => 'verb', 'subpos' => 'cop', 'verbform' => 'fin', 'mood' => 'cnd'], # particle verb+cond (deshitara, dattara, deshitaraba)
    'PVfin'      => ['pos' => 'verb', 'subpos' => 'cop', 'verbform' => 'fin', 'mood' => 'ind'], # particle verb+tens (feature ta: da, deshita, datta; feature u: desu, deshou, darou)
    'PVte'       => ['pos' => 'verb', 'subpos' => 'cop', 'verbform' => 'trans'], # particle verb-tens (de, deshite)
    'PreN'       => ['pos' => 'noun'], # noun prefix (yaku, dai, yoku, maru, Frau)
    'UNIT'       => ['pos' => 'noun'], # unit (maruku, biN, meetoru, kiro, shitsu) [maruku = mark, meetoru = meter, kiro = kilo]
    'V'          => ['pos' => 'verb'], # verb-tense (ittari, nitari, tomarezu, shirabetari, tanoshimetari) [ittari = and go; nitari = barge]
    'Vbas'       => ['pos' => 'verb'], # verb-tense, stem and 1st/2nd/5th base (mi, tore, nomi, kimari, kiki, tabe) [mi = look at, tabe = eat]
    'Vcnd'       => ['pos' => 'verb', 'mood' => 'cnd'], # verb conditional (shimashitara, shitara, areba, arimashitara, dekimashitara) [str. 160]
    # Finite verbs occur with three different features:
    # eN (sumimaseN, arimaseN, kamaimaseN, suimaseN, shiremaseN) [honorific negative future] [str. 61]
    # ta (wakarimashita, gozaimashita, itta, kashikomarimashita, hanareta) [past] [str. 61]
    # u (iu, aru, arimasu, narimasu, omoimasu) [present or afirmative future?] [str. 61]
    'Vfin'       => ['pos' => 'verb', 'verbform' => 'fin', 'mood' => 'ind'], # finite verb + tense (-ru, -ta, -masu, -maseN)
    'Vimp'       => ['pos' => 'verb', 'verbform' => 'fin', 'mood' => 'imp'], # verb imperative (gomeNnasai, kudasai, ie, nome, shiro, kimero) [gomeNnasai = pardon me; kudasai = please do]
    'Vte'        => ['pos' => 'verb', 'verbform' => 'trans'], # verb tense, -te/-de ending [transgressive?] (aite, shite, tsuite, natte, arimashite) [str. 73]
    'VADJ_n'     => ['pos' => 'adj'], # verbal adjective -sou (ikesou, arisou, toresou, owarisou, awanasasou) [str. 153] [dono atari ikesou desu ka = how do I go around]
    'VADJi'      => ['pos' => 'adj'], # verbal adjective -nai/-tai (shitai, mitai, ikitai, kimetai, itadakitai) [str. 67]
    # VADJi can also occur with the feature 'kute' (kimenakute, ikanakute, noranakute, wakaranakute, okanakute)
    # VADJi can also occur with the feature 'ta' (inakatta, ikitakatta, kiitenakatta, dekinakatta)
    'VADJicnd'   => ['pos' => 'adj', 'mood' => 'cnd'], # verbal adjective conditional -nakereba (shinakereba, konakereba, ikanakereba, sashitsukaenakereba, iwanakereba) [shinakereba = unless one does something]
    'VAUX'       => ['pos' => 'verb', 'subpos' => 'aux'], # auxiliary verb - tense (mitari, shimattari) [str. 181]
    'VAUXbas'    => ['pos' => 'verb', 'subpos' => 'aux'], # auxiliary verb - tense (itadaki) [itadaku = to take]
    'VAUXcnd'    => ['pos' => 'verb', 'subpos' => 'aux', 'mood' => 'cnd'], # auxiliary verb conditional (itadakereba, okanakereba, itadaitara, itadakimashitara, mitara)
    # Finite auxiliary verbs occur with three different features:
    # eN (imaseN, orimaseN, mimaseN, itadakemaseN, shimaimaseN)
    # ta (ita, mita, imashita, kita, oita, itadaita)
    # u (iru, okimasu, imasu, orimasu, itadakimasu)
    'VAUXfin'    => ['pos' => 'verb', 'subpos' => 'aux', 'verbform' => 'fin', 'mood' => 'ind'], # finite auxiliary verb +tense following V (iru, ita, kuru, shimau)
    'VAUXimp'    => ['pos' => 'verb', 'subpos' => 'aux', 'verbform' => 'fin', 'mood' => 'imp'], # finite auxiliary verb imperative (kudasai, kure)
    'VAUXte'     => ['pos' => 'verb', 'subpos' => 'aux', 'verbform' => 'trans'], # auxiliary verb -tense -te/-de ending transgressive (imashite, orimashite, itadaite, oite, shimatte)
    'VS'         => ['pos' => 'verb'], # support (light) verb -tense VN (shitari, shinagara)
    'VSbas'      => ['pos' => 'verb'], # support verb -tense VN (shi)
    'VScnd'      => ['pos' => 'verb', 'mood' => 'cnd'], # support verb conditional (dekireba, sureba, dekitara, dekimashitara, shitara)
    # Finite support verbs occur with three different features:
    # eN (shimaseN)
    # ta (shita, shimashita, itashimashita, sareta, dekita)
    # u (shimasu, itashimasu, suru, dekimasu, shimashou, dekiru)
    'VSfin'      => ['pos' => 'verb', 'verbform' => 'fin', 'mood' => 'ind'], # finite support verb +tense VN (suru, shita)
    'VSimp'      => ['pos' => 'verb', 'verbform' => 'fin', 'mood' => 'imp'], # finite support verb imperative (shiro)
    'VSte'       => ['pos' => 'verb', 'verbform' => 'trans'], # support verb -tense, -te ending transgressive (shite, sasete, shimashite, sashite, sarete, itashimashite)
    'xxx'        => [], # segmentation problem
);



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = 'ja::conll';
    # three components: coarse-grained pos, fine-grained pos, features
    my ($pos, $subpos, $feature) = split(/\s+/, $tag);
    my @assignments = @{$postable{$subpos}};
    for(my $i = 0; $i<=$#assignments; $i += 2)
    {
        $f{$assignments[$i]} = $assignments[$i+1];
    }
    # There are only four possible features, mutually exclusive:
    if($feature eq 'eN')
    {
        $f{tense} = ['pres', 'fut'];
        $f{negativeness} = 'neg';
    }
    elsif($feature eq 'ta')
    {
        $f{tense} = 'past';
    }
    elsif($feature eq 'u')
    {
        $f{tense} = ['pres', 'fut'];
    }
    elsif($feature eq 'kute')
    {
        ###!!! unknown meaning of the suffix -kute
        # maybe (from Google "Japanese suffix kute"):
        # tsuyokute yasashii hito = a strong and kind person
        #   tsuyokute = strong and
        #   yasashii = kind
        #   hito = a person
        $f{subpos} = 'coor'; ###???
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
