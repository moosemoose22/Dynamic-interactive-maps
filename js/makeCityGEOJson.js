var json_funcs = require('./json_funcs');

const spawn = require('child_process').spawn;

// Get all country admin2 data
var GEOJsonFileNamePromise = json_funcs.createPopulationGEOJson();
// GEOJsonFileName is the parameter that the promise passes to us
GEOJsonFileNamePromise.then(GEOJsonFileName => {
	// This topojson command creates the d3 map javascript file for the country
	//,textPosition=TextPosition
	const make_topojson = spawn('topojson', ['-o', "landingpage.population.topo.json", '--properties', 'cityname=cityname,capital=capital,population=citypopulation,regionname=admin1name,subregionname=admin2name,admin3name=admin3name,textPosition=textposition', "population=" + GEOJsonFileName]);

	make_topojson.stdout.on('data', (data) => {
		console.log("Created topojson for landing page population");
		// Once we've created the topojson, let's delete the GEOJson that isn't being used in the final web product
		json_funcs.deleteCountryAreaGEOJson(GEOJsonFileName);
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
