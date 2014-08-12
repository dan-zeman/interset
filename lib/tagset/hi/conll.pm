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
CC	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-declarative'>|voicetype-active
CC	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-declarative|voicetype-
CC	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
CC	adv	cat-adv|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
CC	avy	cat-avy|gen-|num-|pers-3|case-|vib-|tam-|stype-|voicetype-
CC	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-declarative'>|voicetype-active
CC	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
CC	pn	cat-pn|gen-any|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
CC	pn	cat-pn|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
CC	psp	cat-psp|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
CC	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
CCC	avy	cat-avy|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
CCC	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
DEM	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
DEM	adj	cat-adj|gen-f|num-sg|pers-any|case-d|vib-|tam-|stype-|voicetype-
DEM	n	cat-n|gen-any|num-pl|pers-3|case-o|vib-|tam-|stype-|voicetype-
DEM	n	cat-n|gen-any|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
DEM	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-|tam-|stype-|voicetype-
DEM	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
DEM	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-any|num-any|pers-3|case-d|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-any|num-pl|pers-1|case-d|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-any|num-pl|pers-1|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-any|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-any|num-pl|pers-3|case-d|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-any|num-sg|pers-1|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-any|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-any|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_बारे_में|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-any|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-any|pers-3|case-d|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-any|pers-3|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-any|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-any|pers-any|case-d|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-any|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-any|pers-any|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-pl|pers-3|case-d|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-pl|pers-3|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-pl|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-pl|pers-any|case-d|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-pl|pers-any|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-sg|pers-3|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-sg|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-sg|pers-any|case-d|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-sg|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-f|num-sg|pers-any|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-any|pers-any|case-d|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-any|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-any|pers-any|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-pl|pers-3|case-d|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-pl|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-pl|pers-any|case-d|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-pl|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-pl|pers-any|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-sg|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-sg|pers-any|case-d|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-sg|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-sg|pers-any|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
DEM	pn	cat-pn|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
INJ	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
INTF	adj	cat-adj|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
INTF	adj	cat-adj|gen-f|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
INTF	adj	cat-adj|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
INTF	adj	cat-adj|gen-m|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
INTF	avy	cat-avy|gen-m|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
INTF	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
INTF	unk	cat-unk|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
JJ	_	cat-_|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
JJ	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-adj|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-any|num-any|pers-any|case-o|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-any|num-any|pers-d|case-|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-any|num-any|pers-|case-0|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-0|tam-0|stype-|voicetype-
JJ	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-any|num-any|pers-|case-|vib-|tam-0|stype-|voicetype-
JJ	adj	cat-adj|gen-any|num-any|pers-|case-|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-any|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-any|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-any|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-any|num-|pers-any|case-|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-f|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-f|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-f|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-f|num-pl|pers-o|case-|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-f|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-f|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-f|num-pl|pers-|case-|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-f|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-f|num-sg|pers-3|case-o|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-f|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-f|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-m|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-m|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-m|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-m|num-pl|pers-any|case-o|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-m|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-m|num-pl|pers-|case-o|vib-0_से|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-m|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-m|num-pl|pers-|case-|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-m|num-sg|pers-3h|case-d|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-m|num-sg|pers-3h|case-|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-m|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
JJ	adj	cat-adj|gen-m|num-sg|pers-|case-0|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-m|num-sg|pers-|case-o|vib-0_के_मुकाबला_में|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-m|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
JJ	adj	cat-adj|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
JJ	any	cat-any|gen-any|num-|pers-|case-o|vib-|tam-|stype-|voicetype-
JJ	any	cat-any|gen-any|num-|pers-|case-|vib-|tam-|stype-|voicetype-
JJ	avy	cat-avy|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
JJ	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
JJ	n	cat-n|gen-any|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
JJ	n	cat-n|gen-any|num-any|pers-|case-|vib-|tam-|stype-|voicetype-
JJ	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
JJ	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
JJ	num	cat-num|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
JJ	num	cat-num|gen-any|num-any|pers-|case-|vib-|tam-|stype-|voicetype-
JJ	pn	cat-pn|gen-any|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
JJ	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
JJ	unk	cat-unk|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
JJ	v	cat-v|gen-m|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
JJ	v	cat-v|gen-m|num-sg|pers-|case-|vib-कर|tam-kara|stype-|voicetype-
JJC	adj	cat-adj|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
JJC	adj	cat-adj|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
JJC	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
JJC	adj	cat-adj|gen-any|num-any|pers-|case-|vib-|tam-|stype-|voicetype-
JJC	adj	cat-adj|gen-f|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
JJC	adj	cat-adj|gen-f|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
JJC	adj	cat-adj|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
JJC	adj	cat-adj|gen-f|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
JJC	adj	cat-adj|gen-f|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
JJC	adj	cat-adj|gen-m|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
JJC	adj	cat-adj|gen-m|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
JJC	adj	cat-adj|gen-m|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
JJC	adj	cat-adj|gen-m|num-pl|pers-|case-|vib-|tam-|stype-|voicetype-
JJC	adj	cat-adj|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
JJC	adj	cat-adj|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
JJC	adj	cat-adj|gen-m|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
JJC	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
JJC	n	cat-n|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
JJC	n	cat-n|gen-f|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
JJC	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
JJC	n	cat-n|gen-f|num-sg|pers-3|case-|vib-0|tam-0|stype-|voicetype-
JJC	n	cat-n|gen-m|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
JJC	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
JJC	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
JJC	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
JJC	n	cat-n|gen-m|num-sg|pers-3|case-|vib-0|tam-0|stype-|voicetype-
JJC	unk	cat-unk|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
JJC	v	cat-v|gen-m|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
NEG	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NEG	adv	cat-adv|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NEG	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-declarative'>|voicetype-active
NEG	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-declarative|voicetype-passive
NEG	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NN	_	cat-_|gen-f|num-sg|pers-3|case-o|vib-0_से|tam-0|stype-|voicetype-
NN	_	cat-_|gen-|num-|pers-|case-|vib-0_के|tam-|stype-|voicetype-
NN	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NN	adj	cat-adj|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
NN	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-0_का|tam-|stype-|voicetype-
NN	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-0_के_तौर_पर|tam-|stype-|voicetype-
NN	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-0_के_रूप_में|tam-|stype-|voicetype-
NN	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-0_को|tam-|stype-|voicetype-
NN	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-0_ने|tam-|stype-|voicetype-
NN	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-0_सहित|tam-|stype-|voicetype-
NN	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-0_से|tam-|stype-|voicetype-
NN	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
NN	adj	cat-adj|gen-any|num-any|pers-|case-|vib-|tam-|stype-|voicetype-
NN	avy	cat-avy|gen-|num-|pers-|case-|vib-0_में|tam-|stype-|voicetype-
NN	avy	cat-avy|gen-|num-|pers-|case-|vib-0_से|tam-|stype-|voicetype-
NN	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NN	f	cat-f|gen-sg|num-3|pers-o|case-0|vib-0_का|tam-|stype-|voicetype-
NN	n	cat-n|gen-any|num-any|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-any|pers-3|case-o|vib-0_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-1|case-o|vib-को|tam-ko|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-3|case-o|vib-0_के_खिलाफ|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-3|case-o|vib-0_के_पास_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-3|case-o|vib-0_के_बारे_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-3|case-o|vib-0_के_बीच_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-3|case-o|vib-0_के_बीच|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-3|case-o|vib-0_के_लिए|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-3|case-o|vib-0_ने|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-3|case-o|vib-0_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-3|case-o|vib-0_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-3|case-o|vib-0_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-any|case-o|vib-0_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-any|case-o|vib-0_के_बीच|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-pl|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-sg|pers-3|case-d|vib-0_तक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_का_ओर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_करीब|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_बाद|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_बीच|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_तक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_ने|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-any|num-sg|pers-|case-o|vib-0_तक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-d|vib-0_तक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-d|vib-0_बाद|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-d|vib-0_भी|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-d|vib-|tam-|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_का_ओर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_का_तरफ|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_का_तुलना_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_का_वजह_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_का_हवाले_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_की_बाबत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_अंतर्गत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_अनुरूप|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_अनुसार|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_अलावा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_आगे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_आसपास|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_कारण|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_खिलाफ|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_चलते|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_जरिये|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_तहत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_दौरान|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_पास|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_पीछे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_प्रति|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_बजाय|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_बाद|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_बारे_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_बावजूद|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_बीच|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_मद्देनजर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_मद्देनज़र|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_मुकाबला|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_मुताबिक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_रूप_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_लिए|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_ले|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_संबंध_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_समय_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_समय|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_साथ|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_हिसाब_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_जैसा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_तक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_द्वारा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_ने|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_में_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_वाला|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_समेत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_सहित|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_से_अलग|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_से_आगे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_से_बाहर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-0|vib-0_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0_जैसा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0_तक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0_बतौर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0_बाद_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0_बाद|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0|tam-|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_अपेक्षा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_ओर_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_ओर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_कारण|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_खातिर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_तरफ_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_तरफ|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_तरह|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_तर्ज_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_तुलना_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_दौरान|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_बजाय|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_बदौलत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_बल_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_वक्त|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_वजह_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_वजह|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_की|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_अंदर_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_अंदर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_अनुरूप|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_अनुसार|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_अलावा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_आगे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_आधार_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_आसपास|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_उपरान्त|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_ऊपर_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_ऊपर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_करीब|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_कारण|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_खिलाफ|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_चलते|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_जरिये|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_तहत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_तौर_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_दौरान|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_नजदीक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_निकट|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_नीचा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_नीचे_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_नीचे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_परिणामस्वरूप|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_पश्चात|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_पास|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_पीछे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_पूर्व|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_प्रति|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बगैर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बजाय|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बदले_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बराबर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बल_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बहाना|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बाद_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बाद|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बाबत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बारे_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बावजूद|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बाहर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बीच_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बीच_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बीच|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_भीतर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_मद्देजनर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_मद्देनजर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_मद्देनज़र|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_मुकाबला|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_मुताबिक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_रूप_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_लायक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_लिए|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_लिहाज_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_ले|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_वक्त|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_विपरीत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_विरुद्ध|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_विरोध_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_संबंध_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_संबंध|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_समक्ष|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_समय|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_समान|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_साथ|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_सामने|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_हिसाब_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_जैसा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_जैसी|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_तक_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_तक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_दूर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_द्वारा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_ने|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_बतौर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_में_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_वाला_ने|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_वाला|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_वाली|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_समेत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_सरीखा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_सहित|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_से_ऊपर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_से_दूर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_से_नीचे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_से_परे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_से_पहला|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_से_पहले|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_से_पूर्व|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_से_बाहर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-any|case-o|vib-0_ने|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-any|case-o|vib-0_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-|case-d|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-f|num-sg|pers-|case-o|vib-0_ने|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-d|vib-0_तक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-d|vib-0_दूर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-d|vib-0_पहला|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-d|vib-0_पहले_तक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-d|vib-0_पहले_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-d|vib-0_पहले|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-d|vib-0_पूर्व|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-d|vib-0_बाद|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-d|vib-0|tam-0|stype-declarative'>|voicetype-passive
NN	n	cat-n|gen-m|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_कर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_का_अपेक्षा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_का_ओर_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_का_ओर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_का_खातिर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_का_तरफ_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_का_तरह|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_का_तुलना_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_का_बदौलत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_का_भांति|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_का_वजह_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_का_साथ|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_की|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_अंतर्गत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_अंदर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_अनुरूप|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_अनुसार|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_अलावा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_आसपास|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_ऊपर_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_ऊपर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_कारण|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_खिलाफ|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_चलते|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_जरिये|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_तहत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_दौरान|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_परिणामस्वरूप|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_पास_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_पास|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_पीछे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_प्रति|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_बजाय|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_बाद|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_बारे_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_बावजूद|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_बीच_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_बीच_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_बीच|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_भीतर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_मद्देनजर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_मद्देनज़र|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_मुकाबला|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_मुकाबले|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_मुताबिक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_मुताबिक|tam-|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_यहाँ|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_रूप_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_लिए|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_वक्त|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_विरुद्ध|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_संबंध_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_समक्ष|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_साथ|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_सामने|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_हवाला_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_हवाले_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_जरिये|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_जैसा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_तक_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_तक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_द्वारा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_ने|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_ने|tam-|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_पर_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_पर|tam-|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_बाद|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_बीच|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_में_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_में|tam-|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_वाला|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_समेत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_सहित|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_सामने|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_से_आगे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_से_पहले|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_से_पीछे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_से_बाहर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_से_लेकर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_से|tam-|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-o|case-0|vib-0_से|tam-|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-|case-d|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-|case-o|vib-0_को|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-pl|pers-|case-o|vib-0_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3h|case-d|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-0|vib-0_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-0|vib-0_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-0|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_अंदर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_आगे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_ऊपर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_का_तुलना_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_के_मुकाबला|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_के|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_तक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_दूर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_नीचे_तक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_पहला|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_पहले_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_पहले_तक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_पहले|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_पूर्व|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_बतौर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_बाद_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_बाद|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_वाला_को|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_वाला_ने|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_वाला|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_संग|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_साथ|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_स्वरूप|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-declarative'>|voicetype-passive
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-active
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-o|tam-o|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-00|tam-|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_उपग्रह|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_कंप्यूटर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_अपेक्षा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_ओर_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_ओर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_जगह|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_तरफ_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_तरफ|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_तरह|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_तुलना_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_तौर_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_बाद|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_बाबत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_भीतर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_ले|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_वजह_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_साथ|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_हैसियत_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का|tam-0|stype-declarative'>|voicetype-active
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_की_तरह|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_की|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_अंतर्गत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_अंदर_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_अंदर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_अंर्तगत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_अतिरिक्त|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_अनुकूल|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_अनुरूप|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_अनुसार|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_अलावा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_आगे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_आधार_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_आसपास|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_ऊपर_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_ऊपर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_करीब|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_कारण|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_खिलाफ|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_चलते|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_जरिये|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_तहत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_तौर_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_दरम्यान|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_दौरान|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_द्वारा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_नजदीक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_नाते|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_नीचे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_परिणामस्वरूप|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_पहले|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_पास_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_पास|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_पीछे_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_पीछे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_प्रति|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बजाए|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बजाय|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बदले_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बदले|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बराबर_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बराबर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बहाना|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बाद_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बाद_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बाद|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बाबत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बारे_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बावजूद|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बाहर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बीच_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बीच|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_भीतर_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_भीतर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_मद्देनजर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_मद्देनज़र|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_मद्देनज़र|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_मध्य_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_माध्यम_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_मार्फत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_मुकाबला|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_मुताबिक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_रुप_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_रूप_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_लिए|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_लिहाज_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_वक्त|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_विपरीत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_विरोध_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_संबंध_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_समक्ष|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_समय_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_समय_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_समय|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_समान|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_समीप|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_सहारा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_साथ|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_सामने|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_सिलसिले_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_हवाला_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_हिसाब_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_ज़रिए|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_को|tam-|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_जैसा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_जैसे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_तक_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_तक_के_लिए|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_तक_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_तक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_तले|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_द्वारा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_ने|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_पर_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_पर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_पर|tam-|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_पहले_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_फोन|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_बतौर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_बनाम|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_बाद|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_भी|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_में_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_में|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_में|tam-|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_वाला_के_लिए|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_वाला_के_साथ|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_वाला_को|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_वाला_ने|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_वाला|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_विस्फोट|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_समान|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_समेत|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_सहित|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_ऊपर_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_दूर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_नीचे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_पहला|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_पहले_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_पहले|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_पीछा|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_पीछे|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_पूर्व|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_बाहर_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_बाहर_तक|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_बाहर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_लेकर|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-d|case-3|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-d|case-o|vib-0_का|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-m|case-d|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-sg|case-o|vib-0_को|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-sg|pers-|case-d|vib-0|tam-0|stype-|voicetype-
NN	n	cat-n|gen-m|num-|pers-|case-o|vib-0_के_पर|tam-|stype-|voicetype-
NN	nst	cat-nst|gen-m|num-sg|pers-3|case-d|vib-0_के|tam-|stype-|voicetype-
NN	nst	cat-nst|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
NN	nst	cat-nst|gen-m|num-sg|pers-3|case-o|vib-0_में|tam-|stype-|voicetype-
NN	num	cat-num|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
NN	num	cat-num|gen-any|num-pl|pers-|case-o|vib-0_का|tam-|stype-|voicetype-
NN	num	cat-num|gen-any|num-sg|pers-|case-o|vib-0_से|tam-|stype-|voicetype-
NN	pn	cat-pn|gen-any|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NN	pn	cat-pn|gen-any|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
NN	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NN	pn	cat-pn|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NN	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NN	unk	cat-unk|gen-|num-|pers-|case-|vib-0_का|tam-|stype-|voicetype-
NN	unk	cat-unk|gen-|num-|pers-|case-|vib-0_को|tam-|stype-|voicetype-
NN	unk	cat-unk|gen-|num-|pers-|case-|vib-0_पर|tam-|stype-|voicetype-
NN	unk	cat-unk|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NNC	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NNC	adj	cat-adj|gen-any|num-any|pers-any|case-d|vib-|tam-|stype-|voicetype-
NNC	adj	cat-adj|gen-any|num-any|pers-any|case-o|vib-|tam-|stype-|voicetype-
NNC	adj	cat-adj|gen-any|num-any|pers-|case-0|vib-|tam-|stype-|voicetype-
NNC	adj	cat-adj|gen-any|num-any|pers-|case-any|vib-0|tam-|stype-|voicetype-
NNC	adj	cat-adj|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
NNC	adj	cat-adj|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
NNC	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
NNC	adj	cat-adj|gen-any|num-any|pers-|case-|vib-0|tam-|stype-|voicetype-
NNC	adj	cat-adj|gen-any|num-any|pers-|case-|vib-|tam-|stype-|voicetype-
NNC	adj	cat-adj|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNC	adj	cat-adj|gen-m|num-sg|pers-3|case-d|vib-०|tam-0|stype-|voicetype-
NNC	adv	cat-adv|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NNC	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NNC	n	cat-n|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
NNC	n	cat-n|gen-any|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
NNC	n	cat-n|gen-any|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNC	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
NNC	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_ने|tam-0|stype-|voicetype-
NNC	n	cat-n|gen-f|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNC	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NNC	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0_से|tam-0|stype-|voicetype-
NNC	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNC	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NNC	n	cat-n|gen-m|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNC	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के|tam-0|stype-|voicetype-
NNC	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNC	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-|stype-|voicetype-
NNC	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-o|tam-o|stype-|voicetype-
NNC	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
NNC	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
NNC	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
NNC	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NNC	n	cat-n|gen-m|num-sg|pers-3|case-|vib-0|tam-0|stype-|voicetype-
NNC	n	cat-n|gen-m|num-sg|pers-|case-d|vib-0|tam-0|stype-|voicetype-
NNC	num	cat-num|gen-any|num-any|pers-any|case-|vib-|tam-|stype-|voicetype-
NNC	num	cat-num|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
NNC	num	cat-num|gen-any|num-pl|pers-|case-any|vib-|tam-|stype-|voicetype-
NNC	pn	cat-pn|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNC	psp	cat-psp|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
NNC	psp	cat-psp|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NNC	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NNC	s	cat-s|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNC	unk	cat-unk|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NNP	_	cat-_|gen-|num-|pers-|case-|vib-0_से|tam-|stype-|voicetype-
NNP	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NNP	adj	cat-adj|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
NNP	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-0_का|tam-|stype-|voicetype-
NNP	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-0_में|tam-|stype-|voicetype-
NNP	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
NNP	m	cat-m|gen-sg|num-3|pers-d|case-o|vib-0|tam-|stype-|voicetype-
NNP	n	cat-n|gen-any|num-any|pers-3|case-o|vib-0_द्वारा|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-any|pers-3|case-o|vib-0_ने|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-any|pers-any|case-o|vib-0_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-any|pers-|case-o|vib-0_का|tam-|stype-|voicetype-
NNP	n	cat-n|gen-any|num-pl|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-d|vib-0_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-d|vib-0_के_बाद|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-d|vib-0_बकौल|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_का_अनुसार|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_का_ओर_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_का_तरफ_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_अनुसार|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_अलावा|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_उलट|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_करीब|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_कारण|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_खिलाफ|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_जरिये|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_तहत|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_दौरान|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_द्वारा|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_निकट|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_पास|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_बाद_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_बाद|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_बारे_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_बीच|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_मध्य_तक|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_मुताबिक|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_लिए|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_समक्ष|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_साथ|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_सामने|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के_हवाला_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_के|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_जैसा|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_जैसे|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_तक|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_द्वारा|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_नायर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_ने|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_पर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_पर|tam-|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_बकौल|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_वाला|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_वाली|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_समेत|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_सहित|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_से_आगे|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_से_पहले|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_से_पीछे|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-any|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_पास|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_के_समक्ष|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_जैसा|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_द्वारा|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_ने|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-pl|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-0|vib-0_ने|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0_के_जरिये|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0_बकौल|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_ओर_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_ओर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_तरफ_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_तरफ|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_तरह|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_वजह_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_साथ|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_अनुसार|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_अलावा|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_आसपास_के|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_आसपास|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_ऊपर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_कारण|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_खिलाफ|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_चलते|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_जरिये|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_तहत|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_दौरान|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_निकट_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_निकट|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_पास_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_पास|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_पीछे|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_प्रति|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बाद|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बारे_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बाहर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बीच_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_बीच|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_भीतर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_मुकाबला|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_मुताबिक|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_रूप_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_लिए|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_समक्ष|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_समय_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_समय|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_साथ|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_सामने|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_सौजन्य_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के_हवाला_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_के|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_जैसा|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_तक_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_तक_के_लिए|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_तक|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_द्वारा|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_ने|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_पर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_फिल्म|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_समेत|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_सरीखा|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_सहित|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_से_आगे|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_से_बाहर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-may|num-sg|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-any|pers-3|case-o|vib-0_के_खिलाफ|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-any|pers-3|case-o|vib-0_के_तहत|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-any|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-any|pers-3|case-o|vib-0_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_का_तरह|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_बारे_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_बूते|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_के_लिए|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_द्वारा|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_ने|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_पर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_समेत|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-0|vib-0_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-0|vib-0_ने|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-0|vib-0|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-any|vib-0|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_के_बीच|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_के_मुताबिक|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_गैलयां|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_जैसा|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_बकौल|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_मध्य_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_अनुसार|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_अपेक्षा|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_ओर_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_ओर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_जगह|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_तरफ_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_तरफ_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_तरफ|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_तरह|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_बजाय|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_बीच|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_भांति|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_वजह_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का_साथ|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का|tam-|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_की_ओर_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_अंतर्गत|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_अतंर्गत|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_अधीन|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_अनुरूप|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_अनुसार|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_अलावा|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_आसपास|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_उलट|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_ऊपर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_करीब|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_कारण|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_खिलाफ|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_गिर्द|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_जरिये|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_तत्वावधान_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_तहत|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_तहत|tam-|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_तौर_पर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_दौरान|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_नजदीक|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_नाते|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_निकट|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_नीचे|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_पहले|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_पास|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_प्रति|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बजाय|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बराबर_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बाद_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बाद_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बाद|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बारे_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बाहर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बीच_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बीच_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_बीच|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_भीतर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_मद्देनजर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_मुकाबला|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_मुकाबले|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_मुताबिक|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_रुप_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_रूप_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_लिए|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_वक्त|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_विरुद्ध|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_विरूद्ध|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_संबंध_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_समक्ष|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_समय_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_समय|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_समान|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_समीप|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_साथ|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_सामने|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_हवाला_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_हवाले_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के_ज़रिए|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_को|tam-|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_जैसा|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_जैसी|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_जैसे|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_तक_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_तक_के_लिए|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_तक|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_द्वारा|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_ने|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_पर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_बकौल|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_बाद_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_मनमोहन|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_मार्च|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_में_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_में|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_में|tam-|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_रावण|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_वाला|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_विपिन|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_समेत|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_सहित|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_आगे|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_दूर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_पहला_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_पहले_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_पहले|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_बाहर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से_लेकर|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-|vib-0_का|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-3|case-|vib-0_ने|tam-|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-m|case-d|vib-0|tam-0|stype-|voicetype-
NNP	n	cat-n|gen-m|num-sg|pers-|case-o|vib-0_के_तहत|tam-0|stype-|voicetype-
NNP	num	cat-num|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
NNP	num	cat-num|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
NNP	num	cat-num|gen-any|num-any|pers-|case-o|vib-0_का|tam-|stype-|voicetype-
NNP	num	cat-num|gen-any|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
NNP	num	cat-num|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
NNP	num	cat-num|gen-m|num-sg|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
NNP	pn	cat-pn|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NNP	psp	cat-psp|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NNP	unk	cat-unk|gen-|num-|pers-|case-o|vib-0_ने|tam-|stype-|voicetype-
NNP	unk	cat-unk|gen-|num-|pers-|case-o|vib-|tam-|stype-|voicetype-
NNP	unk	cat-unk|gen-|num-|pers-|case-|vib-0_का|tam-|stype-|voicetype-
NNP	unk	cat-unk|gen-|num-|pers-|case-|vib-0_को|tam-|stype-|voicetype-
NNP	unk	cat-unk|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NNP	v	cat-v|gen-any|num-any|pers-3|case-|vib-0|tam-0|stype-|voicetype-
NNPC	_	cat-_|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NNPC	adj	cat-adj|gen-any|num-any|pers-3|case-o|vib-|tam-|stype-|voicetype-
NNPC	adj	cat-adj|gen-any|num-any|pers-d|case-o|vib-|tam-|stype-|voicetype-
NNPC	adj	cat-adj|gen-any|num-any|pers-|case-0|vib-|tam-|stype-|voicetype-
NNPC	adj	cat-adj|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
NNPC	adj	cat-adj|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
NNPC	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-0_से|tam-|stype-|voicetype-
NNPC	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-0|tam-0|stype-|voicetype-
NNPC	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
NNPC	adj	cat-adj|gen-any|num-any|pers-|case-|vib-|tam-|stype-|voicetype-
NNPC	adj	cat-adj|gen-f|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
NNPC	adj	cat-adj|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
NNPC	adj	cat-adj|gen-f|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
NNPC	adj	cat-adj|gen-m|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
NNPC	adj	cat-adj|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
NNPC	adj	cat-adj|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
NNPC	avy	cat-avy|gen-|num-|pers-|case-|vib-0|tam-0|stype-|voicetype-
NNPC	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NNPC	c	cat-c|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-any|num-any|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-any|num-any|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
NNPC	n	cat-n|gen-any|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
NNPC	n	cat-n|gen-any|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-any|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
NNPC	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_ने|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-any|num-sg|pers-m|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-f|num-any|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-f|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0_का_तरह|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-any|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-sg|pers-3|case-any|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-00|tam-|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-o|tam-o|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_ने|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-sg|pers-3|case-|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-sg|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-sg|pers-m|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-sg|pers-|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
NNPC	n	cat-n|gen-m|num-|pers-|case-o|vib-|tam-|stype-|voicetype-
NNPC	n	cat-n|gen-sg|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	nst	cat-nst|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
NNPC	null	cat-null|gen-f|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	num	cat-num|gen-any|num-any|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	num	cat-num|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
NNPC	num	cat-num|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
NNPC	num	cat-num|gen-any|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
NNPC	num	cat-num|gen-any|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	num	cat-num|gen-f|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
NNPC	num	cat-num|gen-m|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
NNPC	num	cat-num|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
NNPC	pn	cat-pn|gen-any|num-sg|pers-2|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	pn	cat-pn|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	pn	cat-pn|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NNPC	psp	cat-psp|gen-f|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
NNPC	psp	cat-psp|gen-m|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
NNPC	psp	cat-psp|gen-m|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
NNPC	psp	cat-psp|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
NNPC	psp	cat-psp|gen-m|num-|pers-|case-o|vib-|tam-|stype-|voicetype-
NNPC	psp	cat-psp|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NNPC	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NNPC	s	cat-s|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NNPC	unk	cat-unk|gen-|num-|pers-|case-|vib-0|tam-|stype-|voicetype-
NNPC	unk	cat-unk|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NNPC	v	cat-v|gen-any|num-sg|pers-2|case-|vib-ओ|tam-ao|stype-|voicetype-
NNPC	v	cat-v|gen-m|num-sg|pers-3|case-|vib-गा|tam-gA|stype-|voicetype-
NNPC	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ता|tam-wA|stype-|voicetype-
NNPC	v	cat-v|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NST	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NST	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
NST	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
NST	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_के|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-f|num-pl|pers-3|case-d|vib-|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-f|num-pl|pers-3|case-o|vib-|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-f|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-f|num-sg|pers-3|case-o|vib-|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-3|pers-sg|case-d|vib-|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-d|vib-0_का|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-d|vib-0_के_मुकाबले|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-d|vib-0_तक|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-d|vib-0_वाला|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-d|vib-0|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-o|vib-0_का_तरह|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-o|vib-0_का_भांति|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-o|vib-0_का|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-o|vib-0_के_मुकाबले|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-o|vib-0_के|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-o|vib-0_जैसा|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-o|vib-0_तक|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-o|vib-0_में|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-o|vib-0_वाला|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-o|vib-0_से|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-3|case-o|vib-|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-|case-o|vib-0_का_तरह|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-|case-o|vib-0_का|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-|case-o|vib-0_के_मुकाबला|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-n|num-m|pers-sg|case-3|vib-d|tam-|stype-|voicetype-
NST	nst	cat-nst|gen-n|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
NST	num	cat-num|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
NST	psp	cat-psp|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
NST	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
NSTC	nst	cat-nst|gen-f|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
NSTC	nst	cat-nst|gen-m|num-sg|pers-3|case-d|vib-0_का|tam-|stype-|voicetype-
NSTC	nst	cat-nst|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
NSTC	nst	cat-nst|gen-|num-|pers-|case-|vib-0_का|tam-|stype-|voicetype-
NULL	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-declarative'>|voicetype-active
NULL	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
PRP	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
PRP	adj	cat-adj|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
PRP	avy	cat-avy|gen-|num-|pers-|case-d|vib-|tam-|stype-|voicetype-
PRP	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
PRP	n	cat-n|gen-any|num-any|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PRP	n	cat-n|gen-any|num-pl|pers-1|case-o|vib-को|tam-ko|stype-|voicetype-
PRP	n	cat-n|gen-any|num-pl|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
PRP	n	cat-n|gen-any|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PRP	n	cat-n|gen-any|num-sg|pers-3|case-o|vib-0_बारे_में|tam-0|stype-|voicetype-
PRP	n	cat-n|gen-f|num-pl|pers-1|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	n	cat-n|gen-m|num-any|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
PRP	n	cat-n|gen-m|num-any|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
PRP	n	cat-n|gen-m|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PRP	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PRP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
PRP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_पर|tam-0|stype-|voicetype-
PRP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	n	cat-n|gen-m|num-sg|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
PRP	num	cat-num|gen-any|num-pl|pers-|case-o|vib-0_पर|tam-|stype-|voicetype-
PRP	num	cat-num|gen-m|num-sg|pers-|case-o|vib-0_के_खिलाफ|tam-|stype-|voicetype-
PRP	num	cat-num|gen-m|num-sg|pers-|case-o|vib-0_के_खिलाफ़|tam-|stype-|voicetype-
PRP	num	cat-num|gen-m|num-sg|pers-|case-o|vib-0_को|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-any|pers-2h|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-any|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-any|pers-3|case-d|vib-|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-any|pers-3|case-o|vib-0_बाद|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-any|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-any|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-any|pers-any|case-o|vib-0_का|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-any|pers-any|case-o|vib-0_को|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-any|pers-any|case-o|vib-0_पर|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-any|pers-any|case-o|vib-0_में|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-any|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-any|pers-any|case-o|vib-को|tam-ko|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-any|pers-any|case-|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-1|case-any|vib-0_लिए|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-1|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-1|case-d|vib-|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-1|case-o|vib-0_को|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-1|case-o|vib-0_जैसे|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-1|case-o|vib-0_बीच|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-1|case-o|vib-0_में_से|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-1|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-1|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-1|case-o|vib-को|tam-ko|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-1|case-o|vib-ने|tam-ne|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-1|case-o|vib-में|tam-meM|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-1|case-o|vib-से|tam-se|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-2|case-o|vib-को|tam-ko|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-any|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-d|vib-|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_अलावा|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_के_अंदर|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_के_बारे_में|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_के_बारे_में|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_के_माध्यम_से|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_के_लिए|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_खिलाफ|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_जरिये|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_तक|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_पर|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_पास|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_प्रति|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_बारे_में|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_बावजूद|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_मुताबिक|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_में_से|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_लिए|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_साथ|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_सामने|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0_से|tam-meM|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-के|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-को|tam-ko|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-ने|tam-ne|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-में|tam-eM|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-में|tam-meM|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-में|tam-me|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-से|tam-se|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-any|case-o|vib-0_का|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-any|case-o|vib-0_के_अंदर|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-any|case-o|vib-0_के_पीछे|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-any|case-o|vib-0_के_लिए|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-any|case-o|vib-0_के_साथ|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-any|case-o|vib-0_को|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-any|case-o|vib-0_में|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-any|case-o|vib-0_से|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-pl|pers-any|case-o|vib-को|tam-ko|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-1h|case-o|vib-ने|tam-ne|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-1|case-any|vib-0_लिए|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-1|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-1|case-d|vib-|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-1|case-o|vib-0_जैसा|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-1|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-1|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-1|case-o|vib-को|tam-ko|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-1|case-o|vib-ने|tam-ne|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-1|case-o|vib-में|tam-meM|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-1|case-o|vib-से|tam-se|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-2h|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-2h|case-d|vib-को|tam-ko|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-2h|case-o|vib-0_पास|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-2h|case-o|vib-0_से|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-2h|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-2h|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-2h|case-o|vib-को|tam-ko|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-2h|case-o|vib-ने|tam-ne|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-2h|case-o|vib-से|tam-se|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-2|case-o|vib-ने|tam-ne|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-d|vib-|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-0_अलावा|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-0_खिलाफ|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-0_पर|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-0_पर|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-0_पास|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-0_मुताबिक|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-0_लिए|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-0_विरोध_में|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-0_साथ|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-के|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-को|tam-ko|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-ने|tam-ne|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-ने|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-में|tam-meM|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3h|case-o|vib-से|tam-se|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-d|vib-0_के_लिए|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-d|vib-0_बाबत|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-d|vib-0_बारे_में|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-d|vib-0|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-d|vib-को|tam-kO|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_अतिरिक्त|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_अलावा|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_आगे|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_आसपास_का|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_उलट|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_ऊपर|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_का|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_कारण|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_के_खिलाफ|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_के_चलते|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_के_तहत|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_के_तहत|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_के_पास|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_के_बाद|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_के_मद्देनजर|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_के_साथ|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_खिलाफ|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_चलते|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_जरिये|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_जो|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_तहत|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_ने|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_पर|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_पर|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_परिणामस्वरूप|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_पहला|tam-se|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_पहले|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_पहले|tam-se|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_पास_का|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_पास|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_पीछे|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_पूर्व|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_पूर्व|tam-se|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_प्रति|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_बाद_से|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_बाद|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_बाबत|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_बाबत|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_बारे_में|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_बारे_में|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_बारे_में|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_बावजूद|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_बाहर|tam-se|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_मद्देनजर|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_मुताबिक|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_में_में|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_में|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_लिए|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_वजह_से|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_समक्ष|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_साथ|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_से|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_से|tam-meM|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_से|tam-me|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0_से|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-के|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-को|tam-ko|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-ने|tam-ne|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-में|tam-meM|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-में|tam-me|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-से|tam-se|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-|vib-0_तहत|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-3|case-|vib-0_ज़रिए|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-any|case-o|vib-0_से|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-any|num-sg|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-any|pers-1|case-any|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-any|pers-1|case-d|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-any|pers-1|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-any|pers-3h|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-any|pers-3|case-o|vib-0_ओर_से|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-any|pers-any|case-d|vib-0_ओर|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-any|pers-any|case-d|vib-0_तरफ_से|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-any|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-any|pers-any|case-o|vib-0_ओर_से|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-any|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-any|pers-any|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-pl|pers-1|case-any|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-pl|pers-1|case-o|vib-0_ओर_से|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-pl|pers-1|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-pl|pers-3|case-d|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-pl|pers-3|case-o|vib-0_वजह_से|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-pl|pers-3|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-pl|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-pl|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-1|case-any|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-1|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-1|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-2h|case-d|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-2h|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-3h|case-o|vib-0_ओर_से|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-3h|case-o|vib-0_तरफ_से|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-3h|case-o|vib-0_द्वारा|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-3h|case-o|vib-0_वजह_से|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-3h|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-3h|case-o|vib-को|tam-ko|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-3h|case-o|vib-ने|tam-ne|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-3|case-d|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-3|case-o|vib-0_ओर_से|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-3|case-o|vib-0_ओर|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-3|case-o|vib-0_वजह_से|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-3|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-3|case-o|vib-ने|tam-ne|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-any|case-d|vib-0_ओर|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-any|case-d|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-any|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-1|case-any|vib-0_पास|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-1|case-any|vib-0_साथ|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-1|case-any|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-1|case-o|vib-0_लिए|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-1|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-any|case-d|vib-0_पास|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-any|case-d|vib-0_समक्ष|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-any|case-d|vib-0_साथ|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-any|case-d|vib-0_सामने|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-any|case-o|vib-0_आगे_का|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-any|case-o|vib-0_को|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-any|case-o|vib-0_खिलाफ|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-any|case-o|vib-0_द्वारा|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-any|case-o|vib-0_बारे_में|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-any|case-o|vib-0_में|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-any|case-o|vib-0_लिए|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-any|case-o|vib-0_साथ|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-any|case-o|vib-0_से|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-any|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-1|case-any|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-1|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-1|case-o|vib-0_पास|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-1|case-o|vib-0_पास|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-1|case-o|vib-0_लिए|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-1|case-o|vib-0_साथ|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-1|case-o|vib-0_सामने|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-1|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-1|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-3h|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-0_अलावा|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-0_कारण|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-0_के_लिए|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-0_खिलाफ|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-0_चलते|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-0_द्वारा|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-0_पास_से|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-0_पास|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-0_प्रति|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-0_बारे_में|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-0_लिए|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-0_संग|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-0_साथ|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-के|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-any|case-d|vib-|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-any|case-o|vib-0_लिए|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-any|case-o|vib-0_साथ|tam-se|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-pl|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-1|case-0|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-1|case-any|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-1|case-d|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-1|case-o|vib-0_साथ|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-1|case-o|vib-0_सामने|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-1|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-1|case-o|vib-के|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-2h|case-o|vib-0_पास|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-2h|case-o|vib-0_लिए|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-2h|case-o|vib-0_सामने|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-2h|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-2|case-o|vib-0_बारे_में|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-0_अलावा|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-0_ऊपर|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-0_खिलाफ|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-0_जैसा|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-0_द्वारा|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-0_पर|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-0_पास|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-0_बकौल|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-0_मुताबिक|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-0_लिए|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-0_साथ|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-0_हवाला_से|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-का|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-के|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-को|tam-ko|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-ने|tam-ne|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3h|case-o|vib-से|tam-se|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-d|vib-0_साथ|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-d|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_अनुसार|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_अलावा|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_आगे|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_आसपास_का|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_आसपास|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_उलट|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_एवज_में|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_कारण|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_के_खिलाफ|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_के_प्रति|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_के_साथ|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_के|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_खिलाफ|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_चलते|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_जरिये|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_तक|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_तहत|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_द्वारा|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_द्वारा|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_पर|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_परिणामस्वरूप|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_पश्चात|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_पहले|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_पास_का|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_पास|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_पीछे|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_पूर्व|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_प्रति|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_फलस्वरूप|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_बगल_का|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_बगल_में|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_बजाय|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_बदले|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_बाद_से|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_बाद|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_बारे_में|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_बारे_में|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_बावजूद|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_मद्देनजर|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_मद्देनज़र|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_माध्यम_से|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_मुताबिक|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_में|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_लिए|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_विपरीत|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_साथ|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_सामना|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0_से|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-के|tam-ke|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-ने|tam-ne|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-में|tam-meM|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-से|tam-se|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-any|case-d|vib-0_पास|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-any|case-d|vib-0_साथ|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-any|case-d|vib-0_सामना|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-any|case-o|vib-0_खिलाफ|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-any|case-o|vib-0_पीछा|tam-ne|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-any|case-o|vib-0_में|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-any|case-o|vib-0_लिए|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-any|case-o|vib-0_साथ|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-|case-o|vib-0_के|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-sg|num-any|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
PRP	pn	cat-pn|gen-|num-sg|pers-3|case-o|vib-का|tam-kA|stype-|voicetype-
PRP	pn	cat-pn|gen-|num-|pers-|case-d|vib-0_तक|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-|num-|pers-|case-d|vib-|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-|num-|pers-|case-o|vib-0_का|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-|num-|pers-|case-o|vib-0_के_लिए|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-|num-|pers-|case-o|vib-0_के|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-|num-|pers-|case-o|vib-0_को|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-|num-|pers-|case-o|vib-0_तक_का|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-|num-|pers-|case-o|vib-0_तक_के_लिए|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-|num-|pers-|case-o|vib-0_तक|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-|num-|pers-|case-o|vib-0_पर|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-|num-|pers-|case-o|vib-0_में|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-|num-|pers-|case-o|vib-0_से_ले|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-|num-|pers-|case-o|vib-0_से|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-|num-|pers-|case-o|vib-|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-|num-|pers-|case-|vib-0_तक|tam-|stype-|voicetype-
PRP	pn	cat-pn|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
PRP	psp	cat-psp|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
PRP	psp	cat-psp|gen-|num-|pers-|case-o|vib-0_में|tam-|stype-|voicetype-
PRP	psp	cat-psp|gen-|num-|pers-|case-o|vib-|tam-|stype-|voicetype-
PRP	psp	cat-psp|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
PRP	unk	cat-unk|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
PRPC	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
PRPC	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PRPC	num	cat-num|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
PRPC	pn	cat-pn|gen-any|num-any|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PRPC	pn	cat-pn|gen-any|num-any|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
PRPC	pn	cat-pn|gen-any|num-pl|pers-1|case-d|vib-0|tam-0|stype-|voicetype-
PRPC	pn	cat-pn|gen-any|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PRPC	pn	cat-pn|gen-any|num-pl|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
PRPC	pn	cat-pn|gen-any|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PRPC	pn	cat-pn|gen-m|num-any|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
PRPC	pn	cat-pn|gen-m|num-any|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
PRPC	pn	cat-pn|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PRPC	pn	cat-pn|gen-m|num-sg|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
PRPC	pn	cat-pn|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
PSP	PSP	cat-PSP|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
PSP	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-declarative'>|voicetype-active
PSP	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
PSP	adj	cat-adj|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
PSP	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	adj	cat-adj|gen-any|num-any|pers-|case-|vib-|tam-|stype-|voicetype-
PSP	adj	cat-adj|gen-any|num-|pers-|case-any|vib-|tam-|stype-|voicetype-
PSP	adj	cat-adj|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
PSP	adv	cat-adv|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
PSP	avy	cat-avy|gen-|num-|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
PSP	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PSP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
PSP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-|tam-|stype-|voicetype-
PSP	n	cat-n|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
PSP	n	cat-n|gen-f|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	n	cat-n|gen-f|num-|pers-|case-any|vib-|tam-|stype-|voicetype-
PSP	n	cat-n|gen-f|num-|pers-|case-d|vib-|tam-|stype-|voicetype-
PSP	n	cat-n|gen-f|num-|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	n	cat-n|gen-m|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
PSP	n	cat-n|gen-m|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	n	cat-n|gen-m|num-sg|pers-3h|case-d|vib-|tam-|stype-|voicetype-
PSP	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PSP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-|tam-|stype-|voicetype-
PSP	n	cat-n|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
PSP	n	cat-n|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	n	cat-n|gen-m|num-|pers-|case-d|vib-|tam-|stype-|voicetype-
PSP	n	cat-n|gen-m|num-|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	nst	cat-nst|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
PSP	pn	cat-pn|gen-m|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	pn	cat-pn|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-any|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-any|num-pl|pers-|case-|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-any|num-sg|pers-3|case-o|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-pl|pers-|case-o|vib-का|tam-kA|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-pl|pers-|case-|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-sg|pers-3|case-o|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-sg|pers-|case-d|vib-0|tam-0|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-sg|pers-|case-d|vib-का|tam-kA|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-sg|pers-|case-o|vib-0|tam-0|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-sg|pers-|case-o|vib-|tam-s|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-sg|pers-|case-o|vib-का|tam-kA|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-|pers-|case-d|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-f|num-|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-pl|pers-3|case-d|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-pl|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-pl|pers-3|case-o|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-pl|pers-3|case-|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-pl|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-pl|pers-|case-0|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-pl|pers-|case-d|vib-का|tam-kA|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-pl|pers-|case-o|vib-का|tam-kA|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-pl|pers-|case-|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-sg|pers-3h|case-d|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-sg|pers-3h|case-o|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-sg|pers-3h|case-|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-sg|pers-3|case-o|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-sg|pers-3|case-|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-sg|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-sg|pers-|case-0|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-sg|pers-|case-d|vib-का|tam-kA|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-sg|pers-|case-o|vib-का|tam-kA|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-m|num-|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-|num-|pers-|case-d|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-|num-|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-|num-|pers-|case-|vib-|tam-s|stype-|voicetype-
PSP	psp	cat-psp|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
PSP	psp	cat-psp|gen-|num-|pers-|case-|vib-या|tam-yA|stype-|voicetype-
PSP	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
PSP	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना|tam-nA|stype-|voicetype-
PSP	v	cat-v|gen-any|num-any|pers-any|case-|vib-कर|tam-kara|stype-|voicetype-
PSP	v	cat-v|gen-f|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
PSP	v	cat-v|gen-f|num-sg|pers-any|case-d|vib-|tam-|stype-|voicetype-
PSP	v	cat-v|gen-m|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
PSP	v	cat-v|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
QC	_	cat-_|gen-num|num-any|pers-any|case-|vib-any|tam-|stype-|voicetype-
QC	adj	cat-adj|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
QC	adj	cat-adj|gen-any|num-pl|pers-|case-any|vib-|tam-|stype-|voicetype-
QC	adj	cat-adj|gen-any|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
QC	adj	cat-adj|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
QC	any	cat-any|gen-any|num-|pers-any|case-|vib-|tam-|stype-|voicetype-
QC	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
QC	n	cat-n|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
QC	n	cat-n|gen-any|num-any|pers-|case-o|vib-0_से|tam-|stype-|voicetype-
QC	n	cat-n|gen-any|num-pl|pers-3|case-o|vib-0_में|tam-0|stype-|voicetype-
QC	n	cat-n|gen-any|num-pl|pers-|case-any|vib-|tam-|stype-|voicetype-
QC	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
QC	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
QC	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
QC	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_तक|tam-0|stype-|voicetype-
QC	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_में_से|tam-0|stype-|voicetype-
QC	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_से|tam-0|stype-|voicetype-
QC	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-3|case-o|vib-0_ने|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-3|case-o|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-any|case-|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-any|vib-0_का|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-any|vib-0_के|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-any|vib-0_जैसा|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-any|vib-0_तक|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-any|vib-0_पर|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-any|vib-0_में_से|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-any|vib-0_से|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-any|vib-|tam-0|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-o|vib-0_का_जगह|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-o|vib-0_का|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-o|vib-0_की|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-o|vib-0_के_मुकाबला|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-o|vib-0_के_मुकाबले|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-o|vib-0_के|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-o|vib-0_को|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-o|vib-0_तक|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-o|vib-0_पर|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-o|vib-0_में_से|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-o|vib-0_से|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-3|case-o|vib-0_का|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-3|case-o|vib-0_में_से|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-any|case-|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-|case-any|vib-0_का|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-|case-any|vib-0_को|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-|case-any|vib-0_से|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-|case-any|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-|case-o|vib-0_का_जगह|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-|case-o|vib-0_का|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-|case-o|vib-0_के|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-|case-o|vib-0_को|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-|case-o|vib-0_तक|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-|case-o|vib-0_ने|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-|case-o|vib-0_पर|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-|case-o|vib-0_में_से|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-|case-o|vib-0_से_का|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-|case-o|vib-0_से|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-sg|pers-3|case-o|vib-0_से|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-any|num-|pers-any|case-|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-f|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-m|num-pl|pers-|case-any|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-m|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-m|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-m|num-sg|pers-3|case-|vib-|tam-|stype-|voicetype-
QC	num	cat-num|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
QC	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
QCC	adj	cat-adj|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
QCC	avy	cat-avy|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
QCC	n	cat-n|gen-any|num-any|pers-|case-any|vib-0_से|tam-|stype-|voicetype-
QCC	n	cat-n|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
QCC	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_का|tam-0|stype-|voicetype-
QCC	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0_से|tam-0|stype-|voicetype-
QCC	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
QCC	num	cat-num|gen-any|num-any|pers-any|case-|vib-|tam-|stype-|voicetype-
QCC	num	cat-num|gen-any|num-any|pers-|case-any|vib-0_का|tam-|stype-|voicetype-
QCC	num	cat-num|gen-any|num-any|pers-|case-any|vib-0_के_बराबर|tam-|stype-|voicetype-
QCC	num	cat-num|gen-any|num-any|pers-|case-any|vib-0_के|tam-|stype-|voicetype-
QCC	num	cat-num|gen-any|num-any|pers-|case-any|vib-0_को|tam-|stype-|voicetype-
QCC	num	cat-num|gen-any|num-any|pers-|case-any|vib-0_तक_का|tam-|stype-|voicetype-
QCC	num	cat-num|gen-any|num-any|pers-|case-any|vib-0_तक|tam-|stype-|voicetype-
QCC	num	cat-num|gen-any|num-any|pers-|case-any|vib-0_से_के|tam-|stype-|voicetype-
QCC	num	cat-num|gen-any|num-any|pers-|case-any|vib-0_से|tam-|stype-|voicetype-
QCC	num	cat-num|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
QCC	num	cat-num|gen-any|num-any|pers-|case-d|vib-0_से|tam-|stype-|voicetype-
QCC	num	cat-num|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
QCC	num	cat-num|gen-any|num-pl|pers-|case-any|vib-|tam-|stype-|voicetype-
QCC	num	cat-num|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
QCC	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-any|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-any|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-f|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-f|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-f|num-pl|pers-|case-|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-f|num-sg|pers-|case-o|vib-0_तक|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-f|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-f|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-m|num-any|pers-|case-|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-m|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-m|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-m|num-pl|pers-|case-|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-m|num-sg|pers-any|case-d|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-m|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
QF	adj	cat-adj|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
QF	adv	cat-adv|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
QF	avy	cat-avy|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
QF	avy	cat-avy|gen-any|num-any|pers-|case-|vib-|tam-|stype-|voicetype-
QF	avy	cat-avy|gen-f|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
QF	avy	cat-avy|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
QF	avy	cat-avy|gen-f|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
QF	avy	cat-avy|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
QF	avy	cat-avy|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
QF	avy	cat-avy|gen-m|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
QF	avy	cat-avy|gen-|num-pl|pers-|case-|vib-|tam-|stype-|voicetype-
QF	avy	cat-avy|gen-|num-|pers-|case-o|vib-0_का|tam-|stype-|voicetype-
QF	avy	cat-avy|gen-|num-|pers-|case-o|vib-|tam-|stype-|voicetype-
QF	avy	cat-avy|gen-|num-|pers-|case-|vib-0_का|tam-|stype-|voicetype-
QF	avy	cat-avy|gen-|num-|pers-|case-|vib-0_के|tam-|stype-|voicetype-
QF	avy	cat-avy|gen-|num-|pers-|case-|vib-0_तक|tam-|stype-|voicetype-
QF	avy	cat-avy|gen-|num-|pers-|case-|vib-0_में_से|tam-|stype-|voicetype-
QF	avy	cat-avy|gen-|num-|pers-|case-|vib-0_से|tam-|stype-|voicetype-
QF	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
QF	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0_का|tam-0|stype-|voicetype-
QF	n	cat-n|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
QF	num	cat-num|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
QF	num	cat-num|gen-m|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
QF	num	cat-num|gen-m|num-pl|pers-|case-|vib-|tam-|stype-|voicetype-
QF	num	cat-num|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
QF	num	cat-num|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
QF	num	cat-num|gen-m|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
QF	pn	cat-pn|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
QFC	adj	cat-adj|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
QFC	adj	cat-adj|gen-m|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
QFC	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
QFC	num	cat-num|gen-m|num-pl|pers-|case-|vib-|tam-|stype-|voicetype-
QO	_	cat-_|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
QO	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
QO	adj	cat-adj|gen-f|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
QO	adj	cat-adj|gen-f|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
QO	adj	cat-adj|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
QO	adj	cat-adj|gen-f|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
QO	adj	cat-adj|gen-m|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
QO	adj	cat-adj|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
QO	adj	cat-adj|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
QO	n	cat-n|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
QO	num	cat-num|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
QO	num	cat-num|gen-any|num-pl|pers-|case-any|vib-|tam-|stype-|voicetype-
QO	num	cat-num|gen-any|num-pl|pers-|case-o|vib-0_का|tam-|stype-|voicetype-
QO	num	cat-num|gen-any|num-pl|pers-|case-o|vib-0_से|tam-|stype-|voicetype-
QO	num	cat-num|gen-f|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
QO	num	cat-num|gen-f|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
QO	num	cat-num|gen-f|num-sg|pers-o|case-|vib-|tam-|stype-|voicetype-
QO	num	cat-num|gen-f|num-sg|pers-|case-any|vib-|tam-|stype-|voicetype-
QO	num	cat-num|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
QO	num	cat-num|gen-f|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
QO	num	cat-num|gen-m|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
QO	num	cat-num|gen-m|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
QO	num	cat-num|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
QO	num	cat-num|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
QO	num	cat-num|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
RB	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
RB	adj	cat-adj|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
RB	adj	cat-adj|gen-any|num-any|pers-|case-|vib-|tam-|stype-|voicetype-
RB	adv	cat-adv|gen-|num-|pers-|case-o|vib-|tam-|stype-|voicetype-
RB	adv	cat-adv|gen-|num-|pers-|case-|vib-0_पर|tam-|stype-|voicetype-
RB	adv	cat-adv|gen-|num-|pers-|case-|vib-0_में|tam-|stype-|voicetype-
RB	adv	cat-adv|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
RB	adv	cat-adv|gen-|num-|pers-|case-|vib-कर|tam-kara|stype-|voicetype-
RB	avy	cat-avy|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
RB	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
RB	n	cat-n|gen-m|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
RB	n	cat-n|gen-m|num-pl|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
RB	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
RB	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
RB	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
RB	num	cat-num|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
RB	pn	cat-pn|gen-|num-|pers-|case-d|vib-|tam-|stype-|voicetype-
RB	pn	cat-pn|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
RB	psp	cat-psp|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
RB	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
RB	v	cat-v|gen-any|num-any|pers-any|case-|vib-कर|tam-kara|stype-|voicetype-
RBC	adv	cat-adv|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
RBC	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
RBC	num	cat-num|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
RBC	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
RDP	adj	cat-adj|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
RDP	adj	cat-adj|gen-any|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
RDP	adj	cat-adj|gen-any|num-any|pers-|case-|vib-|tam-|stype-|voicetype-
RDP	adj	cat-adj|gen-f|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
RDP	adj	cat-adj|gen-f|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
RDP	adj	cat-adj|gen-f|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
RDP	adj	cat-adj|gen-f|num-pl|pers-|case-|vib-|tam-|stype-|voicetype-
RDP	adj	cat-adj|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
RDP	adj	cat-adj|gen-m|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
RDP	adj	cat-adj|gen-m|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
RDP	adj	cat-adj|gen-m|num-sg|pers-|case-o|vib-|tam-|stype-|voicetype-
RDP	adj	cat-adj|gen-m|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
RDP	adv	cat-adv|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
RDP	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
RDP	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
RDP	n	cat-n|gen-f|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
RDP	n	cat-n|gen-m|num-pl|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
RDP	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
RDP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
RDP	nst	cat-nst|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
RDP	nst	cat-nst|gen-m|num-sg|pers-3|case-o|vib-|tam-|stype-|voicetype-
RDP	num	cat-num|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
RDP	num	cat-num|gen-any|num-any|pers-|case-o|vib-|tam-|stype-|voicetype-
RDP	pn	cat-pn|gen-any|num-pl|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
RDP	pn	cat-pn|gen-f|num-pl|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
RDP	pn	cat-pn|gen-m|num-any|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
RDP	pn	cat-pn|gen-m|num-any|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
RDP	pn	cat-pn|gen-m|num-sg|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
RDP	pn	cat-pn|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
RDP	punc	cat-punc|gen-any|num-any|pers-any|case-|vib-0|tam-0|stype-|voicetype-
RDP	punc	cat-punc|gen-any|num-any|pers-|case-any|vib-|tam-|stype-|voicetype-
RDP	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
RDP	unk	cat-unk|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
RDP	v	cat-v|gen-any|num-any|pers-any|case-|vib-0|tam-0|stype-|voicetype-
RDP	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ता|tam-wA|stype-|voicetype-
RDP	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ता|tam-wA|stype-|voicetype-
RDP	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ता|tam-wA|stype-|voicetype-
RP	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
RP	adj	cat-adj|gen-any|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
RP	adj	cat-adj|gen-f|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
RP	adv	cat-adv|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
RP	avy	cat-avy|gen-any|num-any|pers-any|case-|vib-0|tam-0|stype-|voicetype-
RP	avy	cat-avy|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
RP	avy	cat-avy|gen-f|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
RP	avy	cat-avy|gen-m|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
RP	avy	cat-avy|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
RP	avy	cat-avy|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
RP	avy	cat-avy|gen-m|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
RP	avy	cat-avy|gen-|num-|pers-|case-|vib-0_का|tam-|stype-|voicetype-
RP	avy	cat-avy|gen-|num-|pers-|case-|vib-0_जैसा|tam-|stype-|voicetype-
RP	avy	cat-avy|gen-|num-|pers-|case-|vib-0_में|tam-|stype-|voicetype-
RP	avy	cat-avy|gen-|num-|pers-|case-|vib-0_वाला|tam-|stype-|voicetype-
RP	avy	cat-avy|gen-|num-|pers-|case-|vib-0_से|tam-|stype-|voicetype-
RP	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
RP	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
RP	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
RP	psp	cat-psp|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
SYM	_	cat-_|gen-punc|num-|pers-|case-|vib-|tam-|stype-|voicetype-
SYM	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
SYM	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
SYM	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
SYM	n	cat-n|gen-m|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
SYM	psp	cat-psp|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
SYM	punc	cat-punc|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
SYM	punc	cat-punc|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
SYM	punc	cat-punc|gen-|num-|pers-|case-|vib-0|tam-|stype-|voicetype-
SYM	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-declarative'>|voicetype-
SYM	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-declarative'>|voicetype-active
SYM	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-declarative'>|voicetype-passive
SYM	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-declarative|voicetype-active
SYM	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-imperative'>|voicetype-passive
SYM	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
SYM	s	cat-s|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
SYM	sym	cat-sym|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
SYM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
UNK	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
UNK	unk	cat-unk|gen-|num-|pers-|case-o|vib-|tam-|stype-|voicetype-
UNK	unk	cat-unk|gen-|num-|pers-|case-|vib-0_का|tam-|stype-|voicetype-
UNK	unk	cat-unk|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
UNKC	unk	cat-unk|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
VAUX	_	cat-_|gen-any|num-any|pers-any|case-|vib-0|tam-0|stype-|voicetype-
VAUX	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-declarative'>|voicetype-active
VAUX	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
VAUX	n	cat-n|gen-any|num-any|pers-any|case-|vib-0|tam-0|stype-|voicetype-
VAUX	n	cat-n|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
VAUX	pn	cat-pn|gen-f|num-sg|pers-3|case-|vib-0|tam-0|stype-|voicetype-
VAUX	psp	cat-psp|gen-f|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
VAUX	psp	cat-psp|gen-m|num-pl|pers-|case-|vib-|tam-|stype-|voicetype-
VAUX	psp	cat-psp|gen-m|num-sg|pers-3h|case-|vib-0|tam-0|stype-|voicetype-
VAUX	psp	cat-psp|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
VAUX	punc	cat-punc|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
VAUX	v	cat-v|gen-3|num-sg|pers-3|case-|vib-है|tam-hE|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-any|pers-3|case-|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-any|pers-3|case-|vib-एं|tam-eM|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-any|pers-any|case-0|vib-ना|tam-nA|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-any|pers-any|case-d|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-any|pers-any|case-d|vib-ना|tam-nA|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना|tam-nA|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-any|pers-any|case-|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-any|pers-any|case-|vib-एं|tam-eM|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-any|pers-any|case-|vib-कर|tam-kara|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-any|pers-any|case-|vib-ना|tam-nA|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-any|pers-any|case-|vib-ने|tam-ne|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-any|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-any|pers-any|case-|vib-या१|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-any|pers-|case-any|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-pl|pers-1|case-|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-pl|pers-1|case-|vib-एं|tam-eM|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-pl|pers-1|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-pl|pers-1|case-|vib-है|tam-hE|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-pl|pers-3h|case-|vib-है|tam-hE|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-pl|pers-3|case-any|vib-है|tam-hE|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-pl|pers-3|case-|vib-एं|tam-eM|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-pl|pers-3|case-|vib-था|tam-WA|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-pl|pers-3|case-|vib-है|tam-hE|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-pl|pers-3|case-|vib-हैं|tam-hEM|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-pl|pers-any|case-|vib-एं|tam-eM|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-pl|pers-any|case-|vib-है|tam-hE|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-pl|pers-|case-3|vib-है|tam-hE|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-1|case-|vib-ऊँ|tam-UZ|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-1|case-|vib-है|tam-hE|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-ए|tam-e|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-एं|tam-eM|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-है|tam-hE|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-2|case-|vib-है|tam-hE|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-एं|tam-eM|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-है|tam-hE|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_सक+गा|tam-0|stype-declarative'>|voicetype-active
VAUX	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0|tam-hE|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-3|case-|vib-एं|tam-eM|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-3|case-|vib-सै|tam-sE|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-3|case-|vib-है|tam-hE|stype-declarative'>|voicetype-active
VAUX	v	cat-v|gen-any|num-sg|pers-3|case-|vib-है|tam-hE|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-3|case-|vib-है|tam-hai|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-3|case-|vib-है|tam-|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-any|case-|vib-एं|tam-eM|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-any|case-|vib-ना|tam-nA|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-any|num-sg|pers-any|case-|vib-है|tam-hE|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-any|pers-any|case-|vib-ना|tam-nA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-any|pers-any|case-|vib-या1|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-pl|pers-3|case-|vib-गा|tam-gA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-pl|pers-3|case-|vib-ता|tam-wA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-pl|pers-3|case-|vib-था|tam-WA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या१|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-pl|pers-any|case-|vib-ता|tam-wA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-pl|pers-any|case-|vib-था|tam-WA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या1|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या१|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-1|case-|vib-गा|tam-gA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-2h|case-|vib-गा|tam-gA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-गा|tam-gA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-ता|tam-wA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-था|tam-WA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-या१|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-3|case-any|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-3|case-|vib-|tam-|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-3|case-|vib-गा|tam-gA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ता|tam-wA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-3|case-|vib-था|tam-WA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या१|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-3|case-|vib-है|tam-hE|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-any|case-|vib-|tam-|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-any|case-|vib-गा|tam-gA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ता|tam-wA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-any|case-|vib-था|tam-WA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ना|tam-nA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या1|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या१|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या१|tam-ya1|stype-|voicetype-
VAUX	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या१|tam-|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-3|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना|tam-nA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-any|pers-any|case-|vib-ना|tam-nA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-any|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-1|case-|vib-गा|tam-gA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-1|case-|vib-ता|tam-wA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-1|case-|vib-था|tam-WA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-1|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-2|case-|vib-गा|tam-gA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-3|case-|vib-एं|tam-eM|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-3|case-|vib-गा|tam-gA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ता|tam-wA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-3|case-|vib-था|tam-WA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ना|tam-nA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या१|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-3|case-|vib-है|tam-hE|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-any|case-|vib-एं|tam-eM|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-any|case-|vib-गा|tam-gA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ता|tam-wA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-any|case-|vib-था|tam-WA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ना|tam-nA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या1|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या१|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या१|tam-|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-|case-any|vib-या१|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-1|case-|vib-गा|tam-gA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-1|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-2h|case-|vib-ए|tam-e|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-2h|case-|vib-गा|tam-gA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-2h|case-|vib-ता|tam-wA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3h|case-d|vib-|tam-|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-एं|tam-eM|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-गा|tam-gA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-ता|tam-wA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-था|tam-WA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या1|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या१|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-है|tam-hE|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3|case-any|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-declarative'>|voicetype-active
VAUX	v	cat-v|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3|case-|vib-एं|tam-eM|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3|case-|vib-गा|tam-gA|stype-declarative'>|voicetype-active
VAUX	v	cat-v|gen-m|num-sg|pers-3|case-|vib-गा|tam-gA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ता|tam-wA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3|case-|vib-था|tam-WA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना|tam-nA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+गा|tam-yA|stype-declarative'>|voicetype-active
VAUX	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VAUX	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या१|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-any|case-o|vib-ना|tam-nA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-any|case-|vib-एं|tam-eM|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-any|case-|vib-गा|tam-gA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ता|tam-wA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-any|case-|vib-था|tam-WA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-any|case-|vib-था|tam-|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना|tam-nA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या1|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या1|tam-yA1|stype-|voicetype-passive
VAUX	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-active
VAUX	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या१|tam-yA1|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या१|tam-yA1|stype-|voicetype-passive
VAUX	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या१|tam-ya1|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-any|case-|vib-है|tam-hAi|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-|case-d|vib-0|tam-0|stype-|voicetype-
VAUX	v	cat-v|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
VAUX	v	cat-v|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
VGF	_	cat-_|gen-|num-|pers-|case-|vib-0_का|tam-|stype-declarative'>|voicetype-active
VM	_	cat-_|gen-punc|num-|pers-|case-|vib-|tam-|stype-|voicetype-
VM	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-declarative'>|voicetype-
VM	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-declarative'>|voicetype-active
VM	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-declarative'>|voicetype-passive
VM	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-declarative|voicetype-
VM	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-declarative|voicetype-active
VM	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-imperative'>|voicetype-active
VM	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-interrogative'>|voicetype-active
VM	_	cat-_|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
VM	adj	cat-adj|gen-m|num-pl|pers-3|case-|vib-0_पड़+ता_है|tam-|stype-declarative'>|voicetype-active
VM	any	cat-any|gen-any|num-sg|pers-3|case-ना|vib-nA_के_बाद|tam-|stype-|voicetype-
VM	any	cat-any|gen-any|num-sg|pers-any|case-o|vib-ना_वाला|tam-nA|stype-|voicetype-
VM	any	cat-any|gen-m|num-pl|pers-o|case-ना|vib-nA_वाला_का|tam-|stype-|voicetype-
VM	n	cat-n|gen-any|num-any|pers-any|case-o|vib-ना_के_लिए|tam-nA|stype-|voicetype-
VM	n	cat-n|gen-any|num-sg|pers-any|case-o|vib-ना_का|tam-nA|stype-|voicetype-
VM	n	cat-n|gen-f|num-sg|pers-3|case-d|vib-0_सक+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	n	cat-n|gen-f|num-sg|pers-3|case-|vib-0_दे+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	n	cat-n|gen-f|num-sg|pers-3|case-|vib-0_पा+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	n	cat-n|gen-m|num-sg|pers-3|case-|vib-ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	psp	cat-psp|gen-any|num-pl|pers-3|case-|vib-या|tam-yA|stype-|voicetype-
VM	psp	cat-psp|gen-any|num-pl|pers-any|case-o|vib-ना_का|tam-nA|stype-|voicetype-
VM	psp	cat-psp|gen-f|num-sg|pers-3|case-o|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-3h|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-3|case-|vib-कर|tam-kara|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-3|case-|vib-ता|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-3|case-|vib-है|tam-hE|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-0|vib-ना_के_बावजूद|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-0|vib-ना_के_लिए|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-0|vib-ना_से|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-0|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-d|vib-0_दे+ना|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-d|vib-0_पा+ना|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-d|vib-ना_संबंधी|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-d|vib-ना|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-d|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-0_के_कारण|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-0_के|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-0_जा+ना_पर|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-0_में|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-0|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ता_में|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ता_वक्त|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ता_समय|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_का_बारे_में|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_का|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_अलावा|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_खिलाफ|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_चलते|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_तहत|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_नाते|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_प्रति|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_बजाए|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_बजाय|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_बदले|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_बाबत|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_बारे_में|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_बावजूद|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_मद्देनजर|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_लिए+या|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_लिए|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_ले|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_वास्ते|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के_सिवा|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_के|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_को|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_चाहिए|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_तक_पर|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_तक|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_दे+ना_के_बारे_में|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_पर|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_बाद|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_में|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_लायक|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_वाला_के_खिलाफ|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_वाला_के_बारे_में|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_वाला_के_लिए|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_वाला_के_विरुद्ध|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_वाला|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_संबंधी|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_संबधी|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_समेत|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_सहित|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_से_लेकर|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_से|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_हेतु|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ने_के_लिए|tam-ne|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ने_को|tam-ne|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-o|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_आ+ना_से|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_आना+ना|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_कर|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_जा+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_जा+एं|tam-0|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_जा+कर|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_जा+ना_के_लिए|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_जा+ना_के|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_जा+ना_को|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_जा+ना_चाहिए|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_जा+ना_पर|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_जा+ना_में|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_जा+ना_से|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_जा+ना|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_जान+ना_से|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_डाल+ना|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_दे+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_दे+ना_के_बावजूद|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_दे+ना_से|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_दे+या_जा+ना_चाहिए|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_दे|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_पा+ना_पर|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_पा+ना_में|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_पा+ना|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_फूंक+कर|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_रह+या|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_ले+एं|tam-0|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_ले+ना_पर|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_ले+ना|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_ले|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_सक+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_से|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0|tam-0|stype-declarative|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0|tam-0|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0|tam-0|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-0|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-एं|tam-eM|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-एं|tam-eM|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-कर|tam-kara|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-कर|tam-kara|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-कर|tam-kara|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-कर|tam-kar|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-के|tam-ke|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-ता_वक्त|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-ता_समय|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-ता|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-ना_चाहिए|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-ना_दे_कर|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-ना_से|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-ना|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-या_कर|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-या_जा+ना_को|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-या_जा+ना_चाहिए|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-या_जा+ना_चाहिए|tam-yA|stype-imperative'>|voicetype-passive
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-या_जा+ना_पर|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-या_जा+ना_संबंधी|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-या_जा+ना|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-या_जा+या१|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-या_जा_सक+एं|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-या_रख+ना|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-|case-any|vib-0|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-any|pers-|case-any|vib-कर|tam-kara|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-|case-any|vib-कर|tam-kar|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-|case-o|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-any|pers-|case-|vib-ता|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-1|case-|vib-0_दे+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-1|case-|vib-0_दे+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-1|case-|vib-0_दे|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-1|case-|vib-0_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-1|case-|vib-0_ले+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-1|case-|vib-0_सक+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-1|case-|vib-0_सक+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-1|case-|vib-एं|tam-eM|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-1|case-|vib-गा|tam-gA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-1|case-|vib-है|tam-hE|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-2|case-|vib-ओ|tam-ao|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-2|case-|vib-ता_रह_जा+गा|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-o|vib-ना_वाला|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_आ+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_चुक+एं_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_चुक+एं|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_चुक+या|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_जा+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_जा+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_जा+या१|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_डाल+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_दे+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_दे+एं|tam-0|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_दे+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_निकल+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_पड+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_पा+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_बैठ+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_रह+एं|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_रह+या|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_ले+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_ले+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_सक+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_सक+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-0_सक+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-o_जा+या|tam-o|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-एं_जा_रह+एं_है|tam-eM|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-एं|tam-eM|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-एं|tam-eM|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-एं|tam-eM|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-ता_जा_रह+या_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-ना_जा+ना_वाला|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-ना_दे+एं|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-ना_दे+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-ना_लग+एं|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-ना_लग+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या_जा+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या_जा+ना_का|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या_जा+ना_वाला|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या_जा+ना_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या_जा_रह+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या_जा_सक+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या_जा_सक+एं|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या_जा_सक+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या_जा_सक+गा|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या_जा_सक+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या_रह+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या_रह+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या_हो+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या_हो+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-है|tam-hE|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-है|tam-hE|stype-declarative|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-3|case-|vib-हैं|tam-hEM|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-any|vib-0_जा+या१|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-d|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-o|vib-ना_का|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-o|vib-ना_के|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-o|vib-ना_चाहिए_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-o|vib-ना_जैसा|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-o|vib-ना_दे+ना_वाला|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-o|vib-ना_वाला|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-o|vib-ना_वाली|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-o|vib-ने_का|tam-ne|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_आ+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_आ+या|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_उठ+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_कर+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_चुक+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_चुक+या|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_जा+ना_का|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_जा+ना_पड+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_जा+या1|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_जा+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_जा+या|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_जा+या|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_जा+या१|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_जा+या१|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_जा+या१|tam-0|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_जा+या१|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_डाल+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_दे+एं|tam-0|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_दे+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_दे+या_जा+ना_का|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_दे+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_पड+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_पड़+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_पहुंच+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_पा+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_पा+ना_वाला|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_पा+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_पड़+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_रह+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_रह+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_रह+या|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_ले+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_ले_जा+या१|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_सक+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_सक+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_सक+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-0_हो_जा+या१|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-एं|tam-eM|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-एं|tam-eM|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-कर_आ+या|tam-kara|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-कर_जा+या१|tam-kara|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-ता_रह_जा+या१|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-था|tam-WA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-ना_लग+ता|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-ना_लग+या_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-ना_लग+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_जा+ना_का|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_जा+ना_चाहिए_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_जा+ना_तक|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_जा+ना_पर|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_जा+ना_वाला|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_जा+ना_वाली|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_जा+ना_से|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_जा+या१|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_जा_रह+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_जा_रह+या|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_जा_रह+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_जा_सक+ता|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_जा_सक+ता|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_जान+ना_वाला|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_दे+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_रह+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_समा_रह+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_हो+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या_हो+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-है|tam-hE|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-pl|pers-any|case-|vib-है|tam-hE|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-1h|case-|vib-है|tam-hE|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-1|case-|vib-0_दे+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-1|case-|vib-0_सक+ऊँ|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-1|case-|vib-0_सक+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-1|case-|vib-है|tam-hE|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-0_जा+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-0_जा+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-0_दे+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-0_दे+एं|tam-0|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-0_ले+ए|tam-0|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-0_ले+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-0_ले+एं|tam-0|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-0_सक+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-0_सक+ता|tam-0|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-0_सक+ता|tam-0|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-0|tam-0|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-एं|tam-eM|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-एं|tam-eM|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-ओ|tam-ao|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-ना_चाह+एं|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-ना_चाह+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2h|case-|vib-है|tam-hE|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2|case-|vib-एं|tam-eM|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2|case-|vib-ओ|tam-ao|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-2|case-|vib-है|tam-hE|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-o|vib-0_आ+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-o|vib-ना_का|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3h|case-o|vib-ना_वाला|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_आ+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_चुक+एं_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_चुक+एं|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_चुक+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_चुक+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_चुक+या|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_जा+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_जा+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_जा+या1|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_जा+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_जा+या१|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_जा_रह+या|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_दे+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_दे+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_पहुंचे+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_पा+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_पा+गा|tam-0|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_पा+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_पड़+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_बैठ+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_रह+एं_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_रह+एं|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_रह+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_रह+या|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_ले+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_ले+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_सक+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_सक+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_सक+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_सक+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-0_सक+या|tam-0|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-एं|tam-eM|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-एं|tam-eM|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-एं|tam-eM|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-कर_रो+या|tam-kara|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-ना_जा+या१|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-ना_दे+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-ना_लग+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-या_जा+ना_वाला|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-या_जा+या1|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-या_दे+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-या_रह+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-है|tam-hE|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-है|tam-hE|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-3h|case-|vib-है|tam-hE|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-any|vib-एं|tam-eM|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-any|vib-ना_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-any|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-d|vib-ना_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-d|vib-ना_हो+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-0_के_बाद|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-ना_का_बाद|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-ना_का|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-ना_के_करीब|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-ना_के_दौरान|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-ना_के_निकट|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-ना_के_पहले|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-ना_के_पीछे|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-ना_के_बाद|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-ना_के_बीच|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-ना_के_साथ|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-ना_वाला+या|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-ना_वाला|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-ना_से_पहले|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-ना_से_पूर्व|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-ना_सै|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-ने_के_बाद|tam-ne|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-o|vib-या_जा+ना_के_बाद|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_आ+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_उठा_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_उठा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_कर|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_के_बाद|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_चुक+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_चुक+या|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_चुका_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_जा+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_जा+एं|tam-0|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_जा+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_जा+गा|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_जा+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_जा+ना_के_बाद|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_जा+या१|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_जा+या१|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_जा_सक+एं|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_जा_सक+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_डाल+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_दिया+या|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_दिया|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_दे+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_दे+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_दे+ना_के_बाद|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_दे+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_दे|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_पहुंच+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_पा+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_पा+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_पा+ना_के_बाद|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_पा+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_पाऊंगा+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_रह+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_रह+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_रह+या|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_ले+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_ले+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_ले+या_जा+ना_के_बाद|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_ले+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_सक+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_सक+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_सक+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_सक+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-0|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-एं|tam-eM|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-एं|tam-eM|stype-declarative'>|voicetype-imperative
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-एं|tam-eM|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-एं|tam-eM|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-ओ|tam-ao|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-ता_हो+या|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-ता|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-ना_चाहिए_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-ना_जा_रह+या|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-ना_दे+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-ना_पा+एं|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-ना_लग+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-ना_लग+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-ना_वाला|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-ना_हो+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_आ_रह+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_का|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा+ना_का|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा+ना_के_बाद|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा+ना_को|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा+ना_चाहिए_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा+ना_दे+ना_का|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा+ना_पर|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा+ना_लगा_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा+ना_वाला|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा+ना_से|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा+ना_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा+ने_का|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा+या१|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा_चुका_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा_चुका_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा_रह+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा_सक+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा_सक+एं|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा_सक+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा_सक+गा|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा_सक+ता|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_जा_सक+ता|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_पड_जा+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_रख+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_रह+ना_को|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_रह_सक+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_समा_रह+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-है|tam-hE|stype-declarartive'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-है|tam-hE|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-है|tam-hE|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-है|tam-hE|stype-declarative|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-है|tam-hE|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-है|tam-hE|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-3|case-|vib-है|tam-hE|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-0|vib-ना_का|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-any|vib-0_जा+या१|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-any|vib-0_दे+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-any|vib-0_ले+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-any|vib-या_जा+ना_वाला|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-d|vib-0_दे+ना_का|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-d|vib-ना_पड+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-d|vib-ना_लग_जा+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-0_पा+ना_का|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-0_ले+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-ना_का|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-ना_के_जैसा|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-ना_के_बाद|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-ना_के_समय|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-ना_जा+ना_वाला|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-ना_जैसा|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-ना_तक_का|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-ना_दे+ता|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-ना_दे+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-ना_रह+या|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-ना_लग+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-ना_वाला|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-ना_वाली|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-ने_का|tam-ne|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-या_जा+ना_का|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-या_जा+ना_तक|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-या_जा+ना_से|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_आ+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_उठ+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_का|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_गिरा+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_चुक+या|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_जा+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_जा+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_जा+ना_का|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_जा+ना_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_जा+या1|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_जा+या1|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_जा+या_जा_रह+या|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_जा+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_जा+या|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_जा+या|tam-0|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_जा+या|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_जा+या१|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_जा+या१|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_जा+या१|tam-0|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_जा_पा+या|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_जा_सक+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_डाल+ना_का|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_डाल+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_दिया|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_दे+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_दे+ना_का|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_दे+ना_पड़+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_दे+ना_वाला|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_दे+ना|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_दे+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_दे+या|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_धमक+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_निकाल+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_पड+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_पहुँच+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_पहुंच+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_पा+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_पा+ना|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_पा+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_पड़+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_फेंक+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_बैठ+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_रह+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_रह+या|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_लिया+या_जा+ना_चाहिए_था|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_ले+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_ले+ना_का|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_ले+या_जा+ना_का|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_ले+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_सक+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_सक+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_सक+ता|tam-0|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_सक+ना_का|tam-0|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_सक+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-0_हो+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-o_दे+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-एं|tam-eM|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-एं|tam-eM|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-कर_जा_रह+या|tam-kara|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-कर_हो+या|tam-kara|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-ता_हो+एं|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-ता_हो+या|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-ता|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-ना_का|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-ना_चाहिए_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-ना_जा+ना_वाला|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-ना_जा_रह+या|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-ना_जान+ना_वाला|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-ना_दे+ता|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-ना_दे+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-ना_पड+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-ना_पड़+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-ना_लग+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_आ_रह+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा+ना_का|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा+ना_को|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा+ना_चाहिए_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा+ना_चाहिए_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा+ना_तक|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा+ना_पर|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा+ना_में|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा+ना_वाला|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा+ना_से|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा+या1|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा+या१|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा_रह+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा_रह+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा_सक+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा_सक+एं|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा_सक+ता|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा_सक+ता|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा_सक+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जा_सक+या|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जान+ना_का|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जान+ना_पर|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_जान+ना_वाला|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_दे+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_रख+ना_का|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_रख+ना_में|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_रख+ना|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_रख+या_जा+ना_का|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_रख+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_रह+ना_का|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_रह+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_रह_जा+या१|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_ले+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_समा_रह+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-any|num-sg|pers-any|case-|vib-या_हो+ना_का|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-|case-o|vib-ना_का|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-any|num-sg|pers-|case-o|vib-ना_वाला|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-f|num-any|pers-3|case-o|vib-ना_वाला|tam-nA_vAlA|stype-|voicetype-
VM	v	cat-v|gen-f|num-any|pers-any|case-0|vib-ना_का_बजाय|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-f|num-any|pers-any|case-d|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-f|num-any|pers-any|case-o|vib-ना_का_खातिर|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-f|num-any|pers-any|case-o|vib-ना_का_जगह|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-f|num-any|pers-any|case-o|vib-ना_का_बजाय|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-f|num-any|pers-any|case-o|vib-ना_का_बाबत|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-f|num-any|pers-any|case-o|vib-ना_का_वजह_से|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-f|num-any|pers-any|case-o|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-0_चुक+या_हो|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-0_जा+ना_का_वजह_से|tam-0|stype-|voicetype-
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-0_जा+ना_चाहिए|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-0_जा+या१_थी&COMMA|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-0_जा+या१_हो|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-0_दे+या_जा+ना_चाहिए|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-0_पा+ना_का_वजह_से|tam-0|stype-|voicetype-
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-0_पा+या_हो|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-0_रह+या_हो|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-0_ले+ना_चाहिए|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-ता_हो|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-ना_चाहिए|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-ना_चाहिए|tam-nA|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-ना_चाहिए|tam-nA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-या_जा+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-या_जा+ना_चाहिए|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-या_जा+ना_चाहिए|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-या_जा+ना|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-या_जा+या1_हो|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-या_जाना_चाहिए|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-any|pers-any|case-|vib-या_हो|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-any|pers-|case-o|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_चुक+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_जा+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_जा+या1_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_जा+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_जा+या१_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_जा+या१_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_दे+या_जा+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_दे+या_जा+या१_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_दे+या_जा+या१_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_दे+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_दे+या_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_दे+या_है|tam-0|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_पा+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_पा_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_रह+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_रह+या_हैं+है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_रह+या_हो|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_ले+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_सक+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_सक+ता_है|tam-0|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-0_सक+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-गा|tam-gA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-ता_जा_रह+या_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-ता_रह+ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-ता_रह+या_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-ता|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-था|tam-WA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-ना_पड+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-ना_पड़+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-ना_लग+या_है|tam-nA|stype-declarartive'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-ना_लग+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-ना_हो+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-ना_हो+गा|tam-nA|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_जा+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_जा+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_जा+गा|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_जा+ता_रह+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_जा+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_जा+ता_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_जा+या1_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_जा+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_जा+या१_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_जा+या१_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_जा_चुक+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_जा_रह+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_जा_रह+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_जा_सक+ता_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_दे+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_रह+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_सक+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_हो+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या_हो+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-3|case-|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-f|num-pl|pers-any|case-o|vib-ता|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-0_कर+ता_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-0_दे+या_जा+या1|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-0_दे+या_जा+या१_था|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-0_दे+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-0_पा+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-0_रह+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-0_ले+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-0|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-ता_था|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-ता|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-ता|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-था|tam-WA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-ना_जा_रह+या_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-ना_पड़+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_जा+ना_वाला_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_जा+या1_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_जा+या1_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_जा+या1|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_जा+या1|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_जा+या_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_जा+या१_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_जा+या१_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_जा+या१|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_जा_रह+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_था|tam-yA|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_रह+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_हो+ना_की_वजह_से|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_हो+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_हो+या_हो|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या१_था|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-pl|pers-|case-o|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-1|case-|vib-0_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-1|case-|vib-0_सक+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-1|case-|vib-गा|tam-gA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-1|case-|vib-ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-1|case-|vib-या_है+ऊँ|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-1|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-1|case-गा|vib-gA|tam-|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-2|case-|vib-या_जा+या१_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3h|case-any|vib-0_जा+या१_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-0_उठ+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-0_चुक+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-0_जा+या1_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-0_जा+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-0_जा+या१_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-0_बैठ+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-0_रह+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-0_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-0_सक+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-गा|tam-gA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-ता_रह+ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-ता_रह+या_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-ता_रह+या|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-ता|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-था|tam-WA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-ना_वाला_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-ना_वाला_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-या_दे+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-या_रह+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-या_हो+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-या_हो+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3h|case-|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-3|case-any|vib-0_रख+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-any|vib-0_ले+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-d|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-3|case-d|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-o|vib-ना_जा_रह+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-o|vib-ना_वाला_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-o|vib-ना_वाला|tam-nA_vAlA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_आ+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_उठ+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_उठ+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_चुक+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_चुक+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_चुक+या_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_जा+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_जा+या1_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_जा+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_जा+या१_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_जा+या१_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_जा+या१_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_दे+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_दे+या_जा+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_दे+या_जा+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_दे+या_जा+गा|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_दे+या_जा+या1_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_दे+या_जा+या१_था|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_दे+या_जा+या१_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_दे+या_जा+या१_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_दे+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_पहुंच+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_पा+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_पा+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_पा_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_पाई_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_पड़+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_रख+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_रह+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_रह+या_है|tam-0|stype-declarartive'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_रह+या_है|tam-0|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_ले+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_ले+या_जा+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_ले+या_जा+या1_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_ले+या_जा+या1_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_ले+या_जा+या१_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_ले+या_जा+या१_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_ले+या_जा+या१|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_ले+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_ले+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_सक+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_सक+ता_है|tam-0|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_सक+ता_है|tam-0|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_सक+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_सक+या_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-गा_है|tam-gA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-गा|tam-gA|stype-declarartive'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-गा|tam-gA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-गा|tam-gA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-गा|tam-gA|stype-declarative|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-गा|tam-gA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-गा|tam-gA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ता_जा+या१_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ता_जा_रह+या_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ता_था|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ता_रह+गा|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ता_रह+ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ता_रह+या_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ता|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ता|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-था|tam-WA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ना_जा+ता_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ना_जा_रह+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ना_जा_रह+या_है|tam-nA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ना_पड+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ना_पड+गा|tam-nA|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ना_पड+ता_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ना_पड+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ना_पड़+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ना_पड़_रह+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ना_लग+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ना_वाला_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ना_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ना_हो+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ना_हो+गा|tam-nA|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ना_हो+गा|tam-nA|stype-imperative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-ना_हो+ता_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+एं|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+गा|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+गा|tam-yA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+गा|tam-yA|stype-interrogative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+ता_रह+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+ता_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+ना_का_ओर|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+ना_का_वजह_से|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+ना_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+ना_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+या1_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+या1_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+या१_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+या१_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+या१_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा+या१|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा_चुक+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा_चुक+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा_रह+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा_रह+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा_रह+या_है|tam-yA|stype-interrogative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा_सक+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जा_सक+ता_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_जाएगी+गा|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_दे+या_जा+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_दे+या_जा+या१_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_दे_रह+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_रख+ना_हो+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_रख+या_जा+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_रह+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_रह+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_रह+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_रह+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_समा_रह+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_है|tam-yA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_हो+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या_हो+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या१|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-या१|tam-yA1|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-3|case-|vib-०_सक+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-o|vib-ना_वाला_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-o|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_चुक+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_जा+ता_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_जा+या1_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_जा+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_जा+या१_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_जा+या१_हो+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_दे+या_जा+या1_था|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_दे+या_जा+या1|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_दे+या_जा+या1|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_दे+या_जा+या१_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_दे+या_जा+या१_था|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_दे+या_जा+या१|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_दे+या_जा+या१|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_दे+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_पा+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_रह+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_रह+या_हो+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_ले+या_जा+या1_था|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_ले+या_जा+या१_था|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_ले+या_जा+या१|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_ले+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_सक+ता_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-0_सक+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ता_जा+या१|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ता_था|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ता_बन+ता_था|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ता_रह+या|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ता_हो+या|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ता|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ता|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-था|tam-WA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-था|tam-WA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-था|tam-WA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ना_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ना_दे+या_जा+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ना_दे+या_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ना_पड+या_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ना_पड+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ना_पड़+या_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ना_पड़+या_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ना_पड़+या_था|tam-nA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ना_पड़+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ना_लग+या_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ना_वाला_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ना|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_गया+या१|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+ता_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+ता|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+ना_का_बजाय|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+ना_का_बाबत|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+ना_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+या1_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+या1_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+या1|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+या1|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+या1|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+या१_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+या१_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+या१|tam-yA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+या१|tam-yA|stype-interrogative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा+या१|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा_चुक+या_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा_रह+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_जा_रह+या_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_दे+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_दे+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_दे_रह+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_पड़+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_रख+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_रह+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_रह+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_हो+ता|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_हो+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या_हो+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या|tam-yA|stype-declarative|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या|tam-yA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-f|num-sg|pers-any|case-|vib-या१|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-f|num-sg|pers-|case-o|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-3|case-|vib-ना_चाह+एं|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-3|case-|vib-या_को|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-0|vib-ना_के_कारण|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-any|vib-या_जा+ना|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-d|vib-0_पा+ना_के_कारण|tam-0|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-d|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_का_कारण|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_के_एवज_में|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_के_कारण|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_के_तौर_पर|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_के_नाते|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_के_बाद_से|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_के_संबंध_में|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_के_समय|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_के_समान|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_को|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_दे+ना_चाहिए|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_वाला_को|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_वाला_द्वारा|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_वाला_ने|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_वाला_पर|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_वाला_में|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_वाला_समय_में|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_वाला_से|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_से_पहले_तक|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-0_चुक+या_हो|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-0_जा+ना_के_कारण|tam-0|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-0_जा+ना_के_बाद_से|tam-0|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-0_जा+ना_चाहिए|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-0_जा+या१_हो|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-0_दे+ना_चाहिए|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-0_दे+या_जा+ना_चाहिए|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-0_दे+या_जा+ना_चाहिए|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-0_दे+या_जान+ना_के_कारण|tam-0|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-0_पा+ना_के_कारण|tam-0|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-0_रह+या_हो|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-ता_बन+ना|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-ता_हो|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-ना_चाह|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-ना_चाहिए|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-ना_चाहिए|tam-nA|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-ना_दे+ना_चाहिए|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-ना_दे+या_जा+ना_चाहिए|tam-nA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-ना_हो|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-या_कर|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-या_जा+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-या_जा+ना_चाहिए|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-या_जा+ना_चाहिए|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-या_जा+ना_चाहिए|tam-yA|stype-imperative'>|voicetype-passive
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-या_जा+ना_चाहिए|tam-yA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-या_जा+ना|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-या_जा+या१_हो|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-या_जान+ना|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-या_जान+या_चाहिए|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-या_रख+ना|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-या_रह+ना_चाहिए|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-या_रह+ना|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-या_हो+ना_चाहिए|tam-yA|stype-imperative'>|voicetype-passive
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-या_हो|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-any|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-any|pers-|case-any|vib-ना_चाहिए|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-1|case-|vib-0_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-1|case-|vib-0_सक+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-1|case-|vib-गा|tam-gA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-1|case-|vib-गा|tam-gA|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-1|case-|vib-ता_रह+गा|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-1|case-|vib-ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-1|case-|vib-ता_है|tam-wA|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-1|case-|vib-ना_हो+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-1|case-|vib-या_हो+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-1|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-2h|case-|vib-गा|tam-gA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3h|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-0|vib-0_जा+या१_है|tam-|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-any|vib-0_जा+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-any|vib-0_सक+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-o|vib-0_जा+या१|tam-0|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-3|case-o|vib-ना|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-o|vib-०|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_उठ+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_उठ+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_गुजर+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_चुक+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_जा+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_जा+या1_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_जा+या1_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_जा+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_जा+या_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_जा+या१_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_जा+या१_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_जा+या१_है|tam-0|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_जा+या१|tam-0|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_दे+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_दे+या_जा+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_दे+या_जा+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_दे+या_जा+गा|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_दे+या_जा+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_दे+या_जा+या1_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_दे+या_जा+या१_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_दे+या_जा+या१_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_दे+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_पड+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_पा+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_पा+ता_है|tam-0|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_पा_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_बैठ+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_रह+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_रह+या_है|tam-0|stype-Declarative'>|voicetype-Active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_रह+या_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_रहा+या_हैं+है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_ले+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_ले+या_जा+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_ले+या_जा+या१_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_ले+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0_सक+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-0|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-एं|tam-eM|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-गा|tam-gA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-गा|tam-gA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-गा|tam-gA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ता_आ+या_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ता_चल+या_जा+या१|tam-wA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ता_जा_रह+या_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ता_था|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ता_रह+एं|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ता_रह+गा|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ता_रह+ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ता_रह+या_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ता_रह+या|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ता_है|tam-wA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ता_हो|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ता|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ता|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-था|tam-WA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ना_जा_रह+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ना_पड_सक+ता_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ना_पड़+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ना_रह+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ना_लग+ता_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ना_लग+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ना_लग+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ना_वाला_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ना_वाला|tam-nA_vAlA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ना_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-ना_हो+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_आ+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+एं|tam-yA|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+एं|tam-yA|stype-imperative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+गा|tam-yA|stype-declarartive'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+गा|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+ता_रह+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+ता_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+ता_है|tam-yA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+ना_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+ना_लग+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+ना_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+या1_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+या1_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+या_चुक+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+या१_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+या१_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+या१_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+या१_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+या१_है|tam-yA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा+या१|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा_चुक+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा_चुक+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा_रह+या_है+या|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा_रह+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा_रह+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा_रह+या_हो|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा_सक+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_जा_सक+ता_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_दे+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_दे+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_दे_रह+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_पड_रह+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_पड़+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_रख+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_रख+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_रह+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_रह+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_रह+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_रह+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_सक+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_है+हैं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_है|tam-yA|stype-declarartive'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_हो+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_हो+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या_हो+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या|tam-yA|stype-declarative|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या|tam-yA|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-3|case-|vib-या१_है|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-any|vib-गा_था|tam-gA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-o|vib-ना_वाला_का|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_गिरा+या_जा+या१|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_चुक+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_चुका+या_था|tam-0|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_जा+ता_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_जा+या1_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_जा+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_जा+या१_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_दे+ता_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_दे+या_जा+या1|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_दे+या_जा+या1|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_दे+या_जा+या१|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_दे+या_जा+या१|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_दे+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_दे_रह+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_पा+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_पा_रह+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_रख+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_रह+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_रह+या_है|tam-0|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_ले+या_जा+या1|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_ले+या_जा+या१_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_ले+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_सक+ता_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_सक+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_सक+ता_है|tam-0|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-0_सक+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-एं|tam-eM|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-एं|tam-eM|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-गा|tam-gA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ता_चल+या_जा+या१|tam-wA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ता_था_जैसे|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ता_था|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ता_रह+या|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ता_हो+या_में|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ता_हो+या|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ता_हो|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ता|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ता|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-था|tam-WA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-था|tam-WA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ना_के_लिए|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ना_के_ले+या|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ना_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ना_पड+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ना_पा+ता|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ना_पड़+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ना_में|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ना_लग+या_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ना_लग+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ना_वाला_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ना_हो+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ना|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या1|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_कर+ता_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+एं|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+ना_का|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+ना_के_बावजूद|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+ना_के_लिए|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+ना_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+ना_वाला_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+या1_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+या1_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+या1|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+या1|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+या1|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+या१_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+या१_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+या१|tam-yA|stype-declarartive'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा+या१|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा_रह+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_जा_रह+या_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_पड+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_रख+ना_के_लिए|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_रह+ना_के_कारण|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_रह+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_रह+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_हो+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_हो+ता|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_हो+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_हो+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_हो+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_हो+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या_हो|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या|tam-yA|stype-declarartive'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या|tam-yA|stype-declarative|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या|tam-yA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या१_था|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या१_हो+या_था|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या१|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-pl|pers-any|case-|vib-या१|tam-yA1|stype-|voicetype-
VM	v	cat-v|gen-m|num-pl|pers-|case-o|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-1|case-|vib-0_चुक+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-1|case-|vib-0_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-1|case-|vib-0_सक+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-1|case-|vib-गा|tam-gA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-1|case-|vib-ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-1|case-|vib-ता_हो+है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-1|case-|vib-ना_जा_रह+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-1|case-|vib-या_रहू+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-1|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-2h|case-|vib-0_रह+ए_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-2h|case-|vib-0_सक+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-2h|case-|vib-एं|tam-eM|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-2h|case-|vib-गा|tam-gA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-2h|case-|vib-ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-2h|case-|vib-ना_दे+एं|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-any|vib-ना_वाला_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-o|vib-ना_वाला_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_आ+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_चुक+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_चुक+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_जा+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_जा+या1_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_जा+या१_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_जा+या१_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_दे+ता_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_दे+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_दे+या_जा+या१_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_पा+ता_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_पा+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_पड़+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_रह+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_रह+या_है|tam-0|stype-declartive'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_सक+ता_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_सक+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-गा|tam-gA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-गा|tam-gA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-गा|tam-gA|stype-declarative|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-गा|tam-gA|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-गा|tam-gA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-ता_था|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-ता_बन+या|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-ता_रह+गा|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-ता_रह+या_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-ता_रह+या|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-ता_हो+एं|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-ता_हो+या|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-ता|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-ता|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-था|tam-WA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-ना_जा+या१_हो+या_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-ना_जा_रह+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-ना_वाला_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-ना_वाला_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-ना_हो+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या1|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_आ+एं|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_आ+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_कर+ता_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_कर+ता_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_जा+एं|tam-yA|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_जा+एं|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_जा+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_जा+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_जा+या1|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_जा+या१_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_जा+या१_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_जा+या१_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_जा+या१|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_जा_रह+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_बैठ+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_रख+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_रह+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_रह+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_रह+गा|tam-yA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_रह+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_रह+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_रह+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_सक+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_सक+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_हो+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_हो+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या_हो+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या१_था|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या१_है|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या१|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-या१|tam-yA1|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-any|vib-0_जा+या1_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-any|vib-ता|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-d|vib-ता_जा_रह+या_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-d|vib-ना_पड_रह+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-d|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-d|vib-या_हो+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-o|vib-0_सक+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-o|vib-ना_के_साथ_साथ|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-o|vib-ना_जा_रह+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-o|vib-ना_वाला_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-o|vib-या_जा+ना_से_पहले|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_आ+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_गिरा+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_चुक+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_चुक+या_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_चुक+या_हो+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_जा+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_जा+ना_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_जा+या1_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_जा+या_जा+गा|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_जा+या_जा+या१|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_जा+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_जा+या_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_जा+या_हो+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_जा+या१_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_जा+या१_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_जा+या१_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_जा+या१_है|tam-0|stype-interrogative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_जा+या१_हो+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_जा+या१|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_जा_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दिखा+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दिया_जा+या१_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दे+ता_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दे+या_जा+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दे+या_जा+एं|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दे+या_जा+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दे+या_जा+गा|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दे+या_जा+ता_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दे+या_जा+या1_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दे+या_जा+या1_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दे+या_जा+या१_था|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दे+या_जा+या१_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दे+या_जा+या१_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दे+या_जा+या१|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दे+या_जाय+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दे+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दे+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दे+या_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_दे+या१_जा+या१_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_निकाल+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_पड_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_पा+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_पा+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_पा_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_पड़+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_रख+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_रह+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_रह+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_ले+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_ले+या_जा+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_ले+या_जा+एं|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_ले+या_जा+गा|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_ले+या_जा+गा|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_ले+या_जा+ता_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_ले+या_जा+या१_था|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_ले+या_जा+या१_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_ले+या_जा+या१_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_ले+या_जा+या१|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_ले+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_सक+ता_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_सक+ता_है|tam-0|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_सक+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_सक+या_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_हो+या_है|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_हो+या_है|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0|tam-0|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-एं|tam-eM|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-कर|tam-kara|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-कर|tam-kara|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-गा|tam-gA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-गा|tam-gA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-गा|tam-gA|stype-declarative|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-गा|tam-gA|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-गा|tam-gA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-गा|tam-gA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ता_आ+या_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ता_जा+ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ता_जा_रह+या_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ता_जा_रह+या_है|tam-wA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ता_रह+एं|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ता_रह+गा|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ता_रह+ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ता_रह+या_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ता_रह+या|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ता_है|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ता_है|tam-wA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ता_हो+या|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ता|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ता|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-था|tam-WA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_जा+ता_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_जा_रह+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_दे+या_जा+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_दे+या_जा+गा|tam-nA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_पड+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_पड+ता_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_पड+या_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_पड+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_पड+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_पड_रह+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_पड़+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_पड़_रह+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_पा+एं|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_पड़+एं|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_पड़+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_पड़+ता_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_पड़+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_पड़_रह+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_पड़_सक+ता_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_रह+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_रह+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_लग+या_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_लग+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_वाला_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_हो+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_हो+गा|tam-nA|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना_हो+ता_है|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_कर+गा|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_के_बाद|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+एं|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+एं|tam-yA|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+एं|tam-yA|stype-imperative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+एं|tam-yA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+एं|tam-yA|stype-interrogative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+गा|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ता_रह+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ता_रह+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ता_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ता_है|tam-yA|stype-interrogative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ना_के_कारण|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ना_के_चलते|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ना_के_दौरान|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ना_के_पीछे|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ना_के_बाद_से|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ना_के_बाद|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ना_के_बारे_में|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ना_के_बावजूद|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ना_के_मद्देनजर|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ना_के_लिए|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ना_के_समय|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ना_लग+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ना_लगा+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ना_से_पहले|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ना_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+ना_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+या1_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+या1_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+या१_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+या१_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+या१_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+या१_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+या१_है|tam-yA|stype-imperative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा+या१|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा_चुक+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा_चुका_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा_रह+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा_रह+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा_सक+ता_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा_सक+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा_सक+ता_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा_सक+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जा_सक+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_जान+ना_के_बाद|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_दे+ना_लग+या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_दे+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_दे+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_दे_रह+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_पर|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_बैठ+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_रख+ता_हो+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_रख+या_जा+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_रख+या_जा+गा|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_रह+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_रह+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_रह+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_रह+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_ले+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_सक+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_है|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_है|tam-yA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_हो+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_हो+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_हो+या_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_हो+या_हो+गा|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_हो+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या_हो_सक+ता_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या|tam-yA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या१_है|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या१_है|tam-yA1|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या१|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-या१|tam-yA1|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-3|case-|vib-है|tam-hE|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-any|vib-या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-d|vib-0_दे+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-d|vib-ना|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-d|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-o|vib-ता_वक्त|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-o|vib-ना_दे+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-o|vib-ना_पड+या_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-o|vib-ना_वाला_का|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-o|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_आ+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_करा+या_जा+या१|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_गिरा+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_चुक+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_चुक+या_हो+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_जा+ना_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_जा+या1_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_जा+या_जा+या1|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_जा+या_जा+या1|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_जा+या_जा+या१_था|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_जा+या_जा+या१|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_जा+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_जा+या_था|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_जा+या१_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_जा+या१_था|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_जा+या१_था|tam-0|stype-interrogative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_डाल+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_दिया+या_जा+या1|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_दे+या_जा+एं|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_दे+या_जा+ता_था|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_दे+या_जा+ता|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_दे+या_जा+या1_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_दे+या_जा+या1_था|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_दे+या_जा+या1|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_दे+या_जा+या1|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_दे+या_जा+या१_था|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_दे+या_जा+या१|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_दे+या_जा+या१|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_दे+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_दे+या_हो+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_निकाल+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_पा+ता_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_रख+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_रह+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_रह+या_हो+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_ले+ना_का|tam-0|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_ले+या_जा+एं|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_ले+या_जा+या1_था|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_ले+या_जा+या1|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_ले+या_जा+या1|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_ले+या_जा+या|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_ले+या_जा+या१_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_ले+या_जा+या१|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_ले+या_जा+या१|tam-0|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_ले+या_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_ले+या_हो+ता|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0_सक+ता_था|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0|tam-0|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-0|tam-0|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ए|tam-e|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-एं|tam-eM|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-एं|tam-eM|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-एं|tam-eM|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-एं|tam-eM|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-एं|tam-eM|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ता_था|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ता_था|tam-wA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ता_बच+या|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ता_रह+एं|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ता_रह+या|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ता_वक्त|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ता_समय|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ता_हो+एं|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ता_हो+या|tam-wA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ता_हो+या|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ता_हो|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ता|tam-wA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ता|tam-wA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-था|tam-WA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-था|tam-WA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_दे+या_जा+या१|tam-nA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_पड+एं|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_पड+ता|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_पड+या_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_पड+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_पड+या|tam-nA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_पड़+ता_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_पड़+या_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_पड़+एं|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_पड़+ता|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_पड़+या_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_पड़+या_था|tam-nA|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_पड़+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_पड़+या|tam-nA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_पड़+या|tam-nA|stype-imperative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_पड़_रह+या_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_लग+या|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_वाला_था|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना_हो+गा|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना|tam-nA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-ना|tam-nA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या1_था|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या1|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_कर+ता_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_का|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_के_लिए|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+एं|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+ता_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+ता_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+ता_रह+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+ता|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+ना_के_कारण|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+ना_के_बाद_से|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+ना_के_बारे_में|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+ना_के_बावजूद|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+ना_के_लिए|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+ना_के_संबंध_में|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+ना_कें_बारे_में|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+ना_चाहिए|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+ना_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+ना_पर|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+ना|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या1_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या1_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या1_है|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या1|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या1|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या1|tam-yA|stype-interrogative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या1|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या१_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या१_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या१_था|tam-yA|stype-interrogative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या१_हो+ता|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या१|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या१|tam-yA|stype-interrogative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा+या१|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा_रह+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा_रह+या_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा_सक+ता_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा_सक+ता_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_जा_सक+या_था|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_था|tam-yA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_दे+या1|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_दे+या_जा+एं|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_दे+या_जा+या१|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_दे+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_पर|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_पा+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_रख+ना_के_लिए|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_रख+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_रख+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_रह+ता|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_रह+ना_के_लिए|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_रह+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_ले+या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_सक+ता|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_हो+ता|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_हो+या_था|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या_हो+या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या|tam-yA|stype-declarartive'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या|tam-yA|stype-declarative'>|voicetype-passive
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या|tam-yA|stype-declarative|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या|tam-yA|stype-interrogative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या१_तक|tam-yA1|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या१_था|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या१|tam-yA1|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या१|tam-yA1|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-|case-any|vib-या|tam-yA|stype-|voicetype-
VM	v	cat-v|gen-m|num-sg|pers-|case-|vib-या|tam-yA|stype-declarative'>|voicetype-active
VM	v	cat-v|gen-pl|num-pl|pers-3|case-|vib-या_था|tam-yA|stype-declarative'>|voicetype-active
VMC	avy	cat-avy|gen-any|num-sg|pers-3|case-|vib-एं|tam-eM|stype-declarative'>|voicetype-active
VMC	n	cat-n|gen-m|num-pl|pers-any|case-|vib-ता|tam-wA|stype-|voicetype-
VMC	v	cat-v|gen-any|num-any|pers-any|case-d|vib-ना|tam-nA|stype-|voicetype-
VMC	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_जा+ना_सहित|tam-nA|stype-|voicetype-
VMC	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_में|tam-nA|stype-|voicetype-
VMC	v	cat-v|gen-any|num-any|pers-any|case-o|vib-ना_से|tam-nA|stype-|voicetype-
VMC	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_कर|tam-0|stype-|voicetype-
VMC	v	cat-v|gen-any|num-any|pers-any|case-|vib-0_के_लिए|tam-0|stype-|voicetype-
VMC	v	cat-v|gen-any|num-any|pers-any|case-|vib-0|tam-0|stype-|voicetype-
VMC	v	cat-v|gen-any|num-any|pers-any|case-|vib-ना_में|tam-nA|stype-|voicetype-
VMC	v	cat-v|gen-any|num-any|pers-any|case-|vib-ना|tam-nA|stype-|voicetype-
VMC	v	cat-v|gen-any|num-pl|pers-any|case-o|vib-ना_का|tam-nA|stype-|voicetype-
VMC	v	cat-v|gen-any|num-pl|pers-any|case-o|vib-ना_वाला|tam-nA|stype-|voicetype-
VMC	v	cat-v|gen-any|num-pl|pers-any|case-|vib-ना_वाला|tam-nA|stype-|voicetype-
VMC	v	cat-v|gen-any|num-sg|pers-3|case-|vib-या|tam-yA|stype-|voicetype-
VMC	v	cat-v|gen-any|num-sg|pers-any|case-o|vib-ना_दे+ना_का|tam-nA|stype-|voicetype-
VMC	v	cat-v|gen-any|num-sg|pers-any|case-|vib-ना_का|tam-nA|stype-|voicetype-
VMC	v	cat-v|gen-f|num-pl|pers-any|case-|vib-या_हो+ता|tam-yA|stype-declarative'>|voicetype-active
VMC	v	cat-v|gen-f|num-sg|pers-3|case-|vib-0_रह+या_है|tam-0|stype-declarative'>|voicetype-active
VMC	v	cat-v|gen-f|num-sg|pers-any|case-|vib-ता|tam-wA|stype-|voicetype-
VMC	v	cat-v|gen-m|num-any|pers-any|case-o|vib-ना_वाला_को|tam-nA|stype-|voicetype-
VMC	v	cat-v|gen-m|num-pl|pers-any|case-|vib-ता|tam-wA|stype-|voicetype-
VMC	v	cat-v|gen-m|num-sg|pers-3h|case-|vib-0_सक+ता_है|tam-0|stype-declarative'>|voicetype-active
VMC	v	cat-v|gen-m|num-sg|pers-3|case-|vib-0_जा+या_है|tam-0|stype-declarative'>|voicetype-active
VMC	v	cat-v|gen-m|num-sg|pers-any|case-|vib-या|tam-yA|stype-|voicetype-
WQ	adj	cat-adj|gen-f|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
WQ	adj	cat-adj|gen-m|num-pl|pers-|case-d|vib-|tam-|stype-|voicetype-
WQ	adv	cat-adv|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
WQ	avy	cat-avy|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
WQ	pn	cat-pn|gen-any|num-pl|pers-3|case-o|vib-|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-any|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-को|tam-ko|stype-|voicetype-
WQ	pn	cat-pn|gen-any|num-sg|pers-3|case-o|vib-ने|tam-ne|stype-|voicetype-
WQ	pn	cat-pn|gen-f|num-any|pers-|case-d|vib-|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-f|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-f|num-sg|pers-3|case-o|vib-0|tam-0|stype-|voicetype-
WQ	pn	cat-pn|gen-f|num-sg|pers-3|case-o|vib-का|tam-kA|stype-|voicetype-
WQ	pn	cat-pn|gen-f|num-sg|pers-3|case-|vib-|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-f|num-sg|pers-|case-|vib-|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-m|num-pl|pers-3|case-d|vib-|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-0_को|tam-0|stype-|voicetype-
WQ	pn	cat-pn|gen-m|num-pl|pers-3|case-o|vib-|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-m|num-pl|pers-|case-o|vib-|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-m|num-sg|pers-3|case-d|vib-0|tam-0|stype-|voicetype-
WQ	pn	cat-pn|gen-m|num-sg|pers-3|case-d|vib-|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-m|num-sg|pers-3|case-o|vib-का|tam-kA|stype-|voicetype-
WQ	pn	cat-pn|gen-m|num-sg|pers-|case-d|vib-|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-|num-|pers-|case-d|vib-|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-|num-|pers-|case-o|vib-0_तक|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-|num-|pers-|case-o|vib-0_से|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-|num-|pers-|case-o|vib-|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-|num-|pers-|case-|vib-0_लिए|tam-|stype-|voicetype-
WQ	pn	cat-pn|gen-|num-|pers-|case-|vib-|tam-|stype-|voicetype-
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
