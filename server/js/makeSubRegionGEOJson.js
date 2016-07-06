var fs = require('fs');
var mkdirp = require('mkdirp');
var latinize = require('latinize');
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

function getPromisesArr(ids_arr, ID_elem_name, admin_level)
{
	var promises_arr = [];
	ids_arr.forEach(function(idObj, index, array)
	{
		var id = parseInt(idObj[ID_elem_name]);
		var adminKey = (admin_level == 0) ? "country" : "admin" + admin_level;
		promises_arr.push(
			json_funcs.getSubRegionGeometry(adminKey, countryISO, id)
		);
	});
	return promises_arr;
}

function parseSubRegionData(subregionDataArr, admin_level)
{
	subregionDataArr.forEach(function(subRegion, index, array)
	{
		// For some reason subRegion is occasionally an empty array and occasionally not an array
		if (!Array.isArray(subRegion) || (Array.isArray(subRegion) && subRegion.length == 0))
			return;

		var firstRow = subRegion[0];
		var fileLoc = json_funcs.subRegionMapFileLocation;

		var JSONFileNamePrefix = countryISO.toLowerCase();
		if (admin_level > 1)
			JSONFileNamePrefix += ("." + firstRow["admin1Name"])
		if (admin_level > 2)
			JSONFileNamePrefix += ("_" + firstRow["admin2Name"]);
		JSONFileNamePrefix = latinize(JSONFileNamePrefix.toLowerCase());
		JSONFileNamePrefix = JSONFileNamePrefix.replace(/ /g, "_");
		JSONFileNamePrefix = JSONFileNamePrefix.replace(/'/g, "_");

		var GeoJSONFileName = JSONFileNamePrefix + ".geo.json";
		var TopoJSONFileName = JSONFileNamePrefix + ".topo.json";

		console.log("Creating " + GeoJSONFileName);

		fileLoc = fileLoc.replace("*country*", countryISO.toLowerCase());
		mkdirp.sync(fileLoc);
		var geoJSONArr = [];
		subRegion.forEach(function(row, index, array)
		{
			geoJSONArr.push(geojson_container_funcs.getFeatureResult(row, "regionGeom", false));
		});
		//json_funcs.deleteCountryAreaGEOJson(GEOJsonFileName);

		var finalJSON = geojson_container_funcs.getFeatureContainer(geoJSONArr);
		(function(finalJSONParam, geoJSONFileParam, TopoJSONFileParam, json_funcsParam)
		{
			fs.writeFile(geoJSONFileParam, JSON.stringify(finalJSONParam), 'utf8', function(err)
			{
				if (err)
					console.log("File write error: " + err);
				else
				{
					const make_topojson = spawn('topojson', ['-o', TopoJSONFileParam, '--properties Cntry=countryName,regionname=admin1Name,subregionname=admin2Name,admin3name=admin3Name', "region=" + geoJSONFileParam]);

					make_topojson.stdout.on('data', (data) => {
						// Once we've created the topojson, let's delete the GEOJson that isn't being used in the final web product
						console.log("Try to delete " + geoJSONFileParam);
						//json_funcsParam.deleteCountryAreaGEOJson(geoJSONFileParam);
					});

					make_topojson.stderr.on('data', (data) => {
						;//console.log(`stderr: ${data}`);
					});
				}
			});
		})(finalJSON, fileLoc + GeoJSONFileName, fileLoc + TopoJSONFileName, json_funcs);
	});
}

// Get all country admin2 data
var subRegionIDPromise = json_funcs.getParentRegionAdmin2IDs(countryISO);
// GEOJsonFileName is the parameter that the promise passes to us
subRegionIDPromise.then(admin2ids => {
	// This topojson command creates the d3 map javascript file for the country
	var admin_level;
	if (admin2ids.length > 0)
	{
		admin_level = 3;
		var promises_arr = getPromisesArr(admin2ids, "admin2ID", admin_level);

		Promise.all(promises_arr).then(admin3data => {
			parseSubRegionData(admin3data, admin_level);
		});
	}
	else
	{
		var subRegionIDPromise2 = json_funcs.getParentRegionAdmin1IDs(countryISO);
		subRegionIDPromise2.then(admin1ids => {
			if (admin1ids.length > 0)
			{
				admin_level = 2;
				var promises_arr = getPromisesArr(admin2ids, "admin1ID", admin_level);

				Promise.all(promises_arr).then(admin1data => {
					parseSubRegionData(admin1data, admin_level);
				});
			}
			else
			{
				var subRegionIDPromise3 = json_funcs.hasSubRegionAdmin1IDs(countryISO);
				subRegionIDPromise3.then(hasCountryIDs => {
					var admin_level;
					if (hasCountryIDs[0]["hasadmin1ID"])
						admin_level = 1;
					else
						admin_level = 0;
					var promises_arr = getPromisesArr(hasCountryIDs, "hasadmin1ID", admin_level);

					Promise.all(promises_arr).then(admin0data => {
						parseSubRegionData(admin0data, admin_level);
					});
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
