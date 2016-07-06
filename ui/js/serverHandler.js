var serverHandler = new function()
{
	this.requestData = function(action)
	{
		var JSONRequest = $.getJSON( "/request", {"action": action}, function() {
			console.log( "success" );
		});
		return JSONRequest;
	}
};
