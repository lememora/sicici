class Campaign < ActiveRecord::Base

  PERIODICITY = { 0 => "INDEFINIDO",
              86400 => "DIÁRIO",
             604800 => "SEMANAL",
            1296000 => "QUINZENAL",
            2629744 => "MENSAL" } # 31556926 / 12

  belongs_to :campaign_template
  has_many :campaign_jobs
  has_and_belongs_to_many :containers, :join_table => "campaign_containers"

  validates_presence_of :name
  validates_uniqueness_of :name

  before_create :generate_hash_id

  include SectionModelHelper::IncludeMethods
  extend SectionModelHelper::ExtendMethods

  def to_s
    "##{self.id} #{self.name}"
  end

  def image_url
    ApplicationHelper.public_data_url(:campaign_image, self.hash_id)
  end

  def hashmap
    map = HashWithIndifferentAccess.new
    map["campaign"] = self.attributes
    map["campaign"]["created_at"] = FormatHelper.date_time(self.created_at)
    map["campaign"]["updated_at"] = FormatHelper.date_time(self.updated_at)
    template = self.campaign_template
    map["campaign_template"] = template.nil? ? "" : template.name
    map["campaign_periodicity"] = PERIODICITY[self.periodicity.to_i]
    map["campaign_enabled"] = self.enabled ? "Sim" : "Não"
    map["containers"] = self.containers.map { |v| v.hash_id }
    map["container_names"] = self.containers.map { |v| v.name }.join(",")
    map["campaign_image_url"] = self.image_url
    map["campaign_image_img"] = self.image_url ? "<img src=\"#{self.image_url}?#{Time.now.to_i}\" width=\"120\"/>" : nil
    map
  end

  def campaign_image_base64
    ApplicationHelper.public_data_base64(:campaign_image, self.hash_id)
  end

  def populate(data)
    self.attributes = data["campaign"]
    self.enabled = data["campaign_enabled"] == "Sim"

    self.containers.clear
    (data["containers"] || []).each do |v|
      container = Container.find_by_hash_id(v)
      self.containers << container unless container.nil?
    end
  end

  def test(email)
    template_name = self.campaign_template.name
    subject = "Mensagem de Teste"
    data = self.attributes
    not Notifier.deliver_campaign_test(template_name, email, subject, data).nil?
  end

  private

  def generate_hash_id
    self.hash_id = ApplicationHelper.generate_rand_hash
  end
end
