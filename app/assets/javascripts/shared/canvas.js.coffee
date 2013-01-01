
window.canvas = {
  blockKeyPress: false,
  object: null,
  ctx: null,

  checks : null,
  crosses : null,
  exclamations : null,
  mode : null,
  comments : null,

  xoff: 0,
  yoff: 0,
  last:0, # insert before updating index 
  colour : {
    crosses : "#ea5115",
    exclamations : "#f6bd13",
    checks : "#4b9630",
    white : "#ffffff",
    blue : "#1b13f1"
  }

  initialize: (id) ->
    canvas.object = if typeof id is 'string' then $(id) else id

    # Canvas context settings
    canvas.ctx = canvas.object[0].getContext('2d')
    canvas.ctx.lineCap = "round"
    canvas.ctx.lineJoin = "round"
    canvas.ctx.lineWidth = 3
    canvas.ctx.fillStyle = canvas.colour.blue
    canvas.ctx.font = "12px Ubuntu"

    offset = canvas.object.offset()
    canvas.xoff = offset.left
    canvas.yoff = offset.top

    canvas.checks = new Array()
    canvas.crosses = new Array()
    canvas.exclamations = new Array()
    canvas.comments = new Array()

    return true
    

  load : (scan) ->
    # 'scan' is a jQuery object provided by abacus as abacus.current.scan

    # Clear any previously added check marks etc 
    canvas.clear()
    ctx = canvas.ctx
    image = new Image()
    src  = scan.attr 'name'

    # Scans for a testpaper are stored together within a folder in locker/ 
    # And the locker is named "quizId-testpaperId" - which we store as an attribute 
    # on the parent student object. Note that the code is here for a specific quiz.
    # And a quiz can be taken only once by a student

    folder = scan.parent().attr 'within' # stored as an attribute in the parent student

    image.onload = () ->
      ctx.drawImage(image,15,0)

    image.src = "#{gutenberg.server}/locker/#{folder}/#{src}"
    return true

  drawMark : (draw = true) ->
    return false unless canvas.mode?
    return false if canvas.mode is "comments"

    ctx = canvas.ctx

    ctx.strokeStyle = if draw is true then canvas.colour[canvas.mode] else canvas.colour.white

    switch canvas.mode
      when 'checks'
        pts = if draw then canvas.checks.slice(-8) else canvas.checks.splice(-8)
      when 'crosses'
        pts = if draw then canvas.crosses.slice(-8) else canvas.crosses.splice(-8)
      when 'exclamations'
        pts = if draw then canvas.exclamations.slice(-8) else canvas.exclamations.splice(-8)

    for j in [0..1]
      start = 4*j
      ctx.beginPath()
      ctx.moveTo pts[start], pts[start + 1]
      ctx.lineTo pts[start + 2], pts[start + 3]
      # else
      #  ctx.rect pts[start], pts[start+1], pts[start+2], pts[start+3]
      ctx.stroke()
    return true


  record: (event) ->
    return false unless canvas.mode?
    x = event.pageX - canvas.xoff
    y = event.pageY- canvas.yoff

    return if x < 0 || y < 0 # click not inside canvas
    # alert "#{x} --> #{y} --> #{canvas.mode}"

    switch canvas.mode
      when 'checks'
        canvas.checks.push x-3,y-4,x,y,x,y,x+5,y-12 # pythagoras triplets
      when 'crosses'
        canvas.crosses.push x-5,y-5,x+5,y+5,x-5,y+5,x+5,y-5
      when 'exclamations'
        canvas.exclamations.push x-3,y-13,x-3,y, x-3,y+5,x-3,y+7
      when 'comments'
        if not $('#comment-box').hasClass 'hidden' # record only if comment-box is visible
          commentBox = $('#comment-box').children().eq(0) # input[type="text"]
          comment = $(commentBox).val()

          if comment.length isnt 0
            canvas.comments.push x,y, comment
            canvas.ctx.fillText comment, x, y
          commentBox.focus()

    canvas.drawMark()
    return true
    
  clear: () ->
    # The better way to clear a JS array is to set its length to 0
    canvas.checks.length = 0 if canvas.checks?
    canvas.crosses.length = 0 if canvas.crosses?
    canvas.exclamations.length = 0 if canvas.exclamations?
    canvas.comments.length = 0 if canvas.comments?
    canvas.last = 0

  undo: () ->
    canvas.drawMark false
    return true
  
  decompile: () ->
    ###
      Returns the list of points clicked on the canvas in the form: 
        a_b_c_d_e_f_g_h     ----> '_' is a separator
      It is understood that (a,b) and (c,d) are corners of one rectangle
      - as are (e,f) and (g,h). in the rails code, one always picks 
      pairs of points 
    ###
    ret = ""
    for type in ['crosses', 'checks', 'exclamations']
      switch type
        when 'crosses' then ret += "_R" # _R_ ...
        when 'checks' then ret += "_G" # _R_ ... _G_....
        when 'exclamations' then ret += "_T" # _R_.... _G_ .... _T_.....
      for p in canvas[type]
        ret += "_#{p}"
    ###
      Comments are complicated because they can have any character in them. 
      They need to be therefore wrapped properly
    ###
    
    l = canvas.comments.length
    ret += "_C"

    for cmnts,index  in canvas.comments
      j = (index % 3)
      if (j < 2) # => 0 or 1
        ret += "_#{canvas.comments[index]}"
      else
        ret += "_#{canvas.comments[index]}" # => += _"comment string"
    #alert ret
    return ret

}