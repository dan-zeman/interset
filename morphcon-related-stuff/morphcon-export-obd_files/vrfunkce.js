//
// Copyright (c) 1996 - 2006 DERS s.r.o.
// Jan Mach, email: machj@ders.cz, web: http://www.ders.cz
//

// podpurne funkce verso

{
    pic1 = new Image;
    pic1.src = "/images/progress.gif";
}                                                     

var vrFind = ''
var obsah='';

function vrGetScrollTop(frm) {
  var f=frm;
  if (!frm.onsubmit) {
    f=document.forms[0]; // tohle je hack kvuli HTMLaree - podminkou funkce je, aby byl jen jeden form
  }
  if ( f && f._vr_sclt ) {
    if (document.getElementById('scrollingpane')) {
      f._vr_sclt.value = document.getElementById('scrollingpane').scrollTop;
    } else {
      /* UKO-2699, scrolltop bud z body nebo documentElement, viz http://www.xinotes.org/notes/note/969/ */
      f._vr_sclt.value = document.documentElement ? document.documentElement.scrollTop : document.body.scrollTop;
    }
  } 
}

                        
function vrScrollToAnchor(kam) {
  var t=0;
  if (kam) {
  t = kam;
    if (! isNaN(t) ) {
      if (document.getElementById('scrollingpane')) {
                document.getElementById('scrollingpane').scrollTop = t;
      } else {
                window.scrollTo(0,t);
      }
    }
  } else {
    if ( window.location.hash ) {
      if (window.location.hash.indexOf('&_vr_sclt') == 0 ) {
  	    t = window.location.hash.substring(9,100);
        if (! isNaN(t) ) {
          if (document.getElementById('scrollingpane')) {
                    document.getElementById('scrollingpane').scrollTop = t;
          } else {
                    window.scrollTo(0,t);
          }
        }
      }
    }
  }
}

function nOkno(nazev) {
        w = window.open(vr_stript_name+'?fname=help&n='+nazev,
                'wHelp',
                'Scrollbars=1,resizable=1,width=400,height=500');
        w.focus
}

function Get_Cookie(name) {
  var start = document.cookie.indexOf(name+"=");
  var len = start+name.length+1;
  if ((!start) && (name != document.cookie.substring(0,name.length)))
  return null;
  if (start == -1) return null;
  var end = document.cookie.indexOf(";",len);
  if (end == -1) end = document.cookie.length;
  return unescape(document.cookie.substring(len,end));
}

function hideWkinPrgs() {
  if (document.getElementById('wkinprgs')) {
    document.getElementById('wkinprgs').style.visibility='hidden';
  }
  if (document.getElementById('wkinprgs_ifr')) {
    document.getElementById('wkinprgs_ifr').style.visibility='hidden';
  }
}

function doWkinPrgs(windowName, caption) {
try
{
	var win = window;
  var nadpisek='			Probíhá zpracování formuláře...';
	if (caption){
	  nadpisek=caption;
	}
	if (windowName && windowName.substring(0,1) != '_')
		win=window.open('',windowName);
	if (!win)
		win = window;
//	if (! win.document.getElementById('wkinprgs') ) {
		var doc = win.document;
		var b = doc.body;
		if (doc.getElementById('wkinprgs_ifr')) {
		    IFrameObj = doc.getElementById('wkinprgs_ifr')
		}
		else {
			if (getBrowserName() == 'Internet Explorer') {
			  
				var tempIFrame=doc.createElement('iframe');
				tempIFrame.setAttribute('id','wkinprgs_ifr');
				tempIFrame.setAttribute('frameborder','0');
				tempIFrame.setAttribute('scrolling','no');
				tempIFrame.setAttribute('src','/blank.html');
				tempIFrame.style.border='0px';
				tempIFrame.style.width='220pt';
				tempIFrame.style.height='65pt';
				tempIFrame.style.zindex=98;
				tempIFrame.style.position='absolute';
				tempIFrame.style.left='40%';
				tempIFrame.style.top='40%';
				tempIFrame.style.visibility='hidden';
				IFrameObj = b.appendChild(tempIFrame);
			}
		}
		
		if (doc.getElementById('wkinprgs')) {
		    DIVObj = doc.getElementById('wkinprgs');
		    doc.getElementById('progress_caption').innerHTML=nadpisek; 
		}
		else {
          		   
		    var tempDIV=doc.createElement('div');
		    tempDIV.setAttribute('id','wkinprgs');
		    tempDIV.style.border='solid 1px';
		    tempDIV.style.width='220pt';
		    tempDIV.style.height='65pt';
		    tempDIV.style.zindex=99;
		    tempDIV.style.position='absolute';
				tempDIV.style.left='40%';
				tempDIV.style.top='40%';
		    tempDIV.style.visibility='hidden';		
		    tempDIV.innerHTML = 
//	'<iframe id="wkinprgs_ifr" src="/blank.html" scrolling="no" frameborder="0" style="z-index:98; position: absolute; visibility: hidden; width: 220pt; height:65pt;">Progress...</iframe>'
//+'<div id="wkinprgs" style="z-index:99; position: absolute; visibility: hidden; width: 220pt; height:65pt;">'
'	<div style="border: solid 1px black; width: 220pt; height:65pt; background-color: window;">'
+'		<div style="border-bottom: solid 1px; background-color: ActiveCaption; padding: 3pt;width:215pt;">'
+'			<table style="width:215pt; background-color: ActiveCaption; border: none" cellpadding="0" cellspacing="0" border="0"><tr>'
+'			<td id="progress_caption" style="font: caption; font-size: 13pt; background-color: ActiveCaption; color: CaptionText; border: none">'
+nadpisek
+'			</td>'
+'			<td align="right" style="font: caption; font-size: 13pt; color: CaptionText; background-color: ActiveCaption; border: none">'
+'			<a href="#" onclick="document.getElementById(\'wkinprgs\').style.visibility=\'hidden\';document.getElementById(\'wkinprgs_ifr\').style.visibility=\'hidden\';return false" title="Schovat" style="text-decoration:none; background-color: ActiveCaption; color: CaptionText; font-size: 13pt">X</a>'
+'			</td>'
+'			</table>'
+'		</div>'
+'		<div align="center" style="background-color: window;"><br><img src="/images/progress.gif" border=0></div>'
//+'	</div>'
//+'</div>'
		    ;
		    DIVObj = b.appendChild(tempDIV);
		}

//	var o = win.document.getElementById('wkinprgs');
	var o = DIVObj;
	if (o && o.style) {
		var x=10; y=10;
		if (isNaN(window.screenX)) {
			x=win.document.body.scrollLeft+(win.document.body.clientWidth-220)/2;
			y=win.document.body.scrollTop+(win.document.body.clientHeight-65)/2;
		}
		else {
			x=(win.innerWidth-220)/2+win.pageXOffset;
			y=(win.innerHeight-65)/2+win.pageYOffset;
		}
		o.style.left=x;
		o.style.top=y;
		o.style.visibility='visible';
//		o = win.document.getElementById('wkinprgs_ifr');
		o = IFrameObj;
		if (o && o.style) {
			o.style.left=x;
			o.style.top=y;
			o.style.visibility='visible';
		}
	}
}
catch(exception) {}
}

function getBrowserName() {
	var detect = navigator.userAgent.toLowerCase();
	var OS,browser,version,total,thestring;

	if (checkIt('konqueror'))
	{
		browser = "Konqueror";
		OS = "Linux";
	}
	else if (checkIt('safari')) browser = "Safari"
	else if (checkIt('firefox')) browser = "Firefox"
	else if (checkIt('omniweb')) browser = "OmniWeb"
	else if (checkIt('opera')) browser = "Opera"
	else if (checkIt('webtv')) browser = "WebTV";
	else if (checkIt('icab')) browser = "iCab"
	else if (checkIt('msie')) browser = "Internet Explorer"
	else if (!checkIt('compatible'))
	{
		browser = "Netscape Navigator"
		version = detect.charAt(8);
	}
	else browser = "An unknown browser";

	if (!version) version = detect.charAt(place + thestring.length);

	if (!OS)
	{
		if (checkIt('linux')) OS = "Linux";
		else if (checkIt('x11')) OS = "Unix";
		else if (checkIt('mac')) OS = "Mac"
		else if (checkIt('win')) OS = "Windows"
		else OS = "an unknown operating system";
	}
	
	return browser;

	function checkIt(string)
	{
		place = detect.indexOf(string) + 1;
		thestring = string;
		return place;
	}
}

// funkce najde prvni formular a nastavi focus na prvni prvek, vola se onLoad na formulari
function placeFocus() {
	try
	{
		var focused = false;
		if (document.forms.length > 0) {
			for (j = 0; j < document.forms.length; j++) {
				var frm = document.forms[j];
				for (i = 0; i < frm.length; i++) {
					var fld = frm.elements[i];
					if (fld.type && ((fld.type == "text") || (fld.type == "textarea") || (fld.type == "checkbox") || (fld.type == "radio") || (fld.type.toString().charAt(0) == "s"))) {
						if ( !fld.readOnly && !fld.disabled) {
							fld.focus();
							focused = true;
						}
					}
					if ( focused ) break;
				}
				if ( focused ) break;
			}
		}
	}
	catch(exception) {}
}

function versoKeyDown(e){
	if (!e) e = window.event;
	if ( e ) {
		if (e.keyCode) code = e.keyCode;
		else if (e.which) code = e.which;
		if ( e.altKey && code >= 48 && code <= 57 ){ // alt+cislo -> prepnuti trideni na strance
			code = code - 49;
			if ( code == -1 ) code = 9;
			'vrorderby' + code
			var link;
			for (i = 0; i < document.links.length; i++ ) {
				if ( document.links[i].name == 'vrorderby' + code ) {			
					link = document.links[i];
					e.returnValue = false;
					break;
				}
			}
			if ( link ) {
				doWkinPrgs(null);
				if ( link.onclick() != false ) {
					document.location.href = link.href;
				}
			}
//			e.returnValue = false;
		}
		else if ( !e.ctrlKey && ( code == 33 || code == 34 ) ) { //pgup, pgdown -> strankovani, +ctrl -> prvni, posledni stranka
			var aname = '';
			if ( e.altKey && code == 33) {
				aname = 'pgfirst';
			}
			else if ( e.altKey && code == 34) {
				aname = 'pglast';
			}
			else if ( !e.altKey && code == 33) {
				aname = 'pgprev';
			}
			else if ( !e.altKey && code == 34) {
				aname = 'pgnext';
			}
			if ( aname != '' ) {
				for (i = 0; i < document.links.length; i++ ) {
					var link = document.links[i];
					if ( link.name == aname ) {
						e.returnValue = false;
						doWkinPrgs(null);
						document.location.href = link.href;
						break;
					}
				}
			}
		}
		else if ( code == 113 ) { //F2 -> vyvolani ciselniku
			var targ;
			if (e.target) targ = e.target;
			else if (e.srcElement) targ = e.srcElement;
			if (targ.nodeType == 3) // defeat Safari bug
				targ = targ.parentNode;
			if ( targ && targ.name ) {
				var link;
				for (i = 0; i < document.links.length; i++ ) {
					if ( document.links[i].name == targ.name ) {			
						link = document.links[i];
						e.returnValue = false;
						break;
					}
				}
				if ( link ) link.onclick();
			}
		}
		else if (code == 116) top.window.closing = false; //F5 - chci zabranit hlaskam, kdyz znova nacitam stranku
	}
}
document.onkeydown=versoKeyDown;

  function versoCloseIt(e) {
    if ( top.window.closing && !top.window.opener) {
			if (!e) e = window.event;
			e.returnValue = "\n\n\n\n\nOpravdu chcete zavřít hlavní okno aplikace nebo přejít na jinou aplikaci?\n\n\n\n\n\n\n\n";
		}
  }
  try {
		top.window.closing = true; 
  } catch(exception) {}
  // if (top.window == window) { window.onbeforeunload=versoCloseIt; }  //prozatim vypnuto, musi se do vsech onclick u anchoru a u onsubmit na formulari doplnit: top.window.closing=false

// zafixovani zahlavi tabulky - vola se v onload: vrfixheader(tabid), kde tabid je id tagu table, ktery chci zafixovat. Fixuje se cely HEAD a musi byt v tabulce !
	var hdr, tab;
	var onResizeHandler;
	var intheader;
	
	function vrgetPosTop(obj, objsource) {
		el = objsource;
		var ot=el.offsetTop;
		while((el=el.offsetParent) != null) { ot += el.offsetTop; }
		//return document.body.scrollTop+15;
		var scrollTop = document.body.scrollTop || document.documentElement.scrollTop;
//		document.title=ot+' - '+document.body.scrollTop+' - '+scrollTop;
		return ot > scrollTop ? ot : scrollTop;
	}
	
	function onResizeAdjustTable() {
		if (intheader) clearTimeout(intheader);
		if (onResizeHandler) onResizeHandler();
		
		hdr.style.width=tab.offsetWidth+'px';
		hdr.tHead.style.width=tab.tHead.offsetWidth+'px';
		
		for (r=0; r<tab.tHead.rows.length;r++) { //pomale
			for(c=0;c<tab.tHead.rows[r].cells.length;c++) {
				hdr.tHead.rows[r].cells[c].style.width = 0+'px';
			}
		}
		   
    for (r=0; r<tab.tHead.rows.length;r++) { //pomale
    
		  //for (r=tab.tHead.rows.length-1; r>=0;r--) { //pomale
		  //tab.tHead.rows[r].cells.length - pocet sloupcu tabulky
			for(c=tab.tHead.rows[r].cells.length-1;c>=0;c--) {
				hdr.tHead.rows[r].cells[c].style.width=tab.tHead.rows[r].cells[c].offsetWidth+'px';
				//tab.tHead.rows[r].cells[c].offsetWidth - sirka kazdeho sloupce
			}
			for(c=0;c<tab.tHead.rows[r].cells.length;c++) {
			  w=tab.tHead.rows[r].cells[c].offsetWidth;
        while (w>=0 && hdr.tHead.rows[r].cells[c].offsetWidth>tab.tHead.rows[r].cells[c].offsetWidth) {
          hdr.tHead.rows[r].cells[c].style.width=w+'px';
				  w--;
				}
			}
			for(c=tab.tHead.rows[r].cells.length-1;c>=0;c--) {
				w=tab.tHead.rows[r].cells[c].offsetWidth;
				while (w>=0 && hdr.tHead.rows[r].cells[c].offsetWidth>tab.tHead.rows[r].cells[c].offsetWidth) {
					hdr.tHead.rows[r].cells[c].style.width=w+'px';
					w--;
				}
			}
		}
		
		vrmoveheader();
	}

	function vrmoveheader() {	
		hdr.style.top=vrgetPosTop(hdr,tab)+'px';
		if (getBrowserName() == 'Firefox') {
			if (document.body.offsetWidth >= tab.offsetWidth) {
        //hdr.style.left='0px';     // VN // tady jsem zakomentoval, aby se hlavička vykreslovala do správné pozice
      } //fix Firefox
		}
		intheader = setTimeout('vrmoveheader()',400);
	}
		
	function vrfixheader(tabid) {
		if ( document.getElementById(tabid) && document.getElementById(tabid).tHead) {
			tab = document.getElementById(tabid);
			if (tab) {
				hdr = tab.cloneNode(false);
				hdr.id += 'Header';
				hdr.style.position='absolute';
				hdr.appendChild(tab.tHead.cloneNode(true));
				//hdr.style.width=tab.offsetWidth;
				//hdr.tHead.style.width=tab.tHead.offsetWidth;
				hdr.style.width='';
				hdr.tHead.style.width='';
				hdr.setAttribute('width',null); 
				hdr.tHead.setAttribute('width',null); 
				tab.parentNode.insertBefore(hdr,tab);
				
				onResizeAdjustTable();
				onResizeHandler = window.onresize;
				window.onresize = onResizeAdjustTable;

				vrmoveheader();
			}
		}
	}  
// konec zafixovani tabulky  
  
function getForm (obj) {
//funkce vrati pro dany objekt formular, ve kterem se nachazi
    if (obj.nodeName == 'FORM') { return obj; }
    while ( obj.parentNode ) {
		if (obj.nodeName == 'FORM') { return obj; }
		obj = obj.parentNode;
	}
}

function getFormId (obj) {
//funkce vrati pro dany objekt id formulare, ve kterem je
    var f = getForm(obj);
	if (f) {
         var fid = f.elements.namedItem('__idf');
  	     if (fid) { return fid.value; } 
	}
	return '';
}

function getFormByFormid (doc, formid) {
//funkce dle id formulare najde prislusny objekt
//musim specifikovat, kde hledat - dokument, oppener.document,...
    if (doc && doc.forms) {
	    for (var i=0; i < doc.forms.length; i++) {
	        var fid = doc.forms[i].elements.namedItem('__idf');
	        if (fid && fid.value == formid) { return doc.forms[i]; }
		}
	}
}

function drzHodnotu(prvek) 
{
	if ( ! prvek.defaultValue ) { 
		prvek.defaultValue = ""
	}
	if ( prvek.value != prvek.defaultValue) {
		prvek.value = prvek.defaultValue
	}
}

function novaHodnota(prvek,hodnota)
{
	prvek.defaultValue = hodnota
	prvek.value = hodnota
}

function dynCiselnikCesta(prvek,params,jmeno,idf,ziskana_promenna, lovparams, lovvars) {
  var p='';
  if (params != '') {
    var prm_array = params.split('##_##');
	var prm_cnt = 0;
	while ( prm_cnt < prm_array.length ) {
	  var co = prm_array[prm_cnt+1];
	  var f=getFormByFormid(window.document,idf);
	  if (f) {
	  	var obj = f.elements.namedItem(prm_array[prm_cnt]);
	  	if (obj) {
	  	  co = obj.value;
	  	}
	  }
	  prm_cnt += 2;
	  if (prm_cnt != 2) { p += '##_##'; }
	  p += co;
	}
  }
  return vr_stript_name + "?fname=dynCiselnik&paramlov=" + escape(p)
  			+ "&lov=" + escape(jmeno)
			+ "&prvek=" + escape(prvek)
			+ "&idf=" + escape(idf)
			+ "&ziskana_promenna=" + escape(ziskana_promenna)
			+ "&lovparams=" + escape(lovparams) 
			+ "&lovvars=" + escape(lovvars) + "&"+lovvars;
}

function dynCiselnik(prvek,params,jmeno,idf,ziskana_promenna, lovparams, lovvars, nextname) { 
	var loc_vrFind = vrFind;
	vrFind = '';
	var autocomplete = 'no';
	var f=getFormByFormid(window.document,idf);
	if (f) {
		var obj = f.elements.namedItem(prvek);
  	if (obj) {
  	  autocomplete = obj.getAttribute('autocomplete');
  	}
	}

  if (autocomplete=='yes') {	
  	// zde chci udelat misto vyskakovaciho okna vlozeny iframe
  	$('#IFRwDynCis').remove();
  	if ( $('#IFRwDynCis').length == 0) {
  		$(document.body).append('<iframe id="IFRwDynCis" title="Výběr z číselníku"></iframe>');
  	}
  	var d = $('#IFRwDynCis');
		d.attr("src", dynCiselnikCesta(prvek,params,jmeno,idf,ziskana_promenna, lovparams, lovvars) + loc_vrFind + '&_auto=1');
  	d.dialog({
  		autoOpen: false,
			modal: true
//		width: 800,
//		height: 450,
	});
  } else {
	  var w = window.open( dynCiselnikCesta(prvek,params,jmeno,idf,ziskana_promenna, lovparams, lovvars) + loc_vrFind,
			   "wDynCis"+nextname,
			   "Scrollbars=1,resizable=1,width=400,height=450,z-lock=yes");
	  if (typeof w  == "undefined") {  alert('V prohlížeči musíte povolit otevírání oken z JavaScriptu pro tuto aplikaci.'); }
	  else {
		  if (w.opener == null)
				w.opener = self;
		  w.focus();
	  }
  }
}

function dynCiselnikCesta_upgr(prvek,params,jmeno,idf,ziskana_promenna, lovparams, lovvars) 
{
  var p='';
  if (params != '') {
    var prm_array = params.split('##_##');
  	var prm_cnt = 0;
  	while ( prm_cnt < prm_array.length ) {
  	  var co = prm_array[prm_cnt+1];
  	  var f=getFormByFormid(window.document,idf);
  	  if (f) {
  	  	var obj = f.elements.namedItem(prm_array[prm_cnt]);
  	  	if (obj) {
  	  	  co = obj.value;
  	  	}
  	  }
  	  prm_cnt += 2;
  	  if (prm_cnt != 2) { p += '##_##'; }
  	  p += co;
  	}
  }
  var cf='';
  var pf=0;
  var f=getFormByFormid(window.document,idf);
  if (f) {
    for (var pf=0;pf<document.forms.length;pf++) {
      if (document.forms[pf]==f){
        cf = "&_cislo_formu=" + pf;
      } 
    } 
//    cf = "&_cislo_formu='" + f.getAttribute('name') + "'";
  }

  return vr_stript_name + "?fname=dynciselnik_upgr&paramlov=" + escape(p)
  			+ "&lov=" + escape(jmeno)
			+ "&prvek=" + escape(prvek)
			+ "&idf=" + escape(idf)
			+ "&ziskana_promenna=" + escape(ziskana_promenna)
			+ "&lovparams=" + escape(lovparams)
			+ cf
			+ "&lovvars=" + escape(lovvars) + "&"+lovvars;
}

function dynCiselnik_upgr(prvek,params,jmeno,idf,ziskana_promenna, lovparams, lovvars, nextname) { 
	var loc_vrFind = vrFind;
	vrFind = '';
	
	var autocomplete = 'no';
	var f=getFormByFormid(window.document,idf);
	if (f) {
		var obj = f.elements.namedItem(prvek);
	  	if (obj) {
	  	  autocomplete = obj.getAttribute('autocomplete');
	  	}
	}
	
//  if ( loc_vrFind != '' ) {
  if (autocomplete=='yes') {	
  	// zde chci udelat misto vyskakovaciho okna vlozeny iframe
  	$('#IFRwDynCis').remove();
  	if ( $('#IFRwDynCis').length == 0) {
  		$(document.body).append('<iframe id="IFRwDynCis" title="Výběr z číselníku"></iframe>');
  	}
  	var d = $('#IFRwDynCis');
	d.attr("src", dynCiselnikCesta_upgr(prvek,params,jmeno,idf,ziskana_promenna, lovparams, lovvars) + loc_vrFind + '&_auto=1');
  	d.dialog({
  		autoOpen: false,
		modal: true
//		width: 800,
//		height: 450,
	});
  }
  else {

	  var w = window.open( dynCiselnikCesta_upgr(prvek,params,jmeno,idf,ziskana_promenna, lovparams, lovvars) + loc_vrFind,
			   "wDynCis"+nextname,
			   "Scrollbars=1,resizable=1,width=800,height=450,z-lock=yes");
			   
	  if (typeof w  == "undefined") {  alert('V prohlížeči musíte povolit otevírání oken z JavaScriptu pro tuto aplikaci.'); }
	  else {
	
		  if (w.opener == null)
			w.opener = self;
		  w.focus();
	  }
  }
}

function cis_strom_cesta(prvek,params,jmeno,idf,ziskana_promenna, lovparams, lovvars) {
  var p='';
  if (params != '') {
    var prm_array = params.split('##_##');
	var prm_cnt = 0;
	while ( prm_cnt < prm_array.length ) {
	  var co = '';
      //eval( 'if (window.document.forms[0] && window.document.forms[0].'+prm_array[prm_cnt]+') { co=window.document.forms[0].'+prm_array[prm_cnt]+'.value } else { co=prm_array[prm_cnt+1] }' );
	  prm_cnt += 2;
	  if (prm_cnt != 2) { p += '##_##'; }
	  p += co;
	}
  }
  return vr_stript_name + "?fname=cis_strom&paramlov=" + escape(p)
  			+ "&lov=" + escape(jmeno)
			+ "&prvek=" + escape(prvek)
			+ "&idf=" + escape(idf)
			+ "&ziskana_promenna=" + escape(ziskana_promenna)
			+ "&lovparams=" + escape(lovparams)
			+ "&lovvars=" + escape(lovvars) + "&"+lovvars;
}

function cis_strom(prvek,params,jmeno,idf,ziskana_promenna, lovparams, lovvars) { 
  var w = window.open( cis_strom_cesta(prvek,params,jmeno,idf,ziskana_promenna, lovparams, lovvars) + vrFind,
		   "wDynCis",
           "Scrollbars=1,resizable=1,width=800,height=450,z-lock=yes");

  if (typeof w  == "undefined") {  alert('V prohlížeči musíte povolit otevírání oken z JavaScriptu pro tuto aplikaci.'); }
  else {

	  if (w.opener == null)
		w.opener = self;
	  w.focus();
  }
}

function getHTTPObject() {
  var xmlhttp;
  /*@cc_on
  @if (@_jscript_version >= 5)
    try {
      xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
    } catch (e) {
      try {
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
      } catch (E) {
        xmlhttp = false;
      }
    }
  @else
  xmlhttp = false;
  @end @*/
  if (!xmlhttp && typeof XMLHttpRequest != 'undefined') {
    try {
      xmlhttp = new XMLHttpRequest();
    } catch (e) {
      xmlhttp = false;
    }
  }
  return xmlhttp;
}
var http = getHTTPObject(); // We create the HTTP Object

var intervalID;

function callToServer(prvek,params,jmeno,idf) {
  clearInterval(intervalID);
  var inp;
  var f=getFormByFormid(window.document,idf);
  if (f) {
    inp=f.elements.namedItem(prvek);
  }
  
	if ( ! inp.defaultValue ) { 
		inp.defaultValue = ""
	}
	if ( inp.value != inp.defaultValue) {
  
		var vrlink;
		for (i = 0; i < document.links.length; i++ ) {
			if ( document.links[i].name == inp.name ) {			
				vrlink = document.links[i];
				break;
			}
		}
		
		vrFind = '&find=' + encodeURIComponent(inp.value);
		inp.value = inp.defaultValue;
		if ( vrlink ) vrlink.onclick();
		vrFind = '';
	}
}

function callToServer2(prvek,params,jmeno,idf) {
  clearInterval(intervalID);	
  var inp;
  var f=getFormByFormid(window.document,idf);
  if (f) {
    inp=f.elements.namedItem(prvek);
  }

  var URL = dynCiselnikCesta(prvek,params,jmeno,idf) + '&lkp=1'  + "&find=" + inp.value + '&params=' + escape(params);
  http.open("GET", URL, false);
  http.send(null); 
  if(http.status == 200) {
	//alert(http.responseText);	
	if (http.responseText.indexOf('<error>nofound</error>') > 0) {
		//function dynCiselnik(prvek,params,jmeno,idf,ziskana_promenna, lovparams, lovvars) { 
		dynCiselnik(prvek,params,jmeno, idf, 'neni', '', '');
	}
	else {
		handleResponse(prvek,
			http.responseText.substring(http.responseText.indexOf('<id>')+4, http.responseText.indexOf('</id>')),
			http.responseText.substring(http.responseText.indexOf('<popis>')+7, http.responseText.indexOf('</popis>')),
			idf);
	}
  }	
}	
	
function handleResponse(prvek, hodnota, napis,idf) {
	var input;
	var p=prvek.indexOf('lov_value_');
	var newstr = prvek.substring(0,p);
	newstr += prvek.substring(p+10,prvek.length);
	var f=getFormByFormid(window.document,idf);
	if (f) {
		f.elements.namedItem(newstr).value=hodnota;
		input=f.elements.namedItem(prvek);
	}
	if ( input && napis != input.value ) {
		var start = 0;
		var match = new RegExp(input.value, "i").exec(napis);
		if (match) { start = match[0].length; }
		input.value=napis;
		setSelectionRange(input, start, input.value.length);
	}
}	

function setSelectionRange(input, selectionStart, selectionEnd) { 
	if (input.setSelectionRange) {
		input.focus(); 
		input.setSelectionRange(selectionStart, selectionEnd); 
	} 
	else if (input.createTextRange) { 
		var range = input.createTextRange(); 
		range.collapse(true); 
		range.moveEnd('character', selectionEnd); 
		range.moveStart('character', selectionStart); 
		range.select(); 
	} 
} 

function setRefresh (prvek,params,jmeno,idf) {
	clearInterval(intervalID);
	intervalID = setInterval('callToServer("'+prvek+'","'+params+'","'+jmeno+'","'+idf+'")', 600);
}

// podpora dropdown boxu s vicecetnym vyberem
	function vr_check_mover(obj) {
//		obj.style.backgroundColor="Highlight";
//		obj.style.color="HighlightText";
		obj.style.backgroundColor="ButtonFace";
		obj.style.color="ButtonText";
	}
	
	function vr_check_mout(obj) {
		vr_check_rowcolor(obj);
	}
	
	function vr_check_click(obj) {
		if (obj && obj.cells[0] && obj.cells[0].firstChild) {
			cb = obj.cells[0].firstChild;
			cb.checked = cb.checked ? false : true;
			vr_check_rowcolor(obj);
		}
	}
	
	function vr_check_rowcolor(obj) {
		if (obj && obj.cells[0] && obj.cells[0].firstChild) {
			if ( obj.cells[0].firstChild.checked ) {
				//obj.style.backgroundColor="Highlight";
				//obj.style.color="HighlightText";	
				obj.style.fontWeight="bold"
			}
			else {
				//obj.style.backgroundColor="window";
				//obj.style.color="WindowText";
				obj.style.fontWeight="normal"
			}
		}
		else {
			obj.style.backgroundColor="window";
			obj.style.color="WindowText";
		}
	}
	
	function vr_check_tablecolor(obj) {
		for (i=0; i < obj.rows.length; i++) vr_check_rowcolor(obj.rows[i]);
	}
	
	function vr_check_selectall(obj) {
		for (i=0; i < obj.rows.length; i++) {
			if (obj.rows[i] && obj.rows[i].cells[0] && obj.rows[i].cells[0].firstChild) {
				obj.rows[i].cells[0].firstChild.checked = true;
			}
		}
		vr_check_tablecolor(obj);
	}
	
	function vr_check_selectnone(obj) {
		for (i=0; i < obj.rows.length; i++) {
			if (obj.rows[i] && obj.rows[i].cells[0] && obj.rows[i].cells[0].firstChild) {
				obj.rows[i].cells[0].firstChild.checked = false;
			}
		}
		vr_check_tablecolor(obj);
	}
	
	function vr_check_selectinv(obj) {
		for (i=0; i < obj.rows.length; i++) {
			if (obj.rows[i] && obj.rows[i].cells[0] && obj.rows[i].cells[0].firstChild) {
				obj.rows[i].cells[0].firstChild.checked = ! obj.rows[i].cells[0].firstChild.checked;
			}
		}
		vr_check_tablecolor(obj);
	}
	
	function vr_check_return(obj, inp) {
		var j=0;
		var text='';
		for (i=0; i < obj.rows.length; i++) {
			if (obj.rows[i] && obj.rows[i].cells[0] && obj.rows[i].cells[0].firstChild) {
				if ( obj.rows[i].cells[0].firstChild.checked ) {
					text=obj.rows[i].cells[1].firstChild.nodeValue;
					j++;
				}
			}
		}
		if (j==0) inp.value = 'Nic nevybráno';
		if (j==1) inp.value = text;
		if (j>=2) inp.value = 'Vybráno více';
		if (j==i) inp.value = 'Vše';
	}
function neulozit(){
  if (document.getElementById('neulozit').value!=''){
      window.onbeforeunload=function(){
	  return showWarning();
      }
    }
}
            
function showWarning(){
  return 'Opravdu si přejete opustit formulář bez uložení změn?';
}
                      
//funkce na zjiskani objektu dle name, ktera funguje i pro IE
function getElementsByName_iefix(tag, name) {  
  var elem = document.getElementsByTagName(tag);
  var arr = new Array();

  for(i = 0,iarr = 0; i < elem.length; i++){
		att = elem[i].getAttribute("name");
		if(att == name) {
	    arr[iarr] = elem[i];
	    iarr++;
		}
  }
  return arr;
}
