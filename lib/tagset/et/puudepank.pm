#!/usr/bin/perl
# Driver for the Estonian tagset from the Eesti keele puudepank (Estonian Language Treebank).
# Tag is the part of speech followed by a slash and the morphosyntactic features, separated by commas.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::et::puudepank;
use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");



# Parts of speech (32 classes):
my %postable =
(
    # n = noun (tuul, mees, kraan, riik, naine)
    'n' => ['pos' => 'noun'],
    # prop = proper noun (Arnold, Lennart, Palts, Savisaar, Telia)
    'prop' => ['pos' => 'noun', 'subpos' => 'prop'],
    # art = article ###!!! DOES NOT OCCUR IN THE CORPUS
    'art' => ['pos' => 'adj', 'subpos' => 'art'],
    # v = verb (kutsutud, tahtnud, teadnud, tasunud, polnud)
    'v' => ['pos' => 'verb'],
    # v-fin = finite verb (roniti, valati, sõidutati, lahkunud, prantsatasimegi)
    'v-fin' => ['pos' => 'verb', 'verbform' => 'fin'],
    # v-inf = infinitive?/non-finite verb (lugeda, nuusutada, kiirustamata, laulmast, magama)
    'v-inf' => ['pos' => 'verb', 'verbform' => 'inf'],
    # v-pcp2 = verb participle? (sõidutatud, liigutatud, sisenenud, sõudnud, prantsatatud)
    'v-pcp2' => ['pos' => 'verb', 'verbform' => 'part'],
    # adj = adjective (suur, väike, noor, aastane, hall)
    'adj' => ['pos' => 'adj'],
    # adj-nat = nationality adjective (prantsuse, tšuktši)
    'adj-nat' => ['pos' => 'adj', 'subpos' => 'prop'],
    # adv = adverb (välja, edasi, ka, siis, maha)
    'adv' => ['pos' => 'adv'],
    # prp = preposition (juurde, taga, all, vastu, kohta)
    'prp' => ['pos' => 'prep'],
    # pst = preposition/postposition (poole, järele, juurde, pealt, peale)
    'pst' => ['pos' => 'prep', 'subpos' => 'post'],
    # conj-s = subordinating conjunction (et, kui, sest, nagu, kuigi)
    'conj-s' => ['pos' => 'conj', 'subpos' => 'sub'],
    # conj-c = coordinating conjunction (ja, aga, või, vaid, a)
    'conj-c' => ['pos' => 'conj', 'subpos' => 'coor'],
    # conj-p = prepositional conjunction ??? ###!!! DOES NOT OCCUR IN THE CORPUS
    'conj-p' => ['pos' => 'conj', 'other' => {'subpos' => 'prep'}],
    # pron = pronoun (to be specified) (pronoun type may be specified using features) (nood, sel, niisugusest, selle, sellesama)
    'pron' => ['pos' => 'noun', 'prontype' => 'prs'],
    # pron-pers = personal pronoun (ma, mina, sa, ta, tema, me, nad, nemad)
    'pron-pers' => ['pos' => 'noun', 'prontype' => 'prs'],
    # pron-rel = relative pronoun (mis, kes)
    'pron-rel' => ['pos' => 'noun', 'prontype' => 'rel'],
    # pron-int = interrogative pronoun ###!!! DOES NOT OCCUR IN THE CORPUS (is included under relative pronouns)
    'pron-int' => ['pos' => 'noun', 'prontype' => 'int'],
    # pron-dem = demonstrative pronoun (see, üks, siuke, selline, too)
    'pron-dem' => ['pos' => 'noun', 'prontype' => 'dem'],
    # pron-indef = indefinite pronoun (mõned)
    'pron-indef' => ['pos' => 'noun', 'prontype' => 'ind'],
    # pron-poss = possessive pronoun (ise)
    'pron-poss' => ['pos' => 'noun', 'prontype' => 'prs', 'poss' => 'poss'],
    # pron-def = possessive (?) pronoun (keegi, mingi)
    'pron-def' => ['pos' => 'noun', 'prontype' => 'prs', 'poss' => 'poss'],
    # pron-refl = reflexive pronoun (enda, endasse)
    'pron-refl' => ['pos' => 'noun', 'prontype' => 'prs', 'reflex' => 'reflex'],
    # num = numeral (kaks, neli, viis, seitse, kümme)
    'num' => ['pos' => 'num'],
    # intj = interjection (no, kurat)
    'intj' => ['pos' => 'int'],
    # infm = infinitive marker ###!!! DOES NOT OCCUR IN THE CORPUS
    'infm' => ['pos' => 'part', 'subpos' => 'inf'],
    # punc = punctuation (., ,, ', -, :)
    'punc' => ['pos' => 'punc'],
    # sta = statement ??? ###!!! DOES NOT OCCUR IN THE CORPUS
    # abbr = abbreviation (km/h, cm)
    'abbr' => ['abbr' => 'abbr'],
    # x = undefined word class (--, pid, viis-, ta-)
    'x' => [],
    # b = discourse particle (only in sul.xml (spoken language)) (noh, nigu, vä, nagu, ei)
    'b' => ['pos' => 'part']
);
my %featable =
(
# SUBCLASS FEATURES:
# Noun:
    # com ... common noun (tuul, mees, kraan, riik, naine)
    # nominal ... nominal abbreviation (Kaabel-TV, EE, kaabelTV) ... used rarely and inconsistently, should be ignored
    'com'   => [], # common is the default type of noun
# Pronoun:
    # dem ... demonstrative pronoun (see = it/this/that, üks = one, selline = that/such, too = that/such)
    # det ... pron/det: totality pronoun (iga = each/every, kõik = all)
    # det ... pron-poss/pos,det,refl: reflexive possessive pronoun (ise = oneself)
    # indef ... pron-def/indef (!) (keegi = someone/anyone, mingi = some/any)
    # indef ... pron-def/inter,rel,indef (mitu = several/many)
    # inter ... pron/inter: interrogative pronoun (mitu = how many, milline = what/which, mis = which/what)
    # inter ... pron-def/inter,rel,indef (mitu = how many/several/many)
    # inter ... pron-rel/inter,rel (kes = who)
    # pers ... pron/pers || pron-pers/pers (ma, mina = I, sa = you, ta, tema = he/she/it, me = we, nad, nemad = they)
    # rec ... pron/rec: reciprocal pronoun (üksteisele = each other)
    # refl ... pron/refl || pron-poss/pos,det,refl || pron-refl/refl: reflexive pronoun (ise = oneself, enda = own [genitive of 'ise'], oma = my/your/his/her/its/our/their)
    # rel ... pron/rel: relative pronoun (mis, kes)
    # rel ... pron-def/inter,rel,indef (mitu)
    # rel ... pron-rel/inter,rel || pron-rel/rel (mis, kes)
    'dem'   => ['prontype' => 'dem'],
    'det'   => ['prontype' => 'tot'],
    'indef' => ['prontype' => 'ind'],
    'inter' => ['prontype' => 'int'],
    'pers'  => ['prontype' => 'prs'],
    'rec'   => ['prontype' => 'rcp'],
    'refl'  => ['reflex' => 'reflex'],
    'rel'   => ['prontype' => 'rel'],
# Numeral:
    # digit ... numeral written in digits (21, 120, 20_000, 15.40, 1875)
    # card ... cardinal numerals (kaks = two, neli = four, viis = five, seitse = seven, kümme = ten)
    # ord ... adj/ord || num/ord (esimene = first, teine = second, kolmas = third)
    'digit' => ['numform' => 'digit'],
    'card'  => ['numtype' => 'card'],
    'ord'   => ['numtype' => 'ord'],
# Verb:
    # aux ... v/aux || v-fin/aux: auxiliary verb (ole = to be, ei = not, saaks = to)
    # mod ... v/mod || v-fin/mod: modal verb (saa = can, pean = have/need?, võib = can)
    # main ... main verb:
    # main ... v/main (teha = do, saada = get, hakata = start, pakkuda = offer, müüa = sell)
    # main ... v-fin/main (olen = I am, tatsan, sõidan = I drive, ütlen = I say, ujun = I swim)
    # main ... v-inf/main (magama = sleep, hingama = breathe, uudistama = gaze, külastama = visit, korjama = pick)
    # main ... v-pcp2/main (liikunud = moved, roninud = climbed, tilkunud = dripped, tõusnud = increased, prantsatanud = crashed)
    'main'  => [], # main is the default type of verb
    'aux'   => ['subpos' => 'aux'],
    'mod'   => ['subpos' => 'mod'],
# Adposition:
    # pre ... prp/pre: preposition (vastu = against, enne = before, pärast = after, hoolimata = in spite of, üle = over)
    # post ... prp/post: postposition (mööda = along, juurde = to/by/near, taga = behind, all = under, vastu = against)
    # post ... pst/post: postposition (vahet = between, poole = to, järele = for, pealt = from, peale = after)
    'pre'   => [], # preposition is the default type of adposition
    'post'  => ['subpos' => 'post'],
# Conjunction:
    # crd ... conj-c/crd || conj-s/crd: coordination (ja = and, aga = but, või = or, vaid = but, ent = however)
    #         conj-c/crd,sub (kui = if/as/when/that)
    # sub ... conj-s/sub || conj-c/sub: subordination (et = that, kui = if/as/when/that, sest = because, nagu = as/like, kuigi = although)
    'crd'   => ['subpos' => 'coor'],
    'sub'   => ['subpos' => 'sub'],
# Punctuation:
    # Com ... comma (,)
    # Exc ... exclamation mark (!)
    # Fst ... full stop (., ...)
    # Int ... question mark (?)
    'Com'   => ['punctype' => 'comm'],
    'Exc'   => ['punctype' => 'excl'],
    'Fst'   => ['punctype' => 'peri'],
    'Int'   => ['punctype' => 'qest'],
# FEATURES:
# Number:
    # sg ... singular (abbreviations, adjectives, nouns, numerals, pronouns, proper nouns, verbs
    # pl ... plural (ditto)
    'sg'    => ['number' => 'sing'],
    'pl'    => ['number' => 'plu'],
# Case:
    # nom ... nominative (tuul, mees, kraan, riik, naine)
    # gen ... genitive (laua, mehe, ukse, metsa, tee)
    # abes ... abessive? (aietuseta)
    # abl ... ablative (maalt, laevalt, põrandalt, teelt, näolt)
    # ad ... adessive (aastal, tänaval, hommikul, õhtul, sammul)
    # adit ... additive (koju, tuppa, linna, kööki, aeda) ... tenhle pád česká, anglická ani estonská Wikipedie estonštině nepřipisuje, ale značky Multext ho obsahují
    #    additive has the same meaning as illative, exists only for some words and only in singular
    # all ... allative (põrandala, kaldale, rinnale, koerale, külalisele)
    # el ... elative (hommikust, trepist, linnast, toast, voodist)
    # es ... essive (naisena, paratamatusena, tulemusena, montöörina, tegurina)
    # ill ... illative (voodisse, ämbrisse, sahtlisse, esikusse, autosse)
    # in ... inessive (toas, elus, unes, sadulas, lumes)
    # kom ... comitative (kiviga, jalaga, rattaga, liigutusega, petrooliga)
    # part ... partitive (vett, tundi, ust, verd, rada)
    # term ... terminative (õhtuni, mereni, ääreni, kaldani, kroonini)
    # tr ... translative (presidendiks, ajaks, kasuks, müüjaks, karjapoisiks)
    'nom'   => ['case' => 'nom'],
    'gen'   => ['case' => 'gen'],
    'abes'  => ['case' => 'abe'],
    'abl'   => ['case' => 'abl'],
    'ad'    => ['case' => 'ade'],
    'adit'  => ['case' => 'add'],
    'all'   => ['case' => 'all'],
    'el'    => ['case' => 'ela'],
    'es'    => ['case' => 'ess'],
    'ill'   => ['case' => 'ill'],
    'in'    => ['case' => 'ine'],
    'kom'   => ['case' => 'com'],
    'part'  => ['case' => 'par'],
    'term'  => ['case' => 'ter'],
    'tr'    => ['case' => 'tra'],
# Subcategorization cases of adpositions:
    # .el, %el ... preposition requires ellative (hoolimata = in spite of)
    # .gen, %gen ... preposition requires genitive (juurde = to, taga = behind, all = under, vastu = against, kohta = for)
    # .nom, %nom ... preposition requires nominative (tagasi = back)
    # .kom, %kom ... preposition requires comitative (koos = with)
    # .part, %part ... preposition requires partitive (mööda = along, vastu = against, keset = in the middle of, piki = along, enne = before)
    '.nom'  => ['case' => 'nom'],
    '.gen'  => ['case' => 'gen'],
    '.el'   => ['case' => 'ela'],
    '.kom'  => ['case' => 'com'],
    '.part' => ['case' => 'par'],
# Degree of comparison:
    # The feature 'pos' seems to be the only feature with multiple meanings depending on the part of speech.
    # With adjectives, it means probably 'positive degree'. With adjectives, it is probably 'possessive'.
    # pos ... adj/pos (suur = big, väike = small, noor = young, aastane = annual, hall = gray)
    # pos ... adj/pos,partic (unistav = dreamy, rahulolev = contented, kägardunud = pushed, hautatud = stew, solvatud = hurt)
    # pos ... pron/pos (oma = my/your/his/her/its/our/their)
    # pos ... pron-poss/pos (oma)
    # pos ... pron-poss/pos,det,refl (ise, enda, oma)
    # comp ... comparative (tugevam = stronger, parem = better, tõenäolisem = more likely, enam = more, suurem = greater)
    'pos'   => ['degree' => 'pos'],
    'comp'  => ['degree' => 'comp'],
# Person:
    # ps1 ... first person (ma, mind)
    # ps2 ... second person (sind)
    # ps3 ... third person (neil, neile, nende, nad, neid, tal, talle, tema, ta)
    'ps1'   => ['person' => 1],
    'ps2'   => ['person' => 2],
    'ps3'   => ['person' => 3],
# Personativity of verbs: is the person of the verb known? (###!!! DZ: tagset documentation missing, misinterpretation possible!)
    # ps ... (olen = I am, sõidan = I drive, ütlen = I say, ujun = I swim, liigutan = I move)
    # imps ... (räägitakse = it's said, kaalutakse = it's considered; mängiti = played, visati = thrown, eelistati = preferred, hakati = began)
# Verb form and mood:
    # inf ... infinitive (teha, saada, hakata, pakkuda, müüa)
    # sup ... supine (informeerimata, tulemast, avaldamast, otsima, tegema)
    # partic ... adjectives and verbs ... participles (keedetud, tuntud, tunnustatud)
    # ger ... gerund (arvates, naeratades, vaadates, näidates, saabudes)
    # indic ... indicative (oli, pole, ole, on, ongi)
    # imper ... imperative (vala, sõiduta)
    # cond ... conditional (saaks, moodustaksid)
    # quot ... quotative mood (olevat, tilkuvat)
    'inf'   => ['verbform' => 'inf'],
    'sup'   => ['verbform' => 'sup'],
    'partic'=> ['verbform' => 'part'],
    'ger'   => ['verbform' => 'ger'],
    'indic' => ['verbform' => 'fin', 'mood' => 'ind'],
    'imper' => ['verbform' => 'fin', 'mood' => 'imp'],
    'cond'  => ['verbform' => 'fin', 'mood' => 'cnd'],
    'quot'  => ['verbform' => 'fin', 'mood' => 'qot'],
# Tense:
    # pres ... present (saaks, moodustaksid, oleks, asetuks, kaalutakse)
    # past ... past (tehtud, antud, surutud, kirjutatud, arvatud)
    # impf ... imperfect (oli, käskisin, helistasin, olid, algasid)
    'pres'  => ['tense' => 'pres'],
    'past'  => ['tense' => 'past'],
    'impf'  => ['tense' => 'past', 'subtense' => 'imp', 'aspect' => 'imp'],
# Negativeness:
    # af ... affirmative verb (oli, saime, andsin, sain, ütlesin)
    # neg ... negative verb (ei, kutsutud, tahtnud, teadnud, polnud)
    'af'    => ['negativeness' => 'pos'],
    'neg'   => ['negativeness' => 'neg'],
# Subcategorization of verbs:
    # .Intr, %Intr ... intransitive verb
    # .Int, %Int ... verb subcategorization? another code for intransitive?
    # .InfP, %InfP ... infinitive phrase
    # .FinV, %FinV ... finite verb
    # .NGP-P, %NGP-P ... verb subcategorization? for what?
    # .Abl, %Abl ... noun phrase in ablative
    # .All, %All ... noun phrase in allative
    # .El, %El ... noun phrase in elative
    # .Part, %Part ... noun phrase in partitive
# l ... ordinal adjectives and cardinal and ordinal numerals; unknown meaning
# y ... noun abbreviations? (USA, AS, EBRD, CIA, ETV)
# ? ... abbreviations, numerals; unknown meaning
# .? ... abbreviations, adjectives, adverbs, nouns, proper nouns; unknown meaning
# x? ... numerals; unknown meaning
# .cap, %cap ... capitalized word (abbreviations: KGB; adjectives: Inglise; adverbs: Siis; conj-c: Ja; nouns: Poistelt; pronouns: Meile; prop: Jane...)
# .gi ... adjectives and nouns with the suffix '-gi' (rare feature)
# .ja, %ja ... words with suffix '-ja' (pakkujad, vabastaja)
# .janna ... words with suffix '-janna' (pekimägi-käskijanna)
# .ke ... words with suffix '-ke' (aiamajakese, sammukese, klaasikese)
# .lik ... words with suffix '-lik' (pidulikku)
# .line ... unknown meaning
# .m ... adjectives; unknown meaning (rare feature)
# .mine, %mine ... nouns; unknown meaning (rare feature)
# .nud, %nud ... words with suffix '-nud'
# .tav, %tav ... words with suffix '-tav' (laetav, väidetavasti)
# .tud, %tud ... words with suffix '-tud'
# .v, %v ... unknown meaning
# -- ... meaning no features?
);



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = 'et::puudepank';
    # two components: part of speech and features
    my ($pos, $features) = split(/\//, $tag);
    # The features are simple words, not attribute=value assignments.
    # Their list and brief description is in the beginning of the TIGER-XML corpus files
    # (note that some files define and use tags not used in other files).
    my @features = split(/,/, $features);
    my @assignments = @{$postable{$pos}};
    for(my $i = 0; $i<=$#assignments; $i += 2)
    {
        $f{$assignments[$i]} = $assignments[$i+1];
    }
    # Decode features.
    ###!!! Note that some tags contain conflicting features.
    # We are currently ignoring that fact. It could be partially solved using arrays of feature values.
    foreach my $feature (@features)
    {
        # Some marginal features have two variants, e.g. '.nom' and '%nom' have probably the same meaning.
        $feature =~ s/^%/./;
        @assignments = @{$featable{$feature}};
        for(my $i = 0; $i<=$#assignments; $i += 2)
        {
            $f{$assignments[$i]} = $assignments[$i+1];
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
