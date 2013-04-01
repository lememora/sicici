ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = false

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def contact_new_example_data
    data = Hash.new
    data["subscriber"] = Hash.new
    data["subscriber"]["email"] = "jackson+#{(rand()*4096+1024).round}@neverland.com"
    data["individual"] = Hash.new
    data["individual"]["name_first"] = "Michael"
    data["individual"]["name_last"] = "Jackson"
    data["personal_activities"] = Array.new
    data["personal_activities"] << PersonalActivity.find_by_name("Músico").id
    data["personal_activities"] << PersonalActivity.find_by_name("Terapeuta").id
    data["individual_connections"] = Hash.new
    data["individual_connections"][ConnectionType::PHONE_HOME] = "120 300 5678"
    data["individual_connections"][ConnectionType::MSN] = "michael@msn.com"
    data["individual_localizations"] = Hash.new
    data["individual_localizations"]["home"] = Hash.new
    data["individual_localizations"]["home"]["country"] = "US"
    data["individual_localizations"]["home"]["state"] = "California"
    data["individual_localizations"]["home"]["city"] = "Santa Ynez"
    data["individual_localizations"]["home"]["district"] = "Neverland Ranch"
    data["individual_localizations"]["home"]["code"] = "93460"
    data["individual_localizations"]["home"]["address"] = "Figueroa Mountain Rd"
    data["individual_localizations"]["business"] = Hash.new
    data["individual_localizations"]["business"]["country"] = "US"
    data["individual_localizations"]["business"]["state"] = "California"
    data["individual_localizations"]["business"]["city"] = "Santa Ynez"
    data["individual_localizations"]["business"]["district"] = "Neverland Ranch"
    data["individual_localizations"]["business"]["code"] = "93460"
    data["individual_localizations"]["business"]["address"] = "Figueroa Mountain Rd"
    data["containers"] = Array.new
    data["containers"] << Container.find_by_name("Notícias").hash_id
    data["containers"] << Container.find_by_name("Programação").hash_id
    data["organization"] = Hash.new
    organization = Organization.find_by_name("Neverland")
    data["organization"]["id"] = organization.id unless organization.nil?
    data["organization"]["name"] = "Neverland"
    data["business_activities"] = Array.new
    data["business_activities"] << BusinessActivity.find_by_name("Comércio").id
    data["business_activities"] << BusinessActivity.find_by_name("Indústria").id
    data["organization_connections"] = Hash.new
    data["organization_connections"][ConnectionType::PHONE_BUSINESS] = "140 250 3322"
    data["organization_connections"][ConnectionType::EMAIL] = "contact@neverland.com"
    data["organization_localizations"] = Hash.new
    data["organization_localizations"]["office"] = Hash.new
    data["organization_localizations"]["office"]["country"] = "US"
    data["organization_localizations"]["office"]["state"] = "California"
    data["organization_localizations"]["office"]["city"] = "Santa Ynez"
    data["organization_localizations"]["office"]["district"] = "Neverland Ranch"
    data["organization_localizations"]["office"]["code"] = "93460"
    data["organization_localizations"]["office"]["address"] = "Figueroa Mountain Rd"
    data["job_position"] = JobPosition.find_by_name("Presidente").id
    data
  end

  def contact_update_example_data
    individual = Individual.last
    data = Hash.new
    data["subscriber"] = Hash.new
    data["subscriber"]["email"] = "jagger+#{(rand()*4096+1024).round}@stones.com"
    data["subscriber"]["hash_id"] = individual.subscriber.hash_id
    data["individual"] = Hash.new
    data["individual"]["id"] = individual.id
    data["individual"]["name_first"] = "Mick"
    data["individual"]["name_last"] = "Jagger"
    data["personal_activities"] = Array.new
    data["personal_activities"] << PersonalActivity.find_by_name("Músico").id
    data["individual_connections"] = Hash.new
    data["individual_connections"][ConnectionType::PHONE_HOME] = "152 200 4321"
    data["individual_connections"][ConnectionType::MSN] = ""
    data["individual_localizations"] = Hash.new
    data["individual_localizations"]["home"] = Hash.new
    data["individual_localizations"]["home"]["country"] = "GB"
    data["individual_localizations"]["home"]["city"] = "Dartford"
    data["individual_localizations"]["home"]["address"] = "Shepherds Lane"
    data["individual_localizations"]["business"] = Hash.new
    data["individual_localizations"]["business"]["country"] = nil
    data["individual_localizations"]["business"]["city"] = ""
    data["individual_localizations"]["business"]["address"] = ""
    data["containers"] = Array.new
    data["containers"] << Container.find_by_name("Geral").hash_id
    data
  end
end
