exports.getFeatureResult = function(result, spatialcolName, isCity) {
	var props = new Object;
	var crsobj = {
		"type" : "name",
		"properties" : {
			"name" : "urn:ogc:def:crs:EPSG:6.3:4326"
		}
	};
	//builds feature properties from database columns
	for (var k in result) {
		if (result.hasOwnProperty(k))
		{
			var nm = "" + k;
			if (k != spatialcolName && result[k])
				props[nm] = result[k];
		}
	}

	var geometryContent;
	if (isCity)
	{
		geometryContent = {
		   "type": "Point",
		   "coordinates":  [ result.latitude, result.longitude ]
		};
	}
	else
		geometryContent = JSON.parse(result[spatialcolName]);
	return {
		type : "Feature",
		//crs : crsobj,
		properties : props,
		geometry : geometryContent
	};
};

exports.getFeatureContainer = function(resultArr)
{
	return {
		"type": "FeatureCollection",
		"features": resultArr
	};
};
