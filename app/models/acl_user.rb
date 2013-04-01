class AclUser < ActiveRecord::Base
  belongs_to :individual
  has_many :acl_histories
  has_many :acl_permissions

  validates_presence_of :username
  validates_presence_of :hash_password, :message => "Informe a Senha"
  validates_uniqueness_of :username

  def to_s
    "##{self.id} #{self.username}"
  end

  def password=(password)
    require 'digest/sha1'
    self.hash_password = Digest::SHA1.hexdigest(password) if password.to_s.length > 0
  end

  def sections_allowed(writable_only=false)
    sections = Array.new
    roles = self.acl_permissions.all(
      :conditions => writable_only ? { :writable => true } : {}, 
      :include => :acl_role).map { |j| j.acl_role.name }
    AclRole::SECTIONS.each do |j,k|
      sections << k if roles.include?(j)
    end
    sections
  end

  def self.authenticate(username, password, digest=true)
    user = find_by_username(username, 
      :conditions => { :enabled => true }, :include => :acl_permissions)
    return false, nil if user.nil?
    hash_password = digest ? Digest::SHA1.hexdigest(password) : password
    match_password = (user.hash_password == hash_password)
    role = AclRole.find_by_name(AclRole::AUTHENTICATION)
    authenticable = user.acl_permissions.map { |j| j.acl_role }.include?(role)
    return (match_password and authenticable), user
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
    map["acl_user"] = self.attributes
    map["acl_user_enabled"] = self.enabled ? "Sim" : "Não"
    permissions = Array.new
    self.acl_permissions.each do |j|
      r = j.acl_role.name
      permissions<< (j.writable ? "<b>#{r}</b>" : "<span style=\"color:gray;\">#{r}</span>")
    end
    map["permissions"] = permissions.join("<br/>")
    map["roles"] = Array.new
    self.acl_permissions.each do |j|
      map["roles"]<< "#{j.acl_role_id}-r"
      if j.writable == true
        map["roles"]<< "#{j.acl_role_id}-a"
        map["roles"]<< "#{j.acl_role_id}-w"
      end
    end
    map
  end

  def populate(data)
    self.attributes = data["acl_user"]
    self.enabled = (data["acl_user_enabled"])
    permissions = Hash.new
    (data["roles"] || {}).keys.each do |j|
      k = j.split(/-/)
      if k.length == 2
        permissions[k[0]] = false if permissions[k[0]].nil?
        permissions[k[0]] = %w{a w}.include?(k[1]) if permissions[k[0]] == false
      end
    end
    self.acl_permissions.each { |j| j.destroy }
    permissions.each do |j,k|
      role = AclRole.find_by_id(j)
      AclPermission.create(:acl_user => self, :acl_role => role, :writable => k)
    end
  end

  protected

  def self.select_conditions_joins
    [ :individual ]
  end

  def self.select_conditions_columns
    [ "individuals.name" ]
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
      return "acl_users.username ASC"
    end
  end

  def self.select_conditions_lambda(select)
    lambda do
      return
    end
  end

  def self.options_for_all(options)
    options[:limit] = 25
    select = SelectHelper::Setup.new('acl_users', options)
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
    select = SelectHelper::Setup.new('acl_users', options)
    select.order.lambda = self.select_order_lambda_quick(select)
    if options[:search]
      self.select_conditions_joins.each { |j| select << j }
      select.conditions.columns = self.select_conditions_columns
    end    
    select.build
  end

  def self.options_for_filter_and_search(options)
    select = SelectHelper::Setup.new('acl_users', options, :extended)
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
