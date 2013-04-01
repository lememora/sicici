namespace :sample do

  task :contact => :environment do
    puts SampleContact.generate(100)
  end

  task :campaign => :environment do
    puts SampleCampaign.generate
  end

end
