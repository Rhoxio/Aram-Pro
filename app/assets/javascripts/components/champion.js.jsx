var Champion = React.createClass({

  revealParentElements:function(){
    $('.bottom-team').removeClass('hidden').addClass('show')
    $('.top-team').removeClass('hidden').addClass('show')
    $('.mid-separator').removeClass('hidden').addClass('show')
  },

  componentDidMount: function(){
    this.revealParentElements()
  },

  render: function() {

    // These tag divs need keys at some point...

    var champion =  this.props.champion

    var riotTags = this.props.riot_tags.map(function(tag, i) {

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
        case "Assassin":
            return <div className='tag tag-red columns'>Assassin</div>
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

    var items = this.props.items.map(function(item){
      // Filter all Porosnax out
      if(item.item_identifier != '2052'){
        var uniqueIdentifer = champion.id + "-" + item.id

        return (
          <ItemEntry identifier={uniqueIdentifer} item={item}></ItemEntry>
        ) 
      }

    })

    if(champion.team == "200"){
      // Need to  designate the side they are on before render.
      var topSide = 'right purple-team '
    } else{
      var topSide = 'left blue-team '
    }

    return (
      <div className={topSide+"champion large-12 columns"}>
        <img className="large-2 champ-image columns" src={this.props.image}/>
        <h2 className="champion-name large-4 columns">
          {this.props.name}
        </h2>

         <div className='items columns large-10'>
          {items}
         </div>         
      </div>
    );
  }
});

// Item
var ItemEntry = React.createClass({

  handleMouseOver: function(event){
    var element = $(".tooltip-"+this.props.identifier)
    // console.log(element)
    $(element).removeClass('hidden')
    $(element).addClass('show') 
  },

  handleMouseOut: function(event){
    var element = $(".tooltip-"+this.props.identifier)
    // console.log(element)
    $(element).removeClass('show')
    $(element).addClass('hidden') 
  },  

  render:function(){

    return(
      <div onMouseOver={this.handleMouseOver} onMouseLeave={this.handleMouseOut} className='columns item-container'>
        <a href="#" className='item item-small columns'>
          <img src={this.props.item.image}/>
        </a>

        <div className={"tooltip-"+this.props.identifier+" hidden item-tooltip"}>
          <h5>{this.props.item.name}</h5>
          <h5>Cost: {this.props.item.gold.total}</h5>
          <h5>Effect: {this.props.item.short_description}</h5>
        </div>
      </div>      
    )
  }
})

// Match Button
var MatchButton = React.createClass({
  handleGet: function(){
    this.props.getMatch(this.props.match_id)
  },
  
  render: function(){
    return(
      <div>
        <button className='large-1 columns match-button' key={this.props.match_id} data-match={this.props.match_id} onClick={this.handleGet}>Match {this.props.index + 1}</button>
      </div>

    )
  }
})

var MatchupIndicator = React.createClass({
 render: function(){
    return(
      <div>
        <div className='matchup'>
          <div className='matchup-indicator point-left favorable'>
            Some quick text.
          </div>
        </div>
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
      return{champions: [], matches: this.props.matches}
    } else {
      return{champions: [], matches: []}
    }
  },

  componentDidMount: function(){
    $.post( "/match/current?summoner_id="+this.props.summoner_id, function( data ) {
      if(!data.hasOwnProperty('error')){
        this.setState({champions: data.champions}, function(){})
      } else {
        console.log('No current game.')
      }
    }.bind(this));
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

  getRecentGames: function(){
    $.post( "/match/recent?summoner_id="+this.props.summoner_id, function( data ) {
      // console.log(data)
      this.setState({matches: data})
      console.log(this.state.matches)
    }.bind(this));

  },  

  getMatch: function(match){
    $.get("/match/"+match, function(data){
      console.log(data)
      this.setState({champions: data.champions}, function(){})
    }.bind(this))
  },

  render: function() {

    if(this.state.champions){
      var topSideChampionNodes = this.state.champions.map(function(champion) {
        if(champion.team === "200"){
          return (
            <Champion champion={champion} items={champion.items} riot_tags={champion.championbase.riot_tags} other_tags={champion.championbase.other_tags} image={champion.image} name={champion.name} key={champion.id}>
            </Champion>
          );
        }
      });

      var bottomSideChampionNodes = this.state.champions.map(function(champion) {
        if(champion.team === "100"){
          return (
            <Champion champion={champion} key={champion.championbase.champion_identifer} items={champion.items} riot_tags={champion.championbase.riot_tags} other_tags={champion.championbase.other_tags} image={champion.image} name={champion.name} key={champion.id}>
            </Champion>
          );
        }
      });

      var matchups = [<MatchupIndicator></MatchupIndicator>]

    } else{
      var topSideChampionNodes = []
      var bottomSideChampionNodes = []
      var matchups = []
    }

    var matchButtons = this.state.matches.map(function(match, i){
      return (
        <MatchButton getMatch={this.getMatch} key={match.match_id} index={i} match_id={match.match_id}></MatchButton> 
      )
    }.bind(this))

    return (
      <div className="team-container large-12 inline-list columns">
        <button className="simple-button button large-2" onClick={this.getCurrentGame}>Get Current Game</button>
        <button className="simple-button button large-2" onClick={this.getRecentGames}>Get Recent Games</button>
        <div className="match-container large-12 inline-list columns">
          {matchButtons}
        </div>

        <div>
          <div className="bottom-team team large-5 inline-list columns hidden">
            {bottomSideChampionNodes}
          </div>

          <div className='mid-separator large-2 columns hidden'>
            {matchups}
          </div>

          <div className="top-team team large-5 inline-list columns hidden">
            {topSideChampionNodes}
          </div>
        </div> 
      </div>     
    );
  }

});
