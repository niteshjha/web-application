
jQuery ->
  
  window.preview = {
    blockKeyPress: false,

    initialize : () ->
      # step 1: hide siblings of #wide - except #left 
      wide = $('#wide')
      for m in wide.siblings()
        continue if $(m).attr('id') is 'left'
        $(m).addClass 'hide'

      wide.removeClass 'hide'

      # step 2: within #wide, hide siblings of #wide-X
      wideX = wide.children('#wide-X').eq(0)
      $(m).addClass 'hide' for m in wideX.siblings()
      wideX.removeClass 'hide'

      wideX.empty() if wideX.length isnt 0
      obj = $('#toolbox > #wp-preview').clone()
      obj.attr 'id', 'wide-X-carousel' # Working copy should have a different ID

      for a in obj.children('a')
        $(a).attr 'href', '#wide-X-carousel'
      obj.appendTo wideX
      return true
    
    showControls : (scans) ->
      carousel = $('#wide-X-carousel')
      return false if carousel.length is 0
      hide = if scans.length is 1 then true else false
      for m in carousel.children('a')
        if hide then $(m).addClass('hide') else $(m).removeClass('hide')
      return true

    execute : () ->
      obj = $('#wide-X > #wide-X-carousel')
      inner = obj.find('.carousel-inner').eq(0)
      first = inner.children('.item').eq(0)
      first.addClass 'active'
      obj.carousel { interval:15000 }
      return true

    loadJson : (json) ->
      ###
        json.preview = {
          source : [ vault | mint | minthril | scantray | scan-ashtray ],
          images : [ .... ], #  an N-element array of fully-delineated relative paths to the image
          captions : [ ..... ] # (optional) one caption per image 
        }

        This method will create, then append all the required <img> tags based 
        on what the passed JSON and the current gutenberg.server are
      ###
      return false unless json.preview?

      preview.initialize()

      target = $('#wide > #wide-X').find('.carousel-inner').eq(0)
      server = gutenberg.server 

      for img,i in json.preview.images
        item = $("<div class=item></div>").appendTo target
        $("<img alt='' src=#{server}/#{json.preview.source}/#{img}>").appendTo $(item)

        caption = if json.captions? then json.captions[i] else null
        $("<div class='carousel-caption top'><h3>#{caption}</h3></div>").appendTo($(item)) if caption?

      preview.execute()
      return true

    ###
    loadJson : (json, source, suffix = null) ->
        This method will create the preview in all situations - 
        when viewing candidate question in the 'vault', existing 
        quizzes in the 'mint' or stored response scans in the 'locker/atm'

        Needless to say, to keep the code here simple, the form of the passed 
        json should be consistent across all situations. And so, this is
        what it would be : 
          json.preview = { :id => 45, :scans => < single file-name > } OR
          json.preview = { :id => [56,67], :scans => [ [<images for '56'>], [<images for '67'>] ..] }
        where 'id' is whatever the preview is for and 'scans' are the list 
        of object-identifiers that need to be picked up. All interpretation 
        is context specific
      server = gutenberg.server
      switch source
        when 'mint' then base = "#{server}/mint"
        when 'vault' then base = "#{server}/vault"
        when 'atm' then base = "#{server}/atm"
        when 'locker' then base = "#{server}/locker"
        when 'scantray' then base = "#{server}/scantray"
        else base = null

      return false if base is null

      preview.initialize()

      # target = $('#document-preview').find 'ul:first'
      target = $('#wide > #wide-X').find('.carousel-inner').eq(0)
      roots = json.preview.id

      return false if roots.length is 0

        When we didn't have multi-part support, we had questions that could 
        be laid out on one page. We could therefore get away with specifying 
        just the folder name (in vault) for the question when generating previews
        of candidate questions because we knew that there would be atmost 
        JPEG within that folder

        However, multipart questions can span multiple pages. And we 
        need to be able to pick up all pages for preview. Couple this with the
        need to show multiple questions and we have no choice but to prepare
        for a situation where both 'preview.json.id' and 'preview.json.scans'
        are arrays

      if roots instanceof Array
        nRoots = roots.length
        multiRoot = true
      else
        nRoots = 1
        multiRoot = false

      scans = json.preview.scans
      preview.showControls scans

      # Relevant only when rendering yardstick examples 
      isMcq = false
      counter = 1

      for i in [0 .. nRoots - 1]
        if multiRoot
          root = roots[i]
          pages = scans[i]
        else
          root = roots
          pages = scans

        for page,j in pages
          hop = if (not multiRoot || (multiRoot && j == 0)) then true else false
          caption = json.caption

          switch source
            when 'mint'
              suffix = "preview" unless suffix?
              if root.indexOf("/") isnt -1 # root = a/b/c etc. 
                full = "#{base}/#{root}/page-#{page}.jpeg"
              else if root.indexOf("-") isnt -1
                full = "#{base}/#{root}/#{suffix}/page-#{page}.jpeg"
              else
                full = "#{base}/quiz/#{root}/preview/page-#{page}.jpeg"
              caption += " ( page #{page} )"
              alt = "##{page}"
            when 'vault'
              version = parseInt (Math.random()*4) # show a random version
              full = "#{base}/#{root}/page-#{page}.jpeg" # Always load version 0 preview
              # full = "#{base}/#{root}/0/page-#{page}.jpeg" # Always load version 0 preview
              alt = "#{root}"
            when 'locker'
              full = if root isnt 'nothing' then "#{base}/#{root}/#{page}" else "#{base}/#{page}" # backward compatibility
              alt = "pg-#{j+1}"
            when 'scantray'
              full = "#{base}/#{page}"
              alt = "pg-#{j+1}"
            else break

          item = "<div class=item hop=#{hop} m=#{j}></div>"
          item = $(item).appendTo target

          img = $("<img alt=#{alt} src=#{full}>").appendTo $(item)

          # Append caption - if specified
          $("<div class='carousel-caption top'><h3>#{caption}</h3></div>").appendTo $(item) if caption?

      # Now, call the preview
      preview.execute()
      return true
    ###

    # Returns the index of the currently displayed image, starting with 0
    currIndex : () ->
      p = $('#wide > #wide-X')
      return -1 if p.length is 0

      images = p.children('.carousel-inner').eq(0).children('.item')
      index = images.index '.active'
      return index
      
    # Given a question UID, returns its position in the image-list (0-indexed)
    # Returns -1 if not found 

    isAt : (uid) ->
      return -1 if not uid?
      p = $('#wide > #wide-X')

      images = p.find '.carousel-inner > .item'
      posn = -1

      for m,j in images
        img = $(m).children('img').eq(0)
        if img.attr('alt') is uid
          posn = j
          break
      return posn

    jump : (from, to) ->
      return if not to?
      p = $('#wide > #wide-X')

      p.carousel to
      return true

    ###
      Hop backwards/forwards one image. And when displaying the list of questions 
      to pick from for a quiz, update the side panel bearing in mind that some 
      questions can span multiple pages/images
    ###

    hop: (fwd = true) ->
      p = $('#wide > #wide-X')
      active = p.find('.carousel-inner > .item.active').eq(0)
      next = if fwd then active.next(".item[hop='true']") else active.prevAll(".item[hop='true']")
      active.removeClass 'active'
      next.addClass 'active'
      return true

  }


