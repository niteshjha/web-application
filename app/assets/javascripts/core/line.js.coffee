
renderTextAndEqnsOn = (obj, text, marker) ->
  hasTex = false
  if text.search(/\$.*\$/) isnt -1 # => LaTeX
    hasTex = true
    jaxified = karo.jaxify text 
    parent = obj.parent() 
    obj.replaceWith "<div class='tex'><script id='tex-#{marker}' type='math/tex'>#{jaxified}</script></div>"
    # kinda imp. to wrap <script> within some <div>
    j = parent.find('script')[0]
    MathJax.Hub.Queue ['Typeset', MathJax.Hub, j]
  else
    obj.text text
  return hasTex

### 
  Single line 
###

window.line = {

  write : (here, json, menu, buttons = null) ->
    return false if not json.id? or not json.name?
    here = if typeof here is 'string' then $(here) else here

    ###
      Fields in the JSON that change from one .line to the next
        - name (mandatory): set as 'text' 
        - id (mandatory): set as 'marker'
        - tag (optional): written extreme right, in orange 
        - badge (optional): Eg. quiz totals 
        - klass (optional)
        - icons (optional)

      Common to all .lines rendered from the same JSON 
        - buttons (optional) 
        - menu (optional) 
    ###

    isVideo = json.video?

    obj = $('#toolbox').children('.line').eq(0).clone()
    remaining = 12

    # 1. Do the easiest first 
    if json.klass?
      obj.addClass json.klass

    obj.attr 'marker', json.id
    children = obj.children()

    # Write the main text
    label = children.filter(".text")
    hasTex = renderTextAndEqnsOn label, json.name, json.id
    if hasTex 
      children = obj.children()
      label = children.filter('.tex') 

    # Tag
    tag = children.filter(".subtext")
    if json.tag?
      tag.text json.tag
      tag.addClass 'span3'
      remaining -= 3
    else
      tag.remove()

    # Contextual menu
    m = obj.find("[data-toggle='dropdown']")[0]
    if menu?
      m.setAttribute 'data-show-menu', menu
      $(m).addClass 'span1'

      unless isVideo
        children.filter(".badge").eq(0).remove() unless json.badge? # no badge if menu and badge.empty?
      remaining -= 1
    else
      $(m).parent().remove()

    # Badge
    badge = children.filter(".badge")
    if json.badge? || isVideo
      if isVideo
        $("<i class='icon-facetime-video'></i>").appendTo badge
        badge.addClass 'video'
        badge.attr 'data-video', json.video
      else
        badge.text json.badge
      badge.addClass 'span2'
      remaining -= 2

    # Icons 
    icons = children.filter "i"
    if json.icons?
      j = json.icons.split(' ')
      for k in j
        i = icons.filter("[class~=#{k}]")[0]
        continue unless i?
        $(i).removeClass 'hide'
        remaining -= 1
      $(m).remove() for m in icons.filter(".hide") # remove the unrequired and/or not found
    else
      $(m).remove() for m in icons

    # Buttons 
    btns = children.filter("div[class~='btn']")
    hiddenChkBox = children.filter("input[type='checkbox']")

    if buttons?
      hiddenChkBox.remove()
      j = buttons.split(' ') # each token = class set on an <i> within the .btn
      for b in btns
        keep = false
        i = $(b).children('i').eq(0)
        for k in j
          keep = true if i.hasClass(k)
          break if keep
        
        if keep
          chkBox = $(b).children("input[type='checkbox']").eq(0)
          name = chkBox.attr 'name'
          chkBox.attr 'name', "#{name}[#{json.id}]"
          chkBox.attr 'id', "#{name}_#{json.id}"
        else
          $(b).remove()
    else
      $(m).remove() for m in btns
      hiddenChkBox.attr 'name', "checked[#{json.id}]"
      hiddenChkBox.attr 'id', "checked_#{json.id}"

    # Stopwatch 
    watch = children.filter(".stopwatch")
    watch.remove() unless json.timer?

    # Whatever span remains, give to 'label'
    remaining = if remaining > 8 then 8 else remaining
    label.addClass("span#{remaining}") if remaining > 0

    # Done !!!
    obj.appendTo here
    return true
}

### 
  All lines 
###


window.lines = {
  columnify : (here, json, menu, buttons = null) ->
    # json = array of N objects 
    here = if typeof here is 'string' then $(here) else here
    columns = here.find '.column'
    $(m).empty() for m in columns

    nColumns = columns.length
    perColumn = if nColumns > 0 then ((json.length / nColumns ) + 1) else json.length
    perColumn = parseInt perColumn

    currIndex = 0
    currColumn = if nColumns > 0 then columns.eq(currIndex) else here
    nAdded = 0

    for m,j in json
      if nAdded > perColumn
        currIndex += 1
        currColumn = columns.eq(currIndex)
        nAdded = 0
      line.write currColumn, m, menu, buttons
      nAdded += 1
    return true

  # target, key, json, menu, buttons, clickFirst, pgn, pgnUrl
  render : (target, key, json, menu, buttons, clickFirst, pgn, pgnUrl = null) -> 
    return false unless target?
    return false if target.length is 0

    writeData = if key? then true else false
    # Enable / disable paginator as needed 
    if json.last_pg?
      pagination.enable pgn, json.last_pg
      pagination.url.set pgn, pgnUrl if pgnUrl?

      ###
        this next bit of code is done only for teachers and in a very specific 
        contexts - picking questions to add to a quiz - either when its 
        first being built or when its being edited subsequently

        the issue is that we would like pagination with multi-select. 
        with pagination, we can break a long list down into manageable chunks
        But multi-select requires that we retain any previously loaded data 
        and selections
      ###
      if target.hasClass 'pagination'
        if json.pg?
          page = target.children("div[page='#{json.pg}']")
          $("<div page=#{json.pg} class='multi-select purge-skip'></div>").appendTo target if page.length is 0
          target = target.children("div[page='#{json.pg}']").eq(0)
          $(m).addClass 'hide' for m in target.siblings()
          target.removeClass 'hide'
          writeData = target.children().length is 0

    # Render the returned JSON - in columns if so desired
    if writeData
      lines.columnify target, json[key], menu, buttons
      sieve.through target

    # Disable / hide any .line whose marker is in json.[disabled, hide]
    for m in ['disabled', 'hide']
      continue unless json[m]
      j = target.find('.line')
      for k in json[m]
        l = j.filter("[marker=#{k}]")[0]
        $(l).addClass(m) if l?

    # Auto-click first line - if needed
    target.children('.line').filter(":not([class~='disabled'])").eq(0).click() if clickFirst
    return true

}
