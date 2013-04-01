class AdminController < ApplicationController
  before_filter :authenticate

  def index
    render :template => "layouts/admin"
  end

  def logout
    session[:authenticated_username] = nil
    redirect_to "http://#{rand.to_s.split(/\./)[1]}:logout@#{request.env["HTTP_HOST"]}"
  end
end
