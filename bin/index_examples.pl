#!/usr/bin/perl
# Prepares corpus index for browsing tag examples.
# Copyright © 2010, 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
my $laptop_path = 'C:/Users/Dan/Documents/Web/cgi/tags';
my $format = 'conll2006'; # default
sub usage
{
    print STDERR ("Usage: perl index_examples.pl corpus-name [-format conll2006|icon|conll2009|csts|pmk] < corpus\n");
    print STDERR ("       -format ... input corpus format; values: conll2006|conll2009|csts|pmk; default: conll2006\n");
    print STDERR ("       -o ........ output path\n");
    print STDERR ("                   Because Dan is currently the only user of this script, the default is specific on Dan's laptop:\n");
    print STDERR ("                   If '$laptop_path' exists, it is the default output path.\n");
    print STDERR ("                   Otherwise, the current folder is the default output path.\n");
}

use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use Getopt::Long;

GetOptions
(
    'format=s' => \$format,
    'output=s' => \$outdir
);
if(scalar(@ARGV)<1)
{
    usage();
    die("Missing mandatory argument: name of the corpus");
}
$corpusname = shift(@ARGV);
# On Dan's laptop, write directly to the CGI path. Anywhere else, write to the current folder.
my $target_path = $outdir ? "$outdir/$corpusname" : (-d $laptop_path) ? "$laptop_path/$corpusname" : "./$corpusname";
# Windows command line will not expand wildcards automatically.
if(grep {m/\*/} (@ARGV))
{
    my @soubory = map {glob($_)} (@ARGV);
    @ARGV = @soubory;
    print STDERR (join(' ', @soubory), "\n");
}
# On Dan's laptop, write directly to the CGI path. Anywhere else, write to the current folder.
my $laptop_path = 'C:/Documents and Settings/Dan/Dokumenty/Web/cgi/tags';
my $target_path = (-d $laptop_path) ? "$laptop_path/$corpusname" : "./$corpusname";
# Read the corpus. This part depends on the input corpus format.
# The block defines the scope of the reference to the original document so that it can be freed.
{
    my $document;
    if($format eq 'pmk')
    {
        $document = read_document_pmk();
    }
    elsif($format eq 'csts')
    {
        $document = read_document_csts();
    }
    elsif($format eq 'conll2009')
    {
        $document = read_document_conll_2009();
    }
    elsif($format eq 'icon')
    {
        $document = read_document_conll_2006();
        foreach my $sentence (@{$document})
        {
            foreach my $t (@{$sentence->{tokens}})
            {
                my $tag = $t->[2];
                my ($cpos, $pos, $feat) = split(/\t/, $tag);
                my @features = split(/\|/, $feat);
                # Discard features that do not belong to the morphosyntactic tag.
                # Note that 'cat' belongs there but it is redundant because its copy is in the $pos column.
                @features = grep {!m/^(lex|cat|vpos|posn|name|chunkId|chunkType)-/} (@features);
                $t->[2] = join("\t", $cpos, $pos, join('|', @features));
            }
        }
    }
    else # conll2006 is the default format
    {
        $document = read_document_conll_2006();
    }
    print STDERR ("Read ", scalar(@{$document}), " sentences.\n");
    # Shuffle the corpus: sort sentences alphabetically.
    @document = sort {$a->{text} cmp $b->{text}} (@{$document});
}
# The rest is independent of the input corpus format.
# Index tag examples.
foreach my $sentence (@document)
{
    foreach my $token (@{$sentence->{tokens}})
    {
        my $form = $token->[0];
        my $tag = $token->[2];
        # Remember this form-tag co-occurrence.
        $index{$tag}{$form}++;
    }
}
# Print the tags with examples.
@keys = sort(keys(%index));
print STDERR ("Found ", scalar(@keys), " distinct tags.\n");
###!!! Obsolete - should be moved to a CGI script.
if(0)
{
    print("<html>\n");
    print("<head>\n");
    print("<meta http-equiv='content-type' content='text/html; charset=utf8' />\n");
    print("<title>Tags with examples</title>\n");
    print("</head>\n");
    print("<body>\n");
    print("<table>\n");
    foreach my $tag (@keys)
    {
        my $tag_html = $tag;
        $tag_html =~ s/&/&amp;/sg;
        $tag_html =~ s/</&lt;/sg;
        $tag_html =~ s/>/&gt;/sg;
        # Sort the examples by frequency.
        my @examples = sort {$index{$tag}{$b} <=> $index{$tag}{$a}} (keys(%{$index{$tag}}));
        # Print up to five most frequent examples.
        splice(@examples, 5);
        my $examples_html = join(' ', @examples);
        $examples_html =~ s/&/&amp;/sg;
        $examples_html =~ s/</&lt;/sg;
        $examples_html =~ s/>/&gt;/sg;
        print("<tr><td>$tag_html</td><td>$examples_html</td></tr>\n");
    }
    print("</table>\n");
    print("</body>\n");
    print("</html>\n");
}
print STDERR ("Building the indexes...\n");
($fhash, $lhash, $thash) = build_index(\@document);
if(! -d $target_path)
{
    mkdir($target_path) or die("Cannot create folder $target_path: $!\n");
}
print STDERR ("Printing the corpus...\n");
print_corpus(\@document, $target_path);
print STDERR ("Printing the word form index...\n");
print_index($fhash, $target_path, 'f');
print STDERR ("Printing the lemma index...\n");
print_index($lhash, $target_path, 'l');
print STDERR ("Printing the tag index...\n");
print_tag_index($thash, $target_path);



#------------------------------------------------------------------------------
# Index slov: některé tvary se vyskytují současně jako lemmata.
# slovo \t <asform>...</asform><aslemma>...</aslemma>
# uvnitř <asform>: <df> odděluje pole, <dr> záznamy
# lemma1<df>tag1<df>vyskyty1<dr>lemma2<df>tag2<df>vyskyty2...
# uvnitř <aslemma>:
# form1<df>tag1<df>vyskyty1<dr>form2<df>tag2<df>vyskyty2...
# výskyty: index věty : index slova ve větě
# 0:0;3:10;5:9;...
#------------------------------------------------------------------------------
sub build_index
{
    my $document = shift; # array of sentences
    my %fhash; # hash for word forms
    my %lhash; # hash for lemmas
    my %thash; # hash for tags
    # Loop over sentences.
    for(my $i = 0; $i<=$#{$document}; $i++)
    {
        my $sentence = $document->[$i];
        my $tokens = $sentence->{tokens};
        # Loop over tokens.
        for(my $j = 0; $j<=$#{$tokens}; $j++)
        {
            my $token = $tokens->[$j];
            my $form = $token->[0];
            my $lemma = $token->[1];
            my $tag = $token->[2];
            my $curpos = "$i:$j";
            push(@{$fhash{$form}{$lemma}{$tag}}, $curpos);
            push(@{$lhash{$lemma}{$form}{$tag}}, $curpos);
            $thash{$tag}{$form}++;
        }
    }
    return(\%fhash, \%lhash, \%thash);
}



#------------------------------------------------------------------------------
# Prints the index of words or lemmas to the target folder.
#------------------------------------------------------------------------------
sub print_index
{
    my $hash = shift;
    my $path = shift; # target path where to create the index files
    my $prefix = shift; # 'f' for form index, 'l' for lemma index
    $path = '.' unless($path);
    # Get alphabetical list of words.
    my @words = sort(keys(%{$hash}));
    # Loop over words.
    my $last_fl;
    my %all_fl;
    foreach my $word (@words)
    {
        # Choose target index file according to the first letter.
        # The words are sorted, so words with starting letter A should not be interrupted by other words.
        $word =~ m/^(.)/;
        my $fl = $1;
        $all_fl{$fl}++;
        if($fl ne $last_fl)
        {
            close(INDEX) unless($last_fl eq '');
            my $indexname = sprintf($path.'/'.$prefix.'index%04x.txt', ord($fl));
            open(INDEX, ">$indexname") or die("Cannot write $indexname: $!\n");
            print STDERR ("Writing index $indexname for words beginning in $fl...\n");
            $last_fl = $fl;
        }
        my @records;
        # Loop over subwords (lemmas for forms and forms for lemmas).
        foreach my $subword (sort(keys(%{$hash->{$word}})))
        {
            # Loop over tags.
            foreach my $tag (sort(keys(%{$hash->{$word}{$subword}})))
            {
                push(@records, enc($subword).'<df>'.enc($tag).'<df>'.join(';', @{$hash->{$word}{$subword}{$tag}}));
            }
        }
        my $line = enc($word)."\t".join('<dr>', @records);
        print INDEX ("$line\n");
    }
    # Close the last index file.
    close(INDEX);
    # Create the master index file (list of first letters).
    my $indexname = $path.'/'.$prefix.'index.txt';
    open(INDEX, ">$indexname") or die("Cannot write $indexname: $!\n");
    foreach my $fl (sort(keys(%all_fl)))
    {
        my $indexname = sprintf($prefix.'index%04x.txt', ord($fl));
        print INDEX ("$fl\t$indexname\t$all_fl{$fl}\n");
    }
    close(INDEX);
}



#------------------------------------------------------------------------------
# Tag index: every tag knows all words it occurred with. Corpus positions are
# accessible through the words. It is not possible to filter out positions
# where the word got different tag.
# tag<dl>word1<df>freq1<dr>word2...
#------------------------------------------------------------------------------
sub print_tag_index
{
    my $hash = shift;
    my $path = shift; # target path where to create the index files
    # Get alphabetical list of tags.
    my @tags = sort(keys(%{$hash}));
    my $indexname = $path.'/tindex.txt';
    open(INDEX, ">$indexname") or die("Cannot write $indexname: $!\n");
    # Loop over tags.
    foreach my $tag (@tags)
    {
        # Sort words in descending order by frequency.
        my @words = sort {$hash->{$tag}{$b} <=> $hash->{$tag}{$a}} (keys(%{$hash->{$tag}}));
        my @records;
        # Loop over words.
        foreach my $word (@words)
        {
            my $freq = $hash->{$tag}{$word};
            push(@records, enc($word).'<df>'.$freq);
        }
        my $line = enc($tag).'<dl>'.join('<dr>', @records);
        print INDEX ("$line\n");
    }
    close(INDEX);
}



#------------------------------------------------------------------------------
# Prints the corpus to the target folder.
#------------------------------------------------------------------------------
sub print_corpus
{
    my $document = shift; # array of sentences
    my $path = shift; # target path where to create the index files
    my $spf = 1000; # sentences per file
    my $if = 0; # current file number
    my $is = 0; # current sentence number
    my $filepath = sprintf($path.'/corpus%04d.txt', $if);
    open(CORPUS, ">$filepath") or die("Cannot write $filepath: $!\n");
    foreach my $sentence (@{$document})
    {
        # Have we reached the maximum sentences per file?
        if($is>=$spf)
        {
            close(CORPUS);
            $if++;
            $is = 0;
            $filepath = sprintf($path.'/corpus%04d.txt', $if);
            open(CORPUS, ">$filepath") or die("Cannot write $filepath: $!\n");
        }
        # Print the current sentence to the current file.
        my $text = join(' ', map {$_->[0]} @{$sentence->{tokens}});
        print CORPUS ("$text\n");
        $is++;
    }
    close(CORPUS);
}



#------------------------------------------------------------------------------
# Encodes a string so that it does not contain "<>" and can be used with
# XML-like markup.
#------------------------------------------------------------------------------
sub enc
{
    my $string = shift;
    $string =~ s/&/&amp;/g;
    $string =~ s/</&lt;/g;
    $string =~ s/>/&gt;/g;
    return $string;
}



#==============================================================================
# Functions for reading corpora in various input formats.
#==============================================================================



#------------------------------------------------------------------------------
# Reads a document in the CoNLL 2006 format.
#------------------------------------------------------------------------------
sub read_document_conll_2006
{
    my @document;
    my @sentence;
    while(<>)
    {
        # Remove line break.
        s/\r?\n$//;
        # Empty line marks end of sentence.
        if(m/^\s*$/)
        {
            end_of_sentence_conll_2006(\@document, \@sentence);
        }
        # Non-empty line describes a token.
        else
        {
            my @columns = split(/\t/, $_);
            my $form = $columns[1];
            my $lemma = $columns[2];
            # Remove features that are not part of morphosyntactic tag.
            # Persian Dependency Treebank: sentence ID.
            $columns[5] =~ s/(^|\|)senID=\d+//;
            my $tag = "$columns[3]\t$columns[4]\t$columns[5]";
            push(@sentence, [$form, $lemma, $tag]);
        }
    }
    end_of_sentence_conll_2006(\@document, \@sentence);
    return \@document;
}



#------------------------------------------------------------------------------
# Reads a document in the CoNLL 2009 format.
#------------------------------------------------------------------------------
sub read_document_conll_2009
{
    my @document;
    my @sentence;
    while(<>)
    {
        # Remove line break.
        s/\r?\n$//;
        # Empty line marks end of sentence.
        if(m/^\s*$/)
        {
            # The end_of_sentence function is identical for CoNLL 2006 and 2009.
            end_of_sentence_conll_2006(\@document, \@sentence);
        }
        # Non-empty line describes a token.
        else
        {
            my @columns = split(/\t/, $_);
            my $form = $columns[1];
            my $lemma = $columns[2];
            my $tag = "$columns[4]\t$columns[6]";
            push(@sentence, [$form, $lemma, $tag]);
        }
    }
    end_of_sentence_conll_2006(\@document, \@sentence);
    return \@document;
}



#------------------------------------------------------------------------------
# CoNLL 2006 format: Remember the sentence just read.
# Actually the very same function can also be used for the CSTS format.
#------------------------------------------------------------------------------
sub end_of_sentence_conll_2006
{
    my $document = shift;
    my $sentence = shift;
    return unless(@{$sentence});
    my @tokens = @{$sentence};
    my %sentence =
    (
        'text' => join(' ', map {$_->[0]} (@{$sentence})),
        'tokens' => \@tokens
    );
    push(@{$document}, \%sentence);
    splice(@{$sentence});
}



#------------------------------------------------------------------------------
# Reads a document in the CSTS format. Does not fully parse the SGML syntax.
# Expects one token per line.
#------------------------------------------------------------------------------
sub read_document_csts
{
    my @document;
    my @sentence;
    while(<>)
    {
        # Remove line break.
        s/\r?\n$//;
        # Beginning of a new sentence.
        if(m/<s( .*)?>/)
        {
            # We may want to rename this function as it works with both formats.
            end_of_sentence_conll_2006(\@document, \@sentence);
        }
        # Token line. Note that there will be more or fewer elements in some CSTS files. Currently only tested on Russian Dependency Treebank / DZ.
        elsif(m/<f(?: .*)?>([^<]*)<l(?: .*)?>([^<]*)<t(?: .*)?>([^<]*)/)
        {
            my $form = $1;
            my $lemma = $2;
            my $tag = $3;
            push(@sentence, [$form, $lemma, $tag]);
        }
    }
    # We may want to rename this function as it works with both formats.
    end_of_sentence_conll_2006(\@document, \@sentence);
    return \@document;
}



#------------------------------------------------------------------------------
# Reads a document in the PMK (Pražský mluvený korpus) format.
#------------------------------------------------------------------------------
sub read_document_pmk
{
    my $shortened = shift;
    my $n = $shortened ? 4 : 11;
    my @document;
    my @sentence;
    binmode(STDIN, ':encoding(iso-8859-2)');
    ###!!! Momentálně se mi nechce psát ovládací funkce do parseru XML, tak to takhle odfláknu.
    while(<>)
    {
        # Note: both <st> and <sp> are lemmata. They differ for colloquial word forms:
        # <st> is colloquial lemma and <sp> is the corresponding standard lemma, e.g.:
        # <tv>současnym</tv><st>současnej</st><sp>současný</sp>
        if(m-<[fd]>(.*?)</[fd]>(<i1>.*?</i$n>)<tv>.*?</tv><st>.*?</st><sp>(.*?)</sp>-)
        {
            my $form = $1;
            my $lemma = $3;
            my $tag = $2;
            push(@sentence, [$form, $lemma, $tag]);
        }
        elsif(m-</spk>- && @sentence)
        {
            my @tokens = @sentence;
            my %sentence =
            (
                'text' => join(' ', map {$_->[0]} (@sentence)),
                'tokens' => \@tokens
            );
            push(@document, \%sentence);
            splice(@sentence);
        }
    }
    return \@document;
}
