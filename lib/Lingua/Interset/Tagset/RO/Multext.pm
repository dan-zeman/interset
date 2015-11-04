# ABSTRACT: Driver for the Romanian tagset of the Multext-EAST v4 project.
# http://nl.ijs.si/ME/V4/msd/html/msd-ro.html
# Copyright © 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset::Tagset::RO::Multext;
use strict;
use warnings;
our $VERSION = '2.051';

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
extends 'Lingua::Interset::Tagset::Multext';



#------------------------------------------------------------------------------
# Returns the tagset id that should be set as the value of the 'tagset' feature
# during decoding. Every derived class must (re)define this method! The result
# should correspond to the last two parts in package name, lowercased.
# Specifically, it should be the ISO 639-2 language code, followed by
# '::multext'. Example: 'cs::multext'.
#------------------------------------------------------------------------------
sub get_tagset_id
{
    return 'ro::multext';
}



#------------------------------------------------------------------------------
# Creates atomic drivers for surface features.
#------------------------------------------------------------------------------
sub _create_atoms
{
    my $self = shift;
    # Most atoms can be inherited but some have to be redefined.
    my $atoms = $self->SUPER::_create_atoms();
    # PART OF SPEECH ####################
    # The default Multext POS atom is suitable for Slavic languages. It does not distinguish determiners and articles.
    # We have to use this modified atom for Romanian.
    $atoms->{pos} = $self->create_atom
    (
        'surfeature' => 'pos',
        'decode_map' =>
        {
            # noun
            # examples: număr, oraș, loc, punct, protocol
            'N' => ['pos' => 'noun'],
            # adjective
            # examples: național, român, nou, internațional, bun
            'A' => ['pos' => 'adj'],
            # pronoun
            # examples: eu, tu, el, ea, noi, voi, ei, ele
            'P' => ['pos' => 'noun', 'prontype' => 'prn'],
            # determiner
            # examples: meu, lui, acest, acel, mult
            'D' => ['pos' => 'adj', 'prontype' => 'prn'],
            # article
            # indefinite article: un, o
            # definite article (separated affix): -ul, -a
            # demonstrative article: cel, cea, cei, cele
            # possessive article: al, a, ai, ale
            # Since there are demonstrative articles and we have to distinguish them from demonstrative determiners, we must set 'other/prontype'.
            'T' => ['pos' => 'adj', 'prontype' => 'art', 'other' => {'prontype' => 'art'}],
            # numeral
            # examples: doi, trei, patru, cinci, șase, șapte, opt, nouă, zece
            'M' => ['pos' => 'num'],
            # entity; used mostly for numbers expressed in digits; not documented at the Multext-East website
            # examples: 1916, miliarde_de_lei, 58_%, 3, 99-06, mg
            # Ed = a few abbreviations of names, usually just 1 occurrence: mg, A., nr., U.E., N.
            # Eii = interval, only two occurrences: 99-06, 1908-1909
            # Eni = number (usually) written using digits: 3, 20, 50, 2, 24
            #       These numbers do not denote quantity. They are used as references: "figura 3", "apartament 3".
            # Enr = number, only two occurrences: 58_%, 1,4
            # Eqy = only two occurrences: miliarde_de_lei, 2_000_lei
            # Etd = time or date: 1916, 1923, 2005, 1928, 1_martie
            'E' => ['pos' => 'num', 'nountype' => 'prop'],
            # verb
            # examples: poate, este, face, e, devine
            'V' => ['pos' => 'verb'],
            # adverb
            # examples: astfel, încă, doar, atât, bine
            'R' => ['pos' => 'adv'],
            # adposition
            # examples: de, pe, la, cu, în
            'S' => ['pos' => 'adp', 'adpostype' => 'prep'],
            # conjunction
            # examples: și, sau, dar, însă, că
            'C' => ['pos' => 'conj'],
            # particle
            # examples: a, să, nu
            'Q' => ['pos' => 'part'],
            # interjection
            # examples: vai, bravo, na
            'I' => ['pos' => 'int'],
            # abbreviation
            # examples: mp, km, etc.
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
                                                                         'adj'  => { 'prontype' => { ''    => 'A',
                                                                                                     'art' => 'T',
                                                                                                     '@'   => { 'other/prontype' => { 'art' => 'T',
                                                                                                                                      '@'   => { 'person' => { ''  => 'T',
                                                                                                                                                               '@' => 'D' }}}}}},
                                                                         'num'  => { 'nountype' => { 'prop' => 'E',
                                                                                                     '@'    => 'M' }},
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
    # PRONTYPE ####################
    $atoms->{prontype} = $self->create_atom
    (
        'surfeature' => 'prontype',
        'decode_map' =>
        {
            # personal pronoun
            # examples: já, ty, on, ona, ono, my, vy, oni, ony
            'p' => ['prontype' => 'prs'],
            # demonstrative pronoun
            # examples: ten, tento, tenhle, onen, takový, týž, tentýž, sám
            'd' => ['prontype' => 'dem'],
            # emphatic pronoun (~ reflexive demonstrative)
            # examples: sám
            'h' => ['prontype' => 'emp'],
            # indefinite pronoun
            # examples: někdo, něco, nějaký, některý, něčí, leckdo, málokdo, kdokoli
            'i' => ['prontype' => 'ind'],
            # possessive pronoun
            # relative possessive pronouns ("jehož") are classified as relatives
            # examples: můj, tvůj, jeho, její, náš, váš, jejich
            's' => ['prontype' => 'prs', 'poss' => 'poss'],
            # interrogative pronoun
            # examples: kdo, co, jaký, který, čí
            'q' => ['prontype' => 'int'],
            # relative pronoun
            # examples: kdo, co, jaký, který, čí, jenž
            'r' => ['prontype' => 'rel'],
            # interrogative/relative pronoun
            # examples: kdo, co, jaký, který, čí
            'w' => ['prontype' => 'int|rel'],
            # reflexive pronoun (both personal and possessive reflexive pronouns fall here)
            # examples of personal reflexive pronouns: se, si, sebe, sobě, sebou
            # examples of possessive reflexive pronouns: svůj
            'x' => ['prontype' => 'prs', 'reflex' => 'reflex'],
            # negative pronoun
            # examples: nikdo, nic, nijaký, ničí, žádný
            'z' => ['prontype' => 'neg'],
            # general pronoun
            # examples: sám, samý, veškerý, všecko, všechno, všelicos, všelijaký, všeliký, všema
            # some of them also appear classified as indefinite pronouns
            # most of the above examples are clearly syntactic adjectives (determiners)
            # many (except of "sám" and "samý" are classified as totality pronouns in other tagsets)
            'g' => ['prontype' => 'tot'],
            # definite article [ro]
            'f' => ['definiteness' => 'def']
        },
        'encode_map' =>

            { 'reflex' => { 'reflex' => 'x',
                            '@'      => { 'poss' => { 'poss' => 's',
                                                      '@'    => { 'prontype' => { 'dem' => 'd',
                                                                                  'emp' => 'h',
                                                                                  'ind' => 'i',
                                                                                  'int|rel' => 'w',
                                                                                  'int' => 'q',
                                                                                  'rel' => 'r',
                                                                                  'neg' => 'z',
                                                                                  'tot' => 'g',
                                                                                  '@'   => { 'definiteness' => { 'def' => 'f',
                                                                                                                 '@'   => 'p' }}}}}}}}
    );
    # Slovene verbform feature is a merger of verbform, mood, tense and voice.
    # VERB FORM ####################
    $atoms->{verbformX} = $self->create_atom
    (
        'surfeature' => 'verbform',
        'decode_map' =>
        {
            'n' => ['verbform' => 'inf'],                                     # biti, bit
            'u' => ['verbform' => 'sup'],                                     # bit
            'p' => ['verbform' => 'part'],                                    # bil, bila, bilo, bili, bile, bila
            'r' => ['verbform' => 'fin', 'mood' => 'ind', 'tense' => 'pres'], # sem, si, je, sva, sta, sta, smo, ste, su
            'f' => ['verbform' => 'fin', 'mood' => 'ind', 'tense' => 'fut'],  # bom, boš, bo, bova, bosta, bosta, bomo, boste, bodo
            'c' => ['verbform' => 'fin', 'mood' => 'cnd'],                    # bi
            'm' => ['verbform' => 'fin', 'mood' => 'imp']                     # bodi, bodita, bodimo, bodite
        },
        'encode_map' =>
        {
            'mood' => { 'imp' => 'm',
                        'cnd' => 'c',
                        '@'   => { 'verbform' => { 'part' => 'p',
                                                   'sup'  => 'u',
                                                   'inf'  => 'n',
                                                   '@'    => { 'tense' => { 'pres' => 'r',
                                                                            'fut'  => 'f',
                                                                            '@'    => 'n' }}}}}
        }
    );
    # CASE ####################
    $atoms->{case} = $self->create_atom
    (
        'surfeature' => 'case',
        'decode_map' =>
        {
            # Direct case of nouns, articles and numerals. The base form.
            # example indefinite nouns: dor, târg, gând, suflet, deal
            # example definite nouns: locul, anul, orașul, cazul, teritoriul
            # example articles: cel, cea, cei, cele, un, o, -ul
            'r' => ['case' => 'nom'],
            # Indirect case of nouns, articles and numerals.
            # In Romanian it corresponds to genitive rather than accusative!
            # example definite nouns: secolului, guvernului, medicului, numelui, orașului
            # example articles: celei, celor, unui, unei, unor, lui, -ului
            'o' => ['case' => 'gen'],
            # Vocative case, rarely used with nouns.
            # example: domnule (sir)
            'v' => ['case' => 'voc'],
            # Nominative case, used only with 1st and 2nd person singular pronouns (non-possessive).
            # examples: eu (I), tu (you)
            'n' => ['case' => 'nom'],
            # Dative case of personal pronouns.
            # examples: mi (me), ți (you), i (him, her), ne (us), vă (you), le (them), și (oneself)
            'd' => ['case' => 'dat'],
            # Accusative case of personal pronouns.
            # examples: mine, mă (me), tine, te (you), îl (him), o (her), ne (us), vă (you), îi, le (them), se (oneself)
            'a' => ['case' => 'acc'],
            # Genitive case occurs only as subcategorization case of prepositions, and the following noun is tagged as oblique case.
            # examples: asupra (on), în_jurul (around)
            'g' => ['case' => 'gen']
        },
        'encode_map' =>
        {
            'case' => { 'nom' => { 'prontype' => { 'prs' => { 'poss' => { ''  => { 'number' => { 'sing' => { 'person' => { '1' => 'n',
                                                                                                                           '2' => 'n',
                                                                                                                           '@' => 'r' }},
                                                                                                 '@'    => 'r' }},
                                                                          '@' => 'r' }},
                                                   '@'   => 'r' }},
                        'gen' => { 'pos' => { 'adp' => 'g',
                                              '@'   => 'o' }},
                        'voc' => 'v',
                        'dat' => 'd',
                        'acc' => 'a',
                        '@'   => '-' }
        }
    );
    # FORMATION ####################
    # formation of adpositions and conjunctions: simple (s) / compound (c)
    # simple conjunctions: sau (36) dar (11) însă (7) că (6)
    # compound conjunctions: așa_că (1)
    # simple adpositions: de, în, la, din, cu
    # compound adpositions: de_la, până_la, înainte_de, de_după
    $atoms->{formation} = $self->create_atom
    (
        'surfeature' => 'formation',
        'decode_map' =>
        {
            's' => ['other' => {'formation' => 'simple'}],
            'c' => ['other' => {'formation' => 'compound'}]
        },
        'encode_map' =>
        {
            'other/formation' => { 'simple'   => 's',
                                   'compound' => 'c',
                                   '@'        => 's' }
        }
    );
    # COORDINATION TYPE ####################
    # simple, between conjuncts: Ion ori Maria (John or Mary)
    # repetitive, before each conjunct: Ion fie Maria fie... (either John or Mary or...)
    # correlative, before a conjoined phrase, it requires specific coordinators between conjuncts: atât mama cât şi tata (both mother and father)
    ###!!! Note that the corpus contains only examples tagged as simple.
    $atoms->{coord_type} = $self->create_atom
    (
        'surfeature' => 'coordtype',
        'decode_map' =>
        {
            's' => ['other' => {'coordtype' => 'simple'}],
            'r' => ['other' => {'coordtype' => 'repetit'}],
            'c' => ['other' => {'coordtype' => 'correlat'}]
        },
        'encode_map' =>
        {
            'other/coordtype' => { 'simple'   => 's',
                                   'repetit'  => 'r',
                                   'correlat' => 'c',
                                   '@'        => 's' }
        }
    );
    # COORDINATION SUBTYPE ####################
    # Distinguishes positive and negative conjunctions.
    # We use the feature of negativeness to store it, but unlike Multext negativeness, the values are p|z (instead of n|y).
    $atoms->{sub_type} = $self->create_simple_atom
    (
        'intfeature' => 'negativeness',
        'simple_decode_map' =>
        {
            'z' => 'neg',
            'p' => 'pos'
        },
        'encode_default' => '-'
    );
    # MODIFICATION TYPE ####################
    # This feature applies to Romanian determiners.
    # prenominal modifier: acest băiat (this boy)
    # postnominal modifier: băiatul acesta (this boy)
    $atoms->{modtype} = $self->create_simple_atom
    (
        'intfeature' => 'position',
        'simple_decode_map' =>
        {
            'e' => 'prenom',
            'o' => 'postnom'
        },
        'encode_default' => '-'
    );
    # PRONOUN FORM ####################
    # Weak pronouns can be adjoined to the adjacent words both proclitically or enclitically. The junction is always marked by a hyphen, sometimes there are elisions.
    # Even if they are not adjoined, they are tagged as weak.
    # Weak: ne, mă, vă
    # Strong: noi, mine, eu, voi
    $atoms->{pronform} = $self->create_simple_atom
    (
        'intfeature' => 'strength',
        'simple_decode_map' =>
        {
            's' => 'strong',
            'w' => 'weak'
        },
        'encode_default' => '-'
    );
    # PERSON ####################
    ###!!! The common Multext ancestor erases person for demonstratives and some other words.
    ###!!! This worked for Czech, Slovenian and Croatian, but the Romanian tagset marks the third person even for demonstratives!
    $atoms->{person} = $self->create_atom
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
            { 'verbform' => { 'part' => '-',
                              '@'    => { 'person' => { '1' => '1',
                                                        '2' => '2',
                                                        '3' => '3',
                                                        '@' => '-' }}}}
    );
    # IS PRONOUN CLITIC? ####################
    # clitic = yes for short forms of pronouns that behave like clitics (there exists a long form with identical meaning).
    # clitic = bound for short forms with prepositions
    # PerGenNumCase:  1-sa  2-sa  3msg   3msd   3mdg   3mdd   3mpg  3mpd  3fsg 3fsd  3fsa a
    # Examples (yes): me,   te,   ga,    mu,    ju,    jima,  jih,  jim,  je,  ji,   jo,  se
    # Examples (-):   mene, tebe, njega, njemu, njiju, njima, njih, njim, nje, njej, njo, sebe
    # Examples (bound): zame, name, vame, čezme, skozme, predme, pome, zate, nate, vate,
    #     zanjo, vanjo, nanjo, nadnjo, skoznjo, čeznjo, prednjo, ponjo, podnjo, obnjo,
    #     vanj, nanj, zanj, skozenj, nanje, zanje, skoznje, mednje, zase, nase, vase, predse, medse
    $atoms->{clitic} = $self->create_atom
    (
        'surfeature' => 'clitic',
        'decode_map' =>
        {
            'y' => ['variant' => 'short'],
            'n' => ['variant' => 'long'],
            'b' => ['variant' => 'short', 'adpostype' => 'preppron']
        },
        'encode_map' =>
        {
            'variant' => { 'short' => { 'adpostype' => { 'preppron' => 'b',
                                                         '@'        => 'y' }},
                           'long'  => 'n',
                           '@'     => '-' }
        }
    );
    return $atoms;
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
        'N' => ['pos', 'nountype', 'gender', 'number', 'case', 'definiteness', 'clitic'],
        'V' => ['pos', 'verbtype', 'verbform', 'tense', 'person', 'number', 'gender', undef, undef, undef, 'clitic'],
        'A' => ['pos', 'adjtype', 'degree', 'gender', 'number', 'case', 'definiteness', 'clitic'],
        'P' => ['pos', 'prontype', 'person', 'gender', 'number', 'case', 'possnumber', undef, 'clitic', undef, undef, undef, undef, undef, 'pronform'],
        'D' => ['pos', 'prontype', 'person', 'gender', 'number', 'case', 'possnumber', 'clitic', 'pronform', 'modtype'],
        'T' => ['pos', 'prontype', 'gender', 'number', 'case', 'clitic'],
        'R' => ['pos', 'adverb_type', 'degree', 'clitic'],
        'S' => ['pos', 'adpostype', 'formation', 'case', 'clitic'],
        'C' => ['pos', 'conjtype', 'formation', 'coord_type', 'sub_type', 'clitic'],
        'M' => ['pos', 'numtype', 'gender', 'number', 'case', 'numform', 'definiteness', 'clitic'],
        'Q' => ['pos', 'parttype', undef, 'clitic'],
        'Y' => ['pos', 'syntactic_type', 'gender', 'number', 'case', 'definiteness'],
        'X' => ['pos', 'restype']
    );
    return \%features;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# This list has been collected from the UD Romanian 1.2 corpus.
#
# The total of 313 tags included the following 18 special punctuation tags that
# are not Multext and we excluded them from the driver:
# BULLET
# COLON
# COMMA
# DASH
# DBLQ
# EXCL
# LPAR
# LSQR
# PERCENT
# PERIOD
# PLUS
# QUEST
# QUOT
# RPAR
# RSQR
# SCOLON
# SLASH
# UNDERSC
# Thus we have only 295 Multext-East tags in the corpus.
# Removed five entity tags (E.+) because they were not documented and there
# were few occurrences of them. Left just one general 'E'. Result: 290 tags.
# Removed 'M'. We always know the numeral type, don't we?
# Removed 'Mc'. We always know if a numeral is expressed in word or digits.
# Added 'Rg' (there was only 'Rgp' but the other adverb types could only be
# distinguished by the 'other' feature).
# Removed 'Sp'. We always know whether an adposition is simple or compound.
# Removed verbal tags without verbform.
# Removed Pp2-sr--------s (dumneata, polite); kept Pp2-sn--------s (tu, informal);
# the difference between the tags is the direct vs. nominative case and it is not
# important to distinguish. There is no explicit marking of politeness.
#------------------------------------------------------------------------------
sub list
{
    my $self = shift;
    my $list = <<end_of_list
Af
Afcms-n
Afp
Afp-p-n
Afp-poy
Afpf--n
Afpfp-n
Afpfpry
Afpfson
Afpfsoy
Afpfsrn
Afpfsry
Afpmp-n
Afpmpoy
Afpms-n
Afpmsoy
Afpmsry
Cccsp
Ccssp
Crssp
Cscsp
Csssp
Cssspy
Dd3-po---e
Dd3fpr
Dd3fpr---e
Dd3fso---e
Dd3fsr---e
Dd3fsr---o
Dd3mpo
Dd3mso---e
Dd3msr---e
Dh3fs
Dh3ms
Di3--r
Di3--r---e
Di3-po
Di3-po---e
Di3-sr
Di3-sr---e
Di3fp
Di3fpr
Di3fpr---e
Di3fsr
Di3fsr---e
Di3mp
Di3mpr
Di3mpr---e
Di3ms----e
Di3mso---e
Di3msr
Ds1fp-p
Ds1fp-s
Ds1fsos
Ds1fsrp
Ds1fsrs
Ds1mp-s
Ds1ms-s
Ds2fsrp
Ds3---p
Ds3---s
Ds3fp-s
Ds3fsos
Ds3fsrs
Ds3mp-s
Ds3ms-s
Dw3--r---e
Dz3fsr---e
Dz3msr---e
E
I
Mc-p-l
Mcfp-l
Mcfp-ln
Mcfprln
Mcfsrln
Mcmp-l
Mcms-ln
Mlfpr
Mlmpr
Mo-s-r
Mofpoly
Mofprly
Mofs-l
Mofsoly
Mofsrly
Momprly
Moms-l
Moms-ln
Momsoly
Momsrly
Nc
Nc---n
Ncf--n
Ncfp-n
Ncfpoy
Ncfpry
Ncfson
Ncfsony
Ncfsoy
Ncfsrn
Ncfsry
Ncfsvy
Ncm--n
Ncmp-n
Ncmpoy
Ncmpry
Ncmpvy
Ncms-n
Ncmsoy
Ncmsrn
Ncmsry
Ncmsvn
Ncmsvy
Np
Npfson
Npfsoy
Npfsrn
Npfsry
Npmpoy
Npmpry
Npms-n
Npmsry
Pd3-po
Pd3fpr
Pd3fso
Pd3fsr
Pd3mpr
Pd3mso
Pd3msr
Pi3--r
Pi3-po
Pi3-sr
Pi3fpr
Pi3fso
Pi3fsr
Pi3mpr
Pi3msr
Pp1-pa--------w
Pp1-pa--y-----w
Pp1-pd--------w
Pp1-pr--------s
Pp1-sa--------s
Pp1-sa--------w
Pp1-sa--y-----w
Pp1-sd--------w
Pp1-sd--y-----w
Pp1-sn--------s
Pp2-----------s
Pp2-pa--------w
Pp2-pa--y-----w
Pp2-pd--------w
Pp2-pr--------s
Pp2-sa--------s
Pp2-sa--------w
Pp2-sd--------w
Pp2-sd--y-----w
Pp2-sn--------s
Pp3-pd--------w
Pp3-sd--------w
Pp3-sd--y-----w
Pp3fpa--------w
Pp3fpa--y-----w
Pp3fpr--------s
Pp3fsa--------w
Pp3fsa--y-----w
Pp3fsr--------s
Pp3mpa--------w
Pp3mpa--y-----w
Pp3mpr--------s
Pp3msa--------w
Pp3msa--y-----w
Pp3mso--------s
Pp3msr--------s
Ps1fsrp
Ps1ms-s
Ps2fsrs
Ps3---s
Ps3fsrs
Pw3--r
Pw3-po
Pw3-so
Pw3fpr
Pw3fso
Pw3mso
Px3--a--------w
Px3--a--y-----w
Px3--d--------w
Px3--d--y-----w
Pz3-sr
Pz3msr
Qn
Qs
Qz
Qz-y
Rc
Rg
Rgp
Rp
Rw
Rz
Spca
Spcg
Spsa
Spsay
Spsd
Spsg
Td-po
Tdfpr
Tdfso
Tdfsr
Tdmpr
Tdmsr
Tf-so
Tffs-y
Tfms-y
Tfmsoy
Tfmsry
Ti-po
Tifso
Tifsr
Timso
Timsr
Tsfp
Tsfs
Tsmp
Tsms
Vag
Vaii3s
Vail3p
Vaip1p
Vaip1s
Vaip2s
Vaip3p
Vaip3s
Vanp
Vap--sm
Vasp3
Vmg
Vmg-------y
Vmii1
Vmii1p
Vmii1s
Vmii2p
Vmii2s
Vmii3p
Vmii3s
Vmil1
Vmil3p
Vmil3s
Vmip1p
Vmip1s
Vmip2p
Vmip2s
Vmip3
Vmip3p
Vmip3s
Vmip3s----y
Vmis1p
Vmis1s
Vmis3p
Vmis3s
Vmm-2p
Vmm-2s
Vmnp
Vmp--pf
Vmp--pm
Vmp--sf
Vmp--sm
Vmsp1p
Vmsp1s
Vmsp2p
Vmsp2s
Vmsp3
Vmsp3s
X
Y
Yn
Yr
end_of_list
    ;
    my @list = split(/\r?\n/, $list);
    return \@list;
}



1;

=head1 SYNOPSIS

  use Lingua::Interset::Tagset::RO::Multext;
  my $driver = Lingua::Interset::Tagset::RO::Multext->new();
  my $fs = $driver->decode('Ncms-n');

or

  use Lingua::Interset qw(decode);
  my $fs = decode('ro::multext', 'Ncms-n');

=head1 DESCRIPTION

Interset driver for the Romanian tagset of the Multext-EAST v4 project.
See L<http://nl.ijs.si/ME/V4/msd/html/msd-ro.html> for a detailed description
of the tagset.

=head1 SEE ALSO

L<Lingua::Interset>,
L<Lingua::Interset::Tagset>,
L<Lingua::Interset::FeatureStructure>

=cut
