# == Schema Information
#
# Table name: teachers
#
#  id         :integer         not null, primary key
#  first_name :string(255)
#  last_name  :string(255)
#  created_at :datetime
#  updated_at :datetime
#  school_id  :integer
#

#     __:has_many_____     ___:has_many___  
#    |                |   |               | 
#  Teacher --------> Quizzes ---------> Questions 
#    |                |   |               | 
#    |__:belongs_to___|   |___:has_many___| 
#    

#     ___:has_many____     __:belongs_to___  
#    |                |   |                | 
# Teacher ---------> Grade ---------> Yardstick
#    |                |   |                | 
#    |__:belongs_to___|   |___:has_many____| 
#    

require 'rexml/document'
include REXML

class Teacher < ActiveRecord::Base
  has_many :quizzes, :dependent => :destroy 
  belongs_to :school 
  has_one :account, :as => :loggable

  has_many :faculty_rosters
  has_many :study_groups, :through => :faculty_rosters

  has_many :grades
  has_many :yardsticks, :through => :grades

  validates :first_name, :last_name, :presence => true  
  before_save :humanize_name

  # When would one want to 'destroy' a teacher? And what would it mean? 
  # 
  # My guess is that a teacher should NEVER be 'destroyed' even if he/she 
  # is expected to quit teaching for the forseeable future (say, due to child birth). 
  # You never know, he/she might just get back to teaching. Moreover, the teacher's 
  # past record can be a good reference for the new school.

  #after_validation :setup_account, :if => :first_time_save?
  before_destroy :destroyable? 

  def build_xml(questions, students) 
  end 

  def build_tex 
  end 

  def compile_tex
  end 

  def name 
    (self.first_name + ' ' + self.last_name)
  end 

  def roster 
    # Yes, yes.. We could have gotten the same thing by simply calling self.study_groups
    # But if we return an ActiveRelation, then we get the benefit of lazy loading
    StudyGroup.joins(:faculty_rosters).where('faculty_rosters.teacher_id = ?', self.id)
  end 

  private 

    def setup_account 
      self.build_account
    end 

    def destroyable? 
      return false 
    end 

    def first_time_save? 
      self.new_record? || !self.account
    end 

    def humanize_name
      self.first_name = self.first_name.humanize
      self.last_name = self.last_name.humanize
    end 

end
