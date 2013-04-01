# usage:
#
# /usr/bin/ruby script/runner "MailerDaemon.campaign_job_starter"
# /usr/bin/ruby script/runner "MailerDaemon.campaign_job_finalizer"
# /usr/bin/ruby script/runner "MailerDaemon.campaign_dispatcher"
# /usr/bin/ruby script/runner "MailerDaemon.campaign_dsn_parser"
# /usr/bin/ruby script/runner "MailerDaemon.campaign_schedule_observer"
# /usr/bin/ruby script/runner "MailerDaemon.campaign_job_gc"


class MailerDaemonUtil
  include ActionMailer::Quoting
  def encode(s)
    return quoted_printable(s, 'utf-8')
  end
end


module MailerDaemon
  INFO = "INFO"
  FAIL = "FAIL"
  WARN = "WARN"

  SMTP_ADDRESS = "localhost"
  SMTP_PORT = 25

  MAIL_FROM_NAME = "Nobody"
  MAIL_FROM_USERNAME = "nobody"
  MAIL_FROM_DOMAIN = "localhost"

  POP3_ADDRESS = "localhost"
  POP3_PORT = 110
  POP3_USERNAME = "nobody"
  POP3_PASSWORD = "nobody"

  CAMPAIGN_DISPATCH_RATE = 25
  CAMPAIGN_SCHEDULE_FORWARDNESS = 43200

  # Campaign Job Starter
  def self.campaign_job_starter
    connection = ActiveRecord::Base.connection

    query = Array.new
    query<< "UPDATE campaign_jobs SET pid=#{$$} WHERE"
    query<< "pid=0 AND status='#{CampaignJob::STATUS_NEW}' AND"
    query<< "scheduled IS NOT NULL AND scheduled <= UTC_TIMESTAMP() LIMIT 1"

    booked = connection.update(query.join(' ')).to_i

    mlog(INFO, "booked #{booked} campaign jobs")
    
    return false if booked == 0

    campaign_job = CampaignJob.first(
      :conditions => "status='#{CampaignJob::STATUS_NEW}' AND pid=#{$$}",
      :include => { :campaign => [ :containers ] })

    if campaign_job.nil?
      mlog(FAIL, "failed to retrieve the booked campaign job")
      return false
    else
      mlog(INFO, "regained the campaign job #{campaign_job.id}")
    end

    campaign_containers = campaign_job.campaign.containers.map { |j| j.id }

    if campaign_containers.length == 0
      campaign_job.update_attributes(:status => CampaignJob::STATUS_FINISHED)
      mlog(INFO, "finalized campaign job #{campaign_job.id} with no containers")
      return false
    end

    mlog(INFO, "has the following containers: #{campaign_containers.join(",")}")

    query = Array.new
    query<< "REPLACE INTO campaign_dispatches (subscriber_id, campaign_job_id)"
    query<< "SELECT id, #{campaign_job.id} FROM subscribers WHERE"
    query<< "validated = TRUE AND unsubscribed = FALSE AND rejected = FALSE AND"
    query<< "individual_id IN ("
    query<< "SELECT DISTINCT(individual_id) FROM individual_containers WHERE"
    query<< "container_id IN (#{campaign_containers.join(',')}))"

    queued = connection.update(query.join(' ')).to_i

    mlog(INFO, "queued #{queued} campaign dispatches")

    campaign_job.update_attributes(:status => CampaignJob::STATUS_RUNNING)

    mlog(INFO, "campaign job #{campaign_job.id} status updated to running")

    return true
  end

  # Campaign Job Finisher
  def self.campaign_job_finalizer
    campaign_jobs = CampaignJob.all(
      :conditions => "status='#{CampaignJob::STATUS_RUNNING}'")

    if campaign_jobs.count == 0
      mlog(INFO, "found no running campaign jobs")
      return false
    end

    campaign_jobs.each do |job|
      unsent = job.campaign_dispatches.count(
        :conditions => "status='#{CampaignDispatch::STATUS_UNSENT}' AND pid=0")

      if unsent.to_i > 0
        mlog(INFO, "kept intact working campaign job #{job.id} with #{unsent} unsent messages")
      else
        job.update_attributes(:status => CampaignJob::STATUS_FINISHED)
        mlog(INFO, "finalized campaign job #{job.id} with #{unsent} unsent messages")
      end
    end

    return true
  end

  # Campaign Dispatcher
  def self.campaign_dispatcher
    require 'digest/sha1'
    require 'net/smtp'

    connection = ActiveRecord::Base.connection

    query = Array.new
    query<< "UPDATE campaign_dispatches SET pid=#{$$} WHERE"
    rate = APP_CONFIG["campaign_dispatch_rate"] || CAMPAIGN_DISPATCH_RATE
    query<< "pid=0 AND status='#{CampaignDispatch::STATUS_UNSENT}'"
    query<< "AND campaign_job_id IN (SELECT id FROM campaign_jobs WHERE"
    query<< "status = '#{CampaignJob::STATUS_RUNNING}')"
    query<< "LIMIT #{rate}"

    booked = connection.update(query.join(' ')).to_i

    mlog(INFO, "booked #{booked} campaign dispatches")

    return false if booked == 0

    campaign_dispatches = CampaignDispatch.all(
      :conditions => "status='#{CampaignDispatch::STATUS_UNSENT}' AND pid=#{$$}",
      :include => { :campaign_job => [], :subscriber => [ :individual ] })

    if campaign_dispatches.count == 0
      mlog(FAIL, "failed to retrieve booked campaign dispatches")
      return false
    else
      mlog(INFO, "regained #{campaign_dispatches.count} booked campaign dispathes")
    end

    address       = APP_CONFIG["smtp_address"]       || SMTP_ADDRESS
    port          = APP_CONFIG["smtp_port"]          || SMTP_PORT
    from_name     = APP_CONFIG["mail_from_name"]     || MAIL_FROM_NAME
    from_username = APP_CONFIG["mail_from_username"] || MAIL_FROM_USERNAME
    from_domain   = APP_CONFIG["mail_from_domain"]   || MAIL_FROM_DOMAIN

    Net::SMTP.start(address, port) do |smtp|

      mlog(INFO, "net smtp connected on address #{address} and port #{port}")

      campaign_dispatches.each do |dispatch|

        message = Array.new
        # message header
        sender = "#{from_username}+#{dispatch.id}@#{from_domain}"
        recipient = dispatch.subscriber.email
        message_id = dispatch.subscriber.hash
        message<< "From: #{from_name} <#{sender}>"
        message<< "To: #{dispatch.subscriber.individual.name} <#{recipient}>"
        message<< "MIME-Version: 1.0"
        message<< "Content-type: text/html; charset=UTF-8"

        message<< "Subject: #{MailerDaemonUtil.new.encode(dispatch.campaign_job.subject)}"
        message<< "Date: #{Time.now.strftime("%a, %d %b %Y %H:%M:%S %z")}"
        message_serial = "M%05d%010d" % [ dispatch.campaign_job.id, dispatch.id ]
        message<< "Message-Id: <#{message_serial}@#{from_domain}>"

        # message body
        rhtml = ERB.new(dispatch.campaign_job.template || "")
        data = Hash.new
        data["subscriber"] = dispatch.subscriber.attributes
        data["individual"] = dispatch.subscriber.individual.attributes
        message<< ""
        mail_body = TemplateHelper.render_rhtml(rhtml, data)
        message<< mail_body

        if mail_body.to_s.empty?
          mlog(WARN, "message #{message_serial} failed because body is empty")
          dispatch.status = CampaignDispatch::STATUS_FAILED
        else
          # SEND MESSAGE
          begin
            smtp.send_message message.join("\n"), sender, recipient
            mlog(INFO, "message #{message_serial} sent")
            dispatch.status = CampaignDispatch::STATUS_SENT
          # SMTP FAILED
          rescue Net::SMTPSyntaxError, 
                 Net::SMTPFatalError,
                 Net::SMTPUnknownError,
                 IOError => error
            mlog(WARN, "message #{message_serial} failed due to #{error.message}")
            dispatch.status = CampaignDispatch::STATUS_FAILED
          # UNSENT
          rescue Net::SMTPServerBusy, 
                 TimeoutError => error
            mlog(WARN, "message #{message_serial} kept unsent due to #{error.message}")
          end
        end
        sleep 1.0
        dispatch.save
      end
    end

    return true
  end

  # Campaign Delivery Status Notification Parser
  def self.campaign_dsn_parser
    require 'net/pop'

    pop3_address  = APP_CONFIG["pop3_address"]       || POP3_ADDRESS
    pop3_port     = APP_CONFIG["pop3_port"]          || POP3_PORT
    pop3_username = APP_CONFIG["pop3_username"]      || POP3_USERNAME
    pop3_password = APP_CONFIG["pop3_password"]      || POP3_PASSWORD
    from_username = APP_CONFIG["mail_from_username"] || MAIL_FROM_USERNAME
    from_domain   = APP_CONFIG["mail_from_domain"]   || MAIL_FROM_DOMAIN

    from_regexp   = Array.new
    from_regexp  << "#{(from_username.gsub(/[^\w\+]/, '.+'))}\\+[\\d]+"
    from_regexp  << "#{(from_domain.gsub(/[^\w\.]/, '.+'))}"
    from_regexp   = Regexp.new(from_regexp.join("@"))

    stat_regexp   = /Status:[\s]*[2-5]\.[0-9]\.[0-9]/

    begin
      Net::POP3.start(pop3_address, 
                      pop3_port, 
                      pop3_username, 
                      pop3_password) do |pop|

        mlog(INFO, "net pop3 connected on address #{pop3_address} and port #{pop3_port}")

        if pop.mails.empty?
          mlog(INFO, "pop3 not have any new messages")
          return false
        end

        counter = 1
        pop.mails.each do |mail|
          message = mail.pop
          addr = message.scan(from_regexp).uniq.first.to_s
          stat = message.scan(stat_regexp).uniq.first.to_s.match(/[45]/).to_s

          mlog(INFO, "message #{counter} popped with #{message.length} bytes length and status #{stat}")

          if addr.empty?
            mlog(WARN, "message #{counter} does not have a from address")
          end

          unless addr.empty?
            dispatch_id = addr.match(/\+[\d]+@/).to_s.gsub(/[^\d]+/, '').to_i
            status = stat.to_i == 5 ? CampaignDispatch::STATUS_REJECTED :
                                      CampaignDispatch::STATUS_BOUNCED
            dispatch = CampaignDispatch.find_by_id(dispatch_id, :include => :subscriber)

            if dispatch.nil?
              mlog(FAIL, "message #{counter} with campaign dispatch #{dispatch_id} was not found")
            end

            unless dispatch.nil?
              if dispatch.status==CampaignDispatch::STATUS_BOUNCED
                mlog(WARN, "message #{counter} with campaign dispatch #{dispatch_id} has been previously defined as bounced")
              else
                dispatch.update_attributes(:status => status)
                mlog(INFO, "message #{counter} with campaign dispatch #{dispatch_id} had its status set to #{status}")
              end
            end
          end # unless addr.empty?
          mail.delete
          counter = counter + 1
        end # pop.mails.each do |mail|
        pop.finish
      end # Net::POP3.start(...) do |pop|
    rescue Net::POPAuthenticationError
      mlog(FAIL, "pop3 authentication error")
    rescue
      mlog(FAIL, "pop3 error")
    end

    return true
  end

  # Campaign Schedule Observer
  def self.campaign_schedule_observer
    campaigns = Campaign.all(
      :conditions => [ "periodicity > 0 AND (enabled = ? AND deleted = ?)", true, false ],
      :include => :campaign_jobs)

    if campaigns.length == 0
      mlog(INFO, "found no campaigns with periodicity") 
      return false
    end

    campaigns.each do |campaign|
      campaign_job = campaign.campaign_jobs.last(
        :conditions => [ "scheduled IS NOT NULL" ],
        :order => :created_at)

      if campaign_job.nil?
        mlog(INFO, "found no scheduled campaign jobs for campaign #{campaign.id}") 
      else
        finished = campaign_job.status == CampaignJob::STATUS_FINISHED
        forwardness = APP_CONFIG["campaign_schedule_forwardness"]
        forwardness = CAMPAIGN_SCHEDULE_FORWARDNESS if forwardness.nil?
        season = (campaign_job.scheduled + 
                  campaign.periodicity - 
                  forwardness) <= DateTime.now
        if season
          if finished
            scheduled = campaign_job.scheduled + campaign.periodicity
            campaign_job = CampaignJob.create(
              :campaign => campaign, 
              :scheduled => scheduled,
              :subject => campaign_job.subject || campaign.name)
            mlog(INFO, "campaign job #{campaign_job.id} scheduled to #{scheduled}") 
          else
            mlog(WARN, "a new scheduled campaign job could not be created because campaign job #{campaign_job.id} still unfinished")
          end
        else
          mlog(INFO, "campaign job #{campaign_job.id} does not need to schedule") 
        end
      end
    end

    return true
  end

  # Campaign Job Garbage Collector
  def self.campaign_job_gc
    conditions = Array.new
    conditions<< "status='#{CampaignJob::STATUS_NEW}'"
    conditions<< "pid > 0"
    conditions<< "scheduled < UTC_TIMESTAMP()"
    campaign_jobs =CampaignJob.all(:conditions => conditions.join(" AND "))
    
    if campaign_jobs.length == 0
      mlog(INFO, "found no scheduled campaign jobs with pid associated")
      return false
    end

    campaign_jobs.each do |job|
      if %x"/bin/ps --no-heading -p #{job.pid}".match(Regexp.new("#{job.pid}")).nil?
        mlog(WARN, "campaign job #{job.id} pid #{job.pid} not found in system")
        job.campaign_dispatches.clear
        job.update_attributes(:pid => 0)
        mlog(INFO, "campaign job #{job.id} pid was reset")
      else
        mlog(INFO, "campaign job #{job.id} pid #{pid} found in system")
      end
    end

    return true
  end

  # Campaign Dispatch Garbage Collector
  def self.campaign_dispatch_gc
    # TODO
    # SELECT DISTINCT(pid) FROM campaign_dispatches
    # WHERE status=#{CampaignDispatch::STATUS_UNSENT}
    # ...
  end

  # Subscriber Validation Request
  def self.subscriber_validation_request
    # TODO
  end

  # Subscriber Update Request
  def self.subscriber_update_request
    # TODO
  end

  # Subscriber Confirmation Request
  def self.subscriber_confirmation_request
    # TODO
  end

  private

  def self.mlog(priority, message)
    caller[0]=~/`(.*?)'/
    puts("#{priority}\t#{Time.now.strftime("%H:%M:%S %Z")}\t#{$$}\t#{$1}\t#{message}")
    sleep 0.5
  end
end
