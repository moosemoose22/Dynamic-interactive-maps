var pgp = require("pg-promise")(/*options*/);
var db = pgp("postgres://zion:zion@localhost/maps");
var db_funcs = require('./GeoJSON_helper_funcs');
//var db = pgp("postgres://username:password@host:port/database");


exports.getCountryData = function() {
	return new Promise((resolve, reject) => {
		// reject and resolve are functions provided by the Promise
		// implementation. Call only one of them.

		// 1 or more rows
		db.func("get_all_country_specs", [])
			.then(function (data) {
				return resolve(data);
			})
			.catch(function (error) {
				console.log(error);
				return reject("Couldn't initialize city data");
			});
	});
};

