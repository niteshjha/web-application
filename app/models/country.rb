# == Schema Information
#
# Table name: countries
#
#  id           :integer         not null, primary key
#  name         :string(50)
#  alpha_2_code :string(255)
#

class Country < ActiveRecord::Base
  def self.collection
    Country.all.map{ |c|
      {
#       :id    => c.id,
        :label => c.name,
        :value => c.alpha_2_code
      } 
    } 
  end

  def self.names
    []
    Country.all.each do |c|
      [].push(c.name)  
    end
  end 

end
