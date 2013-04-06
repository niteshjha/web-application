
# Returned json : { :preview => { :id => 5, :scans => [0,1,2,3,4] } } where
# 'scans' represents the list of page numbers in the quiz
# 
# Given the list always starts with 0, we could have sent just the 
# total # of pages back to whoever it is that needs it. But the form 
# of the returned json is one that we intend to use for all previews 
# - even in cases where the list of scans is not a contiguous set of numbers

object false
  node(:preview) {
    { :id => @uid, :scans => [*1..@quiz.span?] } 
  } 
  node(:a) { @uid }
  node(:b) { @quiz.id }
  node(:caption) { @quiz.name }

