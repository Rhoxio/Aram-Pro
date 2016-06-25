class SummonersController < ApplicationController
	def new
	end

	def create
	end

	def get
		request = "https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/#{params["summoner_name"]}?api_key=#{ENV['RIOT_KEY']}"
		response = HTTParty.get(request)
		p response.parsed_response

		if !response.parsed_response.key?('status')

			@summoner = Summoner.new()
			new_summoner = response.parsed_response

			@summoner.name = new_summoner.keys[0]
			@summoner.summoner_id = new_summoner.values[0]['id']
			@summoner.icon_id = new_summoner.values[0]['profileIconId']
			@summoner.level = new_summoner.values[0]['summonerLevel']

			if @summoner.save
				session[:summoner_id] = @summoner.summoner_id
				# @user = {name: @summoner.name}
				redirect_to '/dashboard'
			else
				redirect_to '/'
			end			

		else

			redirect_to '/'

		end




	end
end
