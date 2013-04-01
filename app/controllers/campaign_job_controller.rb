class CampaignJobController < ApplicationController
  before_filter :authenticate
  before_filter :check_read_permission
  before_filter :check_write_permission, :only => [ :save, :delete, :start, :stop ]
  after_filter :historify

  include SectionControllerHelper::IncludeMethods

  def test
    campaign_job = CampaignJob.find_by_id(params[:campaign_job_id])
    campaign = campaign_job.campaign unless campaign_job.nil?
    tested = campaign ? campaign.test(params[:email]) : false
    render :json => tested
  end

  def start
    @campaign_job = CampaignJob.find_by_id(params[:id])
    started = false
    started = @campaign_job.start unless @campaign_job.nil?

    render :text => { :success => started, :id => @campaign_job.id }.to_json,
           :status => :ok
  end

  def stop
    @campaign_job = CampaignJob.find_by_id(params[:id])
    stopped = false
    stopped = @campaign_job.stop unless @campaign_job.nil?

    render :text => { :success => stopped, :id => @campaign_job.id }.to_json,
           :status => :ok
  end

  private

  def check_read_permission
    unless @sections.include?(AclRole::SECTIONS[AclRole::CAMPAIGN_JOB])
      render :json => nil, :status => :forbidden
    end
  end

  def check_write_permission
    unless @sections_writable.include?(AclRole::SECTIONS[AclRole::CAMPAIGN_JOB])
      render :json => nil, :status => :forbidden
    end
  end

  def history_write(action, id, message)
    if @user
      AclHistory.create(
        :acl_user => @user,
        :acl_role => AclRole.find_by_name(AclRole::CAMPAIGN_JOB),
        :action => action,
        :record_id => id,
        :message => message)
    end
  end

  def historify
    if @user
      if action_name == 'save'
        if not (params[:campaign_job][:id] rescue nil).to_s.empty?
          history_write(AclHistory::ACTION_UPDATE,
            @entry.id, "1 DISPARO DE CAMPANHA ATUALIZADO: #{@entry.to_s}")
        else
          history_write(AclHistory::ACTION_CREATE,
            @entry.id, "1 DISPARO DE CAMPANHA CRIADO: #{@entry.to_s}")
        end
      elsif action_name == 'delete'
        if @entries.length == 1
          history_write(AclHistory::ACTION_DELETE, @ids.first.to_i,
            "1 DISPARO DE CAMPANHA REMOVIDO: #{@entries.first}")
        elsif @entries.length > 1
          history_write(AclHistory::ACTION_DELETE, 0,
            "#{@entries.length} DISPARO DE CAMPANHAS REMOVIDOS: #{@entries.join(", ")}")
        end
      elsif action_name == 'test'
       history_write(AclHistory::ACTION_CREATE, 0,
         "1 TESTE DE CAMPANHA REALIZADO: Email=#{params[:email]}")
      elsif action_name == 'start'
        history_write(AclHistory::ACTION_UPDATE, @campaign_job.id,
          "1 DISPARO DE CAMPANHA INICIADO: #{@campaign_job.to_s}")
      elsif action_name == 'stop'
        history_write(AclHistory::ACTION_CREATE, @campaign_job.id,
          "1 DISPARO DE CAMPANHA INTERROMPIDO: #{@campaign_job.to_s}")
      end
    end
  end
end
