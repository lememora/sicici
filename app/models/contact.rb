class Contact
  attr_accessor :errors, :organization, :individual, :subscriber, :as_subscriber

  def initialize(data=nil)
    @errors = Array.new
    @individual = nil
    @subscriber = nil
    @organization = nil
    @as_subscriber = false
    populate(data) unless data.nil?
  end

  def to_s
    self.individual.to_s
  end

  def id
    self.individual.id
  end

  def self.find_by_id(id)
    Individual.find_by_id(id)
  end

  def self.ample(options)
    results = Array.new
    Individual.all(self.options_for_all(options)).each do |result|
      contact = self.new
      contact.individual = result
      contact.subscriber = result.subscriber
      if not result.employment.nil?
        contact.organization = result.employment.organization
      end
      results << contact
    end
    results
  end

  def self.quick(options)
    results = Array.new
    Individual.all(self.options_for_quick(options)).each do |result|
      results << [ result.id, self.quick_format(result, options[:search]) ]
    end
    results
  end

  def self.count_(options)
    Individual.count(self.options_for_count(options))
  end

  def save
    @individual.save
    @errors |= @individual.errors.to_a
    @errors.length == 0
  end

  def to_json(options={})
    self.hashmap.to_json(options)
  end

  def update_attributes_(data, rehash_subscriber=false)
    populate(data, rehash_subscriber)
    save
  end

  def self.find_by_subscriber(hash_id)
    contact = self.new
    contact.subscriber = Subscriber.find_by_hash_id(hash_id)
    if contact.subscriber
      contact.individual = contact.subscriber.individual
      if not contact.individual.employment.nil?
        contact.organization = contact.individual.employment.organization
      end
      contact.as_subscriber = true
    end
    contact.subscriber ? contact : nil
  end

  def self.find_by_individual(id)
    contact = self.new
    contact.individual = Individual.find_by_id(id)
    if contact.individual
      contact.subscriber = contact.individual.subscriber
      if not contact.individual.employment.nil?
        contact.organization = contact.individual.employment.organization
      end
    end
    contact.individual ? contact : nil
  end

  def self.find_by_email(email)
    subscriber = Subscriber.find_by_email(email)
    self.find_by_individual(subscriber.individual.id) unless subscriber.nil?
  end

  def self.find_by_name(name)
    individual = Individual.find_by_name(name)
    self.find_by_individual(individual.id) unless individual.nil?
  end

  def self.containers_shift(options)
    container_ids = (options[:selected] || "").split(',')
    container_ids = container_ids.select { |j| FormatHelper.alphanum?(j) }
    container_ids = container_ids.map { |j| Container.find_by_hash_id(j) }
    container_ids = container_ids.select { |j| not j.nil? }
    container_ids = container_ids.map { |j| j.id }

    command = options[:command].to_s
    command = 'insert' unless [ 'insert', 'delete', 'replace' ].include?(command)

    if options[:ids].to_s=='*'
      self.containers_filter_and_search_shift(container_ids, options, command)
    else
      individual_ids = (options[:ids] || "").split(',')
      individual_ids = individual_ids.map { |j| j.to_i }
      individual_ids = individual_ids.select { |j| j > 0 }
      self.containers_individuals_shift(container_ids, individual_ids, command)
    end    
  end

  def self.activities_shift(options)
    activity_ids = (options[:selected] || "").split(',')
    activity_ids = activity_ids.select { |j| j.to_s.match(/^[[:digit:]]+$/) }
    activity_ids = activity_ids.map { |j| PersonalActivity.find_by_id(j) }
    activity_ids = activity_ids.select { |j| not j.nil? }
    activity_ids = activity_ids.map { |j| j.id }

    command = options[:command].to_s
    command = 'insert' unless [ 'insert', 'delete', 'replace' ].include?(command)

    if options[:ids].to_s=='*'
      self.activities_filter_and_search_shift(activity_ids, options, command)
    else
      individual_ids = (options[:ids] || "").split(',')
      individual_ids = individual_ids.map { |j| j.to_i }
      individual_ids = individual_ids.select { |j| j > 0 }
      self.activities_individuals_shift(activity_ids, individual_ids, command)
    end    
  end

  def hashmap
    individual = @individual ? @individual : Individual.new
    individual.readonly!
    subscriber = @subscriber ? @subscriber : Subscriber.new
    subscriber.readonly!
    organization = @organization ? @organization : Organization.new
    organization.readonly!

    map = HashWithIndifferentAccess.new

    subscriber_map = subscriber.hashmap
    if @as_subscriber
      map["subscriber"] = HashWithIndifferentAccess.new
      %w{hash_id email mailto validated}.each do |j|
        map["subscriber"][j] = subscriber_map["subscriber"][j]
      end
    else
      map = map.merge(subscriber_map)
    end

    map = map.merge(individual.hashmap)
    if @as_subscriber
      map["individual"].delete("id")
    end

    map = map.merge(organization.hashmap)
    if @as_subscriber
      %w{created_at updated_at}.each { |j| map["organization"].delete(j) }
    end

    map
  end

  def populate(data, rehash_subscriber=false)
    @individual = Individual.new if @individual.nil?
    @individual.populate(data)

    # use existing organization
    if (data["organization"] || {})["id"].to_i > 0
      @organization = Organization.find_by_id(data["organization"]["id"])
    else
      @organization = nil
    end

    # create a new organization
    if @organization.nil? and not (data["organization"] || {})["name"].to_s.empty?
      @organization = Organization.new
      @organization.populate(data)
    end

    # subscriber
    if (data["subscriber"] || {})["email"].to_s.empty?
      @subscriber.destroy unless @subscriber.nil?
    else
      if @subscriber.nil?
        @individual.subscriber = Subscriber.new(:email => data["subscriber"]["email"])
        @subscriber = @individual.subscriber
      end
      @subscriber.populate(data, rehash_subscriber)
      @subscriber.save unless @subscriber.new_record?
    end

    # employment
    if @organization
      if @individual.employment.nil?
        @individual.employment = Employment.new(:organization => @organization, :job_position => data["job_position"].to_s)
      else
        @individual.employment.organization = @organization
      end
      #if data["job_position"].to_s.match(/^[0-9]+$/)
      #  @individual.employment.job_position = JobPosition.find_by_id(data["job_position"])
      #else
      #  @individual.employment.job_position = JobPosition.find_by_name(data["job_position"].to_s)
      #end
      @individual.employment.save unless @individual.new_record?
    else
      @individual.employment.destroy unless @individual.employment.nil?
    end
  end

  def self.select_conditions_joins
    [ "subscribers", "LEFT JOIN employments ON (employments.individual_id = individuals.id)", "LEFT JOIN organizations ON (organizations.id = employments.organization_id)", "LEFT JOIN individual_connections ON (individual_connections.individual_id = individuals.id)" ]
  end

  def self.select_conditions_columns
    [ "CONCAT(individuals.name_first,' ',individuals.name_last)", "CONCAT(subscribers.email_local,'@',subscribers.email_domain)", "organizations.name", "individual_connections.value" ]
  end

  def self.select_order_lambda_all(select)
    lambda do
      table_and_column = "#{select.order.table}.#{select.order.column}"
      direction = select.order.direction
      if table_and_column=='individuals.name'
        return "individuals.name_first #{direction}, individuals.name_last #{direction}"
      elsif table_and_column=='subscribers.email' or 
            table_and_column=='subscribers.mailto'
        select << 'subscribers'
        return "subscribers.email_local #{direction}, subscribers.email_domain #{direction}"
      else
        return "#{table_and_column} #{direction}"
      end
    end
  end

  def self.select_order_lambda_quick(select)
    lambda do
      return "individuals.name_first ASC, individuals.name_last ASC"
    end
  end

  def self.select_conditions_lambda(select)
    lambda do
      filter = select.conditions.filter
      operator = select.conditions.operator

      if filter.index("containers:")==0
        filter = filter.split(':').last
        containers = filter.split(',').map { |j| FormatHelper.alphanum!(j) } 
        counter=101

        if operator=="OR"
          pieces = Array.new
          containers.each do |hash_id|
            pieces << "(k.individual_id = individuals.id AND k.container_id = (SELECT id FROM containers WHERE hash_id = '#{hash_id}'))"
          end
          select << "INNER JOIN individuals AS j ON (individuals.id = j.id AND j.id IN (SELECT DISTINCT(id) FROM individuals INNER JOIN individual_containers AS k ON (#{pieces.join(" OR ")})))"

        elsif operator=="AND"
          containers.each do |hash_id|
            select << "INNER JOIN individual_containers AS j#{counter} ON (j#{counter}.individual_id = individuals.id AND j#{counter}.container_id = (SELECT id FROM containers WHERE hash_id = '#{hash_id}'))"
            counter+=1
          end
        end
      end

      if filter.index("activities:")==0
        filter = filter.split(':').last
        activities = filter.split(',').map { |j| FormatHelper.alphanum!(j) } 
        counter=101

        if operator=="OR"
          pieces = Array.new
          activities.each do |id|
            pieces << "(k.individual_id = individuals.id AND k.personal_activity_id = #{id})"
          end
          select << "INNER JOIN individuals AS j ON (individuals.id = j.id AND j.id IN (SELECT DISTINCT(individuals.id) FROM individuals INNER JOIN individual_activities AS k ON (#{pieces.join(" OR ")})))"

        elsif operator=="AND"
          activities.each do |id|
            select << "INNER JOIN individual_activities AS j#{counter} ON (j#{counter}.individual_id = individuals.id AND j#{counter}.personal_activity_id = #{id})"
            counter+=1
          end
        end
      end

      return
    end
  end

  def self.options_for_all(options)
    options[:limit] = 25
    select = SelectHelper::Setup.new('individuals', options)
    select.include = { :subscriber => [], 
      :personal_activities => [], 
      :individual_connections => [ :connection_type ], 
      :individual_localizations => [ :localization ], 
      :containers => [], 
      :employment => { 
        :organization => [ :business_activities, 
          :organization_connections, 
          :organization_localizations ] } }
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
    select = SelectHelper::Setup.new('individuals', options)
    select.include = { :subscriber => [], 
      :individual_connections => [], 
      :containers => [], 
      :employment => { :organization => [] } 
    }
    select.order.lambda = self.select_order_lambda_quick(select)
    if options[:search]
      self.select_conditions_joins.each { |j| select << j }
      select.conditions.columns = self.select_conditions_columns
    end    
    select.build
  end

  def self.options_for_filter_and_search(options)
    select = SelectHelper::Setup.new('individuals', options, :extended)
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
    if result.individual_connections.length > 0
      ps = result.prefered_phone.to_s.downcase.gsub(/[[:space:]][^[:space:]]+$/, '')
      others = result.individual_connections(:include => :connection_type)
      prefered = others.select { |j| j.value.downcase.index(ps) }.first
      selected = others.select { |j| j.value.downcase.index(search.downcase) }.first
      selected = prefered if selected.nil?
      selected = others.first if selected.nil?
      if selected
        ct = selected.connection_type.name
        px = ""
        px = "RES " if ct==ConnectionType::PHONE_HOME
        px = "COM " if ct==ConnectionType::PHONE_BUSINESS
        px = "CEL " if ct==ConnectionType::PHONE_MOBILE
        px = "FAX " if ct==ConnectionType::PHONE_FAX
        px = "FAX " if ct==ConnectionType::FAX_ONLY
        footer<< FormatHelper.markup_wrap("<span style=\"font-size:12px;\">#{px}#{selected.value}</span>", search, 'u')
      end
    end
    if result.employment and
       result.employment.organization and not
       result.employment.organization.name.to_s.empty?
       footer<< FormatHelper.markup_wrap("<span style=\"font-size:12px;\">#{result.employment.organization.name}</span>", search, 'u')
    end
    if result.subscriber and not
       result.subscriber.email.empty?
       footer<< FormatHelper.markup_wrap("<span style=\"font-size:12px;\">#{result.subscriber.email}</span>", search, 'u')
    end
    FormatHelper.quick_result(header, footer.join("&nbsp;"))
  end

  # ----------------------------------------------------------------------------

  def self.containers_filter_and_search_shift(container_ids, options, command)
    connection = ActiveRecord::Base.connection
    criteria = self.options_for_filter_and_search(options)
    containers = container_ids.join(',')

    add = [ 'insert', 'replace' ].include?(command)
    remove = [ 'delete', 'replace' ].include?(command)

    # create temporary table to store individual ids
    query = Array.new
    query<< "CREATE TEMPORARY TABLE temporary_individual_ids"
    query<< "(individual_id INT UNSIGNED)"
    connection.execute(query.join(' '))

    query = Array.new
    query<< "INSERT INTO temporary_individual_ids"
    query<< "SELECT individuals.id FROM individuals"
    query<< "#{criteria[:joins]}" if criteria[:joins]
    query<< "WHERE #{criteria[:conditions]}" if criteria[:conditions]
    connection.execute(query.join(' '))

    if add and containers.length > 0
      query = Array.new
      query<< "REPLACE INTO individual_containers (individual_id, container_id)"
      query<< "SELECT individuals.id, containers.id FROM individuals"
      query<< "LEFT JOIN containers ON (containers.id IN (#{containers}))"
      query<< "WHERE individuals.id IN"
      query<< "(SELECT individual_id FROM temporary_individual_ids)"
      connection.update(query.join(' '))
    end

    if remove
      query = Array.new
      query<< "DELETE FROM individual_containers"
      query<< "WHERE individual_id IN"
      query<< "(SELECT individual_id FROM temporary_individual_ids)"
      query<< "AND container_id #{ "NOT" if command=='replace' }"
      query<< "IN (#{containers})" if containers.length > 0
      connection.update(query.join(' '))
    end

    # drop temporary table
    query = "DROP TEMPORARY TABLE temporary_individual_ids"
    connection.execute(query)
  end

  def self.containers_individuals_shift(container_ids, individual_ids, command)
    # nothing to do
    return nil if individual_ids.length==0

    connection = ActiveRecord::Base.connection
    containers = container_ids.join(',')
    individuals = individual_ids.join(',')

    add = [ 'insert', 'replace' ].include?(command)
    remove = [ 'delete', 'replace' ].include?(command)

    if add and containers.length > 0
      query = Array.new
      query<< "REPLACE INTO individual_containers (individual_id, container_id)"
      query<< "SELECT individuals.id, containers.id FROM individuals"
      query<< "LEFT JOIN containers ON (containers.id IN (#{containers}))"
      query<< "WHERE individuals.id IN (#{individuals})"
      connection.execute(query.join(' '))
    end

    if remove
      query = Array.new
      query<< "DELETE FROM individual_containers"
      query<< "WHERE individual_id IN (#{individuals})"
      query<< "AND container_id #{ "NOT" if command=='replace' }"
      query<< "IN (#{containers})" if containers.length > 0
      connection.update(query.join(' '))
    end
  end

  # ----------------------------------------------------------------------------

  def self.activities_filter_and_search_shift(activity_ids, options, command)
    connection = ActiveRecord::Base.connection
    criteria = self.options_for_filter_and_search(options)
    activities = activity_ids.join(',')

    add = [ 'insert', 'replace' ].include?(command)
    remove = [ 'delete', 'replace' ].include?(command)

    # create temporary table to store individual ids
    query = Array.new
    query<< "CREATE TEMPORARY TABLE temporary_individual_ids"
    query<< "(individual_id INT UNSIGNED)"
    connection.execute(query.join(' '))

    query = Array.new
    query<< "INSERT INTO temporary_individual_ids"
    query<< "SELECT individuals.id FROM individuals"
    query<< "#{criteria[:joins]}" if criteria[:joins]
    query<< "WHERE #{criteria[:conditions]}" if criteria[:conditions]
    connection.execute(query.join(' '))

    if add and activities.length > 0
      query = Array.new
      query<< "REPLACE INTO individual_activities (individual_id, personal_activity_id)"
      query<< "SELECT individuals.id, personal_activities.id FROM individuals"
      query<< "LEFT JOIN personal_activities ON (personal_activities.id IN (#{activities}))"
      query<< "WHERE individuals.id IN"
      query<< "(SELECT individual_id FROM temporary_individual_ids)"
      connection.update(query.join(' '))
    end

    if remove
      query = Array.new
      query<< "DELETE FROM individual_activities"
      query<< "WHERE individual_id IN"
      query<< "(SELECT individual_id FROM temporary_individual_ids)"
      query<< "AND personal_activity_id #{ "NOT" if command=='replace' }"
      query<< "IN (#{activities})" if activities.length > 0
      connection.update(query.join(' '))
    end

    # drop temporary table
    query = "DROP TEMPORARY TABLE temporary_individual_ids"
    connection.execute(query)
  end

  def self.activities_individuals_shift(activity_ids, individual_ids, command)
    # nothing to do
    return nil if individual_ids.length==0

    connection = ActiveRecord::Base.connection
    activities = activity_ids.join(',')
    individuals = individual_ids.join(',')

    add = [ 'insert', 'replace' ].include?(command)
    remove = [ 'delete', 'replace' ].include?(command)

    if add and activities.length > 0
      query = Array.new
      query<< "REPLACE INTO individual_activities (individual_id, personal_activity_id)"
      query<< "SELECT individuals.id, personal_activities.id FROM individuals"
      query<< "LEFT JOIN personal_activities ON (personal_activities.id IN (#{activities}))"
      query<< "WHERE individuals.id IN (#{individuals})"
      connection.execute(query.join(' '))
    end

    if remove
      query = Array.new
      query<< "DELETE FROM individual_activities"
      query<< "WHERE individual_id IN (#{individuals})"
      query<< "AND personal_activity_id #{ "NOT" if command=='replace' }"
      query<< "IN (#{activities})" if activities.length > 0
      connection.update(query.join(' '))
    end
  end
end
