var express = require("express");
var ui_server_funcs = require('../server/js/dataForUIServer');
var app = express();

/* serves main page */
app.get("/", function(req, res) {
	res.sendFile(__dirname + '/index.html');
});

app.get("/request", function(req, res) {
	console.log("In UIServer request here");
	console.log(req.query);

	if (req.query.action == "getCountryData")
	{
		var GeoJSONFileNamePromise = ui_server_funcs.getCountryData();
		// GEOJsonFileName is the parameter that the promise passes to us
		GeoJSONFileNamePromise.then(countryData => {
			res.json({"response": countryData});
		})
		.catch(err => {
			console.log(err);
			res.json({"response": false});
		});
	}	
});

/*
app.post("/", function(req, res) { 
	console.log(req.body);
	res.send("Moo");
	res.send("OK");
});
*/
/* serves all the static files */
app.get(/^(.+)$/, function(req, res){ 
	console.log('static file request : ' + req.params[0]);
	res.sendFile( __dirname + req.params[0]); 
});

app.use(express.static('js'));

var port = process.env.PORT || 5000;
	app.listen(port, function() {
	console.log("Listening on " + port);
});
