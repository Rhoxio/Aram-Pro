class DashboardController < ApplicationController
	def show

		if logged_in?
			@user = current_user
			@champions = Championbase.all
			
			# p 'User is logged in'
			# request = "https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/Azorius07?api_key=#{ENV['RIOT_KEY']}"
			# response = HTTParty.get(request)
			# p response.parsed_response

		else
			 p 'error'
		end

	end
end
