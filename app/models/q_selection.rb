# == Schema Information
#
# Table name: q_selections
#
#  id          :integer         not null, primary key
#  quiz_id     :integer
#  question_id :integer
#  start_page  :integer
#  created_at  :datetime
#  updated_at  :datetime
#  index       :integer
#  end_page    :integer
#

#     __:has_many_____     ___:has_many___  
#    |                |   |               | 
#  Teacher --------> Quizzes ---------> Questions 
#    |                |   |               | 
#    |__:belongs_to___|   |___:has_many___| 
#    

class QSelection < ActiveRecord::Base
  belongs_to :quiz
  belongs_to :question

  has_many :graded_responses, dependent: :destroy
  has_many :variants, dependent: :destroy

  # [:all] ~> [:admin, :teacher]
  #attr_accessible 

  def self.on_page(n)
    # Return QSelections that either lie on page 'n' or that span
    # pages including page 'n'
    where('start_page <= ?', n).where('end_page >= ?', n)
  end

  def self.on_topic(n)
    select{ |m| m.question.topic_id == n }
  end

end
