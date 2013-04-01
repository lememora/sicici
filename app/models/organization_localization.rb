class OrganizationLocalization < ActiveRecord::Base
  belongs_to :organization
  belongs_to :localization

  CONTEXT_ARRAY = [ Localization::CONTEXT_OFFICE ]

  validates_inclusion_of :context, :in => CONTEXT_ARRAY
end
