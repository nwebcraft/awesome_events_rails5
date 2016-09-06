class UsersController < ApplicationController
  before_action :authenticate

  def retire
  end

  def destroy
    if current_user.destroy
      reset_session
      redirect_to root_path, notice: t('message.notice.retired')
    else
      render :retire
    end
  end
end
