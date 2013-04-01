class PersonalActivity < ActiveRecord::Base
  has_and_belongs_to_many :individuals, :join_table => "individual_activities"

  validates_presence_of :name
  validates_uniqueness_of :name

  ##DEPRECATED
  ##def self.seach_for(query)
  ##  #query = "" if query.nil?
  ##  #partial = query.empty? self.all(:order => :name)
  ##  #self.all(:order => :name).select { |a| a.downcase.index(query.downcase) != nil }.collect { |j| [ j.id, j.name ] }
  ##end

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
    map["personal_activity"] = self.attributes
    map["members"] = self.individuals.count
    map
  end

  def populate(data)
    self.attributes = data["personal_activity"]
  end

  protected

  def self.select_conditions_joins
    [ ]
  end

  def self.select_conditions_columns
    [ "personal_activities.name" ]
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
      return "personal_activities.name ASC"
    end
  end

  def self.select_conditions_lambda(select)
    lambda do
      return
    end
  end

  def self.options_for_all(options)
    options[:limit] = 25
    select = SelectHelper::Setup.new('personal_activities', options)
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
    select = SelectHelper::Setup.new('personal_activities', options)
    select.order.lambda = self.select_order_lambda_quick(select)
    if options[:search]
      self.select_conditions_joins.each { |j| select << j }
      select.conditions.columns = self.select_conditions_columns
    end    
    select.build
  end

  def self.options_for_filter_and_search(options)
    select = SelectHelper::Setup.new('personal_activities', options, :extended)
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
end
