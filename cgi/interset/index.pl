#!/usr/bin/perl
# CGI skript pro vstup do webového rozhraní DZ Intersetu
# Copyright © 2009, 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
# CGI skript běží pod jiným uživatelem a nezná cestu k mým knihovnám. Říct mu ji.
use lib '/home/zeman/lib';
use lib '/home/zeman/interset/lib';
use dzcgi;
use Lingua::Interset;

# Přečíst parametry CGI.
dzcgi::cist_parametry(\%konfig);
if($konfig{tagset} eq '')
{
    $konfig{tagset} = 'mul::upos';
}
# Vypsat záhlaví HTTP.
print("Content-type: text/html; charset=utf8\n\n");
# Vypsat záhlaví HTML.
print("<html>\n");
print("<head>\n");
print("  <meta name=\"robots\" content=\"noindex, nofollow\" />\n");
print("  <meta http-equiv=\"content-type\" content=\"text/html; charset=utf8\" />\n");
print("  <title>DZ Interset Web Interface</title>\n");
print("  <link href=\"http://ufal.mff.cuni.cz/css/ufal.css\" rel=\"stylesheet\" media=\"screen\" />\n");
print("  <link href=\"http://ufal.mff.cuni.cz/css/print.css\" rel=\"stylesheet\" media=\"print\" />\n");
print("</head>\n");
print("<body id=\"p-home\">\n");
#print_header();
print("<div id=\"body\">\n");
print_menu();
# Vlastní text dokumentu.
print("<div id=\"main\">\n");
print("<h1>DZ Interset Web Interface</h1>\n");
print("<p>Please visit the main site of DZ Interset at <a href=\"https://wiki.ufal.ms.mff.cuni.cz/user:zeman:interset\">https://wiki.ufal.ms.mff.cuni.cz/user:zeman:interset</a> if you landed here accidentially and do not know what it is all about.</p>\n");
print("<p>The web interface currently provides the following options:</p>\n");
print("<ul>\n");
print("  <li>View the list of tags of a driver</li>\n");
print("</ul>\n");
print_list_of_tagsets($konfig{tagset});
print_tagset($konfig{tagset}, $konfig{offset});
print("</div><!-- #main -->\n");
print_footer();
# Uzavřít HTML.
print("</body>\n");
print("</html>\n");



#------------------------------------------------------------------------------
# Prints header (ÚFAL logo, main heading etc.)
# This part is currently not used because it does not fit graphically.
#------------------------------------------------------------------------------
sub print_header
{
    print <<EOF
<div id="head">
<!-- Logo tady nevypadá hezky, je moc velké.
<div id="logos">
<a href="http://ufal.mff.cuni.cz/"><img id="logo_ufal" src="http://ufal.mff.cuni.cz/image/logo_ufal_142.png" alt="Logo ÚFAL" title="Ústav formální a aplikované lingvistiky" /></a>
</div-->
<h1 class="header">DZ Interset</h1>
<div class="clear"></div>
</div><!-- #head -->
EOF
    ;
}



#------------------------------------------------------------------------------
# Prints left menu.
#------------------------------------------------------------------------------
sub print_menu
{
    print <<EOF
<ul id="menu">
<li><a class="highlight" href="https://wiki.ufal.ms.mff.cuni.cz/user:zeman:interset">DZ Interset Home</a></li>
<li><a class="folder" href="http://ufal.mff.cuni.cz/">ÚFAL Home</a></li>
<li><a class="folder" href="http://ufal.mff.cuni.cz/daniel-zeman/">Dan Zeman</a><!--ul>
</ul-->
</li>
</ul><!-- #menu -->
EOF
    ;
}



#------------------------------------------------------------------------------
# Prints footer (copyright, contact info etc.)
#------------------------------------------------------------------------------
sub print_footer
{
print <<EOF
<div id="tail">
<hr />
<div class="copy">
<small class="owner">Copyright &copy; 2009&ndash;2016 <a href="http://ufal.mff.cuni.cz/daniel-zeman/">Daniel Zeman</a></small>
</div>
</div><!-- #tail -->
EOF
;
}



#------------------------------------------------------------------------------
# Prints table of tagsets
#------------------------------------------------------------------------------
sub print_list_of_tagsets
{
    my $current = shift;
    print("<h2>List of known tagsets</h2>\n");
    my @tagsets = Lingua::Interset::find_tagsets();
    my @links = map {$_ eq $current ? "<b>$_</b>" : "<a href=\"index.pl?tagset=$_\">$_</a>"} (@tagsets);
    my $list = join(' ', @links);
    print("<p>$list</p>\n");
}



#------------------------------------------------------------------------------
# Prints table of tags
#------------------------------------------------------------------------------
sub print_tagset
{
    my $tagset = shift;
    my $offset = shift;
    my $threshold = 350;
    my $batchsize = 300;
    $offset = 0 if($offset eq '');
    print("<h2>List of tags in <tt>$tagset</tt></h2>\n");
    my $list = Lingua::Interset::list($tagset);
    my @matching_tags = grep
    {
        my $fs = Lingua::Interset::decode($tagset, $_);
        my $ok=1;
        foreach my $f (keys(%konfig))
        {
            ###!!! We must distinguish between features and other CGI parameters.
            ###!!! And we should do so in a more systematic manner than this!
            next if($f =~ m/^(clear|tagset)$/);
            if($konfig{$f} eq '<empty>')
            {
                if($fs->{$f} ne '')
                {
                    $ok = 0;
                    last;
                }
            }
            elsif($konfig{$f} ne '')
            {
                if(ref($fs->{$f}) eq 'ARRAY')
                {
                    if(!grep {$_ eq $konfig{$f}} (@{$fs->{$f}}))
                    {
                        $ok = 0;
                        last;
                    }
                }
                elsif($fs->{$f} ne $konfig{$f})
                {
                    $ok = 0;
                    last;
                }
            }
        }
        $ok
    }
    (@{$list});
    print(get_filter_form($tagset, \%konfig, \@matching_tags));
    my $n = scalar(@{$list});
    my $n_matching = scalar(@matching_tags);
    ###!!! Debugging: If there are no matching tags, print the parameters so we can see what happened.
    if($n_matching==0)
    {
        foreach my $show_non_empty (1, 0)
        {
            foreach my $key (keys(%konfig))
            {
                my $value = $konfig{$key};
                next if($show_non_empty && $value eq '' || !$show_non_empty && $value ne '');
                $value = escapetext($value);
                print("$key=$value\n");
            }
            print("<br/>\n");
        }
    }
    print("<p>Total number of tags: $n");
    # If the output is too long (roughly over 500 Kbytes) the server issues an error message.
    my $cut = $n;
    if($n>$threshold)
    {
        $cut = $offset+$batchsize;
        print("<br/>Only $batchsize shown, starting at $offset");
    }
    else
    {
        $offset = 0;
    }
    print("<br/>\n");
    print("Number of matching tags: $n_matching</p>\n");
    if($n>$threshold)
    {
        my @links;
        if($offset>0)
        {
            my $prevoffset = $offset-$batchsize;
            $prevoffset = 0 if($prefoffset<0);
            push(@links, "<a href=\"index.pl?tagset=$tagset&offset=$prevoffset\">previous $batchsize</a>");
        }
        if($cut<$n)
        {
            my $nextoffset = $offset+$batchsize;
            push(@links, "<a href=\"index.pl?tagset=$tagset&offset=$nextoffset\">next $batchsize</a>");
        }
        my $links = join(' | ', @links);
        print("<p>Show $links</p>\n");
    }
    print("<table>\n");
    print("  <tr><th>$tagset</th><th>features</th></tr>\n");
    for(my $i = $offset; $i<=$#matching_tags && $i<$cut; $i++)
    {
        my $tag = $matching_tags[$i];
        my $f = Lingua::Interset::decode($tagset, $tag);
        my $fs = feature_structure_to_text($f);
        $fs =~ s/",/", /g;
        $tag = escapetext($tag);
        print("  <tr><td><tt>$tag</tt></td><td>$fs</td></tr>\n");
        $n_matching++;
    }
    print("</table>\n");
}



#------------------------------------------------------------------------------
# Generates text from contents of feature structure so it can be printed.
# There is a similar method, Lingua::Interset::FeatureStructure::as_string().
# We do not use it because:
# * We want nicer HTML formatting
# * We want better handling of the 'other' feature
#------------------------------------------------------------------------------
sub feature_structure_to_text
{
    my $fs = shift; # Lingua::Interset::FeatureStructure
    my $atrstyle = "color:brown;font-weight:bold";
    my $valstyle = "color:blue;font-weight:bold";
    my @features = $fs->get_nonempty_features();
    my @assignments = map
    {
        my $f = $_;
        my $v;
        if($f eq 'other')
        {
            $v = escapetext(Lingua::Interset::FeatureStructure::structure_to_string($fs->get('other')));
        }
        else
        {
            $v = "\"<span style='$valstyle'>".$fs->get_joined($f)."</span>\"";
        }
        "<span style='$atrstyle'>$f</span>=$v";
    }
    # Skip the tagset feature. It is not interesting and it is always the same.
    (grep {$_ ne 'tagset'} (@features));
    return '['.join(', ', @assignments).']';
}



#------------------------------------------------------------------------------
# For the given tagset, and for every Interset feature, generates a control
# that can be used to filter the tags and get only those with matching value of
# the feature.
#------------------------------------------------------------------------------
sub get_filter_form
{
    my $tagset = shift;
    my $konfig = shift;
    my $list = shift; # the list may already be filtered
    my $map = map_feature_values($tagset, $list);
    my $html;
    $html .= "<!-- Controls to filter tags and get those with matching values of selected features -->\n";
    $html .= "<form id=\"filter\" method=\"get\" action=\"index.pl\">\n";
    $html .= "  <script>function sendForm() { document.getElementById(\"filter\").submit() }</script>\n";
    $html .= "  <input type=\"hidden\" name=\"tagset\" value=\"$tagset\" />\n";
    $html .= "  <b>Filter:</b>\n";
    my @known_features = Lingua::Interset::FeatureStructure::known_features();
    foreach my $feature (@known_features)
    {
        $html .= "  <!-- \$konfig{$feature} = $konfig->{$feature} -->\n";
        next unless(exists($map->{$feature}) || $konfig->{$feature} ne '');
        next if($feature =~ m/^(tagset|other)$/);
        my @values = Lingua::Interset::FeatureStructure::known_values($feature);
        unshift(@values, '<empty>');
        @values = map {escapetext($_)} (grep {exists($map->{$feature}{$_})} (@values));
        # Features that are already part of the current filter cannot be modified again
        # because the options for the other features depend on the current filter.
        # If the user wishes to change the feature, he should either go back in the browser or clear the form.
        if($konfig->{$feature} ne '')
        {
            # I wanted to have this input control disabled for editing but it resulted in the browser's not sending the value when the form was submitted.
            $html .= "  $feature&nbsp;=&nbsp;<input type=\"text\" id=\"filter_$feature\" name=\"$feature\" value=\"$konfig->{$feature}\" size=\"6\" style=\"color:grey\" />\n";
        }
        elsif(scalar(@values)==1)
        {
            # I wanted to have this input control disabled for editing but it resulted in the browser's not sending the value when the form was submitted.
            $html .= "  $feature&nbsp;=&nbsp;<input type=\"text\" id=\"filter_$feature\" name=\"$feature\" value=\"$values[0]\" size=\"6\" style=\"color:grey\" />\n";
        }
        else
        {
            $html .= "  $feature&nbsp;=&nbsp;<select id=\"filter_$feature\" name=\"$feature\" onchange=\"sendForm()\">\n";
            $html .= "    <option value=\"\" selected=\"1\">&lt;any&gt;</option>\n";
            foreach my $value (@values)
            {
                $html .= "    <option value=\"$value\">$value</option>\n";
            }
            $html .= "  </select>\n";
        }
    }
    $html .= "</form>\n";
    $html .= "<form id=\"clear_filter\" method=\"get\" action=\"index.pl\">\n";
    $html .= "  <input type=\"hidden\" name=\"tagset\" value=\"$tagset\" />\n";
    $html .= "  <input type=\"submit\" name=\"clear\" value=\"Clear filter\" />\n";
    $html .= "</form>\n";
    return $html;
}



#------------------------------------------------------------------------------
# Maps Interset features and values used in a set of tags.
#------------------------------------------------------------------------------
sub map_feature_values
{
    my $tagset = shift;
    my $list = shift; # the list may already be filtered
    # Get feature structure for every tag in the list.
    my @fss = map {Lingua::Interset::decode($tagset, $_)} (@{$list});
    # First run: Which features are relevant? They must have a non-empty value for at least one tag.
    my %relevant_features;
    foreach my $fs (@fss)
    {
        foreach my $f (keys(%{$fs}))
        {
            if($fs->{$f} ne '')
            {
                $relevant_features{$f}++;
            }
        }
    }
    # Second run: Map relevant values.
    # An empty value is now also significant because it belongs to a feature that can be empty or non-empty.
    # To make it clear and also to prepare for printing the values, convert empty values to "<empty>" now.
    my %map;
    foreach my $fs (@fss)
    {
        foreach my $f (keys(%relevant_features))
        {
            if(ref($fs->{$f}) eq 'ARRAY')
            {
                my @values = @{$fs->{$f}};
                foreach my $v (@values)
                {
                    if($v eq '')
                    {
                        $map{$f}{'<empty>'}++;
                    }
                    else
                    {
                        $map{$f}{$v}++;
                    }
                }
            }
            elsif($fs->{$f} eq '')
            {
                $map{$f}{'<empty>'}++;
            }
            else
            {
                $map{$f}{$fs->{$f}}++;
            }
        }
    }
    return \%map;
}



#------------------------------------------------------------------------------
# Encodes text so that it can be inserted in HTML: & < > " will be escaped.
#------------------------------------------------------------------------------
sub escapetext
{
    my $text = shift;
    $text =~ s/&/&amp;/g;
    $text =~ s/</&lt;/g;
    $text =~ s/>/&gt;/g;
    $text =~ s/"/&quot;/g;
    return $text;
}
