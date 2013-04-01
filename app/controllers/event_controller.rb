class EventController < ApplicationController
  before_filter :authenticate
  before_filter :check_read_permission
  before_filter :check_write_permission, :only => [ :save, :delete ]
  after_filter :historify

  include SectionControllerHelper::IncludeMethods

  def list
    @results = Event.ample(params)
    @total = Event.count_(params)

    render :text => { :success => true, :results => @results, :total => @total }.to_json, 
           :status => :ok
  end

  def quick
    render :text => Event.quick(params).to_json, 
           :status => :ok
  end

  def load
    @event = Event.find_by_id(params[:id])

    if @event
      render :text => { :success => true, :result => @event }.to_json, 
             :status => :ok
    else
      render :text => { :success => false }.to_json, 
             :status => :not_found
    end
  end

  def save
    if (params[:event] || {})[:id].to_i > 0
      @event = Event.find_by_id(params[:event][:id])
      @event.update_attributes_(params)
    else
      @event = Event.new
      @event.populate(params)
      @event.save
    end

    if params[:event_image] and @event.hash_id
      ApplicationHelper.public_data_upload(
        params[:event_image], :event_image, @event.hash_id)
    end
    if params[:event_image_delete] and @event.hash_id
      ApplicationHelper.public_data_delete(:event_image, @event.hash_id)
    end

    if @event.errors.length == 0
      render :text => { :success => true, :id => @event.id }.to_json, 
             :status => :created
    else
      render :text => { :success => false, :errors => @event.errors }.to_json, 
             :status => :unprocessable_entity
    end
  end

  ##def delete
  ##  @event = Event.find(params[:id])
  ##  @event.destroy unless @event.nil?

  ##  if @event and @event.destroyed?
  ##    render :text => { :success => true, :id => params[:id] }.to_json, 
  ##           :status => :ok
  ##  else
  ##    render :text => { :success => false }.to_json, 
  ##           :status => :not_found
  ##  end
  ##end

  def generate_permalink
    permalink = ApplicationHelper.generate_permalink(params[:input] || "")
    render :json => { :permalink => permalink }
  end

  private

  def check_read_permission
    unless @sections.include?(AclRole::SECTIONS[AclRole::EVENT])
      render :json => nil, :status => :forbidden
    end
  end

  def check_write_permission
    unless @sections_writable.include?(AclRole::SECTIONS[AclRole::EVENT])
      render :json => nil, :status => :forbidden
    end
  end

  def history_write(action, id, message)
    if @user
      AclHistory.create(
        :acl_user => @user,
        :acl_role => AclRole.find_by_name(AclRole::EVENT),
        :action => action,
        :record_id => id,
        :message => message)
    end
  end

  def historify
    if @user
      if action_name == 'save'
        if not (params[:event][:id] rescue nil).to_s.empty?
          history_write(AclHistory::ACTION_UPDATE,
            @event.id, "1 EVENTO ATUALIZADO: #{@event.to_s}")
        else
          history_write(AclHistory::ACTION_CREATE,
            @event.id, "1 EVENTO CRIADO: #{@event.to_s}")
        end
      elsif action_name == 'delete'
        if @entries.length == 1
          history_write(AclHistory::ACTION_DELETE, @ids.first.to_i,
            "1 EVENTO REMOVIDO: #{@entries.first}")
        elsif @entries.length > 1
          history_write(AclHistory::ACTION_DELETE, 0,
            "#{@entries.length} EVENTOS REMOVIDOS: #{@entries.join(", ")}")
        end
      elsif action_name == 'delete_all'
        # TODO: improve verbosity
        str = "Texto=#{params[:search]}, Filtro=#{params[:filter]}"
        history_write(AclHistory::ACTION_DELETE, 0,
          "#{@affected} EVENTOS REMOVIDOS A CRITÉRIO DE BUSCA: #{str}")
      end
    end
  end
end
