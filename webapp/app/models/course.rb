# == Schema Information
#
# Table name: courses
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  board_id   :integer
#  grade      :integer
#  subject_id :integer
#  created_at :datetime
#  updated_at :datetime
#

#     __:has_many___      __:has_many___   ____:has_many__
#    |              |    |              | |               |
#  Board --------> Courses ---------> Topics ---------> Questions
#    |               |  |               | |               |
#    |__:belongs_to__|  |___:has_many___| |__:belongs_to__|
#    

class Course < ActiveRecord::Base
  belongs_to :board 

  has_many :topics, :through => :syllabi
  has_many :syllabi

  validates :name, :presence => true
  validates :grade, :presence => true, \
            :numericality => {:only_integer => true, :greater_than => 0}
  
  # [:name,:board_id,:grade,:subject] ~> [:admin] 
  #attr_accessible 
end
