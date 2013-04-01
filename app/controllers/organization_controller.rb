class OrganizationController < ApplicationController
  before_filter :authenticate
  before_filter :check_read_permission
  before_filter :check_write_permission, :only => [ :save, :delete ]
  after_filter :historify

  include SectionControllerHelper::IncludeMethods

  def list
    @results = Organization.ample(params)
    @total = Organization.count_(params)

    render :text => { :success => true, :results => @results, :total => @total }.to_json, 
           :status => :ok
  end

  def quick
    render :text => Organization.quick(params).to_json, 
           :status => :ok
  end

  def load
    @organization = Organization.find_by_id(params[:id])

    if @organization
      render :text => { :success => true, :result => @organization }.to_json, 
             :status => :ok
    else
      render :text => { :success => false }.to_json, 
             :status => :not_found
    end
  end

  def save
    if (params[:organization] || {})[:id].to_i > 0
      @organization = Organization.find_by_id(params[:organization][:id])
      @organization.update_attributes_(params)
    else
      @organization = Organization.new
      @organization.populate(params)
      @organization.save
    end

    if @organization.errors.length == 0
      render :text => { :success => true, :id => @organization.id }.to_json, 
             :status => :created
    else
      render :text => { :success => false, :errors => @organization.errors }.to_json, 
             :status => :unprocessable_entity
    end
  end

  ##def delete
  ##  @organization = Organization.find(params[:id])
  ##  @organization.destroy unless @organization.nil?

  ##  if @organization and @organization.destroyed?
  ##    render :text => { :success => true, :id => params[:id] }.to_json, 
  ##           :status => :ok
  ##  else
  ##    render :text => { :success => false }.to_json, 
  ##           :status => :not_found
  ##  end
  ##end

  def activities
    Organization.activities_shift(params)

    render :text => { :success => true }.to_json, 
           :status => :created
  end

  private

  def check_read_permission
    unless @sections.include?(AclRole::SECTIONS[AclRole::ORGANIZATION])
      render :json => nil, :status => :forbidden
    end
  end

  def check_write_permission
    unless @sections_writable.include?(AclRole::SECTIONS[AclRole::ORGANIZATION])
      render :json => nil, :status => :forbidden
    end
  end

  def history_write(action, id, message)
    if @user
      AclHistory.create(
        :acl_user => @user,
        :acl_role => AclRole.find_by_name(AclRole::ORGANIZATION),
        :action => action,
        :record_id => id,
        :message => message)
    end
  end

  def historify
    if @user
      if action_name == 'save'
        if not (params[:organization][:id] rescue nil).to_s.empty?
          history_write(AclHistory::ACTION_UPDATE,
            @organization.id, "1 EMPRESA ATUALIZADA: #{@organization.to_s}")
        else
          history_write(AclHistory::ACTION_CREATE,
            @organization.id, "1 EMPRESA CRIADA: #{@organization.to_s}")
        end
      elsif action_name == 'delete'
        if @entries.length == 1
          history_write(AclHistory::ACTION_DELETE, @ids.first.to_i,
            "1 EMPRESA REMOVIDA: #{@entries.first}")
        elsif @entries.length > 1
          history_write(AclHistory::ACTION_DELETE, 0,
            "#{@entries.length} EMPRESAS REMOVIDAS: #{@entries.join(", ")}")
        end
      elsif action_name == 'delete_all'
        # TODO: improve verbosity
        str = "Texto=#{params[:search]}, Filtro=#{params[:filter]}"
        history_write(AclHistory::ACTION_DELETE, 0,
          "#{@affected} EMPRESAS REMOVIDAS A CRITÉRIO DE BUSCA: #{str}")
      end
    end
  end
end
