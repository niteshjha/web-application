
############################################################################
## Bootstrap 
############################################################################

jQuery ->
  # Auto-click on the 'quizzes' tab. This will initiate the $.get request to get things started
  # $('#left-1 > ul:first a:first').tab 'show'

  $('#left-quizzes').on 'click', '.line', (event) ->
    event.stopPropagation()
    marker = $(this).attr 'marker'
    $.get "quiz/preview.json?id=#{marker}"

    return true

  $('#select-all-for-quiz').click (event) ->
    event.stopPropagation()
    $(m).click() for m in $('#wsb-sektions').children('.line')
    return false

  #$('#build-worksheet').click (event) ->
  $('#lnk-build-ws').click (event) ->
    someChecked = false
    for m in $('#wsb-sektions').find("input[type='checkbox']")
      someChecked |= $(m).prop('checked')
      break if someChecked
    
    unless someChecked
      event.stopPropagation()
      notifier.show 'n-wsb-no-selection'
    else
      # wsTailor.rewind()
      wsTailor.initialize()

    return someChecked

  $('#tab-qzb-topics').on 'shown', (event) ->
    pane = $(this).closest('.nav-tabs').eq(0).next().children('.tab-pane.active').eq(0)
    btnGroup = pane.find('.btn-group').eq(0)
    buttonGroup.initialize btnGroup unless btnGroup.length is 0
    return true

  ###
    [qzb] : Ensure that atleast one question is selected
  ###
  $('#form-qzb').submit (event) ->
    root = $(this).find('#qzb-questions').eq(0)
    isBlank = sthSelected = false
    checkBoxes = root.find ".line > .btn > input"

    for m in checkBoxes
      s = $(m).prop('checked')
      sthSelected = sthSelected || s
      break if sthSelected
    
    if sthSelected
      name = $(this).find("input[type='text']").eq(0).val()
      isBlank = if (not name or /^\s*$/.test(name)) then true else false
      notifier.show 'n-qzb-no-name' if isBlank
    else
      notifier.show 'n-qzb-no-selection'
    return (sthSelected and not isBlank)

  ###
    [wsb] : Ensure that atleast one student is selected (issue #70) 
  $('#form-wsb-3').submit (event) ->
    students = $(this).children("[id='wsb-sektions']").eq(0)
    sthSelected = false
    checkBoxes = students.find("input[type='checkbox']")

    for m in checkBoxes
      s = $(m).prop('checked')
      sthSelected = sthSelected || s
      break if sthSelected
    
    return true if sthSelected
    notifier.show 'n-wsb-no-selection'
    return false
  ###

  ###
    [ course-editing ]: Set id and type of asset to be attached / detached on the to-be submitted form
  ###

  $('#mng-assets').on 'submit', 'form', (event) ->
    root = $('#lessons-and-quizzes')
    selected = root.find '.line.selected' 
    id = selected.attr 'marker'
    type = if selected.hasClass('video') then 'Lesson' else 'Quiz'
    action = "attach_detach_asset?id=#{id}&type=#{type}"
    $(this).attr 'action', action
    return true

  ###
    Launch QuickTrial demo on click
  ###
  $('#btn-launch-demo').on 'click', (event) ->
    event.stopImmediatePropagation()
    m = $(this).closest('.modal').eq(0)
    m.modal 'hide'
    $('#m-demo').modal 'show'
    return true

  ###
    Step 2 of defining a new sektion
  ###

  $('#m-new-sk-1').on 'click', 'button', (event) ->
    return false if $(this).hasClass 'disabled'
    return true if $(this).attr('type') is 'submit'

    parent = $(this).closest '.modal'
    $(parent).modal 'hide'
    id = $(this).attr 'id'
    $('#m-new-sk-2').modal('show') if id is 'btn-add-now'
    event.stopImmediatePropagation()
    return true

  ###
    Launch Quick Trial explanatory dialog
  ###
  $('#btn-whatisthis').on 'click', (event) ->
    event.stopPropagation()
    $('#m-demo').modal 'hide'
    $('#m-demo-intro').modal 'show'
    return true

  ###
    [qzb]: When a filter is clicked
  ###
  $('#form-qzb').on 'click', '#lnk-qzb-fav, #lnk-qzb-selected, #lnk-qzb-showall', (event) ->
    id = $(this).attr 'id'
    switch id
      when 'lnk-qzb-fav'
        show = 'Favourites'
        klass = 'fav'
      when 'lnk-qzb-selected'
        show = 'Selected'
        klass = 'checkbox_checked'
      when 'lnk-qzb-showall'
        show = 'Show All'
        klass = 'none'

    # Step 1: Visual reminder of last filter selected
    filter = $(this).closest('ul').next()
    filter.text show

    # Step 2: Update [filter] attribute on #qzb-questions. The attribute 
    # is set when filter selection is changed and it determines which 
    # questions are shown 

    root = $('#qzb-questions')
    root.attr 'filter', klass
    sieve.through root
    return true

