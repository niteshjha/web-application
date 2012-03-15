
window.canvas = {

  object: null,
  clicks: null,
  xoff: 0,
  yoff: 0,
  last:0,

  initialize: (id) ->
    canvas.object = if typeof id is 'string' then $(id) else id
    offset = canvas.object.offset()
    canvas.xoff = offset.left
    canvas.yoff = offset.top
    canvas.clear()

    return true
    

  # n: 0-indexed
  loadNth: (n, list = '#ungraded-responses', id = '#grading-canvas') ->
    list = $(list).find('ul:first')
    nImages = list.children('li').length
    return if nImages < 1
    
    n %= nImages
    me = if typeof id is 'string' then $(id) else id
    
    ctx = me[0].getContext('2d')
    image = new Image()
    src = list.children('li').eq(n).text()
    image.onload = () ->
      ctx.drawImage(image,15,0)
      ctx.strokeStyle="#fd9105"
      ctx.lineJoin="round"
    image.src = "#{gutenberg.server}/locker/#{src}"

  record: (event) ->
    x = event.pageX - canvas.xoff
    y = event.pageY- canvas.yoff

    return if x < 0 || y < 0 # click not inside canvas

    last = canvas.last
    canvas.clicks[last] = [x,y]
    canvas.last += 1

    if (last % 2) is 1
      first = canvas.clicks[last-1] #first click
      second = canvas.clicks[last] # second click

      if first[0] > second[0] # comparing x-coordinates
        a = second[0]
        width = first[0]-second[0]
      else
        a = first[0]
        width = second[0] - first[0]

      if first[1] > second[1] # comparing y-coordinates
        b = second[1]
        height = first[1]-second[1]
      else
        b = first[1]
        height = second[1] - first[1]

      #alert "#{width} --> #{height}"

      ctx = canvas.object[0].getContext('2d')
      ctx.strokeRect a,b,width,height
    return true
    
  clear: () ->
    canvas.clicks = new Array()
    canvas.last = 0
}
