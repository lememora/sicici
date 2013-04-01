class PrintableController < ApplicationController
  before_filter :authenticate
  before_filter :check_read_permission
  before_filter :check_write_permission, :only => [ :save, :delete ]
  after_filter :historify

  include SectionControllerHelper::IncludeMethods

  def printables
    render :json => ApplicationHelper.extract_key_value(
      Printable.all(:order => "created_at DESC"), :id, :name, params[:search])
  end

  def printable_templates
    render :json => ApplicationHelper.extract_key_value(
      PrintableTemplate.all(:order => :name), :id, :name, params[:search])
  end

  private

  def check_read_permission
    unless @sections.include?(AclRole::SECTIONS[AclRole::PRINTABLE])
      render :json => nil, :status => :forbidden
    end
  end

  def check_write_permission
    unless @sections_writable.include?(AclRole::SECTIONS[AclRole::PRINTABLE])
      render :json => nil, :status => :forbidden
    end
  end

  private

  def history_write(action, id, message)
    if @user
      AclHistory.create(
        :acl_user => @user,
        :acl_role => AclRole.find_by_name(AclRole::PRINTABLE),
        :action => action,
        :record_id => id,
        :message => message)
    end
  end

  def historify
    if @user
      if action_name == 'save'
        if not (params[:printable][:id] rescue nil).to_s.empty?
          history_write(AclHistory::ACTION_UPDATE,
            @entry.id, "1 IMPRESSÃO ATUALIZADA: #{@entry.to_s}")
        else
          history_write(AclHistory::ACTION_CREATE,
            @entry.id, "1 IMPRESSÃO CRIADA: #{@entry.to_s}")
        end
      elsif action_name == 'delete'
        if @entries.length == 1
          history_write(AclHistory::ACTION_DELETE, @ids.first.to_i,
            "1 IMPRESSÃO REMOVIDA: #{@entries.first}")
        elsif @entries.length > 1
          history_write(AclHistory::ACTION_DELETE, 0,
            "#{@entries.length} IMPRESSÕES REMOVIDAS: #{@entries.join(", ")}")
        end
      elsif action_name == 'delete_all'
        # TODO: improve verbosity
        str = "Texto=#{params[:search]}, Filtro=#{params[:filter]}"
        history_write(AclHistory::ACTION_DELETE, 0,
          "#{@affected} IMPRESSÕES REMOVIDAS A CRITÉRIO DE BUSCA: #{str}")
      end
    end
  end
end
