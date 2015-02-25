# ABSTRACT: Driver for the Turkish tagset of the CoNLL 2007 Shared Task (derived from the METU Sabanci Treebank).
# Copyright © 2011, 2013, 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Copyright © 2011 Loganathan Ramasamy <ramasamy@ufal.mff.cuni.cz>

package Lingua::Interset::Tagset::TR::Conll;
use strict;
use warnings;
our $VERSION = '2.040';

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
extends 'Lingua::Interset::Tagset::Conll';



#------------------------------------------------------------------------------
# Returns the tagset id that should be set as the value of the 'tagset' feature
# during decoding. Every derived class must (re)define this method! The result
# should correspond to the last two parts in package name, lowercased.
# Specifically, it should be the ISO 639-2 language code, followed by '::' and
# a language-specific tagset id. Example: 'cs::multext'.
#------------------------------------------------------------------------------
sub get_tagset_id
{
    return 'tr::conll';
}



#------------------------------------------------------------------------------
# Creates atomic drivers for surface features.
#------------------------------------------------------------------------------
sub _create_atoms
{
    my $self = shift;
    my %atoms;
    # PART OF SPEECH ####################
    $atoms{pos} = $self->create_atom
    (
        'surfeature' => 'pos',
        'decode_map' =>
        {
            # Noun Noun A3sg|Pnon|Nom examples: şey (thing), gün (day), zaman (time), kadın (woman), yıl (year)
            'Noun Noun'      => ['pos' => 'noun', 'nountype' => 'com'],
            'Noun Prop'      => ['pos' => 'noun', 'nountype' => 'prop'],
            # Documentation: "A +Zero appears after a zero morpheme derivation."
            # So it does not seem as something one would necessarily want to preserve.
            'Noun Zero'      => ['pos' => 'noun', 'other' => {'zero' => 1}],
            'Noun NInf'      => ['pos' => 'noun', 'verbform' => 'inf'],
            'Noun NFutPart'  => ['pos' => 'noun', 'verbform' => 'part', 'tense' => 'fut'],
            'Noun NPresPart' => ['pos' => 'noun', 'verbform' => 'part', 'tense' => 'pres'],
            'Noun NPastPart' => ['pos' => 'noun', 'verbform' => 'part', 'tense' => 'past'],
            'Pron PersP'     => ['pos' => 'noun', 'prontype' => 'prs'],
            'Pron ReflexP'   => ['pos' => 'noun', 'prontype' => 'prs', 'reflex' => 'reflex'],
            # "Pron Pron" contains a heterogenous group of pronouns. Reciprocal pronouns seem to constitute a large part of it.
            # Example: birbirimizi (each other)
            'Pron Pron'      => ['pos' => 'noun', 'prontype' => 'rcp'],
            'Pron DemonsP'   => ['pos' => 'noun', 'prontype' => 'dem'],
            'Pron QuesP'     => ['pos' => 'noun', 'prontype' => 'int'],
            'Adj Adj'        => ['pos' => 'adj'],
            'Adj Zero'       => ['pos' => 'adj', 'other' => {'zero' => 1}],
            'Adj AFutPart'   => ['pos' => 'adj', 'verbform' => 'part', 'tense' => 'fut'],
            'Adj APresPart'  => ['pos' => 'adj', 'verbform' => 'part', 'tense' => 'pres'],
            'Adj APastPart'  => ['pos' => 'adj', 'verbform' => 'part', 'tense' => 'past'],
            'Det Det'        => ['pos' => 'adj', 'prontype' => 'prn'],
            'Num Card'       => ['pos' => 'num', 'numtype' => 'card'],
            'Num Ord'        => ['pos' => 'adj', 'numtype' => 'ord'],
            'Num Distrib'    => ['pos' => 'num', 'numtype' => 'dist'],
            'Num Range'      => ['pos' => 'num', 'numtype' => 'range'],
            'Num Real'       => ['pos' => 'num', 'numform' => 'digit'],
            'Verb Verb'      => ['pos' => 'verb'],
            'Verb Zero'      => ['pos' => 'verb', 'other' => {'zero' => 1}],
            'Adv Adv'        => ['pos' => 'adv'],
            'Postp Postp'    => ['pos' => 'adp', 'adpostype' => 'post'],
            'Conj Conj'      => ['pos' => 'conj'],
            # Question particle "mi". It inflects for person, number and tense.
            'Ques Ques'      => ['pos' => 'part', 'prontype' => 'int'],
            # Documentation (https://wiki.ufal.ms.mff.cuni.cz/_media/user:zeman:treebanks:ttbankkl.pdf page 25):
            # +Dup category contains onomatopoeia words (zvukomalebná slova) which only appear as duplications in a sentence.
            # Some of them could be considered interjections, some others (or in some contexts) not.
            # Syntactically they may probably act as various parts of speech. Adjectives? Adverbs? Verbs? Nouns?
            # There are only about ten examples in the corpus.
            'Dup Dup'        => ['pos' => '', 'echo' => 'rdp'],
            'Interj Interj'  => ['pos' => 'int'],
            'Punc Punc'      => ['pos' => 'punc']
        },
        'encode_map' =>
        {
            'pos' => { 'noun' => { 'nountype' => { 'com'  => 'Noun Noun',
                                                   'prop' => 'Noun Prop',
                                                   '@'    => { 'prontype' => { 'dem' => 'Pron DemonsP',
                                                                               'int' => 'Pron QuesP',
                                                                               'prs' => { 'reflex' => { 'reflex' => 'Pron ReflexP',
                                                                                                        '@'      => 'Pron PersP' }},
                                                                               ''    => 'Noun Noun',
                                                                               '@'   => 'Pron Pron' }}}},
                       'adj'  => { 'numtype' => { 'ord' => 'Num Ord',
                                                  '@'   => { 'prontype' => { ''  => 'Adj Adj',
                                                                             '@' => 'Det Det' }}}},
                       'num'  => { 'numtype' => { 'ord'   => 'Num Ord',
                                                  'dist'  => 'Num Distrib',
                                                  'range' => 'Num Range',
                                                  '@'     => { 'numform' => { 'digit' => 'Num Real',
                                                                              '@'     => 'Num Card' }}}},
                       'verb' => 'Verb Verb',
                       'adv'  => 'Adv Adv',
                       'adp'  => 'Postp Postp',
                       'conj' => 'Conj Conj',
                       'part' => 'Ques Ques',
                       'int'  => 'Interj Interj',
                       'punc' => 'Punc Punc',
                       'sym'  => 'Punc Punc' }
        }
    );
    # GENDER ####################
    $atoms{gender} = $self->create_simple_atom
    (
        'intfeature' => 'gender',
        'simple_decode_map' =>
        {
            'Ma' => 'masc',
            'Fe' => 'fem',
            'Ne' => 'neut'
        }
    );
    # AGREEMENT ####################
    $atoms{agreement} = $self->create_atom
    (
        'surfeature' => 'agreement',
        'decode_map' =>
        {
            'A1sg' => ['person' => '1', 'number' => 'sing'],
            'A1pl' => ['person' => '1', 'number' => 'plur'],
            'A2sg' => ['person' => '2', 'number' => 'sing'],
            'A2pl' => ['person' => '2', 'number' => 'plur'],
            'A3sg' => ['person' => '3', 'number' => 'sing'],
            'A3pl' => ['person' => '3', 'number' => 'plur']
        },
        'encode_map' =>
        {
            'number' => { 'sing' => { 'person' => { '1' => 'A1sg',
                                                    '2' => 'A2sg',
                                                    '3' => 'A3sg' }},
                          'plur' => { 'person' => { '1' => 'A1pl',
                                                    '2' => 'A2pl',
                                                    '3' => 'A3pl' }}}
        }
    );
    # POSSESSIVE AGREEMENT ####################
    $atoms{possagreement} = $self->create_atom
    (
        'surfeature' => 'possagreement',
        'decode_map' =>
        {
            'P1sg' => ['possperson' => '1', 'possnumber' => 'sing'],
            'P1pl' => ['possperson' => '1', 'possnumber' => 'plur'],
            'P2sg' => ['possperson' => '2', 'possnumber' => 'sing'],
            'P2pl' => ['possperson' => '2', 'possnumber' => 'plur'],
            'P3sg' => ['possperson' => '3', 'possnumber' => 'sing'],
            'P3pl' => ['possperson' => '3', 'possnumber' => 'plur'],
            'Pnon' => [] # no overt agreement
        },
        'encode_map' =>
        {
            'possnumber' => { 'sing' => { 'possperson' => { '1' => 'P1sg',
                                                            '2' => 'P2sg',
                                                            '3' => 'P3sg' }},
                              'plur' => { 'possperson' => { '1' => 'P1pl',
                                                            '2' => 'P2pl',
                                                            '3' => 'P3pl' }}}
        }
    );
    # CASE ####################
    $atoms{case} = $self->create_simple_atom
    (
        'intfeature' => 'case',
        'simple_decode_map' =>
        {
            'Nom' => 'nom',
            'Gen' => 'gen',
            'Acc' => 'acc',
            'Abl' => 'abl',
            'Dat' => 'dat',
            'Loc' => 'loc',
            'Ins' => 'ins',
            # There is also the 'Equ' feature. It seems to appear in place of case but it is not documented.
            # And descriptions of Turkish grammar that I have seen do not list other cases than the above.
            # Nevertheless, until further notice, I am going to use another case value to store the feature.
            'Equ' => 'com'
        }
    );
    # PC (???) CASE ####################
    $atoms{pccase} = $self->create_simple_atom
    (
        'intfeature' => 'case',
        'simple_decode_map' =>
        {
            'PCNom' => 'nom',
            'PCGen' => 'gen',
            'PCAcc' => 'acc',
            'PCAbl' => 'abl',
            'PCDat' => 'dat',
            'PCLoc' => 'loc',
            'PCIns' => 'ins'
        }
    );
    # DEGREE OF COMPARISON ####################
    $atoms{degree} = $self->create_simple_atom
    (
        'intfeature' => 'degree',
        'simple_decode_map' =>
        {
            'Cp' => 'comp',
            'Su' => 'sup'
        }
    );
    # ADJECTIVE TYPE ####################
    # We save it in 'other/adjvtype' together with adverb types. We merge the two features so that
    # we do not have to distinguish them later on encoding.
    $atoms{adjtype} = $self->create_atom
    (
        'surfeature' => 'adjtype',
        'decode_map' =>
        {
            # Adj Adj _ examples: büyük (big), yeni (new), iyi (good), aynı (same), çok (many)
            # Adj Adj Agt examples: üretici (manufacturing), ürkütücü (scary), rahatlatıcı (relaxing), yakıcı (burning), barışçı (pacific)
            'Agt'       => ['other' => {'adjvtype' => 'agt'}],
            # Adj Adj AsIf examples: böylece (so that), onca (all that), delice (insane), aptalca (stupid), çılgınca (wild)
            'AsIf'      => ['other' => {'adjvtype' => 'asif'}],
            # Adj Adj FitFor examples: dolarlık (in dollars), yıllık (annual), saatlik (hourly), trilyonluk (trillions worth), liralık (in pounds)
            'FitFor'    => ['other' => {'adjvtype' => 'fitfor'}],
            # Adj Adj InBetween example: uluslararası (international)
            'InBetween' => ['other' => {'adjvtype' => 'inbetween'}],
            # Adj Adj JustLike example: konyakımsı (just like brandy), redingotumsu (just like redingot)
            'JustLike'  => ['other' => {'adjvtype' => 'justlike'}],
            # Adj Adj Rel examples: önceki (previous), arasındaki (in-between), içindeki (intra-), üzerindeki (upper), öteki (other)
            'Rel'       => ['other' => {'adjvtype' => 'rel'}],
            # Adj Adj Related examples: ideolojik (ideological), teknolojik (technological), meteorolojik (meteorological), bilimsel (scientific), psikolojik (psychological)
            'Related'   => ['other' => {'adjvtype' => 'related'}],
            # Adj Adj With examples: önemli (important), ilgili (related), vadeli (forward), yaşlı (elderly), yararlı (helpful)
            'With'      => ['other' => {'adjvtype' => 'with'}],
            # Adj Adj Without examples: sessiz (quiet), savunmasız (vulnerable), anlamsız (meaningless), gereksiz (unnecessary), rahatsız (uncomfortable)
            'Without'   => ['other' => {'adjvtype' => 'without'}]
        },
        'encode_map' =>
        {
            'other/adjvtype' => { 'agt'       => 'Agt',
                                  'asif'      => 'AsIf',
                                  'fitfor'    => 'FitFor',
                                  'inbetween' => 'InBetween',
                                  'justlike'  => 'JustLike',
                                  'rel'       => 'Rel',
                                  'related'   => 'Related',
                                  'with'      => 'With',
                                  'without'   => 'Without' }
        }
    );
    # ADVERB TYPE ####################
    # We save it in 'other/adjvtype' together with adverb types. We merge the two features so that
    # we do not have to distinguish them later on encoding.
    $atoms{advtype} = $self->create_atom
    (
        'surfeature' => 'advtype',
        'decode_map' =>
        {
            # The non-"_" non-Ly non-Since adverbs seem to be derived from verbs, i.e. they could be called adverbial participles (transgressives).
            # Adv Adv _ examples: daha (more), çok (very), en (most), bile (even), hiç (never)
            # Adv Adv Ly examples: hafifçe (slightly), rahatça (easily), iyice (thoroughly), öylece (just), aptalca (stupidly)
            'Ly'                  => ['other' => {'adjvtype' => 'ly'}],
            # Adv Adv Since examples: yıldır (for years), yıllardır (for years), saattir (for hours)
            'Since'               => ['other' => {'adjvtype' => 'since'}],
            # Adv Adv AfterDoingSo examples: gidip (having gone), gelip (having come), deyip (having said), kesip (having cut out), çıkıp (having gotten out)
            'AfterDoingSo'        => ['other' => {'adjvtype' => 'afterdoingso'}, 'verbform' => 'trans'],
            # Adv Adv As examples: istemedikçe (unless you want to), arttıkça (as increases), konuştukça (as you talk), oldukça (rather), gördükçe (as you see)
            'As'                  => ['other' => {'adjvtype' => 'as'}, 'verbform' => 'trans'],
            # Adv Adv AsIf examples: güneşiymişçesine, okumuşçasına (as if reads), etmişçesine, taparcasına (as if worships), okşarcasına (as if strokes)
            'AsIf'                => ['other' => {'adjvtype' => 'asif'}, 'verbform' => 'trans'],
            # Adv Adv ByDoingSo examples: olarak (by being), diyerek (by saying), belirterek (by specifying), koşarak (by running), çekerek (by pulling)
            'ByDoingSo'           => ['other' => {'adjvtype' => 'bydoingso'}, 'verbform' => 'trans'],
            # Adv Adv SinceDoingSo examples: olalı (since being), geleli (since coming), dönüşeli (since returning), başlayalı (since starting), kapılalı
            'SinceDoingSo'        => ['other' => {'adjvtype' => 'sincedoingso'}, 'verbform' => 'trans'],
            # Adv Adv When examples: görünce (when/on seeing), deyince (when we say), olunca (when), açılınca (when opening), gelince (when coming)
            'When'                => ['other' => {'adjvtype' => 'when'}, 'verbform' => 'trans'],
            # Adv Adv While examples: giderken (en route), konuşurken (while talking), derken (while saying), çıkarken (on the way out), varken (when there is)
            'While'               => ['other' => {'adjvtype' => 'while'}, 'verbform' => 'trans'],
            # Adv Adv WithoutHavingDoneSo examples: olmadan (without being), düşünmeden (without thinking), geçirmeden (without passing), çıkarmadan (without removing), almadan (without taking)
            'WithoutHavingDoneSo' => ['other' => {'adjvtype' => 'withouthavingdoneso'}, 'verbform' => 'trans'],
        },
        'encode_map' =>
        {
            'other/adjvtype' => { 'ly'                  => 'Ly',
                                  'since'               => 'Since',
                                  'afterdoingso'        => 'AfterDoingSo',
                                  'as'                  => 'As',
                                  'asif'                => 'AsIf',
                                  'bydoingso'           => 'ByDoingSo',
                                  'sincedoingso'        => 'SinceDoingSo',
                                  'when'                => 'When',
                                  'while'               => 'While',
                                  'withouthavingdoneso' => 'WithoutHavingDoneSo' }
        }
    );
    # COMPOUNDING AND MODALITY ####################
    # Compounding and modality features (here explained on the English verb "to do"; Turkish examples are not translations of "to do"!)
    # +Able ... able to do ... examples: olabilirim, olabilirsin, olabilir ... bunu demis olabilirim = I may have said (demis = said)
    # +Repeat ... do repeatedly ... no occurrence
    # +Hastily ... do hastily ... examples: aliverdi, doluverdi, gidiverdi
    # +EverSince ... have been doing ever since ... no occurrence
    # +Almost ... almost did but did not ... no occurrence
    # +Stay ... stayed frozen whlie doing ... just two examples: şaşakalmıştık, uyuyakalmıştı (Google translates the latter as "fallen asleep")
    # +Start ... start doing immediately ... no occurrence
    # Verbs derived from nouns or adjectives:
    #1 if($feature eq 'Acquire'); # to acquire the noun
    #1 if($feature eq 'Become'); # to become the noun
    # TENSE ####################
    # Two (but not more) tenses may be combined together.
    # We have to preprocess the tags so that two tense features appear as one, e.g. "Fut|Past" becomse "FutPast".
    $atoms{tense} = $self->create_atom
    (
        'surfeature' => 'tense',
        'decode_map' =>
        {
            # The "Pres" tag is not frequent.
            # It occurs with "Verb Zero" more often than with "Verb Verb". It often occurs with copulae ("Cop").
            # According to documentation, it is intended for predicative nominals or adjectives.
            # Pres|Cop|A3sg examples: vardır (there are), yoktur (there is no), demektir (means), sebzedir, nedir (what is the)
            'Pres'     => ['tense' => 'pres'],
            # The "Fut" tag can be combined with "Past" and occasionally with "Narr".
            # Pos|Fut|A3sg examples: olacak (will), verecek (will give), gelecek, sağlayacak, yapacak
            # Pos|Fut|Past|A3sg examples: olacaktı (would), öğrenecekti (would learn), yapacaktı (would make), ölecekti, sokacaktı
            'Fut'      => ['tense' => 'fut'],
            'FutPast'  => ['tense' => 'fut|past'],
            # Pos|Past|A3sg examples: dedi (said), oldu (was), söyledi (said), geldi (came), sordu (asked)
            # Pos|Prog1|Past|A3sg examples: geliyordu (was coming), oturuyordu (was sitting), bakıyordu, oluyordu, titriyordu
            'NarrPast' => ['tense' => 'narr|past'],
            'Past'     => ['tense' => 'past'],
            # Pos|Narr|A3sg examples: olmuş (was), demiş (said), bayılmış (fainted), gelmiş (came), çıkmış (emerged)
            # Pos|Narr|Past|A3sg examples: başlamıştı (started), demişti (said), gelmişti (was), geçmişti (passed), kalkmıştı (sailed)
            # Pos|Prog1|Narr|A3sg examples: oluyormuş (was happening), bakıyormuş (was staring), çırpınıyormuş, yaşıyormuş, istiyormuş
            # enwiki:
            # The definite past or di-past is used to assert that something did happen in the past.
            # The inferential past or miş-past can be understood as asserting that a past participle is applicable now;
            # hence it is used when the fact of a past event, as such, is not important;
            # in particular, the inferential past is used when one did not actually witness the past event.
            # A newspaper will generally use the di-past, because it is authoritative.
            'FutNarr'  => ['tense' => 'fut|narr'],
            'Narr'     => ['tense' => 'narr'],
            # Pos|Aor|A3sg examples: olur (will), gerekir (must), yeter (is enough), alır (takes), gelir (income)
            # Pos|Aor|Narr|A3sg examples: olurmuş (bustled), inanırmış, severmiş (loved), yaşarmış (lived), bitermiş
            # Pos|Aor|Past|A3sg examples: olurdu (would), otururdu (sat), yapardı (would), bilirdi (knew), derdi (used to say)
            # enwiki:
            # In Turkish the aorist is a habitual aspect. (Geoffrey Lewis, Turkish Grammar (2nd ed, 2000, Oxford))
            # So it is not a tense (unlike e.g. Bulgarian aorist) and it can be combined with tenses.
            # Habitual aspect means repetitive actions (they take place "usually"). It is a type of imperfective aspect.
            # English has habitual past: "I used to visit him frequently."
            'Aor'      => ['tense' => 'aor']
        },
        'encode_map' =>
        {
            'tense' => { 'aor'       => 'Aor',
                         'fut'       => 'Fut',
                         'fut|narr'  => 'FutNarr',
                         'fut|past'  => 'FutPast',
                         'narr'      => 'Narr',
                         'narr|past' => 'NarrPast',
                         'past'      => 'Past',
                         'pres'      => 'Pres' }
        }
    );
    # ASPECT ####################
    $atoms{aspect} = $self->create_atom
    (
        'surfeature' => 'aspect',
        'decode_map' =>
        {
            # Documentation calls the following two tenses "present continuous".
            # Prog1 = "present continuous, process"
            # Prog2 = "present continuous, state"
            # However, there are also combinations with past tags, e.g. "Prog1|Past".
            # Pos|Prog1|A3sg examples: diyor (is saying), geliyor (is coming), oluyor (is being), yapıyor (is doing), biliyor (is knowing)
            # Pos|Prog1|Past|A3sg examples: geliyordu (was coming), oturuyordu (was sitting), bakıyordu, oluyordu, titriyordu
            # Pos|Prog1|Narr|A3sg examples: oluyormuş (was happening), bakıyormuş (was staring), çırpınıyormuş, yaşıyormuş, istiyormuş
            # Pos|Prog2|A3sg examples: oturmakta (is sitting), kapamakta (is closing), soymakta (is peeling), kullanmakta, taşımakta
            'Prog1' => ['aspect' => 'prog'],
            'Prog2' => ['aspect' => 'prog', 'variant' => '2']
        },
        'encode_map' =>
        {
            'aspect' => { 'prog' => { 'variant' => { '2' => 'Prog2',
                                                     '@' => 'Prog1' }}}
        }
    );
    # MOOD ####################
    # mood: wish-must case (dilek-şart kipi)
    $atoms{mood} = $self->create_simple_atom
    (
        'intfeature' => 'mood',
        'simple_decode_map' =>
        {
            # Pos|Imp|A2sg examples: var (be), gerek (need), bak (look), kapa (expand), anlat (tell)
            'Imp'   => 'imp',
            # Pos|Neces|A3sg examples: olmalı (should be), almalı (should buy), sağlamalı (should provide), kapsamalı (should cover)
            'Neces' => 'nec',
            # Optative mood (indicates a wish or hope). "May you have a long life! If only I were rich!"
            # Oflazer: "Let me/him/her do..." / "Kéž by ..."
            # Pos|Opt|A3sg examples: diye (if only said), sevine (if only exulted), güle (if only laughed), ola (if only were), otura (if only sat)
            'Opt'   => 'opt',
            ###!!! What's the difference between Desr and Cond?
            # Pos|Desr|A3sg examples: olsa (wants to be), ise, varsa, istese (if wanted), bıraksa (wants to leave)
            'Desr'  => 'des',
            # Pos|Aor|Cond|A3sg examples: verirse (if), isterse, kalırsa (if remains), başlarsa (if begins), derse
            # Pos|Fut|Cond|A3sg example: olacaksa (if will)
            # Pos|Narr|Cond|A3sg example: oturmuşsa
            # Pos|Past|Cond|A3sg example: olduysa (if (would have been)), uyuduysa
            # Pos|Prog1|Cond|A3sg examples: geliyorsa (would be coming), öpüyorsa, uyuşuyorsa, seviyorsa (would be loving)
            'Cond'  => 'cnd'
        }
    );
    # NEGATIVENESS ####################
    $atoms{negativeness} = $self->create_simple_atom
    (
        'intfeature' => 'negativeness',
        'simple_decode_map' =>
        {
            # Pos|Prog1|A3sg examples: diyor (is saying), geliyor (is coming), oluyor (is being), yapıyor (is doing), biliyor (is knowing)
            'Pos' => 'pos',
            # Neg|Prog1|A3sg examples: olmuyor (is not), tutmuyor (does not match), bilmiyor (does not know), gerekmiyor, benzemiyor
            'Neg' => 'neg'
        }
    );
    # VOICE ####################
    $atoms{voice} = $self->create_atom
    (
        'surfeature' => 'voice',
        'decode_map' =>
        {
            # Pass|Pos|Past|A3sg examples: belirtildi (was said), söylendi (was told), istendi (was asked), öğrenildi (was learned), kaldırıldı
            'Pass'   => ['voice' => 'pass'],
            # Reflex|Pos|Prog1|A3sg example: hazırlanıyor (is preparing itself)
            'Reflex' => ['reflex' => 'reflex'],
            # Recip|Pos|Past|A3sg example: karıştı (confused each other?)
            'Recip'  => ['voice' => 'rcp'],
            # Caus ... causative
            # Oflazer's documentation classifies this as a value of the voice feature.
            # Caus|Pos|Narr|A3sg examples: bastırmış (suppressed), bitirmiş (completed), oluşturmuş (created), çoğaltmış (multiplied), çıkartmış (issued)
            # Caus|Pos|Past|A3sg examples: belirtti (said), bildirdi (reported), uzattı (extended), indirdi (reduced), sürdürdü (continued)
            # Caus|Pos|Prog1|A3sg examples: karıştırıyor (is confusing), korkutuyor (is scaring), geçiriyor (is taking), koparıyor (is breaking), döktürüyor
            # Caus|Pos|Prog1|Past|A3sg examples: karıştırıyordu (was scooping), geçiriyordu (was giving), dolduruyordu (was filling), sürdürüyordu (was continuing), azaltıyordu (was diminishing)
            'Caus'   => ['voice' => 'cau']
        }
    );
    # COPULA ####################
    # Copula in Turkish is not an independent word. It is a bound morpheme (tur/tır/tir/dur etc.)
    # It is not clear to me though, what meaning it adds when attached to a verb.
    $atoms{copula} = $self->create_simple_atom
    (
        'intfeature' => 'verbtype',
        'simple_decode_map' =>
        {
            # Pos|Narr|Cop|A3sg examples: olmuştur (has been), açmıştır (has led), ulaşmıştır (has reached), başlamıştır, gelmiştir
            # Pos|Prog1|Cop|A3sg examples: oturuyordur (is sitting), öpüyordur (is kissing), tanıyordur (knows)
            # Pos|Fut|Cop|A3sg examples: olacaktır (will), akacaktır (will flow), alacaktır (will take), çarpacaktır, görecektir
            'Cop' => 'cop'
        }
    );
    return \%atoms;
}



#------------------------------------------------------------------------------
# Creates the list of all surface CoNLL features that can appear in the FEATS
# column. This list will be used in decode().
#------------------------------------------------------------------------------
sub _create_features_all
{
    my $self = shift;
    my @features = ('Degree', 'Gender', 'Animate', 'Number', 'Case',
                    'Definiteness', 'Formation', 'Form', 'Syntactic-Type', 'Clitic', 'Owner-Number', 'Owner-Gender', 'Referent-Type',
                    'VForm', 'Tense', 'Person', 'Negative', 'Voice');
    return \@features;
}



#------------------------------------------------------------------------------
# Creates the list of surface CoNLL features that can appear in the FEATS
# column with particular parts of speech. This list will be used in encode().
#------------------------------------------------------------------------------
sub _create_features_pos
{
    my $self = shift;
    my %features =
    (
        'Adjective-ordinal' => ['Degree', 'Gender', 'Number', 'Case', 'Animate'],
        'Adjective-possessive' => ['Degree', 'Gender', 'Number', 'Case', 'Animate'],
        'Adjective-qualificative' => ['Degree', 'Gender', 'Number', 'Case', 'Definiteness', 'Animate'],
        'Adposition-preposition' => ['Formation', 'Case'],
        'Adverb-general' => ['Degree'],
        'Conjunction-coordinating' => ['Formation'],
        'Conjunction-subordinating' => ['Formation'],
        'Noun-common' => ['Gender', 'Number', 'Case', 'Animate'],
        'Noun-proper' => ['Gender', 'Number', 'Case', 'Animate'],
        'Numeral-cardinal' => ['Gender', 'Number', 'Case', 'Form', 'Animate'],
        'Numeral-multiple' => ['Gender', 'Number', 'Case', 'Form'],
        'Numeral-ordinal' => ['Gender', 'Number', 'Case', 'Form', 'Animate'],
        'Numeral-special' => ['Gender', 'Number', 'Case', 'Form'],
        'Pronoun-demonstrative' => ['Gender', 'Number', 'Case', 'Syntactic-Type', 'Animate'],
        'Pronoun-general' => ['Gender', 'Number', 'Case', 'Syntactic-Type', 'Animate'],
        'Pronoun-indefinite' => ['Gender', 'Number', 'Case', 'Syntactic-Type', 'Animate'],
        'Pronoun-interrogative' => ['Gender', 'Number', 'Case', 'Syntactic-Type', 'Animate'],
        'Pronoun-negative' => ['Gender', 'Number', 'Case', 'Syntactic-Type', 'Animate'],
        'Pronoun-personal' => ['Person', 'Gender', 'Number', 'Case', 'Clitic', 'Syntactic-Type'],
        'Pronoun-possessive' => ['Person', 'Gender', 'Number', 'Case', 'Owner-Number', 'Owner-Gender', 'Syntactic-Type', 'Animate'],
        'Pronoun-reflexive' => ['Gender', 'Number', 'Case', 'Clitic', 'Referent-Type', 'Syntactic-Type'],
        'Pronoun-reflexive0' => ['Clitic'],
        'Pronoun-possessive-reflexive' => ['Gender', 'Number', 'Case', 'Referent-Type', 'Syntactic-Type', 'Animate'],
        'Pronoun-relative' => ['Gender', 'Number', 'Case', 'Syntactic-Type', 'Animate'],
        'Verb-copula' => ['VForm', 'Tense', 'Person', 'Number', 'Gender', 'Voice', 'Negative'],
        'Verb-main' => ['VForm', 'Tense', 'Person', 'Number', 'Gender', 'Voice', 'Negative'],
        'Verb-modal' => ['VForm', 'Tense', 'Person', 'Number', 'Gender', 'Voice', 'Negative']
    );
    return \%features;
}



#------------------------------------------------------------------------------
# Decodes a physical tag (string) and returns the corresponding feature
# structure.
#------------------------------------------------------------------------------
sub decode
{
    my $self = shift;
    my $tag = shift;
    my $fs = $self->decode_conll($tag);
    return $fs;
}



#------------------------------------------------------------------------------
# Takes feature structure and returns the corresponding physical tag (string).
#------------------------------------------------------------------------------
sub encode
{
    my $self = shift;
    my $fs = shift; # Lingua::Interset::FeatureStructure
    my $atoms = $self->atoms();
    my $subpos = $atoms->{pos}->encode($fs);
    my $pos = $subpos;
    $pos =~ s/-.*//;
    my $fpos = $subpos;
    if($fpos eq 'Pronoun-reflexive')
    {
        if($fs->is_possessive())
        {
            $fpos = 'Pronoun-possessive-reflexive';
        }
        elsif($fs->case() eq '')
        {
            $fpos = 'Pronoun-reflexive0';
        }
    }
    my $feature_names = $self->get_feature_names($fpos);
    my $tag = $self->encode_conll($fs, $pos, $subpos, $feature_names);
    # We cannot distinguish Adjective-ordinal and Adjective-qualificative without the 'other' feature.
    # If the feature is not available, we should make sure that we only generate valid tags.
    # We change all ordinal adjectives to qualificatives. But these should have the definiteness feature in certain contexts.
    $tag =~ s/(Adjective-qualificative\tDegree=positive\|Gender=masculine\|Number=singular\|Case=(nominative|accusative))(\|Animate=no$|$)/$1|Definiteness=yes$3/;
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# Tags were collected from the corpus, 766 distinct tags found.
#------------------------------------------------------------------------------
sub list
{
    my $self = shift;
    my $list = <<end_of_list
Abbreviation	Abbreviation	_
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=dual|Case=nominative
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=plural|Case=accusative
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=plural|Case=dative
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=plural|Case=genitive
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=plural|Case=instrumental
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=plural|Case=locative
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=plural|Case=nominative
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=singular|Case=accusative
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=singular|Case=dative
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=singular|Case=genitive
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=singular|Case=instrumental
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=singular|Case=locative
Adjective	Adjective-ordinal	Degree=positive|Gender=feminine|Number=singular|Case=nominative
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=dual|Case=nominative
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=plural|Case=accusative
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=plural|Case=genitive
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=plural|Case=instrumental
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=plural|Case=locative
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=plural|Case=nominative
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=singular|Case=accusative|Animate=no
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=singular|Case=accusative|Animate=yes
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=singular|Case=genitive
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=singular|Case=instrumental
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=singular|Case=locative
Adjective	Adjective-ordinal	Degree=positive|Gender=masculine|Number=singular|Case=nominative
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=plural|Case=accusative
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=plural|Case=genitive
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=plural|Case=instrumental
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=plural|Case=nominative
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=singular|Case=accusative
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=singular|Case=dative
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=singular|Case=genitive
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=singular|Case=instrumental
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=singular|Case=locative
Adjective	Adjective-ordinal	Degree=positive|Gender=neuter|Number=singular|Case=nominative
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=dual|Case=genitive
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=plural|Case=genitive
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=plural|Case=instrumental
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=plural|Case=locative
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=plural|Case=nominative
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=singular|Case=accusative
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=singular|Case=genitive
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=singular|Case=locative
Adjective	Adjective-possessive	Degree=positive|Gender=feminine|Number=singular|Case=nominative
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=plural|Case=accusative
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=plural|Case=genitive
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=plural|Case=locative
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=singular|Case=accusative|Animate=no
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=singular|Case=accusative|Animate=yes
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=singular|Case=dative
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=singular|Case=genitive
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=singular|Case=instrumental
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=singular|Case=locative
Adjective	Adjective-possessive	Degree=positive|Gender=masculine|Number=singular|Case=nominative
Adjective	Adjective-possessive	Degree=positive|Gender=neuter|Number=plural|Case=accusative
Adjective	Adjective-possessive	Degree=positive|Gender=neuter|Number=singular|Case=accusative
Adjective	Adjective-possessive	Degree=positive|Gender=neuter|Number=singular|Case=instrumental
Adjective	Adjective-possessive	Degree=positive|Gender=neuter|Number=singular|Case=nominative
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=plural|Case=accusative
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=plural|Case=instrumental
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=plural|Case=locative
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=plural|Case=nominative
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=singular|Case=accusative
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=singular|Case=dative
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=singular|Case=genitive
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=singular|Case=instrumental
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=singular|Case=locative
Adjective	Adjective-qualificative	Degree=comparative|Gender=feminine|Number=singular|Case=nominative
Adjective	Adjective-qualificative	Degree=comparative|Gender=masculine|Number=plural|Case=accusative
Adjective	Adjective-qualificative	Degree=comparative|Gender=masculine|Number=plural|Case=genitive
Adjective	Adjective-qualificative	Degree=comparative|Gender=masculine|Number=plural|Case=nominative
Adjective	Adjective-qualificative	Degree=comparative|Gender=masculine|Number=singular|Case=accusative|Animate=no
Adjective	Adjective-qualificative	Degree=comparative|Gender=masculine|Number=singular|Case=accusative|Animate=yes
Adjective	Adjective-qualificative	Degree=comparative|Gender=masculine|Number=singular|Case=genitive
Adjective	Adjective-qualificative	Degree=comparative|Gender=masculine|Number=singular|Case=locative
Adjective	Adjective-qualificative	Degree=comparative|Gender=masculine|Number=singular|Case=nominative
Adjective	Adjective-qualificative	Degree=comparative|Gender=neuter|Number=plural|Case=accusative
Adjective	Adjective-qualificative	Degree=comparative|Gender=neuter|Number=singular|Case=accusative
Adjective	Adjective-qualificative	Degree=comparative|Gender=neuter|Number=singular|Case=locative
Adjective	Adjective-qualificative	Degree=comparative|Gender=neuter|Number=singular|Case=nominative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=dual|Case=accusative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=dual|Case=nominative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=plural|Case=accusative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=plural|Case=dative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=plural|Case=genitive
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=plural|Case=instrumental
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=plural|Case=locative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=plural|Case=nominative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=singular|Case=accusative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=singular|Case=dative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=singular|Case=genitive
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=singular|Case=instrumental
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=singular|Case=locative
Adjective	Adjective-qualificative	Degree=positive|Gender=feminine|Number=singular|Case=nominative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=dual|Case=accusative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=dual|Case=genitive
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=dual|Case=instrumental
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=dual|Case=nominative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=plural|Case=accusative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=plural|Case=dative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=plural|Case=genitive
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=plural|Case=instrumental
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=plural|Case=locative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=plural|Case=nominative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=accusative|Animate=yes
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=accusative|Definiteness=no|Animate=no
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=accusative|Definiteness=yes|Animate=no
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=dative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=genitive
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=instrumental
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=locative
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=nominative|Definiteness=no
Adjective	Adjective-qualificative	Degree=positive|Gender=masculine|Number=singular|Case=nominative|Definiteness=yes
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=plural|Case=accusative
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=plural|Case=genitive
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=plural|Case=instrumental
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=plural|Case=locative
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=plural|Case=nominative
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=singular|Case=accusative
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=singular|Case=dative
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=singular|Case=genitive
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=singular|Case=instrumental
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=singular|Case=locative
Adjective	Adjective-qualificative	Degree=positive|Gender=neuter|Number=singular|Case=nominative
Adjective	Adjective-qualificative	Degree=superlative|Gender=feminine|Number=singular|Case=accusative
Adjective	Adjective-qualificative	Degree=superlative|Gender=feminine|Number=singular|Case=genitive
Adjective	Adjective-qualificative	Degree=superlative|Gender=feminine|Number=singular|Case=nominative
Adjective	Adjective-qualificative	Degree=superlative|Gender=masculine|Number=plural|Case=genitive
Adjective	Adjective-qualificative	Degree=superlative|Gender=masculine|Number=plural|Case=locative
Adjective	Adjective-qualificative	Degree=superlative|Gender=masculine|Number=singular|Case=accusative|Animate=no
Adjective	Adjective-qualificative	Degree=superlative|Gender=masculine|Number=singular|Case=genitive
Adjective	Adjective-qualificative	Degree=superlative|Gender=masculine|Number=singular|Case=locative
Adjective	Adjective-qualificative	Degree=superlative|Gender=masculine|Number=singular|Case=nominative
Adjective	Adjective-qualificative	Degree=superlative|Gender=neuter|Number=singular|Case=genitive
Adjective	Adjective-qualificative	Degree=superlative|Gender=neuter|Number=singular|Case=nominative
Adposition	Adposition-preposition	Formation=compound
Adposition	Adposition-preposition	Formation=simple|Case=accusative
Adposition	Adposition-preposition	Formation=simple|Case=dative
Adposition	Adposition-preposition	Formation=simple|Case=genitive
Adposition	Adposition-preposition	Formation=simple|Case=instrumental
Adposition	Adposition-preposition	Formation=simple|Case=locative
Adverb	Adverb-general	Degree=comparative
Adverb	Adverb-general	Degree=positive
Adverb	Adverb-general	Degree=superlative
Conjunction	Conjunction-coordinating	Formation=simple
Conjunction	Conjunction-subordinating	Formation=simple
Interjection	Interjection	_
Noun	Noun-common	Gender=feminine|Number=dual|Case=accusative
Noun	Noun-common	Gender=feminine|Number=dual|Case=genitive
Noun	Noun-common	Gender=feminine|Number=dual|Case=instrumental
Noun	Noun-common	Gender=feminine|Number=dual|Case=nominative
Noun	Noun-common	Gender=feminine|Number=plural|Case=accusative
Noun	Noun-common	Gender=feminine|Number=plural|Case=dative
Noun	Noun-common	Gender=feminine|Number=plural|Case=genitive
Noun	Noun-common	Gender=feminine|Number=plural|Case=instrumental
Noun	Noun-common	Gender=feminine|Number=plural|Case=locative
Noun	Noun-common	Gender=feminine|Number=plural|Case=nominative
Noun	Noun-common	Gender=feminine|Number=singular|Case=accusative
Noun	Noun-common	Gender=feminine|Number=singular|Case=dative
Noun	Noun-common	Gender=feminine|Number=singular|Case=genitive
Noun	Noun-common	Gender=feminine|Number=singular|Case=instrumental
Noun	Noun-common	Gender=feminine|Number=singular|Case=locative
Noun	Noun-common	Gender=feminine|Number=singular|Case=nominative
Noun	Noun-common	Gender=masculine|Number=dual|Case=accusative
Noun	Noun-common	Gender=masculine|Number=dual|Case=dative
Noun	Noun-common	Gender=masculine|Number=dual|Case=instrumental
Noun	Noun-common	Gender=masculine|Number=dual|Case=locative
Noun	Noun-common	Gender=masculine|Number=dual|Case=nominative
Noun	Noun-common	Gender=masculine|Number=plural|Case=accusative
Noun	Noun-common	Gender=masculine|Number=plural|Case=dative
Noun	Noun-common	Gender=masculine|Number=plural|Case=genitive
Noun	Noun-common	Gender=masculine|Number=plural|Case=instrumental
Noun	Noun-common	Gender=masculine|Number=plural|Case=locative
Noun	Noun-common	Gender=masculine|Number=plural|Case=nominative
Noun	Noun-common	Gender=masculine|Number=singular
Noun	Noun-common	Gender=masculine|Number=singular|Case=accusative|Animate=no
Noun	Noun-common	Gender=masculine|Number=singular|Case=accusative|Animate=yes
Noun	Noun-common	Gender=masculine|Number=singular|Case=dative
Noun	Noun-common	Gender=masculine|Number=singular|Case=genitive
Noun	Noun-common	Gender=masculine|Number=singular|Case=instrumental
Noun	Noun-common	Gender=masculine|Number=singular|Case=locative
Noun	Noun-common	Gender=masculine|Number=singular|Case=nominative
Noun	Noun-common	Gender=neuter|Number=dual|Case=accusative
Noun	Noun-common	Gender=neuter|Number=dual|Case=genitive
Noun	Noun-common	Gender=neuter|Number=dual|Case=locative
Noun	Noun-common	Gender=neuter|Number=dual|Case=nominative
Noun	Noun-common	Gender=neuter|Number=plural|Case=accusative
Noun	Noun-common	Gender=neuter|Number=plural|Case=dative
Noun	Noun-common	Gender=neuter|Number=plural|Case=genitive
Noun	Noun-common	Gender=neuter|Number=plural|Case=instrumental
Noun	Noun-common	Gender=neuter|Number=plural|Case=locative
Noun	Noun-common	Gender=neuter|Number=plural|Case=nominative
Noun	Noun-common	Gender=neuter|Number=singular|Case=accusative
Noun	Noun-common	Gender=neuter|Number=singular|Case=dative
Noun	Noun-common	Gender=neuter|Number=singular|Case=genitive
Noun	Noun-common	Gender=neuter|Number=singular|Case=instrumental
Noun	Noun-common	Gender=neuter|Number=singular|Case=locative
Noun	Noun-common	Gender=neuter|Number=singular|Case=nominative
Noun	Noun-proper	Gender=feminine|Number=singular|Case=accusative
Noun	Noun-proper	Gender=feminine|Number=singular|Case=genitive
Noun	Noun-proper	Gender=feminine|Number=singular|Case=instrumental
Noun	Noun-proper	Gender=feminine|Number=singular|Case=locative
Noun	Noun-proper	Gender=feminine|Number=singular|Case=nominative
Noun	Noun-proper	Gender=masculine|Number=plural|Case=genitive
Noun	Noun-proper	Gender=masculine|Number=singular|Case=accusative|Animate=no
Noun	Noun-proper	Gender=masculine|Number=singular|Case=accusative|Animate=yes
Noun	Noun-proper	Gender=masculine|Number=singular|Case=dative
Noun	Noun-proper	Gender=masculine|Number=singular|Case=genitive
Noun	Noun-proper	Gender=masculine|Number=singular|Case=instrumental
Noun	Noun-proper	Gender=masculine|Number=singular|Case=locative
Noun	Noun-proper	Gender=masculine|Number=singular|Case=nominative
Noun	Noun-proper	Gender=neuter|Number=singular|Case=genitive
Noun	Noun-proper	Gender=neuter|Number=singular|Case=locative
Numeral	Numeral-cardinal	Form=digit
Numeral	Numeral-cardinal	Gender=feminine|Number=dual|Case=accusative|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=dual|Case=genitive|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=dual|Case=instrumental|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=dual|Case=nominative|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=plural|Case=accusative|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=plural|Case=genitive|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=plural|Case=instrumental|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=plural|Case=locative|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=plural|Case=nominative|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=singular|Case=accusative|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=singular|Case=dative|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=singular|Case=genitive|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=singular|Case=instrumental|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=singular|Case=locative|Form=letter
Numeral	Numeral-cardinal	Gender=feminine|Number=singular|Case=nominative|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=dual|Case=accusative|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=dual|Case=instrumental|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=dual|Case=nominative|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=plural|Case=accusative|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=plural|Case=instrumental|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=plural|Case=locative|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=plural|Case=nominative|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=singular|Case=accusative|Form=letter|Animate=no
Numeral	Numeral-cardinal	Gender=masculine|Number=singular|Case=accusative|Form=letter|Animate=yes
Numeral	Numeral-cardinal	Gender=masculine|Number=singular|Case=genitive|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=singular|Case=instrumental|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=singular|Case=locative|Form=letter
Numeral	Numeral-cardinal	Gender=masculine|Number=singular|Case=nominative|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=dual|Case=accusative|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=dual|Case=genitive|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=dual|Case=locative|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=plural|Case=accusative|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=plural|Case=genitive|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=plural|Case=instrumental|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=plural|Case=locative|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=plural|Case=nominative|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=singular|Case=accusative|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=singular|Case=genitive|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=singular|Case=instrumental|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=singular|Case=locative|Form=letter
Numeral	Numeral-cardinal	Gender=neuter|Number=singular|Case=nominative|Form=letter
Numeral	Numeral-multiple	Gender=feminine|Number=singular|Case=instrumental|Form=letter
Numeral	Numeral-ordinal	Form=digit
Numeral	Numeral-ordinal	Gender=feminine|Number=plural|Case=accusative|Form=letter
Numeral	Numeral-ordinal	Gender=feminine|Number=plural|Case=genitive|Form=letter
Numeral	Numeral-ordinal	Gender=feminine|Number=singular|Case=accusative|Form=letter
Numeral	Numeral-ordinal	Gender=feminine|Number=singular|Case=genitive|Form=letter
Numeral	Numeral-ordinal	Gender=feminine|Number=singular|Case=locative|Form=letter
Numeral	Numeral-ordinal	Gender=feminine|Number=singular|Case=nominative|Form=letter
Numeral	Numeral-ordinal	Gender=masculine|Number=singular|Case=accusative|Form=letter|Animate=no
Numeral	Numeral-ordinal	Gender=masculine|Number=singular|Case=genitive|Form=letter
Numeral	Numeral-ordinal	Gender=masculine|Number=singular|Case=instrumental|Form=letter
Numeral	Numeral-ordinal	Gender=masculine|Number=singular|Case=locative|Form=letter
Numeral	Numeral-ordinal	Gender=masculine|Number=singular|Case=nominative|Form=letter
Numeral	Numeral-ordinal	Gender=neuter|Number=plural|Case=accusative|Form=letter
Numeral	Numeral-ordinal	Gender=neuter|Number=plural|Case=genitive|Form=letter
Numeral	Numeral-ordinal	Gender=neuter|Number=plural|Case=locative|Form=letter
Numeral	Numeral-ordinal	Gender=neuter|Number=singular|Case=accusative|Form=letter
Numeral	Numeral-ordinal	Gender=neuter|Number=singular|Case=genitive|Form=letter
Numeral	Numeral-ordinal	Gender=neuter|Number=singular|Case=instrumental|Form=letter
Numeral	Numeral-ordinal	Gender=neuter|Number=singular|Case=locative|Form=letter
Numeral	Numeral-ordinal	Gender=neuter|Number=singular|Case=nominative|Form=letter
Numeral	Numeral-special	Gender=feminine|Number=plural|Case=accusative|Form=letter
Numeral	Numeral-special	Gender=masculine|Number=singular|Case=locative|Form=letter
PUNC	PUNC	_
Particle	Particle	_
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=plural|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=plural|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=plural|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=singular|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=singular|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=singular|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=adjectival|Animate=yes
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=nominal|Animate=no
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=dative|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=masculine|Number=singular|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=dative|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=locative|Syntactic-Type=nominal
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-demonstrative	Gender=neuter|Number=singular|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Case=dative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=feminine|Number=dual|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=dual|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=feminine|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=plural|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=feminine|Number=plural|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=plural|Case=locative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=feminine|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=plural|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=locative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=dual|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=masculine|Number=dual|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=dual|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=masculine|Number=dual|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=masculine|Number=plural|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=masculine|Number=plural|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=plural|Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=masculine|Number=plural|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=adjectival|Animate=yes
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=nominal|Animate=no
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=masculine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=dual|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=neuter|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=dative|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-general	Gender=neuter|Number=singular|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Case=dative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=feminine|Number=dual|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=plural|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=dative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=masculine|Number=dual|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=plural|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=adjectival|Animate=yes
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=nominal|Animate=yes
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=locative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=masculine|Number=singular|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=neuter|Number=dual|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=neuter|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=neuter|Number=singular|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=neuter|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=neuter|Number=singular|Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Gender=neuter|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=neuter|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=neuter|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-indefinite	Gender=neuter|Number=singular|Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-indefinite	Syntactic-Type=adjectival
Pronoun	Pronoun-interrogative	Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-interrogative	Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-interrogative	Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-interrogative	Case=locative|Syntactic-Type=nominal
Pronoun	Pronoun-interrogative	Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-interrogative	Gender=feminine|Number=plural|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-interrogative	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-interrogative	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-interrogative	Gender=masculine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-interrogative	Gender=masculine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-interrogative	Gender=neuter|Number=plural|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-interrogative	Gender=neuter|Number=singular|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-interrogative	Gender=neuter|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-interrogative	Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-negative	Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-negative	Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-negative	Gender=feminine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=feminine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=masculine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=masculine|Number=singular|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=masculine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=masculine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=masculine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=neuter|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=neuter|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Gender=neuter|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-negative	Syntactic-Type=adjectival
Pronoun	Pronoun-personal	Person=first|Number=dual|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=plural|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=plural|Case=genitive|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=plural|Case=nominative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=singular|Case=accusative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=singular|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=singular|Case=dative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=singular|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=singular|Case=genitive|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=singular|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=first|Number=singular|Case=nominative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=plural|Case=accusative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=plural|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=plural|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=plural|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=plural|Case=nominative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=singular|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=singular|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=singular|Case=genitive|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=singular|Case=genitive|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=singular|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=singular|Case=locative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=second|Number=singular|Case=nominative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=dual|Case=accusative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=dual|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=dual|Case=genitive|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=dual|Case=nominative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=plural|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=plural|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=plural|Case=genitive|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=plural|Case=genitive|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=accusative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=dative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=genitive|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=genitive|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=locative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=feminine|Number=singular|Case=nominative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=dual|Case=accusative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=dual|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=dual|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=dual|Case=genitive|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=dual|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=plural|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=plural|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=plural|Case=genitive|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=plural|Case=genitive|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=plural|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=plural|Case=locative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=accusative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=dative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=dative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=genitive|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=genitive|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=locative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=masculine|Number=singular|Case=nominative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=neuter|Number=plural|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=neuter|Number=singular|Case=accusative|Clitic=yes|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=neuter|Number=singular|Case=instrumental|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-personal	Person=third|Gender=neuter|Number=singular|Case=locative|Clitic=no|Syntactic-Type=nominal
Pronoun	Pronoun-possessive	Person=first|Gender=feminine|Number=plural|Case=nominative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=feminine|Number=singular|Case=genitive|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=feminine|Number=singular|Case=genitive|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=feminine|Number=singular|Case=locative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=feminine|Number=singular|Case=nominative|Owner-Number=dual|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=feminine|Number=singular|Case=nominative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=feminine|Number=singular|Case=nominative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=masculine|Number=dual|Case=nominative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=masculine|Number=plural|Case=genitive|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=masculine|Number=plural|Case=locative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=masculine|Number=singular|Case=accusative|Owner-Number=dual|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-possessive	Person=first|Gender=masculine|Number=singular|Case=locative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=masculine|Number=singular|Case=nominative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=neuter|Number=plural|Case=accusative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=neuter|Number=plural|Case=nominative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=neuter|Number=singular|Case=locative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=first|Gender=neuter|Number=singular|Case=nominative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=feminine|Number=plural|Case=instrumental|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=feminine|Number=plural|Case=locative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=feminine|Number=singular|Case=accusative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=feminine|Number=singular|Case=locative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=feminine|Number=singular|Case=nominative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=masculine|Number=plural|Case=accusative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=masculine|Number=singular|Case=accusative|Owner-Number=singular|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-possessive	Person=second|Gender=masculine|Number=singular|Case=genitive|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=masculine|Number=singular|Case=locative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=masculine|Number=singular|Case=nominative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=neuter|Number=singular|Case=genitive|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=neuter|Number=singular|Case=locative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=second|Gender=neuter|Number=singular|Case=nominative|Owner-Number=singular|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=accusative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=accusative|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=accusative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=dative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=genitive|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=genitive|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=instrumental|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=locative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=nominative|Owner-Number=dual|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=nominative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=nominative|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=plural|Case=nominative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=accusative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=accusative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=dative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=genitive|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=genitive|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=genitive|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=instrumental|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=locative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=nominative|Owner-Number=dual|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=nominative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=nominative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=feminine|Number=singular|Case=nominative|Owner-Number=singular|Owner-Gender=neuter|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=dual|Case=locative|Owner-Number=dual|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=accusative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=genitive|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=genitive|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=genitive|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=instrumental|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=instrumental|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=locative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=locative|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=nominative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=nominative|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=plural|Case=nominative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=accusative|Owner-Number=dual|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=accusative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=genitive|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=genitive|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=genitive|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=instrumental|Owner-Number=dual|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=instrumental|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=locative|Owner-Number=dual|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=locative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=nominative|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=masculine|Number=singular|Case=nominative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=plural|Case=accusative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=plural|Case=accusative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=plural|Case=genitive|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=plural|Case=genitive|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=plural|Case=locative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=plural|Case=nominative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=plural|Case=nominative|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=plural|Case=nominative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=accusative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=accusative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=dative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=genitive|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=instrumental|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=locative|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=locative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=nominative|Owner-Number=plural|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=nominative|Owner-Number=singular|Owner-Gender=feminine|Syntactic-Type=adjectival
Pronoun	Pronoun-possessive	Person=third|Gender=neuter|Number=singular|Case=nominative|Owner-Number=singular|Owner-Gender=masculine|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Case=accusative|Clitic=no|Referent-Type=personal|Syntactic-Type=nominal
Pronoun	Pronoun-reflexive	Case=accusative|Clitic=yes|Referent-Type=personal|Syntactic-Type=nominal
Pronoun	Pronoun-reflexive	Case=dative|Clitic=no|Referent-Type=personal|Syntactic-Type=nominal
Pronoun	Pronoun-reflexive	Case=dative|Clitic=yes|Referent-Type=personal|Syntactic-Type=nominal
Pronoun	Pronoun-reflexive	Case=genitive|Clitic=no|Referent-Type=personal|Syntactic-Type=nominal
Pronoun	Pronoun-reflexive	Case=instrumental|Clitic=no|Referent-Type=personal|Syntactic-Type=nominal
Pronoun	Pronoun-reflexive	Case=locative|Clitic=no|Referent-Type=personal|Syntactic-Type=nominal
Pronoun	Pronoun-reflexive	Clitic=yes
Pronoun	Pronoun-reflexive	Gender=feminine|Number=plural|Case=accusative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=plural|Case=dative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=plural|Case=genitive|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=plural|Case=instrumental|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=plural|Case=locative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=singular|Case=accusative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=singular|Case=dative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=singular|Case=genitive|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=singular|Case=instrumental|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=feminine|Number=singular|Case=locative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=masculine|Number=plural|Case=accusative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=masculine|Number=plural|Case=genitive|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=masculine|Number=plural|Case=instrumental|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=masculine|Number=plural|Case=locative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=masculine|Number=singular|Case=accusative|Referent-Type=possessive|Syntactic-Type=adjectival|Animate=no
Pronoun	Pronoun-reflexive	Gender=masculine|Number=singular|Case=accusative|Referent-Type=possessive|Syntactic-Type=adjectival|Animate=yes
Pronoun	Pronoun-reflexive	Gender=masculine|Number=singular|Case=genitive|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=masculine|Number=singular|Case=instrumental|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=masculine|Number=singular|Case=locative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=neuter|Number=plural|Case=accusative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=neuter|Number=plural|Case=locative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=neuter|Number=singular|Case=accusative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=neuter|Number=singular|Case=genitive|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-reflexive	Gender=neuter|Number=singular|Case=locative|Referent-Type=possessive|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Case=accusative|Syntactic-Type=nominal
Pronoun	Pronoun-relative	Case=genitive|Syntactic-Type=nominal
Pronoun	Pronoun-relative	Case=instrumental|Syntactic-Type=nominal
Pronoun	Pronoun-relative	Case=locative|Syntactic-Type=nominal
Pronoun	Pronoun-relative	Case=nominative|Syntactic-Type=nominal
Pronoun	Pronoun-relative	Gender=feminine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=feminine|Number=plural|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=feminine|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=feminine|Number=singular|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=feminine|Number=singular|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=feminine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=feminine|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=feminine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=feminine|Number=singular|Case=nominative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=masculine|Number=plural|Case=accusative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=masculine|Number=plural|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=masculine|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=masculine|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=masculine|Number=singular|Case=accusative|Syntactic-Type=adjectival|Animate=yes
Pronoun	Pronoun-relative	Gender=masculine|Number=singular|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=masculine|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=masculine|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=masculine|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=neuter|Number=plural|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=neuter|Number=plural|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=neuter|Number=singular|Case=dative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=neuter|Number=singular|Case=genitive|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=neuter|Number=singular|Case=instrumental|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Gender=neuter|Number=singular|Case=locative|Syntactic-Type=adjectival
Pronoun	Pronoun-relative	Syntactic-Type=adjectival
Verb	Verb-copula	VForm=conditional
Verb	Verb-copula	VForm=indicative|Tense=future|Person=first|Number=dual
Verb	Verb-copula	VForm=indicative|Tense=future|Person=first|Number=plural
Verb	Verb-copula	VForm=indicative|Tense=future|Person=first|Number=singular
Verb	Verb-copula	VForm=indicative|Tense=future|Person=second|Number=plural
Verb	Verb-copula	VForm=indicative|Tense=future|Person=second|Number=singular
Verb	Verb-copula	VForm=indicative|Tense=future|Person=third|Number=dual
Verb	Verb-copula	VForm=indicative|Tense=future|Person=third|Number=plural
Verb	Verb-copula	VForm=indicative|Tense=future|Person=third|Number=singular
Verb	Verb-copula	VForm=indicative|Tense=present|Person=first|Number=dual|Negative=no
Verb	Verb-copula	VForm=indicative|Tense=present|Person=first|Number=plural|Negative=no
Verb	Verb-copula	VForm=indicative|Tense=present|Person=first|Number=plural|Negative=yes
Verb	Verb-copula	VForm=indicative|Tense=present|Person=first|Number=singular|Negative=no
Verb	Verb-copula	VForm=indicative|Tense=present|Person=first|Number=singular|Negative=yes
Verb	Verb-copula	VForm=indicative|Tense=present|Person=second|Number=plural|Negative=no
Verb	Verb-copula	VForm=indicative|Tense=present|Person=second|Number=singular|Negative=no
Verb	Verb-copula	VForm=indicative|Tense=present|Person=second|Number=singular|Negative=yes
Verb	Verb-copula	VForm=indicative|Tense=present|Person=third|Number=dual|Negative=no
Verb	Verb-copula	VForm=indicative|Tense=present|Person=third|Number=dual|Negative=yes
Verb	Verb-copula	VForm=indicative|Tense=present|Person=third|Number=plural|Negative=no
Verb	Verb-copula	VForm=indicative|Tense=present|Person=third|Number=plural|Negative=yes
Verb	Verb-copula	VForm=indicative|Tense=present|Person=third|Number=singular|Negative=no
Verb	Verb-copula	VForm=indicative|Tense=present|Person=third|Number=singular|Negative=yes
Verb	Verb-copula	VForm=participle|Tense=past|Number=dual|Gender=feminine|Voice=active
Verb	Verb-copula	VForm=participle|Tense=past|Number=dual|Gender=masculine|Voice=active
Verb	Verb-copula	VForm=participle|Tense=past|Number=dual|Gender=neuter|Voice=active
Verb	Verb-copula	VForm=participle|Tense=past|Number=plural|Gender=feminine|Voice=active
Verb	Verb-copula	VForm=participle|Tense=past|Number=plural|Gender=masculine|Voice=active
Verb	Verb-copula	VForm=participle|Tense=past|Number=plural|Gender=neuter|Voice=active
Verb	Verb-copula	VForm=participle|Tense=past|Number=singular|Gender=feminine|Voice=active
Verb	Verb-copula	VForm=participle|Tense=past|Number=singular|Gender=masculine|Voice=active
Verb	Verb-copula	VForm=participle|Tense=past|Number=singular|Gender=neuter|Voice=active
Verb	Verb-main	VForm=imperative|Tense=present|Person=first|Number=dual
Verb	Verb-main	VForm=imperative|Tense=present|Person=first|Number=plural
Verb	Verb-main	VForm=imperative|Tense=present|Person=second|Number=plural
Verb	Verb-main	VForm=imperative|Tense=present|Person=second|Number=singular
Verb	Verb-main	VForm=indicative|Tense=present|Person=first|Number=dual|Negative=no
Verb	Verb-main	VForm=indicative|Tense=present|Person=first|Number=plural|Negative=no
Verb	Verb-main	VForm=indicative|Tense=present|Person=first|Number=plural|Negative=yes
Verb	Verb-main	VForm=indicative|Tense=present|Person=first|Number=singular|Negative=no
Verb	Verb-main	VForm=indicative|Tense=present|Person=first|Number=singular|Negative=yes
Verb	Verb-main	VForm=indicative|Tense=present|Person=second|Number=plural|Negative=no
Verb	Verb-main	VForm=indicative|Tense=present|Person=second|Number=plural|Negative=yes
Verb	Verb-main	VForm=indicative|Tense=present|Person=second|Number=singular|Negative=no
Verb	Verb-main	VForm=indicative|Tense=present|Person=second|Number=singular|Negative=yes
Verb	Verb-main	VForm=indicative|Tense=present|Person=third|Number=dual|Negative=no
Verb	Verb-main	VForm=indicative|Tense=present|Person=third|Number=plural|Negative=no
Verb	Verb-main	VForm=indicative|Tense=present|Person=third|Number=singular|Negative=no
Verb	Verb-main	VForm=infinitive
Verb	Verb-main	VForm=participle|Number=dual|Gender=masculine|Voice=passive
Verb	Verb-main	VForm=participle|Number=dual|Gender=neuter|Voice=passive
Verb	Verb-main	VForm=participle|Number=plural|Gender=feminine|Voice=passive
Verb	Verb-main	VForm=participle|Number=plural|Gender=masculine|Voice=passive
Verb	Verb-main	VForm=participle|Number=plural|Gender=neuter|Voice=passive
Verb	Verb-main	VForm=participle|Number=singular|Gender=feminine|Voice=passive
Verb	Verb-main	VForm=participle|Number=singular|Gender=masculine|Voice=passive
Verb	Verb-main	VForm=participle|Number=singular|Gender=neuter|Voice=passive
Verb	Verb-main	VForm=participle|Tense=past|Number=dual|Gender=feminine|Voice=active
Verb	Verb-main	VForm=participle|Tense=past|Number=dual|Gender=masculine|Voice=active
Verb	Verb-main	VForm=participle|Tense=past|Number=plural|Gender=feminine|Voice=active
Verb	Verb-main	VForm=participle|Tense=past|Number=plural|Gender=masculine|Voice=active
Verb	Verb-main	VForm=participle|Tense=past|Number=plural|Gender=neuter|Voice=active
Verb	Verb-main	VForm=participle|Tense=past|Number=singular|Gender=feminine|Voice=active
Verb	Verb-main	VForm=participle|Tense=past|Number=singular|Gender=masculine|Voice=active
Verb	Verb-main	VForm=participle|Tense=past|Number=singular|Gender=neuter|Voice=active
Verb	Verb-main	VForm=supine
Verb	Verb-modal	VForm=indicative|Tense=present|Person=first|Number=plural|Negative=no
Verb	Verb-modal	VForm=indicative|Tense=present|Person=first|Number=singular|Negative=no
Verb	Verb-modal	VForm=indicative|Tense=present|Person=second|Number=plural|Negative=no
Verb	Verb-modal	VForm=indicative|Tense=present|Person=second|Number=singular|Negative=no
Verb	Verb-modal	VForm=indicative|Tense=present|Person=third|Number=dual|Negative=no
Verb	Verb-modal	VForm=indicative|Tense=present|Person=third|Number=plural|Negative=no
Verb	Verb-modal	VForm=indicative|Tense=present|Person=third|Number=singular|Negative=no
Verb	Verb-modal	VForm=participle|Number=plural|Gender=feminine|Voice=passive
Verb	Verb-modal	VForm=participle|Number=singular|Gender=neuter|Voice=passive
Verb	Verb-modal	VForm=participle|Tense=past|Number=plural|Gender=feminine|Voice=active
Verb	Verb-modal	VForm=participle|Tense=past|Number=plural|Gender=masculine|Voice=active
Verb	Verb-modal	VForm=participle|Tense=past|Number=singular|Gender=feminine|Voice=active
Verb	Verb-modal	VForm=participle|Tense=past|Number=singular|Gender=masculine|Voice=active
Verb	Verb-modal	VForm=participle|Tense=past|Number=singular|Gender=neuter|Voice=active
end_of_list
    ;
    # Protect from editors that replace tabs by spaces.
    $list =~ s/ \s+/\t/sg;
    my @list = split(/\r?\n/, $list);
    return \@list;
}



1;

=head1 SYNOPSIS

  use Lingua::Interset::Tagset::SL::Conll;
  my $driver = Lingua::Interset::Tagset::SL::Conll->new();
  my $fs = $driver->decode("Noun\tNoun-common\tGender=masculine|Number=singular|Case=nominative");

or

  use Lingua::Interset qw(decode);
  my $fs = decode('sl::conll', "Noun\tNoun-common\tGender=masculine|Number=singular|Case=nominative");

=head1 DESCRIPTION

Interset driver for the Slovene tagset of the CoNLL 2006 Shared Task.
CoNLL tagsets in Interset are traditionally three values separated by tabs.
The values come from the CoNLL columns CPOS, POS and FEAT. For Slovene,
these values are derived from the tagset of the Slovene Dependency Treebank.

=head1 SEE ALSO

L<Lingua::Interset>,
L<Lingua::Interset::Tagset>,
L<Lingua::Interset::Tagset::Conll>,
L<Lingua::Interset::FeatureStructure>

=cut
