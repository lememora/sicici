class CampaignJob < ActiveRecord::Base

  STATUS_NEW = 'new'
  STATUS_RUNNING = 'running'
  STATUS_STOPPED = 'stopped'
  STATUS_FINISHED = 'finished'

  belongs_to :campaign
  has_many :campaign_dispatches

  before_create :generate_template

  include SectionModelHelper::IncludeMethods
  extend SectionModelHelper::ExtendMethods

  def to_s
    "##{self.id} #{self.subject}"
  end

  def self.select_conditions_columns
    [ "campaign_jobs.subject" ]
  end

  def self.select_order_lambda_quick(select)
    lambda do
      return "campaign_jobs.subject ASC"
    end
  end

  def self.quick_format(result, search)
    output = String.new
    header = FormatHelper.markup_wrap(result.subject, search, 'u')
    footer = nil
    FormatHelper.quick_result(header, footer)
  end

  def hashmap
    map = HashWithIndifferentAccess.new
    map["campaign_job"] = self.attributes
    map["campaign_job"]["created_at"] = FormatHelper.date_time(self.created_at)
    map["campaign_job"]["updated_at"] = FormatHelper.date_time(self.updated_at)
    map["campaign_job_campaign"] = self.campaign.name
    map["campaign_job_status"] = { STATUS_NEW => "Novo",
                                   STATUS_RUNNING => "Executando",
                                   STATUS_STOPPED => "Interrompido",
                                   STATUS_FINISHED => "Concluído" }[self.status]
    if self.status==STATUS_NEW and self.scheduled and self.scheduled <= DateTime.now
      map["campaign_job_status"] = "Iniciando..."
    end
    map["campaign_scheduled"] = FormatHelper.date(self.scheduled)
    total = CampaignDispatch.total_by_campaign_job(self)
    unsent = CampaignDispatch.total_unsent_by_campaign_job(self)
    bogus = CampaignDispatch.total_bogus_by_campaign_job(self)
    completed = total > 0.0 ? (1.0 - (unsent.to_f / total.to_f)) * 100.0 : -1.0
    map["campaign_total"] = total
    map["campaign_sent"] = total - unsent
    map["campaign_bogus"] = bogus
    map["campaign_completed"] = ((completed * 10).round / 10.0).to_s if completed >= 0
    map["campaign_completed"] = "&empty;" if completed < 0
    map
  end

  def populate(data)
    self.attributes = data["campaign_job"]
  end

  def start
    connection = ActiveRecord::Base.connection

    query = Array.new
    query<< "UPDATE campaign_jobs SET scheduled=UTC_TIMESTAMP(), updated_at=UTC_TIMESTAMP() WHERE"
    query<< "pid=0 AND status='#{STATUS_NEW}' AND id=#{self.id}"

    connection.update(query.join(' ')) > 0
  end

  def stop
    connection = ActiveRecord::Base.connection

    query = Array.new
    query<< "UPDATE campaign_jobs"
    query<< "SET status='#{STATUS_STOPPED}', updated_at=UTC_TIMESTAMP() WHERE"
    query<< "status='#{STATUS_RUNNING}' AND id=#{self.id}"

    connection.update(query.join(' ')) > 0
  end

  protected

  def generate_template
    template = "campaign_template/#{self.campaign.campaign_template.permalink}"
    self.template = TemplateHelper.render_view(template, self.campaign.attributes)
  end
end
