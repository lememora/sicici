class IndividualConnection < ActiveRecord::Base
  belongs_to :individual
  belongs_to :connection_type

  validates_presence_of :value
  validates_uniqueness_of :connection_type_id, :scope => :individual_id

  acts_as_list :scope => :individual
end
