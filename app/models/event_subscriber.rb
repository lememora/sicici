class EventSubscriber < ActiveRecord::Base
  belongs_to :event
  belongs_to :subscriber
  validates_uniqueness_of :subscriber_id, :scope => :event_id
end
