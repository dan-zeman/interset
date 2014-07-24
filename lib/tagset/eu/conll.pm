#!/usr/bin/perl
# Driver for the CoNLL 2007 Basque
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>, Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>
# License: GNU GPL

package tagset::eu::conll;
use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");



my %postable =
(
    "ADB\tARR" => ['pos' => 'adv'], # adberbiboa = adverb, common (gaurko = today, samar = relatively, lehenbiziko = first)
    "ADB\tGAL" => ['pos' => 'adv', 'prontype' => 'int'], # adberbiboa, galdera = adverb, question (nola = how, zergatik = why, noraino = to what extent, non = where, noiz = when)
    "ADI\tADI_IZEELI" => ['pos' => 'verb'], # aditz = verb (azaltzekoak = explain, pentsatzekoa = think, egotekoa = be)
    "ADI\tADK" => ['pos' => 'verb'], # verb, composed (ahal_izateko = in order to, aurre_egiteko = meet, hitz_egiteko = speak)
    "ADI\tADP" => ['pos' => 'verb'], # (merezi = worth)
    "ADI\tFAK" => ['pos' => 'verb'], # verb, factitive (faktitivní, kausativní) (adierazi = said, jakinarazi = reported, ikustarazi = displayed)
    "ADI\tSIN" => ['pos' => 'verb'], # verb, simple (egin = do, izan = be, jokatu = play, eman = given, esan = said)
    "ADJ\tADJ" => ['pos' => 'adj'], # adjektiboa = adjective (nondik_norakoa)
    "ADJ\tARR" => ['pos' => 'adj'], # adjective, common (errusiar = Russian, atzerritar = foreign, gustuko = tasteful, britainiar = British, ageriko = visible)
    "ADJ\tERKIND" => ['pos' => 'adj'], # (aldi_bereko = at the same time, simultaneous)
    "ADJ\tGAL" => ['pos' => 'adj', 'prontype' => 'int'], # adjektiboa, galdera = adjective, question (nolakoa = what, nongoa = where)
    "ADJ\tSIN" => ['pos' => 'adj'], # adjective, simple (ongi_etorria = welcome to) [error?]
    "ADL\tADL" => ['pos' => 'verb', 'subpos' => 'aux'], # auxiliary verb (izan, *edin, ukan, *edun, *ezan)
    "ADT\tADT" => ['pos' => 'verb'], # synthetic verb (joan = go, egon = be, izan = be, jakin = know)
    "ADT\tARR" => ['pos' => 'verb'], # [error?] (Bear_Zana)
    "BEREIZ\tBEREIZ" => ['pos' => 'punc'], # bereiz = separator (", (, ), -, », «, /, ', *, [, ], +, `)
    "BST\tARR" => [], # beste = other (eta_abar = etc.)
    "BST\tBST" => [], # beste = other (baino = than, de = of, ohi = usually, ea = whether, ezta = or)
    "BST\tDZG" => [], # other, indefinite (ez_beste, ez_besterik = only, no other)
    "DET\tBAN" => ['pos' => 'num'], # determiner, distributive = banatu (bana = one each, 6na, 25na, bedera = at least, bina = two)
    "DET\tDZG" => ['pos' => 'num', 'prontype' => 'ind'], # determiner, indefinite (bestea = other, nahikoa = enough, gehiena = most of the, bestekoa = average, hainbat = some, gehiago = more)
    "DET\tDZH" => ['pos' => 'num', 'numtype' => 'card'], # determiner, definite (10:00etarako = 10:00 pm, bi = two, hiru = three, zortzi = eight)
    "DET\tERKARR" => ['pos' => 'adj', 'prontype' => 'dem'], # determiner, demonstrative common (horretarako = this, hartarako = so, horietarako = these, hori, hau, hura)
    "DET\tERKIND" => ['pos' => 'adj', 'prontype' => 'dem'], # determiner, demonstrative emphatic (bera = the same)
    "DET\tNOLARR" => ['pos' => 'adj', 'prontype' => 'ind'], # determiner, indefinite common (edozer = any)
    "DET\tNOLGAL" => ['pos' => 'adj', 'prontype' => 'int'], # determiner, indefinite question (zer = what, zenbat = how many, zein = which)
    "DET\tORD" => ['pos' => 'num', 'numtype' => 'ord'], # determiner, ordinal (lehen = first, aurren = first, bigarren = second, hirugarren = third, azken = last)
    "DET\tORO" => ['pos' => 'adj', 'subpos' => 'det', 'prontype' => 'tot'], # determiner, general (guzti = all, dena = everything)
    "ERL\tERL" => [], # [error?] (bait = because)
    "HAOS\tHAOS" => [], # (ari, komeni, berrogoita, hogeita)
    "IOR\tELK" => ['pos' => 'noun', 'prontype' => 'rcp'], # pronoun, reciprocal (elkar = each other)
    "IOR\tIZGGAL" => ['pos' => 'noun', 'prontype' => 'int'], # pronoun, question (nor = who)
    "IOR\tIZGMGB" => ['pos' => 'noun', 'prontype' => 'ind'], # pronoun, indefinite (ezer = nothing, zerbait = something, inor = no one, zertxobait = somewhat, norbait = someone)
    "IOR\tPERARR" => ['pos' => 'noun', 'prontype' => 'prs'], # pronoun, personal common (ni = I, hi = thou, hura = he/she/it, gu = we, zu, zuek = you, haiek = they)
    "IOR\tPERIND" => ['pos' => 'noun', 'prontype' => 'prs', 'variant' => 1], # pronoun, personal emphatic (neu, heu, geu, zeu)
    "ITJ\tARR" => ['pos' => 'int'], # interjection, [error?]
    "ITJ\tITJ" => ['pos' => 'int'], # interjekzioa = interjection (beno, ha, tira, dzast, ea)
    "IZE\tADB_IZEELI" => ['pos' => 'noun'], # izen = noun, adverbial (araberakoak = according to, kontrakoak = against, betikoak = always)
    "IZE\tADJ_IZEELI" => ['pos' => 'noun'], # izen = noun, adjectival (handikoa = high, hutsezkoa = empty, nagusietakoa = main)
    "IZE\tARR" => ['pos' => 'noun'], # noun, common (jokalari = player, pertsona = person, soldadu = soldier)
    "IZE\tDET_IZEELI" => ['pos' => 'noun'], # izen = noun, determinal (batena, batekoa = one, berea = percent)
    "IZE\tIOR_IZEELI" => ['pos' => 'noun'], # izen = noun, pronominal (nireak = mine, geurea = our, zuena)
    "IZE\tIZB" => ['pos' => 'noun', 'subpos' => 'prop'], # proper noun (Jean, EAJ, Espainiako_Erregearen_Gabonetako)
    "IZE\tIZE_IZEELI" => ['pos' => 'noun'], # izen = noun, denominal (mailakoa = level, aldekoa = support, pezetakoa = peseta)
    "IZE\tLIB" => ['pos' => 'noun', 'subpos' => 'prop'], # place name (Bahamak, Molukak, Filipinak)
    "IZE\tZKI" => ['pos' => 'num', 'numtype' => 'card'], # izen = noun, number (biak = two, hiruak = three, hamabiak = twelve, 22raino = until 22, 1996tik = since 1996)
    "LOT\tJNT" => ['pos' => 'conj', 'subpos' => 'coor'], # conjunction (baina = but, baino = than, izan_ezik = except for, ez_baina = but not, eta = and, baita = and, ezta = or, ez_ezik = in addition to, baita_ere = also, edo = or, zein = and, ala = or, edota = or, nahiz = and)
    "LOT\tLOK" => ['pos' => 'conj', 'subpos' => 'sub'], # connector (hala_ere = but, baldin = if/or, ere = also, bestalde = in addition, batez_ere = especially, batik_bat = mainly, are_gehiago = more so, hots = that, bestela = or, osterantzean = moreover, ezen = that, zeren_eta = because, alde_batetik = on the one hand, besterik_gabe = just, beraz = so)
    "LOT\tMEN" => ['pos' => 'conj', 'subpos' => 'sub'], # (eta_gero = and then, eta = and, arren = although)
    "PRT\tPRT" => ['pos' => 'part'], # partikula = particle (ez, ezetz = no/not, bai, baietz = yes, al = to, ote = whether, omen = it seems
    "PUNT_MARKA\tPUNT_BI_PUNT" => ['pos' => 'punc', 'punctype' => 'colo'], # :
    "PUNT_MARKA\tPUNT_ESKL" => ['pos' => 'punc', 'punctype' => 'excl'], # !
    "PUNT_MARKA\tPUNT_GALD" => ['pos' => 'punc', 'punctype' => 'qest'], # ?
    "PUNT_MARKA\tPUNT_HIRU" => ['pos' => 'punc', 'punctype' => 'peri'], # ...
    "PUNT_MARKA\tPUNT_KOMA" => ['pos' => 'punc', 'punctype' => 'comm'], # ,
    "PUNT_MARKA\tPUNT_PUNT" => ['pos' => 'punc', 'punctype' => 'peri'], # .
    "PUNT_MARKA\tPUNT_PUNT_KOMA" => ['pos' => 'punc', 'punctype' => 'semi'], # ;
);



my %featable =
(
    'BIZ:+'     => ['animateness' => 'anim'], # lagun, jokalari, pertsona, jabe, nagusi
    'BIZ:-'     => ['animateness' => 'inan'], # urte, arte, gain, ezin, behar
    'NUM:S'     => ['number' => 'sing'],
    'NUM:P'     => ['number' => 'plu'],
    'NUM:PH'    => [], # adjectives, determiners and nouns (maiteok = dear, gehienok = most, biok [bi=two], laurok [lau=four], denok, guztiok)
    'KAS:ABL'   => ['case' => 'abl'],
    'KAS:ABS'   => ['case' => 'abs'],
    'KAS:ABU'   => ['case' => 'ter'],
    'KAS:ABZ'   => ['case' => 'lat'],
    'KAS:ALA'   => ['case' => 'all'],
    'KAS:BNK'   => ['case' => 'loc', 'other' => {'case' => 'BNK'}],
    'KAS:DAT'   => ['case' => 'dat'],
    'KAS:DES'   => ['case' => 'ben'],
    'KAS:DESK'  => ['case' => 'loc', 'other' => {'case' => 'DESK'}],
    'KAS:EM'    => ['prepcase' => 'pre'],
    'KAS:ERG'   => ['case' => 'erg'],
    'KAS:GEL'   => ['case' => 'loc'],
    'KAS:GEN'   => ['case' => 'gen'],
    'KAS:INE'   => ['case' => 'ine'],
    'KAS:INS'   => ['case' => 'ins'],
    'KAS:MOT'   => ['case' => 'cau'],
    'KAS:PAR'   => ['case' => 'par'],
    'KAS:PRO'   => ['case' => 'ess'],
    'KAS:SOZ'   => ['case' => 'com'],
    'MUG:M'     => [], # these have number
    'MUG:MG'    => [], # these do not have number
    'PLU:+'     => [], # nouns, unknown meaning
    'PLU:-'     => [], # nouns, unknown meaning
    'ZENB:-'    => [], # nouns, unknown meaning
    'NEUR:-'    => [], # rare feature of nouns
    'ENT:???'       => [], # unknown or miscellaneous
    'ENT:Erakundea' => [], # organization: Parlamentu_Federala, Aginte_Nazionala, Erresuma_Batua, Eliza_Ortodoxoa, Hidroelektrikoa
    'ENT:Pertsona'  => [], # person: Andreas, Jontxu, Milosevic, Eli, Arafat
    'ENT:Tokia'     => [], # place: Frantzia, Bizkaia, Errusia, Zaragoza, Gipuzkoa
    'MTKAT:LAB' => [], # noun abbreviations (etab = etc., g.e., H.G.)
    'MTKAT:SIG' => [], # noun abbreviations (EAJ, ELA, CSU, EH, EHE)
    'MTKAT:SNB' => [], # noun abbreviations (Kw, m, km, cm, kg)
    'IZAUR:+'   => [], # adjectives (unknown meaning; applies predominantly but not exclusively to nationalities (errusiar = Russian))
    'IZAUR:-'   => [], # adjectives, adverbs and some nouns (unknown meaning; could this be a quality while + would be membership in a group?)
    'MAI:GEHI'  => ['degree' => 'abs'], # adjectives and adverbs, degree (goizegi = too early, maizegi = too often, urrunegi = too far, azkarregi = too fast, berantegi = too late)
    'MAI:IND'   => [], # determiners (hauexek, horixe, hauxe, huraxe)
    'MAI:KONP'  => ['degree' => 'comp'], # adverbs, verbs, adjectives, nouns (beranduago = later, urrunago = further, arinago = lighter, ezkorrago = wetter)
    'MAI:SUP'   => ['degree' => 'sup'], # adjectives and adverbs (ondoen = the best, urrutien = the farthest, seguruen = the safest, azkarren = the fastest, gutxien = the least)
    'NMG:MG'    => [], # determiners (hainbat = some, zenbait = some, milaka = thousands, gehiago = more, asko = many, ugari = many, oro = all)
    'NMG:P'     => [], # determiners (milioika = millions of, batzu, batzuk = some, gehientsuenak = most of, bi = two, hiru = three, zortzi = eight, 20:00ak)
    'NMG:S'     => [], # determiners (bat, bata = one, bera = the same, bereak = own)
    'PER:NI'    => ['person' => 1, 'number' => 'sing'], # (ni, niregana, niri, niretzat, nik, nire, nigan, nitaz, niregatik, nirekin, neu, neuri, neuk, neure = I, nireak = mine)
    'PER:HI'    => ['person' => 2, 'number' => 'sing', 'politeness' => 'inf'], # (hi, hiri, hik, hire, heure = thou)
    'PER:HURA'  => ['person' => 3, 'number' => 'sing'], # (berau = it)
    'PER:GU'    => ['person' => 1, 'number' => 'plu'], # (gu, guri, guretzat, guk, gutako, gure, gurean, gutaz, gurekin, geu, geuri, geuk, geure, geuregan = we, geurea = our)
    'PER:ZU'    => ['person' => 2, 'number' => 'sing', 'politeness' => 'pol'], # (zugandik, zu, zuretzat, zuk, zure, zutaz, zurekin, zeu, zeuk, zeure = you)
    'PER:ZUEK'  => ['person' => 2, 'number' => 'plu'], # (zuek, zuei, zuenak, zuetako, zuen, zuetaz = you, zuena)
    'PER:HAIEK' => ['person' => 3, 'number' => 'plu'], # (nortzuk = who, zenbaitzuk = some, beraiek, eurak = they)
    'ADM:PART'  => ['verbform' => 'part'], # participle
    'ADM:ADIZE' => ['verbform' => 'ger'], # verbal noun
    'ADM:ADOIN' => ['verbform' => 'inf'], # occurs with modal
    'ASP:PNT'   => [], # composed verbs, finite forms of synthetic verbs
    'ASP:BURU'  => ['aspect' => 'perf'],
    'ASP:EZBU'  => ['aspect' => 'imp'],
    'ASP:GERO'  => ['aspect' => 'pro'],
    'ERL:AURK'  => [], # conjunctions: baina = but, baino = than, baizik = but, izan_ezik = except for, ez baina = but not, ostera = while
    'ERL:BALD'  => [], # verbs: conditional protasis (balira = if they were; bada, badira, bagara, bagatzaizkio, bagina, baginen, balira, balitz, ..., izatekoan)
    'ERL:DENB'  => [], # verbs (denean, denerako, denetik, direnean, direneako, ginenean, naizenean, naizenetik, nintzenean, zaigunean, zenean, zenetik, zirenean, zirenetik, zitzaionean, zitzaizkienean)
    'ERL:EMEN'  => [], # conjunctions: eta = and, baita = and, ezta = or, ez_ezik = in addition to, baita_ere = also
    'ERL:ERLT'  => [], # verbs (den, diren, giren, naizen, zaidan, zaien, zaigun, zaion, zaizkien, zaizkion, zaizkizun, zen, ziren, zitzaidan, zitzaion, zitzaizkigun, zitzaizkion)
    'ERL:ESPL'  => [], # conjunctions (explicative): hain_zuzen = which, esate_baterako = such as, hala_nola = such as
    'ERL:HAUT'  => [], # conjunctions: edo = or, zein = and, ala = or, edota = or, nahiz = and, bestela = or
    'ERL:HELB'  => [], # verbs (izateko, izatera)
    'ERL:KAUS'  => [], # verbs (baigara, bailitzateke, bainintzen, baita, baitira, baitzaio, baitzait..., danez, delako, denez, direlako, direlakotz, direnez, garelako, garenez, haizelako, litzatekeelako, naizenez, nintzelako, zaienez, zaiolako, zelako, zenez, zirelako, zirenez, zitzaizkiolako)
    'ERL:KONPL' => [], # verbs (badela, badirela, bazela, dela, dena, denik, direla, direnik, garela, ginela, izatea, izatekoa, izaten, liratekeela, lizatekeela, naizela, naizenik, nintzatekeela, nintzela, zaiela, zaiguna, zaiola, zaizkiela, zaizkiola, zarela, zatekeela, zela, zenik, zirela, zirenik, zitzaidala, zitzaigunik, zitzaiola)
    'ERL:KONT'  => [], # verbs (izanagatik, izateagatik) because? although? as?
    'ERL:MOD'   => [], # verbs (delakoan, direlakoan, izaki, izanda, izaten, zelakoan, zirelakoan)
    'ERL:MOD/DENB'=>[],# verbs (dela, delarik, direla, direlarik, nintzela, nintzelarik, zaiola, zela, zelarik, zirela, zirelarik)
    'ERL:MOS'   => [], # verbs: conditional apodosis? (lirateke = they would be, ziratekeen = they would have been; baden, bazen, den, diren, garen, liratekeen, zaizkidan, zen, zinen, ziren, zitzaidan, zitzaien)
    'ERL:ONDO'  => [], # conjunctions (beraz = so, bada = if, orduan = when, hortaz = so, egia_esan = true that, azken_esan = now that)
    'ERL:ZHG'   => [], # verbs (den, diren, direnetz, garen, naizen, nintzen, zaigun, zaion, zaizkion, zaren, zen, ziren)
    'MDN:A1'    => [], # verbs 11766
    'MDN:A3'    => [], # verbs 107
    'MDN:A4'    => [], # verbs 1
    'MDN:A5'    => [], # verbs 282
    'MDN:B1'    => [], # verbs 6666
    'MDN:B2'    => [], # verbs 185
    'MDN:B3'    => [], # verbs 11
    'MDN:B4'    => [], # verbs 59
    'MDN:B5A'   => [], # verbs 1
    'MDN:B5B'   => [], # verbs 27
    'MDN:B6'    => [], # verbs 1
    'MDN:B7'    => [], # verbs 79
    'MDN:B8'    => [], # verbs 38
    'MDN:C'     => [], # verbs 52
    'MOD:EGI'   => [], # verbs
    'MOD:ZIU'   => [], # verbs
    # absolutive argument (nor = who) of verb
    'NOR:NI'       => ['person' => 1, 'number' => 'sing'],                        # verb abs argument 'ni' = 'I'           (naiz,   banaiz,   naizateke) 337
    'NOR:HI'       => ['person' => 2, 'number' => 'sing', 'politeness' => 'inf'], # verb abs argument 'hi' = 'thou'        (haiz,   bahaiz,   haizateke) 20
    'NOR:HURA'     => ['person' => 3, 'number' => 'sing'],                        # verb abs argument 'hura' = 'he/she/it' (da,     bada,     dateke) 14342
    'NOR:GU'       => ['person' => 1, 'number' => 'plu'],                         # verb abs argument 'gu' = 'we'          (gara,   bagara,   garateke) 223
    'NOR:ZU'       => ['person' => 2, 'number' => 'sing', 'politeness' => 'pol'], # verb abs argument 'zu' = 'you'         (zara,   bazara,   zarateke) 93
    'NOR:ZUEK'     => ['person' => 2, 'number' => 'plu'],                         # verb abs argument 'zuek' = 'you'       (zarete, bazarete, zaratekete) 12
    'NOR:HAIEK'    => ['person' => 3, 'number' => 'plu'],                         # verb abs argument 'haiek' = 'they'     (dira,   badira,   dirateke) 4248
    # dative argument (nori = whom/dat) of verb
    'NORI:NIRI'    => [], # verb dat argument 'niri' = 'to me'             (hatzait, zait, zatzaizkit, zatzaizkidate, zaizkit) 152
    'NORI:HIRI-NO' => [], # verb dat argument 'hiri' = 'to thee'           (natzaik, zaik, gatzaizkik, zaizkik) 2
    'NORI:HIRI-TO' => [], # 5
    'NORI:HARI'    => [], # verb dat argument 'hari' = 'to him/her/it'     (natzaio, hatzaio, zaio, gatzaizkio, zatzaizkio, zatzaizkiote, zaizkio) 1085
    'NORI:GURI'    => [], # verb dat argument 'guri' = 'to us'             (hatzaigu, zaigu, zatzaizkigu, zatzaizkigute, zaizkigu) 124
    'NORI:ZURI'    => [], # verb dat argument 'zuri' = 'to you-sg'         (natzaizu, zaizu, gatzaizkizu, zaizkizu) 39
    'NORI:ZUEI'    => [], # verb dat argument 'zuei' = 'to you-pl'         (natzaizue, zaizue, gatzaizkizue, zaizkizue) 12
    'NORI:HAIEI'   => [], # verb dat argument 'haiei' = 'to them'          (natzaie, hatzaie, zaie, gatzaizkie, zatzaizkie, zatzaizkiete, zaizkie) 306
    # ergative argument (nork = whom/erg) of verb
    'NORK:NIK'     => [], # verb erg argument 'nik' = 'I'                  (haut, dut, zaitut, zaituztet, ditut) 662
    'NORK:HIK'     => [], # verb erg argument 'hik' = 'thou'               (nauk, duk, gaituk, dituk) 6
    'NORK:HIK-NO'  => [], # 10
    'NORK:HIK-TO'  => [], # 8
    'NORK:HARK'    => [], # verb erg argument 'hark' = 'he/she/it'         (nau, hau, du, gaitu, zaitu, zaituzte, ditu) 5981
    'NORK:GUK'     => [], # verb erg argument 'guk' = 'we'                 (haugu, dugu, zaitugu, zaituztegu, ditugu) 721
    'NORK:ZUK'     => [], # verb erg argument 'zuk' = 'you-sg'             (nauzu, duzu, gaituzu, dituzu) 208
    'NORK:ZUEK-K'  => [], # verb erg argument 'zuek' = 'you-pl'            (nauzue, duzue, gaituzue, dituzue) 46
    'NORK:HAIEK-K' => [], # verb erg argument 'haiek' = 'they'             (naute, haute, dute, gaituzte, zaituzte, zaituztete, dituzte) 2618
    'HIT:NO'    => [], # rare feature of verbs
    'HIT:TO'    => [], # rare feature of verbs
    'KLM:AM'    => [], # only conjunction "eta" = "and" (causative)
    'KLM:HAS'   => [], # only conjunction "zeren" = "because" (causative)
    'MW:B'      => [], # multi-word token (contains '_')
    '_'         => [], # featureless tag (POS: ADB/ARR, ADB/GAL, ADJ/ARR, ADJ/GAL, BEREIZ, BST, DET/BAN, DET/DZG, DET/ORD, DET/ORO, HAOS, ITJ, IZE/ARR, IZE/IZB, IZE/LIB, IZE/ZKI, PUNT_BI_PUNT(:), PUNT_ESKL(!), PUNT_GALD(?), PUNT_HIRU(...), PUNT_KOMA(,), PUNT_PUNT(.), PUNT_PUNT_KOMA(;)
    # postpositions attached using underscore (postposition itself does not trigger MW:B!)
    'POS:+'     => [], # there is a postposition
    # features for particular postpositions:
    'POS:POSAldeko' => [], # for 2
    'POS:POSAurkako' => [], # against 1
    'POS:POSGabeko' => [], # not 1
    'POS:POSInguruko' => [], # about 1
    'POS:POSKontrako' => [], # against 2
    'POS:POSaintzinean' => [], # former 1
    'POS:POSaitzina' => [], # beyond 2
    'POS:POSaitzinean' => [], # in the 5
    'POS:POSaitzineko' => [], # before 2
    'POS:POSaitzinetik' => [], # beforehand 3
    'POS:POSalboan' => [], # next 2
    'POS:POSaldamenetik' => [], # side 1
    'POS:POSalde' => [], # the 38
    'POS:POSaldean' => [], # at 11
    'POS:POSaldeaz' => [], # at 1
    'POS:POSaldeko' => [], # for 37
    'POS:POSaldera' => [], # to 20
    'POS:POSalderat' => [], # 1
    'POS:POSaldetik' => [], # as 25
    'POS:POSantzean' => [], # similar 1
    'POS:POSantzeko' => [], # similar 9
    'POS:POSantzekoa' => [], # similar 2
    'POS:POSantzera' => [], # like 3
    'POS:POSarabera' => [], # according to 135
    'POS:POSaraberako' => [], # by 1
    'POS:POSarte' => [], # to 82
    'POS:POSartean' => [], # among 158
    'POS:POSarteetik' => [], # among 1
    'POS:POSarteko' => [], # between 108
    'POS:POSartekoak' => [], # between 1
    'POS:POSat' => [], # at 6
    'POS:POSatzean' => [], # back 15
    'POS:POSatzeko' => [], # back 6
    'POS:POSatzera' => [], # back 1
    'POS:POSatzetik' => [], # after 12
    'POS:POSaurka' => [], # against 103
    'POS:POSaurkaa' => [], # against 1
    'POS:POSaurkako' => [], # against 48
    'POS:POSaurrean' => [], # to 74
    'POS:POSaurreko' => [], # previous 10
    'POS:POSaurrera' => [], # from 36
    'POS:POSaurrerako' => [], # from 2
    'POS:POSaurretik' => [], # before 26
    'POS:POSazpian' => [], # under 9
    'POS:POSazpitik' => [], # below 6
    'POS:POSbaitan' => [], # within 12
    'POS:POSbarik' => [], # not 2
    'POS:POSbarna' => [], # through 1
    'POS:POSbarnean' => [], # within 11
    'POS:POSbarneko' => [], # including 2
    'POS:POSbarnera' => [], # into 1
    'POS:POSbarrena' => [], # through 4
    'POS:POSbarrenean' => [], # inside 1
    'POS:POSbarru' => [], # in 7
    'POS:POSbarruan' => [], # within 37
    'POS:POSbarruetatik' => [], # inside 1
    'POS:POSbarruko' => [], # internal 3
    'POS:POSbarrura' => [], # inside 1
    'POS:POSbarrutik' => [], # inside 2
    'POS:POSbatera' => [], # with 42
    'POS:POSbatera?' => [], # with 1
    'POS:POSbegira' => [], # at 31
    'POS:POSbehera' => [], # down 11
    'POS:POSbestaldean' => [], # other 1
    'POS:POSbezala' => [], # as 75
    'POS:POSbezalako' => [], # as 15
    'POS:POSbezalakoa' => [], # as 1
    'POS:POSbezalakoen' => [], # as 1
    'POS:POSbidez' => [], # by 45
    'POS:POSbila' => [], # for 20
    'POS:POSbitarte' => [], # to 2
    'POS:POSbitartean' => [], # while 18
    'POS:POSbitarteko' => [], # to 5
    'POS:POSbitarterako' => [], # 1
    'POS:POSbitartez' => [], # through 13
    'POS:POSburuan' => [], # after 7
    'POS:POSburuz' => [], # about 47
    'POS:POSburuzko' => [], # on 36
    'POS:POSeran' => [], # as 1
    'POS:POSerdian' => [], # middle 11
    'POS:POSerdiko' => [], # central 1
    'POS:POSerdira' => [], # half 3
    'POS:POSerditan' => [], # half 1
    'POS:POSeske' => [], # begging 2
    'POS:POSesker' => [], # thanks 30
    'POS:POSesku' => [], # the 12
    'POS:POSeskuetan' => [], # hands 5
    'POS:POSeskuko' => [], # hand 1
    'POS:POSeskutik' => [], # by 6
    'POS:POSezean' => [], # if you do not 4
    'POS:POSgabe' => [], # no 74
    'POS:POSgabeko' => [], # not 17
    'POS:POSgain' => [], # in addition to 36
    'POS:POSgaindi' => [], # overcome 1
    'POS:POSgaindiko' => [], # border 1
    'POS:POSgainean' => [], # on 33
    'POS:POSgaineko' => [], # on 12
    'POS:POSgainera' => [], # also 9
    'POS:POSgainerat' => [], # 1
    'POS:POSgainetik' => [], # above 16
    'POS:POSgero' => [], # more 1
    'POS:POSgeroztik' => [], # since 18
    'POS:POSgertu' => [], # near 4
    'POS:POSgibeleko' => [], # liver 1
    'POS:POSgibeletik' => [], # behind 2
    'POS:POSgisa' => [], # as 34
    'POS:POSgisako' => [], # as 1
    'POS:POSgisan' => [], # as 2
    'POS:POSgisara' => [], # as 1
    'POS:POSgoiko' => [], # top 1
    'POS:POSgoitik' => [], # top 1
    'POS:POSgora' => [], # up 30
    'POS:POSgorago' => [], # above 1
    'POS:POSgorako' => [], # more 7
    'POS:POSgorakoen' => [], # over 1
    'POS:POShurbil' => [], # close 8
    'POS:POShurrean' => [], # respectively 1
    'POS:POSinguru' => [], # about 16
    'POS:POSingurua' => [], # environment 1
    'POS:POSinguruan' => [], # about 77
    'POS:POSinguruetako' => [], # surrounding 1
    'POS:POSinguruetan' => [], # in 2
    'POS:POSinguruetara' => [], # environments 1
    'POS:POSinguruko' => [], # about 27
    'POS:POSingurura' => [], # about 5
    'POS:POSingururako' => [], # environment 1
    'POS:POSirian' => [], # 1
    'POS:POSkanpo' => [], # outside 28
    'POS:POSkanpoko' => [], # external 12
    'POS:POSkanpora' => [], # outside 4
    'POS:POSkontra' => [], # against 72
    'POS:POSkontrako' => [], # against 38
    'POS:POSlanda' => [], # rural 7
    'POS:POSlandara' => [], # plant 2
    'POS:POSlegez' => [], # as 1
    'POS:POSlekuan' => [], # where 4
    'POS:POSlepora' => [], # 1
    'POS:POSmendean' => [], # the 1
    'POS:POSmenpe' => [], # depends on 8
    'POS:POSmenpera' => [], # conquest 1
    'POS:POSmoduan' => [], # as 1
    'POS:POSmodura' => [], # as 1
    'POS:POSondoan' => [], # next 19
    'POS:POSondoko' => [], # the 1
    'POS:POSondora' => [], # close 1
    'POS:POSondoren' => [], # after 32
    'POS:POSondorengo' => [], # the 2
    'POS:POSondotik' => [], # after 14
    'POS:POSordez' => [], # instead of 9
    'POS:POSostean' => [], # after 17
    'POS:POSosteko' => [], # after 1
    'POS:POSpare' => [], # two 1
    'POS:POSparean' => [], # at 5
    'POS:POSpareko' => [], # equivalent 2
    'POS:POSpartean' => [], # part of 3
    'POS:POSpartez' => [], # notebook 1
    'POS:POSpean' => [], # under 1
    'POS:POStruke' => [], # exchange 9
    'POS:POSurrun' => [], # from 3
    'POS:POSurruti' => [], # far 3
    'POS:POSzai' => [], # waiting 2
    'POS:POSzain' => [], # waiting 12
    'POS:POSzehar' => [], # during 42
);



#------------------------------------------------------------------------------
# Takes tag string.
# Returns feature hash.
#------------------------------------------------------------------------------
sub decode
{
    my $tag = shift;
    my %f; # features
    $f{tagset} = "eu::conll";
    # three components: coarse-grained pos, fine-grained pos, features
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    # Decode part of speech.
    my @assignments = @{$postable{"$pos\t$subpos"}};
    for(my $i = 0; $i<=$#assignments; $i += 2)
    {
        $f{$assignments[$i]} = $assignments[$i+1];
    }
    # Decode feature values.
    my @features = split(/\|/, $features);
    foreach my $feature (@features)
    {
        my @assignments = @{$featable{$feature}};
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
