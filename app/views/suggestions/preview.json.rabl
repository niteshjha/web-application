
object false
  node(:preview) {
    {
      :id => "0-#{@suggestion.teacher_id}/#{@suggestion.signature}",
      :scans => [*1..@suggestion.pages].map{ |m| "page-#{m}.jpeg" }
    }
  } 

  node(:a) { "0-#{@suggestion.teacher_id}/#{@suggestion.signature}/page-1.jpeg" }
