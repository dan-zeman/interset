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
    print("<h1>$config{tag}</h1>\n");
    my $indexpath = "$config{corpus}/tindex.txt";
    open(INDEX, $indexpath) or print("<p style='color:red'>Cannot read $indexpath: $!</p>\n");
    while(<INDEX>)
    {
        s/\r?\n$//;
        if(m/^(.*?)<dl>(.*)$/)
        {
            my $tag = $1;
            my $records = $2;
            if($tag eq $config{tag})
            {
                # Parse records.
                my @records = split('<dr>', $records);
                print("<p>Found ", scalar(@records), " word forms tagged with this tag.</p>\n");
                foreach my $record (@records)
                {
                    # The [<>&] characters are already encoded in fields which is good because we are about to paste it in HTML.
                    my @fields = split('<df>', $record);
                    my $word_escaped = uri_escape_utf8($fields[0]);
                    my $tag_escaped = uri_escape_utf8($config{tag});
                    my $word_hlink = "<a href='form.pl?corpus=$config{corpus}&amp;form=$word_escaped&amp;tag=$tag_escaped'>$fields[0]</a>";
                    print("$word_hlink&nbsp;($fields[1])\n");
                }
                last;
            }
        }
    }
    close(INDEX);
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
