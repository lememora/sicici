require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  test "01 - Contact New" do
    contact = Contact.new(contact_new_example_data)
    contact.save

    Rails.logger.info("\e[101m#{contact.errors.inspect}\e[0m")

    assert_equal 0, contact.errors.length
    assert_not_nil contact.subscriber
    assert_equal 2, contact.individual.personal_activities.length
    assert_equal 2, contact.individual.individual_connections.length
    assert_equal 2, contact.individual.individual_localizations.length
    assert_not_nil contact.individual.individual_localizations.first.localization
    assert_equal 2, contact.individual.containers.length
    assert_not_nil contact.individual.employment
    assert_not_nil contact.organization
    assert_equal 2, contact.organization.business_activities.length
    assert_equal 2, contact.organization.organization_connections.length
    assert_equal 1, contact.organization.organization_localizations.length
    assert contact.organization.employments.length > 0
  end

  test "02 - Contact to JSON" do
    contact = Contact.find_by_individual(Individual.last)
    data = ActiveSupport::JSON.decode contact.to_json

    assert_not_nil data["subscriber"]
    assert_not_nil data["individual"]
    assert_equal 2, (data["personal_activities"] || []).length
    ##assert_equal 2, (data["individual_connections"] || {}).length
    assert (data["individual_connections"] || {}).length > 0
    assert_equal 2, (data["individual_localizations"] || {}).length
    assert_not_nil (data["individual_localizations"] || {})["home"]
    assert_equal 2, (data["containers"] || []).length
    assert_not_nil data["organization"]
    assert_equal 2, (data["business_activities"] || []).length
    ##assert_equal 2, (data["organization_connections"] || {}).length
    assert (data["organization_connections"] || {}).length > 0
    assert_equal 1, (data["organization_localizations"] || {}).length
    assert_not_nil data["job_position"]
  end

  test "03 - Contact find by Individual" do
    contact = Contact.find_by_individual(Individual.last.id)
    assert_not_nil contact.individual
    assert_not_nil contact.subscriber
    assert_not_nil contact.organization
  end

  test "04 - Contact find by Subscriber" do
    contact = Contact.find_by_subscriber(Subscriber.last.hash_id)
    assert_not_nil contact.individual
    assert_not_nil contact.subscriber
    assert_not_nil contact.organization
  end

  test "05 - Contact Update" do
    data = contact_update_example_data
    contact = Contact.find_by_individual(data["individual"]["id"])
    contact.update_attributes_(data)

    Rails.logger.info("\e[101m#{contact.errors.inspect}\e[0m")

    assert_equal 0, contact.errors.length
    assert_not_nil contact.subscriber
    assert_equal 1, contact.individual.personal_activities(true).length
    assert_equal 1, contact.individual.individual_connections(true).length
    assert_equal 1, contact.individual.individual_localizations(true).length
    assert_not_nil contact.individual.individual_localizations(true).first.localization
    assert_equal 1, contact.individual.containers(true).length
    assert_nil contact.individual.employment(true)
    assert_nil contact.organization
  end
end
