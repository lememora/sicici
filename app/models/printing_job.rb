class PrintableJob < ActiveRecord::Base
  belongs_to :printable
  has_many :printable_dispatches

  after_create :generate_dispatches

  private

  def generate_dispatches
  end
end
