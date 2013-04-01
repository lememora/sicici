class Localization < ActiveRecord::Base
  CONTEXT_HOME = 'home'
  CONTEXT_BUSINESS = 'business'
  CONTEXT_OFFICE = 'office'

  has_one :individual_localization
  has_one :organization_localization

  validates_presence_of :city
  validates_presence_of :address

  validates_inclusion_of :country, :in => Country.keys

  def to_s
    output = Array.new
    output<< Country.find_by_id(self.country) unless self.country.to_s.empty?
    output<< self.state unless self.state.to_s.empty?
    output<< self.city unless self.city.to_s.empty?
    output<< self.district unless self.district.to_s.empty?
    output<< self.code unless self.code .to_s.empty?
    output<< self.address unless self.address.to_s.empty?
    output.join(' - ')
  end

  def hashmap
    map = HashWithIndifferentAccess.new
    map = self.attributes
    map["country_name"] = self.country ? Country.find_by_id(self.country) : nil
    map
  end

  def populate(data)
    self.attributes = data
    country_id = nil
    country_id = data["country"] if Country.keys.include?(data["country"])
    country_id = Country.find_by_name(data["country"]) if country_id.nil?
    self.country = country_id unless country_id.nil?
  end
end
