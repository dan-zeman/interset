# ABSTRACT: Common code for drivers of tagsets of the Multext-EAST project.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset::Tagset::Multext;
use strict;
use warnings;
our $VERSION = '2.050';

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
extends 'Lingua::Interset::Tagset';



has 'atoms'       => ( isa => 'HashRef', is => 'ro', builder => '_create_atoms',       lazy => 1 );
has 'feature_map' => ( isa => 'HashRef', is => 'ro', builder => '_create_feature_map', lazy => 1 );



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
            # noun
            # examples: pán, hrad, žena, růže, město, moře
            'N' => ['pos' => 'noun'],
            # adjective
            # examples: mladý, jarní
            'A' => ['pos' => 'adj'],
            # pronoun
            # examples: já, ty, on, ona, ono, my, vy, oni, ony
            'P' => ['prontype' => 'prn'],
            # numeral
            # examples: jeden, dva, tři, čtyři, pět, šest, sedm, osm, devět, deset
            'M' => ['pos' => 'num'],
            # verb
            # examples: nese, bere, maže, peče, umře, tiskne, mine, začne, kryje, kupuje, prosí, trpí, sází, dělá
            'V' => ['pos' => 'verb'],
            # adverb
            # examples: kde, kam, kdy, jak, dnes, vesele
            'R' => ['pos' => 'adv'],
            # adposition
            # examples: v, pod, k
            'S' => ['pos' => 'adp', 'adpostype' => 'prep'],
            # conjunction
            # examples: a, i, ani, nebo, ale, avšak
            'C' => ['pos' => 'conj'],
            # particle
            # examples: ať, kéž, nechť
            'Q' => ['pos' => 'part'],
            # interjection
            # examples: haf, bum, bác
            'I' => ['pos' => 'int'],
            # abbreviation
            # examples: atd., apod.
            'Y' => ['abbr' => 'abbr'],
            # punctuation
            # examples: , .
            'Z' => ['pos' => 'punc'],
            # residual
            'X' => []
        },
        'encode_map' =>

            { 'abbr' => { 'abbr' => 'Y',
                          '@'    => { 'numtype' => { ''  => { 'pos' => { 'noun' => { 'prontype' => { ''  => 'N',
                                                                                                     '@' => 'P' }},
                                                                         'adj'  => { 'prontype' => { ''  => 'A',
                                                                                                     '@' => 'P' }},
                                                                         'num'  => 'M',
                                                                         'verb' => 'V',
                                                                         'adv'  => 'R',
                                                                         'adp'  => 'S',
                                                                         'conj' => 'C',
                                                                         'part' => 'Q',
                                                                         'int'  => 'I',
                                                                         'punc' => 'Z',
                                                                         '@'    => 'X' }},
                                                     '@' => 'M' }}}}
    );
    # NOUNTYPE ####################
    $atoms{nountype} = $self->create_simple_atom
    (
        'intfeature' => 'nountype',
        'simple_decode_map' =>
        {
            'c' => 'com',
            'p' => 'prop'
        }
    );
    # ADJTYPE ####################
    $atoms{adjtype} = $self->create_atom
    (
        'surfeature' => 'adjtype',
        'decode_map' =>
        {
            # qualificative adjective
            # examples: mladý, jarní
            'f' => [],
            # possessive adjective
            # examples: otcův, matčin
            's' => ['poss' => 'poss']
        },
        'encode_map' =>

            { 'poss' => { 'poss' => 's',
                           '@'   => 'f' }}
    );
    # PRONTYPE ####################
    $atoms{prontype} = $self->create_atom
    (
        'surfeature' => 'prontype',
        'decode_map' =>
        {
            # personal pronoun
            # examples: já, ty, on, ona, ono, my, vy, oni, ony
            'p' => ['pos' => 'noun', 'prontype' => 'prs'],
            # demonstrative pronoun
            # examples: ten, tento, tenhle, onen, takový, týž, tentýž, sám
            'd' => ['pos' => 'noun|adj', 'prontype' => 'dem'],
            # indefinite pronoun
            # examples: někdo, něco, nějaký, některý, něčí, leckdo, málokdo, kdokoli
            'i' => ['pos' => 'noun|adj', 'prontype' => 'ind'],
            # possessive pronoun
            # relative possessive pronouns ("jehož") are classified as relatives
            # examples: můj, tvůj, jeho, její, náš, váš, jejich
            's' => ['pos' => 'adj', 'prontype' => 'prs', 'poss' => 'poss'],
            # interrogative pronoun
            # examples: kdo, co, jaký, který, čí
            'q' => ['pos' => 'noun|adj', 'prontype' => 'int'],
            # relative pronoun
            # examples: kdo, co, jaký, který, čí, jenž
            'r' => ['pos' => 'noun|adj', 'prontype' => 'rel'],
            # reflexive pronoun (both personal and possessive reflexive pronouns fall here)
            # examples of personal reflexive pronouns: se, si, sebe, sobě, sebou
            # examples of possessive reflexive pronouns: svůj
            'x' => ['pos' => 'noun|adj', 'prontype' => 'prs', 'reflex' => 'reflex'],
            # negative pronoun
            # examples: nikdo, nic, nijaký, ničí, žádný
            'z' => ['pos' => 'noun|adj', 'prontype' => 'neg'],
            # general pronoun
            # examples: sám, samý, veškerý, všecko, všechno, všelicos, všelijaký, všeliký, všema
            # some of them also appear classified as indefinite pronouns
            # most of the above examples are clearly syntactic adjectives (determiners)
            # many (except of "sám" and "samý" are classified as totality pronouns in other tagsets)
            'g' => ['pos' => 'adj', 'prontype' => 'tot']
        },
        'encode_map' =>

            { 'reflex' => { 'reflex' => 'x',
                            '@'      => { 'poss' => { 'poss' => 's',
                                                      '@'    => { 'prontype' => { 'dem' => 'd',
                                                                                  'ind' => 'i',
                                                                                  'int' => 'q',
                                                                                  'rel' => 'r',
                                                                                  'neg' => 'z',
                                                                                  'tot' => 'g',
                                                                                  '@'   => 'p' }}}}}}
    );
    # NUMTYPE ####################
    $atoms{numtype} = $self->create_atom
    (
        'surfeature' => 'numtype',
        'decode_map' =>
        {
            # cardinal number
            # examples [cs]: jeden, dva, tři, čtyři, pět, šest, sedm, osm, devět, deset
            'c' => ['pos' => 'num', 'numtype' => 'card'],
            # ordinal number
            # examples [cs]: první, druhý, třetí, čtvrtý, pátý
            'o' => ['pos' => 'adj', 'numtype' => 'ord'],
            # pronominal numeral
            # examples [sl]: eden, en, drugi, drug
            # "en" ("one") could also be classified as a cardinal numeral but it is never tagged so.
            # "drugi" ("second" / "other") could also be classified as an ordinal numeral but is never tagged so.
            # These two have a catagory of their own because they also work as indefinite pronouns ("one man or the other").
            # Other pronominal numerals (in the sense of Interset, e.g. "how many") are not classified as pronominal in the Slovene Multext tagset!
            # Note that prontype=ind itself is not enough to distinguish this category because in other languages (e.g. Czech)
            # prontype is orthogonal to numtype (indefinite cardinal: "několik"; indefinite ordinal: "několikátý" etc.)
            # The only thing that makes these Slovene numerals different is the multivalue of numtype: card|ord.
            'p' => ['pos' => 'adj', 'numtype' => 'card|ord', 'prontype' => 'ind'],
            # multiplier number
            # examples [cs]: jednou, dvakrát, třikrát, čtyřikrát, pětkrát
            'm' => ['pos' => 'adv', 'numtype' => 'mult'],
            # special (generic) number (only Slavic languages?)
            # Czech term: číslovka druhová
            # Slovene term: števnik drugi
            # examples [cs]: desaterý, dvojí, jeden, několikerý, několikery, obojí
            # examples [sl]: dvojen, trojen
            's' => ['pos' => 'adj', 'numtype' => 'gen']
        },
        'encode_map' =>
        {
            'numtype' => { 'card|ord' => { 'prontype' => { 'ind' => 'p',
                                                           '@'   => 'c' }},
                           'card'     => 'c',
                           'ord'      => 'o',
                           'mult'     => 'm',
                           'gen'      => 's',
                           '@'        => 'c' }
        }
    );
    # VERBTYPE ####################
    $atoms{verbtype} = $self->create_atom
    (
        'surfeature' => 'verbtype',
        'decode_map' =>
        {
            # main verb
            # examples: absentovat, absolvovat, adaptovat, ...
            'm' => [],
            # auxiliary verb
            # examples: dostat, mít
            'a' => ['verbtype' => 'aux'],
            # modal verb
            # examples: chtít, dát, dávat, hodlat, moci, muset, lze, umět, zachtít
            'o' => ['verbtype' => 'mod'],
            # copula verb
            # examples: být, bývat, by
            'c' => ['verbtype' => 'cop']
        },
        'encode_map' =>

            { 'verbtype' => { 'aux' => 'a',
                              'mod' => 'o',
                              'cop' => 'c',
                              '@'   => 'm' }}
    );
    # CONJTYPE ####################
    $atoms{conjtype} = $self->create_simple_atom
    (
        'intfeature' => 'conjtype',
        'simple_decode_map' =>
        {
            # coordinating conjunction
            # examples: a, i, ani, nebo, ale
            'c' => 'coor',
            # subordinating conjunction
            # examples: že, zda, aby, protože
            's' => 'sub'
        }
    );
    # GENDER ####################
    $atoms{gender} = $self->create_simple_atom
    (
        'intfeature' => 'gender',
        'simple_decode_map' =>
        {
            'm' => 'masc',
            'f' => 'fem',
            'n' => 'neut'
        },
        'encode_default' => '-'
    );
    # NUMBER ####################
    $atoms{number} = $self->create_simple_atom
    (
        'intfeature' => 'number',
        'simple_decode_map' =>
        {
            's' => 'sing',
            'd' => 'dual',
            'p' => 'plur'
        },
        'encode_default' => '-'
    );
    # CASE ####################
    $atoms{case} = $self->create_simple_atom
    (
        'intfeature' => 'case',
        'simple_decode_map' =>
        {
            'n' => 'nom',
            'g' => 'gen',
            'd' => 'dat',
            'a' => 'acc',
            'v' => 'voc',
            'l' => 'loc',
            'i' => 'ins'
        },
        'encode_default' => '-'
    );
    # ANIMATENESS ####################
    $atoms{animateness} = $self->create_simple_atom
    (
        'intfeature' => 'animateness',
        'simple_decode_map' =>
        {
            'y' => 'anim',
            'n' => 'inan'
        },
        'encode_default' => '-'
    );
    # DEGREE ####################
    $atoms{degree} = $self->create_simple_atom
    (
        'intfeature' => 'degree',
        'simple_decode_map' =>
        {
            'p' => 'pos',
            'c' => 'cmp',
            's' => 'sup'
        },
        'encode_default' => '-'
    );
    # ADJECTIVE FORMATION ####################
    $atoms{adjform} = $self->create_atom
    (
        'surfeature' => 'adjform',
        'decode_map' =>
        {
            # Short form of adjective ("nominal form" = "jmenný tvar" in Czech)
            # Only a handful of adjectives have nominal forms that are still in use.
            # One adjective has only nominal form: "rád".
            # examples: mlád, stár, zdráv, nemocen
            'n' => ['variant' => 'short'],
            # Long (normal) form of adjective ("pronominal form" = "zájmenný tvar" in Czech)
            # examples: mladý, starý, zdravý, nemocný
            'c' => [],
            '-' => []  # possessive adjectives do not have two forms
        },
        'encode_map' =>

            { 'poss' => { 'poss' => '-',
                          '@'    => { 'variant' => { 'short' => 'n',
                                                     '@'     => 'c' }}}}
    );
    # DEFINITENESS ####################
    # Definiteness is defined only for adjectives in Croatian.
    # It distinguishes long and short forms of Slavic adjectives. In Czech, the "indefinite" form would be "jmenný tvar" (nominal form, as opposed to the long, pronominal form).
    $atoms{definiteness} = $self->create_simple_atom
    (
        'intfeature' => 'definiteness',
        'simple_decode_map' =>
        {
            'y' => 'def', # glavni, bivši, novi, prvi, turski
            'n' => 'ind'  # važan, velik, poznat, dobar, ključan
        }
    );
    # PERSON ####################
    $atoms{person} = $self->create_atom
    (
        'surfeature' => 'person',
        'decode_map' =>
        {
            '1' => ['person' => '1'],
            '2' => ['person' => '2'],
            '3' => ['person' => '3']
        },
        'encode_map' =>
            # Person of participles is undefined even if the attached clitic "-s" suggests the 2nd person.
            # Person of demonstrative and reflexive pronouns is undefined despite the attached clitic "-s".
            # Warning: This holds for Czech Multext tags but may not hold for other Multext-East tags!
            { 'verbform' => { 'part' => '-',
                              '@'    => { 'reflex' => { 'reflex' => '-',
                                                        '@'      => { 'prontype' => { 'dem' => '-',
                                                                                      '@'   => { 'person' => { '1' => '1',
                                                                                                               '2' => '2',
                                                                                                               '3' => '3',
                                                                                                               '@' => '-' }}}}}}}}
    );
    # OWNER NUMBER ####################
    $atoms{possnumber} = $self->create_simple_atom
    (
        'intfeature' => 'possnumber',
        'simple_decode_map' =>
        {
            's' => 'sing',
            'd' => 'dual',
            'p' => 'plur'
        },
        'encode_default' => '-'
    );
    # OWNER GENDER ####################
    $atoms{possgender} = $self->create_simple_atom
    (
        'intfeature' => 'possgender',
        'simple_decode_map' =>
        {
            'm' => 'masc',
            'f' => 'fem',
            'n' => 'neut'
        },
        'encode_default' => '-'
    );
    # IS PRONOUN CLITIC? ####################
    # clitic = yes for short forms of pronouns that behave like clitics (there exists a long form with identical meaning).
    # Examples: ho, mě, mi, mu, se, ses, si, sis, tě, ti
    # Long equivalents: jeho, mne, mně, jemu, sebe, sebe jsi, sobě, sobě jsi, tebe, tobě
    # Counterexamples: je, ně, tys
    $atoms{clitic} = $self->create_atom
    (
        'surfeature' => 'clitic',
        'decode_map' =>
        {
            'y' => ['variant' => 'short'],
            'n' => []
        },
        'encode_map' =>

            { 'variant' => { 'short' => 'y',
                             '@'     => 'n' }}
    );
    # IS REFLEXIVE PRONOUN POSSESSIVE? ####################
    # referent type distinguishes between reflexive personal and reflexive possessive pronouns
    # personal: sebe, sebou, se, ses, si, sis, sobě
    # possessive: svůj
    $atoms{referent_type} = $self->create_atom
    (
        'surfeature' => 'referent_type',
        'decode_map' =>
        {
            's' => ['reflex' => 'reflex', 'poss' => 'poss'],
            'p' => ['reflex' => 'reflex']
        },
        'encode_map' =>

            { 'reflex' => { 'reflex' => { 'poss' => { 'poss' => 's',
                                                      '@'    => 'p' }},
                            '@'      => '-' }}
    );
    # SYNTACTIC TYPE OF PRONOUN ####################
    # syntactic type: nominal or adjectival pronouns
    # nominal: který, co, cokoliv, cosi, což, copak, cože, on, jaký, jenž, kdekdo, kdo, já, něco, někdo, nic, nikdo, se, ty, žádný
    # adjectival: který, čí, čísi, jaký, jakýkoli, jakýkoliv, jakýsi, jeho, jenž, kdekterý, kterýkoli, kterýkoliv, kterýžto, málokterý, můj, nějaký, něčí, některý, ničí, onen, sám, samý, svůj, týž, tenhle, takýs, takovýto, ten, tento, tentýž, tenhleten, tvůj, veškerý, všecko, všechno, všelicos, všelijaký, všeliký, všema, žádný
    $atoms{syntactic_type} = $self->create_atom
    (
        'surfeature' => 'syntactic_type',
        'decode_map' =>
        {
            'n' => ['pos' => 'noun'],
            'a' => ['pos' => 'adj']
        },
        'encode_map' =>

            { 'pos' => { 'noun' => 'n',
                         'adj'  => 'a',
                         '@'    => '-' }}
    );
    # IS THERE AN ATTACHED CLITIC "-S" ("JSI")? ####################
    # clitic_s: Does it contain encliticized form of 2nd person of the auxiliary verb "být"?
    # There is no directly corresponding feature in the Interset.
    # Pronoun examples: ses, sis, tos, tys
    # "ses", "sis" and "tos" can be distinguished from "se", "si", "to" by setting person = '2'.
    # However, such a trick will not work for "tys" (as opposed to "ty": both are 2nd person).
    # Verb examples: slíbils, zapomněls, scvrnkls
    # In Czech this applies only to participles that normally do not set person.
    # Thus, setting person = '2' will distinguish these forms from the normal ones.
    $atoms{clitic_s} = $self->create_atom
    (
        'tagset'     => 'cs::multext',
        'surfeature' => 'clitic_s',
        'decode_map' =>
        {
            'y' => ['person' => '2', 'other' => {'clitic_s' => 'y'}],
            'n' => ['other' => {'clitic_s' => 'n'}]
        },
        # We cannot use encode_map for decisions based on the 'other' feature.
        # Custom code must be used instead of calling Atom::encode().
        'encode_map' =>

            { 'other/clitic_s' => { 'y' => 'y',
            # Clitic_s is obligatory for pronouns.
            # It is also obligatory for participles and infinitives (!) but not other verb forms.
                                    '@' => { 'prontype' => { ''  => { 'verbform' => { 'inf'  => 'n',
                                                                                      'part' => 'n',
                                                                                      '@'    => '-' }},
                                                             '@' => 'n' }}}}
    );
    # NUMERAL FORM ####################
    $atoms{numform} = $self->create_simple_atom
    (
        'intfeature' => 'numform',
        'simple_decode_map' =>
        {
            'd' => 'digit',
            'r' => 'roman',
            'l' => 'word'
        },
        'encode_default' => 'l'
    );
    # NUMERAL CLASS ####################
    $atoms{numclass} = $self->create_atom
    (
        'surfeature' => 'numclass',
        'decode_map' =>
        {
            # Definite other than 1, 2, 3, 4
            # Examples: 1929, čtrnáctý, čtyřiapadesát, dvoustý, tucet
            # This is the default class of numerals, so we do not have to set anything.
            'f' => [],
            # Definite1 examples: jeden, první
            '1' => ['numvalue' => '1'],
            # Definite2 examples: druhý, dvojí, dvojnásob, dva, nadvakrát, oba, obojí
            '2' => ['numvalue' => '2'],
            # Definite34 examples: čtvrtý, čtyři, potřetí, tři, třetí, třikrát
            '3' => ['numvalue' => '3'],
            # Demonstrative examples: tolik, tolikrát
            'd' => ['prontype' => 'dem'],
            # Indefinite examples: bezpočet, bezpočtukrát, bůhvíkolik, hodně, málo, mnohý, mockrát, několik, několikerý, několikrát, nejeden, pár, vícekrát
            'i' => ['prontype' => 'ind'],
            # Interrogative examples: kolik, kolikrát
            'q' => ['prontype' => 'int'],
            # Relative examples: kolik, kolikrát
            'r' => ['prontype' => 'rel']
        },
        'encode_map' =>

            { 'prontype' => { 'dem' => 'd',
                              'ind' => 'i',
                              'int' => 'q',
                              'rel' => 'r',
                              '@'   => { 'numvalue' => { '1' => '1',
                                                         '2' => '2',
                                                         '3' => '3',
                                                         '@' => 'f' }}}}
    );
    # VERB FORM ####################
    $atoms{verbform} = $self->create_atom
    (
        'surfeature' => 'verbform',
        'decode_map' =>
        {
            'i' => ['verbform' => 'fin', 'mood' => 'ind'],
            'm' => ['verbform' => 'fin', 'mood' => 'imp'],
            'c' => ['verbform' => 'fin', 'mood' => 'cnd'],
            'n' => ['verbform' => 'inf'],
            'p' => ['verbform' => 'part'],
            't' => ['verbform' => 'trans']
        },
        'encode_map' =>

            { 'mood' => { 'imp' => 'm',
                          'cnd' => 'c',
                          'ind' => 'i',
                          '@'   => { 'verbform' => { 'part'  => 'p',
                                                     'trans' => 't',
                                                     '@'     => 'n' }}}}
    );
    # ASPECT ####################
    $atoms{aspect} = $self->create_simple_atom
    (
        'intfeature' => 'aspect',
        'simple_decode_map' =>
        {
            'e' => 'perf',    # perfective
            'p' => 'imp',     # imperfective (this is called "progressive" in the Slovene tagset)
            'b' => 'imp|perf' # biaspectual (we do not use the empty value here because we need it for tags where aspect is '-')
        },
        'encode_default' => '-'
    );
    # TENSE ####################
    $atoms{tense} = $self->create_simple_atom
    (
        'intfeature' => 'tense',
        'simple_decode_map' =>
        {
            'p' => 'pres',
            'f' => 'fut',
            's' => 'past'
        },
        'encode_default' => '-'
    );
    # VOICE ####################
    $atoms{voice} = $self->create_simple_atom
    (
        'intfeature' => 'voice',
        'simple_decode_map' =>
        {
            'a' => 'act',
            'p' => 'pass'
        },
        'encode_default' => '-'
    );
    # NEGATIVENESS ####################
    $atoms{negativeness} = $self->create_simple_atom
    (
        'intfeature' => 'negativeness',
        'simple_decode_map' =>
        {
            'y' => 'neg',
            'n' => 'pos'
        },
        'encode_default' => '-'
    );
    # ADVERB TYPE ####################
    # Croatian distinguishes participial adverbs (or adverbial participles).
    # In Czech, the same category is classified as verbs (verbform = transgressive).
    ###!!! Note that the current solution does not convert Czech transgressives to Croatian participial adverbs and back!
    $atoms{adverb_type} = $self->create_atom
    (
        'surfeature' => 'adverb_type',
        'decode_map' =>
        {
            # general adverb
            # examples: također, međutim, još, samo, kada
            'g' => [],
            # participial adverb (= adverbial participle = transgressive in Czech!)
            # examples: uključujući, ističući, govoreći, dodajući, budući
            'r' => ['verbform' => 'trans']
        },
        'encode_map' =>

            { 'verbform' => { 'trans' => 'r',
                              'part'  => 'r',
                              '@'     => 'g' }}
    );
    # ADPOSITION TYPE ####################
    # Czech has only prepositions, no postpositions or circumpositions.
    # Nevertheless, this field must still be filled in because of compatibility with the other languages.
    $atoms{adpostype} = $self->create_atom
    (
        'surfeature' => 'adpostype',
        'decode_map' =>
        {
            'p' => ['adpostype' => 'prep']
        },
        'encode_map' =>

            { 'adpostype' => { '@' => 'p' }}
    );
    # ADPOSITION FORMATION ####################
    # formation = compound ("nač", "naň", "oč", "vzhledem", "zač", "zaň")
    # These should be classified as pronouns rather than prepositions.
    $atoms{adposition_formation} = $self->create_atom
    (
        'surfeature' => 'adposition_formation',
        'decode_map' =>
        {
            # Merged word form of a preposition and a pronoun.
            # Examples: oč, zač, nač, oň, zaň, naň
            'c' => ['adpostype' => 'preppron'],
            's' => []
        },
        'encode_map' =>

            { 'adpostype' => { 'preppron' => 'c',
                               '@'        => 's' }}
    );
    # PARTICLE TYPE ####################
    $atoms{parttype} = $self->create_atom
    (
        'surfeature' => 'parttype',
        'decode_map' =>
        {
            # affirmative particle
            # examples: da
            'r' => ['negativeness' => 'pos'],
            # negative particle
            # examples: ne
            'z' => ['negativeness' => 'neg'],
            # interrogative particle
            # examples: li, zar
            'q' => ['prontype' => 'int'],
            # modal particle
            # examples: sve, što, i, više, god, bilo
            'o' => ['parttype' => 'mod']
        },
        'encode_map' =>

            { 'negativeness' => { 'pos' => 'r',
                                  'neg' => 'z',
                                  '@'   => { 'prontype' => { 'int' => 'q',
                                                             '@'   => { 'parttype' => { 'mod' => 'o',
                                                                                        '@'   => '-' }}}}}}
    );
    # RESIDUAL TYPE ####################
    $atoms{restype} = $self->create_atom
    (
        'surfeature' => 'restype',
        'decode_map' =>
        {
            # foreign word
            # examples: a1, SETimes, European, bin, international
            'f' => ['foreign' => 'foreign'],
            # typo
            't' => ['typo' => 'typo'],
            # program
            # DZ: I am not sure what this value is supposed to mean. It is mentioned but not explained in the documentation.
            # It does not occur in the SETimes.HR corpus.
            'p' => []
        },
        'encode_map' =>

            { 'foreign' => { 'foreign' => 'f',
                             '@'       => { 'typo' => { 'typo' => 't',
                                                        '@'    => '-' }}}}
    );
    return \%atoms;
}



#------------------------------------------------------------------------------
# Creates a map that tells for each surface part of speech which features are
# relevant and in what order they appear.
#------------------------------------------------------------------------------
sub _create_feature_map
{
    my $self = shift;
    my %features =
    (
        # This method must be overridden in every Multext-EAST-based tagset because the lists of features vary across languages.
        # Declaring a feature as undef means that there will be always a dash at that position of the tag.
        # 'N' => ['pos', 'nountype', 'gender', 'number', 'case'],
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
    $fs->set_tagset($self->get_tagset_id());
    my $atoms = $self->atoms();
    my $features = $self->feature_map();
    my @chars = split(//, $tag);
    $atoms->{pos}->decode_and_merge_hard($chars[0], $fs);
    my @features;
    @features = @{$features->{$chars[0]}} if(defined($features->{$chars[0]}));
    for(my $i = 1; $i<=$#features; $i++)
    {
        if(defined($features[$i]) && defined($chars[$i]))
        {
            # Tagset drivers normally do not throw exceptions because they should be able to digest any input.
            # However, if we know we expect a feature and we have not defined an atom to handle that feature,
            # then it is an error of our code, not of the input data.
            if(!defined($atoms->{$features[$i]}))
            {
                confess("There is no atom to handle the feature '$features[$i]'");
            }
            $atoms->{$features[$i]}->decode_and_merge_hard($chars[$i], $fs);
        }
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
    my $features = $self->feature_map();
    my $tag = $atoms->{pos}->encode($fs);
    my @features;
    @features = @{$features->{$tag}} if(defined($features->{$tag}));
    for(my $i = 1; $i<=$#features; $i++)
    {
        if(defined($features[$i]))
        {
            # Tagset drivers normally do not throw exceptions because they should be able to digest any input.
            # However, if we know we expect a feature and we have not defined an atom to handle that feature,
            # then it is an error of our code, not of the input data.
            if(!defined($atoms->{$features[$i]}))
            {
                confess("There is no atom to handle the feature '$features[$i]'");
            }
            $tag .= $atoms->{$features[$i]}->encode($fs);
        }
        else
        {
            $tag .= '-';
        }
    }
    # Remove trailing dashes.
    $tag =~ s/-+$//;
    return $tag;
}



1;

=head1 SYNOPSIS

  package Lingua::Interset::Tagset::HR::Multext;
  extends 'Lingua::Interset::Tagset::Multext';

  # We must redefine the method that returns tagset identification, used by the
  # decode() method for the 'tagset' feature.
  sub get_tagset_id
  {
      # It should correspond to the last two parts in package name, lowercased.
      # Specifically, it should be the ISO 639-2 language code, followed by '::multext'.
      return 'hr::multext';
  }

  # We may add or redefine atoms for individual surface features.
  sub _create_atoms
  {
      my $self = shift;
      # Most atoms can be inherited but some have to be redefined.
      my $atoms = $self->SUPER::_create_atoms();
      $atoms->{verbform} = $self->create_atom (...);
      return $atoms;
  }

  # We must define the lists of surface features for all surface parts of speech!
  sub _create_feature_map
  {
      my $self = shift;
      my %features =
      (
          'N' => ['pos', 'nountype', 'gender', 'number', 'case', 'animateness'],
          ...
      );
      return \%features;
  }

  # We must define the list() method.
  sub list
  {
      my $self = shift;
      my $list = <<end_of_list
  Ncmsn
  Ncmsg
  Ncmsd
  ...
  end_of_list
      ;
      my @list = split(/\r?\n/, $list);
      return \@list;
  }

=head1 DESCRIPTION

Common code for drivers of tagsets of the Multext-EAST project.
All the Multext-EAST tagsets use the same inventory of parts of speech and the
same inventory of features (but not all features are used in all languages).
Feature values are individual alphanumeric characters and they are also
unified, thus if a feature value appears in several languages, it is always
encoded by the same character. The tagsets are positional, i.e. the position
of the value character in the tag determines the feature whose value this is.
The interpretation of the positions is defined separately for every language
and for every part of speech. Empty value (for unknown or irrelevant features)
is either encoded by a dash ("-"; if at least one of the following features has
a non-empty value) or is just omitted (at the end of the tag).

=head1 SEE ALSO

L<Lingua::Interset>,
L<Lingua::Interset::Tagset>,
L<Lingua::Interset::Tagset::CS::Multext>,
L<Lingua::Interset::Tagset::HR::Multext>,
L<Lingua::Interset::FeatureStructure>

=cut
