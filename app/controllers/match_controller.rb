class MatchController < ApplicationController
  respond_to :json, :html

  def get_one
    if params[:id] && current_user

      match = Match.find_by(match_id:params[:id])

      respond_to do |format|
        format.json{render :json => match, :include =>[:champions => {:include => :championbase}] }
      end 

    else

      if !current_user
        error = {error: "User not logged in."}
      elsif !params[:id]
        error = {error: "Param not specified"}
      else
        error = {error: "Error occured."}
      end

      respond_to do |format|
        format.json{render :json => error }
      end 

    end
  end

  def create
  end

  def current_match

    if params[:summoner_id]

      current_match = RiotAPI.get_current_match(params[:summoner_id])

      if current_match.instance_of?(Match)
        new_match = Match.build_from_current_match(current_match, current_user)

        respond_to do |format|
          format.json{render :json => new_match, :include =>[:champions => {:include => :championbase}] }
        end 
      else
        # current_match holds the HTTP error hash to be passed to the front.
        respond_to do |format|
          format.json{render :json => current_match}
        end
      end 
    else
      respond_to do |format|
        format.json{render :json => {error: 'No summoner id.'} }
      end   
    end

  end

  def recent_matches
    if params[:summoner_id]

      recent_arams = RiotAPI.get_recent_matches(params[:summoner_id])

      ap recent_arams

      if recent_arams.is_a?(Array)
        all_matches = Match.build_from_recent_matches(recent_arams, current_user)

        respond_to do |format|
          format.json{render :json => all_matches, :include =>[:champions => {:include => :championbase}]}
        end
      else
        # recent_arams holds the HTTP error hash to be passed to the front.
        respond_to do |format|
          format.json{render :json => recent_arams}
        end
      end
      
    else
      #There was some kind of error. 
      respond_to do |format|
        format.json{render :json => {error: "No id param provided."}}
      end
    end 
  end

end
