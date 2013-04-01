module SampleCampaign
 
  def self.generate
    template = CampaignTemplate.find_by_name("Example")
    template = CampaignTemplate.create(:name => "Example") if template.nil?
    campaign = Campaign.create(:campaign_template => template, 
                               :name => "Example ##{rand(1000)}", 
                               :data => Marshal.dump({ "foobar" => rand(1000) }))

    campaign.containers << Container.find_by_name("Geral")
    campaign.containers << Container.find_by_name("Notícias")

    Rails.logger.debug("[sample_campaign] #{campaign.name}")
  end

end
