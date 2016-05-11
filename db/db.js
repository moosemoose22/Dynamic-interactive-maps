var pgp = require("pg-promise")(/*options*/);
var db = pgp("postgres://zion:zion@localhost/maps");
//var db = pgp("postgres://username:password@host:port/database");

var db_query = 
	"SELECT countries.place_name as \"countryName\", admin1Regions.place_name as \"admin1Name\", " +
	"admin2Regions.place_name as \"admin2Name\", ST_AsGeoJSON(admin2Regions.geometry) as \"admin2Geom\" " +
	"FROM countries " +
	"INNER JOIN admin1Regions " +
	"ON countries.id = admin1Regions.country_id " +
	"INNER JOIN admin2Regions ON admin2Regions.admin1_id = admin1Regions.id";

db.any(db_query, 123)
	.then(function (data) {
		data.forEach(function(row, index, array)
		{
			//console.log(row);
			console.log(row.countryName + "," + row.admin1Name + "," + row.admin2Name);
			console.log(row.admin2Geom);
		});
		process.exit();
	})
	.catch(function (error) {
		console.log("ERROR:", error);
		process.exit();
	});
