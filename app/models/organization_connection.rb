class OrganizationConnection < ActiveRecord::Base
  belongs_to :organization
  belongs_to :connection_type

  validates_presence_of :value
  validates_uniqueness_of :connection_type_id, :scope => :organization_id

  acts_as_list :scope => :organization
end
