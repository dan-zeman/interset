// Podpurne funkce pro UI ve Verso prostrednictvim jQuery-UI

	(function( $ ) {
		$.widget( "ui.combobox", {
			_create: function() {
				var self = this,
					select = this.element.hide(),
					selected = select.children( ":selected" ),
					value = selected.text(),
					w = select.innerWidth() < 5 ? 150 : select.innerWidth();
					
				var input = this.input = $( '<input>' )
					.insertAfter( select )
					.val( value )
					.attr('selectname',select.attr('name'))
					.innerWidth( w )
					.blur(function() { 
						fo(select[0]);
						select.blur(); 
						$(this).removeClass("povinne softwarn warn softerr err softchyba chyba");
						$(this).addClass(select.attr('class'));
					})
					.autocomplete({
						delay: 0,
						minLength: 0,
						source: function( request, response ) {
							var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
							response( select.children( "option" ).map(function() {
								var text = $( this ).text();
								//if ( this.value && ( !request.term || matcher.test(text) ) )
								if (  ( !request.term || matcher.test(text) ) ) // UKO-814 - i praznou hodnotu bereme
									return {
										label: text.replace(
											new RegExp(
												"(?![^&;]+;)(?!<[^<>]*)(" +
												$.ui.autocomplete.escapeRegex(request.term) +
												")(?![^<>]*>)(?![^&;]+;)", "gi"
											), "<strong>$1</strong>" ),
										value: text,
										option: this
									};
							}) );
						},
						select: function( event, ui ) {

              //  nastavim spravny atribut selected pro vsechny <option>, JHf
//              $(select).find('option').removeAttr('selected');
//              $(select).find('option:nth-child('+(ui.item.option.index+1)+')').attr('selected','selected');
              
							ui.item.option.selected = true;
							self._trigger( "selected", event, {
								item: ui.item.option
							});	

							fo(select[0]);
							select.blur();
							$(this).removeClass("povinne softwarn warn softerr err softchyba chyba");
							$(this).addClass(select.attr('class'));

						},
						
						open: function(){
                $(this).autocomplete('widget').css('z-index', 999);
                $(this).autocomplete('widget').css('width', 170);
                return false;
            },

						
						change: function( event, ui ) {
							if ( !ui.item ) {
								var matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( $(this).val() ) + "$", "i" ),
									valid = false;
								
								var vrValue = "";
								var vrText = "";

								select.children( "option" ).each(function() {
									if (vrText == "") {
										vrText = $(this).text();
										vrValue = $(this).val();
									}
									if ( $( this ).text().match( matcher ) ) {
										this.selected = valid = true;
									}
								});
								if ( !valid ) {
									// remove invalid value, as it didn't match anything
									$( this ).val( vrText );
									select.val( vrValue );
									input.data( "autocomplete" ).term = "";									
								}
								fo(select[0]);
								select.blur();
								$(this).removeClass("povinne softwarn warn softerr err softchyba chyba");
								$(this).addClass(select.attr('class'));
								return false;
							}
						}
					})
					.addClass( "ui-widget ui-widget-content ui-corner-left" )
					.click(function(){ /* JHf, obsah inputu je oznacen pro kliknuti do inputu, dovoluje to hned psat */
            this.select();
          })
          ;

				input.data( "autocomplete" )._renderItem = function( ul, item ) {
					return $( "<li></li>" )
						.data( "item.autocomplete", item )
						.append( "<a>" + item.label + "</a>" )
						.appendTo( ul );
				};

				this.button = $( "<button type='button'>&nbsp;</button>" )
					.attr( "tabIndex", -1 )
					.attr( "title", "Zobrazit všechny položky" )
					.insertAfter( input )
					.button({
						icons: {
							primary: "ui-icon-triangle-1-s"
						},
						text: false
					})
					.removeClass( "ui-corner-all" )
					.addClass( "ui-corner-right ui-button-icon obd-autocomplete-size" )
					.click(function() {
						// close if already visible
						if ( input.autocomplete( "widget" ).is( ":visible" ) ) {
							input.autocomplete( "close" );
							return;
						}

						// work around a bug (likely same cause as #5265)
						$( this ).blur();

						// pass empty string as value to search for, displaying all results
						input.autocomplete( "search", "" );
						input.focus();
					});
			},

			destroy: function() {
				this.input.remove();
				this.button.remove();
				this.element.show();
				$.Widget.prototype.destroy.call( this );
			}
		});
	})( jQuery );
	