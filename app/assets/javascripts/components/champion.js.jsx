var Champion = React.createClass({

  render: function() {

    var riotTags = this.props.riot_tags.map(function(tag) {

      switch(tag) {
        case "Tank":
            return <div className='tag tag-orange columns'>Tank</div>
            break;
        case "Fighter":
            return <div className='tag tag-yellow columns'>Fighter</div>
            break;
        case "Slayer":
            return <div className='tag tag-red columns'>Slayer</div>
            break;
        case "Mage":
            return <div className='tag tag-blue columns'>Mage</div>
            break;
        case "Controller":
            return <div className='tag tag-purple columns'>Controller</div>
            break;
        case "Marksman":
            return <div className='tag tag-green columns'>Marksman</div>
            break;
        case "Support":
            return <div className='tag tag-lt-green columns'>Support</div>
            break;                                                            
        default:
            return <div className='tag tag-teal columns'>None</div>
      }     

    });

    var otherTags = this.props.other_tags.map(function(tag) {

      switch(tag) {
        case "god":
            return <div className='other-tag tag-yellow columns'>God</div>
            break;
        case "very_strong":
            return <div className='other-tag tag-green columns'>Very Strong</div>
            break;
        case "strong":
            return <div className='other-tag tag-red columns'>Strong</div>
            break;
        case "Average":
            return <div className='other-tag tag-blue columns'>Average</div>
            break;
        case "below_average":
            return <div className='other-tag tag-orange columns'>Below Average</div>
            break;
        case "weak":
            return <div className='other-tag tag-purple columns'>Weak</div>
            break;
        case "heavy_cc":
            return <div className='other-tag tag-purple columns'>Heavy CC</div>
            break;
        case "true_damage":
            return <div className='other-tag tag-red columns'>True Damage</div>
            break;  
        case "self_healing":
            return <div className='other-tag tag-green columns'>Self Healing</div>
            break;   
        case "healer":
            return <div className='other-tag tag-lt-green columns'>Healer</div>
            break; 
        case "aoe_cc":
            return <div className='other-tag tag-purple columns'>AOE CC</div>
            break;
        case "waveclear":
            return <div className='other-tag tag-blue columns'>Waveclear</div>
            break;
        case "preserving_ult":
            return <div className='other-tag tag-yellow columns'>Preserving Ult</div>
            break;
        case "poke":
            return <div className='other-tag tag-red columns'>Poke</div>
            break;
        case "initiator":
            return <div className='other-tag tag-orange columns'>Initiator</div>
            break;  
        case "mobile":
            return <div className='other-tag tag-red columns'>Mobile</div>
            break;
        case "traps":
            return <div className='other-tag tag-green columns'>Traps</div>
            break;
        case "good_scaling":
            return <div className='other-tag tag-red columns'>Scales Well</div>
            break; 
        case "early_power":
            return <div className='other-tag tag-red columns'>Powerful Early</div>
            break;
        case "stealth":
            return <div className='other-tag tag-purple columns'>Stealth</div>
            break; 
        case "strong_level_6":
            return <div className='other-tag tag-blue columns'>Level 6 Power</div>
            break;                                                                                                                                                                                                                          
        default:
            return <div></div>
      }     

    });    

    return (
      <div className="champion">
        <img src={this.props.image}/>
        <h2 className="championName">
          {this.props.name}
        </h2>
         <div className='riot-tags large-12 columns'>
          {riotTags}
         </div>
         <div className='other-tags large-12 columns'>
         {otherTags}
         </div>         
      </div>
    );
  }
});

// Match Button
var MatchButton = React.createClass({
  handleGet: function(){
    this.props.getMatch(this.props.match_id)
  },
  
  render: function(){
    return(
      <div>
        <button key={this.props.match_id} data-match={this.props.match_id} onClick={this.handleGet}>{this.props.match_id}</button>
      </div>

    )
  }
})

var ChampionList = React.createClass({
  propTypes: {
    summoner_id: React.PropTypes.number,
    matches: React.PropTypes.array
  },

  getInitialState: function(){

    if(this.props.matches.length > 1){
      return{champions: [], match: this.props.matches, selected_match: this.props.matches[0]}
    } else {
      return{champions: [], match: [], selected_match: undefined}
    }
  },

  componentDidMount: function(){
    // It seems as if I can also just go a $.get here to grab current match data. Will need to set it in a handleclick
    // function or something.
    $.post( "/match/current?summoner_id="+this.props.summoner_id, function( data ) {
        if(!data.hasOwnProperty('error')){
          this.setState({champions: data.champions}, function(){})
        } else {
          console.log('No current game.')
        }
    }.bind(this));
    console.log(this.props)
  },

  getCurrentGame: function(){
    $.post( "/match/current?summoner_id="+this.props.summoner_id, function( data ) {
        if(!data.hasOwnProperty('error')){
          this.setState({champions: data.champions}, function(){})
        } else {
          console.log('No current game.')
        }
    }.bind(this));

  },

  getMatch: function(match){
    console.log("It sent it.")

    $.get("/match/"+match, function(data){
      this.setState({champions: data.champions}, function(){})
    }.bind(this))
  },

  render: function() {

    if(this.state.champions){
      var topSideChampionNodes = this.state.champions.map(function(champion) {
        if(champion.team === "200"){
          return (
            <Champion riot_tags={champion.championbase.riot_tags} other_tags={champion.championbase.other_tags} image={champion.image} name={champion.name} key={champion.id}>
            </Champion>
          );
        }
      });

      var bottomSideChampionNodes = this.state.champions.map(function(champion) {
        if(champion.team === "100"){
          return (
            <Champion riot_tags={champion.championbase.riot_tags} other_tags={champion.championbase.other_tags} image={champion.image} name={champion.name} key={champion.id}>
            </Champion>
          );
        }
      });
    } else{
      var topSideChampionNodes = []
      var bottomSideChampionNodes = []
    }

    var matchButtons = this.props.matches.map(function(match){
      return (
        <MatchButton getMatch={this.getMatch} key={match.match_id} match_id={match.match_id}></MatchButton> 
      )
    }.bind(this))

    return (
    <div className="team-container">
      <button onClick={this.getCurrentGame}>Get Current Game</button>
      <div className="match-container">
        {matchButtons}
      </div>

      <div>
        <div className="bottom-team large-6 columns">
          <div>
            {bottomSideChampionNodes}
          </div>
        </div>

        <div className="top-team large-6 columns">
          <div>
            {topSideChampionNodes}
          </div>
        </div>
      </div> 
    </div>     
    );
  }

});
