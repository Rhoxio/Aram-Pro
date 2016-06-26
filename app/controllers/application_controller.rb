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

  # class Champion
  #   def self.process_full(champion_list)
  #     champion_bases = Championbase.all()

  #     champion_list.each do |champion|
  #       p champion
  #       champion_base = champion_bases.find {|c| c.champion_id == champion.champion_id}
  #       champion.name = champion_base.name
  #       champion.
  #     end

  #     champion_list
  #   end
  # end

end
