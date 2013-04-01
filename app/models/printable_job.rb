class PrintableJob < ActiveRecord::Base
  belongs_to :printable
  has_many :printable_dispatches

  after_create :generate_document

  include SectionModelHelper::IncludeMethods
  extend SectionModelHelper::ExtendMethods

  def to_s
    "##{self.id}"
  end

  def self.select_conditions_columns
    [ "printable_jobs.created_at" ]
  end

  def self.select_order_lambda_quick(select)
    lambda do
      return "printable_jobs.created_at DESC"
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
    map["printable_job"] = self.attributes
    map["printable_job"]["created_at"] = FormatHelper.date_time(self.created_at)
    map["printable_job_printable"] = self.printable.name
    map["printable_job_total"] = PrintableDispatch.total_by_printable_job(self)
    map
  end

  def populate(data)
    self.attributes = data["printable_job"]
  end

  private

  def generate_document
    require 'htmldoc'

    connection = ActiveRecord::Base.connection

    query = Array.new
    query<< "CREATE TEMPORARY TABLE temporary_individual_ids"
    query<< "(individual_id INT UNSIGNED)"

    connection.execute(query.join(' '))

    printable_containers = self.printable.containers.map { |j| j.id }

    query = Array.new
    query<< "INSERT INTO temporary_individual_ids (individual_id)"
    query<< "SELECT DISTINCT(individual_id) FROM individual_containers"
    query<< "WHERE container_id IN (#{printable_containers.join(',')})"

    connection.execute(query.join(' '))

    template = self.printable.printable_template.name
    template = ApplicationHelper.generate_permalink(template).gsub(/-/,'_')

    conditions = Array.new
    conditions<< "individuals.id IN ("
    conditions<< "SELECT individual_id"
    conditions<< "FROM temporary_individual_ids)"

    include_map = { :subscriber => [], 
      :personal_activities => [], 
      :individual_connections => [ :connection_type ], 
      :individual_localizations => [ :localization ], 
      :containers => [], 
      :employment => { 
        :organization => [ :business_activities, 
          :organization_connections, 
          :organization_localizations ] } }

    body = PrintableTemplate.send(
      "template_#{template}",
      self.printable.name,
      Individual.all(
        :include => include_map, 
        :conditions => conditions.join(' ')))

    ApplicationHelper.public_data_write(
      body, '.pdf', 'printable_job', self.id)

    query = "DROP TEMPORARY TABLE temporary_individual_ids"
    connection.execute(query)
  end
end
