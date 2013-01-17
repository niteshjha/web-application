

###
  For when .tabbable.tab-left need to be created on the fly based on returned JSON

  JSON below has the following * fixed * form 
    {tabs : [{name : xyz, id : 123}, {name : abc, id : 789} .... ]}
  Only this kind of JSON will result in tabs

  Optionally, there can also be a key called :filters
    { tabs: [{ ... }, { ... } ... ], filters : [a,b,c] }

  Filters change the data-url of ul > li > a as follows:
    <a data-url="url?a="true"&b="true"&c="true" ... ></a>

  Any other tweaking can be done using the options hash
  'options' is of the form : 
    options = { 
      shared : < panel in toolbox >, (optional): if present, all tabs share the same panel
      klass : { => 'class' attributes to set on ... 
        root : ( .tabbable and .tabs-left are implicit )
        ul : ( root > ul: .nav & .nav-tabs are implicit )
        a : ( ul > a )
        content : ( .tab-content is implicit )
        div : ( content > div: .tab-pane is implicit )
      },
      id : {
        root : ... ,
        < others > ...
      } , 
      data : { => data-* attributes set on ul > li > a ( data-toggle="tab" is implicit )
        prev :
        url :
      } 

    }
###

emptyOptions = {
  klass : {
    root : "",
    ul : "",
    a : "",
    content : "",
    div : ""
  },
  id : {
    root : "",
    ul : "",
    a : "",
    content : "",
    div : ""
  },
  data : {
    prev : ""
    url : ""
  }
}

window.leftTabs = {
  create : (root, json, optns = {}) ->
    root = if typeof root is 'string' then $(root) else root

    options = {}
    $.extend options, emptyOptions, optns # at the very least, ensure empty values 
    sharedPanel = options.shared

    html = $("<div id='#{options.id.root}' class='tabbable tabs-left #{options.klass.root}'></div>")

    # Prep the shell
    html.appendTo root
    ul = $("<ul class='nav nav-tabs #{options.klass.ul}' id='#{options.id.ul}'></ul>")
    content = $("<div class='tab-content #{options.klass.content}' id='#{options.id.content}'></div>")
    ul.appendTo html

    content.appendTo html
    if sharedPanel?
      $("#toolbox").children("##{sharedPanel}").eq(0).clone().appendTo content

    # Collect the data-* attributes set on ul > li > a into one string. These are common to all <a>
    data = ""
    for j in ['prev', 'panel-url']
      data += " data-#{j}='#{options.data[j]}'" if options.data[j]?

    url = options.data.url
    if url?
      filters = json.filters
      if filters?
        url = if url.indexOf("?") > -1 then url else (url + "?")
        url += "&filter[#{f}]" for f in filters
      data += " data-url=#{url}" # -> final url - with filters

    data += " data-toggle='tab'"

    # Then, write the JSON
    for m in json.tabs
      li = if options.split then $("<li marker=#{m.id} class='split'></li>") else $("<li marker=#{m.id}></li>")
      li.appendTo ul
      if sharedPanel?
        html = "<a href=##{sharedPanel} #{data} class='#{options.klass.a}'>"
        if options.split
          html += "<div class='row-one'>#{m.name}</div>"
          html += "<div class='row-two'>#{m.split}</div></a>"
          a = $(html)
        else
          a = $("<a href=##{sharedPanel} #{data} data-toggle='tab' class='#{options.klass.a}'>#{m.name}</a>")
      else
        a = $("<a href='#dyn-tab-#{m.id}' #{data} data-toggle='tab' class='#{options.klass.a}'>#{m.name}</a>")
        pane = $("<div class='tab-pane #{options.klass.div}' id='dyn-tab-#{m.id}'></div>")
        pane.appendTo content
      a.appendTo li
    return true
}
