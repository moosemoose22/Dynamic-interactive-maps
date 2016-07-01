CREATE OR REPLACE FUNCTION get_admin2_parent_ids(country_iso char(3))
RETURNS TABLE (
	"admin2ID"  integer) AS $$
DECLARE
	result_count integer;
BEGIN
	SELECT count(place_name) INTO result_count
	FROM admin3regions
	where admin2_id in
	(
		SELECT id
		FROM admin2regions WHERE admin1_id IN
		(
			SELECT id FROM admin1regions WHERE country_id = country_iso
		)
	);

	IF result_count = 0 THEN 
		RAISE NOTICE 'No parent admin2';
		RETURN;
	ELSE
		RETURN QUERY (SELECT id FROM admin2regions WHERE admin1_id in (select id from admin1regions where country_id = country_iso));
	END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_admin1_parent_ids(country_iso char(3))
RETURNS TABLE (
	"admin1ID"  integer) AS $$
DECLARE
	result_count integer;
BEGIN
	SELECT count(place_name) INTO result_count
	FROM admin2regions
	WHERE admin1_id IN
	(
		SELECT admin1regions.id FROM admin1regions WHERE country_id = country_iso
	);
	IF result_count = 0 THEN 
		RAISE NOTICE 'No parent admin1';
		RETURN;
	ELSE
		RETURN QUERY (SELECT admin1regions.id FROM admin1regions WHERE country_id = country_iso);
	END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION has_admin1_ids(country_iso char(3))
RETURNS TABLE (
	"hasadmin1ID"  boolean) AS $$
DECLARE
	result_count integer;
BEGIN
	SELECT count(place_name) INTO result_count
	FROM admin1regions
	WHERE country_id = country_iso;

	If result_count = 0 then
		RETURN QUERY (SELECT FALSE);
	ELSE
		RETURN QUERY (SELECT TRUE);
	END IF;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION region_area_data_country(country_iso char(3))
RETURNS TABLE (
	"countryName"  varchar,
	"regionGeom"   text) AS $$
DECLARE
	result_count integer;
BEGIN
	RETURN QUERY SELECT countries.place_name as "countryName", ST_AsGEOJSON(countries.geometry) AS "regionGeom"
	FROM countries
	WHERE countries.id = country_iso;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION region_area_data_adm0(country_iso char(3))
RETURNS TABLE (
	"countryName"  varchar,
	"regionGeom"   text) AS $$
DECLARE
	result_count integer;
BEGIN
	RETURN QUERY (
		SELECT countries.place_name as "countryName", ST_AsGEOJSON(admin1regions.geometry) AS "regionGeom"
		FROM countries
		INNER JOIN admin1regions ON countries.id = admin1regions.country_id
		WHERE countries.id = country_iso
	);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION region_area_data_adm1(country_iso char(3), admin1ID integer)
RETURNS TABLE (
	"countryName"  varchar,
	"regionGeom"   text,
	"admin1Name"   varchar) AS $$
DECLARE
	result_count integer;
BEGIN
	RETURN QUERY (
		SELECT countries.place_name as "countryName", ST_AsGEOJSON(admin2regions.geometry) AS "regionGeom",
		admin1regions.place_name as "admin1Name"
		FROM countries
		INNER JOIN admin1regions ON countries.id = admin1regions.country_id
		INNER JOIN admin2regions ON admin2regions.admin1_id = admin1regions.id
		WHERE countries.id = country_iso and admin1regions.id = admin1ID
	);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION region_area_data_adm2(country_iso char(3), admin2ID int)
RETURNS TABLE (
	"countryName"  varchar,
	"regionGeom"   text,
	"admin1Name"   varchar,
	"admin2Name"   varchar,
	"admin3Name"   varchar) AS $$
BEGIN
	RETURN QUERY
	(
		SELECT countries.place_name as "countryName", ST_AsGEOJSON(admin3regions.geometry) AS "regionGeom",
		admin1regions.place_name as "admin1Name", admin2regions.place_name as "admin2Name", admin3regions.place_name as "admin3Name"
		FROM countries
		INNER JOIN admin1regions ON countries.id = admin1regions.country_id
		INNER JOIN admin2regions ON admin2regions.admin1_id = admin1regions.id
		INNER JOIN admin3regions ON admin3regions.admin2_id = admin2regions.id
		WHERE countries.id = country_iso and admin2regions.id = admin2ID
	);
END;
$$ LANGUAGE plpgsql;
