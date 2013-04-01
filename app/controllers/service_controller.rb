class ServiceController < ApplicationController

  before_filter :authenticate_service

  def method_missing(*args)
    render :json => nil
  end

  def subscriber_email_check
    @subscriber = nil
    @subscriber = Subscriber.find_by_email(params[:email]) if params[:email]
    render :json => { :found => (@subscriber.instance_of? Subscriber) }
  end

  def subscriber_request_update
    @requested = false
    @requested = Subscriber.request_update(params[:email]) if params[:email]
    render :json => { :requested => @requested }
  end

  def subscriber_request_validation
    @requested = false
    @requested = Subscriber.request_validation(params[:email]) if params[:email]
    render :json => { :requested => @requested }
  end

  def subscriber_validate 
    @validated = false
    @validated = Subscriber.validate(params[:hash_id]) if params[:hash_id]
    render :json => { :validated => @validated }
  end

  def subscriber_unsubscribe
    @validated = false
    @validated = Subscriber.unsubscribe(params[:hash_id]) if params[:hash_id]
    render :json => { :validated => @validated }
  end

  def contact
    @contact = Contact.find_by_subscriber(params[:hash_id])
    render :json => @contact
  end

  def contact_save
    hash_id = params[:subscriber][:hash_id] rescue nil
    @contact = hash_id ? Contact.find_by_subscriber(hash_id) : nil
    @updated = false
    if @contact
      @contact.update_attributes_(params, rehash_subscriber=true)
      @updated = true
    else
      @contact = Contact.new(params)
      @contact.save
    end
    @errors = @contact ? @contact.errors : []
    render :json => { :success => @errors.length == 0, 
                      :errors => @errors,
                      :updated => @updated,
                      :contact => @contact }
  end

  def organization
    @organization = nil
    if params[:query].to_s.match(/^[\d]+$/)
      @organization = Organization.find_by_id(params[:query])
    else
      @organization = Organization.find_by_name(params[:query]) 
    end
    render :json => @organization
  end

  def event
    @event = nil
    found = Event.find_by_permalink(params[:permalink])
    if found
      @event = found.hashmap
      @event["event_image_base64"] = found.event_image_base64
    end
    render :json => @event
  end

  def event_request_confirmation
    @requested = false
    @requested = Event.request_confirmation(
      params[:email], 
      params[:permalink]) if params[:email] and params[:permalink]
    render :json => { :requested => @requested }
  end

  def event_subscribe
    event = Event.find_by_permalink(params[:permalink])
    subscriber = Subscriber.find_by_hash_id(params[:hash_id], :include => :individual)
    # TODO read data from params[:data], serialize and store in EventSubscriber
    @subscribed = nil
    @subscribed = event.subscribe(subscriber) if event and subscriber
    Subscriber.validate(params[:hash_id]) if params[:hash_id] # also validate
    render :json => { :subscribed => (@subscribed.instance_of? EventSubscriber) }
  end

  def containers
    render :json => ApplicationHelper.extract_key_value(
      Container.all(:conditions => "container_types.public = TRUE",
                    :joins => :container_type,
                    #:order => "container_types.name, containers.name"),
                    :order => "containers.name"),
      :hash_id, :name, params[:search])
  end

  def countries
    render :json => ApplicationHelper.extract_key_value(
      Country.all, :id, :name,
        params[:search], params[:value_only])
  end

  def personal_activities
    render :json => ApplicationHelper.extract_key_value(
      PersonalActivity.all(:order => :name), :id, :name, 
        params[:search], params[:value_only])
  end

  def business_activities
    render :json => ApplicationHelper.extract_key_value(
      BusinessActivity.all(:order => :name), :id, :name,
        params[:search], params[:value_only])
  end

  #def job_positions
  #  render :json => ApplicationHelper.extract_key_value(
  #    JobPosition.all(:order => :name), :id, :name,
  #      params[:search], params[:value_only])
  #end

  def organizations
    render :json => ApplicationHelper.extract_key_value(
      Organization.all(:order => :name), :id, :name,
        params[:search], params[:value_only])
  end

  private

  def authenticate_service
    return true if authenticated?
    authenticate_or_request_with_http_basic do |username, password| 
      authenticated, @user = AclUser.authenticate(username, password, digest=false)
      session[:authenticated_username] = username if authenticated
      authenticated
    end
  end
end
