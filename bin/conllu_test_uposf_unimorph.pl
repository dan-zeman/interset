#!/usr/bin/env perl
# Reads CoNLL-U from STDIN, converts UPOS+FEATS to UniMorph, saves UniMorph as
# XPOS, writes the result to STDOUT. Checks round-trip conversion, looking for
# UD features that we cannot represent in UniMorph.
# Copyright © 2023 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Lingua::Interset qw(decode encode list);

sub usage
{
    print STDERR ("Usage: $0 < input.conllu > output.conllu\n");
}

my %uposf2um;
my %um2uposf;
my %reported;

# Read the CoNLL-U file from STDIN or from files given as arguments.
while(<>)
{
    unless(m/^\#/ || m/^\s*$/)
    {
        chomp();
        my @f = split(/\t/, $_);
        my $uposf = "$f[3]\t$f[5]";
        my $unimorph = $uposf2um{$uposf};
        if(!defined($unimorph))
        {
            my $fs1 = reset_non_unimorph_features(decode('mul::uposf', $uposf));
            my $uposf1 = encode('mul::uposf', $fs1);
            $unimorph = encode('mul::unimorph', $fs1);
            $uposf2um{$uposf} = $unimorph;
            # Check the round-trip conversion.
            my $uposf2 = $um2uposf{$unimorph};
            if(!defined($uposf2))
            {
                my $fs2 = decode('mul::unimorph', $unimorph);
                $uposf2 = encode('mul::uposf', $fs2);
                $um2uposf{$unimorph} = $uposf2;
            }
            if($uposf2 ne $uposf1)
            {
                my $message = sprintf("Roundtrip failed: '%s' --> '%s' --> '%s' --> '%s' ... '%s'\n", $uposf, $uposf1, $unimorph, $uposf2, $f[1]);
                unless(exists($reported{$message}))
                {
                    print STDERR ($message);
                    $reported{$message}++;
                }
            }
        }
        # Replace the current XPOS tag, if any, with UniMorph.
        $f[4] = defined($unimorph) && $unimorph ne '' ? $unimorph : '_';
        $_ = join("\t", @f)."\n";
    }
    # Write the modified line to the standard output.
    print();
}
my $n = scalar(keys(%reported));
print STDERR ("Total $n roundtrip conversions failed.\n");



#------------------------------------------------------------------------------
# Removes from a feature structure the features that we know cannot be
# represented in UniMorph. This way we only report roundtrip mismatches that
# are of some interest.
#------------------------------------------------------------------------------
sub reset_non_unimorph_features
{
    my $fs = shift;
    $fs->clear('pos') if($fs->is_punctuation() || $fs->is_symbol());
    $fs->clear('nametype');
    $fs->set('prontype', 'prn') if($fs->prontype());
    $fs->clear('poss');
    $fs->clear('reflex');
    $fs->set('numtype', 'card') if($fs->numtype() eq 'frac');
    $fs->clear('numtype') unless($fs->numtype() eq 'card' && $fs->prontype() eq '');
    $fs->clear('numform');
    $fs->clear('numvalue');
    $fs->clear('adpostype');
    $fs->clear('conjtype') if($fs->conjtype() eq 'oper');
    $fs->clear('verbform') if($fs->pos() eq 'noun'); # use V.MASDAR only for VERB + VerbForm=Vnoun
    $fs->set('pos', 'verb') if($fs->verbform() eq 'part');
    $fs->clear('prepcase');
    $fs->clear('degree') if($fs->degree() eq 'pos');
    $fs->clear('variant');
    $fs->clear('foreign');
    $fs->clear('abbr');
    $fs->clear('hyph');
    $fs->clear('style');
    $fs->clear('typo');
    # UniMorph also cannot express multi-values (e.g. Gender=Masc,Neut).
    foreach my $key (keys(%{$fs}))
    {
        my $value = $fs->get($key);
        if(ref($value) eq 'ARRAY')
        {
            $value = $value->[0];
            $fs->set($key, $value);
        }
    }
    return $fs;
}
