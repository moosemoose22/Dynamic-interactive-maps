# Development notes on Dynamic-interactive-maps  
These notes are to help me get this project to beta  

psql -U postgres -d postgres -a -f createTables.sql  
psql -U zion -d maps < createTables.sql  

ogrinfo FRA_adm1.shp -geom=YES -sql "SELECT NAME_1, SHAPE FROM FRA_adm1" | grep "NAME_1 (String)" | sed 's/  NAME_1 (String) = //g' | sed "s/'/_/g" | sed "s/ /_/g" | awk '{printf "INSERT INTO countries (name) VALUES (\x27"$0"\x27);\n"}'

http://gis.stackexchange.com/questions/19432/why-does-postgis-installation-not-create-a-template-postgis

sudo su postgres

Didn't do any of these on Ubuntu 16:
createdb template_postgis
createlang plpgsql template_postgis
psql -d template_postgis -f /usr/share/postgresql/9.5/contrib/postgis-2.2/postgis.sql
psql -d template_postgis -f /usr/share/postgresql/9.5/contrib/postgis-2.2/spatial_ref_sys.sql


CREATE DATABASE maps TEMPLATE template_postgis;

https://trac.osgeo.org/postgis/wiki/UsersWikiNewbieAddgeometrycolumn

http://trac.osgeo.org/postgis/wiki/UsersWikiPostGIS22UbuntuPGSQL95Apt



psql -U zion -d maps < migrate.sql  
psql -U zion -d maps < countryAreaGEOJson.sql  
psql -U zion -d maps < createTables.sql  


##### Install pg so nodeJS can connect to postgres
npm install pg --save

##### Install express
sudo npm install -g express-generator


https://github.com/brianc/node-postgres

http://mherman.org/blog/2015/02/12/postgresql-and-nodejs/#.VzCjutwrLCK

http://www.marcusoft.net/2014/02/mnb-express.html




http://expressjs.com/en/guide/database-integration.html#postgres

ogr2ogr -f PostgreSQL PG:dbname=maps FRA_adm.gdb

psql -U zion -d maps < migrate.sql


Once everything's set up, you can create admin2 topojson by running this:  
nodejs makeCountryAreaGEOJson.js FRA

##### Cities
npm install csv  

