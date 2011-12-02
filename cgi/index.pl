#!/usr/bin/perl
# Displays pre-indexed examples of words, lemmas and tags from corpora.
# Copyright © 2010 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use URI::Escape;
# Let Apache know where Dan's libraries are.
use lib 'C:/Documents and Settings/Dan/Dokumenty/Lingvistika/lib';
use lib '/home/zeman/lib';
use dzcgi; # Dan's library for CGI parameters

print("Content-type: text/html; charset=utf8\n\n");
print("<html>\n");
print("<head>\n");
# We do not want robots to consume our CPU capacity.
# And we do not want copyrighted corpus text to be indexed by search engines.
print("<meta name=\"robots\" content=\"noindex\">\n");
print("<meta name=\"robots\" content=\"noarchive\">\n");
print("<meta http-equiv='content-type' content='text/html; charset=utf8' />\n");
print("<title>Tagzplorer</title>\n");
print("</head>\n");
print("<body>\n");
print("<h1>Tagzplorer: Examples of Words and Tags from Corpora</h1>\n");
# Read cgi parameters.
dzcgi::cist_parametry(\%config);
# If no corpus is selected, provide list of available corpora.
if(!exists($config{corpus}))
{
    opendir(DIR, '.') or print("<p style='color:red'>Error: Cannot read current folder.</p>\n");
    my @objects = sort(readdir(DIR));
    closedir(DIR);
    print("<p>Please select a corpus from the list below.</p>\n");
    my $ok = 0;
    print("<ul>\n");
    foreach my $object (@objects)
    {
        if($object !~ m/^\./ && -d $object)
        {
            print("<li><a href='index.pl?corpus=$object'>$object</a></li>\n");
            $ok = 1;
        }
    }
    print("</ul>\n");
    unless($ok)
    {
        print("<p style='color:red'>Error: No corpora found.</p>\n");
    }
}
elsif(! -d $config{corpus})
{
    print("<p style='color:red'>Error: Unknown corpus '$config{corpus}'</p>\n");
}
else
{
    if(!exists($config{index}))
    {
        print("<p>Please select the initial letter of the word:</p>\n");
        # Read the master index file.
        my $indexpath = "$config{corpus}/findex.txt";
        open(INDEX, $indexpath) or print("<p style='color:red'>Error: Cannot read $indexpath: $!</p>\n");
        while(<INDEX>)
        {
            s/\r?\n$//;
            my @fields = split(/\t/, $_);
            print("<a href='index.pl?corpus=$config{corpus}&amp;index=$fields[1]'>$fields[0]</a>&nbsp;($fields[2])\n");
        }
        close(INDEX);
        print("<form method=get action='index.pl'>\n");
        print("  <p>Or specify a Perl regular expression for the tag:\n");
        print("    <input type=hidden name=corpus value='$config{corpus}' />\n");
        print("    <input type=text name=re value='$config{re}' size='50' />\n");
        print("    AND NOT <input type=text name=notre value='$config{notre}' size='50' />\n");
        print("    <input type=submit name=submit value='Apply' />\n");
        print("  </p>\n");
        print("</form>\n");
        print("<p>Or select the tag:</p>\n");
        $indexpath = "$config{corpus}/tindex.txt";
        open(INDEX, $indexpath) or print("<p style='color:red'>Error: Cannot read $indexpath: $!</p>\n");
        print("<ol>\n");
        # Optionally the tags can be filtered using a regular expression.
        # For safety reasons, the regular expression must not contain embedded code execution.
        my $re = $config{re};
        my $notre = $config{notre};
        $re = '' if($re =~ m/\(\?\??\{/);
        $notre = '' if($notre =~ m/\(\?\??\{/);
        if($re || $notre)
        {
            # Escape &<> in the regular expression. It is needed for displaying the RE.
            # Note that &<> has been escaped in the tag index, so we need to escape the RE even for matching.
            $re =~ s/&/&amp;/g;
            $re =~ s/</&lt;/g;
            $re =~ s/>/&gt;/g;
            $notre =~ s/&/&amp;/g;
            $notre =~ s/</&lt;/g;
            $notre =~ s/>/&gt;/g;
            print("<p>Filter regular expression: <span style='color:green'>$re</span> AND NOT <span style='color:green'>$notre</span></p>\n");
        }
        while(<INDEX>)
        {
            s/\r?\n$//;
            if(m/^(.*?)<dl>(.*)$/)
            {
                my $tag = $1;
                my $records = $2;
                next if($re && $tag !~ m/$re/ || $notre && $tag =~ m/$notre/);
                my $tag_escaped = uri_escape_utf8($tag);
                my $tag_hlink = "<a href='tag.pl?corpus=$config{corpus}&amp;tag=$tag_escaped'>$tag</a>";
                # Parse records.
                my @records = split('<dr>', $records);
                # Print only the first five records. The index should guarantee they are in descending order by frequency.
                splice(@records, 5);
                my $examples = scalar(@records) ? ' ('.join(', ', map {s/<df>.*//; $_} (@records)).')' : '';
                print("<li>$tag_hlink$examples</li>\n");
            }
        }
        print("</ol>\n");
        close(INDEX);
    }
    # Safety check: unexpected filenames could also be pipes to commands!
    elsif($config{index} !~ m/^[fl]index[0-9a-f]{4}\.txt$/)
    {
        print("<p style='color:red'>Error: Unexpected index filename '$config{index}'</p>\n");
    }
    else
    {
        print("<p>Please select the word form:</p>\n");
        # Which index file do we need?
        my $indexpath = "$config{corpus}/$config{index}";
        open(INDEX, $indexpath) or print("<p style='color:red'>Cannot read $indexpath: $!</p>\n");
        while(<INDEX>)
        {
            s/\r?\n$//;
            if(m/^(.*?)\t.*$/)
            {
                my $word = $1;
                print("<a href='form.pl?corpus=$config{corpus}&amp;index=$config{index}&amp;form=$word'>$word</a>\n");
            }
        }
        close(INDEX);
    }
}
print("<p><i><b>Acknowledgements:</b> This research has been supported by the grant of the Czech Ministry of Education no. MSM0021620838.</i></p>\n");
print("</body>\n");
print("</html>\n");
