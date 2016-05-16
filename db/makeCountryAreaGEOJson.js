var json_funcs = require('./json_funcs');

const spawn = require('child_process').spawn;


// Note that the ID for countries is the country ISO
var countryISO = process.argv[2];
if (!countryISO)
{
	console.log("Error: please set a country ISO to generate GEO JSON. Such as: FRA (france), ESP (Spain), AND (Andorra)");
	process.exit();
}

var GEOJsonFileNamePromise = json_funcs.createCountryAreaGEOJson(countryISO);
GEOJsonFileNamePromise.then(GEOJsonFileName => {
	var topojson_cmd = "topojson --simplify-proportion .25 " +
						"-o " + countryISO + ".adm2.topo.json " +
						"--properties Cntry=ISO,regionname=NAME_1,regionID=ID_1,subregionname=NAME_2,subregionID=ID_2,region=HASC_2 " +
						"admin2=" + GEOJsonFileName;
	const make_topojson = spawn('topojson', ['--simplify-proportion', '.25', '-o', countryISO.toLowerCase() + ".adm2.topo.json", '--properties Cntry=ISO,regionname=NAME_1,regionID=ID_1,subregionname=NAME_2,subregionID=ID_2,region=HASC_2', "admin2=" + GEOJsonFileName]);

	make_topojson.stdout.on('data', (data) => {
		console.log("Created topojson for country " + countryISO);
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
