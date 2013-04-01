require 'test_helper'

class NotifierTest < ActiveSupport::TestCase
  test "01 - Subscriber Request Validation" do
    subscriber = Subscriber.find_by_email("no-reply@fbco.com.br")
    if subscriber.nil?
      individual = Individual.create(:name => "Rafael Castilho")
      subscriber = Subscriber.create(:individual => individual, :email => "no-reply@fbco.com.br")
    end
    assert Notifier.deliver_subscriber_request_validation(subscriber)
  end

  test "02 - Subscriber Request Update (Register)" do
    subscriber = Subscriber.find_by_email("no-reply@fbco.com.br")
    assert Notifier.deliver_subscriber_request_update(subscriber)
  end

  test "03 - Subscriber Request Update (Event)" do
    subscriber = Subscriber.find_by_email("no-reply@fbco.com.br")
    event = Event.create(:name => "Test #{rand(1000)}")
    assert Notifier.deliver_subscriber_request_update(subscriber, event)
  end

  test "04 - Subscriber Request Confirmation" do
    subscriber = Subscriber.find_by_email("no-reply@fbco.com.br")
    event = Event.last
    assert Notifier.deliver_subscriber_request_confirmation(subscriber, event)
  end
end
