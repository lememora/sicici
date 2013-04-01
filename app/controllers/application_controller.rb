# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  DEFAULT_PAGE_NUMBER = 0
  DEFAULT_PAGE_SIZE = 25
  DEFAULT_SORT_DIR = 'ASC'

  helper :all # include all helpers, all the time
  ## protect_from_forgery # See ActionController::RequestForgeryProtection for details

  def initializer
    @user = nil
    @sections = []
    @sections_writable = []
  end

  protected

  def authenticate
    authenticate_or_request_with_http_basic do |username, password| 
      authenticated, @user = AclUser.authenticate(username, password)
      if authenticated and @user
        @sections = APP_CONFIG["sections"] & @user.sections_allowed
        @sections_writable = APP_CONFIG["sections"] & @user.sections_allowed(writable=true)
        if session[:authenticated_username].nil?
          AclHistory.create(
            :acl_user => @user,
            :acl_role => AclRole.find_by_name(AclRole::AUTHENTICATION),
            :action => AclHistory::ACTION_RESTORE,
            :record_id => @user.id,
            :message => "1 USUÁRIO AUTENTICADO: #{@user.to_s}")
          session[:authenticated_username] = username
        end
      else
        if @user
          AclHistory.create(
            :acl_user => @user,
            :acl_role => AclRole.find_by_name(AclRole::AUTHENTICATION),
            :action => AclHistory::ACTION_RESTORE,
            :record_id => @user.id,
            :message => "1 USUÁRIO COM AUTENTICAÇÃO NEGADA: #{@user.to_s}")
        end
      end
      authenticated
    end
  end

  def authenticated?
    not session[:authenticated_username].to_s.empty?
  end
end
