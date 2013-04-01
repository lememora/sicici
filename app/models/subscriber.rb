class Subscriber < ActiveRecord::Base
  attr_protected :individual_id, :hash_id, :email_local, :email_domain, :validated, :unsubscribed, :rejected, :bounces, :enabled, :created_at, :updated_at

  belongs_to :individual
  has_many :campaign_dispatches
  has_many :event_subscribers
  has_many :events, :through => :event_subscribers

  validates_uniqueness_of :email_local, :scope => :email_domain

  before_create :generate_hash_id

  def email=(email)
    self.email_local, self.email_domain = email.split("@", 2)
  end

  def email
    [ self.email_local, self.email_domain ].join("@") unless self.email_local.nil?
  end

  def to_json(options={})
    self.hashmap.to_json(options)
  end

  def hashmap
    map = HashWithIndifferentAccess.new
    map["subscriber"] = self.attributes
    map["subscriber_validated"] = self.validated ? "Sim" : "Não"
    map["subscriber_rejected"] = self.rejected ? "Sim" : "Não"
    map["subscriber_unsubscribed"] = self.unsubscribed ? "Sim" : "Não"
    map["subscriber"]["email"] = self.email
    map["subscriber"]["mailto"] = FormatHelper.mailto(self.email)
    map["campaign_dispatches"] = self.campaign_dispatches.count
    map
  end

  def populate(data, rehash=false)
    self.generate_hash_id if rehash
    self.attributes = data["subscriber"]
  end

  def self.find_by_email(email)
    email_local, email_domain = email.split("@", 2)
    self.first(:conditions => { :email_local => email_local, :email_domain => email_domain })
  end

  def self.request_validation(email)
    subscriber = self.find_by_email(email)
    return false if subscriber.nil?
    Notifier.deliver_subscriber_request_validation(subscriber) # TODO check deliver
    return true
  end

  def self.request_update(email)
    subscriber = self.find_by_email(email)
    return false if subscriber.nil?
    Notifier.deliver_subscriber_request_update(subscriber) # TODO check deliver
    return true
  end

  def self.validate(hash_id)
    subscriber = self.find_by_hash_id(hash_id)
    return false if subscriber.nil?
    subscriber.validated = true
    subscriber.generate_hash_id
    return subscriber.save
  end

  def self.unsubscribe(hash_id)
    subscriber = self.find_by_hash_id(hash_id)
    return false if subscriber.nil?
    subscriber.unsubscribed = true
    subscriber.generate_hash_id
    return subscriber.save
  end

  def generate_hash_id
    self.hash_id = ApplicationHelper.generate_rand_hash
  end
end
