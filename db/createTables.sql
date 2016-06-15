
CREATE TABLE countries (
	id				char(3),
	place_name		varchar NOT NULL,
	geometry		geometry(MultiPolygon,4326),
	shape_length	double precision,
	shape_area		double precision,
	population		integer
);
CREATE TABLE admin1Regions (
	id				serial,
	country_id		char(3),
	place_name		varchar(50) NOT NULL,
	geometry		geometry(MultiPolygon,4326),
	shape_length	double precision,
	shape_area		double precision,
	population		integer
);
CREATE TABLE admin2Regions (
	id				serial,
	admin1_id		integer,
	place_name		varchar(50) NOT NULL,
	geometry		geometry(MultiPolygon,4326),
	shape_length	double precision,
	shape_area		double precision,
	population		integer
);
CREATE TABLE admin3Regions (
	id				serial,
	admin2_id		integer,
	place_name		varchar(50) NOT NULL,
	geometry		geometry(MultiPolygon,4326),
	shape_length	double precision,
	shape_area		double precision,
	population		integer
);
CREATE TABLE cities (
	id				serial,
	country_id		char(3),
	admin3_id		integer,
	place_name		varchar(50) NOT NULL,
	geometry		geometry(Point,4326),
	latitude		double precision,
	longitude		double precision,
	population		integer,
	align_name		varchar(7)	
);
CREATE TABLE languages (
	id				serial,
	lang_name		varchar(40) NOT NULL
);
CREATE TABLE lang_region (
	id				serial,
	table_name		varchar(25) NOT NULL,
	lang_id			integer,
	region_id		integer
);
