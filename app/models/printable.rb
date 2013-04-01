class Printable < ActiveRecord::Base
  belongs_to :printable_template
  has_many :printable_jobs
  has_and_belongs_to_many :containers, :join_table => "printable_containers"

  validates_presence_of :name
  validates_uniqueness_of :name

  include SectionModelHelper::IncludeMethods
  extend SectionModelHelper::ExtendMethods

  def to_s
    "##{self.id} #{self.name}"
  end

  def hashmap
    map = HashWithIndifferentAccess.new
    map["printable"] = self.attributes
    map["printable"]["created_at"] = FormatHelper.date_time(self.created_at)
    map["printable"]["updated_at"] = FormatHelper.date_time(self.updated_at)
    template = self.printable_template
    map["printable_template"] = template.nil? ? "" : template.name
    map["containers"] = self.containers.map { |v| v.hash_id }
    map["container_names"] = self.containers.map { |v| v.name }.join(",")
    map
  end

  def populate(data)
    self.attributes = data["printable"]
    self.containers.clear
    (data["containers"] || []).each do |v|
      container = Container.find_by_hash_id(v)
      self.containers << container unless container.nil?
    end
  end
end
