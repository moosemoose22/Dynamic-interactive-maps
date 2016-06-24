var fs = require('fs'); 
var parse = require('csv-parse');

var pgp = require("pg-promise")(/*options*/);
var db = pgp("postgres://zion:zion@localhost/maps");
var db_funcs = require('../db/db_funcs');

var csvData=[];
var country_id = 'ESP';
var inputFile='spainCities/outputNewSpainIneWithLatLng.csv';
//var inputFile='spainCities/outputNewSpainIneWithLatLng1000To10000.csv';
fs.createReadStream(inputFile)
.pipe(parse({delimiter: ','}))
.on('data', function(csvrow) {
	console.log(csvrow[0]);
	//do something with csvrow
	csvData.push(csvrow);
})
.on('end',function() {
	//Catalunya,Barcelona,El Baix Llobregat,Abrera,12071,41.5175266,1.9017802,default
	//Catalunya,Barcelona,Maresme,Arenys de Mar,15289,41.5797073,2.5508683,default
	console.log(csvData[0]);
	db.tx(function (t) {
		var queries = csvData.map(function (cityRow) {
			return t.none("UPDATE admin3regions set place_name = $3 WHERE place_name like 'n.a.%' and id in " +
			"(select admin3_id from cities where place_name = $4)", cityRow);
		});
		return t.batch(queries);
	})
	.then(function (data) {
		// SUCCESS
		// data = array of undefined
		console.log("Success!");
	})
	.catch(function (error) {
		// ERROR;
		console.log(error);
	});
});
