

window.grtb = {
  root : null,
  ul : null,
  form : null,
  current : null, # <li.active>
  keyboard : false,

  show : () ->
    return false unless grtb.current?
    grtb.current.removeClass 'disabled'
    # disable and reset all * subsequent * tabs 
    for m in grtb.current.nextAll('li')
      $(m).addClass 'disabled'
      grtb.reset $(m)

    # Enable the feedback submit button only if on the last tab
    submitBtn = $('#btn-submit-fdb')

    # Ensure that the 'Show Solution' & 'Audit Key' buttons are enabled
    $(m).prop('disabled', false) for m in submitBtn.siblings()

    if grtb.current.next().length isnt 0
      submitBtn.addClass 'disabled'
      submitBtn.prop 'disabled', true
    else
      submitBtn.removeClass 'disabled'
      submitBtn.prop 'disabled', false

    a = grtb.current.children('a').eq(0)
    karo.tab.enable a.attr('id')
    return true

  reset : (li) ->
    # li as in ul.nav-tabs > li
    pane = li.children('a').eq(0).attr('href')
    content = li.parent().next()
    pane = content.children("#{pane}").eq(0)
    for k in $(pane).children('.requirement')
      $(k).removeClass 'selected'
      $(cb).prop 'checked', false for cb in $(k).find("input[type='checkbox']")
    return true

  rewind : () ->
    grtb.current = grtb.ul.children('li').eq(0)
    grtb.reset grtb.current
    grtb.show()
    return false

  select : (n) -> # n-th .requirement in currently active tab/pane, 0 < n < 10
    active = grtb.ul.next().children('.active').eq(0)
    target = active.children('.requirement').eq(n)
    return true if target.length is 0
    target.click()
    return true

}

jQuery ->

  # This script file is called only for roles that can grade => roles that 
  # that can see _grd-abacus. Hence, its safe to assume that #form-feedback is visible

  unless grtb.ul?
    grtb.ul = $('#form-feedback').find('ul.nav-tabs').eq(0)
    grtb.current = grtb.ul.children('li').eq(0)
    grtb.root = grtb.ul.parent()
    grtb.form = grtb.root.parent()

  #####################################################################
  ## Enable / disable keyboard shortcuts 
  #####################################################################

  $('#tab-grd-ws, #tab-grd-page').on 'shown', (event) ->
    grtb.keyboard = false
    return true

  $('#tab-grd-panel').on 'shown', (event) ->
    grtb.keyboard = true
    return true

  #####################################################################
  ## Behaviour of the Grading Abacus  
  #####################################################################

  grtb.ul.on 'click', 'li', (event) ->
    event.stopPropagation()
    return false unless grtb.keyboard # disable mouse-clicks too
    return false if $(this).hasClass 'disabled'

    grtb.current = $(this)
    grtb.show()
    return false # to prevent screen scrolling up

  grtb.root.on 'click', '.requirement', (event) ->
    event.stopImmediatePropagation()
    return false unless grtb.keyboard # disable mouse-clicks too

    multiOk = $(this).parent().hasClass 'multi-select'
    already = $(this).hasClass 'selected'

    if already
      $(this).removeClass 'selected'
      $(this).find("input[type='checkbox']").eq(0).prop 'checked', false
    else
      $(this).addClass 'selected'
      $(this).find("input[type='checkbox']").eq(0).prop 'checked', true

    unless multiOk
      for m in $(this).siblings('.requirement')
        $(m).removeClass 'selected'
        $(m).find("input[type='checkbox']").eq(0).prop 'checked', false

      # Move to the next tab
      unless already
        grtb.current = grtb.current.next()
        grtb.show()
    return true

  grtb.form.submit (event) ->
    annotated = false
    annotated |= (canvas.clicks[m].length isnt 0) for m in ['check', 'cross', 'question']
    annotated |= (canvas.comments.length isnt 0)

    if not annotated
      alert "Add atleast a comment or annotate with a check, cross or question mark"
      return false

    id = abacus.current.response.attr 'marker'
    clicks = canvas.decompile()
    action = "submit/fdb.json?id=#{id}&clicks=#{clicks}"
    $(this).attr 'action', action
    return true


  #####################################################################
  ## On successful submission of feedback 
  #####################################################################

  grtb.form.ajaxComplete (event, xhr,settings) ->
    url = settings.url
    matched = true

    if url.match(/submit\/fdb/)
      abacus.next.response()
      grtb.rewind()
    else
      matched = false

    event.stopPropagation() if matched is true
    return true

  #####################################################################
  ## Keyboard shortcuts to speed-up grading
  #####################################################################

  $('body').on 'keypress', (event) ->
    event.stopImmediatePropagation()
    return true unless grtb.keyboard

    lp = $('#left').children('#left-4').eq(0)
    if lp.hasClass 'hide'
      grtb.keyboard = false
      return true
    pane = lp.children().eq(1).children('#pane-grd-panel').eq(0)
    unless pane.hasClass 'active'
      grtb.keyboard = false
      return true

    key = event.which

    unless (key < 49 || key > 57) # numbers 1-9
      grtb.select( key - 49 )
    else if key is 115 # S => submit
      grtb.form.submit() if grtb.current.next().length is 0
    else if (key >= 102 && key <= 122) 
      buttons = abacus.root.find 'button'
      switch key 
        when 102  #F
          id = 'btn-rotate'
        when 104  #H
          id = 'btn-what'
        when 110  #N
          id = 'btn-next-scan'
        when 112  #P
          id = 'btn-prev-scan'
        when 114  #R
          id = 'btn-fresh-copy'
        when 116  #T
          id = 'btn-ok' 
        when 117  #U
          id = 'btn-undo' 
        when 119  #W 
          id = 'btn-write'
        when 120  #X
          id = 'btn-cross'
        when 121  #Y
          id = 'btn-prev-ques'
        when 122  #Z
          id = 'btn-next-ques'

      btn = buttons.filter("[id=#{id}]")[0]
      $(btn).click() if btn?

    return true

  #####################################################################
  ## If btn-submit-fdb is explicitly clicked 
  #####################################################################
  $('#btn-submit-fdb').click (event) ->
    event.stopPropagation()
    grtb.form.submit()
    return true


  #####################################################################
  ## Toggle between answer-key preview and grading 
  #####################################################################

  $('#btn-toggle-answerkey').click (event) ->
    # event.stopPropagation()
    backToGrading = $(this).hasClass('active')
    grtb.keyboard = backToGrading

    if backToGrading
      $(this).text("See Solution")
      show = $('#wide > #wide-grd-canvas')
    else
      $(this).text("Back to Grading")
      show = $('#wide > #wide-X')
      id = abacus.current.response.attr 'marker'
      $.get "question/preview?gr=#{id}"

      # ws = $('#tab-grd-ws').parent().attr 'marker'
      # $.get "ws/preview.json?id=#{ws}"

    $(m).addClass 'hide' for m in show.siblings()
    show.removeClass 'hide'

    return true

  #####################################################################
  ## Show audit form if grader sees issues w/ answer key during grading 
  #####################################################################

  $('#btn-audit-key').click (event) ->
    event.stopImmediatePropagation()
    audit = $('#m-audit-form')
    form = audit.find('form')[0]

    audit.modal 'show'
    action = form.getAttribute 'data-action'
    pattern = /gr=[\d]+/
    result = pattern.exec action
    action = action.replace result,"gr=#{abacus.current.response.attr('marker')}"
    form.setAttribute 'data-action', action
    return false


