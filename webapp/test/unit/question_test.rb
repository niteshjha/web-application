# == Schema Information
#
# Table name: questions
#
#  id         :integer         not null, primary key
#  folder     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
