class DashboardController < ApplicationController
	def show
		@user = current_user
		request = "https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/Azorius07?api_key=#{ENV['RIOT_KEY']}"
		response = HTTParty.get(request)
		p response.parsed_response
	end
end
