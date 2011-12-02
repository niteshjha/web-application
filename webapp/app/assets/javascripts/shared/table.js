
function createTableRow( rowCells ) { 
  // Each element in 'rowCells' is either a pair or a triplet, where : 
  //   1st = display text (mandatory)
  //   2nd = class attribute to set on table cell (mandatory) 
  //   3rd = some other non-display data, set as marker=< something > (optional)
  // Return : A jQuery <div class=row>.... </div>

  var row = $('<div class="row"></div>') ;

  $.each(rowCells, function(index, cell){
    var value = cell[0] ; 
    var width = cell[1] ; 
    var marker = cell[2] ; 
    var newCell = $('<div class="cell ' + width + '"></div>') ;

    if (width =='radio' || width === 'checkbox') {
      newCell.append( $('<input type="' + width + '"></input>') ) ;
    } 
    // <div class="cell wide"></div>

    // <div class="cell wide">Something, something</div>
    if (value != null) newCell.text(value) ;
    if (marker != null) newCell.attr('marker', marker) ;

    $(row).append(newCell) ;
  }) ;

  return row ;
} 

function countTableColumns(table) { 
   /* 
     Every table in our app is of the form : 
        .table 
          .headings 
            .row 
              .cell .... 
          .data 
            .row 
              .cell ....
     We just count the number of .headings > .row > .cell and set value on the table
   */ 
   var nColumns = table.attr('num_columns') ;

   if (nColumns == null) { 
      nColumns = table.find('.headings .cell').length ;
      table.attr('num_columns', nColumns) ;
   } 
} 

function calculateColumnWidths(table) { 
  /*
    For the table like the one above, calculate % of parent width for a 
    wide, regular and narrow column. Aspect ratio = wide:regular:narrow = 3:2:1
  */
  var score = 0 ; 

  table.find('.headings .cell').each( function() { 
     if ($(this).hasClass('radio') || $(this).hasClass('checkbox')){
       return ; // return from calling function to continue to next jQuery object 
     } else if ($(this).hasClass('wide')) {
         score += 3 ;
     } else if ($(this).hasClass('regular')) {
         score += 2 ;
     } else if ($(this).hasClass('narrow')) {
         score += 1 ;
     } else { 
         score += 2 ;
     } 
  }) ; 

  table.attr('wide', 300/score ) ; 
  table.attr('regular', 200/score) ; 
  table.attr('narrow', 100/score) ; 

} // end 

/*
  The next two functions can only be called on an existing row or table. 
  For rows created on the fly but which aren't yet part of a table,  
  hold calling these functions until they are
*/ 

function setCellSizesIn( row ) { 
  var table = $(row).closest('.table') ; 
  var parentWidth = $(row).parent().width() ; 

  $(row).children().each( function() { 
     if ($(this).hasClass('radio') || $(this).hasClass('checkbox')){
       parentWidth -= 20 ;
     }
  }) ;

  /*
    Don't try to do an exact calculation and fit elements so tightly that they
    take exactly 100% of the their parent's width. Rounding errors mean that 
    sometimes a child element can get 1px more than it should have. And then, the
    alignment gets screwed. Play safe and give a little less than expected
  */ 
  var wide = (parseInt(table.attr('wide')) * parentWidth/101) ;
  var regular = (parseInt(table.attr('regular')) * parentWidth/101) ;
  var narrow = (parseInt(table.attr('narrow')) * parentWidth/101) ;

  // alert(" wide = " + wide + ", regular = " + regular + ", narrow = " + narrow) ;

  $(row).children().each( function() { // should be just .cells
    if ($(this).hasClass('wide')){
      $(this).width(wide) ;
    } else if ($(this).hasClass('regular')){
      $(this).width(regular) ;
    } else if ($(this).hasClass('narrow')) {
      $(this).width(narrow) ;
    } else if ($(this).hasClass('radio') || $(this).hasClass('checkbox')){
      $(this).width(20) ;
    } else { 
      $(this).width(regular) ;
    } 
  }) ; 
  
} // end  

function resizeCellsIn( table ) {
  table.find('.headings > .row, .data > .row').each( function() {
    setCellSizesIn($(this)) ;
  }) ;
} 

/*
  This next function can be applied to either of the following 2 structures - 
  a simple table or a 'mega-form'. The start-point, therefore, has to be either
  a <div> or a <form>

    #table-name         <form> 
      #dump               #dump 
      .column              .column
      .column              .column
      .                    .
      .                    .
      .column              .column 
  
  The assumption is that everthing is first dumped into, well, the #dump
  and that then the children of #dump need to spread equally amongst the .columns. 
  When this function finishes executing, #dump should be empty

  The forms/tables this function is called on are ones where the columns need to be 
  of equal width. If the widths are to be different, then perhaps the other 
  functions in this file are the ones to use
*/ 

function arrangeDumpIntoColumns(id) { 
  var startPoint = $(id) ; 
  var nToArrange = $(startPoint).children('#dump:first').children().length ; 

  if (nToArrange == 0) return ; // empty dump => everything arranged in columns

  var parentWidth = $(startPoint).parent().width() ; 
  var nColumns = $(startPoint).children('.column').length ;
  var maxWidth = (parentWidth / nColumns) ;
  var columnWidth = maxWidth * 0.99 ; // Just to be safe, use 99% of available width
  var perColumn = (nToArrange / nColumns) + 1;
  var index = 0 ;

  // alert(nColumns + ', ' + perColumn) ;

  $(startPoint).children('.column').each( function() { 
    var currColumn = $(this) ; 
    var nArranged = 0 ;

    $(this).width(columnWidth) ;
    $(this).css('margin-left', index * maxWidth) ;

    $(startPoint).children('#dump:first').children().each( function() {
      if (nArranged >= perColumn) return false; 

      var me = $(this).detach() ; 
      me.appendTo(currColumn) ;
      nArranged += 1 ;
      // alert(' Ab dekho' ) ;
    }) ; 
    // alert(' Broken from loop with nArranged = ' + nArranged) ;
    $(this).fadeIn('slow') ;
  }) ; 
} 

