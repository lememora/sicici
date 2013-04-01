class AclHistory < ActiveRecord::Base
  ACTION_CREATE  = 'create'
  ACTION_RESTORE = 'restore'
  ACTION_UPDATE  = 'update'
  ACTION_DELETE  = 'delete'

  belongs_to :acl_user
  belongs_to :acl_role

  validates_presence_of :message

  validates_inclusion_of :action, :in => [ 
    ACTION_CREATE, ACTION_RESTORE, ACTION_UPDATE, ACTION_DELETE 
  ]

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
    return false
  end

  def to_json(options={})
    self.hashmap.to_json(options)
  end

  def hashmap
    map = HashWithIndifferentAccess.new
    map["acl_history"] = self.attributes
    map["acl_history"]["created_at"] = FormatHelper.date_time(self.created_at)
    map["acl_history_action"] = { ACTION_CREATE  => "Criação",
                                  ACTION_RESTORE => "Restauração",
                                  ACTION_UPDATE  => "Atualização",
                                  ACTION_DELETE  => "Exclusão" }[self.action]
    map["acl_role_name"] = self.acl_role.name
    map["acl_user_username"] = self.acl_user.username
    map
  end

  def populate(data)
    return nil
  end

  protected

  def self.select_conditions_joins
    [ :acl_role, :acl_user ]
  end

  def self.select_conditions_columns
    [ "acl_histories.message" ]
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
      return "acl_histories.id DESC"
    end
  end

  def self.select_conditions_lambda(select)
    lambda do
      return
    end
  end

  def self.options_for_all(options)
    options[:limit] = 25
    select = SelectHelper::Setup.new('acl_histories', options)
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
    select = SelectHelper::Setup.new('acl_histories', options)
    select.order.lambda = self.select_order_lambda_quick(select)
    if options[:search]
      self.select_conditions_joins.each { |j| select << j }
      select.conditions.columns = self.select_conditions_columns
    end    
    select.build
  end

  def self.options_for_filter_and_search(options)
    select = SelectHelper::Setup.new('acl_histories', options, :extended)
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
