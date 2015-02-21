# ABSTRACT: Driver for Syntagrus (Russian Dependency Treebank) tags.
# Copyright © 2006, 2011, 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset::Tagset::RU::Syntagrus;
use strict;
use warnings;
our $VERSION = '2.038';

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
extends 'Lingua::Interset::Tagset';



has 'atoms' => ( isa => 'HashRef', is => 'ro', builder => '_create_atoms', lazy => 1 );
has 'features_pos' => ( isa => 'HashRef', is => 'ro', builder => '_create_features_pos', lazy => 1 );



#------------------------------------------------------------------------------
# Returns the tagset id that should be set as the value of the 'tagset' feature
# during decoding. Every derived class must (re)define this method! The result
# should correspond to the last two parts in package name, lowercased.
# Specifically, it should be the ISO 639-2 language code, followed by '::' and
# a language-specific tagset id. Example: 'cs::multext'.
#------------------------------------------------------------------------------
sub get_tagset_id
{
    return 'ru::syntagrus';
}



#------------------------------------------------------------------------------
# Creates atomic drivers for the surface features.
# http://spraakbanken.gu.se/parole/tags.phtml
#------------------------------------------------------------------------------
sub _create_atoms
{
    my $self = shift;
    my %atoms;
    foreach my $p (@positions)
    {
        # Part of speech
        if($p eq 'A')
        {
            $f{pos} = 'adj';
        }
        elsif($p eq 'ADV')
        {
            $f{pos} = 'adv';
        }
        elsif($p eq 'COM')
        {
            $f{hyph} = 'hyph';
        }
        elsif($p eq 'CONJ')
        {
            $f{pos} = 'conj';
        }
        elsif($p eq 'INTJ')
        {
            $f{pos} = 'int';
        }
        elsif($p eq 'NID')
        {
            # Unknown word. Nothing to set in Interset.
        }
        elsif($p eq 'NUM')
        {
            $f{pos} = 'num';
        }
        elsif($p =~ m/^P(ART)?$/)
        {
            $f{pos} = 'part';
        }
        elsif($p eq 'PR')
        {
            $f{pos} = 'prep';
        }
        elsif($p eq 'S')
        {
            $f{pos} = 'noun';
        }
        elsif($p eq 'V')
        {
            $f{pos} = 'verb';
        }
        # Short (nominal) variant of adjectives
        elsif($p eq 'КР')
        {
            $f{variant} = 'short';
        }
        # Compound part
        elsif($p eq 'СЛ')
        {
            $f{hyph} = 'hyph';
        }
        # For adjectives and adverbs: distinguishes forms with prefix по-
        # (поближе, поскорее, подальше) from normal forms (больше, меньше, быстрей, дальше, позже).
        elsif($p eq 'СМЯГ')
        {
            $f{other}{smjag}++;
        }
        # Number
        elsif($p eq 'ЕД')
        {
            $f{number} = 'sing';
        }
        elsif($p eq 'МН')
        {
            $f{number} = 'plu';
        }
        # Gender
        elsif($p eq 'ЖЕН')
        {
            $f{gender} = 'fem';
        }
        elsif($p eq 'МУЖ')
        {
            $f{gender} = 'masc';
        }
        elsif($p eq 'СРЕД')
        {
            $f{gender} = 'neut';
        }
        # Animateness
        elsif($p eq 'НЕОД')
        {
            $f{animateness} = 'inan';
        }
        elsif($p eq 'ОД')
        {
            $f{animateness} = 'anim';
        }
        # Case
        elsif($p eq 'ИМ') # Именительный / Номинатив (Nominative)
        {
            $f{case} = 'nom';
        }
        elsif($p eq 'РОД') # Родительный / Генитив (Genitive)
        {
            $f{case} = 'gen';
        }
        elsif($p eq 'ПАРТ') # Количественно-отделительный (партитив, или второй родительный) (Partitive) [not in Russian schools]
        {
            # Subcase of РОД. Occasionally the word form differs if the genitive
            # is used for the noun describing a whole in relation to parts;
            # these forms may also be preferred with mass nouns.
            # «нет сахара» vs. «положить сахару»
            $f{case} = 'gen';
        }
        elsif($p eq 'ДАТ') # Дательный / Датив (Dative)
        {
            $f{case} = 'dat';
        }
        elsif($p eq 'ВИН') # Винительный / Аккузатив (Accusative)
        {
            $f{case} = 'acc';
        }
        elsif($p eq 'ЗВ') # only one word type: "Господи" # Звательный (вокатив) (Vocative) [not in Russian schools]
        {
            $f{case} = 'voc';
        }
        elsif($p eq 'ПР') # Предложный / Препозитив (Prepositional) [in Russian schools taught as the last one after instrumental?]
        {
            $f{case} = 'loc';
        }
        elsif($p eq 'МЕСТН') # [not in Russian schools]
        {
            # Subcase of ПР. ПР is used for two meanings: 'about what?' (о чём?) and 'where?' (где?).
            # The word forms of the two meanings mostly overlap but there are about 100 words whose forms differ:
            # «о шкафе» — «в шкафу»
            $f{case} = 'loc';
        }
        elsif($p eq 'ТВОР') # Творительный / Аблатив (объединяет инструментатив [Instrumental], локатив и аблатив)
        {
            $f{case} = 'ins';
        }
        # Degree of comparison
        elsif($p eq 'СРАВ')
        {
            $f{degree} = 'comp';
        }
        elsif($p eq 'ПРЕВ')
        {
            $f{degree} = 'sup';
        }
        # Aspect
        elsif($p eq 'НЕСОВ')
        {
            $f{aspect} = 'imp';
        }
        elsif($p eq 'СОВ')
        {
            $f{aspect} = 'perf';
        }
        # Verb form
        elsif($p eq 'ДЕЕПР')
        {
            $f{verbform} = 'trans';
        }
        elsif($p eq 'ИЗЪЯВ')
        {
            $f{verbform} = 'fin';
            $f{mood} = 'ind';
        }
        elsif($p eq 'ИНФ')
        {
            $f{verbform} = 'inf';
        }
        elsif($p eq 'ПОВ')
        {
            $f{verbform} = 'fin';
            $f{mood} = 'imp';
        }
        elsif($p eq 'ПРИЧ')
        {
            $f{verbform} = 'part';
        }
        # Tense
        elsif($p eq 'НЕПРОШ')
        {
            $f{tense} = ['pres'|'fut'];
        }
        elsif($p eq 'ПРОШ')
        {
            $f{tense} = 'past';
        }
        elsif($p eq 'НАСТ')
        {
            $f{tense} = 'pres';
        }
        # Person
        elsif($p eq '1-Л')
        {
            $f{person} = 1;
        }
        elsif($p eq '2-Л')
        {
            $f{person} = 2;
        }
        elsif($p eq '3-Л')
        {
            $f{person} = 3;
        }
        # Voice: страдательный залог = passive voice
        elsif($p eq 'СТРАД')
        {
            $f{voice} = 'pass';
        }
        # Non-standard spelling
        elsif($p eq 'НЕСТАНД')
        {
            $f{typo} = typo;
        }
        # Obsolete tags
        elsif($p eq 'МЕТА')
        {
            # This tag has been encountered at one token only, without any obvious purpose.
            $f{other}{meta}++;
        }
        elsif($p eq 'НЕПРАВ')
        {
            # This tag has been encountered at two tokens only, without any obvious purpose.
            $f{other}{neprav}++;
        }
        else
        {
            print STDERR ("Unknown tag '$p'.\n");
        }
    }
    # 1. PART OF SPEECH ####################
    $atoms{pos} = $self->create_atom
    (
        'surfeature' => 'pos',
        'decode_map' =>
        {
            # adverb / adverb
            # examples: inte, också, så, bara, nu
            'AB' => ['pos' => 'adv'],
            # determiner / determinerare
            # examples: en, ett, den, det, alla, några, inga, de
            'DT' => ['pos' => 'adj', 'prontype' => 'prn'],
            # interrogative/relative adverb / frågande/relativt adverb
            # example: när, där, hur, som, då
            'HA' => ['pos' => 'adv', 'prontype' => 'int|rel'],
            # interrogative/relative determiner / frågande/relativ determinerare
            # examples: vilken, vilket, vilka
            'HD' => ['pos' => 'adj', 'prontype' => 'int|rel'],
            # interrogative/relative pronoun / frågande/relativt pronomen
            # examples: som, vilken, vem, vilket, vad, vilka
            'HP' => ['pos' => 'noun', 'prontype' => 'int|rel'],
            # interrogative/relative possessive pronoun / frågande/relativt possesivt pronomen
            # example: vars
            'HS' => ['pos' => 'adj', 'prontype' => 'int|rel', 'poss' => 'poss'],
            # infinitive marker / infinitivmärke
            # example: att
            'IE' => ['pos' => 'part', 'verbform' => 'inf'], ###!!! what is the current standard about infinitive markers?
            # interjection / interjektion
            # example: jo, ja, nej
            'IN' => ['pos' => 'int'],
            # adjective / adjektiv
            # examples: stor, annan, själv, sådan, viss
            'JJ' => ['pos' => 'adj'],
            # coordinating conjunction / konjunktion
            # examples: och, eller, som, än, men
            'KN' => ['pos' => 'conj', 'conjtype' => 'coor'],
            # meaning separating punctuation / meningsskiljande interpunktion
            # examples: . ? : ! ...
            'MAD' => ['pos' => 'punc', 'punctype' => 'peri|qest|excl|colo'],
            # punctuation inside of sentence / interpunktion
            # examples: , - : * ;
            'MID' => ['pos' => 'punc', 'punctype' => 'comm|dash|semi'], # or 'colo'; but we do not want a conflict with 'MAD'
            # noun / substantiv
            # examples: år, arbete, barn, sätt, äktenskap
            'NN' => ['pos' => 'noun', 'nountype' => 'com'],
            # paired punctuation / interpunktion
            # examples: ' ( )
            'PAD' => ['pos' => 'punc', 'punctype' => 'quot|brck'],
            # participle / particip
            # examples: särskild, ökad, beredd, gift, oförändrad
            'PC' => ['pos' => 'verb', 'verbform' => 'part'],
            # particle / partikel
            # examples: ut, upp, in, till, med
            ###!!! Joakim currently converts the particles to adpositions because these are the Germanic verb particles.
            'PL' => ['pos' => 'part'],
            # proper name / egennamn
            # example: F, N, Liechtenstein, Danmark, DK
            'PM' => ['pos' => 'noun', 'nountype' => 'prop'],
            # pronoun / pronomen
            # examples: han, den, vi, det, denne, de, dessa
            'PN' => ['pos' => 'noun', 'prontype' => 'prn'],
            # preposition / preposition
            # examples: i, av, på, för, till
            'PP' => ['pos' => 'adp', 'adpostype' => 'prep'],
            # possessive pronoun / possesivt pronomen
            # examples: min, din, sin, vår, er, mitt, ditt, sitt, vårt, ert, mina, dina, sina, våra
            'PS' => ['pos' => 'adj', 'prontype' => 'prs', 'poss' => 'poss'],
            # cardinal numeral / grundtal
            # examples: en, ett, två, tre, 1, 20, 2
            'RG' => ['pos' => 'num', 'numtype' => 'card'],
            # ordinal numeral / ordningstal
            # examples: första, andra, tredje, fjärde, femte
            'RO' => ['pos' => 'adj', 'numtype' => 'ord'],
            # subordinating conjunction / subjunktion
            # examples: att, om, innan, eftersom, medan
            'SN' => ['pos' => 'conj', 'conjtype' => 'sub'],
            # foreign word / utländskt ord
            # examples: companionship, vice, versa, family, capita
            'UO' => ['foreign' => 'foreign'],
            # verb / verb
            # examples: vara, få, ha, bli, kunna
            'VB' => ['pos' => 'verb'],
        },
        'encode_map' =>
        {
            'pos' => { 'noun' => { 'prontype' => { ''    => { 'nountype' => { 'prop' => 'PM',
                                                                              '@'    => 'NN' }},
                                                   'int' => { 'poss' => { 'poss' => 'HS',
                                                                          '@'    => 'HP' }},
                                                   '@'   => { 'poss' => { 'poss' => 'PS',
                                                                          '@'    => 'PN' }}}},
                       'adj'  => { 'prontype' => { ''    => { 'verbform' => { 'part' => 'PC',
                                                                              '@'    => { 'numtype' => { 'ord' => 'RO',
                                                                                                         '@'   => 'JJ' }}}},
                                                   'int' => { 'poss' => { 'poss' => 'HS',
                                                                          '@'    => 'HD' }},
                                                   '@'   => { 'poss' => { 'poss' => 'PS',
                                                                          '@'    => 'DT' }}}},
                       'num'  => { 'numtype' => { 'ord' => 'RO',
                                                  '@'   => 'RG' }},
                       'verb' => { 'verbform' => { 'part' => 'PC',
                                                   '@'    => 'VB' }},
                       'adv'  => { 'prontype' => { 'int' => 'HA',
                                                   '@'   => 'AB' }},
                       'adp'  => 'PP',
                       'conj' => { 'verbform' => { 'inf' => 'IE',
                                                   '@'   => { 'conjtype' => { 'sub' => 'SN',
                                                                              '@'   => 'KN' }}}},
                       'part' => { 'verbform' => { 'inf' => 'IE',
                                                   '@'   => 'PL' }},
                       'int'  => 'IN',
                       'punc' => { 'punctype' => { 'peri' => 'MAD',
                                                   'qest' => 'MAD',
                                                   'excl' => 'MAD',
                                                   'colo' => 'MAD', # or MID
                                                   'comm' => 'MID',
                                                   'semi' => 'MID',
                                                   'dash' => 'MID',
                                                   'quot' => 'PAD',
                                                   'brck' => 'PAD',
                                                   '@'    => 'MID' }},
                       '@'    => 'UO' }
        }
    );
    # 2. DEGREE ####################
    $atoms{degree} = $self->create_simple_atom
    (
        'intfeature' => 'degree',
        'simple_decode_map' =>
        {
            'POS' => 'pos',
            'KOM' => 'comp',
            'SUV' => 'sup'
        }
    );
    # 3. GENDER ####################
    $atoms{gender} = $self->create_simple_atom
    (
        'intfeature' => 'gender',
        'simple_decode_map' =>
        {
            'MAS' => 'masc',
            'UTR' => 'com',
            'NEU' => 'neut',
            'UTR/NEU' => ''
        }
    );
    # 4. NUMBER ####################
    $atoms{number} = $self->create_simple_atom
    (
        'intfeature' => 'number',
        'simple_decode_map' =>
        {
            'SIN' => 'sing',
            'PLU' => 'plur',
            'SIN/PLU' => ''
        }
    );
    # 5. CASE ####################
    $atoms{case} = $self->create_simple_atom
    (
        'intfeature' => 'case',
        'simple_decode_map' =>
        {
            'NOM' => 'nom',
            'GEN' => 'gen'
        }
    );
    # 6. SUBJECT / OBJECT FORM ####################
    $atoms{subjobj} = $self->create_simple_atom
    (
        'intfeature' => 'case',
        'simple_decode_map' =>
        {
            'SUB' => 'nom',
            'OBJ' => 'acc',
            'SUB/OBJ' => ''
        }
    );
    # 7. DEFINITENESS ####################
    $atoms{definiteness} = $self->create_simple_atom
    (
        'intfeature' => 'definiteness',
        'simple_decode_map' =>
        {
            'DEF' => 'def',
            'IND' => 'ind',
            'IND/DEF' => ''
        }
    );
    # 8. VERB FORM, MOOD, TENSE AND ASPECT ####################
    $atoms{verbform} = $self->create_atom
    (
        'surfeature' => 'verbform',
        'decode_map' =>
        {
            # infinitive / infinitiv
            'INF' => ['verbform' => 'inf'],
            # perfect participle / particip perfekt
            'PRF' => ['verbform' => 'part', 'aspect' => 'perf', 'tense' => 'past'],
            # present indicative or present subjunctive or present participle / presens eller particip presens
            'PRS' => ['tense' => 'pres'],
            # past indicative or subjunctive / preteritum
            'PRT' => ['verbform' => 'fin', 'tense' => 'past'],
            # imperative / imperativ
            'IMP' => ['verbform' => 'fin', 'mood' => 'imp'],
            # subjunctive / konjunktiv
            'KON' => ['verbform' => 'fin', 'mood' => 'sub'],
            # supine / supinum
            'SUP' => ['verbform' => 'sup']
        },
        'encode_map' =>
        {
            'verbform' => { 'inf'  => 'INF',
                            'fin'  => { 'mood' => { 'ind' => { 'tense' => { 'pres' => 'PRS',
                                                                            'past' => 'PRT' }},
                                                    'sub' => { 'tense' => { 'pres' => 'KON|PRS',
                                                                            'past' => 'KON|PRT' }},
                                                    'imp' => 'IMP',
                                                    '@'   => { 'tense' => { 'pres' => 'PRS',
                                                                            'past' => 'PRT' }}}},
                            'sup'  => 'SUP',
                            'part' => { 'tense' => { 'pres' => 'PRS',
                                                     'past' => 'PRF' }},
                            '@'    => { 'tense' => { 'pres' => 'PRS' }}}
        }
    );
    # 9. VOICE ####################
    $atoms{voice} = $self->create_simple_atom
    (
        'intfeature' => 'voice',
        'simple_decode_map' =>
        {
            # E.g. verb preteritum aktiv
            # Example: hänvisade = referred
            'AKT' => 'act',
            # E.g. verb preteritum s-form
            # Example: tillfrågades = asked
            ###!!! How did we come to conclude that "s-form" means passive?
            ###!!! But Joakim also decodes it as passive.
            'SFO' => 'pass'
        }
    );
    # 10. FORM ####################
    $atoms{form} = $self->create_atom
    (
        'surfeature' => 'form',
        'decode_map' =>
        {
            # hyphenated prefix / sammansättningsform
            'SMS' => ['hyph' => 'hyph'],
            # abbreviation / förkortning
            'AN' => ['abbr' => 'abbr']
        },
        'encode_map' =>
        {
            'hyph' => { 'hyph' => 'SMS',
                        '@'    => { 'abbr' => { 'abbr' => 'AN' }}}
        }
    );
    # MERGED ATOM TO DECODE ANY FEATURE VALUE ####################
    my @fatoms = map {$atoms{$_}} (qw(pos degree gender number case subjobj definiteness verbform voice form));
    $atoms{feature} = $self->create_merged_atom
    (
        'surfeature' => 'feature',
        'atoms'      => \@fatoms
    );
    return \%atoms;
}



#------------------------------------------------------------------------------
# Creates the list of surface features (character positions) that can appear
# with particular parts of speech.
#------------------------------------------------------------------------------
sub _create_features_pos
{
    my $self = shift;
    my %features =
    (
        'NN' => ['gender', 'number', 'definiteness', 'case', 'form'],
        'PM' => ['case', 'form'],
        'JJ' => ['degree', 'gender', 'number', 'definiteness', 'case', 'form'],
        'PC' => ['verbform', 'gender', 'number', 'definiteness', 'case', 'form'],
        'DT' => ['gender', 'number', 'definiteness', 'form'],
        'HD' => ['gender', 'number', 'definiteness', 'form'],
        'PN' => ['gender', 'number', 'definiteness', 'subjobj', 'form'],
        'PS' => ['gender', 'number', 'definiteness', 'form'],
        'HP' => ['gender', 'number', 'definiteness', 'form'],
        'HS' => ['definiteness'],
        'RG' => ['gender', 'number', 'definiteness', 'case', 'form'],
        'RO' => ['gender', 'number', 'definiteness', 'case', 'form'],
        'VB' => ['verbform', 'tense', 'voice', 'form'],
        'AB' => ['degree', 'form'],
        'PP' => ['form'],
        'KN' => ['form'],
        'PL' => ['form']
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
    $fs->set_tagset('sv::suc');
    my $atoms = $self->atoms();
    my @features = split(/\|/, $tag);
    foreach my $feature (@features)
    {
        $atoms->{feature}->decode_and_merge_hard($feature, $fs);
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
    my $pos = $atoms->{pos}->encode($fs);
    my $features = $self->features_pos()->{$pos};
    my @features = ($pos);
    if(defined($features))
    {
        foreach my $feature (@{$features})
        {
            if(defined($feature) && defined($atoms->{$feature}))
            {
                my $value = $atoms->{$feature}->encode($fs);
                if(defined($value) && $value ne '')
                {
                    push(@features, $value);
                }
            }
        }
    }
    my $tag = join('|', @features);
    # A few tags have other forms than expected.
    $tag =~ s:HP\|UTR/NEU\|SIN/PLU\|IND/DEF:HP|-|-|-:;
    $tag =~ s:(JJ|NN|PC|PS)\|.*\|AN:$1|AN:;
    $tag =~ s:JJ\|POS\|UTR\|SIN/PLU\|IND/DEF\|SMS:JJ|POS|UTR|-|-|SMS:;
    $tag =~ s:NN\|UTR/NEU\|SIN/PLU\|IND/DEF$:NN|-|-|-|-:;
    $tag =~ s:NN\|UTR/NEU\|SIN/PLU\|IND/DEF\|SMS:NN|SMS:;
    $tag =~ s:NN\|(NEU|UTR)\|SIN/PLU\|IND/DEF$:NN|$1|-|-|-:;
    $tag =~ s:NN\|(NEU|UTR)\|SIN/PLU\|IND/DEF\|SMS:NN|$1|-|-|SMS:;
    $tag =~ s:(RG|RO)\|UTR/NEU\|SIN/PLU\|IND/DEF:$1:;
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# The source list is the tagset of the Swedish SUC corpus; see also the
# UD Swedish treebank.
# http://spraakbanken.gu.se/parole/tags.phtml
# total tags:
# 155
#------------------------------------------------------------------------------
sub list
{
    my $self = shift;
    my $list = <<end_of_list
A
A ЕД ЖЕН ВИН
A ЕД ЖЕН ДАТ
A ЕД ЖЕН ИМ
A ЕД ЖЕН ИМ МЕТА
A ЕД ЖЕН ПР
A ЕД ЖЕН РОД
A ЕД ЖЕН ТВОР
A ЕД МУЖ ВИН НЕОД
A ЕД МУЖ ВИН ОД
A ЕД МУЖ ДАТ
A ЕД МУЖ ИМ
A ЕД МУЖ ПР
A ЕД МУЖ РОД
A ЕД МУЖ ТВОР
A ЕД СРЕД ВИН
A ЕД СРЕД ДАТ
A ЕД СРЕД ИМ
A ЕД СРЕД ПР
A ЕД СРЕД РОД
A ЕД СРЕД ТВОР
A КР ЕД ЖЕН
A КР ЕД МУЖ
A КР ЕД СРЕД
A КР МН
A МН ВИН НЕОД
A МН ВИН ОД
A МН ДАТ
A МН ИМ
A МН ПР
A МН РОД
A МН ТВОР
A ПРЕВ ЕД ЖЕН ИМ
A ПРЕВ ЕД ЖЕН РОД
A ПРЕВ ЕД ЖЕН ТВОР
A ПРЕВ ЕД МУЖ ИМ
A ПРЕВ ЕД МУЖ ПР
A ПРЕВ ЕД МУЖ РОД
A ПРЕВ ЕД СРЕД ИМ
A ПРЕВ МН ВИН НЕОД
A ПРЕВ МН ВИН ОД
A ПРЕВ МН ДАТ
A ПРЕВ МН ИМ
A ПРЕВ МН ПР
A ПРЕВ МН РОД
A СЛ
A СРАВ
A СРАВ СМЯГ
ADV
ADV НЕСТАНД
ADV СРАВ
ADV СРАВ СМЯГ
COM
COM СЛ
CONJ
INTJ
NID
NUM
NUM ВИН
NUM ВИН НЕОД
NUM ВИН ОД
NUM ДАТ
NUM ЕД ЖЕН ВИН
NUM ЕД ЖЕН ДАТ
NUM ЕД ЖЕН ИМ
NUM ЕД ЖЕН ПР
NUM ЕД ЖЕН РОД
NUM ЕД ЖЕН ТВОР
NUM ЕД МУЖ ВИН НЕОД
NUM ЕД МУЖ ВИН ОД
NUM ЕД МУЖ ДАТ
NUM ЕД МУЖ ИМ
NUM ЕД МУЖ ПР
NUM ЕД МУЖ РОД
NUM ЕД МУЖ ТВОР
NUM ЕД СРЕД ВИН
NUM ЕД СРЕД ИМ
NUM ЕД СРЕД ПР
NUM ЕД СРЕД РОД
NUM ЕД СРЕД ТВОР
NUM ЖЕН ВИН НЕОД
NUM ЖЕН ДАТ
NUM ЖЕН ИМ
NUM ЖЕН РОД
NUM ИМ
NUM МУЖ ВИН НЕОД
NUM МУЖ ВИН ОД
NUM МУЖ ДАТ
NUM МУЖ ИМ
NUM ПР
NUM РОД
NUM СЛ
NUM СРЕД ВИН
NUM СРЕД ИМ
NUM ТВОР
P
PART
PART НЕПРАВ
PR
S ЕД ЖЕН ВИН
S ЕД ЖЕН ВИН НЕОД
S ЕД ЖЕН ВИН ОД
S ЕД ЖЕН ДАТ
S ЕД ЖЕН ДАТ НЕОД
S ЕД ЖЕН ДАТ ОД
S ЕД ЖЕН ИМ
S ЕД ЖЕН ИМ НЕОД
S ЕД ЖЕН ИМ ОД
S ЕД ЖЕН МЕСТН НЕОД
S ЕД ЖЕН ПР
S ЕД ЖЕН ПР НЕОД
S ЕД ЖЕН ПР ОД
S ЕД ЖЕН РОД
S ЕД ЖЕН РОД НЕОД
S ЕД ЖЕН РОД НЕОД НЕСТАНД
S ЕД ЖЕН РОД ОД
S ЕД ЖЕН РОД ОД НЕСТАНД
S ЕД ЖЕН ТВОР НЕОД
S ЕД ЖЕН ТВОР ОД
S ЕД МУЖ ВИН НЕОД
S ЕД МУЖ ВИН ОД
S ЕД МУЖ ДАТ
S ЕД МУЖ ДАТ НЕОД
S ЕД МУЖ ДАТ ОД
S ЕД МУЖ ДАТ ОД НЕСТАНД
S ЕД МУЖ ЗВ ОД
S ЕД МУЖ ИМ
S ЕД МУЖ ИМ НЕОД
S ЕД МУЖ ИМ ОД
S ЕД МУЖ ИМ ОД НЕСТАНД
S ЕД МУЖ МЕСТН НЕОД
S ЕД МУЖ НЕОД
S ЕД МУЖ ПАРТ НЕОД
S ЕД МУЖ ПР
S ЕД МУЖ ПР НЕОД
S ЕД МУЖ ПР ОД
S ЕД МУЖ РОД
S ЕД МУЖ РОД НЕОД
S ЕД МУЖ РОД ОД
S ЕД МУЖ ТВОР
S ЕД МУЖ ТВОР НЕОД
S ЕД МУЖ ТВОР ОД
S ЕД МУЖ ТВОР ОД НЕСТАНД
S ЕД СРЕД ВИН
S ЕД СРЕД ВИН НЕОД
S ЕД СРЕД ВИН ОД
S ЕД СРЕД ДАТ
S ЕД СРЕД ДАТ НЕОД
S ЕД СРЕД ИМ
S ЕД СРЕД ИМ НЕОД
S ЕД СРЕД ИМ ОД
S ЕД СРЕД НЕОД
S ЕД СРЕД ПР
S ЕД СРЕД ПР НЕОД
S ЕД СРЕД РОД
S ЕД СРЕД РОД НЕОД
S ЕД СРЕД РОД ОД
S ЕД СРЕД ТВОР НЕОД
S ЕД СРЕД ТВОР ОД
S ЖЕН НЕОД СЛ
S МН ВИН НЕОД
S МН ВИН ОД
S МН ДАТ
S МН ДАТ НЕОД
S МН ДАТ ОД
S МН ЖЕН ВИН НЕОД
S МН ЖЕН ВИН ОД
S МН ЖЕН ДАТ НЕОД
S МН ЖЕН ДАТ ОД
S МН ЖЕН ИМ НЕОД
S МН ЖЕН ИМ ОД
S МН ЖЕН НЕОД
S МН ЖЕН ПР НЕОД
S МН ЖЕН РОД НЕОД
S МН ЖЕН РОД ОД
S МН ЖЕН ТВОР НЕОД
S МН ЖЕН ТВОР ОД
S МН ИМ
S МН ИМ НЕОД
S МН ИМ ОД
S МН МУЖ ВИН НЕОД
S МН МУЖ ВИН ОД
S МН МУЖ ДАТ НЕОД
S МН МУЖ ДАТ ОД
S МН МУЖ ИМ НЕОД
S МН МУЖ ИМ ОД
S МН МУЖ ИМ ОД НЕСТАНД
S МН МУЖ ПР НЕОД
S МН МУЖ ПР ОД
S МН МУЖ РОД НЕОД
S МН МУЖ РОД НЕОД НЕСТАНД
S МН МУЖ РОД ОД
S МН МУЖ РОД ОД НЕСТАНД
S МН МУЖ ТВОР НЕОД
S МН МУЖ ТВОР ОД
S МН ПР
S МН ПР НЕОД
S МН ПР ОД
S МН РОД
S МН РОД НЕОД
S МН РОД ОД
S МН СРЕД ВИН НЕОД
S МН СРЕД ВИН ОД
S МН СРЕД ДАТ НЕОД
S МН СРЕД ДАТ ОД
S МН СРЕД ИМ НЕОД
S МН СРЕД ИМ ОД
S МН СРЕД НЕОД
S МН СРЕД ПР НЕОД
S МН СРЕД ПР ОД
S МН СРЕД РОД НЕОД
S МН СРЕД РОД ОД
S МН СРЕД ТВОР НЕОД
S МН СРЕД ТВОР ОД
S МН ТВОР
S МН ТВОР НЕОД
S МН ТВОР ОД
S МУЖ НЕОД СЛ
S МУЖ ОД СЛ
S СРЕД НЕОД СЛ
V НЕСОВ ДЕЕПР НЕПРОШ
V НЕСОВ ДЕЕПР ПРОШ
V НЕСОВ ИЗЪЯВ НАСТ ЕД 2-Л
V НЕСОВ ИЗЪЯВ НАСТ ЕД 3-Л
V НЕСОВ ИЗЪЯВ НАСТ МН 3-Л
V НЕСОВ ИЗЪЯВ НЕПРОШ ЕД 1-Л
V НЕСОВ ИЗЪЯВ НЕПРОШ ЕД 2-Л
V НЕСОВ ИЗЪЯВ НЕПРОШ ЕД 3-Л
V НЕСОВ ИЗЪЯВ НЕПРОШ ЕД 3-Л НЕСТАНД
V НЕСОВ ИЗЪЯВ НЕПРОШ МН 1-Л
V НЕСОВ ИЗЪЯВ НЕПРОШ МН 2-Л
V НЕСОВ ИЗЪЯВ НЕПРОШ МН 3-Л
V НЕСОВ ИЗЪЯВ НЕПРОШ МН 3-Л НЕСТАНД
V НЕСОВ ИЗЪЯВ ПРОШ ЕД ЖЕН
V НЕСОВ ИЗЪЯВ ПРОШ ЕД МУЖ
V НЕСОВ ИЗЪЯВ ПРОШ ЕД СРЕД
V НЕСОВ ИЗЪЯВ ПРОШ МН
V НЕСОВ ИНФ
V НЕСОВ ПОВ ЕД 2-Л
V НЕСОВ ПОВ МН 2-Л
V НЕСОВ ПРИЧ НЕПРОШ ЕД ЖЕН ВИН
V НЕСОВ ПРИЧ НЕПРОШ ЕД ЖЕН ИМ
V НЕСОВ ПРИЧ НЕПРОШ ЕД ЖЕН ПР
V НЕСОВ ПРИЧ НЕПРОШ ЕД ЖЕН РОД
V НЕСОВ ПРИЧ НЕПРОШ ЕД ЖЕН ТВОР
V НЕСОВ ПРИЧ НЕПРОШ ЕД МУЖ ВИН НЕОД
V НЕСОВ ПРИЧ НЕПРОШ ЕД МУЖ ВИН ОД
V НЕСОВ ПРИЧ НЕПРОШ ЕД МУЖ ДАТ
V НЕСОВ ПРИЧ НЕПРОШ ЕД МУЖ ИМ
V НЕСОВ ПРИЧ НЕПРОШ ЕД МУЖ ПР
V НЕСОВ ПРИЧ НЕПРОШ ЕД МУЖ РОД
V НЕСОВ ПРИЧ НЕПРОШ ЕД МУЖ ТВОР
V НЕСОВ ПРИЧ НЕПРОШ ЕД СРЕД ВИН
V НЕСОВ ПРИЧ НЕПРОШ ЕД СРЕД ИМ
V НЕСОВ ПРИЧ НЕПРОШ ЕД СРЕД ПР
V НЕСОВ ПРИЧ НЕПРОШ ЕД СРЕД РОД
V НЕСОВ ПРИЧ НЕПРОШ ЕД СРЕД ТВОР
V НЕСОВ ПРИЧ НЕПРОШ МН ВИН НЕОД
V НЕСОВ ПРИЧ НЕПРОШ МН ВИН ОД
V НЕСОВ ПРИЧ НЕПРОШ МН ДАТ
V НЕСОВ ПРИЧ НЕПРОШ МН ИМ
V НЕСОВ ПРИЧ НЕПРОШ МН ПР
V НЕСОВ ПРИЧ НЕПРОШ МН РОД
V НЕСОВ ПРИЧ НЕПРОШ МН ТВОР
V НЕСОВ ПРИЧ ПРОШ ЕД ЖЕН ДАТ
V НЕСОВ ПРИЧ ПРОШ ЕД ЖЕН ИМ
V НЕСОВ ПРИЧ ПРОШ ЕД ЖЕН ПР
V НЕСОВ ПРИЧ ПРОШ ЕД ЖЕН ТВОР
V НЕСОВ ПРИЧ ПРОШ ЕД МУЖ ВИН НЕОД
V НЕСОВ ПРИЧ ПРОШ ЕД МУЖ ИМ
V НЕСОВ ПРИЧ ПРОШ ЕД МУЖ РОД
V НЕСОВ ПРИЧ ПРОШ ЕД МУЖ ТВОР
V НЕСОВ ПРИЧ ПРОШ ЕД СРЕД ВИН
V НЕСОВ ПРИЧ ПРОШ МН ВИН НЕОД
V НЕСОВ ПРИЧ ПРОШ МН ВИН ОД
V НЕСОВ ПРИЧ ПРОШ МН ДАТ
V НЕСОВ ПРИЧ ПРОШ МН ИМ
V НЕСОВ ПРИЧ ПРОШ МН РОД
V НЕСОВ ПРИЧ ПРОШ МН ТВОР
V НЕСОВ СТРАД ИЗЪЯВ НЕПРОШ ЕД 3-Л
V НЕСОВ СТРАД ИЗЪЯВ НЕПРОШ МН 3-Л
V НЕСОВ СТРАД ИЗЪЯВ ПРОШ ЕД ЖЕН
V НЕСОВ СТРАД ИЗЪЯВ ПРОШ ЕД МУЖ
V НЕСОВ СТРАД ИЗЪЯВ ПРОШ ЕД СРЕД
V НЕСОВ СТРАД ИЗЪЯВ ПРОШ МН
V НЕСОВ СТРАД ИНФ
V НЕСОВ СТРАД ПРИЧ НЕПРОШ ЕД ЖЕН ИМ
V НЕСОВ СТРАД ПРИЧ НЕПРОШ ЕД ЖЕН РОД
V НЕСОВ СТРАД ПРИЧ НЕПРОШ ЕД ЖЕН ТВОР
V НЕСОВ СТРАД ПРИЧ НЕПРОШ ЕД МУЖ ИМ
V НЕСОВ СТРАД ПРИЧ НЕПРОШ ЕД МУЖ РОД
V НЕСОВ СТРАД ПРИЧ НЕПРОШ ЕД МУЖ ТВОР
V НЕСОВ СТРАД ПРИЧ НЕПРОШ ЕД СРЕД ВИН
V НЕСОВ СТРАД ПРИЧ НЕПРОШ ЕД СРЕД ИМ
V НЕСОВ СТРАД ПРИЧ НЕПРОШ ЕД СРЕД РОД
V НЕСОВ СТРАД ПРИЧ НЕПРОШ МН ВИН НЕОД
V НЕСОВ СТРАД ПРИЧ НЕПРОШ МН ИМ
V НЕСОВ СТРАД ПРИЧ НЕПРОШ МН РОД
V НЕСОВ СТРАД ПРИЧ ПРОШ ЕД ЖЕН ВИН
V НЕСОВ СТРАД ПРИЧ ПРОШ ЕД МУЖ ВИН ОД
V НЕСОВ СТРАД ПРИЧ ПРОШ ЕД СРЕД ВИН
V НЕСОВ СТРАД ПРИЧ ПРОШ ЕД СРЕД ИМ
V НЕСОВ СТРАД ПРИЧ ПРОШ КР ЕД ЖЕН
V НЕСОВ СТРАД ПРИЧ ПРОШ КР ЕД СРЕД
V НЕСОВ СТРАД ПРИЧ ПРОШ КР МН
V НЕСОВ СТРАД ПРИЧ ПРОШ МН ИМ
V СОВ ДЕЕПР НЕПРОШ
V СОВ ДЕЕПР ПРОШ
V СОВ ДЕЕПР ПРОШ НЕПРАВ
V СОВ ИЗЪЯВ НЕПРОШ ЕД 1-Л
V СОВ ИЗЪЯВ НЕПРОШ ЕД 1-Л НЕСТАНД
V СОВ ИЗЪЯВ НЕПРОШ ЕД 2-Л
V СОВ ИЗЪЯВ НЕПРОШ ЕД 3-Л
V СОВ ИЗЪЯВ НЕПРОШ МН 1-Л
V СОВ ИЗЪЯВ НЕПРОШ МН 2-Л
V СОВ ИЗЪЯВ НЕПРОШ МН 3-Л
V СОВ ИЗЪЯВ ПРОШ ЕД ЖЕН
V СОВ ИЗЪЯВ ПРОШ ЕД МУЖ
V СОВ ИЗЪЯВ ПРОШ ЕД СРЕД
V СОВ ИЗЪЯВ ПРОШ МН
V СОВ ИНФ
V СОВ ПОВ ЕД 2-Л
V СОВ ПОВ ЕД 2-Л НЕСТАНД
V СОВ ПОВ МН 1-Л
V СОВ ПОВ МН 2-Л
V СОВ ПРИЧ ПРОШ ЕД ЖЕН ВИН
V СОВ ПРИЧ ПРОШ ЕД ЖЕН ДАТ
V СОВ ПРИЧ ПРОШ ЕД ЖЕН ИМ
V СОВ ПРИЧ ПРОШ ЕД ЖЕН ПР
V СОВ ПРИЧ ПРОШ ЕД ЖЕН ТВОР
V СОВ ПРИЧ ПРОШ ЕД МУЖ ВИН НЕОД
V СОВ ПРИЧ ПРОШ ЕД МУЖ ВИН ОД
V СОВ ПРИЧ ПРОШ ЕД МУЖ ДАТ
V СОВ ПРИЧ ПРОШ ЕД МУЖ ИМ
V СОВ ПРИЧ ПРОШ ЕД МУЖ ПР
V СОВ ПРИЧ ПРОШ ЕД МУЖ РОД
V СОВ ПРИЧ ПРОШ ЕД МУЖ ТВОР
V СОВ ПРИЧ ПРОШ ЕД СРЕД ВИН
V СОВ ПРИЧ ПРОШ ЕД СРЕД ИМ
V СОВ ПРИЧ ПРОШ ЕД СРЕД ПР
V СОВ ПРИЧ ПРОШ ЕД СРЕД РОД
V СОВ ПРИЧ ПРОШ ЕД СРЕД ТВОР
V СОВ ПРИЧ ПРОШ МН ВИН НЕОД
V СОВ ПРИЧ ПРОШ МН ВИН ОД
V СОВ ПРИЧ ПРОШ МН ИМ
V СОВ ПРИЧ ПРОШ МН ПР
V СОВ ПРИЧ ПРОШ МН РОД
V СОВ ПРИЧ ПРОШ МН ТВОР
V СОВ СТРАД ПРИЧ ПРОШ ЕД ЖЕН ВИН
V СОВ СТРАД ПРИЧ ПРОШ ЕД ЖЕН ДАТ
V СОВ СТРАД ПРИЧ ПРОШ ЕД ЖЕН ИМ
V СОВ СТРАД ПРИЧ ПРОШ ЕД ЖЕН ПР
V СОВ СТРАД ПРИЧ ПРОШ ЕД ЖЕН РОД
V СОВ СТРАД ПРИЧ ПРОШ ЕД ЖЕН ТВОР
V СОВ СТРАД ПРИЧ ПРОШ ЕД МУЖ ВИН НЕОД
V СОВ СТРАД ПРИЧ ПРОШ ЕД МУЖ ДАТ
V СОВ СТРАД ПРИЧ ПРОШ ЕД МУЖ ИМ
V СОВ СТРАД ПРИЧ ПРОШ ЕД МУЖ ПР
V СОВ СТРАД ПРИЧ ПРОШ ЕД МУЖ РОД
V СОВ СТРАД ПРИЧ ПРОШ ЕД МУЖ ТВОР
V СОВ СТРАД ПРИЧ ПРОШ ЕД СРЕД ВИН
V СОВ СТРАД ПРИЧ ПРОШ ЕД СРЕД ИМ
V СОВ СТРАД ПРИЧ ПРОШ ЕД СРЕД ПР
V СОВ СТРАД ПРИЧ ПРОШ ЕД СРЕД РОД
V СОВ СТРАД ПРИЧ ПРОШ ЕД СРЕД ТВОР
V СОВ СТРАД ПРИЧ ПРОШ КР ЕД ЖЕН
V СОВ СТРАД ПРИЧ ПРОШ КР ЕД МУЖ
V СОВ СТРАД ПРИЧ ПРОШ КР ЕД СРЕД
V СОВ СТРАД ПРИЧ ПРОШ КР МН
V СОВ СТРАД ПРИЧ ПРОШ МН ВИН НЕОД
V СОВ СТРАД ПРИЧ ПРОШ МН ВИН ОД
V СОВ СТРАД ПРИЧ ПРОШ МН ДАТ
V СОВ СТРАД ПРИЧ ПРОШ МН ИМ
V СОВ СТРАД ПРИЧ ПРОШ МН ПР
V СОВ СТРАД ПРИЧ ПРОШ МН РОД
V СОВ СТРАД ПРИЧ ПРОШ МН ТВОР
end_of_list
    ;
    # Protect from editors that replace tabs by spaces.
    $list =~ s/ \s+/\t/sg;
    my @list = split(/\r?\n/, $list);
    pop(@list) if($list[$#list] eq "");
    return \@list;
}



1;

=head1 SYNOPSIS

  use Lingua::Interset::Tagset::RU::Syntagrus;
  my $driver = Lingua::Interset::Tagset::RU::Syntagrus->new();
  my $fs = $driver->decode('S ЕД МУЖ ИМ');

or

  use Lingua::Interset qw(decode);
  my $fs = decode('ru::syntagrus', 'S ЕД МУЖ ИМ');

=head1 DESCRIPTION

Interset driver for Syntagrus (Russian Dependency Treebank) tags.

=head1 SEE ALSO

L<Lingua::Interset>,
L<Lingua::Interset::Tagset>,
L<Lingua::Interset::FeatureStructure>

=cut
