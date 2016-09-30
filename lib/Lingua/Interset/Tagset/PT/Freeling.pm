# ABSTRACT: Driver for the EAGLES-based tagset for Portuguese in Freeling.
# Copyright © 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset::Tagset::PT::Freeling;
use strict;
use warnings;
our $VERSION = '2.053';

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
extends 'Lingua::Interset::Tagset';



has 'atoms'       => ( isa => 'HashRef', is => 'ro', builder => '_create_atoms',       lazy => 1 );
has 'feature_map' => ( isa => 'HashRef', is => 'ro', builder => '_create_feature_map', lazy => 1 );



#------------------------------------------------------------------------------
# Returns the tagset id that should be set as the value of the 'tagset' feature
# during decoding. Every derived class must (re)define this method! The result
# should correspond to the last two parts in package name, lowercased.
#------------------------------------------------------------------------------
sub get_tagset_id
{
    return 'pt::freeling';
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
            # noun
            'N' => ['pos' => 'noun'],
            # adjective
            'A' => ['pos' => 'adj'],
            # pronoun
            'P' => ['pos' => 'noun', 'prontype' => 'prn'],
            # determiner (but not article)
            'D' => ['pos' => 'adj', 'prontype' => 'prn'],
            # number
            'Z' => ['pos' => 'num'],
            # date
            # We don't have a specific feature for dates. Maybe we should use the 'other' feature.
            'W' => ['pos' => 'num', 'nountype' => 'prop'],
            # verb
            'V' => ['pos' => 'verb'],
            # adverb
            'R' => ['pos' => 'adv'],
            # adposition
            'S' => ['pos' => 'adp', 'adpostype' => 'prep'],
            # conjunction
            'C' => ['pos' => 'conj'],
            # interjection
            'I' => ['pos' => 'int'],
            # punctuation
            'F' => ['pos' => 'punc']
        },
        'encode_map' =>
        {
            'pos' => { 'noun' => { 'prontype' => { ''  => 'N',
                                                   '@' => 'P' }},
                       'adj'  => { 'prontype' => { ''  => 'A',
                                                   '@' => 'D' }},
                       'num'  => { 'nountype' => { 'prop' => 'W',
                                                   '@'    => 'Z' }},
                       'verb' => 'V',
                       'adv'  => 'R',
                       'adp'  => 'S',
                       'conj' => 'C',
                       'int'  => 'I',
                       'punc' => 'F' }
        }
    );
    # NOUNTYPE ####################
    $atoms{nountype} = $self->create_simple_atom
    (
        'intfeature' => 'nountype',
        'simple_decode_map' =>
        {
            'C' => 'com',
            'P' => 'prop'
        }
    );
    # NAMETYPE ####################
    $atoms{nametype} = $self->create_simple_atom
    (
        'intfeature' => 'nametype',
        'simple_decode_map' =>
        {
            'S' => 'prs',
            'G' => 'geo',
            'O' => 'com',
            'V' => 'oth'
        },
        'encode_default' => '0'
    );
    # ADJTYPE ####################
    $atoms{adjtype} = $self->create_atom
    (
        'surfeature' => 'adjtype',
        'decode_map' =>
        {
            # qualificative adjective
            'Q' => [],
            # possessive adjective
            'P' => ['poss' => 'poss'],
            # ordinal numeral/adjective
            'O' => ['numtype' => 'ord']
        },
        'encode_map' =>
        {
            'numtype' => { 'ord' => 'O',
                           '@'   => { 'poss' => { 'poss' => 'P',
                                                  '@'    => 'Q' }}}
        }
    );
    # PRONTYPE ####################
    $atoms{prontype} = $self->create_atom
    (
        'surfeature' => 'prontype',
        'decode_map' =>
        {
            # personal pronoun
            # OR possessive determiner (depends on the first character of the tag)
            'P' => ['prontype' => 'prs'],
            # article
            'A' => ['prontype' => 'art'],
            # demonstrative pronoun
            'D' => ['prontype' => 'dem'],
            # indefinite pronoun
            'I' => ['prontype' => 'ind'],
            # interrogative pronoun
            'T' => ['prontype' => 'int'],
            # relative pronoun
            'R' => ['prontype' => 'rel'],
            # exclamative pronoun
            'E' => ['prontype' => 'exc'],
            # numeral (?)
            'N' => ['numtype' => 'card']
        },
        'encode_map' =>
        {
            'poss' => { 'poss' => 'P',
                        '@'    => { 'prontype' => { 'prs' => 'P',
                                                    'art' => 'A',
                                                    'dem' => 'D',
                                                    'ind' => 'I',
                                                    'int' => 'T',
                                                    'rel' => 'R',
                                                    'exc' => 'E',
                                                    '@'   => 'N' }}}
        }
    );
    # NUMTYPE ####################
    # d: partitive; m: currency; p: ratio; u: unit
    ###!!!
    $atoms{numtype} = $self->create_atom
    (
        'surfeature' => 'numtype',
        'decode_map' =>
        {
        },
        'encode_map' =>
        {
            'numtype' => { '@' => '0' }
        }
    );
    # VERBTYPE ####################
    $atoms{verbtype} = $self->create_atom
    (
        'surfeature' => 'verbtype',
        'decode_map' =>
        {
            # main verb
            'M' => [],
            # auxiliary verb
            'A' => ['verbtype' => 'aux'],
            # semiauxiliary verb
            'S' => ['verbtype' => 'aux', 'other' => {'verbtype' => 'semi'}]
        },
        'encode_map' =>
        {
            'verbtype' => { 'aux' => { 'other/verbtype' => { 'semi' => 'S',
                                                             '@'    => 'A' }},
                            '@'   => 'M' }
        }
    );
    # ADVTYPE ####################
    $atoms{advtype} = $self->create_atom
    (
        'surfeature' => 'advtype',
        'decode_map' =>
        {
            # general adverb
            'G' => [],
            # negative adverb (particle)
            'N' => ['prontype' => 'neg']
        },
        'encode_map' =>
        {
            'prontype' => { 'neg' => 'N',
                            '@'   => 'G' }
        }
    );
    # CONJTYPE ####################
    $atoms{conjtype} = $self->create_atom
    (
        'surfeature' => 'conjtype',
        'decode_map' =>
        {
            # coordinating conjunction
            'C' => ['conjtype' => 'coor'],
            # subordinating conjunction
            'S' => ['conjtype' => 'sub']
        },
        'encode_map' =>
        {
            'conjtype' => { 'coor' => 'C',
                            'sub'  => 'S',
                            '@'    => 'C' }
        }
    );
    # GENDER ####################
    $atoms{gender} = $self->create_atom
    (
        'surfeature' => 'gender',
        'decode_map' =>
        {
            'M' => ['gender' => 'masc'],
            'F' => ['gender' => 'fem'],
            'N' => ['gender' => 'neut'],
            # Common is not the common gender in the Scandinavian sense. It is just indistinguishable between M and F.
            # That's why we do not set 'gender' => 'com'.
            'C' => ['other' => {'gender' => 'common'}]
        },
        'encode_map' =>
        {
            'gender' => { 'masc' => 'M',
                          'fem'  => 'F',
                          'neut' => 'N',
                          '@'    => { 'other/gender' => { 'common' => 'C',
                                                          '@'      => '0' }}}
        }
    );
    # NUMBER ####################
    $atoms{number} = $self->create_simple_atom
    (
        'intfeature' => 'number',
        'simple_decode_map' =>
        {
            'S' => 'sing',
            'P' => 'plur',
            # Invariable.
            #'N' => ''
        },
        ###!!! We are conflating N and 0. Without a genuine list of tags and Portuguese examples, it is hard to say where either of them will occur.
        'encode_default' => '0'
    );
    # CASE ####################
    $atoms{case} = $self->create_simple_atom
    (
        'intfeature' => 'case',
        'simple_decode_map' =>
        {
            'N' => 'nom',
            'D' => 'dat',
            'A' => 'acc',
            # Oblique. ###!!! What is it and how does it differ from the other cases?
            #'O' => 'acc',
        },
        'encode_default' => '0'
    );
    # DEGREE ####################
    $atoms{degree} = $self->create_simple_atom
    (
        'intfeature' => 'degree',
        'simple_decode_map' =>
        {
            # Evaluative. ###!!!???
            'V' => 'pos',
            'S' => 'sup',
            # For nouns: augmentative and diminutive.
            'A' => 'aug',
            'D' => 'dim'
        },
        'encode_default' => '0'
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
        {
            'person' => { '1' => '1',
                          '2' => '2',
                          '3' => '3',
                          '@' => '0' }
        }
    );
    # POLITENESS ####################
    $atoms{politeness} = $self->create_simple_atom
    (
        'intfeature' => 'politeness',
        'simple_decode_map' =>
        {
            'P' => 'pol'
        }
    );
    # OWNER NUMBER ####################
    $atoms{possnumber} = $self->create_simple_atom
    (
        'intfeature' => 'possnumber',
        'simple_decode_map' =>
        {
            'S' => 'sing',
            'P' => 'plur',
            # Invariable.
            #'N' => ''
        },
        ###!!! We are conflating N and 0. Without a genuine list of tags and Portuguese examples, it is hard to say where either of them will occur.
        'encode_default' => '0'
    );
    # VERB FORM ####################
    $atoms{verbform} = $self->create_atom
    (
        'surfeature' => 'verbform',
        'decode_map' =>
        {
            'I' => ['verbform' => 'fin', 'mood' => 'ind'],
            'M' => ['verbform' => 'fin', 'mood' => 'imp'],
            'S' => ['verbform' => 'fin', 'mood' => 'sub'],
            'N' => ['verbform' => 'inf'],
            # Past participle.
            'P' => ['verbform' => 'part'],
            # Gerund (meaning present participle in Romance languages).
            'G' => ['verbform' => 'ger']
        },
        'encode_map' =>
        {
            'mood' => { 'imp' => 'M',
                        'sub' => 'S',
                        'ind' => 'I',
                        # Conditional is considered a tense in Portuguese but a mood in Interset.
                        # Even in Portuguese we cannot say that it belongs to one of the existing moods, so it could be a mood of its own.
                        'cnd' => '0',
                        '@'   => { 'verbform' => { 'part' => 'P',
                                                   'ger'  => 'G',
                                                   'inf'  => 'N',
                                                   '@'    => '0' }}}
        }
    );
    # TENSE ####################
    $atoms{tense} = $self->create_atom
    (
        'surfeature' => 'tense',
        'decode_map' =>
        {
            'P' => ['tense' => 'pres'],
            'F' => ['tense' => 'fut'],
            'S' => ['tense' => 'past'],
            'I' => ['tense' => 'imp'],
            'M' => ['tense' => 'pqp'],
            # Portuguese grammar treats conditional as a tense while in Interset it is a mood.
            'C' => ['mood' => 'cnd']
        },
        'encode_map' =>
        {
            'mood' => { 'cnd' => 'C',
                        '@'   => { 'tense' => { 'pres' => 'P',
                                                'fut'  => 'F',
                                                'past' => 'S',
                                                'imp'  => 'I',
                                                'pqp'  => 'M',
                                                '@'    => '0' }}}
        }
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
    $atoms{adverb_type} = $self->create_atom
    (
        'surfeature' => 'adverb_type',
        'decode_map' =>
        {
            # general adverb
            'G' => [],
            # negative adverb
            'N' => ['prontype' => 'neg'],
        },
        'encode_map' =>
        {
            'prontype' => { 'neg' => 'N',
                            '@'   => 'G' }
        }
    );
    # ADPOSITION TYPE ####################
    $atoms{adpostype} = $self->create_atom
    (
        'surfeature' => 'adpostype',
        'decode_map' =>
        {
            'P' => ['adpostype' => 'prep']
        },
        'encode_map' =>
        {
            'adpostype' => { '@' => 'P' }
        }
    );
    # PUNCTUATION TYPE ####################
    $atoms{restype} = $self->create_atom
    (
        'surfeature' => 'punctype',
        'decode_map' =>
        {
            'd'  => ['punctype' => 'colo'], # colon
            'c'  => ['punctype' => 'comm'], # comma
            'la' => ['punctype' => 'brck', 'puncside' => 'ini'], # opening curly bracket
            'lt' => ['punctype' => 'brck', 'puncside' => 'fin'], # closing curly bracket
            's'  => [], # etc
            'aa' => ['punctype' => 'excl', 'puncside' => 'ini'], # opening exclamation mark
            'at' => ['punctype' => 'excl', 'puncside' => 'fin'], # closing exclamation mark
            'g'  => ['punctype' => 'dash'], # hyphen
            'z'  => [], # other
            'pa' => ['punctype' => 'brck', 'puncside' => 'ini'], # opening parenthesis
            'pt' => ['punctype' => 'brck', 'puncside' => 'fin'], # closing parenthesis
            't'  => [], # percentage
            'p'  => ['punctype' => 'peri'], # period
            'ia' => ['punctype' => 'qest', 'puncside' => 'ini'], # opening question mark
            'it' => ['punctype' => 'qest', 'puncside' => 'fin'], # closing question mark
            'e'  => ['punctype' => 'quot'], # quotation
            'ra' => ['punctype' => 'quot', 'puncside' => 'ini'], # opening quotation
            'rc' => ['punctype' => 'quot', 'puncside' => 'fin'], # closing quotation
            'x'  => ['punctype' => 'semi'], # semicolon
            'h'  => [], # slash
            'ca' => ['punctype' => 'brck', 'puncside' => 'ini'], # opening square bracket
            'ct' => ['punctype' => 'brck', 'puncside' => 'fin']  # closing square bracket
        },
        'encode_map' =>
        {
            'punctype' => { 'colo' => 'd',
                            'comm' => 'c',
                            'dash' => 'g',
                            'peri' => 'p',
                            'semi' => 'x' }
        }
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
        # Declaring a feature as undef means that there will be always a zero at that position of the tag.
        'N' => ['pos', 'nountype', 'gender', 'number', 'nametype', undef, 'degree'],
        'A' => ['pos', 'adjtype', 'degree', 'gender', 'number', 'person', 'possnumber'],
        'P' => ['pos', 'prontype', 'person', 'gender', 'number', 'case', 'politeness'],
        'D' => ['pos', 'prontype', 'person', 'gender', 'number', 'possnumber'],
        'Z' => ['pos', 'numtype'],
        'W' => ['pos'],
        'V' => ['pos', 'verbtype', 'verbform', 'tense', 'person', 'number', 'gender'],
        'R' => ['pos', 'advtype'],
        'S' => ['pos', 'adpostype'],
        'C' => ['pos', 'conjtype'],
        'I' => ['pos'],
        'F' => ['pos', 'punctype']
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
            $tag .= '0';
        }
    }
    # Even without 'other' being set, we can sometimes disambiguate between the common gender and 0.
    $tag =~ s/^(N.)0/${1}C/;
    $tag =~ s/^(A..)0/${1}C/;
    $tag =~ s/^(A...)0/${1}N/;
    # Remove trailing zeroes.
    $tag =~ s/0+$//;
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
#------------------------------------------------------------------------------
sub list
{
    my $self = shift;
    my $list = <<end_of_list
NCMS
NCMS00A
NCMS00D
NCMP
NCMP00A
NCMP00D
NCFS
NCFS00A
NCFS00D
NCFP
NCFP00A
NCFP00D
NCCS
NCCP
NCNS
NPMSS
NPMSS0A
NPMSS0D
NPMPS
NPMPS0A
NPMPS0D
NPFSS
NPFSS0A
NPFSS0D
NPFPS
NPFPS0A
NPFPS0D
NPCSS
NPCPS
NPMSG
NPMPG
NPFSG
NPFPG
NPCSG
NPCPG
NPMSO
NPMPO
NPFSO
NPFPO
NPCSO
NPCPO
NPMSV
NPMPV
NPFSV
NPFPV
NPCSV
NPCPV
AQVMS
AQVMP
AQVFS
AQVFP
AQVCS
AQVCP
AQVCN
AQSMS
AQSMP
AQSFS
AQSFP
AQSCS
AQSCP
AQSCN
APVMS1S
APVMS2S
APVMS3S
APVMS1P
APVMS2P
APVMS3P
APVMP1S
APVMP2S
APVMP3S
APVMP1P
APVMP2P
APVMP3P
APVFS1S
APVFS2S
APVFS3S
APVFS1P
APVFS2P
APVFS3P
APVFP1S
APVFP2S
APVFP3S
APVFP1P
APVFP2P
APVFP3P
APVCS1S
APVCS2S
APVCS3S
APVCS1P
APVCS2P
APVCS3P
APVCP1S
APVCP2S
APVCP3S
APVCP1P
APVCP2P
APVCP3P
APVCN1S
APVCN2S
APVCN3S
APVCN1P
APVCN2P
APVCN3P
AOVMS
AOVMP
AOVFS
AOVFP
AOVCS
AOVCP
AOVCN
PP10SN
PP10SD
PP10SA
PP20SN
PP20SD
PP20SA
PP20SNP
PP20SDP
PP20SAP
PP3MSN
PP3MSD
PP3MSA
PP3FSN
PP3FSD
PP3FSA
PP10PN
PP10PD
PP10PA
PP20PN
PP20PD
PP20PA
PP20PNP
PP20PDP
PP20PAP
PP3MPN
PP3MPD
PP3MPA
PP3FPN
PP3FPD
PP3FPA
PD
PT
PR
PE
DA0MS
DA0FS
DA0MP
DA0FP
DP1MSS
DP1MPS
DP1FSS
DP1FPS
DP2MSS
DP2MPS
DP2FSS
DP2FPS
DP3MSS
DP3MPS
DP3FSS
DP3FPS
DP1MSP
DP1MPP
DP1FSP
DP1FPP
DP2MSP
DP2MPP
DP2FSP
DP2FPP
DP3MSP
DP3MPP
DP3FSP
DP3FPP
DD0MS
DD0FS
DD0MP
DD0FP
DT
DR
DE
Z
W
VMN
VMIP1S
VMIP2S
VMIP3S
VMIP1P
VMIP2P
VMIP3P
VMIF1S
VMIF2S
VMIF3S
VMIF1P
VMIF2P
VMIF3P
VMIS1S
VMIS2S
VMIS3S
VMIS1P
VMIS2P
VMIS3P
VMII1S
VMII2S
VMII3S
VMII1P
VMII2P
VMII3P
VMIM1S
VMIM2S
VMIM3S
VMIM1P
VMIM2P
VMIM3P
VMSP1S
VMSP2S
VMSP3S
VMSP1P
VMSP2P
VMSP3P
VMSF1S
VMSF2S
VMSF3S
VMSF1P
VMSF2P
VMSF3P
VMSI1S
VMSI2S
VMSI3S
VMSI1P
VMSI2P
VMSI3P
VM0C1S
VM0C2S
VM0C3S
VM0C1P
VM0C2P
VM0C3P
VMM02S
VMM03S
VMM01P
VMM02P
VMM03P
VMPS0SM
VMPS0SF
VMPS0PM
VMPS0PF
VMGP0SM
VMGP0SF
VMGP0PM
VMGP0PF
VAN
VAIP1S
VAIP2S
VAIP3S
VAIP1P
VAIP2P
VAIP3P
VAIF1S
VAIF2S
VAIF3S
VAIF1P
VAIF2P
VAIF3P
VAIS1S
VAIS2S
VAIS3S
VAIS1P
VAIS2P
VAIS3P
VAII1S
VAII2S
VAII3S
VAII1P
VAII2P
VAII3P
VAIM1S
VAIM2S
VAIM3S
VAIM1P
VAIM2P
VAIM3P
VASP1S
VASP2S
VASP3S
VASP1P
VASP2P
VASP3P
VASF1S
VASF2S
VASF3S
VASF1P
VASF2P
VASF3P
VASI1S
VASI2S
VASI3S
VASI1P
VASI2P
VASI3P
VA0C1S
VA0C2S
VA0C3S
VA0C1P
VA0C2P
VA0C3P
VAM02S
VAM03S
VAM01P
VAM02P
VAM03P
VAPS0SM
VAPS0SF
VAPS0PM
VAPS0PF
VAGP0SM
VAGP0SF
VAGP0PM
VAGP0PF
VSN
VSIP1S
VSIP2S
VSIP3S
VSIP1P
VSIP2P
VSIP3P
VSIF1S
VSIF2S
VSIF3S
VSIF1P
VSIF2P
VSIF3P
VSIS1S
VSIS2S
VSIS3S
VSIS1P
VSIS2P
VSIS3P
VSII1S
VSII2S
VSII3S
VSII1P
VSII2P
VSII3P
VSIM1S
VSIM2S
VSIM3S
VSIM1P
VSIM2P
VSIM3P
VSSP1S
VSSP2S
VSSP3S
VSSP1P
VSSP2P
VSSP3P
VSSF1S
VSSF2S
VSSF3S
VSSF1P
VSSF2P
VSSF3P
VSSI1S
VSSI2S
VSSI3S
VSSI1P
VSSI2P
VSSI3P
VS0C1S
VS0C2S
VS0C3S
VS0C1P
VS0C2P
VS0C3P
VSM02S
VSM03S
VSM01P
VSM02P
VSM03P
VSPS0SM
VSPS0SF
VSPS0PM
VSPS0PF
VSGP0SM
VSGP0SF
VSGP0PM
VSGP0PF
RG
RN
SP
CC
CS
I
end_of_list
    ;
    my @list = split(/\r?\n/, $list);
    pop(@list) if($list[$#list] eq '');
    return \@list;
}



1;

=head1 SYNOPSIS

  use Lingua::Interset::Tagset::PT::Freeling;
  my $driver = Lingua::Interset::Tagset::PT::Freeling->new();
  my $fs = $driver->decode('NCMS');

or

  use Lingua::Interset qw(decode);
  my $fs = decode('pt::freeling', 'NCMS');

=head1 DESCRIPTION

Interset driver for the EAGLES-based Portuguese tagset from the Freeling project
(L<http://talp-upc.gitbooks.io/freeling-user-manual/content/tagsets/tagset-pt.html>).

=head1 SEE ALSO

L<Lingua::Interset>,
L<Lingua::Interset::Tagset>,
L<Lingua::Interset::FeatureStructure>

=cut
