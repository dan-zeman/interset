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
A	Af	deg=comparative|n=plural|case=accusative
A	Af	deg=comparative|n=plural|case=adessive
A	Af	deg=comparative|n=plural|case=nominative
A	Af	deg=comparative|n=singular|case=accusative
A	Af	deg=comparative|n=singular|case=dative
A	Af	deg=comparative|n=singular|case=delative
A	Af	deg=comparative|n=singular|case=essive
A	Af	deg=comparative|n=singular|case=factive
A	Af	deg=comparative|n=singular|case=inessive
A	Af	deg=comparative|n=singular|case=nominative
A	Af	deg=comparative|n=singular|case=sublative
A	Af	deg=positive|n=plural|case=ablative
A	Af	deg=positive|n=plural|case=ablative|pednumber=singular
A	Af	deg=positive|n=plural|case=accusative
A	Af	deg=positive|n=plural|case=adessive
A	Af	deg=positive|n=plural|case=allative
A	Af	deg=positive|n=plural|case=dative
A	Af	deg=positive|n=plural|case=delative
A	Af	deg=positive|n=plural|case=factive
A	Af	deg=positive|n=plural|case=genitive
A	Af	deg=positive|n=plural|case=illative
A	Af	deg=positive|n=plural|case=inessive
A	Af	deg=positive|n=plural|case=instrumental
A	Af	deg=positive|n=plural|case=nominative
A	Af	deg=positive|n=plural|case=nominative|pednumber=singular
A	Af	deg=positive|n=plural|case=nominative|pperson=3rd|pnumber=singular
A	Af	deg=positive|n=plural|case=sublative
A	Af	deg=positive|n=singular|case=ablative
A	Af	deg=positive|n=singular|case=accusative
A	Af	deg=positive|n=singular|case=adessive
A	Af	deg=positive|n=singular|case=allative
A	Af	deg=positive|n=singular|case=causalis
A	Af	deg=positive|n=singular|case=dative
A	Af	deg=positive|n=singular|case=dative|pperson=3rd|pnumber=singular
A	Af	deg=positive|n=singular|case=elative
A	Af	deg=positive|n=singular|case=essive
A	Af	deg=positive|n=singular|case=essiveformal
A	Af	deg=positive|n=singular|case=factive
A	Af	deg=positive|n=singular|case=factive|pperson=3rd|pnumber=singular
A	Af	deg=positive|n=singular|case=genitive
A	Af	deg=positive|n=singular|case=illative
A	Af	deg=positive|n=singular|case=inessive
A	Af	deg=positive|n=singular|case=instrumental
A	Af	deg=positive|n=singular|case=nominative
A	Af	deg=positive|n=singular|case=nominative|pednumber=singular
A	Af	deg=positive|n=singular|case=nominative|pperson=3rd|pnumber=singular
A	Af	deg=positive|n=singular|case=sublative
A	Af	deg=positive|n=singular|case=sublative|pperson=3rd|pnumber=singular
A	Af	deg=superlative|n=plural|case=accusative
A	Af	deg=superlative|n=plural|case=accusative|pperson=3rd|pnumber=singular
A	Af	deg=superlative|n=plural|case=nominative
A	Af	deg=superlative|n=singular|case=dative
A	Af	deg=superlative|n=singular|case=essive
A	Af	deg=superlative|n=singular|case=nominative
A	Af	deg=superlative|n=singular|case=sublative
C	Cc	ctype=coordinating
C	Cs	ctype=subordinating
I	I	_
I	Io	_
M	Mc	n=plural|case=accusative
M	Mc	n=plural|case=dative
M	Mc	n=plural|case=genitive|pperson=3rd|pnumber=singular
M	Mc	n=plural|case=inessive
M	Mc	n=plural|case=instrumental
M	Mc	n=plural|case=nominative
M	Mc	n=plural|case=nominative|pperson=3rd|pnumber=singular
M	Mc	n=singular
M	Mc	n=singular|case=ablative
M	Mc	n=singular|case=accusative
M	Mc	n=singular|case=adessive
M	Mc	n=singular|case=causalis
M	Mc	n=singular|case=dative
M	Mc	n=singular|case=delative
M	Mc	n=singular|case=elative
M	Mc	n=singular|case=essive
M	Mc	n=singular|case=genitive
M	Mc	n=singular|case=illative
M	Mc	n=singular|case=inessive
M	Mc	n=singular|case=instrumental
M	Mc	n=singular|case=instrumental|pperson=3rd|pnumber=singular
M	Mc	n=singular|case=nominative
M	Mc	n=singular|case=nominative|pperson=3rd|pnumber=plural
M	Mc	n=singular|case=nominative|pperson=3rd|pnumber=singular
M	Mc	n=singular|case=sublative
M	Mc	n=singular|case=temporalis
M	Mc	n=singular|case=terminative
M	Md	n=singular|case=nominative
M	Mf	n=singular|case=accusative|pperson=3rd|pnumber=singular
M	Mf	n=singular|case=adessive|pperson=3rd|pnumber=singular
M	Mf	n=singular|case=causalis|pednumber=singular
M	Mf	n=singular|case=inessive|pperson=3rd|pnumber=singular
M	Mf	n=singular|case=instrumental
M	Mf	n=singular|case=instrumental|pperson=3rd|pnumber=singular
M	Mf	n=singular|case=nominative
M	Mf	n=singular|case=nominative|pperson=3rd|pnumber=singular
M	Mf	n=singular|case=sublative
M	Mf	n=singular|case=sublative|pperson=3rd|pnumber=singular
M	Mo	n=singular
M	Mo	n=singular|case=dative
M	Mo	n=singular|case=essiveformal
M	Mo	n=singular|case=inessive
M	Mo	n=singular|case=nominative
M	Mo	n=singular|case=sublative
N	Nc	n=plural|case=ablative|proper=no
N	Nc	n=plural|case=ablative|proper=no|pednumber=singular
N	Nc	n=plural|case=ablative|proper=no|pperson=1st|pnumber=plural
N	Nc	n=plural|case=ablative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=plural|case=accusative|proper=no
N	Nc	n=plural|case=accusative|proper=no|pednumber=singular
N	Nc	n=plural|case=accusative|proper=no|pperson=1st|pnumber=plural
N	Nc	n=plural|case=accusative|proper=no|pperson=1st|pnumber=singular
N	Nc	n=plural|case=accusative|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=plural|case=accusative|proper=no|pperson=3rd|pnumber=plural|pednumber=singular
N	Nc	n=plural|case=accusative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=plural|case=adessive|proper=no
N	Nc	n=plural|case=adessive|proper=no|pperson=1st|pnumber=singular
N	Nc	n=plural|case=adessive|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=plural|case=adessive|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=plural|case=adessive|proper=no|pperson=3rd|pnumber=singular|pednumber=singular
N	Nc	n=plural|case=allative|proper=no
N	Nc	n=plural|case=allative|proper=no|pednumber=singular
N	Nc	n=plural|case=allative|proper=no|pperson=1st|pnumber=plural
N	Nc	n=plural|case=allative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=plural|case=causalis|proper=no
N	Nc	n=plural|case=causalis|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=plural|case=dative|proper=no
N	Nc	n=plural|case=dative|proper=no|pperson=1st|pnumber=plural
N	Nc	n=plural|case=dative|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=plural|case=dative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=plural|case=delative|proper=no
N	Nc	n=plural|case=delative|proper=no|pednumber=singular
N	Nc	n=plural|case=delative|proper=no|pperson=1st|pnumber=plural
N	Nc	n=plural|case=delative|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=plural|case=delative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=plural|case=elative|proper=no
N	Nc	n=plural|case=elative|proper=no|pednumber=singular
N	Nc	n=plural|case=elative|proper=no|pperson=1st|pnumber=plural
N	Nc	n=plural|case=elative|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=plural|case=elative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=plural|case=essiveformal|proper=no
N	Nc	n=plural|case=essiveformal|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=plural|case=factive|proper=no
N	Nc	n=plural|case=factive|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=plural|case=genitive|proper=no
N	Nc	n=plural|case=genitive|proper=no|pperson=1st|pnumber=plural
N	Nc	n=plural|case=genitive|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=plural|case=genitive|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=plural|case=illative|proper=no
N	Nc	n=plural|case=illative|proper=no|pperson=1st|pnumber=plural
N	Nc	n=plural|case=illative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=plural|case=inessive|proper=no
N	Nc	n=plural|case=inessive|proper=no|pperson=1st|pnumber=plural
N	Nc	n=plural|case=inessive|proper=no|pperson=1st|pnumber=singular
N	Nc	n=plural|case=inessive|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=plural|case=inessive|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=plural|case=instrumental|proper=no
N	Nc	n=plural|case=instrumental|proper=no|pednumber=singular
N	Nc	n=plural|case=instrumental|proper=no|pperson=1st|pnumber=plural
N	Nc	n=plural|case=instrumental|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=plural|case=instrumental|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=plural|case=nominative|proper=no
N	Nc	n=plural|case=nominative|proper=no|pednumber=singular
N	Nc	n=plural|case=nominative|proper=no|pperson=1st|pnumber=plural
N	Nc	n=plural|case=nominative|proper=no|pperson=1st|pnumber=singular
N	Nc	n=plural|case=nominative|proper=no|pperson=2nd|pnumber=plural
N	Nc	n=plural|case=nominative|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=plural|case=nominative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=plural|case=sublative|proper=no
N	Nc	n=plural|case=sublative|proper=no|pperson=1st|pnumber=plural
N	Nc	n=plural|case=sublative|proper=no|pperson=1st|pnumber=singular
N	Nc	n=plural|case=sublative|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=plural|case=sublative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=plural|case=superessive|proper=no
N	Nc	n=plural|case=superessive|proper=no|pperson=1st|pnumber=plural
N	Nc	n=plural|case=superessive|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=plural|case=superessive|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=plural|case=temporalis|proper=no
N	Nc	n=plural|case=terminative|proper=no
N	Nc	n=plural|case=terminative|proper=no|pperson=1st|pnumber=plural
N	Nc	n=singular|case=ablative|proper=no
N	Nc	n=singular|case=ablative|proper=no|pperson=1st|pnumber=singular
N	Nc	n=singular|case=ablative|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=singular|case=ablative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=accusative|proper=no
N	Nc	n=singular|case=accusative|proper=no|pednumber=singular
N	Nc	n=singular|case=accusative|proper=no|pperson=1st|pnumber=plural
N	Nc	n=singular|case=accusative|proper=no|pperson=1st|pnumber=singular
N	Nc	n=singular|case=accusative|proper=no|pperson=2nd|pnumber=singular
N	Nc	n=singular|case=accusative|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=singular|case=accusative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=accusative|proper=no|pperson=3rd|pnumber=singular|pednumber=singular
N	Nc	n=singular|case=adessive|proper=no
N	Nc	n=singular|case=adessive|proper=no|pednumber=singular
N	Nc	n=singular|case=adessive|proper=no|pperson=1st|pnumber=singular
N	Nc	n=singular|case=adessive|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=singular|case=adessive|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=allative|proper=no
N	Nc	n=singular|case=allative|proper=no|pednumber=singular
N	Nc	n=singular|case=allative|proper=no|pperson=1st|pnumber=singular
N	Nc	n=singular|case=allative|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=singular|case=allative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=causalis|proper=no
N	Nc	n=singular|case=causalis|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=singular|case=causalis|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=dative|proper=no
N	Nc	n=singular|case=dative|proper=no|pperson=1st|pnumber=plural
N	Nc	n=singular|case=dative|proper=no|pperson=1st|pnumber=singular
N	Nc	n=singular|case=dative|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=singular|case=dative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=delative|proper=no
N	Nc	n=singular|case=delative|proper=no|pperson=1st|pnumber=plural
N	Nc	n=singular|case=delative|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=singular|case=delative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=distributive|proper=no
N	Nc	n=singular|case=elative|proper=no
N	Nc	n=singular|case=elative|proper=no|pperson=1st|pnumber=plural
N	Nc	n=singular|case=elative|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=singular|case=elative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=essiveformal|proper=no
N	Nc	n=singular|case=essiveformal|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=essive|proper=no
N	Nc	n=singular|case=essive|proper=no|pperson=1st|pnumber=plural
N	Nc	n=singular|case=essive|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=factive|proper=no
N	Nc	n=singular|case=factive|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=genitive|proper=no
N	Nc	n=singular|case=genitive|proper=no|pednumber=singular
N	Nc	n=singular|case=genitive|proper=no|pperson=2nd|pnumber=singular
N	Nc	n=singular|case=genitive|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=singular|case=genitive|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=illative|proper=no
N	Nc	n=singular|case=illative|proper=no|pperson=1st|pnumber=plural
N	Nc	n=singular|case=illative|proper=no|pperson=1st|pnumber=singular
N	Nc	n=singular|case=illative|proper=no|pperson=2nd|pnumber=singular
N	Nc	n=singular|case=illative|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=singular|case=illative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=inessive|proper=no
N	Nc	n=singular|case=inessive|proper=no|pednumber=singular
N	Nc	n=singular|case=inessive|proper=no|pperson=1st|pnumber=plural
N	Nc	n=singular|case=inessive|proper=no|pperson=1st|pnumber=singular
N	Nc	n=singular|case=inessive|proper=no|pperson=2nd|pnumber=singular
N	Nc	n=singular|case=inessive|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=singular|case=inessive|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=instrumental|proper=no
N	Nc	n=singular|case=instrumental|proper=no|pednumber=singular
N	Nc	n=singular|case=instrumental|proper=no|pperson=1st|pnumber=plural
N	Nc	n=singular|case=instrumental|proper=no|pperson=1st|pnumber=singular
N	Nc	n=singular|case=instrumental|proper=no|pperson=2nd|pnumber=singular
N	Nc	n=singular|case=instrumental|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=singular|case=instrumental|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=locative|proper=no
N	Nc	n=singular|case=nominative|proper=no
N	Nc	n=singular|case=nominative|proper=no|pednumber=singular
N	Nc	n=singular|case=nominative|proper=no|pperson=1st|pnumber=plural
N	Nc	n=singular|case=nominative|proper=no|pperson=1st|pnumber=singular
N	Nc	n=singular|case=nominative|proper=no|pperson=2nd|pnumber=plural
N	Nc	n=singular|case=nominative|proper=no|pperson=2nd|pnumber=singular
N	Nc	n=singular|case=nominative|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=singular|case=nominative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=nominative|proper=no|pperson=3rd|pnumber=singular|pednumber=singular
N	Nc	n=singular|case=sociative|proper=no
N	Nc	n=singular|case=sublative|proper=no
N	Nc	n=singular|case=sublative|proper=no|pednumber=singular
N	Nc	n=singular|case=sublative|proper=no|pperson=1st|pnumber=plural
N	Nc	n=singular|case=sublative|proper=no|pperson=1st|pnumber=singular
N	Nc	n=singular|case=sublative|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=singular|case=sublative|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=superessive|proper=no
N	Nc	n=singular|case=superessive|proper=no|pperson=1st|pnumber=plural
N	Nc	n=singular|case=superessive|proper=no|pperson=1st|pnumber=singular
N	Nc	n=singular|case=superessive|proper=no|pperson=2nd|pnumber=singular
N	Nc	n=singular|case=superessive|proper=no|pperson=3rd|pnumber=plural
N	Nc	n=singular|case=superessive|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=temporalis|proper=no
N	Nc	n=singular|case=temporalis|proper=no|pperson=1st|pnumber=plural
N	Nc	n=singular|case=temporalis|proper=no|pperson=3rd|pnumber=singular
N	Nc	n=singular|case=terminative|proper=no
N	Nc	n=singular|case=terminative|proper=no|pperson=3rd|pnumber=singular
N	Np	n=plural|case=accusative|proper=yes
N	Np	n=plural|case=allative|proper=yes
N	Np	n=plural|case=dative|proper=yes
N	Np	n=plural|case=instrumental|proper=yes
N	Np	n=plural|case=nominative|proper=yes
N	Np	n=plural|case=sublative|proper=yes
N	Np	n=singular|case=ablative|proper=yes
N	Np	n=singular|case=accusative|proper=yes
N	Np	n=singular|case=accusative|proper=yes|pednumber=singular
N	Np	n=singular|case=accusative|proper=yes|pperson=3rd|pnumber=singular
N	Np	n=singular|case=adessive|proper=yes
N	Np	n=singular|case=allative|proper=yes
N	Np	n=singular|case=allative|proper=yes|pednumber=singular
N	Np	n=singular|case=allative|proper=yes|pperson=3rd|pnumber=singular
N	Np	n=singular|case=causalis|proper=yes
N	Np	n=singular|case=dative|proper=yes
N	Np	n=singular|case=dative|proper=yes|pperson=2nd|pnumber=singular
N	Np	n=singular|case=dative|proper=yes|pperson=3rd|pnumber=singular
N	Np	n=singular|case=delative|proper=yes
N	Np	n=singular|case=delative|proper=yes|pperson=3rd|pnumber=singular
N	Np	n=singular|case=elative|proper=yes
N	Np	n=singular|case=elative|proper=yes|pperson=3rd|pnumber=singular
N	Np	n=singular|case=essiveformal|proper=yes
N	Np	n=singular|case=factive|proper=yes
N	Np	n=singular|case=genitive|proper=yes
N	Np	n=singular|case=genitive|proper=yes|pednumber=singular
N	Np	n=singular|case=genitive|proper=yes|pperson=3rd|pnumber=singular
N	Np	n=singular|case=illative|proper=yes
N	Np	n=singular|case=inessive|proper=yes
N	Np	n=singular|case=inessive|proper=yes|pperson=1st|pnumber=plural
N	Np	n=singular|case=inessive|proper=yes|pperson=3rd|pnumber=singular
N	Np	n=singular|case=instrumental|proper=yes
N	Np	n=singular|case=nominative|proper=yes
N	Np	n=singular|case=nominative|proper=yes|pednumber=singular
N	Np	n=singular|case=nominative|proper=yes|pperson=1st|pnumber=singular
N	Np	n=singular|case=nominative|proper=yes|pperson=3rd|pnumber=singular
N	Np	n=singular|case=sublative|proper=yes
N	Np	n=singular|case=superessive|proper=yes
N	Np	n=singular|case=terminative|proper=yes
O	Oh	_
O	Oi	n=singular|case=nominative
O	Oi	n=singular|case=sublative
O	On	n=singular|case=nominative
O	On	n=singular|case=sublative
P	Pd	p=3rd|n=plural|case=accusative
P	Pd	p=3rd|n=plural|case=adessive
P	Pd	p=3rd|n=plural|case=allative
P	Pd	p=3rd|n=plural|case=dative
P	Pd	p=3rd|n=plural|case=delative
P	Pd	p=3rd|n=plural|case=elative
P	Pd	p=3rd|n=plural|case=genitive
P	Pd	p=3rd|n=plural|case=inessive
P	Pd	p=3rd|n=plural|case=instrumental
P	Pd	p=3rd|n=plural|case=nominative
P	Pd	p=3rd|n=plural|case=sublative
P	Pd	p=3rd|n=plural|case=superessive
P	Pd	p=3rd|n=singular|case=ablative
P	Pd	p=3rd|n=singular|case=accusative
P	Pd	p=3rd|n=singular|case=adessive
P	Pd	p=3rd|n=singular|case=allative
P	Pd	p=3rd|n=singular|case=causalis
P	Pd	p=3rd|n=singular|case=dative
P	Pd	p=3rd|n=singular|case=dative|pperson=3rd|pnumber=plural
P	Pd	p=3rd|n=singular|case=delative
P	Pd	p=3rd|n=singular|case=elative
P	Pd	p=3rd|n=singular|case=essive
P	Pd	p=3rd|n=singular|case=factive
P	Pd	p=3rd|n=singular|case=genitive
P	Pd	p=3rd|n=singular|case=illative
P	Pd	p=3rd|n=singular|case=inessive
P	Pd	p=3rd|n=singular|case=instrumental
P	Pd	p=3rd|n=singular|case=nominative
P	Pd	p=3rd|n=singular|case=nominative|pednumber=singular
P	Pd	p=3rd|n=singular|case=sublative
P	Pd	p=3rd|n=singular|case=superessive
P	Pd	p=3rd|n=singular|case=terminative
P	Pg	p=3rd|n=plural|case=nominative
P	Pg	p=3rd|n=singular|case=ablative
P	Pg	p=3rd|n=singular|case=accusative
P	Pg	p=3rd|n=singular|case=accusative|pperson=3rd|pnumber=singular
P	Pg	p=3rd|n=singular|case=allative
P	Pg	p=3rd|n=singular|case=dative
P	Pg	p=3rd|n=singular|case=essive
P	Pg	p=3rd|n=singular|case=genitive
P	Pg	p=3rd|n=singular|case=illative
P	Pg	p=3rd|n=singular|case=inessive
P	Pg	p=3rd|n=singular|case=inessive|pperson=3rd|pnumber=singular
P	Pg	p=3rd|n=singular|case=instrumental
P	Pg	p=3rd|n=singular|case=nominative
P	Pg	p=3rd|n=singular|case=nominative|pednumber=singular
P	Pg	p=3rd|n=singular|case=nominative|pperson=3rd|pnumber=plural
P	Pg	p=3rd|n=singular|case=sublative
P	Pg	p=3rd|n=singular|case=superessive
P	Pi	p=3rd|n=plural|case=accusative
P	Pi	p=3rd|n=plural|case=nominative
P	Pi	p=3rd|n=singular
P	Pi	p=3rd|n=singular|case=ablative
P	Pi	p=3rd|n=singular|case=accusative
P	Pi	p=3rd|n=singular|case=accusative|pperson=3rd|pnumber=plural
P	Pi	p=3rd|n=singular|case=accusative|pperson=3rd|pnumber=singular
P	Pi	p=3rd|n=singular|case=allative
P	Pi	p=3rd|n=singular|case=causalis
P	Pi	p=3rd|n=singular|case=dative
P	Pi	p=3rd|n=singular|case=delative
P	Pi	p=3rd|n=singular|case=essive
P	Pi	p=3rd|n=singular|case=essiveformal
P	Pi	p=3rd|n=singular|case=factive
P	Pi	p=3rd|n=singular|case=genitive
P	Pi	p=3rd|n=singular|case=illative
P	Pi	p=3rd|n=singular|case=inessive
P	Pi	p=3rd|n=singular|case=instrumental
P	Pi	p=3rd|n=singular|case=instrumental|pperson=3rd|pnumber=plural
P	Pi	p=3rd|n=singular|case=nominative
P	Pi	p=3rd|n=singular|case=nominative|pperson=1st|pnumber=plural
P	Pi	p=3rd|n=singular|case=nominative|pperson=3rd|pnumber=plural
P	Pi	p=3rd|n=singular|case=nominative|pperson=3rd|pnumber=singular
P	Pi	p=3rd|n=singular|case=sublative
P	Pi	p=3rd|n=singular|case=superessive
P	Pi	p=3rd|n=singular|case=superessive|pperson=3rd|pnumber=singular
P	Pp	p=1st|n=plural|case=accusative
P	Pp	p=1st|n=plural|case=nominative
P	Pp	p=1st|n=singular|case=accusative
P	Pp	p=1st|n=singular|case=nominative
P	Pp	p=2nd|n=plural|case=nominative
P	Pp	p=2nd|n=singular|case=accusative
P	Pp	p=2nd|n=singular|case=nominative
P	Pp	p=3rd|n=plural|case=accusative
P	Pp	p=3rd|n=plural|case=adessive
P	Pp	p=3rd|n=plural|case=dative
P	Pp	p=3rd|n=plural|case=nominative
P	Pp	p=3rd|n=singular|case=ablative
P	Pp	p=3rd|n=singular|case=accusative
P	Pp	p=3rd|n=singular|case=allative
P	Pp	p=3rd|n=singular|case=causalis
P	Pp	p=3rd|n=singular|case=dative
P	Pp	p=3rd|n=singular|case=elative
P	Pp	p=3rd|n=singular|case=genitive
P	Pp	p=3rd|n=singular|case=inessive
P	Pp	p=3rd|n=singular|case=instrumental
P	Pp	p=3rd|n=singular|case=nominative
P	Pp	p=3rd|n=singular|case=nominative|pednumber=singular
P	Pp	p=3rd|n=singular|case=sublative
P	Pq	p=3rd|n=plural|case=nominative
P	Pq	p=3rd|n=singular|case=ablative
P	Pq	p=3rd|n=singular|case=accusative
P	Pq	p=3rd|n=singular|case=dative
P	Pq	p=3rd|n=singular|case=delative
P	Pq	p=3rd|n=singular|case=elative
P	Pq	p=3rd|n=singular|case=essive
P	Pq	p=3rd|n=singular|case=genitive
P	Pq	p=3rd|n=singular|case=illative
P	Pq	p=3rd|n=singular|case=inessive
P	Pq	p=3rd|n=singular|case=instrumental
P	Pq	p=3rd|n=singular|case=nominative
P	Pq	p=3rd|n=singular|case=sublative
P	Pr	p=3rd|n=plural|case=ablative
P	Pr	p=3rd|n=plural|case=accusative
P	Pr	p=3rd|n=plural|case=allative
P	Pr	p=3rd|n=plural|case=dative
P	Pr	p=3rd|n=plural|case=delative
P	Pr	p=3rd|n=plural|case=elative
P	Pr	p=3rd|n=plural|case=genitive
P	Pr	p=3rd|n=plural|case=inessive
P	Pr	p=3rd|n=plural|case=instrumental
P	Pr	p=3rd|n=plural|case=nominative
P	Pr	p=3rd|n=plural|case=sublative
P	Pr	p=3rd|n=plural|case=superessive
P	Pr	p=3rd|n=singular|case=ablative
P	Pr	p=3rd|n=singular|case=accusative
P	Pr	p=3rd|n=singular|case=adessive
P	Pr	p=3rd|n=singular|case=allative
P	Pr	p=3rd|n=singular|case=causalis
P	Pr	p=3rd|n=singular|case=dative
P	Pr	p=3rd|n=singular|case=delative
P	Pr	p=3rd|n=singular|case=elative
P	Pr	p=3rd|n=singular|case=essive
P	Pr	p=3rd|n=singular|case=genitive
P	Pr	p=3rd|n=singular|case=illative
P	Pr	p=3rd|n=singular|case=inessive
P	Pr	p=3rd|n=singular|case=instrumental
P	Pr	p=3rd|n=singular|case=nominative
P	Pr	p=3rd|n=singular|case=sublative
P	Pr	p=3rd|n=singular|case=superessive
P	Ps	p=1st|n=plural|case=accusative|pednumber=plural
P	Ps	p=3rd|n=singular|case=accusative|pperson=3rd|pnumber=singular
P	Ps	p=3rd|n=singular|case=nominative
P	Ps	p=3rd|n=singular|case=nominative|pperson=1st|pnumber=plural
P	Ps	p=3rd|n=singular|case=nominative|pperson=1st|pnumber=singular
P	Ps	p=3rd|n=singular|case=nominative|pperson=3rd|pnumber=plural
P	Ps	p=3rd|n=singular|case=nominative|pperson=3rd|pnumber=singular
P	Px	p=1st|n=plural|case=accusative
P	Px	p=1st|n=plural|case=instrumental
P	Px	p=1st|n=plural|case=nominative
P	Px	p=1st|n=singular|case=inessive
P	Px	p=1st|n=singular|case=nominative
P	Px	p=2nd|n=singular|case=nominative
P	Px	p=3rd|n=plural|case=ablative
P	Px	p=3rd|n=plural|case=accusative
P	Px	p=3rd|n=plural|case=dative
P	Px	p=3rd|n=plural|case=dative|pednumber=singular
P	Px	p=3rd|n=plural|case=elative
P	Px	p=3rd|n=plural|case=factive|pednumber=singular
P	Px	p=3rd|n=plural|case=illative
P	Px	p=3rd|n=plural|case=inessive
P	Px	p=3rd|n=plural|case=instrumental
P	Px	p=3rd|n=plural|case=nominative
P	Px	p=3rd|n=plural|case=sublative
P	Px	p=3rd|n=singular|case=ablative
P	Px	p=3rd|n=singular|case=accusative
P	Px	p=3rd|n=singular|case=allative
P	Px	p=3rd|n=singular|case=dative
P	Px	p=3rd|n=singular|case=dative|pednumber=singular
P	Px	p=3rd|n=singular|case=elative
P	Px	p=3rd|n=singular|case=illative
P	Px	p=3rd|n=singular|case=inessive
P	Px	p=3rd|n=singular|case=instrumental
P	Px	p=3rd|n=singular|case=nominative
P	Px	p=3rd|n=singular|case=sublative
P	Px	p=3rd|n=singular|case=superessive
P	Py	p=3rd|n=singular|case=ablative
P	Py	p=3rd|n=singular|case=accusative
P	Py	p=3rd|n=singular|case=allative
P	Py	p=3rd|n=singular|case=dative
P	Py	p=3rd|n=singular|case=illative
P	Py	p=3rd|n=singular|case=instrumental
P	Py	p=3rd|n=singular|case=nominative
P	Py	p=3rd|n=singular|case=sublative
R	Rd	_
R	Rg	_
R	Ri	_
R	Rl	_
R	Rm	_
R	Rp	_
R	Rq	_
R	Rr	_
R	Rv	_
R	Rx	_
S	St	_
SPUNCT	SPUNCT	_
T	Tf	def=yes
T	Ti	def=no
V	Va	mood=conditional|t=present|p=3rd|n=singular|def=no
V	Va	mood=indicative|t=present|p=1st|n=plural|def=no
V	Va	mood=indicative|t=present|p=1st|n=singular|def=no
V	Va	mood=indicative|t=present|p=3rd|n=plural|def=no
V	Va	mood=indicative|t=present|p=3rd|n=plural|def=yes
V	Va	mood=indicative|t=present|p=3rd|n=singular|def=no
V	Va	mood=indicative|t=present|p=3rd|n=singular|def=yes
V	Vm	mood=conditional|t=present|p=1st|n=plural|def=no
V	Vm	mood=conditional|t=present|p=1st|n=plural|def=yes
V	Vm	mood=conditional|t=present|p=1st|n=singular|def=no
V	Vm	mood=conditional|t=present|p=1st|n=singular|def=yes
V	Vm	mood=conditional|t=present|p=3rd|n=plural|def=no
V	Vm	mood=conditional|t=present|p=3rd|n=plural|def=yes
V	Vm	mood=conditional|t=present|p=3rd|n=singular|def=no
V	Vm	mood=conditional|t=present|p=3rd|n=singular|def=yes
V	Vm	mood=imperative|t=present|p=1st|n=plural|def=no
V	Vm	mood=imperative|t=present|p=1st|n=plural|def=yes
V	Vm	mood=imperative|t=present|p=1st|n=singular|def=no
V	Vm	mood=imperative|t=present|p=1st|n=singular|def=yes
V	Vm	mood=imperative|t=present|p=2nd|n=plural|def=yes
V	Vm	mood=imperative|t=present|p=2nd|n=singular|def=no
V	Vm	mood=imperative|t=present|p=2nd|n=singular|def=yes
V	Vm	mood=imperative|t=present|p=3rd|n=plural|def=no
V	Vm	mood=imperative|t=present|p=3rd|n=plural|def=yes
V	Vm	mood=imperative|t=present|p=3rd|n=singular|def=no
V	Vm	mood=imperative|t=present|p=3rd|n=singular|def=yes
V	Vm	mood=indicative|t=past|p=1st|n=plural|def=no
V	Vm	mood=indicative|t=past|p=1st|n=plural|def=yes
V	Vm	mood=indicative|t=past|p=1st|n=singular|def=no
V	Vm	mood=indicative|t=past|p=1st|n=singular|def=yes
V	Vm	mood=indicative|t=past|p=2nd|n=plural|def=yes
V	Vm	mood=indicative|t=past|p=2nd|n=singular|def=no
V	Vm	mood=indicative|t=past|p=2nd|n=singular|def=yes
V	Vm	mood=indicative|t=past|p=3rd|n=plural|def=no
V	Vm	mood=indicative|t=past|p=3rd|n=plural|def=yes
V	Vm	mood=indicative|t=past|p=3rd|n=singular|def=no
V	Vm	mood=indicative|t=past|p=3rd|n=singular|def=yes
V	Vm	mood=indicative|t=present|p=1st|n=plural|def=no
V	Vm	mood=indicative|t=present|p=1st|n=plural|def=yes
V	Vm	mood=indicative|t=present|p=1st|n=singular|def=no
V	Vm	mood=indicative|t=present|p=1st|n=singular|def=yes
V	Vm	mood=indicative|t=present|p=2nd|n=singular|def=no
V	Vm	mood=indicative|t=present|p=2nd|n=singular|def=yes
V	Vm	mood=indicative|t=present|p=3rd|n=plural|def=no
V	Vm	mood=indicative|t=present|p=3rd|n=plural|def=yes
V	Vm	mood=indicative|t=present|p=3rd|n=singular|def=no
V	Vm	mood=indicative|t=present|p=3rd|n=singular|def=yes
V	Vm	mood=infinitive
V	Vm	mood=infinitive|t=present|p=1st|n=plural
V	Vm	mood=infinitive|t=present|p=1st|n=singular
V	Vm	mood=infinitive|t=present|p=2nd|n=singular
V	Vm	mood=infinitive|t=present|p=3rd|n=plural
V	Vm	mood=infinitive|t=present|p=3rd|n=singular
WPUNCT	WPUNCT	_
X	X	_
Y	Y	_
Z	Z	_
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
