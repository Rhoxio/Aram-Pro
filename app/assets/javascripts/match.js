$(document).ready(function(){
	$('#current-match').on('click', function(e){
		$.get( "/match/current?summoner_id=21915371", function( data ) {
			console.log(data)
		});
	})
})