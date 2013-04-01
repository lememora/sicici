class UserController < ApplicationController
  before_filter :authenticate
  before_filter :check_read_permission
  before_filter :check_write_permission, :only => [ :save, :delete, :containers ]
  after_filter :historify

  include SectionControllerHelper::IncludeMethods

  def list
    @results = AclUser.ample(params)
    @total = AclUser.count_(params)

    render :text => { :success => true, :results => @results, :total => @total }.to_json, 
           :status => :ok
  end

  def quick
    render :text => AclUser.quick(params).to_json, 
           :status => :ok
  end

  def load
    @user = AclUser.find_by_id(params[:id])

    if @user
      render :text => { :success => true, :result => @user }.to_json, 
             :status => :ok
    else
      render :text => { :success => false }.to_json, 
             :status => :not_found
    end
  end

  def save
    if (params[:acl_user] || {})[:id].to_i > 0
      @user = AclUser.find_by_id(params[:acl_user][:id])
      @user.update_attributes_(params)
    else
      @user = AclUser.new
      @user.populate(params)
      @user.save
    end

    if @user.errors.length == 0
      render :text => { :success => true, :id => @user.id }.to_json, 
             :status => :created
    else
      render :text => { :success => false, :errors => @user.errors }.to_json, 
             :status => :unprocessable_entity
    end
  end

  ##def delete
  ##  @user = AclUser.find(params[:id])
  ##  @user.destroy unless @user.nil?
  
  ##  if @user and @user.destroyed?
  ##    render :text => { :success => true, :id => params[:id] }.to_json, 
  ##           :status => :ok
  ##  else
  ##    render :text => { :success => false }.to_json, 
  ##           :status => :not_found
  ##  end
  ##end

  def delete
    @id = 0
    @ids = Array.new
    @entries = Array.new

    if params[:id]
      entry = AclUser.find_by_id(params[:id])
      @entries << entry.to_s unless entry.nil?
      entry.destroy unless entry.nil?
      @id = params[:id] if not entry.nil? and entry.destroyed?
    elsif params[:ids]
      params[:ids].to_s.split(',').each do |j|
        entry = AclUser.find_by_id(j)
        @entries << entry.to_s unless entry.nil?
        entry.destroy unless entry.nil?
        @ids<< j if not entry.nil? and entry.destroyed?
      end
    end

    if not @id.nil?
      render :text => { :success => true, :id => @id }.to_json, 
             :status => :ok
    elsif not @ids.nil?
      render :text => { :success => true, :ids => @ids }.to_json, 
             :status => :ok
    else
      render :text => { :success => false }.to_json, 
             :status => :not_found
    end
  end

  def roles
    r = Array.new
    AclRole.all(:order => :name).each do |j|
      r<< [ "#{j.id}-a", "<b>#{j.name}</b>" ]
      r<< [ "#{j.id}-r", "Leitura" ]
      r<< [ "#{j.id}-w", "Escrita" ]
    end
    render :json => r
  end

  private

  def check_read_permission
    unless @sections.include?(AclRole::SECTIONS[AclRole::USER])
      render :json => nil, :status => :forbidden
    end
  end

  def check_write_permission
    unless @sections_writable.include?(AclRole::SECTIONS[AclRole::USER])
      render :json => nil, :status => :forbidden
    end
  end

  def history_write(action, id, message)
    if @user
      AclHistory.create(
        :acl_user => @user,
        :acl_role => AclRole.find_by_name(AclRole::USER),
        :action => action,
        :record_id => id,
        :message => message)
    end
  end

  def historify
    if @user
      if action_name == 'save'
        if not (params[:acl_user][:id] rescue nil).to_s.empty?
          history_write(AclHistory::ACTION_UPDATE,
            @user.id, "1 USUÁRIO ATUALIZADO: #{@user.to_s}")
        else
          history_write(AclHistory::ACTION_CREATE,
            @user.id, "1 USUÁRIO CRIADO: #{@user.to_s}")
        end
      elsif action_name == 'delete'
        if @entries.length == 1
          history_write(AclHistory::ACTION_DELETE, @ids.first.to_i,
            "1 USUÁRIO REMOVIDO: #{@entries.first}")
        elsif @entries.length > 1
          history_write(AclHistory::ACTION_DELETE, 0,
            "#{@entries.length} USUÁRIOS REMOVIDOS: #{@entries.join(", ")}")
        end
      elsif action_name == 'delete_all'
        # TODO: improve verbosity
        str = "Texto=#{params[:search]}, Filtro=#{params[:filter]}"
        history_write(AclHistory::ACTION_DELETE, 0,
          "#{@affected} USUÁRIOS REMOVIDOS A CRITÉRIO DE BUSCA: #{str}")
      end
    end
  end
end
