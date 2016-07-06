// Variable declarations
var transitionEndName;
var currentRegion, currentFullRegion;
var currentLeftOffset, currentTopOffset, currentScaling;

// Convert coordinates in topojson file to screen coordinates
function getLargeMapCoords(mapPoints, position)
{
	var XCoord = 0, YCoord = 0;
	position = position ? position : "topleft";
	if (position == "topleft")
	{
		XCoord = d3.min(mapPoints.map(function(array) {
			return array[0];
		}));
		YCoord = d3.max(mapPoints.map(function(array) {
			return array[1];
		}));
	}
	else if (position == "bottomright")
	{
		XCoord = d3.max(mapPoints.map(function(array) {
			return array[0];
		}));
		YCoord = d3.min(mapPoints.map(function(array) {
			return array[1];
		}));
	}
	return [XCoord, YCoord];
}

// Open region detail window when clicking on region on map
var windowManager = new function()
{
	this.openRegionWindow = function(data)
	{
		var mapCountry = data.properties.ISO.toLowerCase();
		var storedCountryData = dataHandler.getCountryData(mapCountry);

		calledRegionOpen = true;
		var id = mapCountry + "_" + data.properties.regionname + "_" + data.properties.subregionname;
		id = convertID(id);
		currentRegion = data.properties.regionname;
		currentFullRegion = id;

		// Stolen from http://bl.ocks.org/mbostock/4707858
		var screenWidth = window.innerWidth - 20;
		var screenHeight = window.innerHeight - 20;
		var b = path.bounds(data),
			s = .95 / Math.max((b[1][0] - b[0][0]) / screenWidth, (b[1][1] - b[0][1]) / screenHeight),
			t = [(screenWidth - s * (b[1][0] + b[0][0])) / 2, (screenHeight - s * (b[1][1] + b[0][1])) / 2];
		currentLeftOffset = t[0];
		currentTopOffset = t[1];
		currentScaling = s;

		if (mapCountry == "esp" || mapCountry == "fra" || mapCountry == "and")
		{
			var regionName, subRegionName;
			// If the smallest admin division is admin 0 or admin 1, we just show the whole country on the big map
			// For a country that has just admin1 areas, such as Andorra, a user can see those divisions when
			// s/he clicks on the country
			if (storedCountryData.adminLevel == "admin0" || storedCountryData.adminLevel == "admin1")
				;
			else if (storedCountryData.adminLevel == "admin3")
			{
				regionName = convertID(latinize(data.properties.regionname).toLowerCase());
				subRegionName = convertID(latinize(data.properties.subregionname).toLowerCase());
			}

			// Once we're done reading the data from the topoJSON file, we add cities
			// This needs to be done in a callback since reading the file is asynchronous
			var regionCallback = regionFuncs.addCities;
			regionFuncs.init(mapCountry, regionName, subRegionName, regionCallback);
		}

		var countryAbbrev = data.properties.ISO;
		$("#openRegionBG").html('<g id="regionZoomAnimationContainer"></g>');

		// Clone current region and attach it to regionZoomAnimationContainer
		$( "#" + currentFullRegion )
			.clone()
			.prop('id', currentFullRegion + "_copy" )
			.removeClass("region" )
			.addClass("regionLarge" )
			.addClass(countryAbbrev) // add country-specific background to region zoom svg
			.appendTo( "#regionZoomAnimationContainer" );

		$("#openRegionBG")
			.css("z-index", "100");

		// Here we simultaneously scale and move the region
		// so that the most western and northern points are near 0,0.
		// Note that the animation happens because of the openWindowStyle animation CSS
		// defined in occitaniaStyles.css
		// Also: we need to use translate below instead of changing css's left and top.
		// Translate has much faster animations, especially in Chrome
		// .2 is quasi-offset for stroke-width
		$("#openRegionBG")
			.css("animation-duration", "1.5s")
			.css("-webkit-animation-duration", "1.5s")
			.css("transform", "translate(" + currentLeftOffset + "px," + currentTopOffset + "px) scale(" + currentScaling + ")");
		var closeButtonWidth = $("#closeButtonObj").width();
		$("#closeButtonObj").css("display", "inline").css("right", closeButtonWidth);
	}

	// Called when user clicks on close button on top right
	// of region detail window
	this.closeWindowPrelim = function()
	{
		regionFuncs.reset();
		calledRegionPrelimClose = true;
		$(".openRegionStyle").css("z-index", "-1").css("visibility", "hidden");
		$("#regionZoomAnimationContainer").css("visibility", "visible");
		$("#openRegionBG").css("background-color", "rgba(0,0,0,0.0)");
		$("#closeButtonObj").css("display", "none");
	}
	this.closeWindow = function()
	{
		calledRegionClose = true;
		$("#openRegionBG")
			.css("transform", "scale(1)")
			.css("transform", "translate(0px," + ($(window).scrollTop() * -1) + "px) scale(1)");
		$("#closeButtonObj").css("display", "none");
	}
}
