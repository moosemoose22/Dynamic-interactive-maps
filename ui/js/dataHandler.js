this.dataHandler = new function()
{
	var countryData = {};
	this.initCountries = function(responseData)
	{
		responseData.response.forEach(function(countryElem, index, array)
		{
			countryData[countryElem.countryISO.toLowerCase()] = {
				id: countryElem.countryISO.toLowerCase(),
				name: countryElem.countryName,
				adminLevel: countryElem.countryAdminDivision,
				loaded: false
			};
		});
	}

	this.getAllCountryData = function()
	{
		return countryData;
	}

	this.getCountryData = function(countryISO)
	{
		var countryISOConverted = countryISO.toLowerCase();
		if (countryISOConverted in countryData)
			return countryData[countryISOConverted];
		else
			return null;
	}

	this.countryAreaDataHasLoaded = function(countryISO, val)
	{
		countryData[countryISO].loaded = val;
	}

	this.allCountriesHaveLoaded = function()
	{
		for (var ISO in countryData)
		{
			if (!countryData[ISO].loaded)
				return false;
		}
		return true;
	}
};
