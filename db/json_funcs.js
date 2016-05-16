var fs = require('fs');
var pgp = require("pg-promise")(/*options*/);
var db = pgp("postgres://zion:zion@localhost/maps");
var db_funcs = require('./db_funcs');
//var db = pgp("postgres://username:password@host:port/database");


exports.createCountryAreaGEOJson = function(countryISO) {
	return new Promise((resolve, reject) => {
		// reject and resolve are functions provided by the Promise
		// implementation. Call only one of them.

		var db_query =
			"SELECT countries.place_name as \"countryName\", admin1Regions.place_name as \"admin1Name\", " +
			"admin2Regions.place_name as \"admin2Name\", ST_AsGEOJSON(admin2Regions.geometry) AS \"admin2Geom\" " +
			"FROM countries " +
			"INNER JOIN admin1Regions " +
			"ON countries.id = admin1Regions.country_id " +
			"INNER JOIN admin2Regions ON admin2Regions.admin1_id = admin1Regions.id " +
			"WHERE countries.id = '" + countryISO + "';";

		// 1 or more rows
		db.many(db_query, 123)
			.then(function (data) {
				
				var geoJSONArr = [];
				data.forEach(function(row, index, array)
				{
					geoJSONArr.push(db_funcs.getFeatureResult(row, "admin2Geom"));
				});
				var GEOJsonFileName = countryISO.toLowerCase() + ".adm2.geo.json";
				module.exports.deleteCountryAreaGEOJson(GEOJsonFileName);

				var finalJSON = db_funcs.getFeatureContainer(geoJSONArr);
				fs.writeFile(GEOJsonFileName, JSON.stringify(finalJSON), 'utf8', function(err)
				{
					if (err)
						return reject(err);
					else
						return resolve(GEOJsonFileName);
				});
			})
			.catch(function (error) {
				return reject("No results for country " + countryISO);
			});
	});
};

exports.deleteCountryAreaGEOJson = function(GEOJsonFileName) {
	// Delete GEOJson file
	try {
		// Query the entry
		stats = fs.lstatSync(GEOJsonFileName);
		fs.unlinkSync(GEOJsonFileName);
	}
	catch (e) {
		; // Do nothing
	}
}
