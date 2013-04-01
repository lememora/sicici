class PersonalActivityController < ApplicationController
  before_filter :authenticate
  before_filter :check_read_permission
  before_filter :check_write_permission, :only => [ :save, :delete ]
  after_filter :historify

  include SectionControllerHelper::IncludeMethods

  def list
    @results = PersonalActivity.ample(params)
    @total = PersonalActivity.count_(params)

    render :text => { :success => true, :results => @results, :total => @total }.to_json, 
           :status => :ok
  end

  def quick
    render :text => PersonalActivity.quick(params).to_json, 
           :status => :ok
  end

  def load
    @personal_activity = PersonalActivity.find_by_id(params[:id])

    if @personal_activity
      render :text => { :success => true, :result => @personal_activity }.to_json, 
             :status => :ok
    else
      render :text => { :success => false }.to_json, 
             :status => :not_found
    end
  end

  def save
    @personal_activity = nil

    if (params[:personal_activity] || {})[:id].to_i > 0
      @personal_activity = PersonalActivity.find_by_id(params[:personal_activity][:id])
      @personal_activity.update_attributes_(params)
    else
      @personal_activity = PersonalActivity.new
      @personal_activity.populate(params)
      @personal_activity.save
    end

    if @personal_activity.errors.length == 0
      render :text => { :success => true, :id => @personal_activity.id }.to_json, 
             :status => :created
    else
      render :text => { :success => false, :errors => @personal_activity.errors }.to_json, 
             :status => :unprocessable_entity
    end
  end

  ##def delete
  ##  @personal_activity = PersonalActivity.find(params[:id])
  ##  @personal_activity.destroy unless @personal_activity.nil?
  ##
  ##  if @personal_activity and @personal_activity.destroyed?
  ##    render :text => { :success => true, :id => params[:id] }.to_json, 
  ##           :status => :ok
  ##  else
  ##    render :text => { :success => false }.to_json, 
  ##           :status => :not_found
  ##  end
  ##end

  private

  def check_read_permission
    unless @sections.include?(AclRole::SECTIONS[AclRole::PERSONAL_ACTIVITY])
      render :json => nil, :status => :forbidden
    end
  end

  def check_write_permission
    unless @sections_writable.include?(AclRole::SECTIONS[AclRole::PERSONAL_ACTIVITY])
      render :json => nil, :status => :forbidden
    end
  end

  def history_write(action, id, message)
    if @user
      AclHistory.create(
        :acl_user => @user,
        :acl_role => AclRole.find_by_name(AclRole::PERSONAL_ACTIVITY),
        :action => action,
        :record_id => id,
        :message => message)
    end
  end

  def historify
    if @user
      if action_name == 'save' and @personal_activity and @personal_activity.valid?
        if not (params[:personal_activity][:id] rescue nil).to_s.empty?
          history_write(AclHistory::ACTION_UPDATE,
            @personal_activity.id, "1 ATUAÇÃO (PF) ATUALIZADA: #{@personal_activity.to_s}")
        else
          history_write(AclHistory::ACTION_CREATE,
            @personal_activity.id, "1 ATUAÇÃO (PF) CRIADA: #{@personal_activity.to_s}")
        end
      elsif action_name == 'delete' and @entries
        if @entries.length == 1
          history_write(AclHistory::ACTION_DELETE, @ids.first.to_i,
            "1 ATUAÇÃO (PF) REMOVIDA: #{@entries.first}")
        elsif @entries.length > 1
          history_write(AclHistory::ACTION_DELETE, 0,
            "#{@entries.length} ATUAÇÕES (PF) REMOVIDAS: #{@entries.join(", ")}")
        end
      elsif action_name == 'delete_all' and @affected
        # TODO: improve verbosity
        str = "Texto=#{params[:search]}, Filtro=#{params[:filter]}"
        history_write(AclHistory::ACTION_DELETE, 0,
          "#{@affected} ATUAÇÕES (PF) REMOVIDAS A CRITÉRIO DE BUSCA: #{str}")
      end
    end
  end
end
