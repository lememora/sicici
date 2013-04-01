class BusinessActivityController < ApplicationController
  before_filter :authenticate
  before_filter :check_read_permission
  before_filter :check_write_permission, :only => [ :save, :delete ]
  after_filter :historify

  include SectionControllerHelper::IncludeMethods

  def list
    @results = BusinessActivity.ample(params)
    @total = BusinessActivity.count_(params)

    render :text => { :success => true, :results => @results, :total => @total }.to_json, 
           :status => :ok
  end

  def quick
    render :text => BusinessActivity.quick(params).to_json, 
           :status => :ok
  end

  def load
    @business_activity = BusinessActivity.find_by_id(params[:id])

    if @business_activity
      render :text => { :success => true, :result => @business_activity }.to_json, 
             :status => :ok
    else
      render :text => { :success => false }.to_json, 
             :status => :not_found
    end
  end

  def save
    @business_activity = nil

    if (params[:business_activity] || {})[:id].to_i > 0
      @business_activity = BusinessActivity.find_by_id(params[:business_activity][:id])
      @business_activity.update_attributes_(params)
    else
      @business_activity = BusinessActivity.new
      @business_activity.populate(params)
      @business_activity.save
    end

    if @business_activity.errors.length == 0
      render :text => { :success => true, :id => @business_activity.id }.to_json, 
             :status => :created
    else
      render :text => { :success => false, :errors => @business_activity.errors }.to_json, 
             :status => :unprocessable_entity
    end
  end

  ##def delete
  ##  @business_activity = BusinessActivity.find(params[:id])
  ##  @business_activity.destroy unless @business_activity.nil?
  ##
  ##  if @business_activity and @business_activity.destroyed?
  ##    render :text => { :success => true, :id => params[:id] }.to_json, 
  ##           :status => :ok
  ##  else
  ##    render :text => { :success => false }.to_json, 
  ##           :status => :not_found
  ##  end
  ##end

  private

  def check_read_permission
    unless @sections.include?(AclRole::SECTIONS[AclRole::BUSINESS_ACTIVITY])
      render :json => nil, :status => :forbidden
    end
  end

  def check_write_permission
    unless @sections_writable.include?(AclRole::SECTIONS[AclRole::BUSINESS_ACTIVITY])
      render :json => nil, :status => :forbidden
    end
  end

  def history_write(action, id, message)
    if @user
      AclHistory.create(
        :acl_user => @user,
        :acl_role => AclRole.find_by_name(AclRole::BUSINESS_ACTIVITY),
        :action => action,
        :record_id => id,
        :message => message)
    end
  end

  def historify
    if @user
      if action_name == 'save' and @business_activity and @business_activity.valid?
        if not (params[:business_activity][:id] rescue nil).to_s.empty?
          history_write(AclHistory::ACTION_UPDATE,
            @business_activity.id, "1 ATUAÇÃO (PJ) ATUALIZADA: #{@business_activity.to_s}")
        else
          history_write(AclHistory::ACTION_CREATE,
            @business_activity.id, "1 ATUAÇÃO (PJ) CRIADA: #{@business_activity.to_s}")
        end
      elsif action_name == 'delete' and @entries
        if @entries.length == 1
          history_write(AclHistory::ACTION_DELETE, @ids.first.to_i,
            "1 ATUAÇÃO (PJ) REMOVIDA: #{@entries.first}")
        elsif @entries.length > 1
          history_write(AclHistory::ACTION_DELETE, 0,
            "#{@entries.length} ATUAÇÕES (PJ) REMOVIDAS: #{@entries.join(", ")}")
        end
      elsif action_name == 'delete_all' and @affected
        # TODO: improve verbosity
        str = "Texto=#{params[:search]}, Filtro=#{params[:filter]}"
        history_write(AclHistory::ACTION_DELETE, 0,
          "#{@affected} ATUAÇÕES (PJ) REMOVIDAS A CRITÉRIO DE BUSCA: #{str}")
      end
    end
  end
end
