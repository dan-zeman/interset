This folder contains Perl drivers for tag sets.
It also contains simple Perl conversion scripts using the drivers.
Naming convention:

format-sl-stagset-tl-ttagset.pl
format ... string identifying the data format (e.g., "conll" means the CoNLL-06 column format)
sl ... source language code (e.g., "da" means Danish)
stagset ... string identifying the source tagset uniquely w.r.t. source language (e.g., "conll")
tl ... target language code (e.g., "cs" means Czech)
ttagset ... string identifying the target tagset uniquely w.r.t. target language (e.g., "pdt")

Example: "conll-da-conll-cs-pdt.pl"
