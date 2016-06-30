# How to use this repository to create a dynamic interactive map  
1) Download data for a country from http://gadm.org

2) Install postgres 9.5 with postGIS extensions  
http://trac.osgeo.org/postgis/wiki/UsersWikiPostGIS22UbuntuPGSQL95Apt  
Note that on Ubuntu 16 I think that postgres 9.5 is already in the apititude repository.  
No need to add repository keys.  
Please note that in the instructions above it tells you to create a new postgres database instead of using the built-in database called "postgres".  
Do that first-- I called mine maps-- and install postGIS into that database.

3) Import the database you downloaded from gadm.org  
Here's an example importing Spain:  
ogr2ogr -f "PostgreSQL" PG:"dbname=mydbname user=*user*" ESP_adm.gdb

4) Create the tables in the database that will house the gadm data.  
Here's how I did it:  
psql -U zion maps < [server/sql/createTables.sql](server/sql/createTables.sql)  
Note that the user is zion and the database is called maps.  
maps contains postGIS and all the tables needed for this application.

5) Import the country data.  
a) First, you need to load some sql helper into the database.  
psql -U zion maps < [server/sql/migrate.sql](server/sql/migrate.sql)  
b) Run the database migration functions  
Log into the database command-line:  
psql -U zion maps  
If you're adding either Spain, France, Andorra, or Monaco, you can run 
select add_france();  
select add_spain();  
select add_andorra();  
select add_monaco();  
For other countries, you can run  
select add_all_country_area_data(country_iso),  
replace country_iso with the 3-letter country iso.

6) Import city data  
There are detailed instructions on how to get city data [here](https://github.com/moosemoose22/Visual-history-of-Occitania/blob/master/landing.md#now-we-need-to-get-the-city-data).  
To import the city data from these pre-made csv files, run  
nodejs [server/js/db/importCities.js](server/js/db/importCities.js) *country_iso*  
Please note that unless you're importing cities for Andorra or Monaco, you'll have to modify [server/js/db/importCities.js](server/js/db/importCities.js) to import the correct file.  

7) Load required database functions  
psql -U zion maps < [server/sql/utils.sql](server/sql/utils.sql)  
psql -U zion maps < [server/sql/cities.sql](server/sql/cities.sql)  

8) Initialize city data, such as capitals and city zoom levels.  
Note that this has been tailored for France, Andorra, Spain, and Monaco.  
nodejs [server/js/initCityData.js](server/js/initCityData.js) FRA  

9) Create web-ready topojson for a country in the db  
For France, for example, run:  
nodejs [server/js/makeCountryAreaGEOJson.js](server/js/makeCountryAreaGEOJson.js) FRA  
Other built-in countries include:  
Spain (ESP), Andorra (AND), and Monaco (MCO)  
