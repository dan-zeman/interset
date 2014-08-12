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
ADB	ARR	ADM:PART
ADB	ARR	BIZ:-
ADB	ARR	BIZ:-|KAS:GEL
ADB	ARR	BIZ:-|MUG:M|MW:B
ADB	ARR	BIZ:-|MW:B
ADB	ARR	ENT:Erakundea
ADB	ARR	ENT:Pertsona
ADB	ARR	ENT:Tokia
ADB	ARR	IZAUR:-
ADB	ARR	IZAUR:-|POS:POSaurrera|POS:+|KAS:ALA
ADB	ARR	KAS:ABL
ADB	ARR	KAS:ABL|NUM:S|MUG:M|MW:B
ADB	ARR	KAS:ABS|MUG:MG
ADB	ARR	KAS:ABS|NUM:P|MUG:M
ADB	ARR	KAS:ABS|NUM:S|MUG:M
ADB	ARR	KAS:ABS|NUM:S|MUG:M|MW:B
ADB	ARR	KAS:ABS|POS:POSkanpo|POS:+
ADB	ARR	KAS:ABZ
ADB	ARR	KAS:ALA|NUM:S|MUG:M
ADB	ARR	KAS:ALA|POS:POSaurrera|POS:+
ADB	ARR	KAS:EM|NUM:S|MUG:M|POS:POSondotik|POS:+
ADB	ARR	KAS:ERG|NUM:S|MUG:M
ADB	ARR	KAS:GEL
ADB	ARR	KAS:GEL|ENT:Erakundea
ADB	ARR	KAS:GEL|MW:B
ADB	ARR	KAS:GEL|NUM:S|MUG:M|MW:B
ADB	ARR	KAS:GEN|NUM:S|MUG:M
ADB	ARR	KAS:INE
ADB	ARR	KAS:INE|MUG:MG
ADB	ARR	KAS:INE|NUM:P|MUG:M
ADB	ARR	KAS:INE|NUM:P|MUG:M|POS:POSartean|POS:+
ADB	ARR	KAS:INE|NUM:S|MUG:M
ADB	ARR	KAS:INS|MUG:MG
ADB	ARR	MAI:GEHI
ADB	ARR	MAI:KONP
ADB	ARR	MAI:KONP|KAS:ABS|MUG:MG
ADB	ARR	MAI:KONP|KAS:ABZ
ADB	ARR	MAI:KONP|KAS:GEL
ADB	ARR	MAI:SUP
ADB	ARR	MAI:SUP|KAS:PAR|MUG:MG
ADB	ARR	MUG:M|MW:B
ADB	ARR	MW:B
ADB	ARR	MW:B|ENT:Erakundea
ADB	ARR	MW:B|KAS:EM|POS:POSgabe|POS:+
ADB	ARR	MW:B|KAS:INE|POS:POSaurrean|POS:+
ADB	ARR	POS:POSantzean|POS:+|KAS:INE
ADB	ARR	POS:POSantzeko|POS:+|KAS:EM
ADB	ARR	POS:POSartean|POS:+|KAS:INE
ADB	ARR	POS:POSartekoak|POS:+|KAS:ABS
ADB	ARR	POS:POSarteko|POS:+|KAS:GEL
ADB	ARR	POS:POSarte|POS:+|KAS:ABS
ADB	ARR	POS:POSatzera|POS:+|KAS:EM
ADB	ARR	POS:POSaurrean|POS:+|KAS:INE
ADB	ARR	POS:POSaurrerako|POS:+|KAS:GEL
ADB	ARR	POS:POSaurrera|POS:+|KAS:ALA
ADB	ARR	POS:POSaurrera|POS:+|KAS:EM
ADB	ARR	POS:POSaurretik|POS:+|KAS:ABL
ADB	ARR	POS:POSbarruan|POS:+|KAS:INE
ADB	ARR	POS:POSbehera|POS:+|KAS:ALA
ADB	ARR	POS:POSbezalakoa|POS:+|KAS:ABS
ADB	ARR	POS:POSbezala|POS:+|KAS:EM
ADB	ARR	POS:POSgainean|POS:+|KAS:INE
ADB	ARR	POS:POSgibeleko|POS:+|KAS:GEL
ADB	ARR	POS:POSgisa|POS:+|KAS:ABS
ADB	ARR	POS:POSgoiko|POS:+|KAS:GEL
ADB	ARR	POS:POSgoitik|POS:+|KAS:ABL
ADB	ARR	POS:POSgorako|POS:+|KAS:GEL
ADB	ARR	POS:POSgora|POS:+|KAS:EM
ADB	ARR	POS:POSinguruko|POS:+|KAS:GEL
ADB	ARR	POS:POSkanpoko|POS:+|KAS:GEL
ADB	ARR	POS:POSlanda|POS:+|KAS:ABS
ADB	ARR	POS:POSlegez|POS:+|KAS:EM
ADB	ARR	POS:POSzain|POS:+|KAS:EM
ADB	ARR	POS:POSzehar|POS:+|KAS:EM
ADB	ARR	_
ADB	GAL	ENT:Pertsona
ADB	GAL	ENT:Tokia
ADB	GAL	KAS:ABU
ADB	GAL	KAS:GEL
ADB	GAL	POS:POSarte|POS:+|KAS:ABS
ADB	GAL	_
ADI	ADI_IZEELI	ADM:ADIZE|KAS:ABS|NUM:P|MUG:M
ADI	ADI_IZEELI	ADM:ADIZE|KAS:ABS|NUM:S|MUG:M
ADI	ADI_IZEELI	ADM:ADIZE|KAS:INE|NUM:S|MUG:M
ADI	ADI_IZEELI	ADM:PART|KAS:ABS|NUM:P|MUG:M
ADI	ADI_IZEELI	ADM:PART|KAS:ABS|NUM:S|MUG:M
ADI	ADI_IZEELI	ADM:PART|KAS:DAT|NUM:P|MUG:M
ADI	ADI_IZEELI	ADM:PART|KAS:ERG|NUM:P|MUG:M
ADI	ADI_IZEELI	ADM:PART|KAS:ERG|NUM:S|MUG:M
ADI	ADI_IZEELI	ADM:PART|KAS:GEN|NUM:P|MUG:M
ADI	ADI_IZEELI	ADM:PART|KAS:GEN|NUM:S|MUG:M
ADI	ADI_IZEELI	ADM:PART|KAS:INE|NUM:P|MUG:M
ADI	ADI_IZEELI	ADM:PART|KAS:INE|NUM:S|MUG:M
ADI	ADI_IZEELI	ADM:PART|KAS:INS|NUM:S|MUG:M
ADI	ADI_IZEELI	ADM:PART|KAS:SOZ|NUM:S|MUG:M
ADI	ADI_IZEELI	MAI:SUP|ADM:PART|KAS:ABS|NUM:S|MUG:M
ADI	ADK	ADM:ADIZE|ERL:DENB|KAS:INE|MW:B
ADI	ADK	ADM:ADIZE|ERL:HELB|KAS:ABS|MUG:MG|MW:B
ADI	ADK	ADM:ADIZE|ERL:HELB|KAS:ALA|MW:B
ADI	ADK	ADM:ADIZE|ERL:KONPL|KAS:ABS|MUG:MG|MW:B
ADI	ADK	ADM:ADIZE|ERL:KONPL|KAS:ABS|MW:B
ADI	ADK	ADM:ADIZE|ERL:KONPL|KAS:INE
ADI	ADK	ADM:ADIZE|ERL:KONPL|KAS:INE|MW:B
ADI	ADK	ADM:ADIZE|ERL:KONPL|KAS:PAR|ENT:Erakundea
ADI	ADK	ADM:ADIZE|ERL:KONPL|KAS:PAR|MW:B
ADI	ADK	ADM:ADIZE|ERL:KONPL|KAS:PAR|MW:B|ENT:Erakundea
ADI	ADK	ADM:ADIZE|ERL:KONT|KAS:MOT
ADI	ADK	ADM:ADIZE|ERL:KONT|KAS:MOT|NUM:S|MUG:M|MW:B
ADI	ADK	ADM:ADIZE|ERL:MOD|KAS:INE
ADI	ADK	ADM:ADIZE|ERL:MOD|KAS:INE|MW:B
ADI	ADK	ADM:ADIZE|KAS:ABS|MW:B
ADI	ADK	ADM:ADIZE|KAS:ABS|NUM:P|MUG:M|MW:B
ADI	ADK	ADM:ADIZE|KAS:DAT|NUM:S|MUG:M|MW:B
ADI	ADK	ADM:ADIZE|KAS:ERG|NUM:S|MUG:M|MW:B
ADI	ADK	ADM:ADIZE|KAS:GEL|MW:B
ADI	ADK	ADM:ADIZE|KAS:GEN|NUM:S|MUG:M|MW:B
ADI	ADK	ADM:ADIZE|KAS:INS|NUM:S|MUG:M|MW:B
ADI	ADK	ADM:ADIZE|MW:B
ADI	ADK	ADM:ADOIN
ADI	ADK	ADM:ADOIN|ASP:EZBU
ADI	ADK	ADM:ADOIN|ASP:EZBU|MW:B
ADI	ADK	ADM:ADOIN|MW:B
ADI	ADK	ADM:PART|ASP:BURU
ADI	ADK	ADM:PART|ASP:BURU|MW:B
ADI	ADK	ADM:PART|ASP:GERO|MW:B
ADI	ADK	ADM:PART|ERL:MOD|MW:B
ADI	ADK	ADM:PART|KAS:ABS|MUG:MG|MW:B
ADI	ADK	ADM:PART|KAS:ABS|NUM:P|MUG:M
ADI	ADK	ADM:PART|KAS:ABS|NUM:P|MUG:M|MW:B
ADI	ADK	ADM:PART|KAS:GEL
ADI	ADK	ADM:PART|KAS:GEL|MW:B
ADI	ADK	ADM:PART|KAS:GEN|NUM:S|MUG:M|MW:B
ADI	ADK	ADM:PART|KAS:INS|MUG:MG|MW:B
ADI	ADK	ADM:PART|KAS:PAR|MUG:MG|MW:B
ADI	ADK	ADM:PART|MW:B
ADI	ADK	ASP:GERO
ADI	ADK	ASP:PNT|ERL:BALD|MDN:A1|NOR:GU|MW:B
ADI	ADK	ASP:PNT|ERL:BALD|MDN:A1|NOR:HAIEK|MW:B
ADI	ADK	ASP:PNT|ERL:BALD|MDN:A1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|ERL:BALD|MDN:A1|NOR:HURA|NORK:GUK|MW:B
ADI	ADK	ASP:PNT|ERL:BALD|MDN:A1|NOR:HURA|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|ERL:BALD|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|ERL:BALD|MDN:A1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:BALD|MDN:A1|NOR:HURA|NORK:ZUK|MW:B
ADI	ADK	ASP:PNT|ERL:BALD|MDN:A1|NOR:ZU|MW:B
ADI	ADK	ASP:PNT|ERL:BALD|MDN:B1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:BALD|MDN:B4|NOR:GU|MW:B
ADI	ADK	ASP:PNT|ERL:DENB|MDN:A1|NOR:GU|MW:B
ADI	ADK	ASP:PNT|ERL:DENB|MDN:A1|NOR:HAIEK|MW:B
ADI	ADK	ASP:PNT|ERL:DENB|MDN:A1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|ERL:DENB|MDN:A1|NOR:HURA|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|ERL:DENB|MDN:A1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:DENB|MDN:A1|NOR:HURA|NORK:NIK|MW:B
ADI	ADK	ASP:PNT|ERL:DENB|MDN:B1|NOR:HAIEK|MW:B
ADI	ADK	ASP:PNT|ERL:DENB|MDN:B1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|ERL:DENB|MDN:B1|NOR:HURA|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|ERL:DENB|MDN:B1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:A1|NOR:GU|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:A1|NOR:GU|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HAIEK|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HAIEK|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HAIEK|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORK:GUK|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORK:NIK|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HAIEK|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HAIEK|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HURA|NORK:GUK|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HURA|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HURA|NORK:HARK|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HURA|NORK:NIK|MW:B
ADI	ADK	ASP:PNT|ERL:ERLT|MDN:B2|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:KAUS|MDN:A1|NOR:GU|MW:B
ADI	ADK	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HAIEK|MW:B
ADI	ADK	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HAIEK|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HAIEK|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORK:GUK|MW:B
ADI	ADK	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HAIEI|MW:B
ADI	ADK	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORK:HARK|NORI:HAIEI|MW:B
ADI	ADK	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORK:NIK|MW:B
ADI	ADK	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORK:ZUK|MW:B
ADI	ADK	ASP:PNT|ERL:KAUS|MDN:B1|NOR:HAIEK|MW:B
ADI	ADK	ASP:PNT|ERL:KAUS|MDN:B1|NOR:HURA|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|ERL:KAUS|MDN:B1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:A1|NOR:GU|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HAIEK|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HAIEK|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HAIEK|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HI|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|NORI:NIRI|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|NORK:GUK|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HAIEI|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:A1|NOR:ZU|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HAIEK|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HAIEK|NORI:HAIEI|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HURA|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HURA|NORK:GUK|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HURA|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HURA|NORK:HIK|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HURA|NORK:NIK|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HURA|NORK:ZUEK-K|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:B1|NOR:NI|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:B1|NOR:NI|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:KONPL|MDN:B2|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|ERL:MOD/DENB|MDN:A1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|ERL:MOD/DENB|MDN:A1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:MOD/DENB|MDN:B1|NOR:HAIEK|MW:B
ADI	ADK	ASP:PNT|ERL:MOD/DENB|MDN:B1|NOR:HAIEK|NORI:NIRI|MW:B
ADI	ADK	ASP:PNT|ERL:MOD/DENB|MDN:B1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|ERL:MOD/DENB|MDN:B1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:MOD|MDN:A1|NOR:HAIEK|MW:B
ADI	ADK	ASP:PNT|ERL:MOS|MDN:A1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|ERL:MOS|MDN:A1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:MOS|MDN:B1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|ERL:MOS|MDN:B1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:MOS|MDN:B4|NOR:HAIEK|MW:B
ADI	ADK	ASP:PNT|ERL:MOS|MDN:B4|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:MOS|MDN:B4|NOR:HURA|NORK:HARK|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|ERL:ZHG|MDN:A1|NOR:GU|MW:B
ADI	ADK	ASP:PNT|ERL:ZHG|MDN:A1|NOR:HAIEK|MW:B
ADI	ADK	ASP:PNT|ERL:ZHG|MDN:A1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|ERL:ZHG|MDN:A1|NOR:HURA|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|ERL:ZHG|MDN:A1|NOR:HURA|NORK:GUK|MW:B
ADI	ADK	ASP:PNT|ERL:ZHG|MDN:A1|NOR:HURA|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|ERL:ZHG|MDN:A1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|ERL:ZHG|MDN:A1|NOR:HURA|NORK:NIK|MW:B
ADI	ADK	ASP:PNT|ERL:ZHG|MDN:A1|NOR:ZU|MW:B
ADI	ADK	ASP:PNT|ERL:ZHG|MDN:B1|NOR:HAIEK|MW:B
ADI	ADK	ASP:PNT|KAS:ABS|NUM:P|MUG:M|MDN:B1|NOR:HURA|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:NIK|MW:B
ADI	ADK	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:ZUK|MW:B
ADI	ADK	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORK:GUK|MW:B
ADI	ADK	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|KAS:ALA|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|KAS:DAT|NUM:S|MUG:M|MDN:A1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|KAS:DES|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|KAS:ERG|NUM:P|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|KAS:ERG|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|KAS:GEN|NUM:P|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|KAS:GEN|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|KAS:PAR|MUG:MG|MDN:A1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:GU|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HAIEK|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HAIEK|NORI:HAIEI|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HAIEK|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HAIEK|NORK:GUK|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HAIEK|NORK:GUK|MW:B|ENT:Erakundea
ADI	ADK	ASP:PNT|MDN:A1|NOR:HAIEK|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HAIEK|NORK:HAIEK-K|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HAIEK|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HAIEK|NORK:HARK|NORI:HAIEI|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HAIEK|NORK:NIK|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HAIEK|NORK:NIK|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HAIEK|NORK:ZUEK-K|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|HIT:NO|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORI:GURI|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORI:HAIEI|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORI:HIRI-NO|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORI:NIRI|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:GUK|HIT:NO|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:GUK|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:GUK|MW:B|ENT:Pertsona
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:GUK|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:GUK|NORI:HIRI-TO|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:HARK|HIT:NO|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:HARK|HIT:TO|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:HARK|NORI:GURI|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:HARK|NORI:HAIEI|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:HIK-TO|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:NIK|HIT:NO|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:NIK|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:NIK|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:NIK|NORI:ZUEI|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:HURA|NORK:ZUK|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:NI|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:NI|NORK:ZUK|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:ZUEK|MW:B
ADI	ADK	ASP:PNT|MDN:A1|NOR:ZU|NORK:NIK|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:GU|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:HAIEK|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:HAIEK|NORI:NIRI|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:HAIEK|NORK:GUK|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:HAIEK|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:HAIEK|NORK:HARK|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:HAIEK|NORK:NIK|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:HURA|HIT:NO|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:HURA|NORI:HAIEI|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:HURA|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:HURA|NORK:GUK|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:HURA|NORK:HAIEK-K|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:HURA|NORK:HARK|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:HURA|NORK:NIK|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:HURA|NORK:NIK|NORI:HARI|MW:B
ADI	ADK	ASP:PNT|MDN:B1|NOR:NI|MW:B
ADI	ADK	ASP:PNT|MDN:B2|NOR:HAIEK|NORK:HIK|MW:B
ADI	ADK	ASP:PNT|MDN:B2|NOR:HURA|MW:B
ADI	ADK	ASP:PNT|MDN:B2|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	ASP:PNT|MDN:B2|NOR:HURA|NORK:NIK|HIT:NO|MW:B
ADI	ADK	ASP:PNT|MDN:B2|NOR:HURA|NORK:NIK|MW:B
ADI	ADK	ASP:PNT|MDN:B3|NOR:HURA|NORK:NIK|MW:B
ADI	ADK	ASP:PNT|MOD:EGI|MDN:A1|NOR:HURA|NORK:NIK|MW:B
ADI	ADK	ASP:PNT|MOD:EGI|MDN:B1|NOR:HURA|NORK:HARK|MW:B
ADI	ADK	MW:B
ADI	ADP	ADM:ADOIN|ASP:BURU|ERL:MOD
ADI	ADP	ASP:BURU
ADI	ADP	ASP:GERO
ADI	FAK	ADM:ADIZE|ERL:HELB|KAS:ABS|MUG:MG
ADI	FAK	ADM:ADIZE|ERL:HELB|KAS:ALA
ADI	FAK	ADM:ADIZE|ERL:KONPL|KAS:ABS
ADI	FAK	ADM:ADIZE|ERL:KONPL|KAS:INE
ADI	FAK	ADM:ADIZE|KAS:ABU
ADI	FAK	ADM:ADIZE|KAS:DAT|NUM:S|MUG:M
ADI	FAK	ADM:ADIZE|KAS:GEL
ADI	FAK	ADM:ADIZE|KAS:INS|NUM:S|MUG:M
ADI	FAK	ADM:ADOIN
ADI	FAK	ADM:ADOIN|ASP:EZBU
ADI	FAK	ADM:PART
ADI	FAK	ADM:PART|ASP:BURU
ADI	FAK	ADM:PART|ASP:GERO
ADI	FAK	ADM:PART|ERL:MOD
ADI	FAK	ADM:PART|KAS:ABS|MUG:MG
ADI	FAK	ADM:PART|KAS:ABS|NUM:S|MUG:M
ADI	FAK	ADM:PART|KAS:GEL
ADI	FAK	ADM:PART|KAS:INS|MUG:MG
ADI	FAK	ASP:EZBU
ADI	FAK	PLU:-|ADM:PART|ASP:BURU
ADI	SIN	ADM:ADIZE
ADI	SIN	ADM:ADIZE|ERL:BALD|KAS:INE
ADI	SIN	ADM:ADIZE|ERL:DENB|KAS:ABS
ADI	SIN	ADM:ADIZE|ERL:DENB|KAS:INE
ADI	SIN	ADM:ADIZE|ERL:HELB|KAS:ABS|MUG:MG
ADI	SIN	ADM:ADIZE|ERL:HELB|KAS:ALA
ADI	SIN	ADM:ADIZE|ERL:HELB|KAS:INE
ADI	SIN	ADM:ADIZE|ERL:KONPL|KAS:ABS
ADI	SIN	ADM:ADIZE|ERL:KONPL|KAS:ABS|ENT:Erakundea
ADI	SIN	ADM:ADIZE|ERL:KONPL|KAS:ABS|MUG:MG
ADI	SIN	ADM:ADIZE|ERL:KONPL|KAS:ABS|NUM:P|MUG:M
ADI	SIN	ADM:ADIZE|ERL:KONPL|KAS:ABS|NUM:S|MUG:M
ADI	SIN	ADM:ADIZE|ERL:KONPL|KAS:INE
ADI	SIN	ADM:ADIZE|ERL:KONPL|KAS:PAR
ADI	SIN	ADM:ADIZE|ERL:KONT|KAS:MOT
ADI	SIN	ADM:ADIZE|ERL:KONT|KAS:MOT|NUM:S|MUG:M
ADI	SIN	ADM:ADIZE|ERL:MOD|KAS:INE
ADI	SIN	ADM:ADIZE|KAS:ABL
ADI	SIN	ADM:ADIZE|KAS:ABU
ADI	SIN	ADM:ADIZE|KAS:DAT|NUM:S|MUG:M
ADI	SIN	ADM:ADIZE|KAS:ERG|NUM:S|MUG:M
ADI	SIN	ADM:ADIZE|KAS:GEL
ADI	SIN	ADM:ADIZE|KAS:GEN|NUM:S|MUG:M
ADI	SIN	ADM:ADIZE|KAS:INS|NUM:S|MUG:M
ADI	SIN	ADM:ADIZE|KAS:SOZ|NUM:S|MUG:M
ADI	SIN	ADM:ADOIN
ADI	SIN	ADM:ADOIN|ASP:EZBU
ADI	SIN	ADM:ADOIN|ENT:Pertsona
ADI	SIN	ADM:ADOIN|ERL:MOD
ADI	SIN	ADM:PART
ADI	SIN	ADM:PART|ASP:BURU
ADI	SIN	ADM:PART|ASP:GERO
ADI	SIN	ADM:PART|ERL:KONT|KAS:MOT|NUM:S|MUG:M
ADI	SIN	ADM:PART|ERL:MOD
ADI	SIN	ADM:PART|KAS:ABL|NUM:P|MUG:M
ADI	SIN	ADM:PART|KAS:ABL|NUM:S|MUG:M
ADI	SIN	ADM:PART|KAS:ABS|MUG:MG
ADI	SIN	ADM:PART|KAS:ABS|NUM:P|MUG:M
ADI	SIN	ADM:PART|KAS:ABS|NUM:P|MUG:M|ENT:Erakundea
ADI	SIN	ADM:PART|KAS:ABS|NUM:S|MUG:M
ADI	SIN	ADM:PART|KAS:ALA|MUG:MG
ADI	SIN	ADM:PART|KAS:ALA|NUM:P|MUG:M
ADI	SIN	ADM:PART|KAS:ALA|NUM:S|MUG:M
ADI	SIN	ADM:PART|KAS:DAT|NUM:P|MUG:M
ADI	SIN	ADM:PART|KAS:DAT|NUM:S|MUG:M
ADI	SIN	ADM:PART|KAS:ERG|NUM:P|MUG:M
ADI	SIN	ADM:PART|KAS:ERG|NUM:S|MUG:M
ADI	SIN	ADM:PART|KAS:GEL
ADI	SIN	ADM:PART|KAS:GEL|MUG:MG
ADI	SIN	ADM:PART|KAS:GEL|NUM:P|MUG:M
ADI	SIN	ADM:PART|KAS:GEL|NUM:S|MUG:M
ADI	SIN	ADM:PART|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea
ADI	SIN	ADM:PART|KAS:GEL|NUM:S|MUG:M|ENT:Tokia
ADI	SIN	ADM:PART|KAS:GEN|MUG:MG
ADI	SIN	ADM:PART|KAS:GEN|NUM:P|MUG:M
ADI	SIN	ADM:PART|KAS:GEN|NUM:P|MUG:M|ENT:Tokia
ADI	SIN	ADM:PART|KAS:GEN|NUM:S|MUG:M
ADI	SIN	ADM:PART|KAS:INE|NUM:P|MUG:M
ADI	SIN	ADM:PART|KAS:INE|NUM:S|MUG:M
ADI	SIN	ADM:PART|KAS:INE|NUM:S|MUG:M|ENT:Tokia
ADI	SIN	ADM:PART|KAS:INS|MUG:MG
ADI	SIN	ADM:PART|KAS:INS|NUM:P|MUG:M
ADI	SIN	ADM:PART|KAS:INS|NUM:S|MUG:M
ADI	SIN	ADM:PART|KAS:PAR|MUG:MG
ADI	SIN	ADM:PART|KAS:PRO|MUG:MG
ADI	SIN	ADM:PART|KAS:SOZ|NUM:P|MUG:M
ADI	SIN	ADM:PART|KAS:SOZ|NUM:S|MUG:M
ADI	SIN	ASP:EZBU
ADI	SIN	ASP:GERO
ADI	SIN	MAI:KONP|ADM:PART|KAS:ABS|MUG:MG
ADI	SIN	MAI:KONP|ADM:PART|KAS:ABS|NUM:P|MUG:M
ADI	SIN	MAI:KONP|ADM:PART|KAS:ABS|NUM:S|MUG:M
ADI	SIN	MAI:SUP|ADM:PART|KAS:ABS|NUM:P|MUG:M
ADI	SIN	MAI:SUP|ADM:PART|KAS:ABS|NUM:S|MUG:M
ADI	SIN	MAI:SUP|ADM:PART|KAS:GEN|NUM:P|MUG:M
ADI	SIN	MAI:SUP|ADM:PART|KAS:INE|NUM:S|MUG:M
ADJ	ADJ	NUM:S|MUG:M|MW:B
ADJ	ARR	BIZ:-
ADJ	ARR	BIZ:-|KAS:ABS|MUG:MG
ADJ	ARR	BIZ:-|KAS:ABS|NUM:P|MUG:M
ADJ	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M
ADJ	ARR	BIZ:-|KAS:DAT|NUM:P|MUG:M
ADJ	ARR	BIZ:-|KAS:ERG|NUM:S|MUG:M
ADJ	ARR	BIZ:-|KAS:INE|MUG:MG
ADJ	ARR	BIZ:-|MUG:M|MW:B|ENT:Erakundea
ADJ	ARR	ENT:Erakundea
ADJ	ARR	ENT:Tokia
ADJ	ARR	IZAUR:+
ADJ	ARR	IZAUR:+|ENT:Erakundea
ADJ	ARR	IZAUR:+|ENT:Pertsona
ADJ	ARR	IZAUR:+|ENT:Tokia
ADJ	ARR	IZAUR:+|KAS:ABL|NUM:P|MUG:M|POS:POSaurretik|POS:+
ADJ	ARR	IZAUR:+|KAS:ABL|NUM:P|MUG:M|POS:POSeskutik|POS:+
ADJ	ARR	IZAUR:+|KAS:ABL|NUM:P|MUG:M|POS:POSgainetik|POS:+
ADJ	ARR	IZAUR:+|KAS:ABL|NUM:S|MUG:M|POS:POSaurretik|POS:+
ADJ	ARR	IZAUR:+|KAS:ABL|NUM:S|MUG:M|POS:POSgibeletik|POS:+
ADJ	ARR	IZAUR:+|KAS:ABS|MUG:MG
ADJ	ARR	IZAUR:+|KAS:ABS|NUM:P|MUG:M
ADJ	ARR	IZAUR:+|KAS:ABS|NUM:S|MUG:M
ADJ	ARR	IZAUR:+|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:+|KAS:ABS|NUM:S|MUG:M|MW:B
ADJ	ARR	IZAUR:+|KAS:ABS|NUM:S|MUG:M|POS:POSaurka|POS:+
ADJ	ARR	IZAUR:+|KAS:DAT|NUM:P|MUG:M
ADJ	ARR	IZAUR:+|KAS:DAT|NUM:S|MUG:M
ADJ	ARR	IZAUR:+|KAS:DES|MUG:MG
ADJ	ARR	IZAUR:+|KAS:DES|NUM:S|MUG:M
ADJ	ARR	IZAUR:+|KAS:EM|NUM:P|MUG:M|POS:POSarteko|POS:+
ADJ	ARR	IZAUR:+|KAS:EM|NUM:S|MUG:M|POS:POSkontra|POS:+
ADJ	ARR	IZAUR:+|KAS:ERG|MUG:MG
ADJ	ARR	IZAUR:+|KAS:ERG|NUM:P|MUG:M
ADJ	ARR	IZAUR:+|KAS:ERG|NUM:S|MUG:M
ADJ	ARR	IZAUR:+|KAS:GEL|NUM:P|MUG:M
ADJ	ARR	IZAUR:+|KAS:GEL|NUM:P|MUG:M|POS:POSarteko|POS:+
ADJ	ARR	IZAUR:+|KAS:GEL|NUM:P|MUG:M|POS:POSaurkako|POS:+
ADJ	ARR	IZAUR:+|KAS:GEL|NUM:P|MUG:M|POS:POSkontrako|POS:+
ADJ	ARR	IZAUR:+|KAS:GEL|NUM:S|MUG:M
ADJ	ARR	IZAUR:+|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:+|KAS:GEL|NUM:S|MUG:M|ENT:Tokia
ADJ	ARR	IZAUR:+|KAS:GEL|NUM:S|MUG:M|POS:POSkontrako|POS:+
ADJ	ARR	IZAUR:+|KAS:GEN|NUM:P|MUG:M
ADJ	ARR	IZAUR:+|KAS:GEN|NUM:P|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:+|KAS:GEN|NUM:S|MUG:M
ADJ	ARR	IZAUR:+|KAS:GEN|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:+|KAS:INE|MUG:MG
ADJ	ARR	IZAUR:+|KAS:INE|NUM:P|MUG:M
ADJ	ARR	IZAUR:+|KAS:INE|NUM:P|MUG:M|POS:POSartean|POS:+
ADJ	ARR	IZAUR:+|KAS:INE|NUM:S|MUG:M
ADJ	ARR	IZAUR:+|KAS:INE|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:+|KAS:INE|NUM:S|MUG:M|POS:POSaurrean|POS:+
ADJ	ARR	IZAUR:+|KAS:INS|MUG:MG
ADJ	ARR	IZAUR:+|KAS:INS|NUM:P|MUG:M
ADJ	ARR	IZAUR:+|KAS:INS|NUM:S|MUG:M
ADJ	ARR	IZAUR:+|KAS:MOT|NUM:S|MUG:M
ADJ	ARR	IZAUR:+|KAS:PAR|MUG:MG
ADJ	ARR	IZAUR:+|KAS:PRO|MUG:MG
ADJ	ARR	IZAUR:+|KAS:SOZ|NUM:P|MUG:M
ADJ	ARR	IZAUR:+|KAS:SOZ|NUM:S|MUG:M
ADJ	ARR	IZAUR:+|MW:B
ADJ	ARR	IZAUR:+|POS:POSinguruetan|POS:+|KAS:INE
ADJ	ARR	IZAUR:-
ADJ	ARR	IZAUR:-|ENT:Erakundea
ADJ	ARR	IZAUR:-|ENT:Pertsona
ADJ	ARR	IZAUR:-|ENT:Tokia
ADJ	ARR	IZAUR:-|KAS:ABL|MUG:MG
ADJ	ARR	IZAUR:-|KAS:ABL|MUG:MG|POS:POSgainetik|POS:+
ADJ	ARR	IZAUR:-|KAS:ABL|NUM:P|MUG:M
ADJ	ARR	IZAUR:-|KAS:ABL|NUM:P|MUG:M|POS:POSaldetik|POS:+
ADJ	ARR	IZAUR:-|KAS:ABL|NUM:P|MUG:M|POS:POSazpitik|POS:+
ADJ	ARR	IZAUR:-|KAS:ABL|NUM:P|MUG:M|POS:POSondotik|POS:+
ADJ	ARR	IZAUR:-|KAS:ABL|NUM:S|MUG:M
ADJ	ARR	IZAUR:-|KAS:ABL|NUM:S|MUG:M|ENT:???
ADJ	ARR	IZAUR:-|KAS:ABL|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:-|KAS:ABL|NUM:S|MUG:M|ENT:Tokia
ADJ	ARR	IZAUR:-|KAS:ABS|MUG:MG
ADJ	ARR	IZAUR:-|KAS:ABS|MUG:MG|ENT:???
ADJ	ARR	IZAUR:-|KAS:ABS|MUG:MG|ENT:Erakundea
ADJ	ARR	IZAUR:-|KAS:ABS|MUG:MG|POS:POSaurka|POS:+
ADJ	ARR	IZAUR:-|KAS:ABS|MUG:MG|POS:POSgain|POS:+
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:P
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:PH|MUG:M
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:P|MUG:M
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:P|MUG:M|ENT:???
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:P|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:P|MUG:M|POS:POSalde|POS:+
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:P|MUG:M|POS:POSaurka|POS:+
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:P|MUG:M|POS:POSesker|POS:+
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:S|MUG:M
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:S|MUG:M|ENT:???
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:S|MUG:M|ENT:Tokia
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:S|MUG:M|MW:B
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:S|MUG:M|POS:POSalde|POS:+
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:S|MUG:M|POS:POSarteko|POS:+
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:S|MUG:M|POS:POSaurka|POS:+
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:S|MUG:M|POS:POSesker|POS:+
ADJ	ARR	IZAUR:-|KAS:ABS|NUM:S|MUG:M|POS:POSesku|POS:+
ADJ	ARR	IZAUR:-|KAS:ABU|NUM:P|MUG:M
ADJ	ARR	IZAUR:-|KAS:ABU|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:-|KAS:ABZ|NUM:S|MUG:M
ADJ	ARR	IZAUR:-|KAS:ABZ|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:-|KAS:ABZ|NUM:S|MUG:M|ENT:Pertsona
ADJ	ARR	IZAUR:-|KAS:ABZ|NUM:S|MUG:M|ENT:Tokia
ADJ	ARR	IZAUR:-|KAS:ALA|MUG:MG
ADJ	ARR	IZAUR:-|KAS:ALA|NUM:P|MUG:M
ADJ	ARR	IZAUR:-|KAS:ALA|NUM:P|MUG:M|POS:POSgainera|POS:+
ADJ	ARR	IZAUR:-|KAS:ALA|NUM:S|MUG:M
ADJ	ARR	IZAUR:-|KAS:ALA|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:-|KAS:ALA|NUM:S|MUG:M|ENT:Tokia
ADJ	ARR	IZAUR:-|KAS:ALA|NUM:S|MUG:M|POS:POSalderat|POS:+
ADJ	ARR	IZAUR:-|KAS:ALA|NUM:S|MUG:M|POS:POSaurrera|POS:+
ADJ	ARR	IZAUR:-|KAS:ALA|NUM:S|MUG:M|POS:POSbatera|POS:+
ADJ	ARR	IZAUR:-|KAS:BNK|MUG:MG
ADJ	ARR	IZAUR:-|KAS:DAT|MUG:MG
ADJ	ARR	IZAUR:-|KAS:DAT|NUM:P|MUG:M
ADJ	ARR	IZAUR:-|KAS:DAT|NUM:S|MUG:M
ADJ	ARR	IZAUR:-|KAS:DAT|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:-|KAS:DES|MUG:MG
ADJ	ARR	IZAUR:-|KAS:DES|NUM:P|MUG:M
ADJ	ARR	IZAUR:-|KAS:DES|NUM:S|MUG:M
ADJ	ARR	IZAUR:-|KAS:EM|MUG:MG|POS:POSgabe|POS:+
ADJ	ARR	IZAUR:-|KAS:EM|NUM:P|MUG:M|POS:POSarabera|POS:+
ADJ	ARR	IZAUR:-|KAS:EM|NUM:P|MUG:M|POS:POSbezala|POS:+
ADJ	ARR	IZAUR:-|KAS:EM|NUM:P|MUG:M|POS:POSbila|POS:+
ADJ	ARR	IZAUR:-|KAS:EM|NUM:P|MUG:M|POS:POSburuz|POS:+
ADJ	ARR	IZAUR:-|KAS:EM|NUM:P|MUG:M|POS:POSzain|POS:+
ADJ	ARR	IZAUR:-|KAS:EM|NUM:P|MUG:M|POS:POSzehar|POS:+
ADJ	ARR	IZAUR:-|KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSarabera|POS:+
ADJ	ARR	IZAUR:-|KAS:EM|NUM:S|MUG:M|POS:POSarabera|POS:+
ADJ	ARR	IZAUR:-|KAS:EM|NUM:S|MUG:M|POS:POSbarna|POS:+
ADJ	ARR	IZAUR:-|KAS:EM|NUM:S|MUG:M|POS:POSbatera|POS:+
ADJ	ARR	IZAUR:-|KAS:EM|NUM:S|MUG:M|POS:POSbegira|POS:+
ADJ	ARR	IZAUR:-|KAS:EM|NUM:S|MUG:M|POS:POSbezala|POS:+
ADJ	ARR	IZAUR:-|KAS:EM|NUM:S|MUG:M|POS:POSburuz|POS:+
ADJ	ARR	IZAUR:-|KAS:EM|NUM:S|MUG:M|POS:POSgora|POS:+
ADJ	ARR	IZAUR:-|KAS:EM|NUM:S|MUG:M|POS:POSondoren|POS:+
ADJ	ARR	IZAUR:-|KAS:EM|NUM:S|MUG:M|POS:POSordez|POS:+
ADJ	ARR	IZAUR:-|KAS:EM|NUM:S|MUG:M|POS:POSzehar|POS:+
ADJ	ARR	IZAUR:-|KAS:ERG|MUG:MG
ADJ	ARR	IZAUR:-|KAS:ERG|MUG:MG|ENT:Pertsona
ADJ	ARR	IZAUR:-|KAS:ERG|NUM:PH|MUG:M
ADJ	ARR	IZAUR:-|KAS:ERG|NUM:P|MUG:M
ADJ	ARR	IZAUR:-|KAS:ERG|NUM:P|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:-|KAS:ERG|NUM:S|MUG:M
ADJ	ARR	IZAUR:-|KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:-|KAS:GEL|MUG:MG
ADJ	ARR	IZAUR:-|KAS:GEL|MUG:MG|POS:POSarteko|POS:+
ADJ	ARR	IZAUR:-|KAS:GEL|MUG:MG|POS:POSburuzko|POS:+
ADJ	ARR	IZAUR:-|KAS:GEL|MUG:MG|POS:POSgabeko|POS:+
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:P|MUG:M
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:P|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:P|MUG:M|POS:POSarteko|POS:+
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:P|MUG:M|POS:POSaurkako|POS:+
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:P|MUG:M|POS:POSaurreko|POS:+
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:P|MUG:M|POS:POSburuzko|POS:+
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:P|MUG:M|POS:POSgaineko|POS:+
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:P|MUG:M|POS:POSinguruko|POS:+
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:P|MUG:M|POS:POSkontrako|POS:+
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:S|MUG:M
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:S|MUG:M|ENT:Pertsona
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:S|MUG:M|ENT:Tokia
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:S|MUG:M|POS:POSaldeko|POS:+
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:S|MUG:M|POS:POSarteko|POS:+
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:S|MUG:M|POS:POSburuzko|POS:+
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:S|MUG:M|POS:POSinguruko|POS:+
ADJ	ARR	IZAUR:-|KAS:GEL|NUM:S|MUG:M|POS:POSkontrako|POS:+
ADJ	ARR	IZAUR:-|KAS:GEN|MUG:MG
ADJ	ARR	IZAUR:-|KAS:GEN|NUM:P|MUG:M
ADJ	ARR	IZAUR:-|KAS:GEN|NUM:S|MUG:M
ADJ	ARR	IZAUR:-|KAS:GEN|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:-|KAS:INE|MUG:MG
ADJ	ARR	IZAUR:-|KAS:INE|NUM:PH|MUG:M
ADJ	ARR	IZAUR:-|KAS:INE|NUM:P|MUG:M
ADJ	ARR	IZAUR:-|KAS:INE|NUM:P|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:-|KAS:INE|NUM:P|MUG:M|POS:POSartean|POS:+
ADJ	ARR	IZAUR:-|KAS:INE|NUM:P|MUG:M|POS:POSaurrean|POS:+
ADJ	ARR	IZAUR:-|KAS:INE|NUM:P|MUG:M|POS:POSazpian|POS:+
ADJ	ARR	IZAUR:-|KAS:INE|NUM:P|MUG:M|POS:POSinguruan|POS:+
ADJ	ARR	IZAUR:-|KAS:INE|NUM:P|MUG:M|POS:POSondoan|POS:+
ADJ	ARR	IZAUR:-|KAS:INE|NUM:P|MUG:M|POS:POSostean|POS:+
ADJ	ARR	IZAUR:-|KAS:INE|NUM:S|MUG:M
ADJ	ARR	IZAUR:-|KAS:INE|NUM:S|MUG:M|ENT:???
ADJ	ARR	IZAUR:-|KAS:INE|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:-|KAS:INE|NUM:S|MUG:M|ENT:Tokia
ADJ	ARR	IZAUR:-|KAS:INE|NUM:S|MUG:M|POS:POSartean|POS:+
ADJ	ARR	IZAUR:-|KAS:INE|NUM:S|MUG:M|POS:POSaurrean|POS:+
ADJ	ARR	IZAUR:-|KAS:INE|NUM:S|MUG:M|POS:POSgainean|POS:+
ADJ	ARR	IZAUR:-|KAS:INE|NUM:S|MUG:M|POS:POSinguruan|POS:+
ADJ	ARR	IZAUR:-|KAS:INS|MUG:MG
ADJ	ARR	IZAUR:-|KAS:INS|NUM:P|MUG:M
ADJ	ARR	IZAUR:-|KAS:INS|NUM:P|MUG:M|POS:POSbidez|POS:+
ADJ	ARR	IZAUR:-|KAS:INS|NUM:P|MUG:M|POS:POSbitartez|POS:+
ADJ	ARR	IZAUR:-|KAS:INS|NUM:S|MUG:M
ADJ	ARR	IZAUR:-|KAS:INS|NUM:S|MUG:M|ENT:Tokia
ADJ	ARR	IZAUR:-|KAS:INS|NUM:S|MUG:M|POS:POSbidez|POS:+
ADJ	ARR	IZAUR:-|KAS:MOT|NUM:P|MUG:M
ADJ	ARR	IZAUR:-|KAS:MOT|NUM:S|MUG:M
ADJ	ARR	IZAUR:-|KAS:PAR|MUG:MG
ADJ	ARR	IZAUR:-|KAS:PRO|MUG:MG
ADJ	ARR	IZAUR:-|KAS:SOZ|MUG:MG
ADJ	ARR	IZAUR:-|KAS:SOZ|NUM:P|MUG:M
ADJ	ARR	IZAUR:-|KAS:SOZ|NUM:S|MUG:M
ADJ	ARR	IZAUR:-|KAS:SOZ|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	IZAUR:-|MUG:M|MW:B
ADJ	ARR	IZAUR:-|MW:B
ADJ	ARR	IZAUR:-|POS:POSaldetik|POS:+|KAS:ABL
ADJ	ARR	IZAUR:-|POS:POSbarik|POS:+|KAS:EM
ADJ	ARR	IZAUR:-|POS:POSbezala|POS:+|KAS:EM
ADJ	ARR	IZAUR:-|POS:POSgisa|POS:+|KAS:ABS
ADJ	ARR	KAS:ABL|NUM:S|MUG:M
ADJ	ARR	KAS:ABS|MUG:MG
ADJ	ARR	KAS:ABS|NUM:P|MUG:M
ADJ	ARR	KAS:ABS|NUM:P|MUG:M|ENT:???
ADJ	ARR	KAS:ABS|NUM:S|MUG:M
ADJ	ARR	KAS:ABS|NUM:S|MUG:M|ENT:Tokia
ADJ	ARR	KAS:ALA|NUM:S|MUG:M
ADJ	ARR	KAS:DAT|NUM:P|MUG:M
ADJ	ARR	KAS:DAT|NUM:S|MUG:M
ADJ	ARR	KAS:DES|NUM:P|MUG:M
ADJ	ARR	KAS:ERG|MUG:MG|ENT:Erakundea
ADJ	ARR	KAS:ERG|NUM:PH|MUG:M|ENT:Erakundea
ADJ	ARR	KAS:ERG|NUM:P|MUG:M
ADJ	ARR	KAS:ERG|NUM:S|MUG:M
ADJ	ARR	KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	KAS:ERG|NUM:S|MUG:M|ENT:Pertsona
ADJ	ARR	KAS:GEL|NUM:P|MUG:M|POS:POSarteko|POS:+
ADJ	ARR	KAS:GEL|NUM:S|MUG:M
ADJ	ARR	KAS:GEL|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	KAS:GEN|NUM:P|MUG:M
ADJ	ARR	KAS:GEN|NUM:S|MUG:M
ADJ	ARR	KAS:INE|NUM:P|MUG:M
ADJ	ARR	KAS:INE|NUM:P|MUG:M|POS:POSinguruan|POS:+
ADJ	ARR	KAS:INE|NUM:S|MUG:M
ADJ	ARR	KAS:INS|MUG:MG
ADJ	ARR	KAS:MOT|NUM:P|MUG:M
ADJ	ARR	KAS:PAR|MUG:MG
ADJ	ARR	KAS:SOZ|NUM:P|MUG:M
ADJ	ARR	KAS:SOZ|NUM:S|MUG:M
ADJ	ARR	MAI:GEHI|IZAUR:-
ADJ	ARR	MAI:GEHI|IZAUR:-|KAS:ABS|MUG:MG
ADJ	ARR	MAI:GEHI|IZAUR:-|KAS:ABS|NUM:P|MUG:M
ADJ	ARR	MAI:GEHI|IZAUR:-|KAS:ABS|NUM:S|MUG:M
ADJ	ARR	MAI:GEHI|IZAUR:-|KAS:PAR|MUG:MG
ADJ	ARR	MAI:KONP
ADJ	ARR	MAI:KONP|IZAUR:+|KAS:ABS|NUM:P|MUG:M
ADJ	ARR	MAI:KONP|IZAUR:+|KAS:ABS|NUM:S|MUG:M
ADJ	ARR	MAI:KONP|IZAUR:-
ADJ	ARR	MAI:KONP|IZAUR:-|KAS:ABS|MUG:MG
ADJ	ARR	MAI:KONP|IZAUR:-|KAS:ABS|NUM:P|MUG:M
ADJ	ARR	MAI:KONP|IZAUR:-|KAS:ABS|NUM:S|MUG:M
ADJ	ARR	MAI:KONP|IZAUR:-|KAS:ABS|NUM:S|MUG:M|POS:POStruke|POS:+
ADJ	ARR	MAI:KONP|IZAUR:-|KAS:ALA|NUM:S|MUG:M
ADJ	ARR	MAI:KONP|IZAUR:-|KAS:EM|NUM:P|MUG:M|POS:POSbila|POS:+
ADJ	ARR	MAI:KONP|IZAUR:-|KAS:GEL|NUM:S|MUG:M
ADJ	ARR	MAI:KONP|IZAUR:-|KAS:GEN|NUM:S|MUG:M
ADJ	ARR	MAI:KONP|IZAUR:-|KAS:INE|NUM:P|MUG:M
ADJ	ARR	MAI:KONP|IZAUR:-|KAS:INE|NUM:S|MUG:M
ADJ	ARR	MAI:KONP|IZAUR:-|KAS:INS|MUG:MG
ADJ	ARR	MAI:KONP|IZAUR:-|KAS:MOT|NUM:S|MUG:M
ADJ	ARR	MAI:KONP|IZAUR:-|KAS:SOZ|NUM:S|MUG:M
ADJ	ARR	MAI:SUP|BIZ:-|KAS:ABS|NUM:S|MUG:M
ADJ	ARR	MAI:SUP|IZAUR:+|KAS:ABS|MUG:MG
ADJ	ARR	MAI:SUP|IZAUR:+|KAS:ABS|NUM:P|MUG:M
ADJ	ARR	MAI:SUP|IZAUR:+|KAS:ABS|NUM:S|MUG:M
ADJ	ARR	MAI:SUP|IZAUR:-
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:ABL|MUG:MG
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:ABS|MUG:MG
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:ABS|NUM:P|MUG:M
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:ABS|NUM:P|MUG:M|POS:POSpare|POS:+
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:ABS|NUM:S|MUG:M
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:ALA|NUM:P|MUG:M
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:ALA|NUM:S|MUG:M
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:DAT|NUM:P|MUG:M
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:DAT|NUM:S|MUG:M
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:EM|NUM:S|MUG:M|POS:POSzain|POS:+
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:ERG|NUM:P|MUG:M
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:ERG|NUM:S|MUG:M
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:GEL|NUM:P|MUG:M
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:GEL|NUM:P|MUG:M|POS:POSarteko|POS:+
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:GEL|NUM:S|MUG:M
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:GEN|NUM:P|MUG:M
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:GEN|NUM:S|MUG:M
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:INE|NUM:P|MUG:M
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:INE|NUM:P|MUG:M|POS:POSartean|POS:+
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:INE|NUM:P|MUG:M|POS:POSparean|POS:+
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:INE|NUM:S|MUG:M
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:PAR|MUG:MG
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:PRO|MUG:MG
ADJ	ARR	MAI:SUP|IZAUR:-|KAS:SOZ|NUM:P|MUG:M
ADJ	ARR	MAI:SUP|KAS:ABS|NUM:S|MUG:M
ADJ	ARR	MAI:SUP|KAS:ERG|NUM:P|MUG:M
ADJ	ARR	MAI:SUP|KAS:INE|NUM:S|MUG:M
ADJ	ARR	_
ADJ	ERKIND	MW:B
ADJ	GAL	KAS:ABS|NUM:P|MUG:M
ADJ	GAL	KAS:ABS|NUM:S|MUG:M
ADJ	GAL	NUM:S|MUG:M|MW:B
ADJ	GAL	_
ADJ	SIN	KAS:ABS|NUM:S|MUG:M|MW:B
ADL	ADL	ASP:PNT|ERL:BALD|MDN:A1|NOR:HURA
ADL	ADL	ASP:PNT|ERL:BALD|MDN:A1|NOR:HURA|NORK:GUK
ADL	ADL	ASP:PNT|ERL:BALD|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ASP:PNT|ERL:BALD|MDN:B1|NOR:HAIEK
ADL	ADL	ASP:PNT|ERL:BALD|MDN:B4|NOR:HURA
ADL	ADL	ASP:PNT|ERL:DENB|MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HAIEK
ADL	ADL	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HAIEK|NORK:GUK
ADL	ADL	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HAIEK|NORK:HARK
ADL	ADL	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA
ADL	ADL	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORI:HARI
ADL	ADL	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA
ADL	ADL	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORK:GUK
ADL	ADL	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL	ASP:PNT|ERL:KAUS|MDN:B1|NOR:HURA
ADL	ADL	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA
ADL	ADL	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL	ASP:PNT|ERL:KONPL|MDN:A1|NOR:NI
ADL	ADL	ASP:PNT|ERL:KONPL|MDN:A5|NOR:HURA
ADL	ADL	ASP:PNT|ERL:MOD/DENB|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:GURI
ADL	ADL	ASP:PNT|ERL:MOS|MDN:B1|NOR:HURA
ADL	ADL	ASP:PNT|ERL:ZHG|MDN:B1|NOR:HURA
ADL	ADL	ASP:PNT|MDN:A1|NOR:HAIEK
ADL	ADL	ASP:PNT|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	ASP:PNT|MDN:A1|NOR:HAIEK|NORK:HARK
ADL	ADL	ASP:PNT|MDN:A1|NOR:HURA
ADL	ADL	ASP:PNT|MDN:A1|NOR:HURA|NORI:HAIEI
ADL	ADL	ASP:PNT|MDN:A1|NOR:HURA|NORI:ZURI
ADL	ADL	ASP:PNT|MDN:A1|NOR:HURA|NORK:GUK
ADL	ADL	ASP:PNT|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ASP:PNT|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL	ASP:PNT|MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ASP:PNT|MDN:A1|NOR:NI|HIT:NO
ADL	ADL	ASP:PNT|MDN:A5|NOR:HURA
ADL	ADL	ASP:PNT|MDN:B1|NOR:HAIEK|NORK:HARK
ADL	ADL	ASP:PNT|MDN:B1|NOR:HURA
ADL	ADL	ASP:PNT|MDN:B1|NOR:HURA|NORK:GUK
ADL	ADL	ASP:PNT|MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL	ASP:PNT|MDN:B1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ASP:PNT|MDN:B1|NOR:HURA|NORK:ZUK
ADL	ADL	ASP:PNT|MDN:B1|NOR:NI
ADL	ADL	ASP:PNT|MDN:B2|NOR:HURA|NORK:HARK
ADL	ADL	ASP:PNT|MDN:B7|NOR:HURA
ADL	ADL	ERL:BALD|MDN:A1|NOR:GU
ADL	ADL	ERL:BALD|MDN:A1|NOR:GU|NORI:HARI
ADL	ADL	ERL:BALD|MDN:A1|NOR:HAIEK
ADL	ADL	ERL:BALD|MDN:A1|NOR:HAIEK|NORK:GUK
ADL	ADL	ERL:BALD|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	ERL:BALD|MDN:A1|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:BALD|MDN:A1|NOR:HAIEK|NORK:ZUK
ADL	ADL	ERL:BALD|MDN:A1|NOR:HURA
ADL	ADL	ERL:BALD|MDN:A1|NOR:HURA|NORI:GURI
ADL	ADL	ERL:BALD|MDN:A1|NOR:HURA|NORI:ZURI
ADL	ADL	ERL:BALD|MDN:A1|NOR:HURA|NORK:GUK
ADL	ADL	ERL:BALD|MDN:A1|NOR:HURA|NORK:GUK|NORI:HARI
ADL	ADL	ERL:BALD|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:BALD|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:GURI
ADL	ADL	ERL:BALD|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL	ERL:BALD|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL	ERL:BALD|MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:BALD|MDN:A1|NOR:HURA|NORK:NIK
ADL	ADL	ERL:BALD|MDN:A1|NOR:HURA|NORK:ZUK
ADL	ADL	ERL:BALD|MDN:A1|NOR:HURA|NORK:ZUK|NORI:HAIEI
ADL	ADL	ERL:BALD|MDN:A1|NOR:HURA|NORK:ZUK|NORI:HARI
ADL	ADL	ERL:BALD|MDN:A1|NOR:HURA|NORK:ZUK|NORI:NIRI
ADL	ADL	ERL:BALD|MDN:A1|NOR:NI
ADL	ADL	ERL:BALD|MDN:A1|NOR:ZU
ADL	ADL	ERL:BALD|MDN:A5|NOR:HURA|NORK:HARK
ADL	ADL	ERL:BALD|MDN:B1|NOR:GU
ADL	ADL	ERL:BALD|MDN:B1|NOR:HAIEK
ADL	ADL	ERL:BALD|MDN:B1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	ERL:BALD|MDN:B1|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:BALD|MDN:B1|NOR:HURA
ADL	ADL	ERL:BALD|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:BALD|MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL	ERL:BALD|MDN:B4|NOR:HAIEK
ADL	ADL	ERL:BALD|MDN:B4|NOR:HAIEK|NORK:GUK
ADL	ADL	ERL:BALD|MDN:B4|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:BALD|MDN:B4|NOR:HAIEK|NORK:NIK
ADL	ADL	ERL:BALD|MDN:B4|NOR:HURA
ADL	ADL	ERL:BALD|MDN:B4|NOR:HURA|NORI:HARI
ADL	ADL	ERL:BALD|MDN:B4|NOR:HURA|NORI:NIRI
ADL	ADL	ERL:BALD|MDN:B4|NOR:HURA|NORK:GUK
ADL	ADL	ERL:BALD|MDN:B4|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:BALD|MDN:B4|NOR:HURA|NORK:HARK
ADL	ADL	ERL:BALD|MDN:B4|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:BALD|MDN:B4|NOR:HURA|NORK:NIK
ADL	ADL	ERL:BALD|MDN:B4|NOR:NI
ADL	ADL	ERL:DENB|MDN:A1|NOR:HAIEK
ADL	ADL	ERL:DENB|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	ERL:DENB|MDN:A1|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:DENB|MDN:A1|NOR:HAIEK|NORK:NIK
ADL	ADL	ERL:DENB|MDN:A1|NOR:HURA
ADL	ADL	ERL:DENB|MDN:A1|NOR:HURA|NORI:GURI
ADL	ADL	ERL:DENB|MDN:A1|NOR:HURA|NORK:GUK
ADL	ADL	ERL:DENB|MDN:A1|NOR:HURA|NORK:GUK|NORI:HARI
ADL	ADL	ERL:DENB|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:DENB|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:GURI
ADL	ADL	ERL:DENB|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HAIEI
ADL	ADL	ERL:DENB|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL	ERL:DENB|MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:DENB|MDN:A1|NOR:HURA|NORK:NIK
ADL	ADL	ERL:DENB|MDN:A1|NOR:HURA|NORK:ZUEK-K
ADL	ADL	ERL:DENB|MDN:A1|NOR:NI
ADL	ADL	ERL:DENB|MDN:A1|NOR:NI|NORK:HARK
ADL	ADL	ERL:DENB|MDN:A5|NOR:HURA|NORK:NIK
ADL	ADL	ERL:DENB|MDN:B1|NOR:GU
ADL	ADL	ERL:DENB|MDN:B1|NOR:HAIEK
ADL	ADL	ERL:DENB|MDN:B1|NOR:HAIEK|NORI:HAIEI
ADL	ADL	ERL:DENB|MDN:B1|NOR:HAIEK|NORK:GUK
ADL	ADL	ERL:DENB|MDN:B1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	ERL:DENB|MDN:B1|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:DENB|MDN:B1|NOR:HAIEK|NORK:HARK|NORI:HAIEI
ADL	ADL	ERL:DENB|MDN:B1|NOR:HURA
ADL	ADL	ERL:DENB|MDN:B1|NOR:HURA|NORI:HARI
ADL	ADL	ERL:DENB|MDN:B1|NOR:HURA|NORK:GUK
ADL	ADL	ERL:DENB|MDN:B1|NOR:HURA|NORK:GUK|NORI:HARI
ADL	ADL	ERL:DENB|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:DENB|MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL	ERL:DENB|MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:NIRI
ADL	ADL	ERL:DENB|MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL	ERL:DENB|MDN:B1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:DENB|MDN:B1|NOR:HURA|NORK:NIK
ADL	ADL	ERL:DENB|MDN:B1|NOR:NI
ADL	ADL	ERL:DENB|MDN:B1|NOR:ZUEK|NORK:HARK
ADL	ADL	ERL:DENB|MDN:B5B|NOR:HURA|NORK:HARK
ADL	ADL	ERL:ERLT|MDN:A1|NOR:GU|NORK:HAIEK-K
ADL	ADL	ERL:ERLT|MDN:A1|NOR:GU|NORK:HARK
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HAIEK
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HAIEK|NORI:HAIEI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HAIEK|NORI:HARI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HAIEK|NORI:ZURI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HAIEK|NORK:GUK
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HAIEK|NORK:HARK|NORI:HAIEI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HAIEK|NORK:HARK|NORI:HARI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HAIEK|NORK:NIK
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HAIEK|NORK:ZUEK-K
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HAIEK|NORK:ZUK
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORI:GURI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORI:HAIEI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORI:HARI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORI:NIRI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORK:GUK
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORK:GUK|NORI:HAIEI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORK:GUK|NORI:HARI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:GURI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HAIEI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORK:HARK|NORI:GURI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORK:HARK|NORI:HAIEI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORK:HARK|NORI:NIRI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORK:NIK
ADL	ADL	ERL:ERLT|MDN:A1|NOR:HURA|NORK:ZUK
ADL	ADL	ERL:ERLT|MDN:A1|NOR:NI
ADL	ADL	ERL:ERLT|MDN:A1|NOR:NI|NORK:HARK
ADL	ADL	ERL:ERLT|MDN:A3|NOR:HURA|NORK:HARK
ADL	ADL	ERL:ERLT|MDN:A5|NOR:HAIEK
ADL	ADL	ERL:ERLT|MDN:A5|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	ERL:ERLT|MDN:A5|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:ERLT|MDN:A5|NOR:HAIEK|NORK:HARK|NORI:HARI
ADL	ADL	ERL:ERLT|MDN:A5|NOR:HURA
ADL	ADL	ERL:ERLT|MDN:A5|NOR:HURA|NORK:GUK
ADL	ADL	ERL:ERLT|MDN:A5|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:ERLT|MDN:A5|NOR:HURA|NORK:HARK
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HAIEK
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HAIEK|NORI:GURI
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HAIEK|NORI:HARI
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HAIEK|NORK:GUK|NORI:HARI
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HAIEK|NORK:HAIEK-K|NORI:HARI
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HAIEK|NORK:HARK|NORI:GURI
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HAIEK|NORK:HARK|NORI:HAIEI
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HURA
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HURA|NORI:HARI
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HURA|NORI:NIRI
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HURA|NORK:GUK
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HURA|NORK:GUK|NORI:ZUEI
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:GURI
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HURA|NORK:HARK|NORI:GURI
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HURA|NORK:NIK
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HURA|NORK:NIK|NORI:HARI
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HURA|NORK:ZUEK-K|NORI:NIRI
ADL	ADL	ERL:ERLT|MDN:B1|NOR:HURA|NORK:ZUK
ADL	ADL	ERL:ERLT|MDN:B1|NOR:NI|NORK:HARK
ADL	ADL	ERL:ERLT|MDN:B1|NOR:ZUEK|NORK:HARK
ADL	ADL	ERL:ERLT|MDN:B2|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:ERLT|MDN:B2|NOR:HURA|NORK:GUK
ADL	ADL	ERL:ERLT|MDN:B2|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:ERLT|MDN:B2|NOR:HURA|NORK:HARK
ADL	ADL	ERL:ERLT|MDN:B2|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:ERLT|MDN:B3|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:ERLT|MDN:B7|NOR:HAIEK
ADL	ADL	ERL:ERLT|MDN:B7|NOR:HURA
ADL	ADL	ERL:ERLT|MDN:B7|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:ERLT|MDN:B7|NOR:HURA|NORK:HARK
ADL	ADL	ERL:ERLT|MDN:B7|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:ERLT|MDN:B8|NOR:HURA
ADL	ADL	ERL:HELB|MDN:A3|NOR:HAIEK
ADL	ADL	ERL:HELB|MDN:A3|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	ERL:HELB|MDN:A3|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:HELB|MDN:A3|NOR:HURA
ADL	ADL	ERL:HELB|MDN:A3|NOR:HURA|NORK:GUK
ADL	ADL	ERL:HELB|MDN:A3|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:HELB|MDN:A3|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL	ERL:HELB|MDN:A3|NOR:HURA|NORK:HARK
ADL	ADL	ERL:HELB|MDN:A3|NOR:HURA|NORK:NIK|NORI:HAIEI
ADL	ADL	ERL:HELB|MDN:A3|NOR:ZU
ADL	ADL	ERL:HELB|MDN:B5A|NOR:HURA|NORK:HARK
ADL	ADL	ERL:HELB|MDN:B5B|NOR:HAIEK
ADL	ADL	ERL:HELB|MDN:B5B|NOR:HURA
ADL	ADL	ERL:HELB|MDN:B5B|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:HELB|MDN:B5B|NOR:HURA|NORK:HARK
ADL	ADL	ERL:HELB|MDN:B5B|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:KAUS|MDN:A1|NOR:GU|NORK:HAIEK-K
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HAIEK
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HAIEK|NORI:GURI
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HAIEK|NORI:HARI
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HAIEK|NORK:GUK
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HAIEK|NORK:HARK|NORI:HARI
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HAIEK|NORK:NIK
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HAIEK|NORK:ZUK
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HI
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HURA
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HURA|NORI:HAIEI
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HURA|NORI:HARI
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HURA|NORI:NIRI
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HURA|NORK:GUK
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HURA|NORK:GUK|NORI:HARI
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HAIEI
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HURA|NORK:HARK|NORI:GURI
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HURA|NORK:HARK|NORI:HAIEI
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HURA|NORK:NIK
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HURA|NORK:ZUEK-K
ADL	ADL	ERL:KAUS|MDN:A1|NOR:HURA|NORK:ZUK
ADL	ADL	ERL:KAUS|MDN:A1|NOR:ZU
ADL	ADL	ERL:KAUS|MDN:A5|NOR:HAIEK
ADL	ADL	ERL:KAUS|MDN:A5|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	ERL:KAUS|MDN:A5|NOR:HAIEK|NORK:NIK
ADL	ADL	ERL:KAUS|MDN:A5|NOR:HURA
ADL	ADL	ERL:KAUS|MDN:A5|NOR:HURA|NORK:GUK
ADL	ADL	ERL:KAUS|MDN:A5|NOR:HURA|NORK:HARK
ADL	ADL	ERL:KAUS|MDN:A5|NOR:HURA|NORK:ZUEK-K
ADL	ADL	ERL:KAUS|MDN:A5|NOR:HURA|NORK:ZUK
ADL	ADL	ERL:KAUS|MDN:B1|NOR:HAIEK
ADL	ADL	ERL:KAUS|MDN:B1|NOR:HAIEK|NORI:HARI
ADL	ADL	ERL:KAUS|MDN:B1|NOR:HAIEK|NORK:GUK
ADL	ADL	ERL:KAUS|MDN:B1|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:KAUS|MDN:B1|NOR:HAIEK|NORK:NIK|NORI:HARI
ADL	ADL	ERL:KAUS|MDN:B1|NOR:HURA
ADL	ADL	ERL:KAUS|MDN:B1|NOR:HURA|NORI:HARI
ADL	ADL	ERL:KAUS|MDN:B1|NOR:HURA|NORK:GUK
ADL	ADL	ERL:KAUS|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:KAUS|MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:HAIEI
ADL	ADL	ERL:KAUS|MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL	ERL:KAUS|MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:NIRI
ADL	ADL	ERL:KAUS|MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL	ERL:KAUS|MDN:B1|NOR:HURA|NORK:HARK|NORI:GURI
ADL	ADL	ERL:KAUS|MDN:B1|NOR:HURA|NORK:HARK|NORI:HAIEI
ADL	ADL	ERL:KAUS|MDN:B1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:KAUS|MDN:B1|NOR:HURA|NORK:ZUEK-K|NORI:GURI
ADL	ADL	ERL:KAUS|MDN:B1|NOR:NI
ADL	ADL	ERL:KAUS|MDN:B2|NOR:HURA
ADL	ADL	ERL:KAUS|MDN:B2|NOR:HURA|NORK:HARK
ADL	ADL	ERL:KAUS|MDN:B3|NOR:HAIEK|NORK:GUK
ADL	ADL	ERL:KAUS|MDN:B7|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:KAUS|MDN:B8|NOR:HURA
ADL	ADL	ERL:KAUS|MDN:B8|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:KONPL|MDN:A1|NOR:GU
ADL	ADL	ERL:KONPL|MDN:A1|NOR:GU|NORK:HARK
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HAIEK
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HAIEK|NORI:HAIEI
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HAIEK|NORI:HARI
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HAIEK|NORK:GUK
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HAIEK|NORK:HAIEK-K|NORI:HAIEI
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HAIEK|NORK:HAIEK-K|NORI:HARI
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HAIEK|NORK:HARK|NORI:GURI
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HAIEK|NORK:HARK|NORI:HARI
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HAIEK|NORK:NIK
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HAIEK|NORK:ZUEK-K
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HAIEK|NORK:ZUK
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HI|NORK:NIK
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HURA
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HURA|NORI:GURI
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HURA|NORI:HAIEI
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HURA|NORI:HARI
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HURA|NORK:GUK
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:GURI
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HAIEI
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HURA|NORK:HARK|NORI:HAIEI
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HURA|NORK:HARK|NORI:NIRI
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HURA|NORK:HIK-NO
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HURA|NORK:NIK
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HURA|NORK:ZUEK-K
ADL	ADL	ERL:KONPL|MDN:A1|NOR:HURA|NORK:ZUK
ADL	ADL	ERL:KONPL|MDN:A1|NOR:NI
ADL	ADL	ERL:KONPL|MDN:A1|NOR:NI|NORK:HAIEK-K
ADL	ADL	ERL:KONPL|MDN:A1|NOR:ZU
ADL	ADL	ERL:KONPL|MDN:A3|NOR:GU
ADL	ADL	ERL:KONPL|MDN:A3|NOR:HAIEK
ADL	ADL	ERL:KONPL|MDN:A3|NOR:HAIEK|NORK:GUK
ADL	ADL	ERL:KONPL|MDN:A3|NOR:HURA
ADL	ADL	ERL:KONPL|MDN:A3|NOR:HURA|NORK:GUK
ADL	ADL	ERL:KONPL|MDN:A3|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:KONPL|MDN:A3|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL	ERL:KONPL|MDN:A3|NOR:HURA|NORK:HARK
ADL	ADL	ERL:KONPL|MDN:A3|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:KONPL|MDN:A3|NOR:HURA|NORK:NIK
ADL	ADL	ERL:KONPL|MDN:A3|NOR:NI|NORK:HAIEK-K
ADL	ADL	ERL:KONPL|MDN:A3|NOR:NI|NORK:ZUK
ADL	ADL	ERL:KONPL|MDN:A5|NOR:GU
ADL	ADL	ERL:KONPL|MDN:A5|NOR:HAIEK
ADL	ADL	ERL:KONPL|MDN:A5|NOR:HAIEK|NORK:GUK
ADL	ADL	ERL:KONPL|MDN:A5|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	ERL:KONPL|MDN:A5|NOR:HURA
ADL	ADL	ERL:KONPL|MDN:A5|NOR:HURA|NORI:HAIEI
ADL	ADL	ERL:KONPL|MDN:A5|NOR:HURA|NORK:GUK
ADL	ADL	ERL:KONPL|MDN:A5|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:KONPL|MDN:A5|NOR:HURA|NORK:HARK
ADL	ADL	ERL:KONPL|MDN:A5|NOR:HURA|NORK:NIK
ADL	ADL	ERL:KONPL|MDN:B1|NOR:GU|NORK:HAIEK-K
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HAIEK
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HAIEK|NORK:HARK|NORI:HAIEI
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HAIEK|NORK:HARK|NORI:HARI
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HAIEK|NORK:NIK
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HURA
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HURA|NORI:GURI
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HURA|NORI:HARI
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HURA|NORI:NIRI
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HURA|NORK:GUK
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:HAIEI
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HURA|NORK:HARK|NORI:HAIEI
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HURA|NORK:NIK
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HURA|NORK:ZUEK-K
ADL	ADL	ERL:KONPL|MDN:B1|NOR:HURA|NORK:ZUK
ADL	ADL	ERL:KONPL|MDN:B1|NOR:NI
ADL	ADL	ERL:KONPL|MDN:B1|NOR:ZUEK|NORK:HARK
ADL	ADL	ERL:KONPL|MDN:B2|NOR:HAIEK
ADL	ADL	ERL:KONPL|MDN:B2|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:KONPL|MDN:B2|NOR:HURA
ADL	ADL	ERL:KONPL|MDN:B2|NOR:HURA|NORK:GUK
ADL	ADL	ERL:KONPL|MDN:B2|NOR:HURA|NORK:HARK
ADL	ADL	ERL:KONPL|MDN:B2|NOR:HURA|NORK:HARK|NORI:HAIEI
ADL	ADL	ERL:KONPL|MDN:B2|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:KONPL|MDN:B2|NOR:HURA|NORK:NIK
ADL	ADL	ERL:KONPL|MDN:B2|NOR:NI
ADL	ADL	ERL:KONPL|MDN:B3|NOR:HURA
ADL	ADL	ERL:KONPL|MDN:B5B|NOR:HURA
ADL	ADL	ERL:KONPL|MDN:B5B|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:KONPL|MDN:B5B|NOR:HURA|NORK:HARK
ADL	ADL	ERL:KONPL|MDN:B7|NOR:HURA
ADL	ADL	ERL:KONPL|MDN:B7|NOR:HURA|NORK:HIK
ADL	ADL	ERL:KONPL|MDN:B8|NOR:GU
ADL	ADL	ERL:KONPL|MDN:B8|NOR:HAIEK
ADL	ADL	ERL:KONPL|MDN:B8|NOR:HURA
ADL	ADL	ERL:KONPL|MDN:B8|NOR:HURA|NORK:HARK
ADL	ADL	ERL:KONPL|MDN:B8|NOR:NI
ADL	ADL	ERL:MOD/DENB|MDN:A1|NOR:HAIEK
ADL	ADL	ERL:MOD/DENB|MDN:A1|NOR:HAIEK|NORK:GUK
ADL	ADL	ERL:MOD/DENB|MDN:A1|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:MOD/DENB|MDN:A1|NOR:HURA
ADL	ADL	ERL:MOD/DENB|MDN:A1|NOR:HURA|NORI:HARI
ADL	ADL	ERL:MOD/DENB|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:MOD/DENB|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL	ERL:MOD/DENB|MDN:A1|NOR:HURA|NORK:NIK
ADL	ADL	ERL:MOD/DENB|MDN:A5|NOR:HAIEK
ADL	ADL	ERL:MOD/DENB|MDN:B1|NOR:HAIEK
ADL	ADL	ERL:MOD/DENB|MDN:B1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	ERL:MOD/DENB|MDN:B1|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:MOD/DENB|MDN:B1|NOR:HAIEK|NORK:HARK|NORI:HARI
ADL	ADL	ERL:MOD/DENB|MDN:B1|NOR:HURA
ADL	ADL	ERL:MOD/DENB|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:MOD/DENB|MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL	ERL:MOD/DENB|MDN:B1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:MOD|MDN:A1|NOR:HAIEK
ADL	ADL	ERL:MOD|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:MOD|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL	ERL:MOD|MDN:B1|NOR:HAIEK
ADL	ADL	ERL:MOD|MDN:B1|NOR:HURA
ADL	ADL	ERL:MOD|MDN:B8|NOR:HAIEK
ADL	ADL	ERL:MOS|MDN:A1|NOR:GU
ADL	ADL	ERL:MOS|MDN:A1|NOR:HAIEK
ADL	ADL	ERL:MOS|MDN:A1|NOR:HAIEK|NORI:NIRI
ADL	ADL	ERL:MOS|MDN:A1|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:MOS|MDN:A1|NOR:HAIEK|NORK:HARK|NORI:HARI
ADL	ADL	ERL:MOS|MDN:A1|NOR:HURA
ADL	ADL	ERL:MOS|MDN:A1|NOR:HURA|NORK:GUK
ADL	ADL	ERL:MOS|MDN:A1|NOR:HURA|NORK:GUK|NORI:HARI
ADL	ADL	ERL:MOS|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:MOS|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL	ERL:MOS|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL	ERL:MOS|MDN:A1|NOR:HURA|NORK:HARK|NORI:GURI
ADL	ADL	ERL:MOS|MDN:A1|NOR:HURA|NORK:NIK
ADL	ADL	ERL:MOS|MDN:A5|NOR:HAIEK
ADL	ADL	ERL:MOS|MDN:A5|NOR:HURA
ADL	ADL	ERL:MOS|MDN:A5|NOR:HURA|NORK:GUK
ADL	ADL	ERL:MOS|MDN:A5|NOR:HURA|NORK:ZUEK-K
ADL	ADL	ERL:MOS|MDN:B1|NOR:HAIEK
ADL	ADL	ERL:MOS|MDN:B1|NOR:HURA
ADL	ADL	ERL:MOS|MDN:B1|NOR:HURA|NORI:HAIEI
ADL	ADL	ERL:MOS|MDN:B1|NOR:HURA|NORI:NIRI
ADL	ADL	ERL:MOS|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:MOS|MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL	ERL:MOS|MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL	ERL:MOS|MDN:B1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:MOS|MDN:B1|NOR:HURA|NORK:NIK
ADL	ADL	ERL:MOS|MDN:B1|NOR:ZU
ADL	ADL	ERL:MOS|MDN:B2|NOR:HAIEK
ADL	ADL	ERL:MOS|MDN:B2|NOR:HURA|NORK:HARK
ADL	ADL	ERL:MOS|MDN:B4|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:ZHG|MDN:A1|NOR:GU
ADL	ADL	ERL:ZHG|MDN:A1|NOR:HAIEK
ADL	ADL	ERL:ZHG|MDN:A1|NOR:HAIEK|NORI:HARI
ADL	ADL	ERL:ZHG|MDN:A1|NOR:HAIEK|NORK:GUK
ADL	ADL	ERL:ZHG|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	ERL:ZHG|MDN:A1|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:ZHG|MDN:A1|NOR:HURA
ADL	ADL	ERL:ZHG|MDN:A1|NOR:HURA|NORI:GURI
ADL	ADL	ERL:ZHG|MDN:A1|NOR:HURA|NORI:HARI
ADL	ADL	ERL:ZHG|MDN:A1|NOR:HURA|NORK:GUK
ADL	ADL	ERL:ZHG|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	ERL:ZHG|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL	ERL:ZHG|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL	ERL:ZHG|MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:ZHG|MDN:A1|NOR:HURA|NORK:HIK-TO
ADL	ADL	ERL:ZHG|MDN:A1|NOR:HURA|NORK:NIK
ADL	ADL	ERL:ZHG|MDN:A1|NOR:HURA|NORK:ZUEK-K
ADL	ADL	ERL:ZHG|MDN:A1|NOR:HURA|NORK:ZUK
ADL	ADL	ERL:ZHG|MDN:A1|NOR:NI
ADL	ADL	ERL:ZHG|MDN:A1|NOR:NI|NORK:HARK
ADL	ADL	ERL:ZHG|MDN:A1|NOR:NI|NORK:ZUK
ADL	ADL	ERL:ZHG|MDN:A1|NOR:ZU
ADL	ADL	ERL:ZHG|MDN:A5|NOR:HAIEK
ADL	ADL	ERL:ZHG|MDN:A5|NOR:HURA
ADL	ADL	ERL:ZHG|MDN:A5|NOR:HURA|NORK:HARK
ADL	ADL	ERL:ZHG|MDN:A5|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:ZHG|MDN:A5|NOR:HURA|NORK:NIK
ADL	ADL	ERL:ZHG|MDN:B1|NOR:HAIEK
ADL	ADL	ERL:ZHG|MDN:B1|NOR:HAIEK|NORK:HARK
ADL	ADL	ERL:ZHG|MDN:B1|NOR:HAIEK|NORK:NIK
ADL	ADL	ERL:ZHG|MDN:B1|NOR:HURA
ADL	ADL	ERL:ZHG|MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:NIRI
ADL	ADL	ERL:ZHG|MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL	ERL:ZHG|MDN:B1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	ERL:ZHG|MDN:B1|NOR:HURA|NORK:NIK
ADL	ADL	ERL:ZHG|MDN:B1|NOR:NI
ADL	ADL	ERL:ZHG|MDN:B1|NOR:ZU|NORK:NIK
ADL	ADL	KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HAIEK
ADL	ADL	KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HAIEK|NORK:HARK
ADL	ADL	KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	KAS:ABS|NUM:P|MUG:M|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	KAS:ABS|NUM:S|MUG:M|MDN:B2|NOR:HAIEK|NORK:HARK
ADL	ADL	KAS:DAT|NUM:S|MUG:M|MDN:A1|NOR:HURA
ADL	ADL	KAS:ERG|NUM:S|MUG:M|MDN:B1|NOR:HURA
ADL	ADL	KAS:ERG|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL	KAS:GEL|MDN:A1|NOR:HURA
ADL	ADL	KAS:GEL|MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL	KAS:GEL|NUM:S|MUG:M|MDN:A1|NOR:HAIEK
ADL	ADL	KAS:GEL|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	KAS:GEN|NUM:S|MUG:M|MDN:A1|NOR:HURA
ADL	ADL	KAS:GEN|NUM:S|MUG:M|MDN:A5|NOR:HURA
ADL	ADL	KAS:GEN|NUM:S|MUG:M|MDN:B7|NOR:HURA
ADL	ADL	KAS:PAR|MUG:MG|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL	MDN:A1|NOR:GU
ADL	ADL	MDN:A1|NOR:GU|NORK:HAIEK-K
ADL	ADL	MDN:A1|NOR:GU|NORK:HARK
ADL	ADL	MDN:A1|NOR:HAIEK
ADL	ADL	MDN:A1|NOR:HAIEK|HIT:NO
ADL	ADL	MDN:A1|NOR:HAIEK|NORI:GURI
ADL	ADL	MDN:A1|NOR:HAIEK|NORI:HAIEI
ADL	ADL	MDN:A1|NOR:HAIEK|NORI:HARI
ADL	ADL	MDN:A1|NOR:HAIEK|NORI:NIRI
ADL	ADL	MDN:A1|NOR:HAIEK|NORI:ZUEI
ADL	ADL	MDN:A1|NOR:HAIEK|NORI:ZURI
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:GUK
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:GUK|NORI:ZURI
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:HAIEK-K|NORI:GURI
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:HAIEK-K|NORI:HAIEI
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:HAIEK-K|NORI:NIRI
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:HARK
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:HARK|HIT:NO
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:HARK|NORI:GURI
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:HARK|NORI:HAIEI
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:HARK|NORI:HARI
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:HARK|NORI:NIRI
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:HARK|NORI:ZURI
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:NIK
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:NIK|NORI:HAIEI
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:NIK|NORI:HARI
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:NIK|NORI:ZUEI
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:ZUEK-K
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:ZUK
ADL	ADL	MDN:A1|NOR:HAIEK|NORK:ZUK|NORI:NIRI
ADL	ADL	MDN:A1|NOR:HI
ADL	ADL	MDN:A1|NOR:HURA
ADL	ADL	MDN:A1|NOR:HURA|HIT:NO
ADL	ADL	MDN:A1|NOR:HURA|HIT:TO
ADL	ADL	MDN:A1|NOR:HURA|NORI:GURI
ADL	ADL	MDN:A1|NOR:HURA|NORI:HAIEI
ADL	ADL	MDN:A1|NOR:HURA|NORI:HARI
ADL	ADL	MDN:A1|NOR:HURA|NORI:HIRI-TO
ADL	ADL	MDN:A1|NOR:HURA|NORI:NIRI
ADL	ADL	MDN:A1|NOR:HURA|NORI:NIRI|HIT:NO
ADL	ADL	MDN:A1|NOR:HURA|NORI:ZUEI
ADL	ADL	MDN:A1|NOR:HURA|NORI:ZURI
ADL	ADL	MDN:A1|NOR:HURA|NORK:GUK
ADL	ADL	MDN:A1|NOR:HURA|NORK:GUK|HIT:TO
ADL	ADL	MDN:A1|NOR:HURA|NORK:GUK|NORI:HAIEI
ADL	ADL	MDN:A1|NOR:HURA|NORK:GUK|NORI:HARI
ADL	ADL	MDN:A1|NOR:HURA|NORK:GUK|NORI:ZURI
ADL	ADL	MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	MDN:A1|NOR:HURA|NORK:HAIEK-K|HIT:TO
ADL	ADL	MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:GURI
ADL	ADL	MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HAIEI
ADL	ADL	MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL	MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:NIRI
ADL	ADL	MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:NIRI|HIT:NO
ADL	ADL	MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:ZURI
ADL	ADL	MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL	MDN:A1|NOR:HURA|NORK:HARK|HIT:NO
ADL	ADL	MDN:A1|NOR:HURA|NORK:HARK|HIT:TO
ADL	ADL	MDN:A1|NOR:HURA|NORK:HARK|NORI:GURI
ADL	ADL	MDN:A1|NOR:HURA|NORK:HARK|NORI:HAIEI
ADL	ADL	MDN:A1|NOR:HURA|NORK:HARK|NORI:HAIEI|HIT:NO
ADL	ADL	MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI|HIT:NO
ADL	ADL	MDN:A1|NOR:HURA|NORK:HARK|NORI:HIRI-NO
ADL	ADL	MDN:A1|NOR:HURA|NORK:HARK|NORI:NIRI
ADL	ADL	MDN:A1|NOR:HURA|NORK:HARK|NORI:ZURI
ADL	ADL	MDN:A1|NOR:HURA|NORK:HIK-NO
ADL	ADL	MDN:A1|NOR:HURA|NORK:HIK-TO
ADL	ADL	MDN:A1|NOR:HURA|NORK:NIK
ADL	ADL	MDN:A1|NOR:HURA|NORK:NIK|HIT:NO
ADL	ADL	MDN:A1|NOR:HURA|NORK:NIK|HIT:TO
ADL	ADL	MDN:A1|NOR:HURA|NORK:NIK|NORI:HAIEI
ADL	ADL	MDN:A1|NOR:HURA|NORK:NIK|NORI:HARI
ADL	ADL	MDN:A1|NOR:HURA|NORK:NIK|NORI:HIRI-TO
ADL	ADL	MDN:A1|NOR:HURA|NORK:NIK|NORI:ZUEI
ADL	ADL	MDN:A1|NOR:HURA|NORK:NIK|NORI:ZURI
ADL	ADL	MDN:A1|NOR:HURA|NORK:ZUEK-K
ADL	ADL	MDN:A1|NOR:HURA|NORK:ZUEK-K|NORI:NIRI
ADL	ADL	MDN:A1|NOR:HURA|NORK:ZUK
ADL	ADL	MDN:A1|NOR:HURA|NORK:ZUK|NORI:GURI
ADL	ADL	MDN:A1|NOR:HURA|NORK:ZUK|NORI:HARI
ADL	ADL	MDN:A1|NOR:NI
ADL	ADL	MDN:A1|NOR:NI|HIT:NO
ADL	ADL	MDN:A1|NOR:NI|NORK:HAIEK-K
ADL	ADL	MDN:A1|NOR:NI|NORK:HARK
ADL	ADL	MDN:A1|NOR:NI|NORK:ZUEK-K
ADL	ADL	MDN:A1|NOR:NI|NORK:ZUK
ADL	ADL	MDN:A1|NOR:ZU
ADL	ADL	MDN:A1|NOR:ZUEK
ADL	ADL	MDN:A1|NOR:ZUEK|NORK:GUK
ADL	ADL	MDN:A1|NOR:ZU|NORI:NIRI
ADL	ADL	MDN:A1|NOR:ZU|NORK:GUK
ADL	ADL	MDN:A1|NOR:ZU|NORK:HAIEK-K
ADL	ADL	MDN:A1|NOR:ZU|NORK:HARK
ADL	ADL	MDN:A1|NOR:ZU|NORK:NIK
ADL	ADL	MDN:A5|NOR:GU
ADL	ADL	MDN:A5|NOR:HAIEK
ADL	ADL	MDN:A5|NOR:HAIEK|NORK:GUK
ADL	ADL	MDN:A5|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	MDN:A5|NOR:HAIEK|NORK:HARK
ADL	ADL	MDN:A5|NOR:HAIEK|NORK:HARK|NORI:HARI
ADL	ADL	MDN:A5|NOR:HAIEK|NORK:ZUK
ADL	ADL	MDN:A5|NOR:HI
ADL	ADL	MDN:A5|NOR:HURA
ADL	ADL	MDN:A5|NOR:HURA|NORI:HARI
ADL	ADL	MDN:A5|NOR:HURA|NORI:HARI|HIT:NO
ADL	ADL	MDN:A5|NOR:HURA|NORI:ZURI
ADL	ADL	MDN:A5|NOR:HURA|NORK:GUK
ADL	ADL	MDN:A5|NOR:HURA|NORK:HAIEK-K
ADL	ADL	MDN:A5|NOR:HURA|NORK:HAIEK-K|NORI:HAIEI
ADL	ADL	MDN:A5|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL	MDN:A5|NOR:HURA|NORK:HARK
ADL	ADL	MDN:A5|NOR:HURA|NORK:HARK|HIT:NO
ADL	ADL	MDN:A5|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	MDN:A5|NOR:HURA|NORK:NIK
ADL	ADL	MDN:A5|NOR:HURA|NORK:ZUK
ADL	ADL	MDN:A5|NOR:NI
ADL	ADL	MDN:A5|NOR:NI|NORK:ZUK
ADL	ADL	MDN:A5|NOR:ZU|NORK:GUK
ADL	ADL	MDN:B1|NOR:GU
ADL	ADL	MDN:B1|NOR:GU|HIT:NO
ADL	ADL	MDN:B1|NOR:GU|NORI:HARI
ADL	ADL	MDN:B1|NOR:GU|NORK:HAIEK-K
ADL	ADL	MDN:B1|NOR:GU|NORK:HARK
ADL	ADL	MDN:B1|NOR:HAIEK
ADL	ADL	MDN:B1|NOR:HAIEK|NORI:GURI
ADL	ADL	MDN:B1|NOR:HAIEK|NORI:HAIEI
ADL	ADL	MDN:B1|NOR:HAIEK|NORI:HARI
ADL	ADL	MDN:B1|NOR:HAIEK|NORI:NIRI
ADL	ADL	MDN:B1|NOR:HAIEK|NORK:GUK
ADL	ADL	MDN:B1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	MDN:B1|NOR:HAIEK|NORK:HAIEK-K|NORI:GURI
ADL	ADL	MDN:B1|NOR:HAIEK|NORK:HAIEK-K|NORI:HAIEI
ADL	ADL	MDN:B1|NOR:HAIEK|NORK:HAIEK-K|NORI:HARI
ADL	ADL	MDN:B1|NOR:HAIEK|NORK:HAIEK-K|NORI:NIRI
ADL	ADL	MDN:B1|NOR:HAIEK|NORK:HARK
ADL	ADL	MDN:B1|NOR:HAIEK|NORK:HARK|NORI:GURI
ADL	ADL	MDN:B1|NOR:HAIEK|NORK:HARK|NORI:HAIEI
ADL	ADL	MDN:B1|NOR:HAIEK|NORK:HARK|NORI:HARI
ADL	ADL	MDN:B1|NOR:HAIEK|NORK:HARK|NORI:NIRI
ADL	ADL	MDN:B1|NOR:HAIEK|NORK:NIK
ADL	ADL	MDN:B1|NOR:HAIEK|NORK:ZUK
ADL	ADL	MDN:B1|NOR:HI
ADL	ADL	MDN:B1|NOR:HI|NORK:HARK
ADL	ADL	MDN:B1|NOR:HURA
ADL	ADL	MDN:B1|NOR:HURA|NORI:GURI
ADL	ADL	MDN:B1|NOR:HURA|NORI:HAIEI
ADL	ADL	MDN:B1|NOR:HURA|NORI:HARI
ADL	ADL	MDN:B1|NOR:HURA|NORI:NIRI
ADL	ADL	MDN:B1|NOR:HURA|NORI:ZUEI
ADL	ADL	MDN:B1|NOR:HURA|NORI:ZURI
ADL	ADL	MDN:B1|NOR:HURA|NORK:GUK
ADL	ADL	MDN:B1|NOR:HURA|NORK:GUK|HIT:TO
ADL	ADL	MDN:B1|NOR:HURA|NORK:GUK|NORI:HAIEI
ADL	ADL	MDN:B1|NOR:HURA|NORK:GUK|NORI:HARI
ADL	ADL	MDN:B1|NOR:HURA|NORK:GUK|NORI:ZUEI
ADL	ADL	MDN:B1|NOR:HURA|NORK:GUK|NORI:ZURI
ADL	ADL	MDN:B1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:GURI
ADL	ADL	MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:HAIEI
ADL	ADL	MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL	MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:NIRI
ADL	ADL	MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL	MDN:B1|NOR:HURA|NORK:HARK|HIT:NO
ADL	ADL	MDN:B1|NOR:HURA|NORK:HARK|NORI:GURI
ADL	ADL	MDN:B1|NOR:HURA|NORK:HARK|NORI:HAIEI
ADL	ADL	MDN:B1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	MDN:B1|NOR:HURA|NORK:HARK|NORI:NIRI
ADL	ADL	MDN:B1|NOR:HURA|NORK:HARK|NORI:ZUEI
ADL	ADL	MDN:B1|NOR:HURA|NORK:HARK|NORI:ZURI
ADL	ADL	MDN:B1|NOR:HURA|NORK:HIK
ADL	ADL	MDN:B1|NOR:HURA|NORK:NIK
ADL	ADL	MDN:B1|NOR:HURA|NORK:NIK|HIT:TO
ADL	ADL	MDN:B1|NOR:HURA|NORK:NIK|NORI:HAIEI
ADL	ADL	MDN:B1|NOR:HURA|NORK:NIK|NORI:HARI
ADL	ADL	MDN:B1|NOR:HURA|NORK:NIK|NORI:HIRI-TO
ADL	ADL	MDN:B1|NOR:HURA|NORK:ZUEK-K
ADL	ADL	MDN:B1|NOR:HURA|NORK:ZUEK-K|NORI:GURI
ADL	ADL	MDN:B1|NOR:HURA|NORK:ZUK
ADL	ADL	MDN:B1|NOR:NI
ADL	ADL	MDN:B1|NOR:NI|NORI:HARI
ADL	ADL	MDN:B1|NOR:NI|NORK:HAIEK-K
ADL	ADL	MDN:B1|NOR:NI|NORK:HARK
ADL	ADL	MDN:B1|NOR:ZU
ADL	ADL	MDN:B1|NOR:ZU|NORK:NIK
ADL	ADL	MDN:B2|NOR:HAIEK
ADL	ADL	MDN:B2|NOR:HAIEK|NORI:HAIEI
ADL	ADL	MDN:B2|NOR:HAIEK|NORK:GUK
ADL	ADL	MDN:B2|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	MDN:B2|NOR:HAIEK|NORK:NIK
ADL	ADL	MDN:B2|NOR:HURA
ADL	ADL	MDN:B2|NOR:HURA|NORI:GURI
ADL	ADL	MDN:B2|NOR:HURA|NORI:NIRI
ADL	ADL	MDN:B2|NOR:HURA|NORK:GUK
ADL	ADL	MDN:B2|NOR:HURA|NORK:HAIEK-K
ADL	ADL	MDN:B2|NOR:HURA|NORK:HARK
ADL	ADL	MDN:B2|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL	MDN:B2|NOR:HURA|NORK:NIK
ADL	ADL	MDN:B2|NOR:HURA|NORK:NIK|NORI:ZURI
ADL	ADL	MDN:B2|NOR:HURA|NORK:ZUEK-K
ADL	ADL	MDN:B2|NOR:HURA|NORK:ZUK
ADL	ADL	MDN:B2|NOR:HURA|NORK:ZUK|NORI:HARI
ADL	ADL	MDN:B2|NOR:NI
ADL	ADL	MDN:B3|NOR:HURA
ADL	ADL	MDN:B3|NOR:HURA|NORI:NIRI
ADL	ADL	MDN:B3|NOR:HURA|NORK:HAIEK-K
ADL	ADL	MDN:B3|NOR:HURA|NORK:HARK
ADL	ADL	MDN:B7|NOR:HAIEK
ADL	ADL	MDN:B7|NOR:HURA
ADL	ADL	MDN:B7|NOR:HURA|NORK:GUK
ADL	ADL	MDN:B7|NOR:HURA|NORK:HAIEK-K
ADL	ADL	MDN:B7|NOR:HURA|NORK:HARK
ADL	ADL	MDN:B7|NOR:HURA|NORK:NIK
ADL	ADL	MDN:B7|NOR:HURA|NORK:ZUK
ADL	ADL	MDN:B8|NOR:HAIEK
ADL	ADL	MDN:B8|NOR:HAIEK|NORK:HARK
ADL	ADL	MDN:B8|NOR:HAIEK|NORK:ZUK
ADL	ADL	MDN:B8|NOR:HURA
ADL	ADL	MDN:B8|NOR:HURA|NORK:HAIEK-K
ADL	ADL	MDN:B8|NOR:HURA|NORK:HARK
ADL	ADL	MDN:B8|NOR:ZU|NORK:NIK
ADL	ADL	MDN:C|NOR:HAIEK|NORK:ZUK
ADL	ADL	MDN:C|NOR:HURA|NORK:HIK-NO
ADL	ADL	MDN:C|NOR:HURA|NORK:HIK-NO|NORI:HARI
ADL	ADL	MDN:C|NOR:HURA|NORK:HIK-TO
ADL	ADL	MDN:C|NOR:HURA|NORK:ZUEK-K
ADL	ADL	MDN:C|NOR:HURA|NORK:ZUK
ADL	ADL	MDN:C|NOR:HURA|NORK:ZUK|NORI:HAIEI
ADL	ADL	MDN:C|NOR:HURA|NORK:ZUK|NORI:HARI
ADL	ADL	MDN:C|NOR:HURA|NORK:ZUK|NORI:NIRI
ADL	ADL	MDN:C|NOR:NI|NORK:HIK-NO
ADL	ADL	MDN:C|NOR:NI|NORK:ZUK
ADL	ADL	MDN:C|NOR:ZU
ADL	ADL	MOD:EGI|MDN:A1|NOR:HAIEK|NORK:HARK
ADL	ADL	MOD:EGI|MDN:A1|NOR:HURA
ADL	ADL	MOD:EGI|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	MOD:EGI|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL	MOD:EGI|MDN:A5|NOR:HAIEK
ADL	ADL	MOD:EGI|MDN:B1|NOR:HAIEK|NORK:HARK
ADL	ADL	MOD:EGI|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADL	ADL	MOD:EGI|MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL	MOD:EGI|MDN:B2|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL	MOD:EGI|MDN:B7|NOR:HURA
ADL	ADL_IZEELI	ASP:PNT|KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HAIEK|NORI:HAIEI
ADL	ADL_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA
ADL	ADL_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:GUK
ADL	ADL_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL_IZEELI	ASP:PNT|KAS:DES|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL_IZEELI	ASP:PNT|KAS:INE|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL_IZEELI	ASP:PNT|KAS:MOT|NUM:S|MUG:M|MDN:A1|NOR:HURA
ADL	ADL_IZEELI	KAS:ABL|NUM:P|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:ABS|MUG:MG|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:GU|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HAIEK
ADL	ADL_IZEELI	KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HAIEK|NORK:HARK|NORI:GURI
ADL	ADL_IZEELI	KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HURA|NORK:GUK
ADL	ADL_IZEELI	KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL_IZEELI	KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HURA|NORK:HARK|NORI:HAIEI
ADL	ADL_IZEELI	KAS:ABS|NUM:P|MUG:M|MDN:A5|NOR:HAIEK
ADL	ADL_IZEELI	KAS:ABS|NUM:P|MUG:M|MDN:B1|NOR:HAIEK
ADL	ADL_IZEELI	KAS:ABS|NUM:P|MUG:M|MDN:B1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:ABS|NUM:P|MUG:M|MDN:B1|NOR:HAIEK|NORK:HAIEK-K|NORI:GURI
ADL	ADL_IZEELI	KAS:ABS|NUM:P|MUG:M|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:ABS|NUM:P|MUG:M|MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:NIRI
ADL	ADL_IZEELI	KAS:ABS|NUM:P|MUG:M|MDN:B8|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:GU|NORK:HARK
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HAIEK|NORK:HARK
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HAIEK|NORK:HARK|NORI:HAIEI
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORI:HARI
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:GUK
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK|NORI:NIRI
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:NI
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:NI|NORK:HARK
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:A5|NOR:HURA
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:A5|NOR:HURA|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:A5|NOR:HURA|NORK:HARK
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:A5|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:GU
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:GU|NORK:HARK
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:HAIEK|NORK:HARK|NORI:HARI
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:HURA
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORI:HARI
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:NIRI
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORK:HARK|NORI:HARI
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORK:NIK
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:B2|NOR:HURA|NORK:HARK
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:B7|NOR:HURA
ADL	ADL_IZEELI	KAS:ABS|NUM:S|MUG:M|MDN:B8|NOR:HURA
ADL	ADL_IZEELI	KAS:DAT|NUM:P|MUG:M|MDN:B1|NOR:HAIEK|NORK:HARK
ADL	ADL_IZEELI	KAS:DAT|NUM:S|MUG:M|MDN:A1|NOR:HURA
ADL	ADL_IZEELI	KAS:DAT|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:GUK
ADL	ADL_IZEELI	KAS:DAT|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL_IZEELI	KAS:DAT|NUM:S|MUG:M|MDN:B1|NOR:HURA
ADL	ADL_IZEELI	KAS:DES|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL_IZEELI	KAS:DES|NUM:S|MUG:M|MDN:A1|NOR:NI|NORK:HARK
ADL	ADL_IZEELI	KAS:DES|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL_IZEELI	KAS:ERG|NUM:P|MUG:M|MDN:A1|NOR:HAIEK
ADL	ADL_IZEELI	KAS:ERG|NUM:P|MUG:M|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:ERG|NUM:P|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:ERG|NUM:P|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL_IZEELI	KAS:ERG|NUM:S|MUG:M|MDN:A1|NOR:HURA
ADL	ADL_IZEELI	KAS:ERG|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL_IZEELI	KAS:ERG|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:NIK
ADL	ADL_IZEELI	KAS:ERG|NUM:S|MUG:M|MDN:B1|NOR:HURA
ADL	ADL_IZEELI	KAS:ERG|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADL	ADL_IZEELI	KAS:GEL|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:GEN|NUM:P|MUG:M|MDN:A1|NOR:HAIEK
ADL	ADL_IZEELI	KAS:GEN|NUM:P|MUG:M|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:GEN|NUM:P|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:GEN|NUM:P|MUG:M|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:GEN|NUM:S|MUG:M|MDN:A1|NOR:HAIEK
ADL	ADL_IZEELI	KAS:GEN|NUM:S|MUG:M|MDN:A1|NOR:HURA
ADL	ADL_IZEELI	KAS:GEN|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORI:GURI
ADL	ADL_IZEELI	KAS:GEN|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORI:NIRI
ADL	ADL_IZEELI	KAS:GEN|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:GUK
ADL	ADL_IZEELI	KAS:GEN|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:GEN|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HAIEI
ADL	ADL_IZEELI	KAS:GEN|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK
ADL	ADL_IZEELI	KAS:GEN|NUM:S|MUG:M|MDN:A5|NOR:HURA
ADL	ADL_IZEELI	KAS:GEN|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORK:HARK
ADL	ADL_IZEELI	KAS:INE|NUM:P|MUG:M|MDN:A1|NOR:HAIEK
ADL	ADL_IZEELI	KAS:INE|NUM:P|MUG:M|MDN:A1|NOR:NI
ADL	ADL_IZEELI	KAS:INE|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:INS|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:MOT|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:MOT|NUM:S|MUG:M|MDN:B1|NOR:GU|NORK:HARK
ADL	ADL_IZEELI	KAS:MOT|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORI:HARI
ADL	ADL_IZEELI	KAS:SOZ|NUM:P|MUG:M|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:SOZ|NUM:P|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADL	ADL_IZEELI	KAS:SOZ|NUM:P|MUG:M|MDN:B1|NOR:HAIEK
ADL	ADL_IZEELI	KAS:SOZ|NUM:P|MUG:M|MDN:B1|NOR:HAIEK|NORK:HAIEK-K|NORI:HARI
ADL	ADL_IZEELI	KAS:SOZ|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:NIK
ADL	ADL_IZEELI	KAS:SOZ|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:ZUK
ADL	ADL_IZEELI	KAS:SOZ|NUM:S|MUG:M|MDN:A1|NOR:NI|NORK:HARK
ADL	ADL_IZEELI	KAS:SOZ|NUM:S|MUG:M|MDN:B1|NOR:HURA
ADL	ADL_IZEELI	KAS:SOZ|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:BALD|MDN:A1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:BALD|MDN:A1|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|ERL:BALD|MDN:A1|NOR:HAIEK|NORK:NIK
ADT	ADT	ASP:PNT|ERL:BALD|MDN:A1|NOR:HAIEK|NORK:ZUK
ADT	ADT	ASP:PNT|ERL:BALD|MDN:A1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:BALD|MDN:A1|NOR:HURA|NORK:GUK
ADT	ADT	ASP:PNT|ERL:BALD|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:BALD|MDN:A1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:BALD|MDN:A1|NOR:HURA|NORK:ZUEK-K
ADT	ADT	ASP:PNT|ERL:BALD|MDN:A1|NOR:HURA|NORK:ZUK
ADT	ADT	ASP:PNT|ERL:BALD|MDN:A1|NOR:NI
ADT	ADT	ASP:PNT|ERL:BALD|MDN:A1|NOR:ZU
ADT	ADT	ASP:PNT|ERL:BALD|MDN:A4|NOR:HURA|NORK:NIK
ADT	ADT	ASP:PNT|ERL:BALD|MDN:B1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:BALD|MDN:B1|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|ERL:BALD|MDN:B1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:BALD|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:BALD|MDN:B1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:BALD|MDN:B1|NOR:HURA|NORK:HIK
ADT	ADT	ASP:PNT|ERL:BALD|MDN:B4|NOR:GU
ADT	ADT	ASP:PNT|ERL:BALD|MDN:B4|NOR:HAIEK|NORK:NIK
ADT	ADT	ASP:PNT|ERL:BALD|MDN:B4|NOR:HURA
ADT	ADT	ASP:PNT|ERL:BALD|MDN:B4|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:BALD|MDN:B4|NOR:ZU
ADT	ADT	ASP:PNT|ERL:BALD|MDN:B6|NOR:HURA
ADT	ADT	ASP:PNT|ERL:BALD|MDN:B7|NOR:HURA
ADT	ADT	ASP:PNT|ERL:DENB|MDN:A1|NOR:GU
ADT	ADT	ASP:PNT|ERL:DENB|MDN:A1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:DENB|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:DENB|MDN:A1|NOR:HAIEK|NORK:NIK
ADT	ADT	ASP:PNT|ERL:DENB|MDN:A1|NOR:HAIEK|NORK:ZUK
ADT	ADT	ASP:PNT|ERL:DENB|MDN:A1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:DENB|MDN:A1|NOR:HURA|NORK:GUK
ADT	ADT	ASP:PNT|ERL:DENB|MDN:A1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:DENB|MDN:A1|NOR:NI
ADT	ADT	ASP:PNT|ERL:DENB|MDN:B1|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|ERL:DENB|MDN:B1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:GU
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:GU|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HAIEK|NORI:HAIEI
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HAIEK|NORI:HARI
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HAIEK|NORK:GUK
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORI:HAIEI
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORI:HARI
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORI:NIRI
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORI:ZURI
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORK:GUK
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORK:HIK-NO
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORK:NIK
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:HURA|NORK:ZUK
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:NI
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A1|NOR:ZUEK|NORK:HARK
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:A3|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:B1|NOR:GU
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HAIEK|NORI:HAIEI
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HAIEK|NORI:HARI
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HAIEK|NORK:GUK
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HAIEK|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HURA|NORI:HARI
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HURA|NORK:GUK
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:B1|NOR:HURA|NORK:NIK
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:B1|NOR:NI
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:B5B|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:B5B|NOR:HAIEK|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:ERLT|MDN:B5B|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:ERLT|MOD:EGI|MDN:A1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:A1|NOR:GU
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORI:GURI
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORI:HAIEI
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORI:HARI
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORI:NIRI
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORK:GUK
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:A1|NOR:HURA|NORK:NIK
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:A1|NOR:NI
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:B1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:B1|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:B1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:B1|NOR:HURA|NORI:HARI
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:B1|NOR:HURA|NORK:GUK
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:B1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:B1|NOR:HURA|NORK:NIK
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:B1|NOR:NI
ADT	ADT	ASP:PNT|ERL:KAUS|MDN:B2|NOR:HURA
ADT	ADT	ASP:PNT|ERL:KAUS|MOD:EGI|MDN:A1|NOR:HURA|NORK:NIK
ADT	ADT	ASP:PNT|ERL:KAUS|MOD:EGI|MDN:B1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:GU
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HAIEK|NORK:GUK
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HAIEK|NORK:NIK
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HAIEK|NORK:ZUK
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|NORI:HAIEI
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|NORI:HARI
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|NORK:GUK
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:HARI
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|NORK:HARK|NORI:HAIEI
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:HURA|NORK:NIK
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:NI
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A1|NOR:ZU
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A3|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:A3|NOR:HURA
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:B1|NOR:GU
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HAIEK|NORK:GUK
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HAIEK|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HURA|NORI:HARI
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HURA|NORK:GUK
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:B1|NOR:HURA|NORK:NIK
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:B1|NOR:NI
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:B2|NOR:HURA
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:B5B|NOR:HURA
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:B5B|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:B7|NOR:HURA
ADT	ADT	ASP:PNT|ERL:KONPL|MDN:B8|NOR:HURA
ADT	ADT	ASP:PNT|ERL:KONPL|MOD:EGI|MDN:A1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:KONPL|MOD:EGI|MDN:A1|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|ERL:KONPL|MOD:EGI|MDN:A1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:KONPL|MOD:EGI|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:KONPL|MOD:EGI|MDN:A1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:KONPL|MOD:EGI|MDN:A1|NOR:HURA|NORK:HIK-TO
ADT	ADT	ASP:PNT|ERL:KONPL|MOD:EGI|MDN:A1|NOR:HURA|NORK:NIK
ADT	ADT	ASP:PNT|ERL:KONPL|MOD:EGI|MDN:B1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:KONPL|MOD:EGI|MDN:B1|NOR:HURA|NORK:NIK
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:A1|NOR:GU
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:A1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:A1|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:A1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:A1|NOR:HURA|NORI:NIRI
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:A1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:A1|NOR:HURA|NORK:HARK|ENT:Pertsona
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:A1|NOR:ZU
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:B1|NOR:GU
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:B1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:B1|NOR:HAIEK|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:B1|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:B1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:B1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:B1|NOR:NI
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:B1|NOR:ZU
ADT	ADT	ASP:PNT|ERL:MOD/DENB|MDN:B5B|NOR:NI
ADT	ADT	ASP:PNT|ERL:MOD|MDN:A1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:MOD|MDN:A1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:MOS|MDN:A1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:MOS|MDN:A1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:MOS|MDN:A1|NOR:HURA|NORK:GUK
ADT	ADT	ASP:PNT|ERL:MOS|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:MOS|MDN:A1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:MOS|MDN:B1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:MOS|MDN:B1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:MOS|MDN:B1|NOR:HURA|NORI:NIRI
ADT	ADT	ASP:PNT|ERL:MOS|MDN:B1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:MOS|MDN:B4|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|ERL:MOS|MDN:B4|NOR:HURA
ADT	ADT	ASP:PNT|ERL:MOS|MOD:EGI|MDN:A1|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|ERL:MOS|MOD:EGI|MDN:A1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:ZHG|MDN:A1|NOR:GU
ADT	ADT	ASP:PNT|ERL:ZHG|MDN:A1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:ZHG|MDN:A1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:ZHG|MDN:A1|NOR:HURA|NORI:HARI
ADT	ADT	ASP:PNT|ERL:ZHG|MDN:A1|NOR:HURA|NORK:GUK
ADT	ADT	ASP:PNT|ERL:ZHG|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:ZHG|MDN:A1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|ERL:ZHG|MDN:A1|NOR:HURA|NORK:NIK
ADT	ADT	ASP:PNT|ERL:ZHG|MDN:A1|NOR:HURA|NORK:ZUK
ADT	ADT	ASP:PNT|ERL:ZHG|MDN:B1|NOR:GU
ADT	ADT	ASP:PNT|ERL:ZHG|MDN:B1|NOR:HAIEK
ADT	ADT	ASP:PNT|ERL:ZHG|MDN:B1|NOR:HAIEK|NORK:HAIEK-K
ADT	ADT	ASP:PNT|ERL:ZHG|MDN:B1|NOR:HURA
ADT	ADT	ASP:PNT|ERL:ZHG|MDN:B1|NOR:NI
ADT	ADT	ASP:PNT|ERL:ZHG|MOD:EGI|MDN:A1|NOR:HURA
ADT	ADT	ASP:PNT|KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADT	ADT	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA
ADT	ADT	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|KAS:GEL|MDN:A1|NOR:HURA
ADT	ADT	ASP:PNT|KAS:GEN|NUM:S|MUG:M|MDN:B1|NOR:HURA
ADT	ADT	ASP:PNT|KAS:INE|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORI:HARI
ADT	ADT	ASP:PNT|KAS:INE|NUM:S|MUG:M|MDN:B5B|NOR:HURA
ADT	ADT	ASP:PNT|KAS:INS|MUG:MG|MDN:A1|NOR:HAIEK
ADT	ADT	ASP:PNT|KAS:INS|NUM:P|MUG:M|MDN:A1|NOR:HURA|NORI:HAIEI
ADT	ADT	ASP:PNT|KAS:PAR|MUG:MG|MDN:A5|NOR:HURA
ADT	ADT	ASP:PNT|KAS:SOZ|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|MDN:A1|NOR:GU
ADT	ADT	ASP:PNT|MDN:A1|NOR:GU|HIT:TO
ADT	ADT	ASP:PNT|MDN:A1|NOR:GU|NORK:HARK
ADT	ADT	ASP:PNT|MDN:A1|NOR:HAIEK
ADT	ADT	ASP:PNT|MDN:A1|NOR:HAIEK|HIT:TO
ADT	ADT	ASP:PNT|MDN:A1|NOR:HAIEK|NORI:GURI
ADT	ADT	ASP:PNT|MDN:A1|NOR:HAIEK|NORI:HAIEI
ADT	ADT	ASP:PNT|MDN:A1|NOR:HAIEK|NORI:HARI
ADT	ADT	ASP:PNT|MDN:A1|NOR:HAIEK|NORK:GUK
ADT	ADT	ASP:PNT|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADT	ADT	ASP:PNT|MDN:A1|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|MDN:A1|NOR:HAIEK|NORK:HARK|HIT:TO
ADT	ADT	ASP:PNT|MDN:A1|NOR:HAIEK|NORK:NIK
ADT	ADT	ASP:PNT|MDN:A1|NOR:HAIEK|NORK:ZUK
ADT	ADT	ASP:PNT|MDN:A1|NOR:HI
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|HIT:NO
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|HIT:TO
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORI:GURI
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORI:HAIEI
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORI:HARI
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:GUK
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:GUK|NORI:HAIEI
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:GUK|NORI:HARI
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:HAIEK-K|NORI:GURI
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:HARK|NORI:GURI
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:HARK|NORI:HAIEI
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:HARK|NORI:ZURI
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:HIK-NO
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:NIK
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:NIK|HIT:NO
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:NIK|HIT:TO
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:NIK|NORI:HARI
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:ZUEK-K
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:ZUK
ADT	ADT	ASP:PNT|MDN:A1|NOR:HURA|NORK:ZUK|NORI:HARI
ADT	ADT	ASP:PNT|MDN:A1|NOR:NI
ADT	ADT	ASP:PNT|MDN:A1|NOR:NI|HIT:NO
ADT	ADT	ASP:PNT|MDN:A1|NOR:NI|HIT:TO
ADT	ADT	ASP:PNT|MDN:A1|NOR:NI|NORK:ZUK
ADT	ADT	ASP:PNT|MDN:A1|NOR:ZU
ADT	ADT	ASP:PNT|MDN:A1|NOR:ZUEK
ADT	ADT	ASP:PNT|MDN:A5|NOR:HURA
ADT	ADT	ASP:PNT|MDN:B1|NOR:GU
ADT	ADT	ASP:PNT|MDN:B1|NOR:HAIEK
ADT	ADT	ASP:PNT|MDN:B1|NOR:HAIEK|NORI:HARI
ADT	ADT	ASP:PNT|MDN:B1|NOR:HAIEK|NORK:HAIEK-K
ADT	ADT	ASP:PNT|MDN:B1|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|MDN:B1|NOR:HAIEK|NORK:NIK
ADT	ADT	ASP:PNT|MDN:B1|NOR:HAIEK|NORK:ZUK|HIT:TO
ADT	ADT	ASP:PNT|MDN:B1|NOR:HURA
ADT	ADT	ASP:PNT|MDN:B1|NOR:HURA|HIT:TO
ADT	ADT	ASP:PNT|MDN:B1|NOR:HURA|NORI:GURI
ADT	ADT	ASP:PNT|MDN:B1|NOR:HURA|NORI:HARI
ADT	ADT	ASP:PNT|MDN:B1|NOR:HURA|NORK:GUK
ADT	ADT	ASP:PNT|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|MDN:B1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|MDN:B1|NOR:HURA|NORK:HARK|HIT:TO
ADT	ADT	ASP:PNT|MDN:B1|NOR:HURA|NORK:HARK|NORI:HAIEI
ADT	ADT	ASP:PNT|MDN:B1|NOR:HURA|NORK:NIK
ADT	ADT	ASP:PNT|MDN:B1|NOR:HURA|NORK:NIK|HIT:NO
ADT	ADT	ASP:PNT|MDN:B1|NOR:HURA|NORK:ZUEK-K
ADT	ADT	ASP:PNT|MDN:B1|NOR:NI
ADT	ADT	ASP:PNT|MDN:B1|NOR:ZU
ADT	ADT	ASP:PNT|MDN:B2|NOR:HAIEK
ADT	ADT	ASP:PNT|MDN:B2|NOR:HURA
ADT	ADT	ASP:PNT|MDN:B2|NOR:HURA|NORK:GUK
ADT	ADT	ASP:PNT|MDN:B2|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|MDN:B2|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|MDN:B2|NOR:HURA|NORK:NIK
ADT	ADT	ASP:PNT|MDN:B2|NOR:NI
ADT	ADT	ASP:PNT|MDN:B4|NOR:HURA
ADT	ADT	ASP:PNT|MDN:B7|NOR:HURA
ADT	ADT	ASP:PNT|MDN:B7|NOR:HURA|NORK:HARK|NORI:HARI
ADT	ADT	ASP:PNT|MDN:C|NOR:HI
ADT	ADT	ASP:PNT|MDN:C|NOR:HURA|NORK:GUK
ADT	ADT	ASP:PNT|MDN:C|NOR:HURA|NORK:HIK-TO
ADT	ADT	ASP:PNT|MDN:C|NOR:HURA|NORK:ZUK
ADT	ADT	ASP:PNT|MDN:C|NOR:HURA|NORK:ZUK|NORI:NIRI
ADT	ADT	ASP:PNT|MDN:C|NOR:ZU
ADT	ADT	ASP:PNT|MDN:C|NOR:ZUEK
ADT	ADT	ASP:PNT|MOD:EGI|MDN:A1|NOR:HAIEK
ADT	ADT	ASP:PNT|MOD:EGI|MDN:A1|NOR:HAIEK|NORK:GUK
ADT	ADT	ASP:PNT|MOD:EGI|MDN:A1|NOR:HAIEK|NORK:GUK|HIT:NO
ADT	ADT	ASP:PNT|MOD:EGI|MDN:A1|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|MOD:EGI|MDN:A1|NOR:HAIEK|NORK:NIK
ADT	ADT	ASP:PNT|MOD:EGI|MDN:A1|NOR:HAIEK|NORK:NIK|HIT:NO
ADT	ADT	ASP:PNT|MOD:EGI|MDN:A1|NOR:HURA
ADT	ADT	ASP:PNT|MOD:EGI|MDN:A1|NOR:HURA|NORK:GUK
ADT	ADT	ASP:PNT|MOD:EGI|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|MOD:EGI|MDN:A1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|MOD:EGI|MDN:A1|NOR:HURA|NORK:HARK|HIT:NO
ADT	ADT	ASP:PNT|MOD:EGI|MDN:A1|NOR:HURA|NORK:HIK-TO
ADT	ADT	ASP:PNT|MOD:EGI|MDN:A1|NOR:HURA|NORK:NIK
ADT	ADT	ASP:PNT|MOD:EGI|MDN:A1|NOR:HURA|NORK:ZUEK-K
ADT	ADT	ASP:PNT|MOD:EGI|MDN:A1|NOR:HURA|NORK:ZUK
ADT	ADT	ASP:PNT|MOD:EGI|MDN:B1|NOR:HAIEK
ADT	ADT	ASP:PNT|MOD:EGI|MDN:B1|NOR:HAIEK|NORK:HAIEK-K
ADT	ADT	ASP:PNT|MOD:EGI|MDN:B1|NOR:HAIEK|NORK:HARK
ADT	ADT	ASP:PNT|MOD:EGI|MDN:B1|NOR:HURA
ADT	ADT	ASP:PNT|MOD:EGI|MDN:B1|NOR:HURA|NORI:HAIEI
ADT	ADT	ASP:PNT|MOD:EGI|MDN:B1|NOR:HURA|NORK:GUK
ADT	ADT	ASP:PNT|MOD:EGI|MDN:B1|NOR:HURA|NORK:HAIEK-K
ADT	ADT	ASP:PNT|MOD:EGI|MDN:B1|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|MOD:EGI|MDN:B1|NOR:HURA|NORK:NIK
ADT	ADT	ASP:PNT|MOD:EGI|MDN:B3|NOR:HURA|NORK:HARK
ADT	ADT	ASP:PNT|MOD:EGI|MDN:B7|NOR:HURA
ADT	ADT	ERL:DENB|MDN:B1|NOR:HURA|NORK:HARK
ADT	ADT	ERL:ERLT|MDN:A1|NOR:HAIEK
ADT	ADT	ERL:KAUS|MDN:A1|NOR:HURA
ADT	ADT	ERL:KONPL|MDN:A1|NOR:HAIEK
ADT	ADT	ERL:KONPL|MDN:A1|NOR:HURA
ADT	ADT	ERL:KONPL|MDN:A1|NOR:HURA|NORK:HARK
ADT	ADT	ERL:KONPL|MDN:B1|NOR:HAIEK
ADT	ADT	ERL:KONPL|MDN:B1|NOR:HURA
ADT	ADT	ERL:MOD/DENB|MDN:B1|NOR:HAIEK
ADT	ADT	ERL:MOS|MDN:B1|NOR:HURA
ADT	ADT	ERL:ZHG|MDN:A1|NOR:HURA
ADT	ADT	MDN:B1|NOR:HURA|NORK:HARK
ADT	ADT_IZEELI	ASP:PNT|KAS:ABL|NUM:S|MUG:M|MDN:B1|NOR:GU
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:PH|MUG:M|MDN:A1|NOR:ZU|NORK:GUK
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:GU
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HAIEK
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HAIEK|NORI:HAIEI
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HAIEK|NORI:HARI
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HURA
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:P|MUG:M|MDN:A1|NOR:HURA|NORK:HAIEK-K
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:P|MUG:M|MDN:B1|NOR:HAIEK
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:P|MUG:M|MDN:B1|NOR:HAIEK|NORK:HARK
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HAIEK
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HAIEK|NORK:HARK
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORI:GURI
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORI:ZURI
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:GUK
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK|NORI:HARI
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:NIK
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:ZUK
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:A1|NOR:NI
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:HAIEK|NORK:HARK
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:HURA
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORI:HARI
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:HURA|NORK:HARK
ADT	ADT_IZEELI	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:B7|NOR:HURA
ADT	ADT_IZEELI	ASP:PNT|KAS:DAT|NUM:P|MUG:M|MDN:A1|NOR:HAIEK
ADT	ADT_IZEELI	ASP:PNT|KAS:DAT|NUM:P|MUG:M|MDN:A1|NOR:HAIEK|NORK:HAIEK-K
ADT	ADT_IZEELI	ASP:PNT|KAS:DAT|NUM:P|MUG:M|MDN:A1|NOR:HURA|NORI:HAIEI
ADT	ADT_IZEELI	ASP:PNT|KAS:DAT|NUM:P|MUG:M|MDN:B1|NOR:HAIEK
ADT	ADT_IZEELI	ASP:PNT|KAS:DAT|NUM:S|MUG:M|MDN:A1|NOR:HURA
ADT	ADT_IZEELI	ASP:PNT|KAS:DAT|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORI:HARI
ADT	ADT_IZEELI	ASP:PNT|KAS:DAT|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK
ADT	ADT_IZEELI	ASP:PNT|KAS:DES|NUM:S|MUG:M|MDN:A1|NOR:HURA
ADT	ADT_IZEELI	ASP:PNT|KAS:ERG|NUM:PH|MUG:M|MDN:A1|NOR:GU
ADT	ADT_IZEELI	ASP:PNT|KAS:ERG|NUM:PH|MUG:M|MDN:A1|NOR:HURA|NORK:GUK
ADT	ADT_IZEELI	ASP:PNT|KAS:ERG|NUM:P|MUG:M|MDN:A1|NOR:HAIEK
ADT	ADT_IZEELI	ASP:PNT|KAS:ERG|NUM:P|MUG:M|MDN:B1|NOR:HAIEK
ADT	ADT_IZEELI	ASP:PNT|KAS:ERG|NUM:S|MUG:M|MDN:A1|NOR:HURA
ADT	ADT_IZEELI	ASP:PNT|KAS:ERG|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORI:HARI
ADT	ADT_IZEELI	ASP:PNT|KAS:ERG|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:HARK
ADT	ADT_IZEELI	ASP:PNT|KAS:GEL|NUM:P|MUG:M|MDN:B1|NOR:HAIEK
ADT	ADT_IZEELI	ASP:PNT|KAS:GEN|NUM:P|MUG:M|MDN:A1|NOR:HAIEK
ADT	ADT_IZEELI	ASP:PNT|KAS:GEN|NUM:P|MUG:M|MDN:B1|NOR:HAIEK
ADT	ADT_IZEELI	ASP:PNT|KAS:GEN|NUM:S|MUG:M|MDN:A1|NOR:HAIEK
ADT	ADT_IZEELI	ASP:PNT|KAS:GEN|NUM:S|MUG:M|MDN:A1|NOR:HURA
ADT	ADT_IZEELI	ASP:PNT|KAS:GEN|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORI:HAIEI
ADT	ADT_IZEELI	ASP:PNT|KAS:GEN|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORI:HARI
ADT	ADT_IZEELI	ASP:PNT|KAS:INE|NUM:S|MUG:M|MDN:A1|NOR:HURA
ADT	ADT_IZEELI	ASP:PNT|KAS:INE|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORI:HARI
ADT	ADT_IZEELI	ASP:PNT|KAS:INE|NUM:S|MUG:M|MDN:A3|NOR:HURA|NORI:HARI
ADT	ADT_IZEELI	ASP:PNT|KAS:INS|NUM:P|MUG:M|MDN:A1|NOR:HURA
ADT	ADT_IZEELI	ASP:PNT|KAS:INS|NUM:P|MUG:M|MDN:A1|NOR:HURA|NORI:HARI
ADT	ADT_IZEELI	ASP:PNT|KAS:INS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORI:HARI
ADT	ADT_IZEELI	ASP:PNT|KAS:INS|NUM:S|MUG:M|MDN:A1|NOR:HURA|NORK:ZUK
ADT	ARR	ASP:PNT|KAS:ABS|NUM:S|MUG:M|MDN:B1|NOR:HURA|ENT:Pertsona
BEREIZ	BEREIZ	_
BST	ARR	KAS:ABS|MUG:MG|MW:B
BST	ARR	KAS:ALA|NUM:P|MUG:M|MW:B
BST	ARR	KAS:DAT|NUM:P|MUG:M|MW:B
BST	BST	ENT:Pertsona
BST	BST	MTKAT:LAB
BST	BST	MTKAT:LAB|KAS:ERG|NUM:P|MUG:M
BST	BST	MW:B
BST	BST	_
BST	DZG	KAS:PAR|MUG:MG|MW:B
BST	DZG	MW:B
DET	BAN	KAS:ABS|MUG:MG
DET	BAN	KAS:GEL
DET	BAN	KAS:SOZ|MUG:MG
DET	BAN	PLU:-|KAS:ABS|MUG:MG
DET	BAN	_
DET	DZG	KAS:ABL|NUM:P|MUG:M
DET	DZG	KAS:ABL|NUM:P|MUG:M|POS:POSgainetik|POS:+
DET	DZG	KAS:ABL|NUM:S|MUG:M
DET	DZG	KAS:ABL|NUM:S|MUG:M|POS:POSatzetik|POS:+
DET	DZG	KAS:ABL|NUM:S|MUG:M|POS:POSgibeletik|POS:+
DET	DZG	KAS:ABS|MUG:MG
DET	DZG	KAS:ABS|MUG:MG|MW:B
DET	DZG	KAS:ABS|NUM:PH|MUG:M
DET	DZG	KAS:ABS|NUM:P|MUG:M
DET	DZG	KAS:ABS|NUM:S|MUG:M
DET	DZG	KAS:ABZ|NUM:S|MUG:M
DET	DZG	KAS:ALA|NUM:S|MUG:M
DET	DZG	KAS:ALA|NUM:S|MUG:M|MW:B
DET	DZG	KAS:DAT|NUM:P|MUG:M
DET	DZG	KAS:DAT|NUM:S|MUG:M
DET	DZG	KAS:DES|MUG:MG
DET	DZG	KAS:DES|NUM:P|MUG:M
DET	DZG	KAS:EM|NUM:P|MUG:M|POS:POSbezala|POS:+
DET	DZG	KAS:EM|NUM:S|MUG:M|POS:POSondoren|POS:+
DET	DZG	KAS:ERG|NUM:P|MUG:M
DET	DZG	KAS:ERG|NUM:S|MUG:M
DET	DZG	KAS:GEL|MUG:MG
DET	DZG	KAS:GEL|NUM:P|MUG:M
DET	DZG	KAS:GEL|NUM:S|MUG:M
DET	DZG	KAS:GEN|NUM:P|MUG:M
DET	DZG	KAS:GEN|NUM:S|MUG:M
DET	DZG	KAS:INE|MUG:MG
DET	DZG	KAS:INE|NUM:P|MUG:M
DET	DZG	KAS:INE|NUM:P|MUG:M|POS:POSaintzinean|POS:+
DET	DZG	KAS:INE|NUM:P|MUG:M|POS:POSartean|POS:+
DET	DZG	KAS:INE|NUM:S|MUG:M
DET	DZG	KAS:INS|MUG:MG
DET	DZG	KAS:INS|NUM:S|MUG:M
DET	DZG	KAS:PAR|MUG:MG
DET	DZG	KAS:SOZ|NUM:P|MUG:M
DET	DZG	KAS:SOZ|NUM:S|MUG:M
DET	DZG	MW:B
DET	DZG	NMG:MG
DET	DZG	NMG:MG|KAS:ABL|MUG:MG
DET	DZG	NMG:MG|KAS:ABL|MUG:MG|POS:POSarteetik|POS:+
DET	DZG	NMG:MG|KAS:ABS|MUG:MG
DET	DZG	NMG:MG|KAS:ABS|MUG:MG|MW:B
DET	DZG	NMG:MG|KAS:ABS|MUG:MG|POS:POSgain|POS:+
DET	DZG	NMG:MG|KAS:ABS|POS:POSarte|POS:+
DET	DZG	NMG:MG|KAS:ALA
DET	DZG	NMG:MG|KAS:ALA|MUG:MG|POS:POSantzera|POS:+
DET	DZG	NMG:MG|KAS:DAT|MUG:MG
DET	DZG	NMG:MG|KAS:DESK
DET	DZG	NMG:MG|KAS:DES|MUG:MG
DET	DZG	NMG:MG|KAS:EM|MUG:MG|POS:POSbezala|POS:+
DET	DZG	NMG:MG|KAS:EM|MUG:MG|POS:POSbidez|POS:+
DET	DZG	NMG:MG|KAS:EM|MUG:MG|POS:POSkontra|POS:+
DET	DZG	NMG:MG|KAS:ERG|MUG:MG
DET	DZG	NMG:MG|KAS:GEL|MUG:MG
DET	DZG	NMG:MG|KAS:GEN|MUG:MG
DET	DZG	NMG:MG|KAS:INE
DET	DZG	NMG:MG|KAS:INE|MUG:MG
DET	DZG	NMG:MG|KAS:INE|MUG:MG|POS:POSartean|POS:+
DET	DZG	NMG:MG|KAS:INE|MUG:MG|POS:POSaurrean|POS:+
DET	DZG	NMG:MG|KAS:INS|MUG:MG
DET	DZG	NMG:MG|KAS:MOT|MUG:MG
DET	DZG	NMG:MG|KAS:PAR|MUG:MG
DET	DZG	NMG:MG|KAS:SOZ|MUG:MG
DET	DZG	NMG:MG|KAS:SOZ|MUG:MG|MW:B
DET	DZG	NMG:MG|MW:B
DET	DZG	NMG:P
DET	DZG	NMG:P|KAS:ABL|NUM:P|MUG:M
DET	DZG	NMG:P|KAS:ABL|NUM:P|MUG:M|POS:POSaldetik|POS:+
DET	DZG	NMG:P|KAS:ABL|NUM:P|MUG:M|POS:POSatzetik|POS:+
DET	DZG	NMG:P|KAS:ABS|MUG:MG
DET	DZG	NMG:P|KAS:ABS|NUM:P|MUG:M
DET	DZG	NMG:P|KAS:ABS|NUM:P|MUG:M|MW:B
DET	DZG	NMG:P|KAS:ABS|NUM:P|MUG:M|POS:POSesker|POS:+
DET	DZG	NMG:P|KAS:ALA|NUM:P|MUG:M
DET	DZG	NMG:P|KAS:DAT|NUM:P|MUG:M
DET	DZG	NMG:P|KAS:DES|NUM:P|MUG:M
DET	DZG	NMG:P|KAS:ERG|NUM:P|MUG:M
DET	DZG	NMG:P|KAS:GEL|MUG:MG
DET	DZG	NMG:P|KAS:GEL|NUM:P|MUG:M
DET	DZG	NMG:P|KAS:GEL|NUM:P|MUG:M|POS:POSaurkako|POS:+
DET	DZG	NMG:P|KAS:GEN|MUG:MG
DET	DZG	NMG:P|KAS:GEN|NUM:P|MUG:M
DET	DZG	NMG:P|KAS:INE|MUG:MG
DET	DZG	NMG:P|KAS:INE|NUM:P|MUG:M
DET	DZG	NMG:P|KAS:INE|NUM:P|MUG:M|POS:POSartean|POS:+
DET	DZG	NMG:P|KAS:INS|NUM:P|MUG:M
DET	DZG	NMG:P|KAS:INS|NUM:P|MUG:M|POS:POSbitartez|POS:+
DET	DZG	NMG:P|KAS:MOT|NUM:P|MUG:M
DET	DZG	NMG:P|KAS:SOZ|NUM:P|MUG:M
DET	DZG	NMG:S|MW:B
DET	DZG	_
DET	DZH	KAS:ABS|MUG:MG
DET	DZH	KAS:GEL|NUM:S|MUG:M
DET	DZH	NMG:P
DET	DZH	NMG:P|ENT:???
DET	DZH	NMG:P|KAS:ABL|NUM:PH|MUG:M|POS:POSaldetik|POS:+
DET	DZH	NMG:P|KAS:ABL|NUM:P|MUG:M
DET	DZH	NMG:P|KAS:ABS|MUG:MG
DET	DZH	NMG:P|KAS:ABS|MUG:MG|MW:B
DET	DZH	NMG:P|KAS:ABS|NUM:PH|MUG:M
DET	DZH	NMG:P|KAS:ABS|NUM:P|MUG:M
DET	DZH	NMG:P|KAS:ABS|NUM:P|MUG:M|POS:POSarte|POS:+
DET	DZH	NMG:P|KAS:ABS|NUM:S|MUG:M
DET	DZH	NMG:P|KAS:ALA|NUM:P|MUG:M
DET	DZH	NMG:P|KAS:ALA|NUM:P|MUG:M|POS:POSaldera|POS:+
DET	DZH	NMG:P|KAS:ALA|NUM:P|MUG:M|POS:POSaurrera|POS:+
DET	DZH	NMG:P|KAS:BNK|MUG:MG
DET	DZH	NMG:P|KAS:DAT|MUG:MG
DET	DZH	NMG:P|KAS:DAT|NUM:PH|MUG:M
DET	DZH	NMG:P|KAS:DAT|NUM:P|MUG:M
DET	DZH	NMG:P|KAS:DAT|NUM:P|MUG:M|ENT:Erakundea
DET	DZH	NMG:P|KAS:DESK
DET	DZH	NMG:P|KAS:DES|NUM:P|MUG:M
DET	DZH	NMG:P|KAS:EM|MUG:MG|POS:POSaurrera|POS:+
DET	DZH	NMG:P|KAS:EM|NUM:P|MUG:M|POS:POSaitzina|POS:+
DET	DZH	NMG:P|KAS:EM|NUM:P|MUG:M|POS:POSirian|POS:+
DET	DZH	NMG:P|KAS:ERG|MUG:MG
DET	DZH	NMG:P|KAS:ERG|NUM:PH|MUG:M
DET	DZH	NMG:P|KAS:ERG|NUM:P|MUG:M
DET	DZH	NMG:P|KAS:ERG|NUM:P|MUG:M|ENT:Pertsona
DET	DZH	NMG:P|KAS:GEL|MUG:MG
DET	DZH	NMG:P|KAS:GEL|NUM:P|MUG:M
DET	DZH	NMG:P|KAS:GEL|NUM:P|MUG:M|POS:POSarteko|POS:+
DET	DZH	NMG:P|KAS:GEN|MUG:MG
DET	DZH	NMG:P|KAS:GEN|MUG:MG|MW:B
DET	DZH	NMG:P|KAS:GEN|NUM:PH|MUG:M
DET	DZH	NMG:P|KAS:GEN|NUM:P|MUG:M
DET	DZH	NMG:P|KAS:GEN|NUM:P|MUG:M|MW:B|KAS:INE|POS:POSartean|POS:+
DET	DZH	NMG:P|KAS:INE|MUG:MG
DET	DZH	NMG:P|KAS:INE|NUM:PH|MUG:M|POS:POSartean|POS:+
DET	DZH	NMG:P|KAS:INE|NUM:P|MUG:M
DET	DZH	NMG:P|KAS:INE|NUM:P|MUG:M|POS:POSartean|POS:+
DET	DZH	NMG:P|KAS:INE|NUM:P|MUG:M|POS:POSbitartean|POS:+
DET	DZH	NMG:P|KAS:INE|NUM:P|MUG:M|POS:POSinguruan|POS:+
DET	DZH	NMG:P|KAS:SOZ|MUG:MG
DET	DZH	NMG:P|KAS:SOZ|NUM:P|MUG:M
DET	DZH	NMG:P|KAS:SOZ|NUM:S|MUG:M
DET	DZH	NMG:P|MW:B
DET	DZH	NMG:S
DET	DZH	NMG:S|KAS:ABL|NUM:S|MUG:M
DET	DZH	NMG:S|KAS:ABL|POS:POSatzetik|POS:+
DET	DZH	NMG:S|KAS:ABL|POS:POSaurretik|POS:+
DET	DZH	NMG:S|KAS:ABL|POS:POSondotik|POS:+
DET	DZH	NMG:S|KAS:ABS|MUG:MG
DET	DZH	NMG:S|KAS:ABS|MUG:MG|ENT:???
DET	DZH	NMG:S|KAS:ABS|MUG:MG|MW:B
DET	DZH	NMG:S|KAS:ABS|MUG:MG|POS:POSesker|POS:+
DET	DZH	NMG:S|KAS:ABS|NUM:S|MUG:M
DET	DZH	NMG:S|KAS:ABS|POS:POSalde|POS:+
DET	DZH	NMG:S|KAS:ABS|POS:POSaurka|POS:+
DET	DZH	NMG:S|KAS:ABZ|NUM:S|MUG:M
DET	DZH	NMG:S|KAS:ALA|MUG:MG|POS:POSbatera|POS:+
DET	DZH	NMG:S|KAS:ALA|NUM:S|MUG:M
DET	DZH	NMG:S|KAS:ALA|NUM:S|MUG:M|POS:POSbehera|POS:+
DET	DZH	NMG:S|KAS:ALA|POS:POSgainerat|POS:+
DET	DZH	NMG:S|KAS:DAT|MUG:MG
DET	DZH	NMG:S|KAS:DESK
DET	DZH	NMG:S|KAS:DES|MUG:MG
DET	DZH	NMG:S|KAS:EM|MUG:MG|POS:POSbegira|POS:+
DET	DZH	NMG:S|KAS:EM|MUG:MG|POS:POSburuz|POS:+
DET	DZH	NMG:S|KAS:EM|NUM:S|MUG:M|POS:POSbezala|POS:+
DET	DZH	NMG:S|KAS:EM|NUM:S|MUG:M|POS:POShurbil|POS:+
DET	DZH	NMG:S|KAS:EM|NUM:S|MUG:M|POS:POSzehar|POS:+
DET	DZH	NMG:S|KAS:EM|POS:POSarabera|POS:+
DET	DZH	NMG:S|KAS:EM|POS:POSbila|POS:+
DET	DZH	NMG:S|KAS:EM|POS:POSgisan|POS:+
DET	DZH	NMG:S|KAS:EM|POS:POSkontra|POS:+
DET	DZH	NMG:S|KAS:EM|POS:POSondoren|POS:+
DET	DZH	NMG:S|KAS:EM|POS:POSordez|POS:+
DET	DZH	NMG:S|KAS:ERG|MUG:MG
DET	DZH	NMG:S|KAS:ERG|NUM:S|MUG:M
DET	DZH	NMG:S|KAS:GEL|NUM:S|MUG:M
DET	DZH	NMG:S|KAS:GEL|POS:POSkontrako|POS:+
DET	DZH	NMG:S|KAS:GEN
DET	DZH	NMG:S|KAS:INE
DET	DZH	NMG:S|KAS:INE|NUM:S|MUG:M
DET	DZH	NMG:S|KAS:INE|POS:POSatzean|POS:+
DET	DZH	NMG:S|KAS:INE|POS:POSaurrean|POS:+
DET	DZH	NMG:S|KAS:INE|POS:POSazpian|POS:+
DET	DZH	NMG:S|KAS:INE|POS:POSbarnean|POS:+
DET	DZH	NMG:S|KAS:INE|POS:POSbarruan|POS:+
DET	DZH	NMG:S|KAS:INE|POS:POSerdian|POS:+
DET	DZH	NMG:S|KAS:INE|POS:POSeskuetan|POS:+
DET	DZH	NMG:S|KAS:INE|POS:POSgainean|POS:+
DET	DZH	NMG:S|KAS:INE|POS:POSinguruan|POS:+
DET	DZH	NMG:S|KAS:INE|POS:POSondoan|POS:+
DET	DZH	NMG:S|KAS:INE|POS:POSparean|POS:+
DET	DZH	NMG:S|KAS:INE|POS:POSpean|POS:+
DET	DZH	NMG:S|KAS:INS|MUG:MG
DET	DZH	NMG:S|KAS:INS|NUM:S|MUG:M
DET	DZH	NMG:S|KAS:INS|POS:POSbidez|POS:+
DET	DZH	NMG:S|KAS:INS|POS:POSbitartez|POS:+
DET	DZH	NMG:S|KAS:MOT
DET	DZH	NMG:S|KAS:PAR|MUG:MG
DET	DZH	NMG:S|KAS:SOZ|MUG:MG
DET	DZH	NMG:S|KAS:SOZ|MUG:MG|MW:B
DET	ERKARR	KAS:ABL|NUM:P|MUG:M
DET	ERKARR	KAS:ABL|NUM:P|MUG:M|POS:POSaurretik|POS:+
DET	ERKARR	KAS:ABL|NUM:P|MUG:M|POS:POSgainetik|POS:+
DET	ERKARR	KAS:ABL|NUM:S|MUG:M
DET	ERKARR	KAS:ABL|NUM:S|MUG:M|POS:POSatzetik|POS:+
DET	ERKARR	KAS:ABL|NUM:S|MUG:M|POS:POSaurretik|POS:+
DET	ERKARR	KAS:ABL|NUM:S|MUG:M|POS:POSondotik|POS:+
DET	ERKARR	KAS:ABS|MUG:MG
DET	ERKARR	KAS:ABS|NUM:P|MUG:M
DET	ERKARR	KAS:ABS|NUM:P|MUG:M|POS:POSalde|POS:+
DET	ERKARR	KAS:ABS|NUM:P|MUG:M|POS:POSgain|POS:+
DET	ERKARR	KAS:ABS|NUM:S|MUG:M
DET	ERKARR	KAS:ABS|NUM:S|MUG:M|POS:POSalde|POS:+
DET	ERKARR	KAS:ABS|NUM:S|MUG:M|POS:POSarte|POS:+
DET	ERKARR	KAS:ABS|NUM:S|MUG:M|POS:POSaurka|POS:+
DET	ERKARR	KAS:ABS|NUM:S|MUG:M|POS:POSesker|POS:+
DET	ERKARR	KAS:ABS|NUM:S|MUG:M|POS:POSgain|POS:+
DET	ERKARR	KAS:ABS|NUM:S|MUG:M|POS:POSlanda|POS:+
DET	ERKARR	KAS:ABS|NUM:S|MUG:M|POS:POSmenpe|POS:+
DET	ERKARR	KAS:ABS|NUM:S|MUG:M|POS:POSpareko|POS:+
DET	ERKARR	KAS:ABS|NUM:S|MUG:M|POS:POStruke|POS:+
DET	ERKARR	KAS:ABU|NUM:S|MUG:M
DET	ERKARR	KAS:ALA|NUM:P|MUG:M
DET	ERKARR	KAS:ALA|NUM:P|MUG:M|POS:POSbatera|POS:+
DET	ERKARR	KAS:ALA|NUM:P|MUG:M|POS:POSgainera|POS:+
DET	ERKARR	KAS:ALA|NUM:P|MUG:M|POS:POSondora|POS:+
DET	ERKARR	KAS:ALA|NUM:S|MUG:M
DET	ERKARR	KAS:ALA|NUM:S|MUG:M|POS:POSbatera|POS:+
DET	ERKARR	KAS:ALA|NUM:S|MUG:M|POS:POSgainera|POS:+
DET	ERKARR	KAS:DAT|NUM:P|MUG:M
DET	ERKARR	KAS:DAT|NUM:S|MUG:M
DET	ERKARR	KAS:DES|NUM:P|MUG:M
DET	ERKARR	KAS:DES|NUM:S|MUG:M
DET	ERKARR	KAS:EM|NUM:P|MUG:M|POS:POSarabera|POS:+
DET	ERKARR	KAS:EM|NUM:P|MUG:M|POS:POSbarrena|POS:+
DET	ERKARR	KAS:EM|NUM:P|MUG:M|POS:POSbatera|POS:+
DET	ERKARR	KAS:EM|NUM:P|MUG:M|POS:POSbezalako|POS:+
DET	ERKARR	KAS:EM|NUM:P|MUG:M|POS:POSburuz|POS:+
DET	ERKARR	KAS:EM|NUM:P|MUG:M|POS:POSkontra|POS:+
DET	ERKARR	KAS:EM|NUM:P|MUG:M|POS:POSondoren|POS:+
DET	ERKARR	KAS:EM|NUM:P|MUG:M|POS:POSordez|POS:+
DET	ERKARR	KAS:EM|NUM:P|MUG:M|POS:POSzehar|POS:+
DET	ERKARR	KAS:EM|NUM:S|MUG:M|POS:POSantzeko|POS:+
DET	ERKARR	KAS:EM|NUM:S|MUG:M|POS:POSarabera|POS:+
DET	ERKARR	KAS:EM|NUM:S|MUG:M|POS:POSat|POS:+
DET	ERKARR	KAS:EM|NUM:S|MUG:M|POS:POSaurrera|POS:+
DET	ERKARR	KAS:EM|NUM:S|MUG:M|POS:POSbarrena|POS:+
DET	ERKARR	KAS:EM|NUM:S|MUG:M|POS:POSbegira|POS:+
DET	ERKARR	KAS:EM|NUM:S|MUG:M|POS:POSbezalako|POS:+
DET	ERKARR	KAS:EM|NUM:S|MUG:M|POS:POSbila|POS:+
DET	ERKARR	KAS:EM|NUM:S|MUG:M|POS:POSburuz|POS:+
DET	ERKARR	KAS:EM|NUM:S|MUG:M|POS:POSgainera|POS:+
DET	ERKARR	KAS:EM|NUM:S|MUG:M|POS:POSkontra|POS:+
DET	ERKARR	KAS:EM|NUM:S|MUG:M|POS:POSondoren|POS:+
DET	ERKARR	KAS:EM|NUM:S|MUG:M|POS:POSordez|POS:+
DET	ERKARR	KAS:EM|NUM:S|MUG:M|POS:POSurrun|POS:+
DET	ERKARR	KAS:EM|NUM:S|MUG:M|POS:POSzain|POS:+
DET	ERKARR	KAS:EM|NUM:S|MUG:M|POS:POSzehar|POS:+
DET	ERKARR	KAS:ERG|NUM:P|MUG:M
DET	ERKARR	KAS:ERG|NUM:S|MUG:M
DET	ERKARR	KAS:GEL|NUM:P|MUG:M
DET	ERKARR	KAS:GEL|NUM:P|MUG:M|POS:POSburuzko|POS:+
DET	ERKARR	KAS:GEL|NUM:P|MUG:M|POS:POSkontrako|POS:+
DET	ERKARR	KAS:GEL|NUM:S|MUG:M
DET	ERKARR	KAS:GEL|NUM:S|MUG:M|POS:POSantzeko|POS:+
DET	ERKARR	KAS:GEL|NUM:S|MUG:M|POS:POSatzeko|POS:+
DET	ERKARR	KAS:GEL|NUM:S|MUG:M|POS:POSburuzko|POS:+
DET	ERKARR	KAS:GEL|NUM:S|MUG:M|POS:POSinguruko|POS:+
DET	ERKARR	KAS:GEL|NUM:S|MUG:M|POS:POSkontrako|POS:+
DET	ERKARR	KAS:GEL|NUM:S|MUG:M|POS:POSondorengo|POS:+
DET	ERKARR	KAS:GEN|MUG:MG
DET	ERKARR	KAS:GEN|NUM:P|MUG:M
DET	ERKARR	KAS:GEN|NUM:S|MUG:M
DET	ERKARR	KAS:INE|NUM:P|MUG:M
DET	ERKARR	KAS:INE|NUM:P|MUG:M|POS:POSartean|POS:+
DET	ERKARR	KAS:INE|NUM:P|MUG:M|POS:POSatzean|POS:+
DET	ERKARR	KAS:INE|NUM:P|MUG:M|POS:POSaurrean|POS:+
DET	ERKARR	KAS:INE|NUM:P|MUG:M|POS:POSburuan|POS:+
DET	ERKARR	KAS:INE|NUM:P|MUG:M|POS:POSostean|POS:+
DET	ERKARR	KAS:INE|NUM:S|MUG:M
DET	ERKARR	KAS:INE|NUM:S|MUG:M|POS:POSaldean|POS:+
DET	ERKARR	KAS:INE|NUM:S|MUG:M|POS:POSatzean|POS:+
DET	ERKARR	KAS:INE|NUM:S|MUG:M|POS:POSaurrean|POS:+
DET	ERKARR	KAS:INE|NUM:S|MUG:M|POS:POSbaitan|POS:+
DET	ERKARR	KAS:INE|NUM:S|MUG:M|POS:POSbarnean|POS:+
DET	ERKARR	KAS:INE|NUM:S|MUG:M|POS:POSbarruan|POS:+
DET	ERKARR	KAS:INE|NUM:S|MUG:M|POS:POSburuan|POS:+
DET	ERKARR	KAS:INE|NUM:S|MUG:M|POS:POSgainean|POS:+
DET	ERKARR	KAS:INE|NUM:S|MUG:M|POS:POSinguruan|POS:+
DET	ERKARR	KAS:INE|NUM:S|MUG:M|POS:POSlekuan|POS:+
DET	ERKARR	KAS:INS|NUM:P|MUG:M
DET	ERKARR	KAS:INS|NUM:S|MUG:M
DET	ERKARR	KAS:INS|NUM:S|MUG:M|POS:POSbidez|POS:+
DET	ERKARR	KAS:INS|NUM:S|MUG:M|POS:POSbitartez|POS:+
DET	ERKARR	KAS:MOT|NUM:S|MUG:M
DET	ERKARR	KAS:SOZ|NUM:P|MUG:M
DET	ERKARR	KAS:SOZ|NUM:S|MUG:M
DET	ERKARR	MAI:IND|KAS:ABS|NUM:P|MUG:M
DET	ERKARR	MAI:IND|KAS:ABS|NUM:S|MUG:M
DET	ERKARR	MAI:IND|KAS:INE|NUM:S|MUG:M
DET	ERKARR	MAI:IND|KAS:MOT|NUM:S|MUG:M
DET	ERKARR	MAI:IND|KAS:SOZ|NUM:S|MUG:M
DET	ERKIND	KAS:ABS|NUM:P|MUG:M
DET	ERKIND	KAS:ABS|NUM:S|MUG:M
DET	ERKIND	KAS:GEL
DET	ERKIND	NMG:P|KAS:ABS|NUM:P|MUG:M
DET	ERKIND	NMG:P|KAS:ABS|NUM:P|MUG:M|POS:POSesku|POS:+
DET	ERKIND	NMG:P|KAS:ABS|NUM:P|MUG:M|POS:POSmenpe|POS:+
DET	ERKIND	NMG:P|KAS:ERG|NUM:P|MUG:M
DET	ERKIND	NMG:P|KAS:GEN
DET	ERKIND	NMG:P|KAS:GEN|NUM:P|MUG:M
DET	ERKIND	NMG:P|KAS:INE|NUM:P|MUG:M
DET	ERKIND	NMG:P|KAS:INE|NUM:P|MUG:M|POS:POSartean|POS:+
DET	ERKIND	NMG:P|KAS:INE|NUM:P|MUG:M|POS:POSbaitan|POS:+
DET	ERKIND	NMG:P|KAS:INS|NUM:P|MUG:M
DET	ERKIND	NMG:S|KAS:ABL
DET	ERKIND	NMG:S|KAS:ABL|POS:POSaitzinetik|POS:+
DET	ERKIND	NMG:S|KAS:ABL|POS:POSaldetik|POS:+
DET	ERKIND	NMG:S|KAS:ABS|MUG:M
DET	ERKIND	NMG:S|KAS:ABS|MUG:MG
DET	ERKIND	NMG:S|KAS:ABS|NUM:P|MUG:M
DET	ERKIND	NMG:S|KAS:ABS|NUM:S|MUG:M
DET	ERKIND	NMG:S|KAS:ABS|POS:POSalde|POS:+
DET	ERKIND	NMG:S|KAS:ABS|POS:POSaurka|POS:+
DET	ERKIND	NMG:S|KAS:ABS|POS:POSesku|POS:+
DET	ERKIND	NMG:S|KAS:ABS|POS:POSgain|POS:+
DET	ERKIND	NMG:S|KAS:ABU|NUM:S|MUG:M
DET	ERKIND	NMG:S|KAS:ALA
DET	ERKIND	NMG:S|KAS:ALA|NUM:S|MUG:M
DET	ERKIND	NMG:S|KAS:ALA|POS:POSmodura|POS:+
DET	ERKIND	NMG:S|KAS:DAT|NUM:S|MUG:M
DET	ERKIND	NMG:S|KAS:DES
DET	ERKIND	NMG:S|KAS:DES|NUM:S|MUG:M
DET	ERKIND	NMG:S|KAS:EM|NUM:S|MUG:M|POS:POSbezalako|POS:+
DET	ERKIND	NMG:S|KAS:EM|NUM:S|MUG:M|POS:POSbila|POS:+
DET	ERKIND	NMG:S|KAS:EM|NUM:S|MUG:M|POS:POSgabe|POS:+
DET	ERKIND	NMG:S|KAS:EM|NUM:S|MUG:M|POS:POSurruti|POS:+
DET	ERKIND	NMG:S|KAS:EM|POS:POSantzeko|POS:+
DET	ERKIND	NMG:S|KAS:ERG|NUM:S|MUG:M
DET	ERKIND	NMG:S|KAS:ERG|NUM:S|MUG:M|ENT:Pertsona
DET	ERKIND	NMG:S|KAS:GEL|POS:POSaurreko|POS:+
DET	ERKIND	NMG:S|KAS:GEL|POS:POSkontrako|POS:+
DET	ERKIND	NMG:S|KAS:GEN
DET	ERKIND	NMG:S|KAS:GEN|NUM:S|MUG:M
DET	ERKIND	NMG:S|KAS:INE
DET	ERKIND	NMG:S|KAS:INE|NUM:S|MUG:M
DET	ERKIND	NMG:S|KAS:INE|POS:POSartean|POS:+
DET	ERKIND	NMG:S|KAS:INE|POS:POSaurrean|POS:+
DET	ERKIND	NMG:S|KAS:INE|POS:POSbaitan|POS:+
DET	ERKIND	NMG:S|KAS:INE|POS:POSbarnean|POS:+
DET	ERKIND	NMG:S|KAS:INE|POS:POSburuan|POS:+
DET	ERKIND	NMG:S|KAS:INE|POS:POSgainean|POS:+
DET	ERKIND	NMG:S|KAS:INE|POS:POSlekuan|POS:+
DET	ERKIND	NMG:S|KAS:INE|POS:POSondoan|POS:+
DET	ERKIND	NMG:S|KAS:INS|NUM:S|MUG:M
DET	ERKIND	NMG:S|KAS:MOT|NUM:S|MUG:M
DET	ERKIND	NMG:S|KAS:SOZ|NUM:S|MUG:M
DET	NOLARR	KAS:ABS|MUG:MG
DET	NOLARR	NMG:MG
DET	NOLARR	NMG:MG|KAS:ABS|MUG:MG
DET	NOLARR	NMG:MG|KAS:DAT|MUG:MG
DET	NOLARR	NMG:MG|KAS:ERG|MUG:MG
DET	NOLGAL	KAS:ABS|MUG:MG
DET	NOLGAL	KAS:GEL|MUG:MG
DET	NOLGAL	NMG:MG
DET	NOLGAL	NMG:MG|KAS:ABS|MUG:MG
DET	NOLGAL	NMG:MG|KAS:ABS|NUM:S|MUG:M
DET	NOLGAL	NMG:MG|KAS:ABU
DET	NOLGAL	NMG:MG|KAS:ALA|MUG:MG
DET	NOLGAL	NMG:MG|KAS:DAT|MUG:MG
DET	NOLGAL	NMG:MG|KAS:DES|MUG:MG
DET	NOLGAL	NMG:MG|KAS:ERG|MUG:MG
DET	NOLGAL	NMG:MG|KAS:GEN|NUM:P|MUG:M
DET	NOLGAL	NMG:MG|KAS:INE|MUG:MG
DET	NOLGAL	NMG:MG|KAS:INS
DET	NOLGAL	NMG:P|KAS:ABS|MUG:MG
DET	NOLGAL	NMG:P|KAS:ABS|NUM:P|MUG:M
DET	NOLGAL	NMG:P|KAS:INE|NUM:P|MUG:M
DET	ORD	ENT:Erakundea
DET	ORD	ENT:Pertsona
DET	ORD	KAS:ABS|MUG:MG
DET	ORD	KAS:ABS|NUM:P|MUG:M
DET	ORD	KAS:ABS|NUM:S|MUG:M
DET	ORD	KAS:ABS|NUM:S|MUG:M|ENT:Erakundea
DET	ORD	KAS:ABS|NUM:S|MUG:M|ENT:Pertsona
DET	ORD	KAS:ABS|NUM:S|MUG:M|POS:POSarte|POS:+
DET	ORD	KAS:ALA|NUM:S|MUG:M
DET	ORD	KAS:DAT|NUM:S|MUG:M
DET	ORD	KAS:ERG|NUM:P|MUG:M
DET	ORD	KAS:ERG|NUM:S|MUG:M
DET	ORD	KAS:ERG|NUM:S|MUG:M|ENT:Pertsona
DET	ORD	KAS:GEL|NUM:S|MUG:M
DET	ORD	KAS:GEN|NUM:S|MUG:M|ENT:Erakundea
DET	ORD	KAS:GEN|NUM:S|MUG:M|ENT:Pertsona
DET	ORD	KAS:INE|NUM:P|MUG:M
DET	ORD	KAS:INE|NUM:S|MUG:M
DET	ORD	KAS:INS|MUG:MG
DET	ORD	KAS:PAR|MUG:MG
DET	ORD	KAS:SOZ|NUM:S|MUG:M|ENT:Pertsona
DET	ORD	_
DET	ORO	KAS:ABL|NUM:P|MUG:M
DET	ORO	KAS:ABL|NUM:P|MUG:M|POS:POSgainetik|POS:+
DET	ORO	KAS:ABL|NUM:S|MUG:M
DET	ORO	KAS:ABL|NUM:S|MUG:M|POS:POSgainetik|POS:+
DET	ORO	KAS:ABS|MUG:MG
DET	ORO	KAS:ABS|NUM:PH|MUG:M
DET	ORO	KAS:ABS|NUM:P|MUG:M
DET	ORO	KAS:ABS|NUM:S|MUG:M
DET	ORO	KAS:ABS|NUM:S|MUG:M|POS:POSgain|POS:+
DET	ORO	KAS:ALA|NUM:P|MUG:M
DET	ORO	KAS:ALA|NUM:S|MUG:M
DET	ORO	KAS:DAT|NUM:PH|MUG:M
DET	ORO	KAS:DAT|NUM:P|MUG:M
DET	ORO	KAS:DAT|NUM:S|MUG:M
DET	ORO	KAS:DES|NUM:PH|MUG:M
DET	ORO	KAS:DES|NUM:P|MUG:M
DET	ORO	KAS:EM|NUM:P|MUG:M|POS:POSantzera|POS:+
DET	ORO	KAS:EM|NUM:P|MUG:M|POS:POSarabera|POS:+
DET	ORO	KAS:EM|NUM:P|MUG:M|POS:POSbezala|POS:+
DET	ORO	KAS:EM|NUM:S|MUG:M|POS:POSzehar|POS:+
DET	ORO	KAS:ERG|NUM:PH|MUG:M
DET	ORO	KAS:ERG|NUM:P|MUG:M
DET	ORO	KAS:ERG|NUM:S|MUG:M
DET	ORO	KAS:GEL|NUM:P|MUG:M
DET	ORO	KAS:GEL|NUM:P|MUG:M|POS:POSarteko|POS:+
DET	ORO	KAS:GEN|NUM:PH|MUG:M
DET	ORO	KAS:GEN|NUM:P|MUG:M
DET	ORO	KAS:GEN|NUM:S|MUG:M
DET	ORO	KAS:INE|NUM:PH|MUG:M|POS:POSartean|POS:+
DET	ORO	KAS:INE|NUM:P|MUG:M
DET	ORO	KAS:INE|NUM:P|MUG:M|POS:POSaldean|POS:+
DET	ORO	KAS:INE|NUM:P|MUG:M|POS:POSartean|POS:+
DET	ORO	KAS:INE|NUM:P|MUG:M|POS:POSerdian|POS:+
DET	ORO	KAS:INE|NUM:S|MUG:M
DET	ORO	KAS:INE|NUM:S|MUG:M|POS:POSatzean|POS:+
DET	ORO	KAS:INE|NUM:S|MUG:M|POS:POSaurrean|POS:+
DET	ORO	KAS:INS|NUM:P|MUG:M
DET	ORO	KAS:MOT|NUM:S|MUG:M
DET	ORO	KAS:SOZ|NUM:P|MUG:M
DET	ORO	KAS:SOZ|NUM:S|MUG:M
DET	ORO	NMG:MG|KAS:ABS|MUG:MG
DET	ORO	NMG:MG|KAS:DAT|MUG:MG
DET	ORO	NMG:MG|KAS:ERG|MUG:MG
DET	ORO	NMG:MG|KAS:INS|MUG:MG
DET	ORO	_
ERL	ERL	ERL:KAUS
HAOS	HAOS	_
IOR	ELK	KAS:ABS|MUG:MG
IOR	ELK	KAS:ABS|MUG:MG|POS:POSaurka|POS:+
IOR	ELK	KAS:DAT|MUG:MG
IOR	ELK	KAS:EM|MUG:MG|POS:POSburuz|POS:+
IOR	ELK	KAS:EM|MUG:MG|POS:POSkontra|POS:+
IOR	ELK	KAS:GEL|MUG:MG
IOR	ELK	KAS:GEN|MUG:MG
IOR	ELK	KAS:INE|MUG:MG|POS:POSartean|POS:+
IOR	ELK	KAS:SOZ|MUG:MG
IOR	IZGGAL	KAS:ABS|MUG:MG
IOR	IZGGAL	KAS:ABS|MUG:MG|POS:POSalde|POS:+
IOR	IZGGAL	KAS:DAT|MUG:MG
IOR	IZGGAL	KAS:EM|MUG:MG|POS:POSkontra|POS:+
IOR	IZGGAL	KAS:ERG|MUG:MG
IOR	IZGGAL	KAS:SOZ|MUG:MG
IOR	IZGGAL	PER:HAIEK|KAS:ABS|NUM:P|MUG:M
IOR	IZGGAL	PER:HAIEK|KAS:ABS|NUM:P|MUG:M|POS:POSesku|POS:+
IOR	IZGMGB	KAS:ABS|MUG:MG
IOR	IZGMGB	KAS:ABS|MUG:MG|MW:B
IOR	IZGMGB	KAS:ABS|NUM:S|MUG:M|POS:POSesku|POS:+
IOR	IZGMGB	KAS:ABS|POS:POSgisako|POS:+
IOR	IZGMGB	KAS:ALA
IOR	IZGMGB	KAS:DAT|MUG:MG
IOR	IZGMGB	KAS:DES|MUG:MG
IOR	IZGMGB	KAS:ERG|MUG:MG
IOR	IZGMGB	KAS:ERG|NUM:S|MUG:M
IOR	IZGMGB	KAS:GEL|MUG:MG
IOR	IZGMGB	KAS:GEL|MW:B
IOR	IZGMGB	KAS:GEN
IOR	IZGMGB	KAS:GEN|MUG:MG
IOR	IZGMGB	KAS:GEN|NUM:S|MUG:M
IOR	IZGMGB	KAS:INE|MUG:MG
IOR	IZGMGB	KAS:INS
IOR	IZGMGB	KAS:INS|MUG:MG
IOR	IZGMGB	KAS:MOT
IOR	IZGMGB	KAS:SOZ
IOR	IZGMGB	KAS:SOZ|MUG:MG
IOR	IZGMGB	KAS:SOZ|NUM:P|MUG:M|MW:B
IOR	IZGMGB	NMG:MG|KAS:ABS|MUG:MG|MW:B
IOR	IZGMGB	NMG:MG|KAS:ERG|MUG:MG|MW:B
IOR	IZGMGB	NMG:P|KAS:ABS|NUM:P|MUG:M|MW:B
IOR	IZGMGB	NMG:S|KAS:ABS|MUG:MG|MW:B
IOR	IZGMGB	NMG:S|KAS:ERG|MUG:MG|MW:B
IOR	IZGMGB	PER:HAIEK|KAS:ABS|NUM:P|MUG:M
IOR	PERARR	PER:GU|KAS:ABL|NUM:P|MUG:M|POS:POSaldetik|POS:+
IOR	PERARR	PER:GU|KAS:ABS|NUM:P|MUG:M
IOR	PERARR	PER:GU|KAS:DAT|NUM:P|MUG:M
IOR	PERARR	PER:GU|KAS:DES|NUM:P|MUG:M
IOR	PERARR	PER:GU|KAS:EM|NUM:P|MUG:M|POS:POSbegira|POS:+
IOR	PERARR	PER:GU|KAS:EM|NUM:P|MUG:M|POS:POSbezala|POS:+
IOR	PERARR	PER:GU|KAS:EM|NUM:P|MUG:M|POS:POSzain|POS:+
IOR	PERARR	PER:GU|KAS:ERG|NUM:P|MUG:M
IOR	PERARR	PER:GU|KAS:GEL|NUM:P|MUG:M
IOR	PERARR	PER:GU|KAS:GEN|NUM:P|MUG:M
IOR	PERARR	PER:GU|KAS:INE|NUM:P|MUG:M
IOR	PERARR	PER:GU|KAS:INE|NUM:P|MUG:M|POS:POSartean|POS:+
IOR	PERARR	PER:GU|KAS:INE|NUM:P|MUG:M|POS:POSinguruan|POS:+
IOR	PERARR	PER:GU|KAS:INS|NUM:P|MUG:M
IOR	PERARR	PER:GU|KAS:SOZ|NUM:P|MUG:M
IOR	PERARR	PER:HAIEK|KAS:ABS|NUM:P|MUG:M
IOR	PERARR	PER:HAIEK|KAS:DAT|NUM:P|MUG:M
IOR	PERARR	PER:HAIEK|KAS:DES|NUM:P|MUG:M
IOR	PERARR	PER:HAIEK|KAS:EM|NUM:P|MUG:M|POS:POSkontra|POS:+
IOR	PERARR	PER:HAIEK|KAS:ERG|NUM:P|MUG:M
IOR	PERARR	PER:HAIEK|KAS:GEL|NUM:P|MUG:M|POS:POSarteko|POS:+
IOR	PERARR	PER:HAIEK|KAS:GEN|NUM:P|MUG:M
IOR	PERARR	PER:HAIEK|KAS:INE|NUM:P|MUG:M|POS:POSaitzinean|POS:+
IOR	PERARR	PER:HAIEK|KAS:INE|NUM:P|MUG:M|POS:POSartean|POS:+
IOR	PERARR	PER:HAIEK|KAS:INS|NUM:P|MUG:M
IOR	PERARR	PER:HAIEK|KAS:SOZ|NUM:P|MUG:M
IOR	PERARR	PER:HI|KAS:ABS|NUM:S|MUG:M
IOR	PERARR	PER:HI|KAS:DAT|NUM:S|MUG:M
IOR	PERARR	PER:HI|KAS:ERG|NUM:S|MUG:M
IOR	PERARR	PER:HI|KAS:GEN|NUM:S|MUG:M
IOR	PERARR	PER:HURA|KAS:ABS|NUM:S|MUG:M
IOR	PERARR	PER:NI|KAS:ABS|NUM:S|MUG:M
IOR	PERARR	PER:NI|KAS:ALA|NUM:S|MUG:M
IOR	PERARR	PER:NI|KAS:DAT|NUM:S|MUG:M
IOR	PERARR	PER:NI|KAS:DES|NUM:S|MUG:M
IOR	PERARR	PER:NI|KAS:EM|NUM:S|MUG:M|POS:POSbegira|POS:+
IOR	PERARR	PER:NI|KAS:EM|NUM:S|MUG:M|POS:POSbezala|POS:+
IOR	PERARR	PER:NI|KAS:EM|NUM:S|MUG:M|POS:POSzai|POS:+
IOR	PERARR	PER:NI|KAS:ERG|NUM:S|MUG:M
IOR	PERARR	PER:NI|KAS:ERG|NUM:S|MUG:M|ENT:Pertsona
IOR	PERARR	PER:NI|KAS:GEL|NUM:S|MUG:M|POS:POSatzeko|POS:+
IOR	PERARR	PER:NI|KAS:GEL|NUM:S|MUG:M|POS:POSbarneko|POS:+
IOR	PERARR	PER:NI|KAS:GEN|NUM:S|MUG:M
IOR	PERARR	PER:NI|KAS:INE|NUM:S|MUG:M
IOR	PERARR	PER:NI|KAS:INE|NUM:S|MUG:M|POS:POSaurrean|POS:+
IOR	PERARR	PER:NI|KAS:INE|NUM:S|MUG:M|POS:POSbarnean|POS:+
IOR	PERARR	PER:NI|KAS:INS|NUM:S|MUG:M
IOR	PERARR	PER:NI|KAS:MOT|NUM:S|MUG:M
IOR	PERARR	PER:NI|KAS:SOZ|NUM:S|MUG:M
IOR	PERARR	PER:ZUEK|KAS:ABS|NUM:P|MUG:M
IOR	PERARR	PER:ZUEK|KAS:ABS|NUM:P|MUG:M|POS:POSgain|POS:+
IOR	PERARR	PER:ZUEK|KAS:DAT|NUM:P|MUG:M
IOR	PERARR	PER:ZUEK|KAS:ERG|NUM:P|MUG:M
IOR	PERARR	PER:ZUEK|KAS:GEL|NUM:P|MUG:M
IOR	PERARR	PER:ZUEK|KAS:GEN|NUM:P|MUG:M
IOR	PERARR	PER:ZUEK|KAS:INE|NUM:P|MUG:M|POS:POSartean|POS:+
IOR	PERARR	PER:ZUEK|KAS:INS|NUM:P|MUG:M
IOR	PERARR	PER:ZU|KAS:ABL|NUM:S|MUG:M
IOR	PERARR	PER:ZU|KAS:ABS|NUM:S|MUG:M
IOR	PERARR	PER:ZU|KAS:DES|NUM:S|MUG:M
IOR	PERARR	PER:ZU|KAS:ERG|NUM:S|MUG:M
IOR	PERARR	PER:ZU|KAS:GEL|NUM:S|MUG:M|POS:POSbarneko|POS:+
IOR	PERARR	PER:ZU|KAS:GEN|NUM:S|MUG:M
IOR	PERARR	PER:ZU|KAS:GEN|NUM:S|MUG:M|ENT:Erakundea
IOR	PERARR	PER:ZU|KAS:INS|NUM:S|MUG:M
IOR	PERARR	PER:ZU|KAS:SOZ|NUM:S|MUG:M
IOR	PERIND	PER:GU|KAS:ABS|NUM:P|MUG:M
IOR	PERIND	PER:GU|KAS:DAT|NUM:P|MUG:M
IOR	PERIND	PER:GU|KAS:ERG|NUM:P|MUG:M
IOR	PERIND	PER:GU|KAS:GEN|NUM:P|MUG:M
IOR	PERIND	PER:GU|KAS:INE|NUM:P|MUG:M
IOR	PERIND	PER:HI|KAS:GEN|NUM:S|MUG:M
IOR	PERIND	PER:NI|KAS:ABL|NUM:S|MUG:M|POS:POSaldetik|POS:+
IOR	PERIND	PER:NI|KAS:ABS|NUM:S|MUG:M
IOR	PERIND	PER:NI|KAS:DAT|NUM:S|MUG:M
IOR	PERIND	PER:NI|KAS:ERG|NUM:S|MUG:M
IOR	PERIND	PER:NI|KAS:GEN|NUM:S|MUG:M
IOR	PERIND	PER:NI|KAS:INE|NUM:S|MUG:M|POS:POSburuan|POS:+
IOR	PERIND	PER:ZU|KAS:ABS|NUM:S|MUG:M
IOR	PERIND	PER:ZU|KAS:EM|NUM:S|MUG:M|POS:POSgisara|POS:+
IOR	PERIND	PER:ZU|KAS:ERG|NUM:S|MUG:M
IOR	PERIND	PER:ZU|KAS:GEN|NUM:S|MUG:M
IOR	PERIND	PER:ZU|KAS:INE|NUM:S|MUG:M|POS:POSinguruan|POS:+
ITJ	ARR	BIZ:-|KAS:ABS|MUG:MG|MW:B
ITJ	ITJ	ENT:Pertsona
ITJ	ITJ	MW:B
ITJ	ITJ	_
IZE	ADB_IZEELI	KAS:ABS|NUM:P|MUG:M
IZE	ADB_IZEELI	KAS:ABS|NUM:S|MUG:M
IZE	ADB_IZEELI	KAS:ERG|NUM:P|MUG:M
IZE	ADB_IZEELI	KAS:ERG|NUM:S|MUG:M
IZE	ADB_IZEELI	KAS:GEN|NUM:S|MUG:M
IZE	ADB_IZEELI	KAS:INE|NUM:S|MUG:M
IZE	ADB_IZEELI	KAS:INS|NUM:S|MUG:M
IZE	ADJ_IZEELI	IZAUR:+|KAS:ABS|NUM:P|MUG:M
IZE	ADJ_IZEELI	IZAUR:+|KAS:ABS|NUM:S|MUG:M
IZE	ADJ_IZEELI	IZAUR:-|KAS:ABS|NUM:P|MUG:M
IZE	ADJ_IZEELI	IZAUR:-|KAS:ABS|NUM:S|MUG:M
IZE	ADJ_IZEELI	IZAUR:-|KAS:ABS|NUM:S|MUG:M|ENT:Pertsona
IZE	ADJ_IZEELI	IZAUR:-|KAS:GEN|NUM:P|MUG:M
IZE	ADJ_IZEELI	IZAUR:-|KAS:INE|NUM:S|MUG:M
IZE	ADJ_IZEELI	MAI:SUP|IZAUR:+|KAS:ABS|NUM:S|MUG:M
IZE	ADJ_IZEELI	MAI:SUP|IZAUR:-|KAS:ABS|NUM:S|MUG:M
IZE	ARR	ADM:ADIZE
IZE	ARR	ADM:ADIZE|KAS:ABS|NUM:S|MUG:M
IZE	ARR	BIZ:+
IZE	ARR	BIZ:+|ENT:Erakundea
IZE	ARR	BIZ:+|KAS:ABL|MUG:MG
IZE	ARR	BIZ:+|KAS:ABL|NUM:P|MUG:M
IZE	ARR	BIZ:+|KAS:ABL|NUM:P|MUG:M|POS:POSaldamenetik|POS:+
IZE	ARR	BIZ:+|KAS:ABL|NUM:P|MUG:M|POS:POSaldetik|POS:+
IZE	ARR	BIZ:+|KAS:ABL|NUM:S|MUG:M
IZE	ARR	BIZ:+|KAS:ABS|MUG:MG
IZE	ARR	BIZ:+|KAS:ABS|MUG:MG|ENT:Erakundea
IZE	ARR	BIZ:+|KAS:ABS|MUG:MG|MW:B
IZE	ARR	BIZ:+|KAS:ABS|MUG:MG|POS:POSaurka|POS:+
IZE	ARR	BIZ:+|KAS:ABS|NUM:PH|MUG:M
IZE	ARR	BIZ:+|KAS:ABS|NUM:P|MUG:M
IZE	ARR	BIZ:+|KAS:ABS|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:+|KAS:ABS|NUM:P|MUG:M|POS:POSalde|POS:+
IZE	ARR	BIZ:+|KAS:ABS|NUM:P|MUG:M|POS:POSaurka|POS:+
IZE	ARR	BIZ:+|KAS:ABS|NUM:P|MUG:M|POS:POSesku|POS:+
IZE	ARR	BIZ:+|KAS:ABS|NUM:S|MUG:M
IZE	ARR	BIZ:+|KAS:ABS|NUM:S|MUG:M|ENT:???
IZE	ARR	BIZ:+|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:+|KAS:ABS|NUM:S|MUG:M|MW:B
IZE	ARR	BIZ:+|KAS:ABS|NUM:S|MUG:M|POS:POSalde|POS:+
IZE	ARR	BIZ:+|KAS:ABS|NUM:S|MUG:M|POS:POSeskuko|POS:+
IZE	ARR	BIZ:+|KAS:ABS|NUM:S|MUG:M|POS:POSgain|POS:+
IZE	ARR	BIZ:+|KAS:ABS|NUM:S|MUG:M|POS:POSmenpe|POS:+
IZE	ARR	BIZ:+|KAS:ALA|MUG:MG
IZE	ARR	BIZ:+|KAS:ALA|MUG:MG|POS:POSbatera|POS:+
IZE	ARR	BIZ:+|KAS:ALA|NUM:P|MUG:M
IZE	ARR	BIZ:+|KAS:ALA|NUM:P|MUG:M|POS:POSbatera?|POS:+
IZE	ARR	BIZ:+|KAS:ALA|NUM:S|MUG:M
IZE	ARR	BIZ:+|KAS:ALA|NUM:S|MUG:M|POS:POSbatera|POS:+
IZE	ARR	BIZ:+|KAS:DAT|MUG:MG
IZE	ARR	BIZ:+|KAS:DAT|NUM:P|MUG:M
IZE	ARR	BIZ:+|KAS:DAT|NUM:S|MUG:M
IZE	ARR	BIZ:+|KAS:DAT|NUM:S|MUG:M|ENT:Tokia
IZE	ARR	BIZ:+|KAS:DAT|NUM:S|MUG:M|MW:B
IZE	ARR	BIZ:+|KAS:DESK
IZE	ARR	BIZ:+|KAS:DES|MUG:MG
IZE	ARR	BIZ:+|KAS:DES|NUM:P|MUG:M
IZE	ARR	BIZ:+|KAS:DES|NUM:S|MUG:M
IZE	ARR	BIZ:+|KAS:DES|NUM:S|MUG:M|MW:B
IZE	ARR	BIZ:+|KAS:EM|MUG:MG|POS:POSgabe|POS:+
IZE	ARR	BIZ:+|KAS:EM|NUM:P|MUG:M|POS:POSarabera|POS:+
IZE	ARR	BIZ:+|KAS:EM|NUM:P|MUG:M|POS:POSbatera|POS:+
IZE	ARR	BIZ:+|KAS:EM|NUM:P|MUG:M|POS:POSbezala|POS:+
IZE	ARR	BIZ:+|KAS:EM|NUM:P|MUG:M|POS:POSburuz|POS:+
IZE	ARR	BIZ:+|KAS:EM|NUM:P|MUG:M|POS:POSkontra|POS:+
IZE	ARR	BIZ:+|KAS:EM|NUM:P|MUG:M|POS:POSondoan|POS:+
IZE	ARR	BIZ:+|KAS:EM|NUM:P|MUG:M|POS:POSordez|POS:+
IZE	ARR	BIZ:+|KAS:EM|NUM:S|MUG:M|POS:POSarabera|POS:+
IZE	ARR	BIZ:+|KAS:EM|NUM:S|MUG:M|POS:POSbezala|POS:+
IZE	ARR	BIZ:+|KAS:EM|NUM:S|MUG:M|POS:POSburuz|POS:+
IZE	ARR	BIZ:+|KAS:ERG|MUG:MG
IZE	ARR	BIZ:+|KAS:ERG|NUM:PH|MUG:M
IZE	ARR	BIZ:+|KAS:ERG|NUM:P|MUG:M
IZE	ARR	BIZ:+|KAS:ERG|NUM:S|MUG:M
IZE	ARR	BIZ:+|KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:+|KAS:ERG|NUM:S|MUG:M|MW:B
IZE	ARR	BIZ:+|KAS:GEL|NUM:PH|MUG:M|POS:POSarteko|POS:+
IZE	ARR	BIZ:+|KAS:GEL|NUM:P|MUG:M
IZE	ARR	BIZ:+|KAS:GEL|NUM:P|MUG:M|ENT:Erakundea|POS:POSGabeko|POS:+
IZE	ARR	BIZ:+|KAS:GEL|NUM:P|MUG:M|POS:POSarteko|POS:+
IZE	ARR	BIZ:+|KAS:GEL|NUM:P|MUG:M|POS:POSatzeko|POS:+
IZE	ARR	BIZ:+|KAS:GEL|NUM:P|MUG:M|POS:POSaurkako|POS:+
IZE	ARR	BIZ:+|KAS:GEL|NUM:S|MUG:M
IZE	ARR	BIZ:+|KAS:GEL|NUM:S|MUG:M|POS:POSarteko|POS:+
IZE	ARR	BIZ:+|KAS:GEN|MUG:MG
IZE	ARR	BIZ:+|KAS:GEN|NUM:PH|MUG:M
IZE	ARR	BIZ:+|KAS:GEN|NUM:P|MUG:M
IZE	ARR	BIZ:+|KAS:GEN|NUM:P|MUG:M|ENT:Pertsona
IZE	ARR	BIZ:+|KAS:GEN|NUM:P|MUG:M|MW:B|KAS:INE|POS:POSaurrean|POS:+
IZE	ARR	BIZ:+|KAS:GEN|NUM:S|MUG:M
IZE	ARR	BIZ:+|KAS:GEN|NUM:S|MUG:M|ENT:Pertsona
IZE	ARR	BIZ:+|KAS:GEN|NUM:S|MUG:M|MW:B
IZE	ARR	BIZ:+|KAS:INE|MUG:MG
IZE	ARR	BIZ:+|KAS:INE|NUM:P|MUG:M
IZE	ARR	BIZ:+|KAS:INE|NUM:P|MUG:M|POS:POSartean|POS:+
IZE	ARR	BIZ:+|KAS:INE|NUM:P|MUG:M|POS:POSaurrean|POS:+
IZE	ARR	BIZ:+|KAS:INE|NUM:P|MUG:M|POS:POSeskuetan|POS:+
IZE	ARR	BIZ:+|KAS:INE|NUM:P|MUG:M|POS:POSgainean|POS:+
IZE	ARR	BIZ:+|KAS:INE|NUM:P|MUG:M|POS:POSmendean|POS:+
IZE	ARR	BIZ:+|KAS:INE|NUM:P|MUG:M|POS:POSondoan|POS:+
IZE	ARR	BIZ:+|KAS:INE|NUM:S|MUG:M
IZE	ARR	BIZ:+|KAS:INE|NUM:S|MUG:M|POS:POSaurrean|POS:+
IZE	ARR	BIZ:+|KAS:INE|NUM:S|MUG:M|POS:POSinguruan|POS:+
IZE	ARR	BIZ:+|KAS:INS|MUG:MG
IZE	ARR	BIZ:+|KAS:INS|NUM:P|MUG:M
IZE	ARR	BIZ:+|KAS:INS|NUM:P|MUG:M|POS:POSbidez|POS:+
IZE	ARR	BIZ:+|KAS:INS|NUM:S|MUG:M
IZE	ARR	BIZ:+|KAS:INS|NUM:S|MUG:M|POS:POSbitartez|POS:+
IZE	ARR	BIZ:+|KAS:PAR|MUG:MG
IZE	ARR	BIZ:+|KAS:PRO|MUG:MG
IZE	ARR	BIZ:+|KAS:SOZ|MUG:MG
IZE	ARR	BIZ:+|KAS:SOZ|NUM:P|MUG:M
IZE	ARR	BIZ:+|KAS:SOZ|NUM:S|MUG:M
IZE	ARR	BIZ:+|KAS:SOZ|NUM:S|MUG:M|MW:B
IZE	ARR	BIZ:+|MW:B
IZE	ARR	BIZ:+|POS:POSaitzinetik|POS:+|KAS:ABL
IZE	ARR	BIZ:+|POS:POSbezala|POS:+|KAS:EM
IZE	ARR	BIZ:+|POS:POSbila|POS:+|KAS:EM
IZE	ARR	BIZ:+|POS:POSgisa|POS:+|KAS:ABS
IZE	ARR	BIZ:+|POS:POSinguruko|POS:+|KAS:GEL
IZE	ARR	BIZ:+|POS:POSinguru|POS:+|KAS:ABS
IZE	ARR	BIZ:-
IZE	ARR	BIZ:-|ADM:ADIZE|KAS:EM|NUM:S|MUG:M|POS:POSburuz|POS:+
IZE	ARR	BIZ:-|ENT:Erakundea
IZE	ARR	BIZ:-|ENT:Pertsona
IZE	ARR	BIZ:-|ENT:Tokia
IZE	ARR	BIZ:-|IZAUR:-|KAS:ERG|MUG:MG|MW:B
IZE	ARR	BIZ:-|IZAUR:-|KAS:ERG|NUM:S|MUG:M|MW:B
IZE	ARR	BIZ:-|IZAUR:-|KAS:ERG|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:ABL|MUG:MG
IZE	ARR	BIZ:-|KAS:ABL|MUG:MG|POS:POSaldetik|POS:+
IZE	ARR	BIZ:-|KAS:ABL|NUM:PH|MUG:M
IZE	ARR	BIZ:-|KAS:ABL|NUM:P|MUG:M
IZE	ARR	BIZ:-|KAS:ABL|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:ABL|NUM:P|MUG:M|POS:POSaldetik|POS:+
IZE	ARR	BIZ:-|KAS:ABL|NUM:P|MUG:M|POS:POSaurretik|POS:+
IZE	ARR	BIZ:-|KAS:ABL|NUM:P|MUG:M|POS:POSgainetik|POS:+
IZE	ARR	BIZ:-|KAS:ABL|NUM:S|MUG:M
IZE	ARR	BIZ:-|KAS:ABL|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:ABL|NUM:S|MUG:M|ENT:Erakundea|POS:POSaldetik|POS:+
IZE	ARR	BIZ:-|KAS:ABL|NUM:S|MUG:M|ENT:Tokia
IZE	ARR	BIZ:-|KAS:ABL|NUM:S|MUG:M|POS:POSaldetik|POS:+
IZE	ARR	BIZ:-|KAS:ABL|NUM:S|MUG:M|POS:POSatzetik|POS:+
IZE	ARR	BIZ:-|KAS:ABL|NUM:S|MUG:M|POS:POSaurretik|POS:+
IZE	ARR	BIZ:-|KAS:ABL|NUM:S|MUG:M|POS:POSazpitik|POS:+
IZE	ARR	BIZ:-|KAS:ABL|NUM:S|MUG:M|POS:POSbarrutik|POS:+
IZE	ARR	BIZ:-|KAS:ABL|NUM:S|MUG:M|POS:POSeskutik|POS:+
IZE	ARR	BIZ:-|KAS:ABL|NUM:S|MUG:M|POS:POSgainetik|POS:+
IZE	ARR	BIZ:-|KAS:ABS|MUG:MG
IZE	ARR	BIZ:-|KAS:ABS|MUG:MG|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:ABS|MUG:MG|ENT:Erakundea|POS:POSaurka|POS:+
IZE	ARR	BIZ:-|KAS:ABS|MUG:MG|MW:B
IZE	ARR	BIZ:-|KAS:ABS|MUG:MG|POS:POSgain|POS:+
IZE	ARR	BIZ:-|KAS:ABS|MUG:MG|POS:POSkanpo|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:PH|MUG:M
IZE	ARR	BIZ:-|KAS:ABS|NUM:P|MUG:M
IZE	ARR	BIZ:-|KAS:ABS|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:ABS|NUM:P|MUG:M|ENT:Pertsona
IZE	ARR	BIZ:-|KAS:ABS|NUM:P|MUG:M|MW:B
IZE	ARR	BIZ:-|KAS:ABS|NUM:P|MUG:M|POS:POSalde|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:P|MUG:M|POS:POSaurka|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:P|MUG:M|POS:POSesker|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:P|MUG:M|POS:POSgain|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:P|MUG:M|POS:POSkanpo|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:P|MUG:M|POS:POStruke|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M|ENT:???
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M|ENT:Pertsona
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M|ENT:Tokia
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M|MW:B
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M|POS:POSalde|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M|POS:POSantzekoa|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M|POS:POSarte|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M|POS:POSaurka|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M|POS:POSbitarte|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M|POS:POSesker|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M|POS:POSesku|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M|POS:POSgain|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M|POS:POSkanpo|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M|POS:POSlanda|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M|POS:POSmenpe|POS:+
IZE	ARR	BIZ:-|KAS:ABS|NUM:S|MUG:M|POS:POStruke|POS:+
IZE	ARR	BIZ:-|KAS:ABU|NUM:S|MUG:M
IZE	ARR	BIZ:-|KAS:ABZ|NUM:S|MUG:M
IZE	ARR	BIZ:-|KAS:ALA|MUG:MG
IZE	ARR	BIZ:-|KAS:ALA|NUM:P|MUG:M
IZE	ARR	BIZ:-|KAS:ALA|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:ALA|NUM:P|MUG:M|ENT:Tokia
IZE	ARR	BIZ:-|KAS:ALA|NUM:P|MUG:M|POS:POSaldera|POS:+
IZE	ARR	BIZ:-|KAS:ALA|NUM:P|MUG:M|POS:POSbatera|POS:+
IZE	ARR	BIZ:-|KAS:ALA|NUM:P|MUG:M|POS:POSbehera|POS:+
IZE	ARR	BIZ:-|KAS:ALA|NUM:P|MUG:M|POS:POSkanpora|POS:+
IZE	ARR	BIZ:-|KAS:ALA|NUM:S|MUG:M
IZE	ARR	BIZ:-|KAS:ALA|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:ALA|NUM:S|MUG:M|ENT:Tokia
IZE	ARR	BIZ:-|KAS:ALA|NUM:S|MUG:M|MW:B
IZE	ARR	BIZ:-|KAS:ALA|NUM:S|MUG:M|POS:POSantzera|POS:+
IZE	ARR	BIZ:-|KAS:ALA|NUM:S|MUG:M|POS:POSaurrera|POS:+
IZE	ARR	BIZ:-|KAS:ALA|NUM:S|MUG:M|POS:POSbatera|POS:+
IZE	ARR	BIZ:-|KAS:ALA|NUM:S|MUG:M|POS:POSbehera|POS:+
IZE	ARR	BIZ:-|KAS:ALA|NUM:S|MUG:M|POS:POSerdira|POS:+
IZE	ARR	BIZ:-|KAS:ALA|NUM:S|MUG:M|POS:POSkanpora|POS:+
IZE	ARR	BIZ:-|KAS:BNK|MUG:MG
IZE	ARR	BIZ:-|KAS:DAT|MUG:MG
IZE	ARR	BIZ:-|KAS:DAT|MUG:MG|ENT:Pertsona
IZE	ARR	BIZ:-|KAS:DAT|NUM:P|MUG:M
IZE	ARR	BIZ:-|KAS:DAT|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:DAT|NUM:S|MUG:M
IZE	ARR	BIZ:-|KAS:DAT|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:DAT|NUM:S|MUG:M|ENT:Pertsona
IZE	ARR	BIZ:-|KAS:DESK
IZE	ARR	BIZ:-|KAS:DESK|MW:B
IZE	ARR	BIZ:-|KAS:DES|NUM:P|MUG:M
IZE	ARR	BIZ:-|KAS:DES|NUM:S|MUG:M
IZE	ARR	BIZ:-|KAS:DES|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:EM|MUG:MG|POS:POSantzeko|POS:+
IZE	ARR	BIZ:-|KAS:EM|MUG:MG|POS:POSezean|POS:+
IZE	ARR	BIZ:-|KAS:EM|MUG:MG|POS:POSgabe|POS:+
IZE	ARR	BIZ:-|KAS:EM|MUG:MG|POS:POSgaineko|POS:+
IZE	ARR	BIZ:-|KAS:EM|MUG:MG|POS:POSgero|POS:+
IZE	ARR	BIZ:-|KAS:EM|MUG:MG|POS:POSondoren|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:P|MUG:M|POS:POSarabera|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:P|MUG:M|POS:POSbegira|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:P|MUG:M|POS:POSbezala|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:P|MUG:M|POS:POSburuz|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:P|MUG:M|POS:POSgaindi|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:P|MUG:M|POS:POShurrean|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:P|MUG:M|POS:POSkontra|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:P|MUG:M|POS:POSondoren|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:P|MUG:M|POS:POSordez|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:P|MUG:M|POS:POSurrun|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:P|MUG:M|POS:POSurruti|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:P|MUG:M|POS:POSzain|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSarabera|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSgeroztik|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSkontra|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSaitzina|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSarabera|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSat|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSaurrera|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSbarrena|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSbatera|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSbegira|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSbezala|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSbidez|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSbila|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSbitartean|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSburuz|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSgeroztik|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSgertu|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSgorago|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSgora|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POShurbil|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSkontra|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSondorengo|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSondoren|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSostean|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSzain|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSzai|POS:+
IZE	ARR	BIZ:-|KAS:EM|NUM:S|MUG:M|POS:POSzehar|POS:+
IZE	ARR	BIZ:-|KAS:ERG|MUG:MG
IZE	ARR	BIZ:-|KAS:ERG|MUG:MG|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:ERG|NUM:PH|MUG:M
IZE	ARR	BIZ:-|KAS:ERG|NUM:P|MUG:M
IZE	ARR	BIZ:-|KAS:ERG|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:ERG|NUM:P|MUG:M|ENT:Pertsona
IZE	ARR	BIZ:-|KAS:ERG|NUM:P|MUG:M|MW:B
IZE	ARR	BIZ:-|KAS:ERG|NUM:S|MUG:M
IZE	ARR	BIZ:-|KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:ERG|NUM:S|MUG:M|ENT:Pertsona
IZE	ARR	BIZ:-|KAS:ERG|NUM:S|MUG:M|MW:B
IZE	ARR	BIZ:-|KAS:ERG|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:GEL
IZE	ARR	BIZ:-|KAS:GEL|MUG:MG
IZE	ARR	BIZ:-|KAS:GEL|MUG:MG|POS:POSInguruko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|MUG:MG|POS:POSgabeko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|MUG:MG|POS:POSinguruko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:PH|MUG:M
IZE	ARR	BIZ:-|KAS:GEL|NUM:P|MUG:M
IZE	ARR	BIZ:-|KAS:GEL|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:GEL|NUM:P|MUG:M|ENT:Erakundea|POS:POSAldeko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:P|MUG:M|ENT:Pertsona|POS:POSgaineko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:P|MUG:M|MW:B
IZE	ARR	BIZ:-|KAS:GEL|NUM:P|MUG:M|POS:POSaldeko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:P|MUG:M|POS:POSantzeko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:P|MUG:M|POS:POSaraberako|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:P|MUG:M|POS:POSarteko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:P|MUG:M|POS:POSaurkako|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:P|MUG:M|POS:POSbitarteko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:P|MUG:M|POS:POSburuzko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:P|MUG:M|POS:POSgaineko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:P|MUG:M|POS:POSinguruko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:P|MUG:M|POS:POSkontrako|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSAldeko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSAurkako|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSarteko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSburuzko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|ENT:Pertsona
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|ENT:Pertsona|POS:POSburuzko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|ENT:Tokia
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|MW:B
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|POS:POSaldeko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|POS:POSarteko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|POS:POSatzeko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|POS:POSaurkako|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|POS:POSburuzko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|POS:POSgaindiko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|POS:POSgaineko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|POS:POSgorako|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|POS:POSinguruko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|POS:POSkanpoko|POS:+
IZE	ARR	BIZ:-|KAS:GEL|NUM:S|MUG:M|POS:POSkontrako|POS:+
IZE	ARR	BIZ:-|KAS:GEL|POS:POSaurreko|POS:+
IZE	ARR	BIZ:-|KAS:GEN|MUG:MG
IZE	ARR	BIZ:-|KAS:GEN|NUM:PH|MUG:M
IZE	ARR	BIZ:-|KAS:GEN|NUM:P|MUG:M
IZE	ARR	BIZ:-|KAS:GEN|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:GEN|NUM:P|MUG:M|ENT:Pertsona
IZE	ARR	BIZ:-|KAS:GEN|NUM:P|MUG:M|MW:B
IZE	ARR	BIZ:-|KAS:GEN|NUM:P|MUG:M|MW:B|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:GEN|NUM:P|MUG:M|MW:B|KAS:ABS|POS:POSalde|POS:+
IZE	ARR	BIZ:-|KAS:GEN|NUM:P|MUG:M|MW:B|KAS:GEL|POS:POSaldeko|POS:+
IZE	ARR	BIZ:-|KAS:GEN|NUM:S|MUG:M
IZE	ARR	BIZ:-|KAS:GEN|NUM:S|MUG:M|ENT:???
IZE	ARR	BIZ:-|KAS:GEN|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:GEN|NUM:S|MUG:M|ENT:Pertsona
IZE	ARR	BIZ:-|KAS:GEN|NUM:S|MUG:M|ENT:Tokia
IZE	ARR	BIZ:-|KAS:GEN|NUM:S|MUG:M|MW:B|KAS:INE|POS:POSbaitan|POS:+
IZE	ARR	BIZ:-|KAS:GEN|NUM:S|MUG:M|POS:POSgorakoen|POS:+
IZE	ARR	BIZ:-|KAS:INE|MUG:MG
IZE	ARR	BIZ:-|KAS:INE|MUG:MG|POS:POSartean|POS:+
IZE	ARR	BIZ:-|KAS:INE|MUG:MG|POS:POSaurrean|POS:+
IZE	ARR	BIZ:-|KAS:INE|MUG:MG|POS:POSazpian|POS:+
IZE	ARR	BIZ:-|KAS:INE|MUG:MG|POS:POSburuan|POS:+
IZE	ARR	BIZ:-|KAS:INE|MUG:MG|POS:POSinguruan|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:PH|MUG:M
IZE	ARR	BIZ:-|KAS:INE|NUM:P|MUG:M
IZE	ARR	BIZ:-|KAS:INE|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:INE|NUM:P|MUG:M|ENT:Tokia
IZE	ARR	BIZ:-|KAS:INE|NUM:P|MUG:M|MW:B
IZE	ARR	BIZ:-|KAS:INE|NUM:P|MUG:M|POS:POSaitzinean|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:P|MUG:M|POS:POSartean|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:P|MUG:M|POS:POSatzean|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:P|MUG:M|POS:POSaurrean|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:P|MUG:M|POS:POSazpian|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:P|MUG:M|POS:POSbarruan|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:P|MUG:M|POS:POSbitartean|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:P|MUG:M|POS:POSgainean|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:P|MUG:M|POS:POSinguruan|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:P|MUG:M|POS:POSondoan|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|ENT:Erakundea|POS:POSparean|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|ENT:Pertsona
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|ENT:Tokia
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|MW:B
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSaitzinean|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSalboan|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSaldean|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSatzean|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSaurrean|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSazpian|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSbaitan|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSbarnean|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSbarrenean|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSbarruan|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSbestaldean|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSbitartean|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSerdian|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSeskuetan|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSgainean|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSinguruan|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSingurua|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSmoduan|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSondoan|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSostean|POS:+
IZE	ARR	BIZ:-|KAS:INE|NUM:S|MUG:M|POS:POSparean|POS:+
IZE	ARR	BIZ:-|KAS:INS|MUG:MG
IZE	ARR	BIZ:-|KAS:INS|MUG:MG|MW:B
IZE	ARR	BIZ:-|KAS:INS|NUM:P|MUG:M
IZE	ARR	BIZ:-|KAS:INS|NUM:P|MUG:M|POS:POSbidez|POS:+
IZE	ARR	BIZ:-|KAS:INS|NUM:P|MUG:M|POS:POSbitartez|POS:+
IZE	ARR	BIZ:-|KAS:INS|NUM:S|MUG:M
IZE	ARR	BIZ:-|KAS:INS|NUM:S|MUG:M|POS:POSbidez|POS:+
IZE	ARR	BIZ:-|KAS:INS|NUM:S|MUG:M|POS:POSbitartez|POS:+
IZE	ARR	BIZ:-|KAS:INS|POS:POSaldeaz|POS:+
IZE	ARR	BIZ:-|KAS:MOT
IZE	ARR	BIZ:-|KAS:MOT|NUM:P|MUG:M
IZE	ARR	BIZ:-|KAS:MOT|NUM:S|MUG:M
IZE	ARR	BIZ:-|KAS:PAR|MUG:MG
IZE	ARR	BIZ:-|KAS:PRO|MUG:MG
IZE	ARR	BIZ:-|KAS:PRO|MUG:MG|ENT:???
IZE	ARR	BIZ:-|KAS:SOZ|MUG:MG
IZE	ARR	BIZ:-|KAS:SOZ|NUM:P|MUG:M
IZE	ARR	BIZ:-|KAS:SOZ|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|KAS:SOZ|NUM:S|MUG:M
IZE	ARR	BIZ:-|KAS:SOZ|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|MTKAT:SNB
IZE	ARR	BIZ:-|MTKAT:SNB|KAS:ABS|NUM:S|MUG:M
IZE	ARR	BIZ:-|MW:B
IZE	ARR	BIZ:-|MW:B|ENT:Erakundea
IZE	ARR	BIZ:-|PLU:-
IZE	ARR	BIZ:-|PLU:-|KAS:ABS|NUM:P|MUG:M
IZE	ARR	BIZ:-|PLU:-|KAS:ABS|NUM:S|MUG:M
IZE	ARR	BIZ:-|PLU:-|KAS:INE|NUM:S|MUG:M
IZE	ARR	BIZ:-|PLU:-|KAS:INE|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	BIZ:-|POS:POSaitzineko|POS:+|KAS:GEL
IZE	ARR	BIZ:-|POS:POSaldean|POS:+|KAS:INE
IZE	ARR	BIZ:-|POS:POSaldeko|POS:+|KAS:GEL
IZE	ARR	BIZ:-|POS:POSaldera|POS:+|KAS:ALA
IZE	ARR	BIZ:-|POS:POSaldetik|POS:+|KAS:ABL
IZE	ARR	BIZ:-|POS:POSantzeko|POS:+|KAS:GEL
IZE	ARR	BIZ:-|POS:POSartean|POS:+|KAS:INE
IZE	ARR	BIZ:-|POS:POSarteko|POS:+|KAS:GEL
IZE	ARR	BIZ:-|POS:POSarte|POS:+|KAS:ABS
IZE	ARR	BIZ:-|POS:POSatzean|POS:+|KAS:INE
IZE	ARR	BIZ:-|POS:POSaurrean|POS:+|KAS:INE
IZE	ARR	BIZ:-|POS:POSaurreko|POS:+|KAS:GEL
IZE	ARR	BIZ:-|POS:POSaurrera|POS:+|KAS:ALA
IZE	ARR	BIZ:-|POS:POSaurretik|POS:+|KAS:ABL
IZE	ARR	BIZ:-|POS:POSazpitik|POS:+|KAS:ABL
IZE	ARR	BIZ:-|POS:POSbarik|POS:+|KAS:EM
IZE	ARR	BIZ:-|POS:POSbarnean|POS:+|KAS:INE
IZE	ARR	BIZ:-|POS:POSbarnera|POS:+|KAS:ALA
IZE	ARR	BIZ:-|POS:POSbarruan|POS:+|KAS:INE
IZE	ARR	BIZ:-|POS:POSbarruetatik|POS:+|KAS:ABL
IZE	ARR	BIZ:-|POS:POSbarruko|POS:+|KAS:GEL
IZE	ARR	BIZ:-|POS:POSbarrura|POS:+|KAS:ALA
IZE	ARR	BIZ:-|POS:POSbarrutik|POS:+|KAS:ABL
IZE	ARR	BIZ:-|POS:POSbarru|POS:+|KAS:ABS
IZE	ARR	BIZ:-|POS:POSbezalako|POS:+|KAS:EM
IZE	ARR	BIZ:-|POS:POSbezala|POS:+|KAS:EM
IZE	ARR	BIZ:-|POS:POSbidez|POS:+|KAS:EM
IZE	ARR	BIZ:-|POS:POSbidez|POS:+|KAS:INS
IZE	ARR	BIZ:-|POS:POSbila|POS:+|KAS:EM
IZE	ARR	BIZ:-|POS:POSbitartean|POS:+|KAS:INE
IZE	ARR	BIZ:-|POS:POSbitarterako|POS:+|KAS:ABS
IZE	ARR	BIZ:-|POS:POSerdian|POS:+|KAS:INE
IZE	ARR	BIZ:-|POS:POSerdiko|POS:+|KAS:GEL
IZE	ARR	BIZ:-|POS:POSerdira|POS:+|KAS:ALA
IZE	ARR	BIZ:-|POS:POSerditan|POS:+|KAS:INE
IZE	ARR	BIZ:-|POS:POSeske|POS:+|KAS:EM
IZE	ARR	BIZ:-|POS:POSgabeko|POS:+|KAS:GEL
IZE	ARR	BIZ:-|POS:POSgabe|POS:+|KAS:EM
IZE	ARR	BIZ:-|POS:POSgainean|POS:+|KAS:INE
IZE	ARR	BIZ:-|POS:POSgaineko|POS:+|KAS:GEL
IZE	ARR	BIZ:-|POS:POSgainera|POS:+|KAS:ALA
IZE	ARR	BIZ:-|POS:POSgisa|POS:+|KAS:ABS
IZE	ARR	BIZ:-|POS:POSgora|POS:+|KAS:EM
IZE	ARR	BIZ:-|POS:POSinguruan|POS:+|KAS:INE
IZE	ARR	BIZ:-|POS:POSinguruetara|POS:+|KAS:ALA
IZE	ARR	BIZ:-|POS:POSinguruko|POS:+|KAS:GEL
IZE	ARR	BIZ:-|POS:POSingurura|POS:+|KAS:ALA
IZE	ARR	BIZ:-|POS:POSinguru|POS:+|KAS:ABS
IZE	ARR	BIZ:-|POS:POSondoan|POS:+|KAS:EM
IZE	ARR	BIZ:-|POS:POSondoan|POS:+|KAS:INE
IZE	ARR	BIZ:-|POS:POSondoren|POS:+|KAS:EM
IZE	ARR	BIZ:-|POS:POSondotik|POS:+|KAS:ABL
IZE	ARR	BIZ:-|POS:POSostean|POS:+|KAS:EM
IZE	ARR	BIZ:-|POS:POSostean|POS:+|KAS:INE
IZE	ARR	BIZ:-|POS:POSpartean|POS:+|KAS:INE
IZE	ARR	BIZ:-|ZENB:-|NEUR:-|PLU:-
IZE	ARR	BIZ:-|ZENB:-|NEUR:-|PLU:-|KAS:ABS|NUM:P|MUG:M
IZE	ARR	BIZ:-|ZENB:-|NEUR:-|PLU:-|KAS:ABS|NUM:S|MUG:M
IZE	ARR	BIZ:-|ZENB:-|NEUR:-|PLU:-|KAS:ALA|NUM:S|MUG:M
IZE	ARR	BIZ:-|ZENB:-|NEUR:-|PLU:-|KAS:DAT|NUM:P|MUG:M
IZE	ARR	BIZ:-|ZENB:-|NEUR:-|PLU:-|KAS:ERG|NUM:P|MUG:M
IZE	ARR	BIZ:-|ZENB:-|NEUR:-|PLU:-|KAS:ERG|NUM:S|MUG:M
IZE	ARR	BIZ:-|ZENB:-|NEUR:-|PLU:-|KAS:GEL|NUM:P|MUG:M|POS:POSburuzko|POS:+
IZE	ARR	BIZ:-|ZENB:-|NEUR:-|PLU:-|KAS:GEN|NUM:P|MUG:M
IZE	ARR	BIZ:-|ZENB:-|NEUR:-|PLU:-|KAS:INE|NUM:P|MUG:M
IZE	ARR	BIZ:-|ZENB:-|NEUR:-|PLU:-|KAS:INE|NUM:S|MUG:M
IZE	ARR	BIZ:-|ZENB:-|NEUR:-|PLU:-|KAS:SOZ|NUM:P|MUG:M
IZE	ARR	ENT:Erakundea
IZE	ARR	ENT:Pertsona
IZE	ARR	ENT:Tokia
IZE	ARR	IZAUR:-
IZE	ARR	IZAUR:-|KAS:ABS|NUM:P|MUG:M|MW:B
IZE	ARR	IZAUR:-|KAS:ABS|NUM:S|MUG:M
IZE	ARR	IZAUR:-|KAS:ABS|NUM:S|MUG:M|MW:B
IZE	ARR	IZAUR:-|KAS:ERG|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	IZAUR:-|KAS:ERG|NUM:S|MUG:M|MW:B
IZE	ARR	IZAUR:-|KAS:GEL|NUM:S|MUG:M|MW:B
IZE	ARR	IZAUR:-|KAS:GEL|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	ARR	IZAUR:-|KAS:GEN|NUM:P|MUG:M|MW:B
IZE	ARR	IZAUR:-|KAS:GEN|NUM:S|MUG:M|ENT:Pertsona
IZE	ARR	IZAUR:-|KAS:GEN|NUM:S|MUG:M|MW:B
IZE	ARR	IZAUR:-|KAS:GEN|NUM:S|MUG:M|MW:B|ENT:Pertsona
IZE	ARR	IZAUR:-|KAS:INE|NUM:P|MUG:M|MW:B
IZE	ARR	IZAUR:-|KAS:INE|NUM:S|MUG:M|MW:B
IZE	ARR	IZAUR:-|KAS:PAR|MUG:MG|MW:B
IZE	ARR	IZAUR:-|KAS:PRO|MUG:MG|MW:B
IZE	ARR	IZAUR:-|MW:B
IZE	ARR	KAS:ABL|MUG:MG
IZE	ARR	KAS:ABL|MUG:MG|POS:POSgainetik|POS:+
IZE	ARR	KAS:ABL|NUM:P|MUG:M
IZE	ARR	KAS:ABL|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	KAS:ABL|NUM:P|MUG:M|POS:POSatzetik|POS:+
IZE	ARR	KAS:ABL|NUM:P|MUG:M|POS:POSaurretik|POS:+
IZE	ARR	KAS:ABL|NUM:P|MUG:M|POS:POSeskutik|POS:+
IZE	ARR	KAS:ABL|NUM:P|MUG:M|POS:POSgainetik|POS:+
IZE	ARR	KAS:ABL|NUM:S|MUG:M
IZE	ARR	KAS:ABL|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	KAS:ABL|NUM:S|MUG:M|ENT:Pertsona
IZE	ARR	KAS:ABL|NUM:S|MUG:M|ENT:Tokia
IZE	ARR	KAS:ABL|NUM:S|MUG:M|POS:POSaurretik|POS:+
IZE	ARR	KAS:ABL|NUM:S|MUG:M|POS:POSazpitik|POS:+
IZE	ARR	KAS:ABL|NUM:S|MUG:M|POS:POSeskutik|POS:+
IZE	ARR	KAS:ABL|NUM:S|MUG:M|POS:POSgainetik|POS:+
IZE	ARR	KAS:ABL|NUM:S|MUG:M|POS:POSondotik|POS:+
IZE	ARR	KAS:ABS
IZE	ARR	KAS:ABS|MUG:MG
IZE	ARR	KAS:ABS|MUG:MG|ENT:Erakundea
IZE	ARR	KAS:ABS|MUG:MG|ENT:Pertsona
IZE	ARR	KAS:ABS|MUG:MG|MW:B
IZE	ARR	KAS:ABS|MUG:MG|POS:POSaurka|POS:+
IZE	ARR	KAS:ABS|MUG:MG|POS:POSkanpo|POS:+
IZE	ARR	KAS:ABS|MUG:MG|POS:POStruke|POS:+
IZE	ARR	KAS:ABS|NUM:PH|MUG:M
IZE	ARR	KAS:ABS|NUM:P|MUG:M
IZE	ARR	KAS:ABS|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	KAS:ABS|NUM:P|MUG:M|MW:B
IZE	ARR	KAS:ABS|NUM:P|MUG:M|POS:POSalde|POS:+
IZE	ARR	KAS:ABS|NUM:P|MUG:M|POS:POSaurka|POS:+
IZE	ARR	KAS:ABS|NUM:P|MUG:M|POS:POSbitarteko|POS:+
IZE	ARR	KAS:ABS|NUM:P|MUG:M|POS:POSesker|POS:+
IZE	ARR	KAS:ABS|NUM:P|MUG:M|POS:POSgain|POS:+
IZE	ARR	KAS:ABS|NUM:S|MUG:M
IZE	ARR	KAS:ABS|NUM:S|MUG:M|ENT:???
IZE	ARR	KAS:ABS|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	KAS:ABS|NUM:S|MUG:M|ENT:Erakundea|POS:POSaurka|POS:+
IZE	ARR	KAS:ABS|NUM:S|MUG:M|ENT:Pertsona
IZE	ARR	KAS:ABS|NUM:S|MUG:M|ENT:Tokia
IZE	ARR	KAS:ABS|NUM:S|MUG:M|MW:B
IZE	ARR	KAS:ABS|NUM:S|MUG:M|POS:POSalde|POS:+
IZE	ARR	KAS:ABS|NUM:S|MUG:M|POS:POSarte|POS:+
IZE	ARR	KAS:ABS|NUM:S|MUG:M|POS:POSaurka|POS:+
IZE	ARR	KAS:ABS|NUM:S|MUG:M|POS:POSesker|POS:+
IZE	ARR	KAS:ABS|NUM:S|MUG:M|POS:POSgain|POS:+
IZE	ARR	KAS:ABS|NUM:S|MUG:M|POS:POSkanpo|POS:+
IZE	ARR	KAS:ABS|NUM:S|MUG:M|POS:POSlanda|POS:+
IZE	ARR	KAS:ABS|NUM:S|MUG:M|POS:POSmenpe|POS:+
IZE	ARR	KAS:ABU|NUM:P|MUG:M
IZE	ARR	KAS:ABU|NUM:S|MUG:M
IZE	ARR	KAS:ABZ|NUM:S|MUG:M
IZE	ARR	KAS:ALA|MUG:MG
IZE	ARR	KAS:ALA|MUG:MG|POS:POSingurura|POS:+
IZE	ARR	KAS:ALA|NUM:P|MUG:M
IZE	ARR	KAS:ALA|NUM:P|MUG:M|MW:B
IZE	ARR	KAS:ALA|NUM:P|MUG:M|POS:POSaurrera|POS:+
IZE	ARR	KAS:ALA|NUM:P|MUG:M|POS:POSbatera|POS:+
IZE	ARR	KAS:ALA|NUM:P|MUG:M|POS:POSlandara|POS:+
IZE	ARR	KAS:ALA|NUM:S|MUG:M
IZE	ARR	KAS:ALA|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	KAS:ALA|NUM:S|MUG:M|ENT:Tokia
IZE	ARR	KAS:ALA|NUM:S|MUG:M|POS:POSaldera|POS:+
IZE	ARR	KAS:ALA|NUM:S|MUG:M|POS:POSbatera|POS:+
IZE	ARR	KAS:ALA|NUM:S|MUG:M|POS:POSbehera|POS:+
IZE	ARR	KAS:ALA|NUM:S|MUG:M|POS:POSgainera|POS:+
IZE	ARR	KAS:ALA|NUM:S|MUG:M|POS:POSlandara|POS:+
IZE	ARR	KAS:BNK|MUG:MG
IZE	ARR	KAS:DAT|MUG:MG
IZE	ARR	KAS:DAT|MUG:MG|ENT:Pertsona
IZE	ARR	KAS:DAT|NUM:PH|MUG:M
IZE	ARR	KAS:DAT|NUM:P|MUG:M
IZE	ARR	KAS:DAT|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	KAS:DAT|NUM:S|MUG:M
IZE	ARR	KAS:DAT|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	KAS:DAT|NUM:S|MUG:M|ENT:Pertsona
IZE	ARR	KAS:DAT|NUM:S|MUG:M|ENT:Tokia
IZE	ARR	KAS:DESK
IZE	ARR	KAS:DES|MUG:MG
IZE	ARR	KAS:DES|NUM:PH|MUG:M
IZE	ARR	KAS:DES|NUM:P|MUG:M
IZE	ARR	KAS:DES|NUM:S|MUG:M
IZE	ARR	KAS:EM|MUG:MG|POS:POSbezala|POS:+
IZE	ARR	KAS:EM|MUG:MG|POS:POSezean|POS:+
IZE	ARR	KAS:EM|MUG:MG|POS:POSgabe|POS:+
IZE	ARR	KAS:EM|MUG:MG|POS:POSgeroztik|POS:+
IZE	ARR	KAS:EM|MUG:MG|POS:POSondoren|POS:+
IZE	ARR	KAS:EM|NUM:P|MUG:M|POS:POSaldetik|POS:+
IZE	ARR	KAS:EM|NUM:P|MUG:M|POS:POSarabera|POS:+
IZE	ARR	KAS:EM|NUM:P|MUG:M|POS:POSat|POS:+
IZE	ARR	KAS:EM|NUM:P|MUG:M|POS:POSbegira|POS:+
IZE	ARR	KAS:EM|NUM:P|MUG:M|POS:POSbezalako|POS:+
IZE	ARR	KAS:EM|NUM:P|MUG:M|POS:POSbezala|POS:+
IZE	ARR	KAS:EM|NUM:P|MUG:M|POS:POSburuz|POS:+
IZE	ARR	KAS:EM|NUM:P|MUG:M|POS:POSgora|POS:+
IZE	ARR	KAS:EM|NUM:P|MUG:M|POS:POSkontra|POS:+
IZE	ARR	KAS:EM|NUM:P|MUG:M|POS:POSondoren|POS:+
IZE	ARR	KAS:EM|NUM:P|MUG:M|POS:POSzehar|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSarabera|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSaurrera|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|POS:POSarabera|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|POS:POSat|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|POS:POSbegira|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|POS:POSbezalako|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|POS:POSbezala|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|POS:POSbidez|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|POS:POSbila|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|POS:POSburuz|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|POS:POSgeroztik|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|POS:POSgertu|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|POS:POSgora|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|POS:POShurbil|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|POS:POSkontra|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|POS:POSondoko|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|POS:POSondoren|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|POS:POSzain|POS:+
IZE	ARR	KAS:EM|NUM:S|MUG:M|POS:POSzehar|POS:+
IZE	ARR	KAS:ERG|MUG:MG
IZE	ARR	KAS:ERG|MUG:MG|ENT:Erakundea
IZE	ARR	KAS:ERG|MUG:MG|ENT:Pertsona
IZE	ARR	KAS:ERG|NUM:PH|MUG:M
IZE	ARR	KAS:ERG|NUM:P|MUG:M
IZE	ARR	KAS:ERG|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	KAS:ERG|NUM:P|MUG:M|ENT:Pertsona
IZE	ARR	KAS:ERG|NUM:P|MUG:M|MW:B
IZE	ARR	KAS:ERG|NUM:S|MUG:M
IZE	ARR	KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	KAS:ERG|NUM:S|MUG:M|ENT:Pertsona
IZE	ARR	KAS:GEL
IZE	ARR	KAS:GEL|MUG:MG
IZE	ARR	KAS:GEL|MUG:MG|ENT:Erakundea
IZE	ARR	KAS:GEL|MUG:MG|POS:POSaurkako|POS:+
IZE	ARR	KAS:GEL|MUG:MG|POS:POSgabeko|POS:+
IZE	ARR	KAS:GEL|MUG:MG|POS:POSkanpoko|POS:+
IZE	ARR	KAS:GEL|MUG:MG|POS:POSkontrako|POS:+
IZE	ARR	KAS:GEL|NUM:PH|MUG:M
IZE	ARR	KAS:GEL|NUM:P|MUG:M
IZE	ARR	KAS:GEL|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	KAS:GEL|NUM:P|MUG:M|POS:POSaldeko|POS:+
IZE	ARR	KAS:GEL|NUM:P|MUG:M|POS:POSarteko|POS:+
IZE	ARR	KAS:GEL|NUM:P|MUG:M|POS:POSaurkako|POS:+
IZE	ARR	KAS:GEL|NUM:P|MUG:M|POS:POSburuzko|POS:+
IZE	ARR	KAS:GEL|NUM:P|MUG:M|POS:POSgaineko|POS:+
IZE	ARR	KAS:GEL|NUM:P|MUG:M|POS:POSinguruko|POS:+
IZE	ARR	KAS:GEL|NUM:P|MUG:M|POS:POSkanpoko|POS:+
IZE	ARR	KAS:GEL|NUM:P|MUG:M|POS:POSkontrako|POS:+
IZE	ARR	KAS:GEL|NUM:S|MUG:M
IZE	ARR	KAS:GEL|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSKontrako|POS:+
IZE	ARR	KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSarteko|POS:+
IZE	ARR	KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSaurkako|POS:+
IZE	ARR	KAS:GEL|NUM:S|MUG:M|ENT:Pertsona
IZE	ARR	KAS:GEL|NUM:S|MUG:M|ENT:Tokia
IZE	ARR	KAS:GEL|NUM:S|MUG:M|POS:POSKontrako|POS:+
IZE	ARR	KAS:GEL|NUM:S|MUG:M|POS:POSaldeko|POS:+
IZE	ARR	KAS:GEL|NUM:S|MUG:M|POS:POSaurkako|POS:+
IZE	ARR	KAS:GEL|NUM:S|MUG:M|POS:POSaurreko|POS:+
IZE	ARR	KAS:GEL|NUM:S|MUG:M|POS:POSburuzko|POS:+
IZE	ARR	KAS:GEL|NUM:S|MUG:M|POS:POSgorako|POS:+
IZE	ARR	KAS:GEL|NUM:S|MUG:M|POS:POSinguruko|POS:+
IZE	ARR	KAS:GEL|NUM:S|MUG:M|POS:POSkontrako|POS:+
IZE	ARR	KAS:GEN|MUG:MG
IZE	ARR	KAS:GEN|NUM:PH|MUG:M
IZE	ARR	KAS:GEN|NUM:P|MUG:M
IZE	ARR	KAS:GEN|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	KAS:GEN|NUM:P|MUG:M|MW:B
IZE	ARR	KAS:GEN|NUM:S|MUG:M
IZE	ARR	KAS:GEN|NUM:S|MUG:M|ENT:???
IZE	ARR	KAS:GEN|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	KAS:GEN|NUM:S|MUG:M|ENT:Pertsona
IZE	ARR	KAS:GEN|NUM:S|MUG:M|ENT:Tokia
IZE	ARR	KAS:INE
IZE	ARR	KAS:INE|MUG:MG
IZE	ARR	KAS:INE|MUG:MG|POS:POSaurrean|POS:+
IZE	ARR	KAS:INE|MUG:MG|POS:POSbarnean|POS:+
IZE	ARR	KAS:INE|NUM:PH|MUG:M
IZE	ARR	KAS:INE|NUM:P|MUG:M
IZE	ARR	KAS:INE|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	KAS:INE|NUM:P|MUG:M|ENT:Tokia
IZE	ARR	KAS:INE|NUM:P|MUG:M|POS:POSartean|POS:+
IZE	ARR	KAS:INE|NUM:P|MUG:M|POS:POSaurrean|POS:+
IZE	ARR	KAS:INE|NUM:P|MUG:M|POS:POSbarruan|POS:+
IZE	ARR	KAS:INE|NUM:P|MUG:M|POS:POSeskuetan|POS:+
IZE	ARR	KAS:INE|NUM:P|MUG:M|POS:POSgainean|POS:+
IZE	ARR	KAS:INE|NUM:P|MUG:M|POS:POSinguruan|POS:+
IZE	ARR	KAS:INE|NUM:P|MUG:M|POS:POSondoan|POS:+
IZE	ARR	KAS:INE|NUM:P|MUG:M|POS:POSostean|POS:+
IZE	ARR	KAS:INE|NUM:S|MUG:M
IZE	ARR	KAS:INE|NUM:S|MUG:M|ENT:???
IZE	ARR	KAS:INE|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	KAS:INE|NUM:S|MUG:M|ENT:Pertsona
IZE	ARR	KAS:INE|NUM:S|MUG:M|ENT:Tokia
IZE	ARR	KAS:INE|NUM:S|MUG:M|MW:B
IZE	ARR	KAS:INE|NUM:S|MUG:M|POS:POSaitzinean|POS:+
IZE	ARR	KAS:INE|NUM:S|MUG:M|POS:POSaldean|POS:+
IZE	ARR	KAS:INE|NUM:S|MUG:M|POS:POSatzean|POS:+
IZE	ARR	KAS:INE|NUM:S|MUG:M|POS:POSaurrean|POS:+
IZE	ARR	KAS:INE|NUM:S|MUG:M|POS:POSazpian|POS:+
IZE	ARR	KAS:INE|NUM:S|MUG:M|POS:POSbaitan|POS:+
IZE	ARR	KAS:INE|NUM:S|MUG:M|POS:POSbarruan|POS:+
IZE	ARR	KAS:INE|NUM:S|MUG:M|POS:POSbitartean|POS:+
IZE	ARR	KAS:INE|NUM:S|MUG:M|POS:POSgainean|POS:+
IZE	ARR	KAS:INE|NUM:S|MUG:M|POS:POSinguruan|POS:+
IZE	ARR	KAS:INE|NUM:S|MUG:M|POS:POSlekuan|POS:+
IZE	ARR	KAS:INE|NUM:S|MUG:M|POS:POSostean|POS:+
IZE	ARR	KAS:INS|MUG:MG
IZE	ARR	KAS:INS|MUG:MG|ENT:Erakundea
IZE	ARR	KAS:INS|MUG:MG|POS:POSbidez|POS:+
IZE	ARR	KAS:INS|NUM:P|MUG:M
IZE	ARR	KAS:INS|NUM:P|MUG:M|POS:POSbidez|POS:+
IZE	ARR	KAS:INS|NUM:S|MUG:M
IZE	ARR	KAS:INS|NUM:S|MUG:M|POS:POSbidez|POS:+
IZE	ARR	KAS:INS|NUM:S|MUG:M|POS:POSbitartez|POS:+
IZE	ARR	KAS:MOT
IZE	ARR	KAS:MOT|NUM:P|MUG:M
IZE	ARR	KAS:MOT|NUM:S|MUG:M
IZE	ARR	KAS:PAR|MUG:MG
IZE	ARR	KAS:PRO|MUG:MG
IZE	ARR	KAS:SOZ|MUG:MG
IZE	ARR	KAS:SOZ|NUM:P|MUG:M
IZE	ARR	KAS:SOZ|NUM:S|MUG:M
IZE	ARR	KAS:SOZ|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	MAI:KONP|BIZ:-|KAS:ABS|MUG:MG
IZE	ARR	MAI:KONP|BIZ:-|KAS:ABS|NUM:S|MUG:M
IZE	ARR	MAI:KONP|BIZ:-|KAS:ALA|NUM:S|MUG:M
IZE	ARR	MAI:KONP|KAS:ABS|MUG:MG
IZE	ARR	MAI:KONP|KAS:ABS|NUM:S|MUG:M
IZE	ARR	MAI:KONP|KAS:ALA|NUM:S|MUG:M
IZE	ARR	MAI:KONP|KAS:INE|MUG:MG
IZE	ARR	MAI:KONP|KAS:INE|NUM:S|MUG:M
IZE	ARR	MTKAT:LAB|KAS:INE|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	MTKAT:SNB
IZE	ARR	MTKAT:SNB|KAS:ABS|NUM:P|MUG:M
IZE	ARR	MTKAT:SNB|KAS:ABS|NUM:S|MUG:M
IZE	ARR	MTKAT:SNB|KAS:GEL|NUM:S|MUG:M
IZE	ARR	MTKAT:SNB|POS:POSingurura|POS:+|KAS:ALA
IZE	ARR	MW:B
IZE	ARR	MW:B|KAS:ABS|POS:POSgisa|POS:+
IZE	ARR	NMG:S|KAS:INE|NUM:S|MUG:M|MW:B
IZE	ARR	NUM:S|MUG:M
IZE	ARR	PLU:+|KAS:GEL|NUM:P|MUG:M
IZE	ARR	PLU:-
IZE	ARR	PLU:-|KAS:ABS|MUG:MG
IZE	ARR	PLU:-|KAS:ABS|NUM:P|MUG:M|ENT:Tokia
IZE	ARR	PLU:-|KAS:ABS|NUM:S|MUG:M
IZE	ARR	PLU:-|KAS:EM|NUM:S|MUG:M|POS:POSgora|POS:+
IZE	ARR	PLU:-|KAS:ERG|NUM:P|MUG:M|ENT:Erakundea
IZE	ARR	PLU:-|KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
IZE	ARR	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Tokia
IZE	ARR	PLU:-|KAS:INE|NUM:S|MUG:M
IZE	ARR	POS:POSaitzineko|POS:+|KAS:GEL
IZE	ARR	POS:POSaldean|POS:+|KAS:INE
IZE	ARR	POS:POSaldera|POS:+|KAS:ALA
IZE	ARR	POS:POSaldetik|POS:+|KAS:ABL
IZE	ARR	POS:POSantzeko|POS:+|KAS:EM
IZE	ARR	POS:POSartean|POS:+|KAS:INE
IZE	ARR	POS:POSarteko|POS:+|KAS:GEL
IZE	ARR	POS:POSarte|POS:+|KAS:ABS
IZE	ARR	POS:POSatzean|POS:+|KAS:INE
IZE	ARR	POS:POSaurrean|POS:+|KAS:INE
IZE	ARR	POS:POSaurreko|POS:+|KAS:GEL
IZE	ARR	POS:POSaurrera|POS:+|KAS:ALA
IZE	ARR	POS:POSazpian|POS:+|KAS:INE
IZE	ARR	POS:POSbarruan|POS:+|KAS:INE
IZE	ARR	POS:POSbarru|POS:+|KAS:ABS
IZE	ARR	POS:POSbezala|POS:+|KAS:EM
IZE	ARR	POS:POSbila|POS:+|KAS:EM
IZE	ARR	POS:POSeran|POS:+|KAS:INE
IZE	ARR	POS:POSerdian|POS:+|KAS:INE
IZE	ARR	POS:POSerdira|POS:+|KAS:ALA
IZE	ARR	POS:POSgabe|POS:+|KAS:EM
IZE	ARR	POS:POSgainean|POS:+|KAS:INE
IZE	ARR	POS:POSgisa|POS:+|KAS:ABS
IZE	ARR	POS:POSinguruan|POS:+|KAS:INE
IZE	ARR	POS:POSinguruetako|POS:+|KAS:GEL
IZE	ARR	POS:POSinguruetan|POS:+|KAS:INE
IZE	ARR	POS:POSingururako|POS:+|KAS:ABS
IZE	ARR	POS:POSinguru|POS:+|KAS:ABS
IZE	ARR	POS:POSostean|POS:+|KAS:INE
IZE	ARR	POS:POSosteko|POS:+|KAS:GEL
IZE	ARR	POS:POSpartean|POS:+|KAS:INE
IZE	ARR	_
IZE	DET_IZEELI	KAS:ABS|NUM:P|MUG:M
IZE	DET_IZEELI	KAS:ABS|NUM:S|MUG:M
IZE	DET_IZEELI	KAS:DAT|NUM:S|MUG:M
IZE	DET_IZEELI	KAS:ERG|NUM:S|MUG:M
IZE	DET_IZEELI	KAS:INE|NUM:S|MUG:M
IZE	DET_IZEELI	KAS:SOZ|NUM:S|MUG:M
IZE	IOR_IZEELI	PER:GU|KAS:ABS|NUM:S|MUG:M
IZE	IOR_IZEELI	PER:NI|KAS:ABS|NUM:P|MUG:M
IZE	IOR_IZEELI	PER:ZUEK|KAS:ABS|NUM:S|MUG:M
IZE	IZB	BIZ:+|ENT:Pertsona
IZE	IZB	BIZ:+|PLU:-|ENT:Pertsona
IZE	IZB	BIZ:+|PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	BIZ:+|PLU:-|KAS:ERG|NUM:S|MUG:M
IZE	IZB	BIZ:+|PLU:-|KAS:ERG|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	BIZ:+|PLU:-|KAS:GEN|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	BIZ:-|KAS:ABS|NUM:S|MUG:M|ENT:Tokia
IZE	IZB	BIZ:-|KAS:ERG|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	BIZ:-|PLU:-|KAS:ERG|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|KAS:ERG|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|KAS:GEN|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|ENT:Erakundea
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|ENT:Pertsona
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|KAS:ABL|NUM:S|MUG:M|ENT:Erakundea|POS:POSaldetik|POS:+
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|KAS:DAT|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|KAS:DES|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSaldetik|POS:+
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSkontra|POS:+
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|KAS:ERG|NUM:S|MUG:M
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|KAS:ERG|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|KAS:GEL|NUM:S|MUG:M
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|KAS:GEL|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|KAS:GEN|NUM:S|MUG:M
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|KAS:GEN|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|KAS:INE|NUM:S|MUG:M|ENT:Erakundea|POS:POSinguruan|POS:+
IZE	IZB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|KAS:SOZ|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	ENT:???
IZE	IZB	ENT:Erakundea
IZE	IZB	ENT:Pertsona
IZE	IZB	IZAUR:-|KAS:ALA|NUM:S|MUG:M|MW:B|ENT:Tokia|KAS:ABS|POS:POSarte|POS:+
IZE	IZB	IZAUR:-|KAS:INE|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	IZB	KAS:ABS|NUM:S|MUG:M
IZE	IZB	KAS:ABS|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	KAS:ABS|NUM:S|MUG:M|ENT:Tokia
IZE	IZB	KAS:ABS|NUM:S|MUG:M|MW:B|ENT:Pertsona
IZE	IZB	KAS:ABS|NUM:S|MUG:M|POS:POSarte|POS:+
IZE	IZB	KAS:DAT|NUM:S|MUG:M
IZE	IZB	KAS:DAT|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	KAS:DAT|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	KAS:EM|NUM:S|MUG:M|ENT:Pertsona|POS:POSarabera|POS:+
IZE	IZB	KAS:ERG|NUM:S|MUG:M
IZE	IZB	KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	KAS:ERG|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	KAS:GEL|NUM:S|MUG:M|POS:POSaldeko|POS:+
IZE	IZB	KAS:GEN|NUM:S|MUG:M
IZE	IZB	KAS:GEN|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	KAS:GEN|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	KAS:GEN|NUM:S|MUG:M|ENT:Tokia
IZE	IZB	KAS:GEN|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	IZB	KAS:SOZ|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	MTKAT:LAB
IZE	IZB	MTKAT:SIG
IZE	IZB	MTKAT:SIG|ENT:???
IZE	IZB	MTKAT:SIG|ENT:Erakundea
IZE	IZB	MTKAT:SIG|ENT:Pertsona
IZE	IZB	MTKAT:SIG|ENT:Tokia
IZE	IZB	MTKAT:SIG|KAS:ABL|NUM:S|MUG:M
IZE	IZB	MTKAT:SIG|KAS:ABL|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	MTKAT:SIG|KAS:ABS|MUG:MG|ENT:Erakundea
IZE	IZB	MTKAT:SIG|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	MTKAT:SIG|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea|POS:POSalde|POS:+
IZE	IZB	MTKAT:SIG|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea|POS:POSaurka|POS:+
IZE	IZB	MTKAT:SIG|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea|POS:POSesku|POS:+
IZE	IZB	MTKAT:SIG|KAS:ABS|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	MTKAT:SIG|KAS:ABS|NUM:S|MUG:M|ENT:Tokia
IZE	IZB	MTKAT:SIG|KAS:ALA|NUM:S|MUG:M|ENT:Erakundea|POS:POSbatera|POS:+
IZE	IZB	MTKAT:SIG|KAS:ALA|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	MTKAT:SIG|KAS:BNK|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	MTKAT:SIG|KAS:DAT|NUM:S|MUG:M
IZE	IZB	MTKAT:SIG|KAS:DAT|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	MTKAT:SIG|KAS:DAT|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	MTKAT:SIG|KAS:DES|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	MTKAT:SIG|KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSarabera|POS:+
IZE	IZB	MTKAT:SIG|KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSbezalako|POS:+
IZE	IZB	MTKAT:SIG|KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSkontra|POS:+
IZE	IZB	MTKAT:SIG|KAS:ERG|NUM:S|MUG:M
IZE	IZB	MTKAT:SIG|KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	MTKAT:SIG|KAS:ERG|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	MTKAT:SIG|KAS:GEL|NUM:S|MUG:M
IZE	IZB	MTKAT:SIG|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	MTKAT:SIG|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSaldeko|POS:+
IZE	IZB	MTKAT:SIG|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSarteko|POS:+
IZE	IZB	MTKAT:SIG|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSaurkako|POS:+
IZE	IZB	MTKAT:SIG|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSkontrako|POS:+
IZE	IZB	MTKAT:SIG|KAS:GEL|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	MTKAT:SIG|KAS:GEN|NUM:S|MUG:M
IZE	IZB	MTKAT:SIG|KAS:GEN|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	MTKAT:SIG|KAS:GEN|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	MTKAT:SIG|KAS:INE|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	MTKAT:SIG|KAS:INE|NUM:S|MUG:M|ENT:Erakundea|POS:POSatzean|POS:+
IZE	IZB	MTKAT:SIG|KAS:INE|NUM:S|MUG:M|ENT:Erakundea|POS:POSbaitan|POS:+
IZE	IZB	MTKAT:SIG|KAS:INE|NUM:S|MUG:M|ENT:Erakundea|POS:POSbarruan|POS:+
IZE	IZB	MTKAT:SIG|KAS:INE|NUM:S|MUG:M|ENT:Erakundea|POS:POSinguruan|POS:+
IZE	IZB	MTKAT:SIG|KAS:INE|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	MTKAT:SIG|KAS:INE|NUM:S|MUG:M|ENT:Tokia
IZE	IZB	MTKAT:SIG|KAS:PAR|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	MTKAT:SIG|KAS:SOZ|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	NEUR:-|PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	PLU:+|ENT:Tokia
IZE	IZB	PLU:+|KAS:ABL|NUM:P|MUG:M|ENT:Tokia
IZE	IZB	PLU:+|KAS:ABS|MUG:MG|ENT:Tokia
IZE	IZB	PLU:+|KAS:ABS|NUM:P|MUG:M|ENT:Pertsona|POS:POSbitarte|POS:+
IZE	IZB	PLU:+|KAS:ABS|NUM:P|MUG:M|ENT:Tokia
IZE	IZB	PLU:+|KAS:ALA|NUM:P|MUG:M|ENT:Tokia
IZE	IZB	PLU:+|KAS:EM|NUM:P|MUG:M|ENT:Tokia|POS:POSbezalako|POS:+
IZE	IZB	PLU:+|KAS:EM|NUM:P|MUG:M|ENT:Tokia|POS:POSbezala|POS:+
IZE	IZB	PLU:+|KAS:ERG|NUM:P|MUG:M|ENT:Erakundea
IZE	IZB	PLU:+|KAS:GEL|NUM:P|MUG:M
IZE	IZB	PLU:+|KAS:GEL|NUM:P|MUG:M|ENT:Erakundea
IZE	IZB	PLU:+|KAS:GEL|NUM:P|MUG:M|ENT:Pertsona
IZE	IZB	PLU:+|KAS:GEL|NUM:P|MUG:M|ENT:Tokia
IZE	IZB	PLU:+|KAS:GEL|NUM:P|MUG:M|ENT:Tokia|POS:POSarteko|POS:+
IZE	IZB	PLU:+|KAS:GEN|NUM:P|MUG:M|ENT:Tokia
IZE	IZB	PLU:+|KAS:INE|NUM:P|MUG:M|ENT:Tokia
IZE	IZB	PLU:-
IZE	IZB	PLU:-|ENT:???
IZE	IZB	PLU:-|ENT:Erakundea
IZE	IZB	PLU:-|ENT:Pertsona
IZE	IZB	PLU:-|ENT:Tokia
IZE	IZB	PLU:-|KAS:ABL|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	PLU:-|KAS:ABL|NUM:S|MUG:M|ENT:Pertsona|POS:POSaitzinetik|POS:+
IZE	IZB	PLU:-|KAS:ABL|NUM:S|MUG:M|ENT:Pertsona|POS:POSatzetik|POS:+
IZE	IZB	PLU:-|KAS:ABL|NUM:S|MUG:M|ENT:Pertsona|POS:POSaurretik|POS:+
IZE	IZB	PLU:-|KAS:ABL|NUM:S|MUG:M|ENT:Pertsona|POS:POSeskutik|POS:+
IZE	IZB	PLU:-|KAS:ABL|NUM:S|MUG:M|ENT:Pertsona|POS:POSondotik|POS:+
IZE	IZB	PLU:-|KAS:ABL|NUM:S|MUG:M|ENT:Tokia
IZE	IZB	PLU:-|KAS:ABL|NUM:S|MUG:M|POS:POSeskutik|POS:+
IZE	IZB	PLU:-|KAS:ABS|MUG:MG|ENT:Pertsona
IZE	IZB	PLU:-|KAS:ABS|NUM:P|MUG:M|ENT:Pertsona
IZE	IZB	PLU:-|KAS:ABS|NUM:S|MUG:M
IZE	IZB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:???
IZE	IZB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea|POS:POSaurka|POS:+
IZE	IZB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Pertsona|POS:POSalde|POS:+
IZE	IZB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Pertsona|POS:POSaurka|POS:+
IZE	IZB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Pertsona|POS:POSesker|POS:+
IZE	IZB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Pertsona|POS:POSgain|POS:+
IZE	IZB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Tokia
IZE	IZB	PLU:-|KAS:ABS|NUM:S|MUG:M|POS:POSaurka|POS:+
IZE	IZB	PLU:-|KAS:ABS|NUM:S|MUG:M|POS:POSgain|POS:+
IZE	IZB	PLU:-|KAS:ALA|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	PLU:-|KAS:ALA|NUM:S|MUG:M|ENT:Pertsona|POS:POSaldera|POS:+
IZE	IZB	PLU:-|KAS:ALA|NUM:S|MUG:M|ENT:Pertsona|POS:POSbatera|POS:+
IZE	IZB	PLU:-|KAS:ALA|NUM:S|MUG:M|ENT:Pertsona|POS:POSlepora|POS:+
IZE	IZB	PLU:-|KAS:DAT|NUM:P|MUG:M|ENT:Pertsona
IZE	IZB	PLU:-|KAS:DAT|NUM:S|MUG:M
IZE	IZB	PLU:-|KAS:DAT|NUM:S|MUG:M|ENT:???
IZE	IZB	PLU:-|KAS:DAT|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	PLU:-|KAS:DAT|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	PLU:-|KAS:DES|NUM:S|MUG:M|ENT:???
IZE	IZB	PLU:-|KAS:DES|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	PLU:-|KAS:DES|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSkontra|POS:+
IZE	IZB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Pertsona|POS:POSarabera|POS:+
IZE	IZB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Pertsona|POS:POSbatera|POS:+
IZE	IZB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Pertsona|POS:POSbezalako|POS:+
IZE	IZB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Pertsona|POS:POSbezala|POS:+
IZE	IZB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Pertsona|POS:POSkontra|POS:+
IZE	IZB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Pertsona|POS:POSordez|POS:+
IZE	IZB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Tokia|POS:POSbezala|POS:+
IZE	IZB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Tokia|POS:POSkontra|POS:+
IZE	IZB	PLU:-|KAS:EM|NUM:S|MUG:M|POS:POSarabera|POS:+
IZE	IZB	PLU:-|KAS:EM|NUM:S|MUG:M|POS:POSbegira|POS:+
IZE	IZB	PLU:-|KAS:ERG|NUM:S|MUG:M
IZE	IZB	PLU:-|KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	PLU:-|KAS:ERG|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	PLU:-|KAS:ERG|NUM:S|MUG:M|ENT:Tokia
IZE	IZB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSkontrako|POS:+
IZE	IZB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Pertsona|POS:POSaldeko|POS:+
IZE	IZB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Pertsona|POS:POSarteko|POS:+
IZE	IZB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Pertsona|POS:POSaurkako|POS:+
IZE	IZB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Pertsona|POS:POSaurreko|POS:+
IZE	IZB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Pertsona|POS:POSburuzko|POS:+
IZE	IZB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Pertsona|POS:POSkontrako|POS:+
IZE	IZB	PLU:-|KAS:GEN|NUM:S|MUG:M
IZE	IZB	PLU:-|KAS:GEN|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	PLU:-|KAS:GEN|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	PLU:-|KAS:GEN|NUM:S|MUG:M|ENT:Pertsona|POS:POSbezalakoen|POS:+
IZE	IZB	PLU:-|KAS:GEN|NUM:S|MUG:M|ENT:Tokia
IZE	IZB	PLU:-|KAS:INE|NUM:S|MUG:M|ENT:Erakundea|POS:POSartean|POS:+
IZE	IZB	PLU:-|KAS:INE|NUM:S|MUG:M|ENT:Erakundea|POS:POSaurrean|POS:+
IZE	IZB	PLU:-|KAS:INE|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	PLU:-|KAS:INE|NUM:S|MUG:M|ENT:Pertsona|POS:POSartean|POS:+
IZE	IZB	PLU:-|KAS:INE|NUM:S|MUG:M|ENT:Pertsona|POS:POSaurrean|POS:+
IZE	IZB	PLU:-|KAS:INE|NUM:S|MUG:M|ENT:Pertsona|POS:POSondoan|POS:+
IZE	IZB	PLU:-|KAS:INE|NUM:S|MUG:M|POS:POSlekuan|POS:+
IZE	IZB	PLU:-|KAS:INS|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	PLU:-|KAS:INS|NUM:S|MUG:M|ENT:Pertsona|POS:POSpartez|POS:+
IZE	IZB	PLU:-|KAS:MOT|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	PLU:-|KAS:PAR|NUM:S|MUG:M
IZE	IZB	PLU:-|KAS:SOZ|NUM:S|MUG:M
IZE	IZB	PLU:-|KAS:SOZ|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	PLU:-|KAS:SOZ|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	PLU:-|MTKAT:LAB|KAS:ABS|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	PLU:-|MTKAT:SIG|ENT:Erakundea
IZE	IZB	PLU:-|MTKAT:SIG|KAS:ABL|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	PLU:-|MTKAT:SIG|KAS:ABS|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	PLU:-|MTKAT:SIG|KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	PLU:-|MTKAT:SIG|KAS:ERG|NUM:S|MUG:M|ENT:Pertsona
IZE	IZB	PLU:-|MTKAT:SIG|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	PLU:-|MTKAT:SIG|KAS:GEL|NUM:S|MUG:M|ENT:Tokia
IZE	IZB	PLU:-|MTKAT:SIG|KAS:GEN|NUM:S|MUG:M|ENT:Erakundea
IZE	IZB	ZENB:-|PLU:-
IZE	IZB	_
IZE	IZE_IZEELI	BIZ:+|KAS:ABS|NUM:P|MUG:M
IZE	IZE_IZEELI	BIZ:+|KAS:ABS|NUM:S|MUG:M
IZE	IZE_IZEELI	BIZ:+|KAS:INE|NUM:P|MUG:M
IZE	IZE_IZEELI	BIZ:-|KAS:ABS|NUM:P|MUG:M
IZE	IZE_IZEELI	BIZ:-|KAS:ABS|NUM:S|MUG:M
IZE	IZE_IZEELI	BIZ:-|KAS:ALA|NUM:S|MUG:M
IZE	IZE_IZEELI	BIZ:-|KAS:DAT|NUM:P|MUG:M
IZE	IZE_IZEELI	BIZ:-|KAS:DES|NUM:S|MUG:M
IZE	IZE_IZEELI	BIZ:-|KAS:ERG|NUM:P|MUG:M
IZE	IZE_IZEELI	BIZ:-|KAS:ERG|NUM:S|MUG:M
IZE	IZE_IZEELI	BIZ:-|KAS:GEN|NUM:P|MUG:M
IZE	IZE_IZEELI	BIZ:-|KAS:GEN|NUM:S|MUG:M
IZE	IZE_IZEELI	BIZ:-|KAS:INE|NUM:P|MUG:M
IZE	IZE_IZEELI	BIZ:-|KAS:INE|NUM:S|MUG:M
IZE	IZE_IZEELI	BIZ:-|KAS:INE|NUM:S|MUG:M|ENT:Tokia
IZE	IZE_IZEELI	BIZ:-|KAS:SOZ|NUM:P|MUG:M
IZE	IZE_IZEELI	BIZ:-|KAS:SOZ|NUM:S|MUG:M
IZE	IZE_IZEELI	KAS:ABL|NUM:S|MUG:M
IZE	IZE_IZEELI	KAS:ABS|NUM:P|MUG:M
IZE	IZE_IZEELI	KAS:ABS|NUM:P|MUG:M|ENT:Erakundea
IZE	IZE_IZEELI	KAS:ABS|NUM:S|MUG:M
IZE	IZE_IZEELI	KAS:ALA|NUM:S|MUG:M
IZE	IZE_IZEELI	KAS:DAT|NUM:S|MUG:M
IZE	IZE_IZEELI	KAS:DES|NUM:P|MUG:M
IZE	IZE_IZEELI	KAS:DES|NUM:S|MUG:M
IZE	IZE_IZEELI	KAS:ERG|NUM:P|MUG:M
IZE	IZE_IZEELI	KAS:ERG|NUM:S|MUG:M
IZE	IZE_IZEELI	KAS:GEN|NUM:P|MUG:M
IZE	IZE_IZEELI	KAS:GEN|NUM:S|MUG:M
IZE	IZE_IZEELI	KAS:INE|NUM:P|MUG:M
IZE	IZE_IZEELI	KAS:INE|NUM:S|MUG:M
IZE	IZE_IZEELI	KAS:SOZ|NUM:P|MUG:M
IZE	IZE_IZEELI	KAS:SOZ|NUM:S|MUG:M
IZE	IZE_IZEELI	MTKAT:SIG|KAS:ABS|NUM:P|MUG:M
IZE	IZE_IZEELI	MTKAT:SIG|KAS:ABS|NUM:S|MUG:M
IZE	IZE_IZEELI	MTKAT:SIG|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea
IZE	IZE_IZEELI	MTKAT:SIG|KAS:ERG|NUM:P|MUG:M|ENT:Erakundea
IZE	IZE_IZEELI	MTKAT:SIG|KAS:GEN|NUM:P|MUG:M|ENT:Erakundea
IZE	IZE_IZEELI	PLU:+|KAS:ERG|NUM:P|MUG:M|ENT:Erakundea
IZE	IZE_IZEELI	PLU:-|KAS:ABL|NUM:P|MUG:M|ENT:Pertsona
IZE	IZE_IZEELI	PLU:-|KAS:ABS|MUG:MG
IZE	IZE_IZEELI	PLU:-|KAS:ABS|NUM:P|MUG:M
IZE	IZE_IZEELI	PLU:-|KAS:ABS|NUM:P|MUG:M|ENT:???
IZE	IZE_IZEELI	PLU:-|KAS:ABS|NUM:P|MUG:M|ENT:Tokia
IZE	IZE_IZEELI	PLU:-|KAS:ABS|NUM:S|MUG:M
IZE	IZE_IZEELI	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea
IZE	IZE_IZEELI	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Pertsona
IZE	IZE_IZEELI	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Tokia
IZE	IZE_IZEELI	PLU:-|KAS:ALA|NUM:S|MUG:M
IZE	IZE_IZEELI	PLU:-|KAS:DAT|NUM:S|MUG:M
IZE	IZE_IZEELI	PLU:-|KAS:DAT|NUM:S|MUG:M|ENT:Tokia
IZE	IZE_IZEELI	PLU:-|KAS:ERG|NUM:P|MUG:M
IZE	IZE_IZEELI	PLU:-|KAS:ERG|NUM:P|MUG:M|ENT:Pertsona
IZE	IZE_IZEELI	PLU:-|KAS:ERG|NUM:S|MUG:M
IZE	IZE_IZEELI	PLU:-|KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
IZE	IZE_IZEELI	PLU:-|KAS:GEN|NUM:S|MUG:M
IZE	IZE_IZEELI	PLU:-|KAS:GEN|NUM:S|MUG:M|ENT:Pertsona
IZE	IZE_IZEELI	PLU:-|KAS:GEN|NUM:S|MUG:M|ENT:Tokia
IZE	IZE_IZEELI	PLU:-|KAS:INE|NUM:S|MUG:M|ENT:Tokia
IZE	IZE_IZEELI	PLU:-|KAS:INS|NUM:S|MUG:M
IZE	IZE_IZEELI	PLU:-|KAS:MOT|NUM:P|MUG:M
IZE	IZE_IZEELI	PLU:-|KAS:SOZ|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	BIZ:-|KAS:ABS|NUM:P|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	BIZ:-|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	BIZ:-|KAS:ABS|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	BIZ:-|KAS:ERG|NUM:P|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	BIZ:-|KAS:ERG|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	BIZ:-|KAS:GEL|NUM:P|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	BIZ:-|KAS:GEL|NUM:S|MUG:M|MW:B
IZE	LIB	BIZ:-|KAS:GEL|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	BIZ:-|KAS:GEL|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	LIB	BIZ:-|KAS:GEN|NUM:P|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	BIZ:-|KAS:GEN|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	BIZ:-|KAS:INE|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	BIZ:-|MTKAT:SIG|ENT:Erakundea
IZE	LIB	BIZ:-|MW:B|ENT:Erakundea
IZE	LIB	BIZ:-|MW:B|ENT:Tokia
IZE	LIB	BIZ:-|ZENB:-|NEUR:-|PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	BIZ:-|ZENB:-|NEUR:-|PLU:-|MTKAT:SIG|KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	ENT:Tokia
IZE	LIB	IZAUR:-|KAS:ABS|NUM:P|MUG:M|MW:B|ENT:Tokia
IZE	LIB	IZAUR:-|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	IZAUR:-|KAS:ABS|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	IZAUR:-|KAS:ABS|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	LIB	IZAUR:-|KAS:DAT|NUM:P|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	IZAUR:-|KAS:ERG|NUM:P|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	IZAUR:-|KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	IZAUR:-|KAS:ERG|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	IZAUR:-|KAS:GEL|NUM:P|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	IZAUR:-|KAS:GEL|NUM:P|MUG:M|MW:B|ENT:Tokia
IZE	LIB	IZAUR:-|KAS:GEL|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	IZAUR:-|KAS:GEL|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	IZAUR:-|KAS:GEL|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	LIB	IZAUR:-|KAS:GEN|NUM:P|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	IZAUR:-|KAS:GEN|NUM:S|MUG:M|MW:B|ENT:Erakundea|KAS:EM|POS:POSarabera|POS:+
IZE	LIB	IZAUR:-|KAS:INE|NUM:P|MUG:M|MW:B|ENT:Tokia
IZE	LIB	IZAUR:-|KAS:SOZ|NUM:P|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	IZAUR:-|MW:B|ENT:Erakundea
IZE	LIB	KAS:ABL|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	KAS:ABS|NUM:S|MUG:M
IZE	LIB	KAS:ABS|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	KAS:ABS|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	KAS:ABS|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	LIB	KAS:DAT|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	KAS:ERG|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	KAS:GEL|NUM:S|MUG:M|ENT:Pertsona
IZE	LIB	KAS:GEL|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	KAS:GEL|NUM:S|MUG:M|MW:B|ENT:Pertsona
IZE	LIB	KAS:GEL|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	LIB	KAS:GEN|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	KAS:GEN|NUM:S|MUG:M|MW:B
IZE	LIB	KAS:GEN|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	KAS:INE|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	KAS:INE|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	LIB	KAS:SOZ|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	KAS:SOZ|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	MTKAT:SIG|ENT:Erakundea
IZE	LIB	MTKAT:SIG|KAS:ABS|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	MTKAT:SIG|KAS:ALA|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	MTKAT:SIG|KAS:DAT|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	MTKAT:SIG|KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	MTKAT:SIG|KAS:ERG|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	MTKAT:SIG|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	MTKAT:SIG|KAS:GEL|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	MTKAT:SIG|KAS:GEN|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	MTKAT:SIG|KAS:INE|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	MW:B|ENT:???
IZE	LIB	MW:B|ENT:Erakundea
IZE	LIB	NEUR:-|ENT:Tokia
IZE	LIB	PLU:+|ENT:Erakundea
IZE	LIB	PLU:+|ENT:Tokia
IZE	LIB	PLU:+|IZAUR:-|KAS:ABS|NUM:P|MUG:M|MW:B|ENT:Tokia
IZE	LIB	PLU:+|IZAUR:-|KAS:ALA|NUM:P|MUG:M|MW:B|ENT:Tokia
IZE	LIB	PLU:+|IZAUR:-|KAS:DAT|NUM:P|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:+|IZAUR:-|KAS:ERG|NUM:P|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:+|IZAUR:-|KAS:GEL|NUM:P|MUG:M|ENT:Erakundea
IZE	LIB	PLU:+|IZAUR:-|KAS:GEL|NUM:P|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:+|IZAUR:-|KAS:GEL|NUM:P|MUG:M|MW:B|ENT:Tokia
IZE	LIB	PLU:+|IZAUR:-|KAS:INE|NUM:P|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:+|IZAUR:-|KAS:INE|NUM:P|MUG:M|MW:B|ENT:Tokia
IZE	LIB	PLU:+|KAS:ABL|NUM:P|MUG:M|ENT:Tokia
IZE	LIB	PLU:+|KAS:ABS|NUM:P|MUG:M|ENT:Erakundea
IZE	LIB	PLU:+|KAS:ABS|NUM:P|MUG:M|ENT:Tokia
IZE	LIB	PLU:+|KAS:ALA|NUM:P|MUG:M|ENT:Tokia
IZE	LIB	PLU:+|KAS:ERG|NUM:P|MUG:M|ENT:Erakundea
IZE	LIB	PLU:+|KAS:GEL|NUM:P|MUG:M|ENT:Erakundea
IZE	LIB	PLU:+|KAS:GEL|NUM:P|MUG:M|ENT:Pertsona
IZE	LIB	PLU:+|KAS:GEL|NUM:P|MUG:M|ENT:Tokia
IZE	LIB	PLU:+|KAS:GEL|NUM:P|MUG:M|ENT:Tokia|POS:POSarteko|POS:+
IZE	LIB	PLU:+|KAS:INE|NUM:P|MUG:M|ENT:Tokia
IZE	LIB	PLU:-
IZE	LIB	PLU:-|BIZ:-|KAS:ABS|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:-|BIZ:-|KAS:ABS|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	LIB	PLU:-|BIZ:-|KAS:DAT|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:-|BIZ:-|KAS:ERG|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:-|BIZ:-|KAS:GEL|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:-|BIZ:-|KAS:GEL|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	LIB	PLU:-|BIZ:-|KAS:GEN|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:-|BIZ:-|KAS:GEN|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	LIB	PLU:-|BIZ:-|KAS:INE|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	LIB	PLU:-|BIZ:-|KAS:INS|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:-|BIZ:-|KAS:SOZ|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:-|ENT:???
IZE	LIB	PLU:-|ENT:Erakundea
IZE	LIB	PLU:-|ENT:Pertsona
IZE	LIB	PLU:-|ENT:Tokia
IZE	LIB	PLU:-|KAS:ABL|NUM:S|MUG:M
IZE	LIB	PLU:-|KAS:ABL|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	PLU:-|KAS:ABL|NUM:S|MUG:M|ENT:Erakundea|POS:POSatzetik|POS:+
IZE	LIB	PLU:-|KAS:ABL|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|KAS:ABL|NUM:S|MUG:M|ENT:Tokia|POS:POSatzetik|POS:+
IZE	LIB	PLU:-|KAS:ABL|NUM:S|MUG:M|ENT:Tokia|POS:POSaurretik|POS:+
IZE	LIB	PLU:-|KAS:ABL|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	LIB	PLU:-|KAS:ABL|NUM:S|MUG:M|MW:B|ENT:Tokia|KAS:ALA|POS:POSkanpora|POS:+
IZE	LIB	PLU:-|KAS:ABS|MUG:MG|ENT:Erakundea
IZE	LIB	PLU:-|KAS:ABS|MUG:MG|ENT:Tokia
IZE	LIB	PLU:-|KAS:ABS|NUM:P|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|KAS:ABS|NUM:S|MUG:M
IZE	LIB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:???
IZE	LIB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea|POS:POSalde|POS:+
IZE	LIB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea|POS:POSaurkaa|POS:+
IZE	LIB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea|POS:POSaurka|POS:+
IZE	LIB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea|POS:POSesku|POS:+
IZE	LIB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Pertsona
IZE	LIB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Tokia|POS:POSalde|POS:+
IZE	LIB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Tokia|POS:POSarte|POS:+
IZE	LIB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Tokia|POS:POSaurka|POS:+
IZE	LIB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Tokia|POS:POSkanpo|POS:+
IZE	LIB	PLU:-|KAS:ABS|NUM:S|MUG:M|ENT:Tokia|POS:POSmenpe|POS:+
IZE	LIB	PLU:-|KAS:ABS|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:-|KAS:ABS|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	LIB	PLU:-|KAS:ABU|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|KAS:ABZ|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|KAS:ALA|NUM:S|MUG:M
IZE	LIB	PLU:-|KAS:ALA|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	PLU:-|KAS:ALA|NUM:S|MUG:M|ENT:Erakundea|POS:POSbatera|POS:+
IZE	LIB	PLU:-|KAS:ALA|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|KAS:ALA|NUM:S|MUG:M|ENT:Tokia|POS:POSkanpora|POS:+
IZE	LIB	PLU:-|KAS:ALA|NUM:S|MUG:M|ENT:Tokia|POS:POSmenpera|POS:+
IZE	LIB	PLU:-|KAS:ALA|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:-|KAS:ALA|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	LIB	PLU:-|KAS:ALA|NUM:S|MUG:M|POS:POSbatera|POS:+
IZE	LIB	PLU:-|KAS:DAT|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	PLU:-|KAS:DAT|NUM:S|MUG:M|ENT:Pertsona
IZE	LIB	PLU:-|KAS:DAT|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|KAS:DAT|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:-|KAS:DES|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	PLU:-|KAS:DES|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSarabera|POS:+
IZE	LIB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSbegira|POS:+
IZE	LIB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSbezalako|POS:+
IZE	LIB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSburuz|POS:+
IZE	LIB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSkontra|POS:+
IZE	LIB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Tokia|POS:POSarabera|POS:+
IZE	LIB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Tokia|POS:POSbegira|POS:+
IZE	LIB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Tokia|POS:POSbezalako|POS:+
IZE	LIB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Tokia|POS:POSbezala|POS:+
IZE	LIB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Tokia|POS:POSgora|POS:+
IZE	LIB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Tokia|POS:POShurbil|POS:+
IZE	LIB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Tokia|POS:POSkanpoko|POS:+
IZE	LIB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Tokia|POS:POSkontra|POS:+
IZE	LIB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Tokia|POS:POSpareko|POS:+
IZE	LIB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Tokia|POS:POSurrun|POS:+
IZE	LIB	PLU:-|KAS:EM|NUM:S|MUG:M|ENT:Tokia|POS:POSzehar|POS:+
IZE	LIB	PLU:-|KAS:ERG|NUM:P|MUG:M|ENT:Pertsona
IZE	LIB	PLU:-|KAS:ERG|NUM:S|MUG:M
IZE	LIB	PLU:-|KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	PLU:-|KAS:ERG|NUM:S|MUG:M|ENT:Pertsona
IZE	LIB	PLU:-|KAS:ERG|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|KAS:ERG|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:-|KAS:GEL|NUM:S|MUG:M
IZE	LIB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSaldeko|POS:+
IZE	LIB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSarteko|POS:+
IZE	LIB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSaurkako|POS:+
IZE	LIB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSburuzko|POS:+
IZE	LIB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSinguruko|POS:+
IZE	LIB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea|POS:POSkontrako|POS:+
IZE	LIB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Pertsona
IZE	LIB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Tokia|POS:POSaldeko|POS:+
IZE	LIB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Tokia|POS:POSarteko|POS:+
IZE	LIB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Tokia|POS:POSaurkako|POS:+
IZE	LIB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Tokia|POS:POSkanpoko|POS:+
IZE	LIB	PLU:-|KAS:GEL|NUM:S|MUG:M|ENT:Tokia|POS:POSkontrako|POS:+
IZE	LIB	PLU:-|KAS:GEL|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:-|KAS:GEL|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	LIB	PLU:-|KAS:GEN|NUM:S|MUG:M|ENT:???
IZE	LIB	PLU:-|KAS:GEN|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	PLU:-|KAS:GEN|NUM:S|MUG:M|ENT:Pertsona
IZE	LIB	PLU:-|KAS:GEN|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|KAS:GEN|NUM:S|MUG:M|MW:B
IZE	LIB	PLU:-|KAS:GEN|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:-|KAS:GEN|NUM:S|MUG:M|MW:B|ENT:Erakundea|KAS:GEL|POS:POSaldeko|POS:+
IZE	LIB	PLU:-|KAS:GEN|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	LIB	PLU:-|KAS:INE|NUM:S|MUG:M
IZE	LIB	PLU:-|KAS:INE|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	PLU:-|KAS:INE|NUM:S|MUG:M|ENT:Erakundea|POS:POSburuan|POS:+
IZE	LIB	PLU:-|KAS:INE|NUM:S|MUG:M|ENT:Erakundea|POS:POSgainean|POS:+
IZE	LIB	PLU:-|KAS:INE|NUM:S|MUG:M|ENT:Pertsona
IZE	LIB	PLU:-|KAS:INE|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|KAS:INE|NUM:S|MUG:M|ENT:Tokia|POS:POSartean|POS:+
IZE	LIB	PLU:-|KAS:INE|NUM:S|MUG:M|ENT:Tokia|POS:POSbarruan|POS:+
IZE	LIB	PLU:-|KAS:INE|NUM:S|MUG:M|ENT:Tokia|POS:POSeskuetan|POS:+
IZE	LIB	PLU:-|KAS:INE|NUM:S|MUG:M|MW:B|ENT:Erakundea
IZE	LIB	PLU:-|KAS:INE|NUM:S|MUG:M|MW:B|ENT:Tokia
IZE	LIB	PLU:-|KAS:INE|NUM:S|MUG:M|MW:B|ENT:Tokia|KAS:EM|POS:POSzehar|POS:+
IZE	LIB	PLU:-|KAS:INS|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|KAS:PRO|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|KAS:SOZ|NUM:S|MUG:M
IZE	LIB	PLU:-|KAS:SOZ|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	PLU:-|KAS:SOZ|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|MTKAT:LAB|KAS:DAT|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	PLU:-|MTKAT:LAB|KAS:ERG|NUM:S|MUG:M
IZE	LIB	PLU:-|MTKAT:SIG
IZE	LIB	PLU:-|MTKAT:SIG|ENT:Erakundea
IZE	LIB	PLU:-|MTKAT:SIG|ENT:Tokia
IZE	LIB	PLU:-|MTKAT:SIG|KAS:ABS|NUM:S|MUG:M
IZE	LIB	PLU:-|MTKAT:SIG|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	PLU:-|MTKAT:SIG|KAS:ABS|NUM:S|MUG:M|ENT:Erakundea|POS:POSesku|POS:+
IZE	LIB	PLU:-|MTKAT:SIG|KAS:ABS|NUM:S|MUG:M|ENT:Pertsona
IZE	LIB	PLU:-|MTKAT:SIG|KAS:ABS|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|MTKAT:SIG|KAS:EM|NUM:S|MUG:M|ENT:Erakundea|POS:POSarabera|POS:+
IZE	LIB	PLU:-|MTKAT:SIG|KAS:ERG|NUM:S|MUG:M
IZE	LIB	PLU:-|MTKAT:SIG|KAS:ERG|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	PLU:-|MTKAT:SIG|KAS:GEL|NUM:S|MUG:M
IZE	LIB	PLU:-|MTKAT:SIG|KAS:GEL|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	PLU:-|MTKAT:SIG|KAS:GEL|NUM:S|MUG:M|ENT:Pertsona
IZE	LIB	PLU:-|MTKAT:SIG|KAS:GEL|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|MTKAT:SIG|KAS:GEN|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	PLU:-|MTKAT:SIG|KAS:INE|NUM:S|MUG:M|ENT:Erakundea|POS:POSartean|POS:+
IZE	LIB	PLU:-|MTKAT:SIG|KAS:INE|NUM:S|MUG:M|ENT:Tokia
IZE	LIB	PLU:-|MTKAT:SIG|KAS:SOZ|NUM:S|MUG:M|ENT:Erakundea
IZE	LIB	PLU:-|MW:B|ENT:Erakundea
IZE	LIB	PLU:-|MW:B|ENT:Tokia
IZE	LIB	_
IZE	ZKI	BIZ:-
IZE	ZKI	BIZ:-|KAS:ABL|NUM:S|MUG:M
IZE	ZKI	BIZ:-|KAS:ABS|NUM:P|MUG:M
IZE	ZKI	BIZ:-|KAS:ABU|NUM:S|MUG:M
IZE	ZKI	BIZ:-|KAS:EM|POS:POSgora|POS:+
IZE	ZKI	BIZ:-|KAS:GEL|NUM:S|MUG:M
IZE	ZKI	KAS:ABL|NUM:P|MUG:M
IZE	ZKI	KAS:ABL|NUM:S|MUG:M
IZE	ZKI	KAS:ABL|NUM:S|MUG:M|ENT:Tokia
IZE	ZKI	KAS:ABS|MUG:MG
IZE	ZKI	KAS:ABS|NUM:P|MUG:M
IZE	ZKI	KAS:ABS|NUM:P|MUG:M|POS:POSarte|POS:+
IZE	ZKI	KAS:ABS|NUM:S|MUG:M
IZE	ZKI	KAS:ABS|NUM:S|MUG:M|POS:POSarte|POS:+
IZE	ZKI	KAS:ABU|NUM:S|MUG:M
IZE	ZKI	KAS:ALA|NUM:P|MUG:M
IZE	ZKI	KAS:ALA|NUM:P|MUG:M|POS:POSaldera|POS:+
IZE	ZKI	KAS:ALA|NUM:P|MUG:M|POS:POSaurrera|POS:+
IZE	ZKI	KAS:ALA|NUM:S|MUG:M
IZE	ZKI	KAS:ALA|NUM:S|MUG:M|POS:POSaldera|POS:+
IZE	ZKI	KAS:ALA|NUM:S|MUG:M|POS:POSaurrera|POS:+
IZE	ZKI	KAS:DAT|MUG:MG
IZE	ZKI	KAS:DAT|NUM:PH|MUG:M
IZE	ZKI	KAS:EM|MUG:MG|POS:POSgisan|POS:+
IZE	ZKI	KAS:EM|NUM:S|MUG:M|POS:POSaurrera|POS:+
IZE	ZKI	KAS:EM|NUM:S|MUG:M|POS:POSgeroztik|POS:+
IZE	ZKI	KAS:EM|NUM:S|MUG:M|POS:POSgora|POS:+
IZE	ZKI	KAS:EM|POS:POSgora|POS:+
IZE	ZKI	KAS:ERG|MUG:MG
IZE	ZKI	KAS:ERG|NUM:P|MUG:M
IZE	ZKI	KAS:ERG|NUM:S|MUG:M
IZE	ZKI	KAS:GEL|NUM:P|MUG:M
IZE	ZKI	KAS:GEL|NUM:P|MUG:M|POS:POSbitarteko|POS:+
IZE	ZKI	KAS:GEL|NUM:S|MUG:M
IZE	ZKI	KAS:GEL|NUM:S|MUG:M|ENT:Tokia
IZE	ZKI	KAS:GEL|NUM:S|MUG:M|MW:B
IZE	ZKI	KAS:GEL|NUM:S|MUG:M|POS:POSbitarteko|POS:+
IZE	ZKI	KAS:GEL|NUM:S|MUG:M|POS:POSgorako|POS:+
IZE	ZKI	KAS:GEN|NUM:P|MUG:M
IZE	ZKI	KAS:GEN|NUM:S|MUG:M
IZE	ZKI	KAS:INE|NUM:P|MUG:M
IZE	ZKI	KAS:INE|NUM:P|MUG:M|POS:POSbitartean|POS:+
IZE	ZKI	KAS:INE|NUM:S|MUG:M
IZE	ZKI	KAS:INE|NUM:S|MUG:M|ENT:Erakundea
IZE	ZKI	KAS:INE|NUM:S|MUG:M|ENT:Tokia
IZE	ZKI	KAS:INE|NUM:S|MUG:M|POS:POSbitartean|POS:+
IZE	ZKI	KAS:INS|NUM:S|MUG:M
IZE	ZKI	KAS:PAR|MUG:MG
IZE	ZKI	KAS:SOZ|MUG:MG
IZE	ZKI	POS:POSaldean|POS:+|KAS:INE
IZE	ZKI	POS:POSarte|POS:+|KAS:ABS
IZE	ZKI	POS:POSbitartean|POS:+|KAS:INE
IZE	ZKI	_
LOT	JNT	ERL:AURK
LOT	JNT	ERL:AURK|MW:B
LOT	JNT	ERL:EMEN
LOT	JNT	ERL:EMEN|MW:B
LOT	JNT	ERL:HAUT
LOT	LOK	ERL:AURK
LOT	LOK	ERL:AURK|MW:B
LOT	LOK	ERL:BALD
LOT	LOK	ERL:BALD|MW:B
LOT	LOK	ERL:DENB|MW:B
LOT	LOK	ERL:EMEN
LOT	LOK	ERL:EMEN|MW:B
LOT	LOK	ERL:ESPL
LOT	LOK	ERL:ESPL|MW:B
LOT	LOK	ERL:HAUT
LOT	LOK	ERL:KAUS
LOT	LOK	ERL:KAUS|KLM:HAS
LOT	LOK	ERL:KAUS|MW:B
LOT	LOK	ERL:KONT
LOT	LOK	ERL:KONT|MW:B
LOT	LOK	ERL:MOD/DENB|MW:B
LOT	LOK	ERL:MOD|MW:B
LOT	LOK	ERL:ONDO
LOT	LOK	ERL:ONDO|MW:B
LOT	MEN	ERL:DENB|MW:B
LOT	MEN	ERL:KAUS|KLM:AM
LOT	MEN	ERL:KONT
PRT	PRT	ERL:KONPL|MOD:EGI
PRT	PRT	MOD:EGI
PRT	PRT	MOD:ZIU
PUNT_MARKA	PUNT_BI_PUNT	_
PUNT_MARKA	PUNT_ESKL	_
PUNT_MARKA	PUNT_GALD	_
PUNT_MARKA	PUNT_HIRU	_
PUNT_MARKA	PUNT_KOMA	_
PUNT_MARKA	PUNT_PUNT	_
PUNT_MARKA	PUNT_PUNT_KOMA	_
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
