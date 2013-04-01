class PrintableDispatch < ActiveRecord::Base
  belongs_to :printable_job
  belongs_to :subscriber

  def self.total_by_printable_job(printable_job)
    self.count(:conditions => [ "printable_job_id = ?", printable_job.id ])
  end
end
