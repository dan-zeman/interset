# ABSTRACT: Driver for the Portuguese tagset of the CoNLL 2006 Shared Task (derived from the Bosque / Floresta sintá(c)tica treebank).
# Copyright © 2007-2009, 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset::Tagset::PT::Conll;
use strict;
use warnings;
our $VERSION = '2.037';

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
    return 'pt::conll';
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
            # n = common noun # example: revivalismo
            'n'         => ['pos' => 'noun', 'nountype' => 'com'],
            # prop = proper noun # example: Castro_Verde, João_Pedro_Henriques
            'prop'      => ['pos' => 'noun', 'nountype' => 'prop'],
            # adj = adjective # example: refrescante, algarvio
            'adj'       => ['pos' => 'adj'],
            # art = article # example: a, as, o, os, uma, um
            'art'       => ['pos' => 'adj', 'prontype' => 'art'],
            # pron-pers = personal # example: ela, elas, ele, eles, eu, nós, se, tu, você, vós
            'pron-pers' => ['pos' => 'noun', 'prontype' => 'prs'],
            # pron-det = determiner # example: algo, ambos, bastante, demais, este, menos, nosso, o, que, todo_o
            'pron-det'  => ['pos' => 'adj', 'prontype' => 'ind'],
            # pron-indp = independent # example: algo, aquilo, cada_qual, o, o_que, que, todo_o_mundo, um_pouco
            'pron-indp' => ['pos' => 'noun', 'prontype' => 'ind'],
            # num = number # example: 0,05, cento_e_quatro, cinco, setenta_e_dois, um, zero
            'num'       => ['pos' => 'num'],
            # v-inf = infinitive # example: abafar, abandonar, abastecer...
            'v-inf'     => ['pos' => 'verb', 'verbform' => 'inf'],
            # v-fin = finite # example: abafaram, abalou, abandonará...
            'v-fin'     => ['pos' => 'verb', 'verbform' => 'fin'],
            # v-pcp = participle # example: abafado, abalada, abandonadas...
            'v-pcp'     => ['pos' => 'verb', 'verbform' => 'part'],
            # v-ger = gerund # example: abraçando, abrindo, acabando...
            'v-ger'     => ['pos' => 'verb', 'verbform' => 'ger'],
            # vp = verb phrase # 1 occurrence in CoNLL 2006 data ("existente"), looks like an error
            'vp'        => ['pos' => 'adj', 'other' => {'pos' => 'vp'}],
            # adv = adverb # example: 20h45, abaixo, abertamente, a_bordo...
            'adv'       => ['pos' => 'adv'],
            # pp = prepositional phrase # example: ao_mesmo_tempo, de_acordo, por_último...
            'pp'        => ['pos' => 'adv', 'other' => {'pos' => 'pp'}],
            # prp = preposition # example: a, abaixo_de, ao, com, de, em, por, que...
            'prp'       => ['pos' => 'adp', 'adpostype' => 'prep'],
            # coordinating conjunction # example: e, mais, mas, nem, ou, quer, tampouco, tanto
            'conj-c'    => ['pos' => 'conj', 'conjtype' => 'coor'],
            # subordinating conjunction # example: a_fim_de_que, como, desde_que, para_que, que...
            'conj-s'    => ['pos' => 'conj', 'conjtype' => 'sub'],
            # in = interjection # example: adeus, ai, alô
            'in'        => ['pos' => 'int'],
            # ec = partial word # example: anti-, ex-, pós, pré-
            'ec'        => ['pos' => 'part', 'hyph' => 'hyph'],
            # punc = punctuation # example: --, -, ,, ;, :, !, ?:?...
            'punc'      => ['pos' => 'punc'],
            # ? = unknown # 2 occurrences in CoNLL 2006 data
            '?'         => [],
        },
        'encode_map' =>
        {
            'pos' => { 'noun' => { 'prontype' => { ''    => { 'nountype' => { 'prop' => 'prop',
                                                                              '@'    => 'n' }},
                                                   'prs' => 'pron-pers',
                                                   '@'   => 'pron-indp' }},
                       'adj'  => { 'prontype' => { ''    => { 'other/pos' => { 'vp' => 'vp',
                                                                               '@'  => 'adj' }},
                                                   'art' => 'art',
                                                   '@'   => 'pron-det' }},
                       'num'  => 'num',
                       'verb' => { 'verbform' => { 'inf'  => 'v-inf',
                                                   'fin'  => 'v-fin',
                                                   'part' => 'v-pcp',
                                                   'ger'  => 'v-ger' }},
                       'adv'  => { 'other/pos' => { 'pp' => 'pp',
                                                    '@'  => 'adv' }},
                       'adp'  => 'prp',
                       'conj' => { 'conjtype' => { 'sub' => 'conj-s',
                                                   '@'   => 'conj-c' }},
                       'part' => 'ec',
                       'int'  => 'in',
                       'punc' => 'punc',
                       'sym'  => 'punc',
                       '@'    => '?' }
        }
    );
    # ADJECTIVE TYPE ####################
    $atoms{adjtype} = $self->create_atom
    (
        'surfeature' => 'adjtype',
        'decode_map' =>
        {
            # adjective type (attr and zelfst applies to numerals and pronouns too)
            # adverbially used adjective
            # Example: "goed" in "Ben je al goed opgeschoten?" = "Have you done good progress?"
            # (goed, lang, erg, snel, zeker)
            'adv'    => ['variant' => 'short', 'other' => {'synpos' => 'adv'}],
            # attributively or predicatively used adjective
            # Example: "Dat huis is groot genoeg om in te verdwalen" = "The house is big enough to get lost in"
            # (groot, goed, bekend, nodig, vorig)
            'attr'   => ['other' => {'synpos' => 'attr'}],
            # independently used adjective
            # Example: "Antwoord in vloeiend Nederlands:" = "Response in fluent Dutch:"
            # (Nederlands, Frans, rood, groen, Engels)
            'zelfst' => ['other' => {'synpos' => 'self'}]
        },
        'encode_map' =>
        {
            'other/synpos' => { 'adv'  => 'adv',
                                'attr' => 'attr',
                                'self' => 'zelfst',
                                '@'    => { 'variant' => { 'short' => 'adv',
                                                           '@'     => { 'prontype' => { 'prs' => { 'poss' => { ''  => '',
                                                                                                               '@' => { 'number' => { 'plur' => 'zelfst',
                                                                                                                                      '@'    => 'attr' }}}},
                                                                                        'rcp' => '',
                                                                                        '@'   => { 'number' => { 'plur' => 'zelfst',
                                                                                                                 '@'    => 'attr' }}}}}}}
        }
    );
    # DEGREE ####################
    $atoms{degree} = $self->create_simple_atom
    (
        'intfeature' => 'degree',
        'simple_decode_map' =>
        {
            # degree of comparison (adjectives, adverbs and indefinite numerals (veel/weinig, meer/minder, meest/minst))
            # positive (goed, lang, erg, snel, zeker)
            'stell'  => 'pos',
            # comparative (verder, later, eerder, vroeger, beter)
            'vergr'  => 'comp',
            # superlative (best, grootst, kleinst, moeilijkst, mooist)
            'overtr' => 'sup'
        }
    );
    # ADJECTIVE FORM ####################
    # Applies also to indefinite numerals and verbal participles.
    $atoms{adjform} = $self->create_atom
    (
        'surfeature' => 'adjform',
        'decode_map' =>
        {
            'onverv'    => [], # uninflected (best, grootst, kleinst, moeilijkst, mooist)
            'vervneut'  => ['case' => 'nom'], # normal inflected form (mogelijke, ongelukkige, krachtige, denkbare, laatste)
            'vervgen'   => ['case' => 'gen'], # genitive form (bijzonders, goeds, nieuws, vreselijks, lekkerders)
            'vervmv'    => ['number' => 'plur'], # plural form (aanwezigen, religieuzen, Fransen, deskundigen, doden)
            'vervdat'   => ['case' => 'dat'], # dative form, verbs only, not found in corpus
            # comparative form of participles (occurs with "V", not with "Adj")
            # tegemoetkomender = more accommodating; overrompelender
            # vermoeider = more tired; verfijnder = more sophisticated
            'vervvergr' => ['degree' => 'comp']
        },
        'encode_map' =>
        {
            'pos' => { 'verb' => { 'degree' => { 'comp' => 'vervvergr',
                                                 '@'    => { 'verbform' => { 'part' => { 'number' => { 'plur' => 'vervmv',
                                                                                                       '@'    => { 'case' => { 'nom' => 'vervneut',
                                                                                                                               '@'   => 'onverv' }}}},
                                                                             '@'    => '' }}}},
                       '@'    => { 'number' => { 'plur' => 'vervmv',
                                                 '@'    => { 'case' => { 'nom' => 'vervneut',
                                                                         'gen' => 'vervgen',
                                                                         'dat' => 'vervdat',
                                                                         # The value 'onverv' occurs also with adverbs but only with those that have degree of comparison.
                                                                         # With adjectives the degree is also always present, hence we can check on it.
                                                                         # With numerals it occurs even without the degree.
                                                                         '@'   => { 'numtype' => { ''  => { 'degree' => { ''  => '',
                                                                                                                          '@' => 'onverv' }},
                                                                                                   '@' => 'onverv' }}}}}}}
        }
    );
    # ADVERB TYPE ####################
    $atoms{advtype} = $self->create_atom
    (
        'surfeature' => 'advtype',
        'decode_map' =>
        {
            # normal (zo, nu, dan, hier, altijd)
            # gew|aanw: zo = so; nu = now; dan = then; hier = here; altijd = always
            # gew|betr: hoe = how; waar = where; wanneer = when; waarom = why; hoeverre = to what extent
            # gew|er: er = there (existential: er is = there is)
            # gew|onbep: nooit = never; ooit = ever; ergens = somewhere; overal = everywhere; elders = elsewhere
            # gew|vrag: waar = where; vanwaar = where from; alwaar = where to
            # gew|geenfunc|stell|onverv: niet = not; nog = still; ook = also; wel = well; al = already
            # gew|geenfunc|vergr|onverv: meer = more; vaker = more often; dichter = more densely; dichterbij = closer
            # gew|geenfunc|overtr|onverv: meest = most
            'gew'     => ['other' => {'advtype' => 'gew'}],
            # pronominal (daar, daarna, waarin, waarbij)
            # pron|aanw: daar = there; daarna = then; daardoor = thereby; daarmee = therewith; daarop = thereon
            # pron|betr: waar = where; waaruit = whence; waaraan = whereat
            # pron|er: er = there (existential: er is = there is)
            # pron|onbep: ervan = whose; erop = on; erin; erover; ervoor = therefore
            # pron|vrag: waarin = wherein; waarbij = whereby; waarmee; waarop = whereupon; waardoor = whereby
            'pron'    => ['other' => {'advtype' => 'pron'}],
            # adverbial or prepositional part of separable (phrasal) verb (uit, op, aan, af, in)
            'deelv'   => ['parttype' => 'vbp', 'other' => {'advtype' => 'deelv'}],
            # prepositional part of separed pronominal adverb (van, voor, aan, op, mee)
            'deeladv' => ['parttype' => 'vbp', 'other' => {'advtype' => 'deeladv'}]
        },
        'encode_map' =>
        {
            'other/advtype' => { 'gew'     => 'gew',
                                 'pron'    => 'pron',
                                 'deelv'   => 'deelv',
                                 'deeladv' => 'deeladv',
                                 '@'       => { 'parttype' => { 'vbp' => 'deelv',
                                                                '@'   => { 'prontype' => { ''  => 'gew',
                                                                                           '@' => 'pron' }}}}}
        }
    );
    # FUNCTION OF NORMAL AND PRONOMINAL ADVERBS ####################
    $atoms{function} = $self->create_atom
    (
        'surfeature' => 'function',
        'decode_map' =>
        {
            'geenfunc' => [], # no function information (meest, niet, nog, ook, wel)
            'betr'     => ['prontype' => 'rel'], # relative pronoun or adverb (welke, die, dat, wat, wie, hoe, waar)
            'vrag'     => ['prontype' => 'int'], # interrogative pronoun or adverb (wat, wie, welke, welk, waar, dat, vanwaar)
            'aanw'     => ['prontype' => 'dem'], # demonstrative pronoun or adverb (deze, dit, die, dat, zo, nu, dan, daar, daardoor)
            'onbep'    => ['prontype' => 'ind'], # indefinite pronoun, numeral or adverb (geen, andere, alle, enkele, wat, minst, meest, nooit, ooit)
            'er'       => ['advtype'  => 'ex'] # the adverb 'er' (existential 'there'?)
        },
        'encode_map' =>
        {
            'prontype' => { 'rel' => 'betr',
                            'int' => 'vrag',
                            'dem' => 'aanw',
                            'ind' => 'onbep',
                            '@'   => { 'advtype' => { 'ex' => 'er',
                                                      '@'  => { 'parttype' => { 'vbp' => '',
                                                                                '@'   => 'geenfunc' }}}}}
        }
    );
    # DEFINITENESS ####################
    $atoms{definiteness} = $self->create_simple_atom
    (
        'intfeature' => 'definiteness',
        'simple_decode_map' =>
        {
            'bep'   => 'def', # (het, der, de, des, den)
            'onbep' => 'ind'  # (een)
        }
    );
    # GENDER OF ARTICLES ####################
    $atoms{gender} = $self->create_atom
    (
        'surfeature' => 'gender',
        'decode_map' =>
        {
            'zijd'         => ['gender' => 'com'], # non-neuter (den)
            'zijdofmv'     => [], # non-neuter gender or plural (de, der)
            'onzijd'       => ['gender' => 'neut'], # neuter (het)
            'zijdofonzijd' => ['number' => 'sing'], # both genders possible (des, een)
        },
        'encode_map' =>
        {
            'gender' => { 'com'  => 'zijd',
                          'neut' => 'onzijd',
                          '@'    => { 'number' => { 'sing' => 'zijdofonzijd',
                                                    '@'    => 'zijdofmv' }}}
        }
    );
    # CASE OF ARTICLES, PRONOUNS AND NOUNS ####################
    $atoms{case} = $self->create_atom
    (
        'surfeature' => 'case',
        'decode_map' =>
        {
            'neut'     => [], # no case (i.e. nominative or a word that does not take case markings) (het, de, een)
            'nom'      => ['case' => 'nom'], # nominative (only pronouns: ik, we, wij, u, je, jij, jullie, ze, zij, hij, het, ie, zijzelf)
            'gen'      => ['case' => 'gen'], # genitive (der, des)
            'dat'      => ['case' => 'dat'], # dative (den)
            'datofacc' => ['case' => 'dat|acc'], # dative or accusative (only pronouns: me, mij, ons, je, jou, jullie, ze, hem, haar, het, haarzelf, hen, hun)
            'acc'      => ['case' => 'acc'], # accusative (not found in the corpus, there is only 'datofacc')
        },
        'encode_map' =>
        {
            'case' => { 'nom'     => 'nom',
                        'gen'     => 'gen',
                        'acc|dat' => 'datofacc',
                        'dat'     => 'dat',
                        'acc'     => 'acc',
                        '@'       => { 'reflex' => { 'reflex' => '',
                                                     '@'      => 'neut' }}}
        }
    );
    # CONJUNCTION TYPE ####################
    $atoms{conjtype} = $self->create_atom
    (
        'surfeature' => 'conjtype',
        'decode_map' =>
        {
            'neven' => ['conjtype' => 'coor'], # coordinating (en, maar, of)
            'onder' => ['conjtype' => 'sub'] # subordinating (dat, als, dan, om, zonder, door)
        },
        'encode_map' =>
        {
            'conjtype' => { 'coor' => 'neven',
                            'sub'  => 'onder' }
        }
    );
    # SUBORDINATING CONJUNCTION TYPE ####################
    $atoms{sconjtype} = $self->create_atom
    (
        'surfeature' => 'sconjtype',
        'decode_map' =>
        {
            # followed by a finite clause (dat, als, dan, omdat)
            # Example: "ik hoop dat we tot een compromis kunnen komen" = "I hope that we can come to a compromise"
            'metfin' => ['other' => {'sconjtype' => 'fin'}],
            # followed by an infinite clause (om, zonder, door, teneinde)
            # Example: "Het was voor ons de kans om een ander Colombia te laten zien." = "It was for us a chance to show a different Colombia."
            'metinf' => ['other' => {'sconjtype' => 'inf'}]
        },
        'encode_map' =>
        {
            'other/sconjtype' => { 'inf' => 'metinf',
                                   'fin' => 'metfin',
                                   # This feature is required for all subordinating conjunctions.
                                   '@'   => { 'conjtype' => { 'sub' => 'metfin' }}}
        }
    );
    # NOUN TYPE ####################
    $atoms{nountype} = $self->create_simple_atom
    (
        'intfeature' => 'nountype',
        'simple_decode_map' =>
        {
            'soort' => 'com', # common noun is the default type of noun (jaar, heer, land, plaats, tijd)
            'eigen' => 'prop' # proper noun (Nederland, Amsterdam, zaterdag, Groningen, Rotterdam)
        }
    );
    # NUMBER ####################
    $atoms{number} = $self->create_atom
    (
        'surfeature' => 'number',
        'decode_map' =>
        {
            # enkelvoud (jaar, heer, land, plaats, tijd)
            'ev'     => ['number' => 'sing'],
            # meervoud (mensen, kinderen, jaren, problemen, landen)
            'mv'     => ['number' => 'plur'],
            # singular undistinguishable from plural (only pronouns: ze, zij, zich, zichzelf)
            'evofmv' => ['number' => 'sing|plur']
        },
        'encode_map' =>
        {
            'number' => { 'plur|sing' => 'evofmv',
                          'sing'      => 'ev',
                          'plur'      => 'mv' }
        }
    );
    # NUMERAL TYPE ####################
    $atoms{numtype} = $self->create_atom
    (
        'surfeature' => 'numtype',
        'decode_map' =>
        {
            'hoofd' => ['pos' => 'num', 'numtype' => 'card'], # hoofdtelwoord (twee, 1969, beider, minst, veel)
            'rang'  => ['pos' => 'adj', 'numtype' => 'ord'], # rangtelwoord (eerste, tweede, derde, vierde, vijfde)
        },
        'encode_map' =>
        {
            'numtype' => { 'card' => 'hoofd',
                           'ord'  => 'rang' }
        }
    );
    # MISCELLANEOUS TYPE ####################
    $atoms{misctype} = $self->create_atom
    (
        'surfeature' => 'misctype',
        'decode_map' =>
        {
            'afkort'  => ['abbr' => 'abbr'], # abbreviation
            'vreemd'  => ['foreign' => 'foreign'], # foreign expression
            'symbool' => ['pos' => 'sym'], # symbol not included in Punc
        },
        'encode_map' =>
        {
            'pos' => { 'sym' => 'symbool',
                       '@'   => { 'foreign' => { 'foreign' => 'vreemd',
                                                 '@'       => { 'abbr' => { 'abbr' => 'afkort' }}}}}
        }
    );
    # ADPOSITION TYPE ####################
    $atoms{adpostype} = $self->create_atom
    (
        'surfeature' => 'adpostype',
        'decode_map' =>
        {
            'voor'    => ['adpostype' => 'prep'], # preposition (voorzetsel) (van, in, op, met, voor)
            'achter'  => ['adpostype' => 'post'], # postposition (achterzetsel) (in, incluis, op)
            'comb'    => ['adpostype' => 'circ'], # second part of combined (split) preposition (toe, heen, af, in, uit) [van het begin af / from the beginning on: van/voor, af/comb]
            'voorinf' => ['parttype' => 'inf'] # infinitive marker (te)
        },
        'encode_map' =>
        {
            'parttype' => { 'inf' => 'voorinf',
                            '@'   => { 'adpostype' => { 'prep' => 'voor',
                                                        'post' => 'achter',
                                                        'circ' => 'comb' }}}
        }
    );
    # PRONOUN TYPE ####################
    $atoms{prontype} = $self->create_atom
    (
        'surfeature' => 'prontype',
        'decode_map' =>
        {
            'per'   => ['prontype' => 'prs'], # persoonlijk (me, ik, ons, we, je, u, jullie, ze, hem, hij, hen)
            'bez'   => ['prontype' => 'prs', 'poss' => 'poss'], # beztittelijk (mijn, onze, je, jullie, zijner, zijn, hun)
            'ref'   => ['prontype' => 'prs', 'reflex' => 'reflex'], # reflexief (me, mezelf, mij, ons, onszelf, je, jezelf, zich, zichzelf)
            'rec'   => ['prontype' => 'rcp'], # reciprook (elkaar, elkaars)
            'aanw'  => ['prontype' => 'dem'], # aanwijzend (deze, dit, die, dat)
            'betr'  => ['prontype' => 'rel'], # betrekkelijk (welk, die, dat, wat, wie)
            'vrag'  => ['prontype' => 'int'], # vragend (wie, wat, welke, welk)
            'onbep' => ['prontype' => 'ind|neg|tot'] # onbepaald (geen, andere, alle, enkele, wat)
        },
        'encode_map' =>
        {
            'prontype' => { 'prs' => { 'poss' => { 'poss' => 'bez',
                                                   '@'    => { 'reflex' => { 'reflex' => 'ref',
                                                                             '@'      => 'per' }}}},
                            'rcp' => 'rec',
                            'dem' => 'aanw',
                            'rel' => 'betr',
                            'int' => 'vrag',
                            'ind' => 'onbep',
                            'neg' => 'onbep',
                            'tot' => 'onbep' }
        }
    );
    # SPECIFIC PRONOUN ####################
    $atoms{pronoun} = $self->create_atom
    (
        'surfeature' => 'pronoun',
        'decode_map' =>
        {
            # eigen = own
            'weigen' => ['other' => {'pronoun' => 'eigen'}],
            # zelf = self
            'wzelf'  => ['other' => {'pronoun' => 'zelf'}]
        },
        'encode_map' =>
        {
            'other/pronoun' => { 'eigen' => 'weigen',
                                 'zelf'  => 'wzelf' }
        }
    );
    # PERSON ####################
    $atoms{person} = $self->create_atom
    (
        'surfeature' => 'person',
        'decode_map' =>
        {
            '1' => ['person' => '1'], # (mijn, onze, ons, me, mij, ik, we, mezelf, onszelf)
            '2' => ['person' => '2'], # (je, uw, jouw, jullie, jou, u, je, jij, jezelf)
            '3' => ['person' => '3'], # (zijner, zijn, haar, zijnen, zijne, hun, ze, zij, hem, het, hij, ie, zijzelf, zich, zichzelf)
            '1of2of3' => [], # person not marked; applies only to verbs in imperfect past (was, werd, heette; waren, werden, bleven) and plural imperfect present (zijn, worden, blijven)
        },
        'encode_map' =>
        {
            'person' => { '1' => '1',
                          '2' => '2',
                          '3' => '3',
                          '@' => { 'pos' => { 'verb' => { 'mood' => { 'ind' => '1of2of3' }}}}}
        }
    );
    # PUNCTUATION TYPE ####################
    $atoms{punctype} = $self->create_atom
    (
        'surfeature' => 'punctype',
        'decode_map' =>
        {
            'aanhaaldubb' => ['punctype' => 'quot'], # "
            'aanhaalenk'  => ['punctype' => 'quot', 'other' => {'punctype' => 'singlequot'}], # '
            'dubbpunt'    => ['punctype' => 'colo'], # :
            'en'          => ['pos' => 'sym', 'other' => {'symbol' => 'and'}], # &
            'gedstreep'   => ['punctype' => 'dash'], # -
            'haakopen'    => ['punctype' => 'brck', 'puncside' => 'ini'], # (
            'haaksluit'   => ['punctype' => 'brck', 'puncside' => 'fin'], # )
            'hellip'      => ['punctype' => 'peri', 'other' => {'punctype' => 'ellipsis'}], # ...
            'isgelijk'    => ['pos' => 'sym', 'other' => {'symbol' => 'equals'}], # =
            'komma'       => ['punctype' => 'comm'], # ,
            'liggstreep'  => ['pos' => 'sym', 'other' => {'symbol' => 'underscore'}], # -, _
            'maal'        => ['pos' => 'sym', 'other' => {'symbol' => 'times'}], # x
            'plus'        => ['pos' => 'sym', 'other' => {'symbol' => 'plus'}], # +
            'punt'        => ['punctype' => 'peri'], # .
            'puntkomma'   => ['punctype' => 'semi'], # ;
            'schuinstreep'=> ['pos' => 'sym', 'other' => {'symbol' => 'slash'}], # /
            'uitroep'     => ['punctype' => 'excl'], # !
            'vraag'       => ['punctype' => 'qest'], # ?
        },
        'encode_map' =>
        {
            'punctype' => { 'quot' => { 'other/punctype' => { 'singlequot' => 'aanhaalenk',
                                                              '@'          => 'aanhaaldubb' }},
                            'colo' => 'dubbpunt',
                            'dash' => 'gedstreep',
                            'brck' => { 'puncside' => { 'ini' => 'haakopen',
                                                        '@'   => 'haaksluit' }},
                            'comm' => 'komma',
                            'peri' => { 'other/punctype' => { 'ellipsis' => 'hellip',
                                                              '@'        => 'punt' }},
                            'semi' => 'puntkomma',
                            'excl' => 'uitroep',
                            'qest' => 'vraag',
                            '@'    => { 'other/symbol' => { 'and'        => 'en',
                                                            'equals'     => 'isgelijk',
                                                            'underscore' => 'liggstreep',
                                                            'times'      => 'maal',
                                                            'plus'       => 'plus',
                                                            'slash'      => 'schuinstreep',
                                                            '@'          => 'isgelijk' }}}
        }
    );
    # VERB TYPE ####################
    $atoms{verbtype} = $self->create_atom
    (
        'surfeature' => 'verbtype',
        'decode_map' =>
        {
            'trans'      => ['subcat' => 'tran'], # transitive (maken, zien, doen, nemen, geven)
            'refl'       => ['reflex' => 'reflex'], # reflexive (verzetten, ontwikkelen, voelen, optrekken, concentreren)
            'intrans'    => ['subcat' => 'intr'], # intransitive (komen, gaan, staan, vertrekken, spelen)
            'hulp'       => ['verbtype' => 'mod'], # auxiliary / modal (kunnen, moeten, hebben, gaan, laten)
            'hulpofkopp' => ['verbtype' => 'aux|cop'] # auxiliary or copula (worden, zijn, blijven, komen, wezen)
        },
        'encode_map' =>
        {
            'verbtype' => { 'aux' => 'hulpofkopp',
                            'cop' => 'hulpofkopp',
                            'mod' => 'hulp',
                            '@'   => { 'reflex' => { 'reflex' => 'refl',
                                                     '@'      => { 'subcat' => { 'tran' => 'trans',
                                                                                 'intr' => 'intrans' }}}}}
        }
    );
    # VERB FORM, MOOD, TENSE AND ASPECT ####################
    $atoms{verbform} = $self->create_atom
    (
        'surfeature' => 'verbform',
        'decode_map' =>
        {
            'ott'    => ['verbform' => 'fin', 'mood' => 'ind', 'aspect' => 'imp', 'tense' => 'pres'], # (komt, heet, gaat, ligt, staat)
            'ovt'    => ['verbform' => 'fin', 'mood' => 'ind', 'aspect' => 'imp', 'tense' => 'past'], # (kwam, ging, stond, viel, won)
            'tegdw'  => ['verbform' => 'part', 'tense' => 'pres'], # (volgend, verrassend, bevredigend, vervelend, aanvallend)
            'verldw' => ['verbform' => 'part', 'tense' => 'past'], # (afgelopen, gekomen, gegaan, gebeurd, begonnen)
            'inf'    => ['verbform' => 'inf'], # (komen, gaan, staan, vertrekken, spelen)
            'conj'   => ['verbform' => 'fin', 'mood' => 'sub'], # (leve, ware, inslape, oordele, zegge)
            'imp'    => ['verbform' => 'fin', 'mood' => 'imp'], # (kijk, kom, ga, denk, wacht)
        },
        'encode_map' =>
        {
            'verbform' => { 'inf'  => 'inf',
                            'fin'  => { 'mood' => { 'ind' => { 'tense' => { 'pres' => 'ott',
                                                                            'past' => 'ovt' }},
                                                    'sub' => 'conj',
                                                    'imp' => 'imp' }},
                            'part' => { 'tense' => { 'pres' => 'tegdw',
                                                     'past' => 'verldw' }}}
        }
    );
    # SUBSTANTIVAL USAGE OF INFINITIVE ####################
    $atoms{subst} = $self->create_atom
    (
        'surfeature' => 'subst',
        'decode_map' =>
        {
            # (worden, zijn, optreden, streven, dringen, maken, bereiken)
            'subst' => ['other' => {'infinitive' => 'subst'}]
        },
        'encode_map' =>
        {
            'other/infinitive' => { 'subst' => 'subst' }
        }
    );
    # MERGED ATOM TO DECODE ANY FEATURE VALUE ####################
    my @fatoms = map {$atoms{$_}} (@{$self->features_all()});
    $atoms{feature} = $self->create_merged_atom
    (
        'surfeature' => 'feature',
        'atoms'      => \@fatoms
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
    my @features = ('pos', 'adjtype', 'degree', 'adjform', 'advtype', 'function', 'definiteness', 'gender', 'case', 'conjtype', 'sconjtype', 'nountype', 'number',
                    'numtype', 'misctype', 'adpostype', 'prontype', 'pronoun', 'person', 'punctype', 'verbtype', 'verbform', 'subst');
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
        'Adj'   => ['adjtype', 'degree', 'adjform'],
        'Adv'   => ['advtype', 'function', 'degree', 'adjform'],
        'Art'   => ['definiteness', 'gender', 'case'],
        'Conj'  => ['conjtype', 'sconjtype'],
        'Misc'  => ['misctype'],
        'N'     => ['nountype', 'number', 'case'],
        'Num'   => ['numtype', 'definiteness', 'prontype', 'adjtype', 'degree', 'adjform'],
        'Prep'  => ['adpostype'],
        'Pron'  => ['prontype', 'person', 'number', 'case', 'adjtype', 'pronoun'],
        'Punc'  => ['punctype'],
        'V'     => ['verbtype', 'verbform', 'subst', 'person', 'number'],
        'Vpart' => ['verbtype', 'verbform', 'adjform']
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
    my $fs = Lingua::Interset::FeatureStructure->new();
    $fs->set_tagset('nl::conll');
    my $atoms = $self->atoms();
    # Three components, and the first two are identical: pos, pos, features.
    # example: N\tN\tsoort|ev|neut
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    # The underscore character is used if there are no features.
    $features = '' if($features eq '_');
    my @features = split(/\|/, $features);
    $atoms->{pos}->decode_and_merge_hard($subpos, $fs);
    foreach my $feature (@features)
    {
        $atoms->{feature}->decode_and_merge_hard($feature, $fs);
    }
    # The feature 'onbep' can mean indefinite pronoun or indefinite article.
    # If it is article, we want prontype=art, not prontype=ind.
    if($tag =~ m/^Art.*onbep/)
    {
        $fs->set('prontype', 'art');
        $fs->set('definiteness', 'ind');
    }
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
    my $fpos = $subpos;
    $fpos = 'Vpart' if($fpos eq 'V' && $fs->is_participle());
    my $feature_names = $self->get_feature_names($fpos);
    my $pos = $subpos;
    my $value_only = 1;
    my $tag = $self->encode_conll($fs, $pos, $subpos, $feature_names, $value_only);
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# Tags were collected from the corpus, 745 distinct tags found.
# MWU (multi-word-unit) tags were removed because they are sequences of normal
# tags and we cannot support them.
# Total 198 tags survived.
# Total 208 tags after adding missing tags (without the 'other' feature etc.)
#------------------------------------------------------------------------------
sub list
{
    my $self = shift;
    my $list = <<end_of_list
?	?	_
adj	adj	<ALT>|<SUP>|M|S
adj	adj	<ALT>|F|P
adj	adj	<ALT>|F|S
adj	adj	<ALT>|M|S
adj	adj	<DERP>|<DERS>|F|S
adj	adj	<DERP>|<n>|M|P
adj	adj	<DERP>|F|P
adj	adj	<DERP>|F|S
adj	adj	<DERP>|M|P
adj	adj	<DERP>|M|S
adj	adj	<DERS>|<n>|M|P
adj	adj	<DERS>|F|P
adj	adj	<DERS>|F|S
adj	adj	<DERS>|M|P
adj	adj	<DERS>|M|S
adj	adj	<KOMP>|F|P
adj	adj	<KOMP>|F|S
adj	adj	<KOMP>|M/F|S
adj	adj	<KOMP>|M|P
adj	adj	<KOMP>|M|S
adj	adj	<NUM-ord>|F|P
adj	adj	<NUM-ord>|F|S
adj	adj	<NUM-ord>|M/F|S
adj	adj	<NUM-ord>|M|P
adj	adj	<NUM-ord>|M|S
adj	adj	<SUP>|F|P
adj	adj	<SUP>|F|S
adj	adj	<SUP>|M|P
adj	adj	<SUP>|M|S
adj	adj	<error>|M|S
adj	adj	<hyfen>|F|P
adj	adj	<n>
adj	adj	<n>|<KOMP>|F|P
adj	adj	<n>|<KOMP>|F|S
adj	adj	<n>|<KOMP>|M|P
adj	adj	<n>|<KOMP>|M|S
adj	adj	<n>|<NUM-ord>|F|P
adj	adj	<n>|<NUM-ord>|F|S
adj	adj	<n>|<NUM-ord>|M|P
adj	adj	<n>|<NUM-ord>|M|S
adj	adj	<n>|<SUP>|F|P
adj	adj	<n>|<SUP>|F|S
adj	adj	<n>|<SUP>|M|P
adj	adj	<n>|<SUP>|M|S
adj	adj	<n>|F|P
adj	adj	<n>|F|S
adj	adj	<n>|M/F|P
adj	adj	<n>|M/F|S
adj	adj	<n>|M|P
adj	adj	<n>|M|S
adj	adj	<prop>|<NUM-ord>|M|S
adj	adj	<prop>|F|P
adj	adj	<prop>|F|S
adj	adj	<prop>|M/F|S
adj	adj	<prop>|M|P
adj	adj	<prop>|M|S
adj	adj	F|P
adj	adj	F|S
adj	adj	M/F|P
adj	adj	M/F|S
adj	adj	M/F|S/P
adj	adj	M|P
adj	adj	M|S
adj	adj	_
adv	adv	<-sam>
adv	adv	<ALT>
adv	adv	<DERP>|<DERS>
adv	adv	<DERS>
adv	adv	<KOMP>
adv	adv	<SUP>
adv	adv	<co-acc>
adv	adv	<co-advl>
adv	adv	<co-prparg>
adv	adv	<co-sc>
adv	adv	<dem>
adv	adv	<dem>|<quant>
adv	adv	<dem>|<quant>|<KOMP>
adv	adv	<error>
adv	adv	<foc>
adv	adv	<interr>
adv	adv	<interr>|<ks>
adv	adv	<interr>|<quant>
adv	adv	<kc>
adv	adv	<kc>|<-sam>
adv	adv	<kc>|<KOMP>
adv	adv	<kc>|<co-acc>
adv	adv	<kc>|<co-advl>
adv	adv	<kc>|<co-pass>
adv	adv	<kc>|<co-piv>
adv	adv	<kc>|<foc>
adv	adv	<ks>
adv	adv	<n>|<KOMP>
adv	adv	<prp>
adv	adv	<quant>
adv	adv	<quant>|<KOMP>
adv	adv	<quant>|<KOMP>|F|P
adv	adv	<quant>|<det>
adv	adv	<rel>
adv	adv	<rel>|<ks>
adv	adv	<rel>|<ks>|<quant>
adv	adv	<rel>|<prp>
adv	adv	<rel>|<prp>|<co-advl>
adv	adv	<rel>|<quant>
adv	adv	<sam->
adv	adv	F|S
adv	adv	M|P
adv	adv	M|S
adv	adv	_
art	art	<-sam>|<artd>|F|P
art	art	<-sam>|<artd>|F|S
art	art	<-sam>|<artd>|M|P
art	art	<-sam>|<artd>|M|S
art	art	<-sam>|<artd>|P
art	art	<-sam>|<artd>|S
art	art	<-sam>|<arti>|F|S
art	art	<-sam>|<arti>|M|S
art	art	<-sam>|F|P
art	art	<-sam>|F|S
art	art	<-sam>|M|S
art	art	<ALT>|<artd>|F|S
art	art	<ALT>|F|S
art	art	<artd>
art	art	<artd>|F|P
art	art	<artd>|F|S
art	art	<artd>|M|P
art	art	<artd>|M|S
art	art	<arti>|F|S
art	art	<arti>|M|S
art	art	<dem>|F|S
art	art	<dem>|M|S
art	art	<error>|<arti>|F|S
art	art	F|P
art	art	F|S
art	art	M|P
art	art	M|S
art	art	P
art	art	S
art	art	_
conj	conj-c	<co-acc>
conj	conj-c	<co-advl>
conj	conj-c	<co-advo>
conj	conj-c	<co-advs>
conj	conj-c	<co-app>
conj	conj-c	<co-fmc>
conj	conj-c	<co-ger>
conj	conj-c	<co-inf>
conj	conj-c	<co-inf>|<co-fmc>
conj	conj-c	<co-oc>
conj	conj-c	<co-pass>
conj	conj-c	<co-pcv>
conj	conj-c	<co-piv>
conj	conj-c	<co-postad>
conj	conj-c	<co-postnom>
conj	conj-c	<co-pred>
conj	conj-c	<co-prenom>
conj	conj-c	<co-prparg>
conj	conj-c	<co-sc>
conj	conj-c	<co-subj>
conj	conj-c	<co-vfin>
conj	conj-c	<co-vfin>|<co-fmc>
conj	conj-c	<fmc>
conj	conj-c	<quant>|<KOMP>
conj	conj-c	_
conj	conj-s	<co-prparg>
conj	conj-s	<kc>
conj	conj-s	<prp>
conj	conj-s	<rel>
conj	conj-s	_
ec	ec	_
in	in	F|S
in	in	M|S
in	in	PS|3S|IND
in	in	_
n	n	<ALT>|F|S
n	n	<ALT>|M|P
n	n	<ALT>|M|S
n	n	<DERP>|<DERS>|F|P
n	n	<DERP>|<DERS>|M|P
n	n	<DERP>|<DERS>|M|S
n	n	<DERP>|F|P
n	n	<DERP>|F|S
n	n	<DERP>|M|P
n	n	<DERP>|M|S
n	n	<DERS>|F|P
n	n	<DERS>|F|S
n	n	<DERS>|M|P
n	n	<DERS>|M|S
n	n	<NUM-ord>|F|S
n	n	<co-prparg>|M|P
n	n	<error>|F|P
n	n	<fmc>|F|S
n	n	<hyfen>|F|S
n	n	<hyfen>|M|P
n	n	<hyfen>|M|S
n	n	<n>|<NUM-ord>|F|S
n	n	<n>|M|P
n	n	<n>|M|S
n	n	<prop>|F|P
n	n	<prop>|F|S
n	n	<prop>|M/F|S
n	n	<prop>|M|P
n	n	<prop>|M|S
n	n	F
n	n	F|P
n	n	F|S
n	n	F|S/P
n	n	M/F|P
n	n	M/F|S
n	n	M|P
n	n	M|S
n	n	M|S/P
n	n	_
num	num	<-sam>|<card>|M|S
num	num	<-sam>|M|S
num	num	<ALT>|<card>|M|P
num	num	<card>|F|P
num	num	<card>|F|S
num	num	<card>|M/F|P
num	num	<card>|M/F|S
num	num	<card>|M|P
num	num	<card>|M|S
num	num	<card>|M|S/P
num	num	<n>|<card>|M|P
num	num	<n>|<card>|M|S
num	num	<n>|M|P
num	num	<prop>|<card>|F|P
num	num	<prop>|<card>|M|P
num	num	F|P
num	num	M/F|P
num	num	M|P
num	num	M|S
num	num	_
pp	pp	<sam->
pp	pp	F|S
pp	pp	_
pron	pron-det	<-sam>|<artd>|F|P
pron	pron-det	<-sam>|<artd>|F|S
pron	pron-det	<-sam>|<artd>|M|P
pron	pron-det	<-sam>|<artd>|M|S
pron	pron-det	<-sam>|<artd>|M|S/P
pron	pron-det	<-sam>|<arti>|F|S
pron	pron-det	<-sam>|<arti>|M|S
pron	pron-det	<-sam>|<dem>|F|P
pron	pron-det	<-sam>|<dem>|F|S
pron	pron-det	<-sam>|<dem>|M|P
pron	pron-det	<-sam>|<dem>|M|S
pron	pron-det	<-sam>|<diff>|F|P
pron	pron-det	<-sam>|<diff>|F|S
pron	pron-det	<-sam>|<diff>|M|P
pron	pron-det	<-sam>|<diff>|M|S
pron	pron-det	<-sam>|<quant>|F|P
pron	pron-det	<-sam>|<quant>|M|P
pron	pron-det	<-sam>|F|P
pron	pron-det	<-sam>|F|S
pron	pron-det	<-sam>|M|P
pron	pron-det	<-sam>|M|S
pron	pron-det	<KOMP>|F|P
pron	pron-det	<KOMP>|F|S
pron	pron-det	<KOMP>|M/F|S
pron	pron-det	<KOMP>|M|P
pron	pron-det	<KOMP>|M|S
pron	pron-det	<artd>|F|P
pron	pron-det	<artd>|F|S
pron	pron-det	<artd>|M|P
pron	pron-det	<artd>|M|S
pron	pron-det	<arti>|F|S
pron	pron-det	<arti>|M|S
pron	pron-det	<dem>|<KOMP>|F|P
pron	pron-det	<dem>|<KOMP>|M|P
pron	pron-det	<dem>|<foc>|M|S
pron	pron-det	<dem>|<quant>|F|S
pron	pron-det	<dem>|<quant>|M|S
pron	pron-det	<dem>|F|P
pron	pron-det	<dem>|F|S
pron	pron-det	<dem>|M|P
pron	pron-det	<dem>|M|S
pron	pron-det	<diff>|<KOMP>|F|P
pron	pron-det	<diff>|<KOMP>|F|S
pron	pron-det	<diff>|<KOMP>|M/F|S
pron	pron-det	<diff>|<KOMP>|M|P
pron	pron-det	<diff>|<KOMP>|M|S
pron	pron-det	<diff>|F|P
pron	pron-det	<diff>|F|S
pron	pron-det	<diff>|M/F|S
pron	pron-det	<diff>|M|P
pron	pron-det	<diff>|M|S
pron	pron-det	<ident>|F|P
pron	pron-det	<ident>|F|S
pron	pron-det	<ident>|M|P
pron	pron-det	<ident>|M|S
pron	pron-det	<interr>|<quant>|F|P
pron	pron-det	<interr>|<quant>|M|P
pron	pron-det	<interr>|<quant>|M|S
pron	pron-det	<interr>|F|P
pron	pron-det	<interr>|F|S
pron	pron-det	<interr>|M/F|S
pron	pron-det	<interr>|M/F|S/P
pron	pron-det	<interr>|M|P
pron	pron-det	<interr>|M|S
pron	pron-det	<n>|<dem>|M|S
pron	pron-det	<n>|<diff>|<KOMP>|F|S
pron	pron-det	<n>|<diff>|<KOMP>|M|P
pron	pron-det	<poss|1P>|F|P
pron	pron-det	<poss|1P>|F|S
pron	pron-det	<poss|1P>|M|P
pron	pron-det	<poss|1P>|M|S
pron	pron-det	<poss|1S>|F|P
pron	pron-det	<poss|1S>|F|S
pron	pron-det	<poss|1S>|M|P
pron	pron-det	<poss|1S>|M|S
pron	pron-det	<poss|2P>|F|S
pron	pron-det	<poss|2P>|M|S
pron	pron-det	<poss|2S>|M|S
pron	pron-det	<poss|3P>|<si>|F|P
pron	pron-det	<poss|3P>|<si>|F|S
pron	pron-det	<poss|3P>|<si>|M|P
pron	pron-det	<poss|3P>|<si>|M|S
pron	pron-det	<poss|3P>|F|S
pron	pron-det	<poss|3P>|M|P
pron	pron-det	<poss|3P>|M|S
pron	pron-det	<poss|3S/P>|<si>|F|S
pron	pron-det	<poss|3S/P>|<si>|M|S
pron	pron-det	<poss|3S/P>|F|S
pron	pron-det	<poss|3S/P>|M|P
pron	pron-det	<poss|3S>|<si>|F|P
pron	pron-det	<poss|3S>|<si>|F|S
pron	pron-det	<poss|3S>|<si>|M|P
pron	pron-det	<poss|3S>|<si>|M|S
pron	pron-det	<poss|3S>|F|P
pron	pron-det	<poss|3S>|F|S
pron	pron-det	<poss|3S>|M|P
pron	pron-det	<poss|3S>|M|S
pron	pron-det	<quant>
pron	pron-det	<quant>|<KOMP>|F|P
pron	pron-det	<quant>|<KOMP>|F|S
pron	pron-det	<quant>|<KOMP>|M/F|S/P
pron	pron-det	<quant>|<KOMP>|M|P
pron	pron-det	<quant>|<KOMP>|M|S
pron	pron-det	<quant>|<SUP>|M|S
pron	pron-det	<quant>|F|P
pron	pron-det	<quant>|F|S
pron	pron-det	<quant>|M/F|P
pron	pron-det	<quant>|M/F|S
pron	pron-det	<quant>|M/F|S/P
pron	pron-det	<quant>|M|P
pron	pron-det	<quant>|M|S
pron	pron-det	<rel>|F|P
pron	pron-det	<rel>|F|S
pron	pron-det	<rel>|M|P
pron	pron-det	<rel>|M|S
pron	pron-det	F|P
pron	pron-det	F|S
pron	pron-det	M/F|S
pron	pron-det	M|P
pron	pron-det	M|S
pron	pron-det	M|S/P
pron	pron-indp	<-sam>|<dem>|M|S
pron	pron-indp	<-sam>|<rel>|F|P
pron	pron-indp	<-sam>|<rel>|F|S
pron	pron-indp	<-sam>|<rel>|M|P
pron	pron-indp	<-sam>|<rel>|M|S
pron	pron-indp	<ALT>|<rel>|F|S
pron	pron-indp	<artd>|F|S
pron	pron-indp	<artd>|M|S
pron	pron-indp	<dem>|M/F|S/P
pron	pron-indp	<dem>|M|S
pron	pron-indp	<diff>|M|S
pron	pron-indp	<interr>|F|P
pron	pron-indp	<interr>|F|S
pron	pron-indp	<interr>|M/F|P
pron	pron-indp	<interr>|M/F|S
pron	pron-indp	<interr>|M/F|S/P
pron	pron-indp	<interr>|M|P
pron	pron-indp	<interr>|M|S
pron	pron-indp	<quant>
pron	pron-indp	<quant>|M/F|S
pron	pron-indp	<quant>|M|S
pron	pron-indp	<rel>
pron	pron-indp	<rel>|F|P
pron	pron-indp	<rel>|F|S
pron	pron-indp	<rel>|M/F|P
pron	pron-indp	<rel>|M/F|S
pron	pron-indp	<rel>|M/F|S/P
pron	pron-indp	<rel>|M|P
pron	pron-indp	<rel>|M|S
pron	pron-indp	F|S
pron	pron-indp	M/F|S
pron	pron-indp	M/F|S/P
pron	pron-indp	M|P
pron	pron-indp	M|S
pron	pron-indp	M|S/P
pron	pron-pers	<-sam>|<refl>|F|3S|PIV
pron	pron-pers	<-sam>|<refl>|M|3S|PIV
pron	pron-pers	<-sam>|F|1P|PIV
pron	pron-pers	<-sam>|F|1S|PIV
pron	pron-pers	<-sam>|F|3P|NOM
pron	pron-pers	<-sam>|F|3P|NOM/PIV
pron	pron-pers	<-sam>|F|3P|PIV
pron	pron-pers	<-sam>|F|3S|ACC
pron	pron-pers	<-sam>|F|3S|NOM/PIV
pron	pron-pers	<-sam>|F|3S|PIV
pron	pron-pers	<-sam>|M/F|2P|PIV
pron	pron-pers	<-sam>|M|3P|NOM
pron	pron-pers	<-sam>|M|3P|NOM/PIV
pron	pron-pers	<-sam>|M|3P|PIV
pron	pron-pers	<-sam>|M|3S|ACC
pron	pron-pers	<-sam>|M|3S|NOM
pron	pron-pers	<-sam>|M|3S|NOM/PIV
pron	pron-pers	<-sam>|M|3S|PIV
pron	pron-pers	<coll>|F|3P|ACC
pron	pron-pers	<coll>|M|3P|ACC
pron	pron-pers	<coll>|M|3S|ACC
pron	pron-pers	<hyfen>|<refl>|F|3S|ACC
pron	pron-pers	<hyfen>|<refl>|M/F|1S|DAT
pron	pron-pers	<hyfen>|F|3S|ACC
pron	pron-pers	<hyfen>|M/F|3S/P|ACC
pron	pron-pers	<hyfen>|M|3S|ACC
pron	pron-pers	<hyfen>|M|3S|DAT
pron	pron-pers	<reci>|F|3P|ACC
pron	pron-pers	<reci>|M|3P|ACC
pron	pron-pers	<refl>|<coll>|F|3P|ACC
pron	pron-pers	<refl>|<coll>|M/F|3P|ACC
pron	pron-pers	<refl>|<coll>|M|3P|ACC
pron	pron-pers	<refl>|<coll>|M|3S|ACC
pron	pron-pers	<refl>|F|1S|ACC
pron	pron-pers	<refl>|F|1S|DAT
pron	pron-pers	<refl>|F|3P|ACC
pron	pron-pers	<refl>|F|3S|ACC
pron	pron-pers	<refl>|F|3S|DAT
pron	pron-pers	<refl>|F|3S|PIV
pron	pron-pers	<refl>|M/F|1P|ACC
pron	pron-pers	<refl>|M/F|1P|ACC/DAT
pron	pron-pers	<refl>|M/F|1P|DAT
pron	pron-pers	<refl>|M/F|1S|ACC
pron	pron-pers	<refl>|M/F|1S|DAT
pron	pron-pers	<refl>|M/F|2P|DAT
pron	pron-pers	<refl>|M/F|3P|ACC
pron	pron-pers	<refl>|M/F|3S/P|ACC
pron	pron-pers	<refl>|M/F|3S/P|ACC/DAT
pron	pron-pers	<refl>|M/F|3S/P|DAT
pron	pron-pers	<refl>|M/F|3S/P|PIV
pron	pron-pers	<refl>|M/F|3S|ACC
pron	pron-pers	<refl>|M/F|3S|PIV
pron	pron-pers	<refl>|M|1P|ACC
pron	pron-pers	<refl>|M|1P|DAT
pron	pron-pers	<refl>|M|1S|ACC
pron	pron-pers	<refl>|M|1S|DAT
pron	pron-pers	<refl>|M|2S|ACC
pron	pron-pers	<refl>|M|3P|ACC
pron	pron-pers	<refl>|M|3P|DAT
pron	pron-pers	<refl>|M|3P|PIV
pron	pron-pers	<refl>|M|3S/P|ACC
pron	pron-pers	<refl>|M|3S|ACC
pron	pron-pers	<refl>|M|3S|DAT
pron	pron-pers	<refl>|M|3S|PIV
pron	pron-pers	<sam->|M/F|3S|DAT
pron	pron-pers	F|1P|NOM/PIV
pron	pron-pers	F|1P|PIV
pron	pron-pers	F|1S|ACC
pron	pron-pers	F|1S|NOM
pron	pron-pers	F|1S|PIV
pron	pron-pers	F|3P|ACC
pron	pron-pers	F|3P|DAT
pron	pron-pers	F|3P|NOM
pron	pron-pers	F|3P|NOM/PIV
pron	pron-pers	F|3P|PIV
pron	pron-pers	F|3S/P|ACC
pron	pron-pers	F|3S|ACC
pron	pron-pers	F|3S|DAT
pron	pron-pers	F|3S|NOM
pron	pron-pers	F|3S|NOM/PIV
pron	pron-pers	F|3S|PIV
pron	pron-pers	M/F|1P|ACC
pron	pron-pers	M/F|1P|DAT
pron	pron-pers	M/F|1P|NOM
pron	pron-pers	M/F|1P|NOM/PIV
pron	pron-pers	M/F|1P|PIV
pron	pron-pers	M/F|1S|ACC
pron	pron-pers	M/F|1S|DAT
pron	pron-pers	M/F|1S|NOM
pron	pron-pers	M/F|1S|PIV
pron	pron-pers	M/F|2P|ACC
pron	pron-pers	M/F|2P|NOM
pron	pron-pers	M/F|2P|PIV
pron	pron-pers	M/F|3P|ACC
pron	pron-pers	M/F|3P|DAT
pron	pron-pers	M/F|3P|NOM
pron	pron-pers	M/F|3S/P|ACC
pron	pron-pers	M/F|3S|ACC
pron	pron-pers	M/F|3S|DAT
pron	pron-pers	M/F|3S|NOM
pron	pron-pers	M/F|3S|NOM/PIV
pron	pron-pers	M|1P|ACC
pron	pron-pers	M|1P|DAT
pron	pron-pers	M|1P|NOM
pron	pron-pers	M|1P|NOM/PIV
pron	pron-pers	M|1S|ACC
pron	pron-pers	M|1S|DAT
pron	pron-pers	M|1S|NOM
pron	pron-pers	M|1S|PIV
pron	pron-pers	M|2S|ACC
pron	pron-pers	M|2S|PIV
pron	pron-pers	M|3P|ACC
pron	pron-pers	M|3P|DAT
pron	pron-pers	M|3P|NOM
pron	pron-pers	M|3P|NOM/PIV
pron	pron-pers	M|3P|PIV
pron	pron-pers	M|3S
pron	pron-pers	M|3S/P|ACC
pron	pron-pers	M|3S|ACC
pron	pron-pers	M|3S|DAT
pron	pron-pers	M|3S|NOM
pron	pron-pers	M|3S|NOM/PIV
pron	pron-pers	M|3S|PIV
prop	prop	<ALT>|F|S
prop	prop	<ALT>|M|S
prop	prop	<DERS>|M|S
prop	prop	<hyfen>|F|P
prop	prop	<hyfen>|F|S
prop	prop	<hyfen>|M|S
prop	prop	<prop>|F|S
prop	prop	<prop>|M|P
prop	prop	<prop>|M|S
prop	prop	F|P
prop	prop	F|S
prop	prop	M/F|P
prop	prop	M/F|S
prop	prop	M/F|S/P
prop	prop	M|P
prop	prop	M|S
prop	prop	_
prp	prp	<-sam>
prp	prp	<ALT>
prp	prp	<co-prparg>
prp	prp	<error>
prp	prp	<kc>
prp	prp	<kc>|<co-acc>
prp	prp	<kc>|<co-prparg>
prp	prp	<ks>
prp	prp	<quant>
prp	prp	<rel>
prp	prp	<rel>|<ks>
prp	prp	<rel>|<prp>
prp	prp	<sam->
prp	prp	<sam->|<co-acc>
prp	prp	<sam->|<kc>
prp	prp	F|S
prp	prp	M|S
prp	prp	_
punc	punc	_
v	v-fin	<ALT>|IMPF|3S|IND
v	v-fin	<ALT>|IMPF|3S|SUBJ
v	v-fin	<ALT>|PR|3S|IND
v	v-fin	<ALT>|PS|3S|IND
v	v-fin	<ALT>|PS|3S|SUBJ
v	v-fin	<DERP>|<DERS>|IMPF|3S|SUBJ
v	v-fin	<DERP>|PR|1S|IND
v	v-fin	<DERP>|PR|3P|IND
v	v-fin	<DERP>|PR|3S|IND
v	v-fin	<DERP>|PS|3S|IND
v	v-fin	<fmc>|PR|3S|SUBJ
v	v-fin	<hyfen>|<DERP>|PR|3S|IND
v	v-fin	<hyfen>|COND|1S
v	v-fin	<hyfen>|COND|3S
v	v-fin	<hyfen>|FUT|3S|IND
v	v-fin	<hyfen>|IMPF|1S|IND
v	v-fin	<hyfen>|IMPF|3P|IND
v	v-fin	<hyfen>|IMPF|3S|IND
v	v-fin	<hyfen>|MQP|1/3S|IND
v	v-fin	<hyfen>|MQP|3S|IND
v	v-fin	<hyfen>|PR|1/3S|SUBJ
v	v-fin	<hyfen>|PR|1P|IND
v	v-fin	<hyfen>|PR|1S|IND
v	v-fin	<hyfen>|PR|3P|IND
v	v-fin	<hyfen>|PR|3P|SUBJ
v	v-fin	<hyfen>|PR|3S|IND
v	v-fin	<hyfen>|PR|3S|SUBJ
v	v-fin	<hyfen>|PS/MQP|3P|IND
v	v-fin	<hyfen>|PS|1S|IND
v	v-fin	<hyfen>|PS|2S|IND
v	v-fin	<hyfen>|PS|3P|IND
v	v-fin	<hyfen>|PS|3S|IND
v	v-fin	<n>|PR|3S|IND
v	v-fin	<sam->|PR|3S|IND
v	v-fin	COND|1/3S
v	v-fin	COND|1P
v	v-fin	COND|1S
v	v-fin	COND|3P
v	v-fin	COND|3S
v	v-fin	FUT|1/3S|SUBJ
v	v-fin	FUT|1P|IND
v	v-fin	FUT|1P|SUBJ
v	v-fin	FUT|1S|IND
v	v-fin	FUT|1S|SUBJ
v	v-fin	FUT|2S|IND
v	v-fin	FUT|3P|IND
v	v-fin	FUT|3P|SUBJ
v	v-fin	FUT|3S|IND
v	v-fin	FUT|3S|SUBJ
v	v-fin	IMPF|1/3S|IND
v	v-fin	IMPF|1/3S|SUBJ
v	v-fin	IMPF|1P|IND
v	v-fin	IMPF|1P|SUBJ
v	v-fin	IMPF|1S|IND
v	v-fin	IMPF|1S|SUBJ
v	v-fin	IMPF|3P|IND
v	v-fin	IMPF|3P|SUBJ
v	v-fin	IMPF|3S|IND
v	v-fin	IMPF|3S|SUBJ
v	v-fin	IMP|2S
v	v-fin	MQP|1/3S|IND
v	v-fin	MQP|1S|IND
v	v-fin	MQP|3P|IND
v	v-fin	MQP|3S|IND
v	v-fin	PR/PS|1P|IND
v	v-fin	PR|1/3S|SUBJ
v	v-fin	PR|1P|IND
v	v-fin	PR|1P|SUBJ
v	v-fin	PR|1S|IND
v	v-fin	PR|1S|SUBJ
v	v-fin	PR|2P|IND
v	v-fin	PR|2S|IND
v	v-fin	PR|2S|SUBJ
v	v-fin	PR|3P|IND
v	v-fin	PR|3P|SUBJ
v	v-fin	PR|3S
v	v-fin	PR|3S|IND
v	v-fin	PR|3S|SUBJ
v	v-fin	PS/MQP|3P|IND
v	v-fin	PS|1/3S|IND
v	v-fin	PS|1P|IND
v	v-fin	PS|1S|IND
v	v-fin	PS|2S|IND
v	v-fin	PS|3P|IND
v	v-fin	PS|3S|IND
v	v-fin	_
v	v-ger	<ALT>
v	v-ger	<hyfen>
v	v-ger	_
v	v-inf	1/3S
v	v-inf	1P
v	v-inf	1S
v	v-inf	3P
v	v-inf	3S
v	v-inf	<DERP>
v	v-inf	<DERS>
v	v-inf	<hyfen>
v	v-inf	<hyfen>|1S
v	v-inf	<hyfen>|3P
v	v-inf	<hyfen>|3S
v	v-inf	<n>
v	v-inf	<n>|3S
v	v-inf	FUT|3S|IND
v	v-inf	_
v	v-pcp	<ALT>|F|S
v	v-pcp	<DERP>|<DERS>|M|S
v	v-pcp	<DERP>|M|P
v	v-pcp	<DERS>|F|P
v	v-pcp	<DERS>|M|S
v	v-pcp	<n>|F|P
v	v-pcp	<n>|F|S
v	v-pcp	<n>|M|P
v	v-pcp	<n>|M|S
v	v-pcp	<prop>|F|S
v	v-pcp	<prop>|M|P
v	v-pcp	F|P
v	v-pcp	F|S
v	v-pcp	M|P
v	v-pcp	M|S
v	v-pcp	_
end_of_list
    ;
    # Protect from editors that replace tabs by spaces.
    $list =~ s/ \s+/\t/sg;
    my @list = split(/\r?\n/, $list);
    return \@list;
}



1;

=head1 SYNOPSIS

  use Lingua::Interset::Tagset::PT::Conll;
  my $driver = Lingua::Interset::Tagset::PT::Conll->new();
  my $fs = $driver->decode("n\tn\tM|S");

or

  use Lingua::Interset qw(decode);
  my $fs = decode('pt::conll', "n\tn\tM|S");

=head1 DESCRIPTION

Interset driver for the Portuguese tagset of the CoNLL 2006 Shared Task.
CoNLL tagsets in Interset are traditionally three values separated by tabs.
The values come from the CoNLL columns CPOS, POS and FEAT. For Portuguese,
these values are derived from the tagset of the Bosque treebank (part of Floresta sintá(c)tica).

=head1 SEE ALSO

L<Lingua::Interset>,
L<Lingua::Interset::Tagset>,
L<Lingua::Interset::Tagset::Conll>,
L<Lingua::Interset::FeatureStructure>

=cut
