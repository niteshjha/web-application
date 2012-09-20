
window.chart = {
  plot : null,
  seriesList : null,

  initialize : () ->
    chart.seriesList = new Array() unless chart.seriesList?
    chart.clear()
    return true

  clear : () ->
    chart.seriesList.length = 0
    return true

  draw : (options = {}) ->
    chart.plot = $.plot $('#flot-chart'), chart.seriesList, options
    return true

  series : {
    define : (json, key, dependentVar = null, independentVar = 'x') ->
      ###
        json = [ { key : { ... } }, { key : { ... } } ... ] - an array of hashes
        Every other argument is a key within json.key 
      ###
      return false unless dependentVar?

      newSeries = new Object()
      newSeries.data = []

      alongY = (independentVar is 'y')

      for m in json
        data = m[key]
        if alongY
          x = data[dependentVar]
          y = data[independentVar]
        else
          x = data[independentVar]
          y = data[dependentVar]
        newSeries.data.push [x,y] if (x? and y?)

      chart.seriesList.push newSeries if newSeries.data.length isnt 0
      return true

    customize : (n, options = {}) -> # customize n'th series with passed options
      series = chart.seriesList[n]
      return false unless series?
      $.extend series, options
      return true

    link: (n,m) -> # it is assumed that the series have already been added
      last = chart.seriesList.length - 1
      return false if (n < 0 || m < 0 || n > last || m > last)

      first = chart.seriesList[n].data
      second = chart.seriesList[m].data
      return false if first.length isnt second.length

      links = new Object()
      links.data = []

      for m,j in first
        links.data.push first[j]
        links.data.push second[j]
        links.data.push null
      chart.seriesList.push links if links.length isnt 0
      return true

    label: (n, json, key) ->
      # Ref: http://stackoverflow.com/questions/1174298/flot-data-labels

      last = chart.seriesList.length - 1
      return false if (n < 0 || n > last)

      points = chart.seriesList[n].data
      plc = chart.plot.getPlaceholder()

      for pt,j in points
        lbl = json[j][key].name # json is assumed to have a key named 'name' 
        node = chart.plot.pointOffset { x: pt[0], y: pt[1] }
        $("<div class='data-point-label'>#{lbl}</div>").css({
          top: node.top - 18,
          left: node.left + 5
        }).appendTo(plc)
      return true
  }

}