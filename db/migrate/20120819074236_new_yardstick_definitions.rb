class NewYardstickDefinitions < ActiveRecord::Migration
  def up
    insights = {
      0 => [
            "(No) The response is either blank or too sparse to capture any insights",
            "(No) And what is written is not mathematically sound"
           ], 
      1 => [
            "(No) And the approach taken will not lead to the correct answer"
           ],
      2 => [
            "(Yes, and no) Some key insight(s) required to get to the correct answer missing" 
           ], 
      3 => [
            "(Yes) All required insights captured"
           ]
    }

    insights.each do |k,v|
      v.each do |reason|
        c = Yardstick.new :insight => true, :weight => k, :meaning => reason
        c.save
      end
    end

    formulations = { 
      0 => [
            "(No) Irrelevant in this case"
           ], 
      1 => [
            "(No) The follow up work is irrelevant because the insights are either missing or off by a lot",
            "(Yes, and no) In of itself, the follow up work might be correct. But it only furthers a faulty line of reasoning",
            "(No) The follow-up work is more incomplete than complete"
           ],
      2 => [
            "(Yes, and no) The follow up work has some errors and/or is only partially complete" 
           ],
      3 => [
            "(Yes) A systematic approach and justifications for correct reasoning are evident",
            "(Yes) But there are sudden, non-obvious jumps in logic. A little more elaboration of intermediate steps would have been nice"
           ]
    } 

    formulations.each do |k,v|
      v.each do |reason|
        c = Yardstick.new :formulation => true, :weight => k, :meaning => reason
        c.save
      end
    end

    calculations = { 
      0 => [
            "Doesn't matter / irrelevant in this case"
           ],
      1 => [
            "Some errors here and there"
           ],
      2 => [
            "No errors"
           ]
    }

    calculations.each do |k,v|
      v.each do |reason|
        c = Yardstick.new :calculation => true, :weight => k, :meaning => reason
        c.save
      end
    end

  end

  def down
    Yardstick.all.each do |m|
      m.destroy
    end
  end
end
