exports.getFeatureResult = function(result, spatialcolName) {
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
			if (k != spatialcolName)
				props[nm] = result[k];
		}
	}

	return {
		type : "Feature",
		//crs : crsobj,
		properties : props,
		geometry : JSON.parse(result.admin2Geom)
	};
};

exports.getFeatureContainer = function(resultArr)
{
	return {
		"type": "FeatureCollection",
		"features": resultArr
	};
};
