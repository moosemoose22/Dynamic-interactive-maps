# Dynamic-interactive-maps
A map generation system to allow storage, editing, and viewing of various data associated with places in the world. The focus for now will be on France and Spain.

### Goals
Here's a demo of a dynamic interactive map  
http://orent.info/timeline/  
The goal is to put all the map data in a database.  
Geometries:  
That means admin 0, admin2, and admin3 geometries, as well as city location data.  
Data:  
City population  
Once all the d3 topojson is generated from a database, we can:  
1) Fix incorrect data and re-generate  
2) Add other data-- such as GDP-- and regenerate. This makes the map so much more powerful as a presentation tool.  

### You may need to install the following to use this  
##### Install pg so nodeJS can connect to postgres
npm install pg --save

##### Install express
sudo npm install -g express-generator

### Further documentation
[landing.md](landing.md) 
