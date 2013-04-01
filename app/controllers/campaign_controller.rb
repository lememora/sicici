class CampaignController < ApplicationController
  before_filter :authenticate
  before_filter :check_read_permission
  before_filter :check_write_permission, :only => [ :save, :delete ]
  after_filter :historify

  include SectionControllerHelper::IncludeMethods

  #def list
  #  @results = Campaign.ample({:conditions => { :hidden => false })
  #  @total = Campaign.count_()
#
#    render :text => { :success => true, 
#                      :results => @results, 
#                      :total => @total }.to_json, :status => :ok
#  end

  def save
    if (params[:campaign] || {})[:id].to_i > 0
      @campaign= Campaign.find_by_id(params[:campaign][:id])
      @campaign.update_attributes_(params)
    else
      @campaign= Campaign.new
      @campaign.populate(params)
      @campaign.save
    end

    if params[:campaign_image] and @campaign.hash_id
      ApplicationHelper.public_data_upload(
        params[:campaign_image], :campaign_image, @campaign.hash_id)
    end
    if params[:campaign_image_delete] and @campaign.hash_id
      ApplicationHelper.public_data_delete(:campaign_image, @campaign.hash_id)
    end

    if @campaign.errors.length == 0
      render :text => { :success => true, :id => @campaign.id }.to_json, 
             :status => :created
    else
      render :text => { :success => false, :errors => @campaign.errors }.to_json, 
             :status => :unprocessable_entity
    end
  end

  def campaigns
    render :json => ApplicationHelper.extract_key_value(
      Campaign.all(:conditions => { :deleted => 0 }, :order => "created_at DESC"), :id, :name, params[:search])
  end

  def campaign_templates
    render :json => ApplicationHelper.extract_key_value(
      CampaignTemplate.all(:order => :name), :id, :name, params[:search])
  end

  def preview
    campaign = Campaign.find_by_id(params[:id])
    @data = campaign.attributes
    render :template => "campaign_template/#{campaign.campaign_template.permalink}"
  end

  private

  def check_read_permission
    unless @sections.include?(AclRole::SECTIONS[AclRole::CAMPAIGN])
      render :json => nil, :status => :forbidden
    end
  end

  def check_write_permission
    unless @sections_writable.include?(AclRole::SECTIONS[AclRole::CAMPAIGN])
      render :json => nil, :status => :forbidden
    end
  end

  def history_write(action, id, message)
    if @user
      AclHistory.create(
        :acl_user => @user,
        :acl_role => AclRole.find_by_name(AclRole::CAMPAIGN),
        :action => action,
        :record_id => id,
        :message => message)
    end
  end

  def historify
    if @user
      if action_name == 'save'
        if not (params[:campaign][:id] rescue nil).to_s.empty?
          history_write(AclHistory::ACTION_UPDATE,
            @campaign.id, "1 CAMPANHA ATUALIZADA: #{@campaign.to_s}")
        else
          history_write(AclHistory::ACTION_CREATE,
            @campaign.id, "1 CAMPANHA CRIADA: #{@campaign.to_s}")
        end
      elsif action_name == 'delete'
        if @entries.length == 1
          history_write(AclHistory::ACTION_DELETE, @ids.first.to_i,
            "1 CAMPANHA REMOVIDA: #{@entries.first}")
        elsif @entries.length > 1
          history_write(AclHistory::ACTION_DELETE, 0,
            "#{@entries.length} CAMPANHAS REMOVIDAS: #{@entries.join(", ")}")
        end
      elsif action_name == 'delete_all'
        # TODO: improve verbosity
        str = "Texto=#{params[:search]}, Filtro=#{params[:filter]}"
        history_write(AclHistory::ACTION_DELETE, 0,
          "#{@affected} CAMPANHAS REMOVIDAS A CRITÉRIO DE BUSCA: #{str}")
      end
    end
  end
end
