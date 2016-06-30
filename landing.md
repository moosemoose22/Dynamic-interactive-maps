1) Download data for a country from http://gadm.org

2) Install postgres 9.5 with postGIS extensions  
http://trac.osgeo.org/postgis/wiki/UsersWikiPostGIS22UbuntuPGSQL95Apt  
Note that on Ubuntu 16 I think that postgres 9.5 is already in the apititude repository.  
No need to add repository keys.  
Please note that in the instructions above it tells you to create a different postgres user.  
Do that first and install postGIS as that user.

3) Import the database you downloaded from gadm.org  
Here's an example importing Spain:  
ogr2ogr -f "PostgreSQL" PG:"dbname=mydbname user=*user*" ESP_adm.gdb

