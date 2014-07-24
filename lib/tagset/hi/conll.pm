#!/usr/bin/perl
# Driver for the CoNLL 2006 Hindi tagset.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>, Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::hi::conll;
use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");



# http://ltrc.iiit.ac.in/nlptools2010/files/documents/POS-Tag-List.pdf
# http://ltrc.iiit.ac.in/MachineTrans/publications/technicalReports/tr031/posguidelines.pdf
# http://ltrc.iiit.ac.in/nlptools2010/files/documents/Morph-specifications-1_3_1.pdf
my %postable =
(
    # The first component is the part-of-speech tag from the common tagset for all Indian languages.
    # The second component has probably been output by the morphological analyzer.
    # There are frequent conflicts between the two in the annotation, which is surprising, as both parts ought to be disambiguated manually in HyDT-Hindi 2010.
    # Occasionally, the part-of-speech tag from the first component is repeated in the second component instead of the morph category.
    # I do not have any documentation of the categories assigned by the morphological analyzer; what follows are my guesses.
    # Repertory of the morph categories:
    # adj = adjective
    # adv = adverb
    # any = uncategorized (see also unk)
    # avy = conjunction, interjection, intensifier, negation
    # c = compound?
    # m = error: feature values shifted, there is no category, and this is masculine gender
    # n = noun
    # nst = noun of location
    # num = numeral
    # pn = pronoun
    # prp = pronoun?
    # psp = postposition
    # psp? = postposition
    # punc = punctuation
    # punn = punctuation
    # s = punctuation
    # unk = unknown (see also any)
    # ??? = ?
    # v = verb
    # All-IL POS tags:
    # *C = compound, e.g. NN = simple noun, NNC = compound noun
    # CC = conjunct (documentation says "conjunct" but perhaps they meant "conjunction"?)
    "CC\tCC"   => ['pos' => 'conj'], # NULL
    "CC\tadv"  => ['pos' => 'conj'], # baharhál # error?
    "CC\tavy"  => ['pos' => 'conj'], # ki, aur, lekin, va, to
    "CC\tpn"   => ['pos' => 'conj'], # jab, to
    "CC\tpsp"  => ['pos' => 'conj'], # banám, par
    "CC\tpunc" => ['pos' => 'conj', 'subpos' => 'sub'], # ki # error?
    "CC\tunk"  => ['pos' => 'conj', 'subpos' => 'sub'], # halánki
    # CL = classifier
    # DEM = demonstrative
    "DEM\tDEM" => ['pos' => 'adj', 'prontype' => 'dem'], # usí
    "DEM\tpn"  => ['pos' => 'adj', 'prontype' => 'dem'], # yah, jo, is, vah, us, yahí, jis, isí, vahí; is, us, isí, jis, usí, kisí, yah
    # ECH = echo
    # No examples in the Hindi treebank.
    # Rupert Snell, Simon Weightman: Teach Yourself Hindi, Section 16.5 Echo words, pages 210-211:
    # “An 'echo word' echoes another word and generalises its sense.
    # Thus čáy-váy means 'tea etc., tea or something similar', as in čáy-váy piyo 'Have some tea or something',
    # in which -váy echoes -čáy. Echo words usually begin with va-, but not always; they can be formed
    # quite creatively, often with a dismissive or disdainful sense.
    # Some echo pairings are an established part of Hindi vocabulary.
    # A further type consists of two words of similar meaning.”
    # INJ = interjection
    "INJ\tavy" => ['pos' => 'int'], # há~, are
    # INTF = intensifier
    "INTF\tadj" => ['pos' => 'adv', 'advtype' => 'deg'], # khásí, itní, barí, bare
    "INTF\tadv" => ['pos' => 'adv', 'advtype' => 'deg'], # sirf
    "INTF\tavy" => ['pos' => 'adv', 'advtype' => 'deg'], # behad, kahí, sabse, bahut, káfí, sarvádhik, ati
    "INTF\tunk" => ['pos' => 'adv', 'advtype' => 'deg'], # most
    # JJ = adjective
    "JJ\tJJ"    => ['pos' => 'adj'], # NULL, lágú
    "JJ\tadj"   => ['pos' => 'adj'], # bharí, viśeš, raváná, niyukt
    "JJ\tadv"   => ['pos' => 'adj'], # zyádátar, sarásar
    "JJ\tany"   => ['pos' => 'adj'], # tej, khotí
    "JJ\tavy"   => ['pos' => 'adj'], # kam, anya
    "JJ\tn"     => ['pos' => 'adj'], # rájí, pramukh, púrí, muslim, púrá
    "JJ\tunk"   => ['pos' => 'adj'], # ilektoral, áf, vándei, ebsentí, dijital
    "JJ\tv"     => ['pos' => 'adj'], # jultá, máná, máne
    "JJC\tadj"  => ['pos' => 'adj'], # učč, haváí, naksal, alag, ast
    "JJC\tn"    => ['pos' => 'adj'], # niyukti, bhárat, uttar
    # NEG = negation
    "NEG\tNEG"  => ['pos' => 'part'], # nahí~
    "NEG\tadv"  => ['pos' => 'part'], # nahí~
    "NEG\tavy"  => ['pos' => 'part'], # nahí~, na, biná, bagair, mat
    # NN = noun
    "NN\tNN"    => ['pos' => 'noun'], # NULL
    "NN\tadj"   => ['pos' => 'noun'], # patá, pramukh, svadeś, bayá~, galat
    "NN\tavy"   => ['pos' => 'noun'], # to, nakár, jabki, bár
    "NN\tm"     => ['pos' => 'noun'], # pákistániyo~
    "NN\tn"     => ['pos' => 'noun'], # baje, ráštrapati, gaváh, bár, samay
    "NNC\tadj"  => ['pos' => 'noun'], # bhárí, haváí
    "NNC\tn"    => ['pos' => 'noun'], # videś, ráštrapati, hom, byáj, sikkh
    "NNC\tunk"  => ['pos' => 'noun'], # kálar
    # NNP = proper noun
    "NNP\tNNP"  => ['pos' => 'noun', 'subpos' => 'prop'], # soní
    "NNP\tm"    => ['pos' => 'noun', 'subpos' => 'prop'], # niyás
    "NNP\tn"    => ['pos' => 'noun', 'subpos' => 'prop'], # kángres, dillí, gándhí, sarkár, sunámí
    "NNP\tnst"  => ['pos' => 'noun', 'subpos' => 'prop'], # púrva
    "NNP\tnum"  => ['pos' => 'noun', 'subpos' => 'prop'], # ??
    "NNP\tunk"  => ['pos' => 'noun', 'subpos' => 'prop'], # riprezentetiv, sált, byúrí, intarpol
    "NNPC\tadj" => ['pos' => 'noun', 'subpos' => 'prop'], # lál
    "NNPC\tavy" => ['pos' => 'noun', 'subpos' => 'prop'], # fôr, evan
    "NNPC\tn"   => ['pos' => 'noun', 'subpos' => 'prop'], # yamuná, rakšá, naí, pranav, śivráj, manmohan, mantrí, pradhánmantrí, ke
    "NNPC\tpsp" => ['pos' => 'noun', 'subpos' => 'prop'], # ke
    "NNPC\tunk" => ['pos' => 'noun', 'subpos' => 'prop'], # ôn, da, ôf, sande
    # NST = NLoc (noun of location)
    "NST\tNST"  => ['pos' => 'noun', 'advtype' => 'loc'], # pás, samakš
    "NST\tn"    => ['pos' => 'noun', 'advtype' => 'loc'], # or, dauran, udhar, taraf, pás, áge, sáth, bád, bíč
    "NST\tnst"  => ['pos' => 'noun', 'advtype' => 'loc'], # or, taraf, níče, bíč, pahle, sáth, sámne, píčhe
    "NSTC\tnst" => ['pos' => 'noun', 'advtype' => 'loc'], # ás, va, ámne, rú
    # PRP = pronoun
    "PRP\tPRP"  => ['pos' => 'noun', 'prontype' => 'prs'], # NULL
    "PRP\tadj"  => ['pos' => 'adj', 'prontype' => 'prs'], # ápsí, aisí, apná, apne
    "PRP\tavy"  => ['pos' => 'noun', 'prontype' => 'prs'], # to, islie, isílie
    "PRP\tn"    => ['pos' => 'noun', 'prontype' => 'prs'], # dúsre, apne
    "PRP\tpn"   => ['pos' => 'noun', 'prontype' => 'prs'], # khud, svayam, áp, sabhí, kučh, sab, ápko, ápse, ham, hame~, unhonne, ve, ye, un, jo, unki...
    "PRP\tprp"  => ['pos' => 'noun', 'prontype' => 'prs'], # dúsre
    "PRP\tpsp"  => ['pos' => 'noun', 'prontype' => 'prs'], # ke
    "PRP\tv"    => ['pos' => 'noun', 'prontype' => 'prs'], # khud
    "PRPC\tpn"  => ['pos' => 'noun', 'prontype' => 'prs'], # apne
    # PSP = postposition
    "PSP\tPSP"  => ['pos' => 'prep', 'subpos' => 'post'], # ke, men, ko, se, ne
    "PSP\tadj"  => ['pos' => 'prep', 'subpos' => 'post'], # mutábik, khiláf, jaise
    "PSP\tavy"  => ['pos' => 'prep', 'subpos' => 'post'], # se, tak, ke, kí, alává
    "PSP\tn"    => ['pos' => 'prep', 'subpos' => 'post'], # kí, apékšá, bhanti, tarah, válí
    "PSP\tnst"  => ['pos' => 'prep', 'subpos' => 'post'], # bád
    "PSP\tpn"   => ['pos' => 'prep', 'subpos' => 'post'], # alává, khiláf
    "PSP\tpsp"  => ['pos' => 'prep', 'subpos' => 'post'], # mutábik, vále, jaisí, kí, ke, lie
    "PSP\tpsp?" => ['pos' => 'prep', 'subpos' => 'post'], # čalte
    "PSP\tpunc" => ['pos' => 'prep', 'subpos' => 'post'], # ke
    "PSP\tunk"  => ['pos' => 'prep', 'subpos' => 'post'], # ôf
    "PSP\tv"    => ['pos' => 'prep', 'subpos' => 'post'], # válá, se, lie
    # QC = cardinal
    "QC\tQC"    => ['pos' => 'num', 'numtype' => 'card'], # hazáro~
    "QC\tadj"   => ['pos' => 'num', 'numtype' => 'card'], # ek, dono~, tín
    "QC\tany"   => ['pos' => 'num', 'numtype' => 'card'], # ??
    "QC\tavy"   => ['pos' => 'num', 'numtype' => 'card'], # sab
    "QC\tm"     => ['pos' => 'num', 'numtype' => 'card'], # páňč
    "QC\tn"     => ['pos' => 'num', 'numtype' => 'card'], # dono~, do, ????, čhah, čár, ek
    "QC\tnum"   => ['pos' => 'num', 'numtype' => 'card'], # páňč, dono~, ek, do, hazár, čár, tín, dúsré, áth
    "QC\tpn"    => ['pos' => 'num', 'numtype' => 'card'], # koí
    "QC\tpunc"  => ['pos' => 'num', 'numtype' => 'card'], # '1, '2
    "QC\t???"   => ['pos' => 'num', 'numtype' => 'card'], # ???
    "QCC\tnum"  => ['pos' => 'num', 'numtype' => 'card'], # 3, 6
    # QF = quantifier (bahut, tho.DA, kam)
    "QF\tQF"    => ['pos' => 'num', 'numtype' => 'card', 'prontype' => 'ind'], # sab, anek
    "QF\tadj"   => ['pos' => 'num', 'numtype' => 'card', 'prontype' => 'ind'], # sabhí, anek, kitní, jitní, thorí, sárí, itní, utní, kučh, koí
    "QF\tavy"   => ['pos' => 'num', 'numtype' => 'card', 'prontype' => 'ind'], # kučh, kam, pratyek, tamám, adhikánš
    "QF\tn"     => ['pos' => 'num', 'numtype' => 'card', 'prontype' => 'ind'], # guná
    "QF\tpn"    => ['pos' => 'num', 'numtype' => 'card', 'prontype' => 'ind'], # kučh
    "QFC\tavy"  => ['pos' => 'num', 'numtype' => 'card', 'prontype' => 'ind'], # thorá
    # QO = ordinal
    "QO\tadj"   => ['pos' => 'num', 'numtype' => 'ord'], # dono~, dúsrí, dúsre, pahlá, tísre
    "QO\tn"     => ['pos' => 'num', 'numtype' => 'ord'], # dúsre
    "QO\tnum"   => ['pos' => 'num', 'numtype' => 'ord'], # pratham, dúsrí, čhathá, pahle, donon, dúsre, tísre, páňčví
    "QO\tv"     => ['pos' => 'verb'], # hai
    # RB = adverb of manner
    "RB\tRB"    => ['pos' => 'adv', 'advtype' => 'man'], # mahaj, phir
    "RB\tadj"   => ['pos' => 'adv', 'advtype' => 'man'], # zyádátar
    "RB\tadv"   => ['pos' => 'adv', 'advtype' => 'man'], # philhál, phir, jald, dobárá, lagátár
    "RB\tavy"   => ['pos' => 'adv', 'advtype' => 'man'], # daraasal, sirf, philhál, sáf, śántipúrvak
    "RB\tn"     => ['pos' => 'adv', 'advtype' => 'man'], # tejí
    "RB\tnst"   => ['pos' => 'adv', 'advtype' => 'man'], # sámne
    "RB\tpn"    => ['pos' => 'adv', 'advtype' => 'man'], # jahán
    "RB\tpsp"   => ['pos' => 'adv', 'advtype' => 'man'], # alává, philhál
    "RB\tunk"   => ['pos' => 'adv', 'advtype' => 'man'], # áf
    "RBC\tadv"  => ['pos' => 'adv', 'advtype' => 'man'], # ánan
    # RDP = reduplicative
    # Rupert Snell, Simon Weightman: Teach Yourself Hindi, Section 16.4 Repetition of words, page 210:
    # “Repeating a word may indicate distribution ('one rupee each'), or separation ('sit separately').
    # Or it may indicate variety and diversity. Repetition of an adjective or adverb lends it emphasis.”
    # Only the second part gets the RDP tag in the Hindi tagset.
    "RDP\tadj"  => ['pos' => 'adj', 'echo' => 'rdp'], # alag, sáf, aččhí, barí, bare
    "RDP\tadv"  => ['pos' => 'adv', 'echo' => 'rdp'], # kabhí, jald, bár, raftá, dhíre
    "RDP\tavy"  => ['pos' => 'adv', 'echo' => 'rdp'], # dhíre
    "RDP\tn"    => ['pos' => 'noun', 'echo' => 'rdp'], # subah, khuśí, tarah, jagah, bál, darjan, samay, qadam
    "RDP\tnst"  => ['pos' => 'noun', 'advtype' => 'loc', 'echo' => 'rdp'], # sáth, áge, dúr
    "RDP\tnum"  => ['pos' => 'num', 'echo' => 'rdp'], # ek, čár, do, ??
    "RDP\tpn"   => ['pos' => ['noun', 'adj'], 'prontype' => 'prs', 'echo' => 'rdp'], # apne, kisí
    "RDP\tpunc" => ['echo' => 'rdp'], # ek, do, bár
    "RDP\tunk"  => ['echo' => 'rdp'], # śem, oke
    "RDP\tv"    => ['pos' => 'verb', 'echo' => 'rdp'], # tarap, bhág, kát, dabočte, rote, játe
    # RP = particle (bhI, to, hI, jI, hA.N, na)
    "RP\tRP"    => ['pos' => 'part'], # bhí
    "RP\tadv"   => ['pos' => 'part'], # karíb, bhí, sirf, hí, keval
    "RP\tavy"   => ['pos' => 'part'], # se, bhí, hí, ádi, tak, to
    "RP\tn"     => ['pos' => 'part'], # aur
    "RP\tpn"    => ['pos' => 'part'], # prati
    "RP\tpsp"   => ['pos' => 'prep'], # se
    # SYM = symbol
    "SYM\tPUNC" => ['pos' => 'punc'], # .
    "SYM\tSYM"  => ['pos' => 'punc'], # , . /
    "SYM\tavy"  => ['pos' => 'punc'], # -
    "SYM\tpunc" => ['pos' => 'punc'], # . , ( ) -
    "SYM\tpunn" => ['pos' => 'punc'], # .
    "SYM\ts"    => ['pos' => 'punc'], # , -JOIN . ###!!! '-JOIN' must not be decoded from the WX encoding!
    "SYM\tunk"  => ['pos' => 'punc'], # -JOIN
    # UNK = unknown or foreign word
    "UNK\tn"    => [], # dát, vebar
    "UNK\tunk"  => [], # áut, regulet, lík, daunlod, ran, śem
    # UT = quotative (mAne)
    "UT\tnum"   => ['pos' => 'num', 'numtype' => 'card'], # ek # error?
    # VAUX = auxiliary verb
    "VAUX\tVAUX"=> ['pos' => 'verb', 'subpos' => 'aux'], # NULL
    "VAUX\tn"   => ['pos' => 'verb', 'subpos' => 'aux'], # vále
    "VAUX\tv"   => ['pos' => 'verb', 'subpos' => 'aux'], # hai, jáne, já, čáhie, rakhná, honá, hue, kar, ho, čuká, hain
    # VM = finite verb
    "VM\tVM"    => ['pos' => 'verb'], # NULL, áe
    "VM\tadj"   => ['pos' => 'verb'], # jamá
    "VM\tany"   => ['pos' => 'verb'], # karáne, nikalne, karne
    "VM\tn"     => ['pos' => 'verb'], # samvárne, sone
    "VM\tnum"   => ['pos' => 'verb'], # pahuňč
    "VM\tpsp"   => ['pos' => 'verb'], # čalte
    "VM\tv"     => ['pos' => 'verb'], # karná, kahná, karne, dená, mánná
    "VMC\tv"    => ['pos' => 'verb'], # číne, kháne
    # WQ = question word
    "WQ\tadv"   => ['pos' => ['noun', 'adj'], 'prontype' => 'int'], # kaise, kyá
    "WQ\tavy"   => ['pos' => ['noun', 'adj'], 'prontype' => 'int'], # kyá
    "WQ\tpn"    => ['pos' => ['noun', 'adj'], 'prontype' => 'int'], # kin, kaun, kis, kaunsá, kitne, kiská, kab, kyá, kyon, kaise
    # XC is not documented, perhaps uncategorized compound?
    # Example: "videś" in "videś mantrí" = "foreign minister" ("videś" = "foreign countries, abroad")
    "XC\tadj"   => ['pos' => 'adj'], # ghatak, śákáhár, gair, sair, klín, solar, dublí, atirikt, sáf, nae, nape
    "XC\tadv"   => ['pos' => 'adv'], # tas, jí, jor, thík
    "XC\tany"   => [], # sájhá, kharí
    "XC\tavy"   => ['pos' => 'conj'], # thore, evam, va, aur, no, tak
    "XC\tc"     => ['hyph' => 'hyph'], # jamč, bin, mukhya, kendriya, púrví, ejensí, úrjá
    "XC\tn"     => ['pos' => 'noun'], # balom, paune, háth, vokeśanal, paśu, kángres, pulis, surkšá, soniyá, ráhat
    "XC\tnst"   => [], # ás, idhar
    "XC\tnum"   => ['pos' => 'num'], # ??, ek, páňč, do, bís, čár
    "XC\tpn"    => ['pos' => 'adj', 'prontype' => 'ind'], # ek, merá, apne
    "XC\tpsp"   => ['pos' => 'prep'], # ke, e
    "XC\tpunc"  => [], # sárk, pákistání, (, )
    "XC\tunk"   => [], # lakme, ôf, suprím, hurriyat, faiśan
    "XC\tv"     => ['pos' => 'verb'], # lená, áná, jáne, áne, bahlá
);

# mapping to Interset 'pos' and other features based only on  CPOSTAG
# this 1-1 mapping is approximate only when POSTAG and FEAT values are not available,
# for example, when tags are obtained from POS tagger which was trained only on CPOSTAG
my %cpostable = 
(
	"CC"   => ['pos' => 'conj'], 
	"DEM" => ['pos' => 'adj', 'prontype' => 'dem'], 
	"INJ" => ['pos' => 'int'], 
	"INTF" => ['pos' => 'adv', 'advtype' => 'deg'], 
	"JJ"    => ['pos' => 'adj'], 
	"JJC"  => ['pos' => 'adj'], 
	"NEG"  => ['pos' => 'part'], 
	"NN"    => ['pos' => 'noun'], 
	"NNC"  => ['pos' => 'noun'], 
	"NNP"  => ['pos' => 'noun', 'subpos' => 'prop'], 
	"NNPC" => ['pos' => 'noun', 'subpos' => 'prop'], 
	"NST"  => ['pos' => 'noun', 'advtype' => 'loc'], 
	"NSTC" => ['pos' => 'noun', 'advtype' => 'loc'], 
	"PRP"  => ['pos' => 'noun', 'prontype' => 'prs'], 
	#"PRP"  => ['pos' => 'adj', 'prontype' => 'prs'], 
	"PRPC"  => ['pos' => 'noun', 'prontype' => 'prs'], 
	"PSP"  => ['pos' => 'prep', 'subpos' => 'post'], 
	"QC"    => ['pos' => 'num', 'numtype' => 'card'], 
	"QCC"  => ['pos' => 'num', 'numtype' => 'card'], 
	"QF"    => ['pos' => 'num', 'numtype' => 'card', 'prontype' => 'ind'], 
	"QFC"  => ['pos' => 'num', 'numtype' => 'card', 'prontype' => 'ind'], 
	"QO"   => ['pos' => 'num', 'numtype' => 'ord'], 
	#"QO"     => ['pos' => 'verb'], 
	"RB"    => ['pos' => 'adv', 'advtype' => 'man'], 
	"RBC"  => ['pos' => 'adv', 'advtype' => 'man'], 
	"RDP"  => ['pos' => 'adj', 'echo' => 'rdp'], 
	#"RDP"  => ['pos' => 'adv', 'echo' => 'rdp'], 
	#"RDP"    => ['pos' => 'noun', 'echo' => 'rdp'], 
	#"RDP"  => ['pos' => 'noun', 'advtype' => 'loc', 'echo' => 'rdp'], 
	#"RDP"  => ['pos' => 'num', 'echo' => 'rdp'], 
	#"RDP"   => ['pos' => ['noun', 'adj'], 'prontype' => 'prs', 'echo' => 'rdp'], 
	#"RDP" => ['echo' => 'rdp'], 
	#"RDP"  => ['echo' => 'rdp'], 
	#"RDP"    => ['pos' => 'verb', 'echo' => 'rdp'], 
	"RP"    => ['pos' => 'part'], 
	#"RP"   => ['pos' => 'prep'], 
	"SYM" => ['pos' => 'punc'], 
	"UNK"    => [], 
	"UT"   => ['pos' => 'num', 'numtype' => 'card'], 
	"VAUX"=> ['pos' => 'verb', 'subpos' => 'aux'], 
	"VM"    => ['pos' => 'verb'], 
	"VMC"    => ['pos' => 'verb'], 
	"WQ"   => ['pos' => ['noun', 'adj'], 'prontype' => 'int'], 
	"XC"   => ['pos' => 'adj'], 
	#"XC"   => ['pos' => 'adv'], 
	#"XC"   => [], 
	#"XC"   => ['pos' => 'conj'], 
	#"XC"     => ['hyph' => 'hyph'], 
	#"XC"     => ['pos' => 'noun'], 
	#"XC"   => [], 
	#"XC"   => ['pos' => 'num'], 
	#"XC"    => ['pos' => 'adj', 'prontype' => 'ind'], 
	#"XC"   => ['pos' => 'prep'], 
	#"XC"  => [], 
	#"XC"   => [], 
	#"XC"     => ['pos' => 'verb'], 
);

my %featable =
(
    'gend-m' => ['gender' => 'masc'],
    'gend-f' => ['gender' => 'fem'],
    'num-sg' => ['number' => 'sing'],
    'num-pl' => ['number' => 'plu'],
    'pers-1' => ['person' => 1],
    'pers-2' => ['person' => 2], # tu, tum = you (familiar and informal); but this value also appears with 'áp' (see below)
    'pers-2h' => ['person' => 2, 'politeness' => 'pol'], # áp = you (honorific)
    'pers-3' => ['person' => 3],
    'pers-3h' => ['person' => 3, 'politeness' => 'pol'], # unhonne = he/ergative/honorific-plural
    'case-d' => ['case' => 'nom'], # direct
    'case-o' => ['case' => 'acc'], # oblique
    # Vibhakti of nouns usually encodes postposition, i.e. another token in the sentence.
    # Pronouns are exception, they attach postpositions as suffixes (in case of compound postpositions they attach only the first part, usually "ke").
    # Pronoun example:
    # vah = he/nom; us = he/obl (us par = on him); usko/use = he/acc; uska/uskí/uske = he/gen; usne = he/erg; usse = he/ins/com/abl; usmen = he/ine
    'vib-ne' => [], # 0_ne: ergative (subject of transitive verb in past perfect tense)
    'vib-kA' => [], # 0_kA: genitive/possessive (ham log kí X = our X)
    'vib-ko' => [], # 0_ko: accusative (main ápko viśvás diláne áyá húm = lit. I you-acc faith unleash come am = I believe you)
    'vib-se' => [], # 0_se: instrumental/comitative (ve to unkí bát se sahmat hain = lit. they indeed his matter with agreed are = they agree with him)
    'vib-meM' => [], # inessive (men = in)
    'vib-para' => [], # adessive (par = on)
    'vib-waka' => [], # terminative (somvár kí rát tak = until Monday night)
    'vib-xvArA' => [], # dvárá = by, via
    'vib-kA_waraha' => [], # kí tarah
    'vib-kA_waraPa' => [], # kí taraf = to, towards
    'vib-ke_Age' => [], # ke áge = to?
    'vib-ke_aMxara' => [], # ke andar = within
    'vib-ke_alAvA' => [], # ke alává = in addition to
    'vib-ke_anusAra' => [], # ke anusár = according to
    'vib-ke_bagEra' => [], # ke bagair = without
    'vib-ke_bAhara' => [], # ke báhar = outside of
    'vib-ke_bAre_meM' => [], # ke báre men = about
    'vib-ke_bAxa' => [], # ke bád = after
    'vib-ke_bIca' => [], # ke bíč = between
    'vib-ke_BIwara' => [], # ke bhítar = in, within
    'vib-ke_jariye' => [], # ke jariye = through, using
    'vib-ke_jZarie' => [], # ke zarie = through
    'vib-ke_kAraNa' => [], # ke káran = due to
    'vib-ke_KilAPa' => [], # ke xiláf = against
    'vib-ke_lie' => [], # ke lie = for
    'vib-ke_maxxenajara' => [], # ke maddenajar = in the wake of
    'vib-ke_muwAbika' => [], # ke mutábik = according to
    'vib-ke_najaxIka' => [], # ke nazdík = near
    'vib-ke_nIce' => [], # ke níče = below
    'vib-ke_pAsa' => [], # ke pás = near, at, to
    'vib-ke_pICe' => [], # ke píčhe = after
    'vib-ke_prawi' => [], # ke prati = for, to
    'vib-ke_rUpa_meM' => [], # ke rúp men = as
    'vib-ke_sAWa' => [], # ke sáth = with
    'vib-ke_sAmane' => [], # ke sámne = in front of
    'vib-ke_Upara' => [], # ke úpar = on top of, above
    'vib-ke_wahawa' => [], # ke tahat = under
    'vib-ke_xOrAna' => [], # ke daurán = during
    # tense + aspect + modality (tam)
    'tam-hE' => ['subpos' => 'aux', 'verbform' => 'fin', 'mood' => 'ind', 'tense' => 'pres'], # auxiliary "to be": hún, hai, hain, ho
    'tam-WA' => ['subpos' => 'aux', 'verbform' => 'fin', 'mood' => 'ind', 'tense' => 'past'], # perfective participle of auxiliary "to be": thá, the, thí, thín
    'tam-gA' => ['verbform' => 'fin', 'mood' => 'ind', 'tense' => 'fut'], # jáegá = will go, will be
    'tam-eM' => ['verbform' => 'fin', 'mood' => 'sub'], # subjunctive: ... ki vah X kare = ... that he does X
    'tam-wA' => ['verbform' => 'part', 'aspect' => 'imp'], # imperfective participle: kartá = doing
    'tam-yA' => ['verbform' => 'part', 'aspect' => 'perf'], # perfective participle: kiyá = done
    'tam-nA' => ['verbform' => 'inf'], # infinitive or gerund
    'tam-kara' => ['verbform' => 'trans', 'tense' => 'past'], # lekar = having brought
    # sentence type (tagged at some verbs)
    'stype-declarative' => [], # declarative sentence
    'stype-imperative'  => [], # imperative sentence
    'stype-interrogative'=>[], # interrogative sentence
    'voicetype-active'  => ['voice' => 'act'],
    'voicetype-passive' => ['voice' => 'pass']
);



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = 'hi::conll';
    # three components: coarse-grained pos, fine-grained pos, features
    #print STDERR ("hi::conll: $tag\n");
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    my $poscombo = "$pos\t$subpos";
    my @features = split(/\|/, $features);
    my %conll_feat;
    map { if(m/^(.+)-(.+)$/) { $conll_feat{$1} = $2 } } (@features);

	my @assignments;
	# if the tag is obtained from a tagger trained only on CPOSTAG 
	# then POSTAG and FEAT columns will be empty... So the conversion will be 
	# based only on CPOSTAG. Conversion however will be only approximate
	if ($features eq '_') {
		@assignments = @{$cpostable{$poscombo}};
	}
	else {
		@assignments = @{$postable{$poscombo}};	
	}


    for(my $i = 0; $i<=$#assignments; $i++)
    {
        $f{$assignments[$i]} = $assignments[$i+1];
        # Exception: distinguish coordinating and subordinating conjunctions.
        # Exploit the fact that one of the features is lexical.
        # 'ki' = 'that'
        # 'hAlAMki' = 'although'
        # 'caMki' = 'as'
        if($pos eq 'UT' || $conll_feat{lex} =~ m/^(ki|hAlAMki|caMki)$/)
        {
            $f{subpos} = 'sub';
        }
    }
    # Decode feature values.
    foreach my $feature (@features)
    {
        my @assignments = @{$featable{$feature}};
        for(my $i = 0; $i<=$#assignments; $i++)
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
