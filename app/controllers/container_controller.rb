class ContainerController < ApplicationController
  before_filter :authenticate
  before_filter :check_read_permission
  before_filter :check_write_permission, :only => [ :save, :delete, :containers ]
  after_filter :historify

  include SectionControllerHelper::IncludeMethods

  def list
    @results = Container.ample(params)
    @total = Container.count_(params)

    render :text => { :success => true, :results => @results, :total => @total }.to_json, 
           :status => :ok
  end

  def quick
    render :text => Container.quick(params).to_json, 
           :status => :ok
  end

  def load
    @container = Container.find_by_id(params[:id])

    if @container
      render :text => { :success => true, :result => @container }.to_json, 
             :status => :ok
    else
      render :text => { :success => false }.to_json, 
             :status => :not_found
    end
  end

  def save
    @container = nil

    if (params[:container] || {})[:id].to_i > 0
      @container = Container.find_by_id(params[:container][:id])
      @container.update_attributes_(params)
    else
      @container = Container.new
      @container.populate(params)
      @container.save
    end

    if @container.errors.length == 0
      render :text => { :success => true, :id => @container.id }.to_json, 
             :status => :created
    else
      render :text => { :success => false, :errors => @container.errors }.to_json, 
             :status => :unprocessable_entity
    end
  end

  ##def delete
  ##  @container = Container.find(params[:id])
  ##  @container.destroy unless @container.nil?
  ##
  ##  if @container and @container.destroyed?
  ##    render :text => { :success => true, :id => params[:id] }.to_json, 
  ##           :status => :ok
  ##  else
  ##    render :text => { :success => false }.to_json, 
  ##           :status => :not_found
  ##  end
  ##end

  def containers
    render :json => ApplicationHelper.extract_key_value(
      Container.all(:joins => :container_type, :order => :name), 
      :hash_id, :name, params[:search])
  end

  def container_types
    render :json => ApplicationHelper.extract_key_value(
      ContainerType.all(:order => :name), :id, :name, params[:search])
  end

  private

  def check_read_permission
    unless @sections.include?(AclRole::SECTIONS[AclRole::CONTAINER])
      render :json => nil, :status => :forbidden
    end
  end

  def check_write_permission
    unless @sections_writable.include?(AclRole::SECTIONS[AclRole::CONTAINER])
      render :json => nil, :status => :forbidden
    end
  end

  def history_write(action, id, message)
    if @user
      AclHistory.create(
        :acl_user => @user,
        :acl_role => AclRole.find_by_name(AclRole::CONTAINER),
        :action => action,
        :record_id => id,
        :message => message)
    end
  end

  def historify
    if @user
      if action_name == 'save' and @container and @container.valid?
        if not (params[:container][:id] rescue nil).to_s.empty?
          history_write(AclHistory::ACTION_UPDATE,
            @container.id, "1 CONTÂINER ATUALIZADO: #{@container.to_s}")
        else
          history_write(AclHistory::ACTION_CREATE,
            @container.id, "1 CONTÂINER CRIADO: #{@container.to_s}")
        end
      elsif action_name == 'delete' and @entries
        if @entries.length == 1
          history_write(AclHistory::ACTION_DELETE, @ids.first.to_i,
            "1 CONTÂINER REMOVIDO: #{@entries.first}")
        elsif @entries.length > 1
          history_write(AclHistory::ACTION_DELETE, 0,
            "#{@entries.length} CONTÂINERES REMOVIDOS: #{@entries.join(", ")}")
        end
      elsif action_name == 'delete_all' and @affected
        # TODO: improve verbosity
        str = "Texto=#{params[:search]}, Filtro=#{params[:filter]}"
        history_write(AclHistory::ACTION_DELETE, 0,
          "#{@affected} CONTÂINERES REMOVIDOS A CRITÉRIO DE BUSCA: #{str}")
      end
    end
  end
end
