
# { :preview => { :id => ['1-hxy-783', '1-78z-783jn'], :scans => [[1,2],[1,2,3,4]] } }

node :topics do 
  @topics.map{ |m| { :topic => {:name => m.name, :id => m.id} } }
end

node :questions do 
  @questions.map{ |m| { :question => {:name => m.name?, :id => m.id, :parent => m.topic_id} } }
end



