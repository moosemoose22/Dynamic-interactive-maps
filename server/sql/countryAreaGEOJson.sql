CREATE OR REPLACE FUNCTION country_area_data_adm0(country_iso char(3))
RETURNS TABLE (
	"countryName"  varchar,
	"regionGeom"   text) AS $$
DECLARE
	result_count integer;
BEGIN
	SELECT count(place_name) INTO result_count FROM countries WHERE id = country_iso;
	IF result_count = 0 THEN 
		RAISE NOTICE 'Skipping country data';
		RETURN;
	END IF;

	RETURN QUERY SELECT countries.place_name as "countryName", ST_AsGEOJSON(countries.geometry) AS "regionGeom"
	FROM countries
	WHERE countries.id = country_iso;

	RETURN;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION country_area_data_adm1(country_iso char(3))
RETURNS TABLE (
	"countryName"  varchar,
	"regionGeom"   text,
	"admin1Name"   varchar) AS $$
DECLARE
	result_count integer;
BEGIN
	SELECT count(place_name) INTO result_count FROM admin1regions WHERE country_id = country_iso;
	IF result_count = 0 THEN 
		RAISE NOTICE 'Skipping admin1 data';
		RETURN;
	END IF;

	RETURN QUERY SELECT countries.place_name as "countryName", ST_AsGEOJSON(admin1regions.geometry) AS "regionGeom",
	admin1regions.place_name as "admin1Name"
	FROM countries
	INNER JOIN admin1regions
	ON countries.id = admin1regions.country_id
	WHERE countries.id = country_iso;

	RETURN;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION country_area_data_adm2(country_iso char(3))
RETURNS TABLE (
	"countryName"  varchar,
	"regionGeom"   text,
	"admin1Name"   varchar,
	"admin2Name"   varchar) AS $$
DECLARE
	result_count integer;
BEGIN
	RETURN QUERY SELECT countries.place_name as "countryName", ST_AsGEOJSON(admin2regions.geometry) AS "regionGeom",
	admin1regions.place_name as "admin1Name", admin2regions.place_name as "admin2Name"
	FROM countries
	INNER JOIN admin1regions
	ON countries.id = admin1regions.country_id
	INNER JOIN admin2regions ON admin2regions.admin1_id = admin1regions.id
	WHERE countries.id = country_iso;

	RETURN;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION country_area_data_adm2_safe(country_iso char(3), go_up_a_region_on_empty boolean)
RETURNS TABLE (
	"countryName"  varchar,
	"regionGeom"   text,
	"admin1Name"   varchar,
	"admin2Name"   varchar) AS $$
DECLARE
	result_count integer;
	admin2data RECORD;
BEGIN
	SELECT count(place_name) INTO result_count FROM admin2regions WHERE admin1_id IN (SELECT id FROM admin1regions WHERE country_id = country_iso);
	IF result_count = 0 THEN 
		RAISE NOTICE 'No admin2';
		IF go_up_a_region_on_empty THEN
			SELECT count(place_name) INTO result_count FROM admin1regions WHERE country_id = country_iso;
			IF result_count = 0 THEN 
				RAISE NOTICE 'No admin1';
				SELECT count(place_name) INTO result_count FROM countries WHERE id = country_iso;
				IF result_count = 0 THEN 
					RAISE NOTICE 'Skipping country data';
					RETURN;
				ELSE
					RETURN QUERY (SELECT *, NULL::varchar as admin1Name, NULL::varchar as admin2Name FROM country_area_data_adm0(country_iso));
				END IF;
			ELSE
				RETURN QUERY (SELECT *, NULL::varchar as admin2Name FROM country_area_data_adm1(country_iso));
			END IF;
		ELSE
			RAISE NOTICE 'Skipping admin2 data';
			RETURN;
		END IF;
	ELSE
		RETURN QUERY (SELECT * FROM country_area_data_adm2(country_iso));
	END IF;
	--admin2data := (SELECT * FROM country_area_data_adm2(country_iso));

	RETURN;
END;
$$ LANGUAGE plpgsql;
