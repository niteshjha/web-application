# == Schema Information
#
# Table name: students
#
#  id             :integer         not null, primary key
#  guardian_id    :integer
#  school_id      :integer
#  first_name     :string(255)
#  last_name      :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  study_group_id :integer
#

include ApplicationUtil

class Student < ActiveRecord::Base
  belongs_to :guardian
  belongs_to :school
  belongs_to :study_group
  has_one :account, :as => :loggable, :dependent => :destroy

  has_many :graded_responses
  has_many :quizzes, :through => :graded_responses

  validates :first_name, :last_name, :presence => true
  before_save :humanize_name
  after_save  :reset_login_info

  # When should a student be destroyed? My guess, some fixed time after 
  # he/she graduates. But as I haven't quite decided what that time should
  # be, I am temporarily disabling all destruction

  before_destroy :destroyable? 

  def username?
    self.account.username
  end 
  
  def name (who_wants_to_know = :guest) 
    case who_wants_to_know 
      when :teacher, :admin, :school
        return "#{self.first_name} #{self.last_name} (#{self.username?})"
      else 
        return "#{self.first_name} #{self.last_name}"
    end
  end 

  def name=(name)
    split = name.split(' ', 2)
    self.first_name = split.first
    self.last_name = split.last
  end

  def teachers
    Teacher.joins(:study_groups).where('study_groups.id = ?', self.study_group_id)
  end 

  private 
    def destroyable? 
      return false 
    end 

    def humanize_name
      self.first_name = self.first_name.humanize
      self.last_name = self.last_name.humanize
    end 

    def reset_login_info
      new_prefix = username_prefix_for(self, :student)
      u = self.account.username.sub(/^\w+\./, "#{new_prefix}.")
      e = self.account.email.sub(/^\w+\./, "#{new_prefix}.")
      self.account.update_attributes(:username => u, :email => e)
    end

end # of class 
