# == Schema Information
#
# Table name: suggestions
#
#  id          :integer         not null, primary key
#  teacher_id  :integer
#  examiner_id :integer
#  completed   :boolean         default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#  signature   :string(255)
#

class Suggestion < ActiveRecord::Base
  
  has_many :questions
  belongs_to :teacher  
  
  def self.unassigned
    where(:examiner_id => nil)
  end  

  def self.assigned_to(id)
    where(:examiner_id => id)
  end

  def self.wip # wip = work in progress 
    where(:completed => false).select{ |m| m.question_ids.count > 0 }
  end

  def self.just_in
    #select{ |m| m.question_ids.count == 0 }
    where(:completed => false)
  end

  def check_for_completeness
    return true if self.completed 
    untagged = Question.where(:suggestion_id => self.id).untagged 
    if untagged.count == 0
      Mailbot.suggestion_typeset(self).deliver if self.update_attribute(:completed, true)
    end
    return false
  end

  def days_since_receipt
    return (Date.today - self.created_at.to_date).to_i
  end

  def weeks_since_receipt(categorize = false)
    # categorize groups scans into one of 4 buckets that are shown in #days-since-receipt
    w = self.days_since_receipt / 7
    return (categorize ? (w > 4 ? 4 : w) : w)
  end

  def label
    self.created_at.strftime "%b %d, %Y"
  end

  def image
    return "0-#{self.signature}-1-1"
  end

end # of class