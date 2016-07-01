var fs = require('fs');
var pgp = require("pg-promise")(/*options*/);
var db = pgp("postgres://zion:zion@localhost/maps");
var db_funcs = require('./GeoJSON_helper_funcs');
//var db = pgp("postgres://username:password@host:port/database");

exports.mapFileLocation = '../../ui/maps/';
exports.subRegionMapFileLocation = '../../ui/maps/*country*/regions/';

exports.initCityData = function() {
	return new Promise((resolve, reject) => {
		// reject and resolve are functions provided by the Promise
		// implementation. Call only one of them.

		// 1 or more rows
		db.func("init_city_zoom", [])
			.then(function (data) {
				return resolve(true);
			})
			.catch(function (error) {
				console.log(error);
				return reject("Couldn't initialize city data");
			});
	});
};


exports.createCountryAreaGEOJson = function(countryISO) {
	return new Promise((resolve, reject) => {
		// reject and resolve are functions provided by the Promise
		// implementation. Call only one of them.

		// 1 or more rows
		db.func("country_area_data_adm2_safe", [countryISO, true])
			.then(function (data) {

				var geoJSONArr = [];
				data.forEach(function(row, index, array)
				{
					geoJSONArr.push(db_funcs.getFeatureResult(row, "regionGeom", false));
				});
				var JSONFilePrefix = "";
				if (data.length > 0)
				{
					if (data[0]["admin1Name"] == null)
						JSONFilePrefix = "adm0";
					else if (data[0]["admin2Name"] == null)
						JSONFilePrefix = "adm1";
					else
						JSONFilePrefix = "adm2";
				}
				var GeoJSONFileName = countryISO.toLowerCase() + "." + JSONFilePrefix + ".geo.json";
				module.exports.deleteCountryAreaGEOJson(GeoJSONFileName);

				var finalJSON = db_funcs.getFeatureContainer(geoJSONArr);
				fs.writeFile(GeoJSONFileName, JSON.stringify(finalJSON), 'utf8', function(err)
				{
					if (err)
						return reject(err);
					else
						return resolve(JSONFilePrefix);
				});
			})
			.catch(function (error) {
				console.log("moo");
				console.log(error);
				return reject("No results for country " + countryISO);
			});
	});
};


exports.createPopulationGEOJson = function() {
	return new Promise((resolve, reject) => {
		// reject and resolve are functions provided by the Promise
		// implementation. Call only one of them.

		// 1 or more rows
		db.func("get_landingpage_cities", [])
			.then(function (data) {

				var geoJSONArr = [];
				data.forEach(function(row, index, array)
				{
					geoJSONArr.push(db_funcs.getFeatureResult(row, "", true));
				});
				var GEOJsonFileName = "landingpage.population.geo.json";
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
				console.log(error);
				return reject("No results for landing page population");
			});
	});
};


exports.getRegionPopulationGeoJSON = function(countryISO, admin2_ID) {
	return new Promise((resolve, reject) => {
		// reject and resolve are functions provided by the Promise
		// implementation. Call only one of them.
		
		// 1 or more rows
		db.func("city_data_adm3", [countryISO, admin2_ID])
			.then(function (data) {

				var geoJSONArr = [];
				data.forEach(function(row, index, array)
				{
					geoJSONArr.push(db_funcs.getFeatureResult(row, "", true));
				});

				var finalJSON = db_funcs.getFeatureContainer(geoJSONArr);
				return resolve(finalJSON);
			})
			.catch(function (error) {
				console.log(error);
				return reject("No results for landing page population");
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


exports.getParentRegionAdmin2IDs = function(countryISO) {
	return new Promise((resolve, reject) => {
		// 1 or more rows
		db.func("get_admin2_parent_ids", [countryISO])
			.then(function (data) {
				return resolve(data);
			})
			.catch(function (error) {
				console.log("moo");
				console.log(error);
				return reject("No results for country " + countryISO);
			});
	});
};


exports.getParentRegionAdmin1IDs = function(countryISO) {
	return new Promise((resolve, reject) => {
		// 1 or more rows
		db.func("get_admin1_parent_ids", [countryISO])
			.then(function (data) {
				return resolve(data);
			})
			.catch(function (error) {
				console.log("moo");
				console.log(error);
				return reject("No results for country " + countryISO);
			});
	});
};


exports.hasSubRegionAdmin1IDs = function(countryISO) {
	return new Promise((resolve, reject) => {
		// 1 or more rows
		db.func("has_admin1_ids", [countryISO])
			.then(function (data) {
				return resolve(data);
			})
			.catch(function (error) {
				console.log("moo");
				console.log(error);
				return reject("No results for country " + countryISO);
			});
	});
};


exports.getSubRegionGeometry = function(admin_level, countryISO, id) {
	return new Promise((resolve, reject) => {
		var db_func_name;
		var params_arr = [countryISO];
		if (admin_level == "admin3")
		{
			db_func_name = "region_area_data_adm2";
			params_arr.push(id);
		}
		else if (admin_level == "admin2")
		{
			db_func_name = "region_area_data_adm1";
			params_arr.push(id);
		}
		else if (admin_level == "admin1")
			db_func_name = "region_area_data_adm0";
		else if (admin_level == "country")
			db_func_name = "region_area_data_country";
		//console.log(params_arr);
		db.func(db_func_name, params_arr)
			.then(function (data) {
				return resolve(data);
			})
			.catch(function (error) {
				//console.log("moo");
				//console.log(error);
				return reject("No results for country " + countryISO);
			});
	});
};
