var fs = require('fs');
var json_funcs = require('./GeoJSON_funcs');

const spawn = require('child_process').spawn;

// Note that the ID for countries is the country ISO
var countryISO = process.argv[2];
if (!countryISO)
{
	console.log("Error: please set a country ISO to generate GEO JSON. Such as: FRA (france), ESP (Spain), AND (Andorra)");
	process.exit();
}

// Get all country admin2 data
var GeoJSONFileNamePromise = json_funcs.createCountryAreaGEOJson(countryISO);
// GEOJsonFileName is the parameter that the promise passes to us
GeoJSONFileNamePromise.then(JSONFilePrefix => {
	// This topojson command creates the d3 map javascript file for the country
	var rootDir = json_funcs.mapFileLocation + countryISO.toLowerCase();
	if (!fs.existsSync(rootDir))
		fs.mkdirSync(rootDir);

	//,regionID=ID_1,subregionID=ID_2,region=HASC_2
	var GeoJSONProps = "ISO=countryISO,Cntry=countryName";
	if (JSONFilePrefix == "adm2")
		GeoJSONProps += ",regionname=admin1Name,subregionname=admin2Name";
	else if (JSONFilePrefix == "adm1")
		GeoJSONProps += ",regionname=admin1Name";
	const make_topojson = spawn('topojson', ['--simplify-proportion', '.25', '-o', rootDir + '/' + countryISO.toLowerCase() + "." + JSONFilePrefix + ".topo.json", '--properties', GeoJSONProps, "admin2=" + countryISO.toLowerCase() + "." + JSONFilePrefix + ".geo.json"]);

	make_topojson.stdout.on('data', (data) => {
		console.log("Created topojson for country " + countryISO);
		// Once we've created the topojson, let's delete the GEOJson that isn't being used in the final web product
		//json_funcs.deleteCountryAreaGEOJson(countryISO.toLowerCase() + "." + JSONFilePrefix + ".geo.json");
		process.exit(0);
	});

	make_topojson.stderr.on('data', (data) => {
		console.log(`stderr: ${data}`);
		process.exit(0);
	});
})
.catch(err => {
	console.log(err);
	process.exit(0);
});
