#!/usr/bin/perl
# Tagset service functions.
# (c) 2007 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

sub usage
{
    print STDERR ("Usage: driver-test.pl [-d] driver\n");
    print STDERR ("  driver name example: ar::conll\n");
    print STDERR ("  -d: debug mode (list tags being tested)\n");
}

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use Getopt::Long;
use Carp; # confess()

# Get options.
$debug = 0;
GetOptions('debug' => \$debug);
# Mandatory information: driver name relative to the tagset folder.
if(scalar(@ARGV)<1)
{
    usage();
    my $drivers = find_drivers();
    if(scalar(@{$drivers}))
    {
        print STDERR ("\nThe following tagset drivers are available on this system:\n");
        print STDERR (join("", map {"$_\n"} sort @{$drivers}));
    }
    else
    {
        print STDERR ("\nNo tagset drivers have been found on this system.\n");
    }
    exit;
}
$driver = $ARGV[0];
# Test the driver.
test($driver);



#------------------------------------------------------------------------------
# Tries to enumerate existing tagset drivers. Searches for the "tagset" folder
# in @INC paths. Once found, it searches its subfolders and lists all modules.
#------------------------------------------------------------------------------
sub find_drivers
{
    my @drivers;
    foreach my $path (@INC)
    {
        my $tpath = "$path/tagset";
        if(-d $tpath)
        {
            opendir(DIR, $tpath) or die("Cannot read folder $tpath: $!\n");
            my @subdirs = readdir(DIR);
            closedir(DIR);
            foreach my $sd (@subdirs)
            {
                my $sdpath = "$tpath/$sd";
                if(-d $sdpath && $sd !~ m/^\.\.?$/)
                {
                    opendir(DIR, $sdpath) or die("Cannot read folder $sdpath: $!\n");
                    my @files = readdir(DIR);
                    closedir(DIR);
                    foreach my $file (@files)
                    {
                        my $fpath = "$sdpath/$file";
                        my $driver = $file;
                        if(-f $fpath && $driver =~ s/\.pm$//)
                        {
                            $driver = $sd."::".$driver;
                            push(@drivers, $driver);
                        }
                    }
                }
            }
        }
    }
    return \@drivers;
}



#------------------------------------------------------------------------------
# Tests that encode(decode(tag))=tag for all tags in list().
#------------------------------------------------------------------------------
sub test
{
    my $driver = shift; # e.g. "cs::pdt"
    my $n_errors = 0;
    # Note: We could also eval() just the "use" statement (and possibly the list(), decode() and encode() calls).
    # Enclosing the eval code in single quotes would prevent any "$" and "@" from being interpreted.
    # However, we still want the ${driver} to be interpreted.
    my $eval = <<_end_of_eval_
    {
        use tagset::${driver};
        my \$list = tagset::${driver}::list();
        foreach my \$tag (\@{\$list})
        {
            if(\$debug)
            {
                print STDERR ("Now testing tag \$tag\n");
            }
            my \$f = tagset::${driver}::decode(\$tag);
            my \$tag1 = tagset::${driver}::encode(\$f);
            if(\$tag1 ne \$tag)
            {
                print("Error: encode(decode(x)) != x\n");
                print(" src = \\"\$tag\\"\n");
                print(" tgt = \\"\$tag1\\"\n");
                print("\n");
                \$n_errors++;
            }
        }
    }
_end_of_eval_
    ;
    if($debug)
    {
        print STDERR ($eval);
    }
    eval($eval);
    if($@)
    {
        confess("$@\nEval failed");
    }
    print("Found $n_errors errors.\n");
}



1;
