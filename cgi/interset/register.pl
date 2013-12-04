#!/usr/bin/perl
# CGI skript pro obsluhu registračního formuláře DZ Intersetu.
# Copyright (c) 2009 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
# CGI skript běží pod jiným uživatelem a nezná cestu k mým knihovnám. Říct mu ji.
use lib '/home/zeman/lib';
use dzcgi;
use mail;

# Získat registrační údaje.
dzcgi::cist_parametry(\%konfig);
# Kolikátého je?
$date = `date`;
$date =~ s/\r?\n$//;
# Lze k IP adrese zjistit název domény?
$domain = `nslookup $ENV{REMOTE_ADDR}`;
$domain =~ s/Server:\s*\d+\.\d+\.\d+\.\d+//;
$domain =~ s/Address:\s*\S+//;
$domain =~ s/\s+/ /sg; # mj. zruší zalomení řádků a nahradí je mezerou
$domain =~ s/^\s+//s;
$domain =~ s/\s+$//s;
# Jednoduchá archivace registrací: prostě uložit nevybalený QUERY_STRING.
open(ARCHIV, ">>archiv_registraci/archiv_registraci.txt");
print ARCHIV ("$ENV{REMOTE_ADDR}($domain)/$date/$ENV{QUERY_STRING}\n");
close(ARCHIV);
# Poslat e-mail Danovi.
$text_mailu .= "Jméno: $konfig{jmeno}\n";
$text_mailu .= "Instituce: $konfig{inst}\n";
$text_mailu .= "Město: $konfig{obec}\n";
$text_mailu .= "Země: $konfig{zeme}\n";
$text_mailu .= "E-mail: $konfig{info}\n";
$text_mailu .= "IP: $ENV{REMOTE_ADDR}\n";
$text_mailu .= "Doména: $domain\n";
$text_mailu .= "Datum: $date\n";
mail::odeslat
(
    "From"     => 'ÚFAL <zeman@ufal.mff.cuni.cz>',
    "Reply-to" => $konfig{info},
    "To"       => 'Daniel Zeman <zeman@ufal.mff.cuni.cz>',
    "Subject"  => 'Registrace DZ Interset',
    "text"     => $text_mailu
);
# Vypsat záhlaví HTTP.
print("Content-type: text/html; charset=utf8\n\n");
# Vypsat záhlaví HTML.
print("<html>\n");
print("<head>\n");
print("  <meta http-equiv=\"content-type\" content=\"text/html; charset=utf8\"/>\n");
print("  <title>Registration of DZ Interset</title>\n");
print("</head>\n");
print("<body>\n");
# Vlastní text dokumentu.
if($konfig{jmeno} !~ m/^\s*$/ && $konfig{obec} !~ m/^\s*$/ && $konfig{zeme} !~ m/^\s*$/)
{
    print("<h1>Thank you for registering!</h1>\n");
    print("<p><a href=\"http://ufal.mff.cuni.cz/~zeman/soubory/interset.zip\">Download interset.zip here.</a></p>\n");
}
else
{
    print("<h1>Empty? :-(</h1>\n");
    print("<p>Unfortunately, an empty registration is useless for me. Would you mind going a step back and filling out your name, city, country, and possibly also your institution? Thanks.</p>\n");
}
print("<table>\n");
print("  <tr><td>Name:</td><td>$konfig{jmeno}</td></tr>\n");
print("  <tr><td>Institution:</td><td>$konfig{inst}</td></tr>\n");
print("  <tr><td>City:</td><td>$konfig{obec}</td></tr>\n");
print("  <tr><td>Country:</td><td>$konfig{zeme}</td></tr>\n");
print("  <tr><td>E-mail:</td><td>$konfig{info}</td></tr>\n");
print("  <tr><td>Date:</td><td>$date</td></tr>\n");
print("</table>\n");
# Uzavřít HTML.
print("</body>\n");
print("</html>\n");
