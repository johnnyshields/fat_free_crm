# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class PasswordsController < Devise::PasswordsController
  respond_to :html
  append_view_path 'app/views/devise'

  def create
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])
    # @user.deliver_password_reset_instructions!

    if resource.errors.empty?
      flash[:notice] = t(:msg_pwd_instructions_sent)
      # set_flash_message(:notice, :send_instructions) if is_navigational_format?
      redirect_to root_url
      # respond_with resource, :location => new_session_path(resource_name)
    else

      # Redirect to custom page instead of displaying errors
      # redirect_to my_custom_page_path
      Rails.logger.info(resource.errors.inspect)
      flash[:notice] = t(:msg_email_not_found)
      redirect_to root_url
    end
  end
end
