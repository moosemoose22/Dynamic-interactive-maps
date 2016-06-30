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
psql -U zion maps < [sql/createTables.sql](sql/createTables.sql)  
Note that the user is zion and the database is called maps.  
maps contains postGIS and all the tables needed for this application.

5) Import the country data.  
a) First, you need to load some sql helper into the database.  
psql -U zion maps < [sql/migrate.sql](sql/migrate.sql)  
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
There are detailed instructions on how to get city data [here](https://github.com/moosemoose22/Visual-history-of-Occitania/blob/master/landing.md#now-we-need-to-get-the-city-data)
