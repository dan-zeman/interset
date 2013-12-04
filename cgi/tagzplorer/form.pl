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
use lib 'C:/Users/Dan/Dokumenty/lib';
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
# Read cgi parameters.
dzcgi::cist_parametry(\%config);
# Corpus name is mandatory.
if(!exists($config{corpus}) || ! -d $config{corpus})
{
    print("<p style='color:red'>Error: Unknown corpus '$config{corpus}'</p>\n");
}
else
{
    print("<h1>Example Word: <span style='color:red'>$config{form}</span></h1>\n");
    my @positions;
    # Which index file do we need?
    $config{form} =~ m/^(.)/;
    my $fl = $1;
    my $indexpath = sprintf("$config{corpus}/findex%04x.txt", ord($fl));
    open(INDEX, $indexpath) or print("<p style='color:red'>Cannot read $indexpath: $!</p>\n");
    while(<INDEX>)
    {
        s/\r?\n$//;
        if(m/^(.*?)\t(.*)$/)
        {
            my $word = $1;
            my $records = $2;
            if($word eq $config{form})
            {
                # Print all tags the word occurred with.
                if($config{tag})
                {
                    print("<p>Interested only in tag: $config{tag}. <a href=\"form.pl?corpus=$config{corpus}&amp;form=$config{form}\">Remove tag filter.</a></p>\n");
                }
                print("<table border=1>\n");
                print("<tr><th>Lemma</th><th>Tag</th><th>Positions</th></tr>\n");
                # Parse records.
                my @records = split('<dr>', $records);
                foreach my $record (@records)
                {
                    # The [<>&] characters are already encoded in fields which is good because we are about to paste it in HTML.
                    my @fields = split('<df>', $record);
                    next if($config{tag} && $fields[1] ne $config{tag});
                    my $lemma = "<a href='lemma.pl?corpus=$config{corpus}&amp;lemma=".uri_escape_utf8($fields[0])."'>$fields[0]</a>";
                    my $tag = "<a href='tag.pl?corpus=$config{corpus}&amp;tag=".uri_escape_utf8($fields[1])."'>$fields[1]</a>";
                    my $positions = $fields[2];
                    $positions =~ s/;/ /g;
                    push(@positions, split(/ /, $positions));
                    print("<tr><td>$lemma</td><td>$tag</td><td>$positions</td></tr>\n");
                }
                print("</table>\n");
                last;
            }
        }
    }
    close(INDEX);
    # Print the first 10 sentences where the word occurs.
    print("<ul>\n");
    for(my $i = 0; $i<10 && $i<=$#positions; $i++)
    {
        my ($is, $iw) = split(/:/, $positions[$i]);
        # Which corpus file do we need?
        my $if = int($is/1000);
        my $filepath = sprintf("$config{corpus}/corpus%04d.txt", $if);
        open(CORPUS, $filepath) or print("<p style='color:red'>Cannot read $filepath: $!</p>\n");
        my $js = $is-($if*1000);
        my $j = 0;
        while(<CORPUS>)
        {
            if($j==$js)
            {
                s/\r?\n$//;
                my @tokens = split(/\s+/, $_);
                $tokens[$iw] = "<span style='color:red'>$tokens[$iw]</span>";
                my $sentence = join(' ', @tokens);
                print("<li>$is:$iw $sentence</li>\n");
                last;
            }
            $j++;
        }
        close(CORPUS);
    }
    print("</ul>\n");
}
print("</body>\n");
print("</html>\n");



#------------------------------------------------------------------------------
# Decodes a string in which "<>&" have been encoded so that it could be used
# with XML-like markup.
#------------------------------------------------------------------------------
sub dec
{
    my $string = shift;
    $string =~ s/&lt;/</g;
    $string =~ s/&gt;/>/g;
    $string =~ s/&amp;/&/g;
    return $string;
}
