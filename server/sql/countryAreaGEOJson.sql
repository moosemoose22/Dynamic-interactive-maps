CREATE OR REPLACE FUNCTION init_regions()
RETURNS integer AS $$
BEGIN
	-- admin1 regions
	UPDATE admin1regions SET place_name = 'Euskadi' WHERE place_name = 'País Vasco' AND country_id = 'ESP';
	UPDATE admin1regions SET place_name = 'Catalunya' WHERE place_name = 'Cataluña' AND country_id = 'ESP';
	UPDATE admin1regions SET place_name = 'Illes Balears' WHERE place_name = 'Islas Baleares' AND country_id = 'ESP';

	-- admin2 regions
	UPDATE admin2regions SET place_name = 'Araba' WHERE place_name = 'Álava' AND admin1_id in (select id from admin1regions where place_name like '%Euskadi%' AND country_id = 'ESP');
	UPDATE admin2regions SET place_name = 'Gipuzkoa' WHERE place_name = 'Guipúzcoa' AND admin1_id in (select id from admin1regions where place_name like '%Euskadi%' AND country_id = 'ESP');
	UPDATE admin2regions SET place_name = 'Bizkaia' WHERE place_name = 'Vizcaya' AND admin1_id in (select id from admin1regions where place_name like '%Euskadi%' AND country_id = 'ESP');

	UPDATE countries SET smallest_admin_division = 'admin3' WHERE id in ('FRA','ESP');
	UPDATE countries SET smallest_admin_division = 'admin1' WHERE id in ('AND');
	UPDATE countries SET smallest_admin_division = 'admin0' WHERE id in ('MCO');
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_all_country_specs()
RETURNS TABLE (
	"countryISO"  char,
	"countryName"  varchar,
	"countryAdminDivision"  char(6)
) AS $$
BEGIN
	RETURN QUERY SELECT countries.id as "countryISO", countries.place_name as "countryName", countries.smallest_admin_division AS "countryAdminDivision"
	FROM countries;

	RETURN;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION country_area_data_adm0(country_iso char(3))
RETURNS TABLE (
	"countryISO"  char,
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

	RETURN QUERY SELECT countries.id as "countryISO", countries.place_name as "countryName", ST_AsGEOJSON(countries.geometry) AS "regionGeom"
	FROM countries
	WHERE countries.id = country_iso;

	RETURN;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION country_area_data_adm1(country_iso char(3))
RETURNS TABLE (
	"countryISO"  char,
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

	RETURN QUERY SELECT countries.id as "countryISO", countries.place_name as "countryName", ST_AsGEOJSON(admin1regions.geometry) AS "regionGeom",
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
	"countryISO"  char,
	"countryName"  varchar,
	"regionGeom"   text,
	"admin1Name"   varchar,
	"admin2Name"   varchar) AS $$
DECLARE
	result_count integer;
BEGIN
	RETURN QUERY SELECT countries.id as "countryISO", countries.place_name as "countryName", ST_AsGEOJSON(admin2regions.geometry) AS "regionGeom",
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
	"countryISO"  char,
	"countryName"  varchar,
	"regionGeom"   text,
	"admin1Name"   varchar,
	"admin2Name"   varchar) AS $$
DECLARE
	result_count integer;
	admin2data RECORD;
BEGIN
	SELECT count(place_name) INTO result_count FROM admin3regions WHERE admin2_id IN
	(
		SELECT id from admin2regions WHERE admin1_id in
		(
			SELECT id FROM admin1regions WHERE country_id = country_iso
		)
	);
	IF result_count = 0 THEN 
		RAISE NOTICE 'No admin2';
		IF go_up_a_region_on_empty THEN
			SELECT count(place_name) INTO result_count from admin2regions WHERE admin1_id in
			(
				SELECT id FROM admin1regions WHERE country_id = country_iso
			);
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
