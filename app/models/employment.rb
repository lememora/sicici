class Employment < ActiveRecord::Base
  belongs_to :individual
  belongs_to :organization
  ##belongs_to :job_position

  validates_uniqueness_of :individual_id, :scope => :organization_id
end
