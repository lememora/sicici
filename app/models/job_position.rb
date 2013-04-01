class JobPosition < ActiveRecord::Base
  ##has_many :employments

  validates_presence_of :name
  validates_uniqueness_of :name
end
