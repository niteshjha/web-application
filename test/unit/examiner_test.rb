# == Schema Information
#
# Table name: examiners
#
#  id              :integer         not null, primary key
#  disputed        :integer         default(0)
#  created_at      :datetime
#  updated_at      :datetime
#  is_admin        :boolean         default(FALSE)
#  first_name      :string(30)
#  last_name       :string(30)
#  last_workset_on :datetime
#  n_assigned      :integer         default(0)
#  n_graded        :integer         default(0)
#

require 'test_helper'

class ExaminerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
