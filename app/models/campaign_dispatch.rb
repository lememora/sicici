class CampaignDispatch < ActiveRecord::Base

  STATUS_UNSENT = 'unsent'
  STATUS_SENT = 'sent'
  STATUS_BOUNCED = 'bounced'
  STATUS_REJECTED = 'rejected'
  STATUS_FAILED = 'failed'

  belongs_to :campaign_job
  belongs_to :subscriber

  after_save :update_subscriber

  def self.total_by_campaign_job(campaign_job)
    self.count(:conditions => [ "campaign_job_id = ?", campaign_job.id ])
  end

  def self.total_unsent_by_campaign_job(campaign_job)
    self.count(:conditions => [ "campaign_job_id = ? AND 
      status = '#{STATUS_UNSENT}'", campaign_job.id ])
  end

  def self.total_bogus_by_campaign_job(campaign_job)
    self.count(:conditions => [ "campaign_job_id = ? AND 
      (status = '#{STATUS_BOUNCED}' OR
       status = '#{STATUS_REJECTED}' OR
       status = '#{STATUS_FAILED}')", campaign_job.id ])
  end

  private

  def update_subscriber
    subscriber = self.subscriber
    if self.status==STATUS_SENT
      subscriber.rejected = false
      subscriber.bounces = 0
      subscriber.validated = true
    elsif self.status==STATUS_BOUNCED
      subscriber.rejected = false
      subscriber.bounces = subscriber.bounces + 1
    elsif self.status==STATUS_REJECTED
      subscriber.rejected = true
    end
    subscriber.save
  end
end
