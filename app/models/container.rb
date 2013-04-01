class Container < ActiveRecord::Base
  belongs_to :container_type
  has_one :event
  has_and_belongs_to_many :campaigns, :join_table => "campaign_containers"
  has_and_belongs_to_many :individuals, :join_table => "individual_containers"
  has_and_belongs_to_many :printables, :join_table => "printable_containers"

  validates_uniqueness_of :name, :message => "Nome já existe"
  validates_uniqueness_of :hash_id

  before_create :generate_hash_id
  before_create :set_default_container_type

  def to_s
    "##{self.id} #{self.name}"
  end

  def self.ample(options)
    self.all(self.options_for_all(options))
  end

  def self.quick(options)
    results = Array.new
    self.all(self.options_for_quick(options)).each do |result|
      results << [ result.id, self.quick_format(result, options[:search]) ]
    end
    results
  end

  def self.count_(options)
    self.count(self.options_for_count(options))
  end

  def update_attributes_(data)
    populate(data)
    save
  end

  def to_json(options={})
    self.hashmap.to_json(options)
  end

  def hashmap
    map = HashWithIndifferentAccess.new
    map["container"] = self.attributes
    map["container_type"] = ContainerType::NAMES[self.container_type.name]
    map["container_public"] = self.container_type.public ? "Sim" : "Não"
    map["container_removable"] = self.container_type.removable ? "Sim" : "Não"
    map["members"] = self.individuals.count
    map
  end

  def populate(data)
    self.attributes = data["container"]

    if self.container_type.nil?
      if data["container_public"] == "Sim"
        self.container_type = ContainerType.find_by_name(ContainerType::PUBLIC)
      end
      if data["container_public"] == "Não" or
         data["container_public"].to_s.empty?
        self.container_type = ContainerType.find_by_name(ContainerType::PRIVATE)
      end
    end
  end

  protected

  def self.select_conditions_joins
    [ :container_type ]
  end

  def self.select_conditions_columns
    [ "containers.name" ]
  end

  def self.select_order_lambda_all(select)
    lambda do
      table_and_column = "#{select.order.table}.#{select.order.column}"
      direction = select.order.direction
      return "#{table_and_column} #{direction}"
    end
  end

  def self.select_order_lambda_quick(select)
    lambda do
      return "containers.name ASC"
    end
  end

  def self.select_conditions_lambda(select)
    lambda do
      return
    end
  end

  def self.options_for_all(options)
    options[:limit] = 25
    select = SelectHelper::Setup.new('containers', options)
    select.order.lambda = self.select_order_lambda_all(select)
    if options[:filter]
      select.conditions.lambda = self.select_conditions_lambda(select)
    end
    if options[:search]
      self.select_conditions_joins.each { |j| select << j }
      select.conditions.columns = self.select_conditions_columns
    end    
    select.build
  end

  def self.options_for_quick(options)
    options[:start] = 0
    options[:limit] = 50
    select = SelectHelper::Setup.new('containers', options)
    select.order.lambda = self.select_order_lambda_quick(select)
    if options[:search]
      self.select_conditions_joins.each { |j| select << j }
      select.conditions.columns = self.select_conditions_columns
    end    
    select.build
  end

  def self.options_for_filter_and_search(options)
    select = SelectHelper::Setup.new('containers', options, :extended)
    if options[:filter]
      select.conditions.lambda = self.select_conditions_lambda(select)
    end
    if options[:search]
      self.select_conditions_joins.each { |j| select << j }
      select.conditions.columns = self.select_conditions_columns
    end    
    select.build
  end

  def self.options_for_count(options)
    self.options_for_filter_and_search(options)
  end

  def self.quick_format(result, search)
    output = String.new
    header = FormatHelper.markup_wrap(result.name, search, 'u')
    footer = nil
    FormatHelper.quick_result(header, footer)
  end

  private

  def generate_hash_id
    self.hash_id = ApplicationHelper.generate_rand_hash
  end

  def set_default_container_type
    if self.container_type.nil?
      self.container_type = ContainerType.find_by_name(ContainerType::PRIVATE)
    end
  end
end
