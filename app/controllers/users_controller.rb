class UsersController < ApplicationController

	def new
	end

	def create
    user = User.new(user_params)

    if params["summoner_name"]

    	request = "https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/#{params["summoner_name"]}?api_key=#{ENV['RIOT_KEY']}"
			response = HTTParty.get(request)

			response.parsed_response.each do |key, value|
				p key
				p value

				# If key is the same as summoner_name.downcase...
				user.summoner_id = value['id']
				user.summoner_icon = value['profileIconId']
			end

    else
    	p 'no summoner to find'
    	user.summoner = Summoner.new()
    end

    if user.save
      session[:user_id] = user.id
      redirect_to '/dashboard'
    else
      redirect_to '/signup'
    end		
	end

	private

	  def user_params
	    params.require(:user).permit(:name, :email, :password, :password_confirmation)
	  end

end
