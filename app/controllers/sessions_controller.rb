class SessionsController < ApplicationController
  def create
    user = User.find_or_create_from_auth_hash(request.env['omniauth.auth'])
    session[:user_id] = user.id
    redirect_to root_url, notice: 'ログインしました'
  end

  def destroy
    # reset_session
    session[:user_id] = nil
    redirect_to root_url, notice: 'ログアウトしました'
  end
end
