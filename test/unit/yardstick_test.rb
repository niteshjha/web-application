# == Schema Information
#
# Table name: yardsticks
#
#  id          :integer         not null, primary key
#  mcq         :boolean         default(FALSE)
#  meaning     :string(255)
#  insight     :boolean         default(FALSE)
#  formulation :boolean         default(FALSE)
#  calculation :boolean         default(FALSE)
#

require 'test_helper'

class YardstickTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
