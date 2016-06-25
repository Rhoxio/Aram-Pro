class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception



  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  # Want this to be available in other files.
  helper_method :current_user

  def authorize
    redirect_to '/login' unless current_user
  end

  def logged_in?
    !!session[:user_id]
  end
  helper_method :logged_in?

end
