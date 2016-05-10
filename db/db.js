var pgp = require("pg-promise")(/*options*/);
var db = pgp("postgres://zion:zion@localhost/maps");
//var db = pgp("postgres://username:password@host:port/database");

db.one("select ST_AsGeoJSON(wkb_geometry) as spacedata from fra_adm1 WHERE NAME_1='Picardie';", 123)
    .then(function (data) {
        console.log("DATA:", data.spacedata);
		process.exit();
    })
    .catch(function (error) {
        console.log("ERROR:", error);
		process.exit();
    });

