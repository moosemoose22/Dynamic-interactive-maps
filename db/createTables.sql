
CREATE TABLE countries (
	id				serial,
	name			varchar NOT NULL,
	geometry		geometry(MultiPolygon,4326),
	shape_length	double precision,
	shape_area		double precision,
	population		integer
);
CREATE TABLE admin1Regions (
	id				serial,
	country_id		integer,
	name			varchar(50) NOT NULL,
	geometry		geometry(MultiPolygon,4326),
	shape_length	double precision,
	shape_area		double precision,
	population		integer
);
CREATE TABLE admin2Regions (
	id				serial,
	country_id		integer,
	admin1_id		integer,
	name			varchar(50) NOT NULL,
	geometry		geometry(MultiPolygon,4326),
	shape_length	double precision,
	shape_area		double precision,
	population		integer
);
CREATE TABLE admin3Regions (
	id				serial,
	country_id		integer,
	admin1_id		integer,
	admin2_id		integer,
	name			varchar(50) NOT NULL,
	geometry		geometry(MultiPolygon,4326),
	shape_length	double precision,
	shape_area		double precision,
	population		integer
);
CREATE TABLE cities (
	id				serial,
	country_id		integer,
	admin1_id		integer,
	admin2_id		integer,
	admin3_id		integer,
	name			varchar(50) NOT NULL,
	lat				double precision,
	long			double precision,
	population		integer
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
