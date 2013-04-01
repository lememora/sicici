class AclPermission < ActiveRecord::Base
  belongs_to :acl_user
  belongs_to :acl_role

  before_create :destroy_duplicate

  private

  def destroy_duplicate
    permission = AclPermission.first(:conditions => { 
      :acl_user_id => self.acl_user_id, 
      :acl_role_id => self.acl_role_id })
    permission.destroy unless permission.nil?
  end
end
