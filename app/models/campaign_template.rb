class CampaignTemplate < ActiveRecord::Base
  has_many :campaigns

  validates_presence_of :name
  validates_uniqueness_of :name

  def permalink
    self.name.to_s.parameterize.to_s.gsub(/-/,'_')
  end
end
