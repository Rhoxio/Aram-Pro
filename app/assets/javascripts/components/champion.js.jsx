var Champion = React.createClass({
  propTypes: {
    summoner_id: React.PropTypes.string
  },

  getInitialState: function(){
    // It seems as if I can also just go a $.get here to grab current match data. Will need to set it in a handleclick
    // function or something.
    $.post( "/match/current?summoner_id="+this.props.summoner_id, function( data ) {
      console.log(data)
    });

    // return { currentChampion: this.props.champions[0], currentIndex: 0 }
  },

  componentDidMount: function(){
    // this.rotate = setInterval(this.nextChampion, 10)
  },

  nextChampion: function(){
    if(this.state.currentIndex < this.props.champions.length - 1){
      this.setState({currentChampion: this.props.champions[this.state.currentIndex + 1], currentIndex: this.state.currentIndex + 1})
    }
  },

  resetChampions: function(){
    this.setState({currentChampion: this.props.champions[0], currentIndex: 0})
  },

  render: function() {
    var champs = []
    for (var i = 0; i < this.props.champions.length; i++){
      champs.push(<div>Text: {this.props.champions[i].name}</div>)
    }

    return (
      <div>
        {champs}    
      </div>
    );
  }
  
});
