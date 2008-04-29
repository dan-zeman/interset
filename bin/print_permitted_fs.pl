#!/usr/bin/perl
use tagset::common;
if(scalar(@ARGV))
  {
    $drivers = \@ARGV;
  }
else
  {
    $drivers = tagset::common::find_drivers();
  }
foreach my $driver (@{$drivers})
  {
    $eval = "
use tagset::$driver;
\$permitted = tagset::common::get_permitted_structures_joint(tagset::${driver}::list(), \\&tagset::${driver}::decode);
print(tagset::common::get_permitted_combinations_as_text(\$permitted));
";
#print($eval);
    eval($eval);
  }
