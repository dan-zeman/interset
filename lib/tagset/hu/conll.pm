#!/usr/bin/perl
# Driver for the CoNLL 2007 Hungarian tagset.
# Copyright © 2011 Dan Zeman
# License: GNU GPL

package tagset::hu::conll;
use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");



# /net/data/conll/2007/hu/doc/README
my %postable =
(
    'Af' => ['pos' => 'adj'],
    'Cc' => ['pos' => 'conj', 'subpos' => 'coor'], # és, is, s, de, vagy
    'Cs' => ['pos' => 'conj', 'subpos' => 'sub'], # hogy, mint, ha, mert
    'I'  => ['pos' => 'int'],
    'Io' => ['pos' => 'int'], # single word sentence
    'Mc' => ['pos' => 'num', 'numtype' => 'card'], # cardinal numeral
    'Md' => ['pos' => 'num', 'numtype' => 'dist'], # distributive numeral
    'Mf' => ['pos' => 'num', 'numtype' => 'frac'], # fractal numeral
    'Mo' => ['pos' => 'num', 'numtype' => 'ord'], # ordinal numeral
    'Nc' => ['pos' => 'noun'], # common noun
    'Np' => ['pos' => 'noun', 'subpos' => 'prop'], # proper noun
    'O'  => [], # other tokens (e-mail or web address)
    'Oh' => ['hyph' => 'hyph'], # words ending in hyphens
    'Oi' => ['pos' => 'noun'], # identifier: R99, V-3
    'On' => ['pos' => 'num', 'numform' => 'digit'], # numbers written in digits: 6:2, 4:2-re
    'Pd' => ['pos' => 'adj',  'prontype' => 'dem'], # az = the, ez = this, olyan = such
    'Pg' => ['pos' => 'noun', 'prontype' => ['tot', 'neg']], # general pronoun: minden = all, mindenki = everyone, semmi = nothing, senki = no one
    'Pi' => ['pos' => 'adj',  'prontype' => 'ind'], # egyik = one, más = other, néhány = some, másik = other, valaki = one
    'Pp' => ['pos' => 'noun', 'prontype' => 'prs'], # én = I, mi = we, te = thou, ti = you, ő = he/she/it, ők = they
    'Pq' => ['pos' => 'noun', 'prontype' => 'int'], # mi, milyen = what, ki = who
    'Pr' => ['pos' => 'noun', 'prontype' => 'rel'], # amely, aki, ami, amelyik = which
    'Ps' => ['pos' => 'adj',  'prontype' => 'prs', 'poss' => 'poss'], # enyém = mine, miénk = ours, övék = theirs, saját, sajátja, önnön = own
    'Px' => ['pos' => 'noun', 'prontype' => 'prs', 'reflex' => 'reflex'], # magam = myself, magunk = ourselves, magad = yourself, önmaga = himself/herself, maga = itself, maguk = themselves
    'Py' => ['pos' => 'noun', 'prontype' => 'rcp'], # egymás = each other
    'Rd' => ['pos' => 'adv', 'prontype' => 'dem'], # akkor = then, úgy = so, így = so, itt = here, ott = there
    'Rg' => ['pos' => 'adv', 'prontype' => ['tot', 'neg']], # general adverbs: mindig = always, soha = never, mindenképpen = in any case, mind = every, bármikor = whenever
    'Ri' => ['pos' => 'adv', 'prontype' => 'ind'], # sokáig = long, olykor = sometimes, valahol = somewhere, egyrészt = on the one hand, másrészt = on the other hand
    'Rl' => ['pos' => 'adv', 'prontype' => 'prs'], # personal adverb: rá = it, neki = him/her, vele = with him, benne = in him/it, inside, róla = it
    'Rm' => ['pos' => 'adv', 'negativeness' => 'neg'], # modifier: nem, ne = not, sem = neither, se = nor
    'Rp' => ['pos' => 'part'], # particle, preverb: meg = and, el = away/off, ki = out, be = in, fel = up
    'Rq' => ['pos' => 'adv', 'prontype' => 'int'], # -e [interrogative suffix, tokenized separately], miért = why, hogyan = how, hol = where, vajon = whether, mikor = when
    'Rr' => ['pos' => 'adv', 'prontype' => 'rel'], # amikor = when, ahol = where, míg = while, miközben = while, mint = as
    'Rv' => ['pos' => 'verb', 'verbform' => 'trans'], # verbal adverb: hivatkozva = referring to, kezdve = from, hozzátéve = adding, mondván = saying
    'Rx' => ['pos' => 'adv'], # other adverb: már = already, még = even, csak = only, is = also, például = for example
    'St' => ['pos' => 'prep', 'subpos' => 'post'], # adposition/postposition: szerint = according to, után = after, között = between, által = by, alatt = under
    'Tf' => ['pos' => 'adj', 'subpos' => 'art', 'definiteness' => 'def'], # definite article: a, az
    'Ti' => ['pos' => 'adj', 'subpos' => 'art', 'definiteness' => 'ind'], # indefinite article: egy
    'Va' => ['pos' => 'verb', 'subpos' => 'aux'], # fogok, fog, fogja, fogunk, fognak, fogják, volna
    'Vm' => ['pos' => 'verb'], # main verb: van = there is, kell = must, lehet = may, lesz = become, nincs = is not, áll = stop, kerül = get to, tud = know
    'X'  => ['foreign' => 'foreign'], # foreign or unknown: homo, ecce, public_relations, szlovák)-Coetzer
    'Y'  => ['abbr' => 'abbr'], # abbreviation: stb., dr., Mr., T., Dr.
    'Z'  => ['typo' => 'typo'], # mistyped word
    'WPUNCT' => ['pos' => 'punc'], # word punctuation
    'SPUNCT' => ['pos' => 'punc', 'punctype' => ['peri', 'excl', 'qest']], # sentence delimiting punctuation (., !, ?)
);



# /net/data/conll/2007/hu/doc/dep_szegedtreebank_en.pdf
my %featable =
(
    'deg=positive'     => ['degree' => 'pos'], # új, magyar, nagy, amerikai, német
    'deg=comparative'  => ['degree' => 'comp'], # nagyobb, újabb, korábbi, kisebb, utóbbi
    'deg=superlative'  => ['degree' => 'sup'], # legnagyobb, legfontosabb, legfőbb, legjobb, legkisebb
    'deg=exaggeration' => ['degree' => 'abs'], # does not occur in the treebank
    'ctype=coordinating'  => ['subpos' => 'coor'], # és, is, s, de, vagy
    'ctype=subordinating' => ['subpos' => 'sub'], # hogy, mint, ha, mert, mivel
    'mood=indicative'  => ['verbform' => 'fin', 'mood' => 'ind'], # van, kell, lehet, lesz, nincs
    'mood=imperative'  => ['verbform' => 'fin', 'mood' => 'imp'], # háborúzz, szeretkezz, figyelj, legyél, szedj
    'mood=conditional' => ['verbform' => 'fin', 'mood' => 'cnd'], # lenne, kellene, lehetne, szeretne, volna
    'mood=infinitive'  => ['verbform' => 'inf'], # tenni, tudni, tartani, venni, elérni
    't=present' => ['tense' => 'pres'], # van, kell, lehet, lesz, nincs
    't=past'    => ['tense' => 'past'], # volt, lett, kellett, került, lehetett
    'p=1st' => ['person' => 1], # vagyok, akarok, gondolok, beszélek, írok
    'p=2nd' => ['person' => 2], # vagy, szerezhetsz, akarsz, bedughatsz, lemész
    'p=3rd' => ['person' => 3], # van, kell, lehet, lesz, nincs
    'n=singular' => ['number' => 'sing'], # kormány, év, század, forint, cég
    'n=plural'   => ['number' => 'plu'], # évek, szerbek, emberek, albánok, nők
    'def=yes' => ['definiteness' => 'def'], # mondja, tudja, teszi, állítja, jelenti
    'def=no'  => ['definiteness' => 'ind'], # van, kell, lehet, lesz, nincs
    # Multext: Genitive is rarely marked in Hungarian. If marked then with the same suffix as that of dative case.
    # Nouns with zero suffix can be nominative or genitive, so they are ambigious.
    'case=nominative'   => ['case' => 'nom'], # kormány, év, század, forint, cég
    'case=accusative'   => ['case' => 'acc'], # forintot, részt, pénzt, dollárt, szerepet
    'case=genitive'     => ['case' => 'gen'], # rendőrségnek, kormánynak, embernek, államnak, tárcának
    'case=dative'       => ['case' => 'dat'], # kormánynak, embernek, parlamentnek, fegyvernek, sikernek
    'case=instrumental' => ['case' => 'ins'], # évvel, százalékkal, nappal, sikerrel, alkalommal
    'case=illative'     => ['case' => 'ill'], # figyelembe, forgalomba, helyzetbe, igénybe, őrizetbe
    'case=inessive'     => ['case' => 'ine'], # évben, kapcsolatban, esetben, mértékben, időben
    'case=elative'      => ['case' => 'ela'], # százalékról, háborúról, dollárról, ügyről, dologról
    'case=allative'     => ['case' => 'all'], # tárgyalóasztalhoz, földhöz, bravúrhoz, feltételhez, békéhez
    'case=adessive'     => ['case' => 'ade'], # évnél, korábbinál, százaléknál, vadásztársaságnál, óránál
    'case=ablative'     => ['case' => 'abl'], # évtől, kormánytól, tárcától, politikától, lőfegyvertől
    'case=sublative'    => ['case' => 'sub'], # évre, forintra, nyilvánosságra, kilométerre, kérdésre
    'case=superessive'  => ['case' => 'sup'], # héten, módon, helyen, területen, pénteken
    'case=delative'     => ['case' => 'del'], # százalékról, háborúról, dollárról, ügyről, dologról
    'case=terminative'  => ['case' => 'ter'], # ideig, évig, máig, napig, hónapig
    'case=essive'       => ['case' => 'ess'], # ráadásul, hírül, célul, segítségül, tudomásul
    'case=essiveformal' => ['case' => 'ess', 'style' => 'form'], # szükségképpen, miniszterként, tulajdonosként, személyként, példaként
    'case=temporalis'   => ['case' => 'tem'], # órakor, induláskor, perckor, átültetéskor, záráskor
    'case=causalis'     => ['case' => 'cau'], # forintért, dollárért, pénzért, euróért, májátültetésért
    'case=sociative'    => ['case' => 'com'], # kamatostul, családostul
    'case=factive'      => ['case' => 'tra'], # várossá, bérmunkássá, sztárrá, társasággá, panzióvá
    'case=distributive' => ['case' => 'dis'], # másodpercenként, négyzetméterenként, tonnánként, óránként, esténként
    'case=locative'     => ['case' => 'loc'], # helyütt
    'proper=no'  => [], # kormány, év, század, forint, cég
    'proper=yes' => ['subpos' => 'prop'], # HVG, Magyarország, NATO, Torgyán_József, Koszovó
    # owner's (possessor's) person of nouns, adjectives, numerals, pronouns
    'pperson=1st' => ['possperson' => 1], # meggyőződésem = my opinion, időm = my time, barátom = my friend, ismerősöm, édesanyám
    'pperson=2nd' => ['possperson' => 2], # ellenfeled = your opponent, kapcsolatod = your relationship, aranytartalékod
    'pperson=3rd' => ['possperson' => 3], # százaléka, éve, vezetője, száma, elnöke
    # owner's (possessor's) number of nouns, adjectives, numerals, pronouns
    'pnumber=singular' => ['possnumber' => 'sing'], # meggyőződésem = my opinion, időm = my time, barátom = my friend, ismerősöm, édesanyám
    'pnumber=plural'   => ['possnumber' => 'plu'], # kultúránk = our culture, tudósítónk = our correspondent, hazánk, lapunk, szükségünk
    # owned (possession's) number of nouns, adjectives, numerals, pronouns
    # Possession relation can be marked on the owner or on the owned, and one noun can be owner and owned at the same time.
    # Combination n=plural|.*|pednumber=singular means that a plural noun owns something singular.
    # szerbeké, mellsebészeké, ortodoxoké, festőké, albánoké
    # Multext: Hungarian has three types of number in the nominal inflection:
    # 1. The number of the noun.
    # 2. The number of owners that own the noun.
    # 3. The number of the context given referent, which is some possession of the noun, i.e. belongs to the noun (anaphoric possessive).
    'pednumber=singular' => ['possednumber' => 'sing'], # pártarányosításé, kerületé, szövetségé, férfié, cukoré
    'pednumber=plural'   => ['possednumber' => 'plu'], # in SzTB, applies only to the possessive pronoun mieinket = ours; and in general is very rare
);



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = 'hu::conll';
    # three components: coarse-grained pos, fine-grained pos, features
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    my @features = split(/\|/, $features);
    my @assignments = @{$postable{$subpos}};
    map {push(@assignments, @{$featable{$_}})} (@features);
    for(my $i = 0; $i<=$#assignments; $i += 2)
    {
        $f{$assignments[$i]} = $assignments[$i+1];
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
