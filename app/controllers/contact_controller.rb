class ContactController < ApplicationController
  before_filter :authenticate
  before_filter :check_read_permission
  before_filter :check_write_permission, :only => [ :save, :delete, :containers ]
  after_filter :historify

  include SectionControllerHelper::IncludeMethods

  def load
    @entry = nil
    @entry = Contact.find_by_individual(params["id"]) if params["id"]
    @entry = Contact.find_by_email(params["email"]) if params["email"]
    @entry = Contact.find_by_name(params["name"]) if params["name"]

    if @entry
      render :text => { :success => true, :result => @entry }.to_json, 
             :status => :ok
    else
      render :text => { :success => false }.to_json, 
             :status => :not_found
    end
  end

  def save
    if (params["individual"] || {})["id"].to_i > 0
      @contact = Contact.find_by_individual(params["individual"]["id"])
      @contact.update_attributes_(params)
    else
      @contact = Contact.new(params)
      @contact.subscriber.validated = true if @contact.subscriber
      @contact.save
    end

    if @contact.errors.length == 0
      render :text => { :success => true, :id => @contact.individual.id }.to_json, 
             :status => :created
    else
      render :text => { :success => false, :errors => @contact.errors }.to_json, 
             :status => :unprocessable_entity
    end
  end

  def containers
    Contact.containers_shift(params)

    render :text => { :success => true }.to_json, 
           :status => :created
  end

  def activities
    Contact.activities_shift(params)

    render :text => { :success => true }.to_json, 
           :status => :created
  end

  def delete_all
    delete_all_(params, 'individuals')
  end

  private

  def check_read_permission
    unless @sections.include?(AclRole::SECTIONS[AclRole::CONTACT])
      render :json => nil, :status => :forbidden
    end
  end

  def check_write_permission
    unless @sections_writable.include?(AclRole::SECTIONS[AclRole::CONTACT])
      render :json => nil, :status => :forbidden
    end
  end

  def history_write(action, id, message)
    if @user
      AclHistory.create(
        :acl_user => @user,
        :acl_role => AclRole.find_by_name(AclRole::CONTACT),
        :action => action,
        :record_id => id,
        :message => message)
    end
  end

  def historify
    if @user
      if action_name == 'save'
        if not (params[:individual][:id] rescue nil).to_s.empty?
          history_write(AclHistory::ACTION_UPDATE,
            @contact.id, "1 CONTATO ATUALIZADO: #{@contact.to_s}")
        else
          history_write(AclHistory::ACTION_CREATE,
            @contact.id, "1 CONTATO CRIADO: #{@contact.to_s}")
        end
      elsif action_name == 'delete'
        if @entries.length == 1
          history_write(AclHistory::ACTION_DELETE, @ids.first.to_i,
            "1 CONTATO REMOVIDO: #{@entries.first}")
        elsif @entries.length > 1
          history_write(AclHistory::ACTION_DELETE, 0,
            "#{@entries.length} CONTATOS REMOVIDOS: #{@entries.join(", ")}")
        end
      elsif action_name == 'delete_all'
        # TODO: improve verbosity
        str = "Texto=#{params[:search]}, Filtro=#{params[:filter]}"
        history_write(AclHistory::ACTION_DELETE, 0,
          "#{@affected} CONTATOS REMOVIDOS A CRITÉRIO DE BUSCA: #{str}")
      end
    end
  end
end
