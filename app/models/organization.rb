class Organization < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  has_many :employments
  has_many :organization_connections, :order => :position
  has_many :organization_localizations
  has_and_belongs_to_many :business_activities, :join_table => "organization_activities"

  validates_presence_of :name

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

  def self.activities_shift(options)
    activity_ids = (options[:selected] || "").split(',')
    activity_ids = activity_ids.select { |j| j.to_s.match(/^[[:digit:]]+$/) }
    activity_ids = activity_ids.map { |j| BusinessActivity.find_by_id(j) }
    activity_ids = activity_ids.select { |j| not j.nil? }
    activity_ids = activity_ids.map { |j| j.id }

    command = options[:command].to_s
    command = 'insert' unless [ 'insert', 'delete', 'replace' ].include?(command)

    if options[:ids].to_s=='*'
      self.activities_filter_and_search_shift(activity_ids, options, command)
    else
      organization_ids = (options[:ids] || "").split(',')
      organization_ids = organization_ids.map { |j| j.to_i }
      organization_ids = organization_ids.select { |j| j > 0 }
      self.activities_organizations_shift(activity_ids, organization_ids, command)
    end    
  end

  def hashmap
    map = HashWithIndifferentAccess.new
    map["organization"] = self.attributes
    map["organization"]["created_at"] = FormatHelper.date_time(self.created_at)
    map["organization"]["updated_at"] = FormatHelper.date_time(self.updated_at)
    business_activity_id_array = self.business_activities.map { |v| v.id }
    map["business_activity"] = business_activity_id_array.first
    map["business_activities"] = business_activity_id_array
    business_activity_name_array = self.business_activities.map { |v| v.name }
    map["business_activity_name"] = business_activity_name_array.first
    map["business_activity_name_array"] = business_activity_name_array
    map["business_activity_names"] = business_activity_name_array.join(",")
    map["organization_connections"] = Hash.new
    ConnectionType::PHONES.each do |phone|
      map["organization_connections"][phone] = nil
    end
    self.organization_connections.each do |v|
      map["organization_connections"][v.connection_type.name] = v.value
    end
    map["organization_localizations"] = Hash.new
    OrganizationLocalization::CONTEXT_ARRAY.each do |j|
      map["organization_localizations"][j] = Hash.new
    end
    map["organization_localizations"] = Hash.new
    self.organization_localizations.each do |v|
      map["organization_localizations"][v.context] = v.localization.hashmap
    end
    map
  end

 def populate(data)
    self.attributes = data["organization"]

    business_activity_names = data["business_activity_names"] || []
    self.business_activities.clear if business_activity_names.length > 0
    business_activity_names.each do |j|
      activity = BusinessActivity.find_by_name(j)
      self.business_activities << activity if activity
    end

    business_activity_ids = (data["business_activities"] || {}).values
    self.business_activity_ids = business_activity_ids if business_activity_ids.length > 0

    if data["business_activity"].to_i > 0
      self.business_activity_ids = [ data["business_activity"] ]
    end

    (data["organization_connections"] || {}).each do |k,v|
      if (t = ConnectionType.find_by_name(k))
        c = self.organization_connections.find_by_connection_type_id(t.id)
        c.destroy unless c.nil?
        if not v.to_s.empty?
          self.organization_connections.build(
            :connection_type => t, 
            :value => v)
        end
      end
    end

    (data["organization_localizations"] || {}).each do |k,v|
      c = k.to_s
      if (d = self.organization_localizations.find_by_context(c))
        a = d.localization
        d.destroy
        a.destroy unless a.nil?
      end
      a = Localization.new
      a.populate(v)
      if a.valid? and not c.empty?
        self.organization_localizations.build(
          :localization => a, 
          :context => c)
      end
    end
  end

  protected

  def self.select_conditions_joins
    [ "LEFT JOIN organization_connections ON (organization_connections.organization_id = organizations.id)" ]
  end

  def self.select_conditions_columns
    [ "organizations.name", "organization_connections.value" ]
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
      return "organizations.name ASC"
    end
  end

  def self.select_conditions_lambda(select)
    lambda do
      filter = select.conditions.filter
      operator = select.conditions.operator

      if filter.index("activities:")==0
        filter = filter.split(':').last
        activities = filter.split(',').map { |j| FormatHelper.alphanum!(j) } 
        counter=101

        if operator=="OR"
          pieces = Array.new
          activities.each do |id|
            pieces << "(k.organization_id = organizations.id AND k.business_activity_id = #{id})"
          end
          select << "INNER JOIN organizations AS j ON (organizations.id = j.id AND j.id IN (SELECT DISTINCT(organizations.id) FROM organizations INNER JOIN organization_activities AS k ON (#{pieces.join(" OR ")})))"

        elsif operator=="AND"
          activities.each do |id|
            select << "INNER JOIN organization_activities AS j#{counter} ON (j#{counter}.organization_id = organizations.id AND j#{counter}.activity_id = #{id})"
            counter+=1
          end
        end
      end

      return
    end
  end

  def self.options_for_all(options)
    options[:limit] = 25
    select = SelectHelper::Setup.new('organizations', options)
    select.include = { 
      :business_activities => [], 
      :organization_connections => [ :connection_type ], 
      :organization_localizations => [ :localization ] 
    }
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
    select = SelectHelper::Setup.new('organizations', options)
    select.include = { 
      :business_activities => [], 
      :organization_connections => []
    }
    select.order.lambda = self.select_order_lambda_quick(select)
    if options[:search]
      self.select_conditions_joins.each { |j| select << j }
      select.conditions.columns = self.select_conditions_columns
    end    
    select.build
  end

  def self.options_for_filter_and_search(options)
    select = SelectHelper::Setup.new('organizations', options, :extended)
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
    footer = Array.new
    if result.organization_connections.length > 0
      others = result.organization_connections(:include => :connection_type)
      selected = others.select { |j| j.value.downcase.index(search.downcase) }.first
      selected = others.first if selected.nil?
      if selected
        ct = selected.connection_type.name
        px = ""
        px = "COM " if ct==ConnectionType::PHONE_BUSINESS
        px = "CEL " if ct==ConnectionType::PHONE_MOBILE
        px = "FAX " if ct==ConnectionType::PHONE_FAX
        px = "FAX " if ct==ConnectionType::FAX_ONLY
        footer<< FormatHelper.markup_wrap("<span style=\"font-size:12px;\">#{px}#{selected.value}</span>", search, 'u')
      end
    end
    FormatHelper.quick_result(header, footer.join("&nbsp;"))
  end

  # ----------------------------------------------------------------------------

  def self.activities_filter_and_search_shift(activity_ids, options, command)
    connection = ActiveRecord::Base.connection
    criteria = self.options_for_filter_and_search(options)
    activities = activity_ids.join(',')

    add = [ 'insert', 'replace' ].include?(command)
    remove = [ 'delete', 'replace' ].include?(command)

    # create temporary table to store organization ids
    query = Array.new
    query<< "CREATE TEMPORARY TABLE temporary_organization_ids"
    query<< "(organization_id INT UNSIGNED)"
    connection.execute(query.join(' '))

    query = Array.new
    query<< "INSERT INTO temporary_organization_ids"
    query<< "SELECT organizations.id FROM organizations"
    query<< "#{criteria[:joins]}" if criteria[:joins]
    query<< "WHERE #{criteria[:conditions]}" if criteria[:conditions]
    connection.execute(query.join(' '))

    if add and activities.length > 0
      query = Array.new
      query<< "REPLACE INTO organization_activities (organization_id, business_activity_id)"
      query<< "SELECT organizations.id, business_activities.id FROM organizations"
      query<< "LEFT JOIN business_activities ON (business_activities.id IN (#{activities}))"
      query<< "WHERE organizations.id IN"
      query<< "(SELECT organization_id FROM temporary_organization_ids)"
      connection.update(query.join(' '))
    end

    if remove
      query = Array.new
      query<< "DELETE FROM organization_activities"
      query<< "WHERE organization_id IN"
      query<< "(SELECT organization_id FROM temporary_organization_ids)"
      query<< "AND business_activity_id #{ "NOT" if command=='replace' }"
      query<< "IN (#{activities})" if activities.length > 0
      connection.update(query.join(' '))
    end

    # drop temporary table
    query = "DROP TEMPORARY TABLE temporary_organization_ids"
    connection.execute(query)
  end

  def self.activities_organizations_shift(activity_ids, organization_ids, command)
    # nothing to do
    return nil if organization_ids.length==0

    connection = ActiveRecord::Base.connection
    activities = activity_ids.join(',')
    organizations = organization_ids.join(',')

    add = [ 'insert', 'replace' ].include?(command)
    remove = [ 'delete', 'replace' ].include?(command)

    if add and activities.length > 0
      query = Array.new
      query<< "REPLACE INTO organization_activities (organization_id, business_activity_id)"
      query<< "SELECT organizations.id, business_activities.id FROM organizations"
      query<< "LEFT JOIN business_activities ON (business_activities.id IN (#{activities}))"
      query<< "WHERE organizations.id IN (#{organizations})"
      connection.execute(query.join(' '))
    end

    if remove
      query = Array.new
      query<< "DELETE FROM organization_activities"
      query<< "WHERE organization_id IN (#{organizations})"
      query<< "AND business_activity_id #{ "NOT" if command=='replace' }"
      query<< "IN (#{activities})" if activities.length > 0
      connection.update(query.join(' '))
    end
  end
end
