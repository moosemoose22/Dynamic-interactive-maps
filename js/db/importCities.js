var fs = require('fs'); 
var parse = require('csv-parse');

var pgp = require("pg-promise")(/*options*/);
var db = pgp("postgres://zion:zion@localhost/maps");
var db_funcs = require('./db_funcs');

var csvData=[];

var cityPrefix = '../../cityData/';
var inputFile = cityPrefix + 'franceCities/outputNewFranceInseeWithLatLng10000.csv';
inputFile = cityPrefix + 'franceCities/outputNewFranceInseeWithLatLng.csv';
inputFile = cityPrefix + 'franceCities/outputNewFranceInseeWithLatLng1000to10000.csv';
var country_id = 'FRA';

inputFile = cityPrefix + 'spainCities/outputNewSpainIneWithLatLng1000To10000.csv';
inputFile = cityPrefix + 'spainCities/outputNewSpainIneWithLatLng.csv';
country_id = 'ESP';

inputFile = cityPrefix + 'andorra.csv';
country_id = 'AND';

inputFile = cityPrefix + 'monaco.csv';
country_id = 'MCO';

fs.createReadStream(inputFile)
.pipe(parse({delimiter: ','}))
.on('data', function(csvrow) {
	console.log(csvrow[0]);
	//do something with csvrow
	csvData.push(csvrow);
})
.on('end',function() {
	//Auvergne Rhône-Alpes,Isere,,Voiron,19988,45.362713,5.591349,default
	//Île-de-France,Paris,Paris,2229621,48.856614,2.3522219,default
	//Île-de-France,Yvelines,Villepreux,9975,48.8301019,2.005269,default
	//Euskadi,Araba,Kantauri Arabarra,Amurrio,10263,43.0518654,-3.0013109,default
	//Extremadura,Cáceres,Valle del Jerte,Tornavacas,1144,40.2540625,-5.6898468
	//Catalunya,Barcelona,El Baix Llobregat,Abrera,12071,41.5175266,1.9017802,default
	//Catalunya,Barcelona,Maresme,Arenys de Mar,15289,41.5797073,2.5508683,default
	console.log(csvData[0]);
	db.tx(function (t) {
		var queries = csvData.map(function (cityRow) {

			// Note that ST_MakePoint is longitude, latitude!!

			if (country_id == 'AND')
			{
				//Andorra la Vella,Andorra la Vella,20430,42.506317,1.521835,default
				return t.none("INSERT INTO cities(country_id, place_name, geometry, latitude, longitude, population, text_position) VALUES " +
					"('" + country_id + "', $2, ST_SetSRID(ST_MakePoint($5, $4),4326), $4, $5, $3, $6)", cityRow);
			}
			else if (country_id == 'MCO')
			{
				//Monaco,37831,43.7384,7.4246,default
				return t.none("INSERT INTO cities(country_id, place_name, geometry, latitude, longitude, population, text_position) VALUES " +
					"('" + country_id + "', $1, ST_SetSRID(ST_MakePoint($4, $3),4326), $3, $4, $2, $5)", cityRow);
			}
			else
			{
				return t.none("INSERT INTO cities(country_id, place_name, geometry, latitude, longitude, population, text_position) VALUES " +
					"('" + country_id + "', $4, ST_SetSRID(ST_MakePoint($7, $6),4326), $6, $7, $5, $8)", cityRow);
				//return t.none("INSERT INTO cities(country_id, place_name, geometry, latitude, longitude, population, align_name) VALUES " +
				//	"('" + country_id + "', $3, ST_SetSRID(ST_MakePoint($6, $5),4326), $5, $6, $4, $7)", cityRow);
			}
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

/*
CREATE TABLE cities (
	id				serial,
	country_id		char(3),
	admin3_id		integer,
	place_name		varchar(50) NOT NULL,
	geometry		geometry(MultiPolygon,4326),
	latitude		double precision,
	longitude		double precision,
	population		integer,
	align_name		varchar(7)	
*/
