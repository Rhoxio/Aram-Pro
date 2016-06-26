var Champion = React.createClass({
  render: function() {
    return (
      <div className="champion">
        <img src={this.props.image}/>
        <h2 className="championName">
          {this.props.name}
        </h2>
      </div>
    );
  }
});

var ChampionList = React.createClass({
  propTypes: {
    summoner_id: React.PropTypes.number
  },

  getInitialState: function(){
    return{champions: [], match: []}
  },

  componentDidMount: function(){
    // It seems as if I can also just go a $.get here to grab current match data. Will need to set it in a handleclick
    // function or something.
    $.post( "/match/current?summoner_id="+this.props.summoner_id, function( data ) {
      // console.log(data)
      this.setState({champions: data.champions}, function(){
        // console.log(this.state.champions)
      })
    }.bind(this));
  },

  getCurrentGame: function(){
    $.post( "/match/current?summoner_id="+this.props.summoner_id, function( data ) {
      // console.log(data)

      this.setState({champions: data.champions}, function(){
        // console.log(this.state.champions)
      })
    }.bind(this));

  },  

  render: function() {
    var championNodes = this.state.champions.map(function(champion) {

      return (
        <Champion image={champion.image} name={champion.name} key={champion.id}>
        </Champion>
      );
    });
    return (
      <div className="championList">
        {championNodes}
      </div>
    );
  }

});
