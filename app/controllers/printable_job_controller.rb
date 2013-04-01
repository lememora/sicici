class PrintableJobController < ApplicationController
  before_filter :authenticate
  before_filter :check_read_permission
  before_filter :check_write_permission, :only => [ :save, :delete ]
  after_filter :historify

  include SectionControllerHelper::IncludeMethods

  def download
    @printable_job = PrintableJob.find_by_id(params[:id], :include => :printable)
    name = Array.new
    name<< @printable_job.printable.name
    name<< @printable_job.created_at.strftime("%a, %d %b %Y %H:%M:%S %z")
    name = ApplicationHelper.generate_permalink(name.join('_'))
    data = ApplicationHelper.public_data_read('printable_job', params[:id])
    send_data data, :filename => "#{name}.pdf", 
                    :disposition => "attachment", 
                    ##:type => "application/pdf; charset=iso-8859-1"
                    :type => "application/pdf; charset=utf-8"
  end

  private

  def check_read_permission
    unless @sections.include?(AclRole::SECTIONS[AclRole::PRINTABLE_JOB])
      render :json => nil, :status => :forbidden
    end
  end

  def check_write_permission
    unless @sections_writable.include?(AclRole::SECTIONS[AclRole::PRINTABLE_JOB])
      render :json => nil, :status => :forbidden
    end
  end

  def history_write(action, id, message)
    if @user
      AclHistory.create(
        :acl_user => @user,
        :acl_role => AclRole.find_by_name(AclRole::PRINTABLE_JOB),
        :action => action,
        :record_id => id,
        :message => message)
    end
  end

  def historify
    if @user
      if action_name == 'save'
        if not (params[:printable_job][:id] rescue nil).to_s.empty?
          history_write(AclHistory::ACTION_UPDATE,
            @entry.id, "1 COMPILADOR DE IMPRESSÃO ATUALIZADO: #{@entry.to_s}")
        else
          history_write(AclHistory::ACTION_CREATE,
            @entry.id, "1 COMPILADOR DE IMPRESSÃO CRIADO: #{@entry.to_s}")
        end
      elsif action_name == 'delete'
        if @entries.length == 1
          history_write(AclHistory::ACTION_DELETE, @ids.first.to_i,
            "1 COMPILADOR DE IMPRESSÃO REMOVIDO: #{@entries.first}")
        elsif @entries.length > 1
          history_write(AclHistory::ACTION_DELETE, 0,
            "#{@entries.length} COMPILADOR DE IMPRESSÕES REMOVIDOS: #{@entries.join(", ")}")
        end
      elsif action_name == 'download'
        history_write(AclHistory::ACTION_CREATE, @printable_job.id,
          "1 DOWNLOAD DE IMPRESSÃO REALIZADO: #{@printable_job.to_s}")
      end
    end
  end
end
