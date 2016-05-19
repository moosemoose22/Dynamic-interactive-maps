var fs = require('fs');
var pgp = require("pg-promise")(/*options*/);
var db = pgp("postgres://zion:zion@localhost/maps");
var db_funcs = require('./db_funcs');
//var db = pgp("postgres://username:password@host:port/database");


exports.createCountryAreaGEOJson = function(countryISO) {
	return new Promise((resolve, reject) => {
		// reject and resolve are functions provided by the Promise
		// implementation. Call only one of them.


		// 1 or more rows
		db.func("country_area_data_adm2_or_best_available", [countryISO, true])
			.then(function (data) {
				
				var geoJSONArr = [];
				data.forEach(function(row, index, array)
				{
					geoJSONArr.push(db_funcs.getFeatureResult(row, "regionGeom"));
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
				console.log("moo");
				console.log(error);
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
