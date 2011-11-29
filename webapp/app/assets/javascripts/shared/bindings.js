/*
  Define only those bindings here that would apply across all roles. 

  These bindings would apply to HTML elements with class, id or other 
  attributes that can occur across roles in the role-specific HTML.

  HTML elements that are specific to a particular role should be bound
  the role-specific .js file
*/ 

$( function() { 
    // Generally speaking, contain all forms first inside a <div class="new-entity"> and call 
    // .dialog() only on this <div>. And if you want the resulting dialog to 
    // close whenever the submit button is clicked ( if there is one and 
    // whatever it might be ), then assign class="close-on-submit" attribute to the <div>

    $('.new-entity, .update-entity').each( function() { 
      $(this).dialog({
        modal : true, 
        autoOpen : false
      }) ;
    }) ;

    $('.close-on-submit').ajaxSend( function() { 
        $(this).dialog('close') ;
    }) ;

    // Group individual forms into one accordion...  
    $('.form.accordion').accordion({ header : '.heading.accordion', collapsible : true, active : false }) ;
    // .. and let the accordion shut like a clam before sending an AJAX request
    $('.form.accordion').ajaxSend( function() {
        $(this).accordion('activate', false) ;
    }) ;

    // Button-set for submit buttons
    $('.submit-buttons').buttonset() ;

    // $('#board-list').buttonset() ;
    
    $('.action-panel.vertical').each( function() {
       alignVertical( $(this) ) ;
    }) ;

    /*
       Expand 'greedy' elements so that they take all remaining 
       width in their parent
    */ 

    $('.greedy').each( function() { 
        makeGreedy($(this)) ;
    }) ;

    /*
      Load controls in the #control-panel when a link in the #side-panel is clicked.
      Also, load the empty table - that is, just the headers - in #tables into #data-panel

      However, logic for loading any relevant data into #data-panel would 
      most probably be in the role-specific .js file and would require a separate 
      binding to the same elements listed below
    */

    $('#side-panel').on('click', '#side-panel a.main-link', function() {
      var controls = $(this).attr('load-controls') ;
      var table = $(this).attr('load-table') ;

      /*
        Otherwise, move any previous controls in #control-panel to #controls.hidden.
        Then move 'controls' to #control-panel w/ fade-in effect
      */ 
      if (controls != null) { 
        var previous = $('#control-panel').children().first() ;

        if (previous.length == 1){
          previous = previous.detach() ; 
          previous.appendTo($('#controls')) ;
        } 
        $(controls).appendTo('#control-panel').hide().fadeIn('slow') ; 
        makeGreedy( $(controls) ) ;
      }

      /* 
        Similarly, move any previous table in #data-panel to #tables.hidden
        and then the new 'table' to #data-panel. However, this time, empty 
        the first table first before moving it to #tables.hidden. We don't 
        want any residual data for next time
      */ 

      if (table != null) { 
        var previous = $('#data-panel').children().first() ;

        if (previous.length == 1) { 
          previous.find('.data:first').empty() ; // empty only the data, not the headers
          previous = previous.detach() ; 
          previous.appendTo($('#tables')) ;
        } 
        $(table).appendTo('#data-panel').hide().fadeIn('slow') ;
        makeGreedy( $(table) ) ; 
        resizeCellsIn( $(table).children('.table').first() ) ;
      } 

    }) ; // end 

    /*
      Count the number of columns for all tables. The count is important 
      for dynamic resizing of table columns. Static class attribute values - like 
      wide, regular & narrow - are not sufficient by themselves for telling us 
      what the width should be. If, however, they were to be used to specify relative 
      width ratios, then they might be useful
    */ 

    $('.table').each( function() { 
      countTableColumns($(this)) ;
      calculateColumnWidths($(this)) ;
    }) ; 

    /*
      In tables where rows have radio-buttons, clicking on one radio-button
      should un-click all other radio buttons in the table. This what the 
      function below does. However, it assumes that tables are created using
      our standard structure, that is : 
         .table 
           .heading
             .
             . 
           .data 
             .row 
               .cell 
                 %input{ :type => :radio }
       
       Also, note that we are using what's called deferred binding. The radio buttons we 
       click are not present when the document first loads. Hence, click() wouldn't work.
       jQuery 1.7+ has a new, more efficient way of handling this using the new on() method
    */ 

    $('#data-panel').on('click', '.data > .row > .radio', function() { 
      var uncles = $(this).parent().siblings() ; // ok, technically grand-uncles.. 

      $(uncles).each( function() { 
        var cousins = $(this).children('.radio') ; // there might be >1 radio buttons/row 

        if (cousins.length == 0) return ;
        $(cousins).each( function() {
          $(this).children('input[type="radio"]:first').prop('checked', false) ;
        }) ;
      }) ;

      $(this).children('input[type="radio"]:first').prop('checked', true) ;
    }) ;

    /*
      Updation of the same summary table can be triggered by many distinct events 
      spread across multiple DOM elements. And hence, rather than bind the updation 
      logic part to the triggering DOM element, it makes all the sense to bind 
      the logic to the table itself
    */ 

    $('.summary-table').ajaxSuccess( function(e, xhr, settings){
      var returnedJSON = $.parseJSON(xhr.responseText) ; 

      $(this).find('.table > .data').empty() ; // clear existing data first

      /*
        There are > 1 summary tables and all of them catch the AJAX success event.
        However, the success event was generated in a context and therefore not all
        tables are supposed to respond to it

        So that is what we do here. We check what the invoking URL was and then 
        which summary table needs to process any returned JSON data. For all other 
        tables, the execution should just fall through
      */ 

      if (settings.url.match(/schools\/list/) != null) { 
        if ($(this).attr('id') == 'schools-summary'){ // the capturing DOM element
          updateSchoolSummary(returnedJSON) ;
        } 
      }

    }) ;


}) ; // end of file ...


