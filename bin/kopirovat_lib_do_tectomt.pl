#!/usr/bin/env perl
# Zkopíruje aktuální verzi knihoven Intersetu do TectoMT. Vynechá pomocné složky .svn. Cesty jsou relativní, ale zadrátované ve skriptu.
# Repozitář Intersetu je hlavní a v TectoMT je pouhá kopie. Pokud někdo dělal změny v TectoMT, tyto změny budou bez varování přepsány.
# Po provedení skriptu je třeba na cílové (tectomt) složce ručně pustit svn commit. A předtím svn add na případné nové soubory!
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use dzsys;
use find;

my $isetpath = dzsys::get_script_path();
my $isetlibpath = "$isetpath/lib";
my $tmtlibpath = "$isetpath/../tectomt/libs/other";
find::go('lib', \&copy);



#------------------------------------------------------------------------------
# Callback funkce, která zpracuje jeden objekt. Soubor zkopíruje, u složek dá
# zelenou k jejich dalšímu prohledávání, symbolické odkazy ignoruje.
#------------------------------------------------------------------------------
sub copy
{
    my $cesta = shift;
    my $objekt = shift;
    my $druh = shift;
    # Přeskočit složky .svn, ani do nich nelézt dovnitř.
    return 0 if($objekt eq '.svn');
    my $relcesta = $cesta;
    $relcesta =~ s:^lib/?::;
    my $cilcesta = $tmtlibpath;
    $cilcesta .= "/$relcesta" if($relcesta ne '');
    # Obyčejné soubory (nikoli složky ani symbolické odkazy) zkopírovat do cíle.
    if($druh eq 'o')
    {
        dzsys::saferun(dzsys::slash_windows("copy $cesta/$objekt $cilcesta/$objekt\n")) or die;
    }
    elsif($druh eq 'drx')
    {
        if(!-d "$cilcesta/$objekt")
        {
            dzsys::saferun(dzsys::slash_windows("mkdir $cilcesta/$objekt\n")) or die;
        }
        return 1;
    }
    # Jestliže jsme se dostali až sem, pak objekt není složka nebo jeto složka, ale nelze do ní vstoupit.
    return 0;
}
