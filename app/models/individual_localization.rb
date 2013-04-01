class IndividualLocalization < ActiveRecord::Base
  belongs_to :individual
  belongs_to :localization

  CONTEXT_ARRAY = [ Localization::CONTEXT_HOME, Localization::CONTEXT_BUSINESS ]

  validates_inclusion_of :context, :in => CONTEXT_ARRAY
end
