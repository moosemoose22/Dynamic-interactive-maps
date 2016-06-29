
CREATE TABLE countries (
	id				char(3),
	place_name		varchar NOT NULL,
	geometry		geometry(MultiPolygon,4326),
	shape_length	double precision,
	shape_area		double precision,
	population		integer
);
CREATE TABLE admin1regions (
	id				serial,
	country_id		char(3),
	place_name		varchar(50) NOT NULL,
	geometry		geometry(MultiPolygon,4326),
	shape_length	double precision,
	shape_area		double precision,
	population		integer
);
CREATE TABLE admin2regions (
	id				serial,
	admin1_id		integer,
	place_name		varchar(50) NOT NULL,
	geometry		geometry(MultiPolygon,4326),
	shape_length	double precision,
	shape_area		double precision,
	population		integer
);
CREATE TABLE admin3regions (
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
	country_id_no_admin1	char(3),
	admin1_id_no_admin2		integer,
	admin2_id_no_admin3		integer,
	admin3_id		integer,
	place_name		varchar(50) NOT NULL,
	geometry		geometry(Point,4326),
	latitude		double precision,
	longitude		double precision,
	population		integer,
	capital			boolean,
	admin_level		integer,
	text_position	varchar(7),
	min_zoom		integer
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
