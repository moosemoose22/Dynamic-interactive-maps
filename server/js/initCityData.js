var json_funcs = require('./GeoJSON_funcs');

// Get all country admin2 data
var initCityDataPromise = json_funcs.initCityData();
// GEOJsonFileName is the parameter that the promise passes to us
initCityDataPromise.then(result => {
	console.log("Successfully initialized city data");
	process.exit(0);
})
.catch(err => {
	console.log(err);
	console.log("Failed to initialize city data");
	process.exit(-1);
});
