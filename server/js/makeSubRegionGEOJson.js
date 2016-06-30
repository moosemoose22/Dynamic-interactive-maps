var fs = require('fs');
var json_funcs = require('./GeoJSON_funcs');
var geojson_container_funcs = require('./GeoJSON_helper_funcs');

const spawn = require('child_process').spawn;

// Note that the ID for countries is the country ISO
var countryISO = process.argv[2];
if (!countryISO)
{
	console.log("Error: please set a country ISO to generate GEO JSON. Such as: FRA (france), ESP (Spain), AND (Andorra)");
	process.exit();
}

// Get all country admin2 data
var subRegionIDPromise = json_funcs.getParentRegionAdmin2IDs(countryISO);
// GEOJsonFileName is the parameter that the promise passes to us
subRegionIDPromise.then(admin2ids => {
	// This topojson command creates the d3 map javascript file for the country
	var subregion;
	if (admin2ids.length > 0)
	{
		subregion = "admin3";
		var geoJSONArr = [];
		var regionGeomPromise;
		var promises_arr = [];
		admin2ids.forEach(function(idObj, index, array)
		{
			var id = parseInt(idObj["admin2ID"]);
			promises_arr.push(json_funcs.getSubRegionGeometry(subregion, countryISO, id));
		});

		Promise.all(promises_arr).then(admin3data => {
			//console.log(admin3data);
			var firstRow = admin3data[0][0];
			console.log(firstRow);
			console.log(" ");
			var fileLoc = json_funcs.subRegionMapFileLocation;
			var GeoJSONFileName = firstRow["countryName"] + "." + firstRow["admin1Name"] + "_" + firstRow["admin2Name"] + ".geo.json";
			console.log(GeoJSONFileName);
			fileLoc = fileLoc.replace("*country*", firstRow["countryName"]);
			if (!fs.existsSync(fileLoc))
				fs.mkdirSync(fileLoc);
			
			admin3data.forEach(function(row, index, array)
			{
				geoJSONArr.push(db_funcs.getFeatureResult(row, "regiongeom", true));
			});
			//json_funcs.deleteCountryAreaGEOJson(GEOJsonFileName);

			var finalJSON = geojson_container_funcs.getFeatureContainer(geoJSONArr);
			console.log(fileLoc + GEOJsonFileName);
			fs.writeFile(fileLoc + GEOJsonFileName, JSON.stringify(finalJSON), 'utf8', function(err)
			{
				if (err)
					console.log(err);
			});
		});
	}
	else
	{
		var subRegionIDPromise2 = json_funcs.getParentRegionAdmin1IDs(countryISO);
		subRegionIDPromise2.then(admin1ids => {
			if (admin1ids.length > 0)
			{
				subregion = "admin2";
			}
			else
			{
				var subRegionIDPromise3 = json_funcs.hasSubRegionAdmin1IDs(countryISO);
				subRegionIDPromise3.then(hasCountryIDs => {
					if (hasCountryIDs)
						subregion = "admin1";
					else
						subregion = "country";
				})
				.catch(err => {
					console.log(err);
					process.exit(-1);
				});
			}
		})
		.catch(err => {
			console.log(err);
			process.exit(-1);
		});
	}
/*
	const make_topojson = spawn('topojson', ['--simplify-proportion', '.25', '-o', rootDir + '/' + countryISO.toLowerCase() + ".adm2.topo.json", '--properties Cntry=ISO,regionname=NAME_1,regionID=ID_1,subregionname=NAME_2,subregionID=ID_2,region=HASC_2', "admin2=" + GEOJsonFileName]);

	make_topojson.stdout.on('data', (data) => {
		console.log("Created topojson for country " + countryISO);
		// Once we've created the topojson, let's delete the GEOJson that isn't being used in the final web product
		json_funcs.deleteCountryAreaGEOJson(GEOJsonFileName);
		process.exit(0);
	});

	make_topojson.stderr.on('data', (data) => {
		console.log(`stderr: ${data}`);
		process.exit(0);
	});
*/
})
.catch(err => {
	console.log(err);
	process.exit(-1);
});
