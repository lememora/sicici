class Event < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :container, :dependent => :delete
  has_many :event_subscribers

  validates_presence_of :name
  validates_uniqueness_of :permalink

  before_create :generate_container
  before_create :generate_hash_id
  before_update :update_container
  before_save :generate_permalink

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

  def image_url
    ApplicationHelper.public_data_url(:event_image, self.hash_id)
  end

  def hashmap
    map = HashWithIndifferentAccess.new
    map["event"] = self.attributes
    map["event"]["created_at"] = FormatHelper.date_time(self.created_at)
    map["event"]["updated_at"] = FormatHelper.date_time(self.updated_at)
    map["event_subscribing"] = self.subscribing ? "Sim" : "Não"
    map["event_url"] = "#{APP_CONFIG["website_base_url"]}#{APP_CONFIG["website_event_path"]}/#{self.permalink}"
    map["event_image_url"] = self.image_url
    map["event_image_img"] = self.image_url ? "<img src=\"#{self.image_url}?#{Time.now.to_i}\" width=\"120\"/>" : nil
    map["members"] = self.event_subscribers.count
    map
  end

  def event_image_base64
    ApplicationHelper.public_data_base64(:event_image, self.hash_id)
  end

  def populate(data)
    self.attributes = data["event"]
    self.subscribing = data["event_subscribing"]=="Sim"
  end

  def subscribe(subscriber)
    return false unless subscriber.instance_of? Subscriber
    subscriber.individual.containers << self.container if self.container and not subscriber.individual.containers.include?(self.container)
    EventSubscriber.create(:event_id => self.id, :subscriber_id => subscriber.id) unless EventSubscriber.first(:conditions => { :event_id => self.id, :subscriber_id => subscriber.id })
  end

  def self.request_confirmation(email, permalink)
    subscriber = Subscriber.find_by_email(email)
    event = self.find_by_permalink(permalink)
    Rails.logger.info("FBCO #{subscriber.inspect}\n#{event.inspect}")
    return false if subscriber.nil? or event.nil?
    Notifier.deliver_subscriber_request_confirmation(subscriber, event) # TODO check deliver
    return true
  end

  def self.request_update(email, permalink)
    subscriber = Subscriber.find_by_email(email)
    event = self.find_by_permalink(permalink)
    return false if subscriber.nil? or event.nil?
    Notifier.deliver_subscriber_request_update(subscriber, event) # TODO check deliver
    return true
  end

  protected

  def self.select_conditions_joins
    []
  end

  def self.select_conditions_columns
    [ "events.name", "events.permalink" ]
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
      return "events.name ASC"
    end
  end

  def self.select_conditions_lambda(select)
    lambda do
      return
    end
  end

  def self.options_for_all(options)
    options[:limit] = 25
    select = SelectHelper::Setup.new('events', options)
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
    select = SelectHelper::Setup.new('events', options)
    select.order.lambda = self.select_order_lambda_quick(select)
    if options[:search]
      self.select_conditions_joins.each { |j| select << j }
      select.conditions.columns = self.select_conditions_columns
    end    
    select.build
  end

  def self.options_for_filter_and_search(options)
    select = SelectHelper::Setup.new('events', options, :extended)
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
    footer = FormatHelper.markup_wrap(result.permalink, search, 'u')
    FormatHelper.quick_result(header, footer)
  end

  private

  def generate_hash_id
    self.hash_id = ApplicationHelper.generate_rand_hash
  end

  def generate_container
    if self.container.nil?
      container_type = ContainerType.find_by_name(ContainerType::EVENT)
      container = Container.new(:name => self.name,
                                :container_type => container_type)
      container.save
      self.container = container
    end
  end

  def update_container
    if self.container
      self.container.update_attributes(:name => self.name)
    end
  end

  def generate_permalink
    if self.permalink.nil? or self.permalink.empty?
      self.permalink = ApplicationHelper.generate_permalink(self.name)
    end
  end
end
