class HistoryController < ApplicationController
  before_filter :authenticate
  before_filter :check_read_permission
  before_filter :check_write_permission, :only => [ :save, :delete ]

  def list
    @results = AclHistory.ample(params)
    @total = AclHistory.count_(params)

    render :text => { :success => true, :results => @results, :total => @total }.to_json, 
           :status => :ok
  end

  def quick
    render :text => AclHistory.quick(params).to_json, 
           :status => :ok
  end

  def load
    @history = AclHistory.find_by_id(params[:id])

    if @history
      render :text => { :success => true, :result => @history }.to_json, 
             :status => :ok
    else
      render :text => { :success => false }.to_json, 
             :status => :not_found
    end
  end

  private

  def check_read_permission
    unless @sections.include?(AclRole::SECTIONS[AclRole::HISTORY])
      render :json => nil, :status => :forbidden
    end
  end

  def check_write_permission
    unless @sections_writable.include?(AclRole::SECTIONS[AclRole::HISTORY])
      render :json => nil, :status => :forbidden
    end
  end
end
