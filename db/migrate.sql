CREATE OR REPLACE FUNCTION add_country(country_iso char(3)) RETURNS integer AS $$
DECLARE
	countrydata RECORD;
BEGIN
	RAISE NOTICE 'Reading country data';
	FOR countrydata IN SELECT iso, name_english, wkb_geometry, shape_length, shape_area FROM fra_adm0
	LOOP
		-- Now "countrydata" has one record from cs_materialized_views
		INSERT INTO countries(id, place_name, geometry, shape_length, shape_area)
		VALUES (countrydata.iso, countrydata.name_english, countrydata.wkb_geometry, countrydata.shape_length,
		countrydata.shape_area);

		RAISE NOTICE 'Added country %', (countrydata.name_english);
	END LOOP;

	RAISE NOTICE 'Done reading country data';
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION add_admin1(country_iso char(3)) RETURNS integer AS $$
DECLARE
	admin1data RECORD;
BEGIN
	RAISE NOTICE 'Reading admin1 data';
	FOR admin1data IN SELECT name_1, wkb_geometry, shape_length, shape_area FROM fra_adm1
	WHERE (iso = country_iso)
	LOOP
		-- Now "admin1data" has one record from cs_materialized_views
		INSERT INTO admin1Regions(country_id, place_name, geometry, shape_length, shape_area)
		VALUES (country_iso, admin1data.name_1, admin1data.wkb_geometry, admin1data.shape_length,
		admin1data.shape_area);

		RAISE NOTICE 'Added admin1 region % in country %', admin1data.name_1, country_iso;
	END LOOP;

	RAISE NOTICE 'Done reading admin1 data';
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION add_admin2(country_iso char(3)) RETURNS integer AS $$
DECLARE
	admin1data RECORD;
	admin2data RECORD;
BEGIN
	RAISE NOTICE 'Reading admin2 data';
	FOR admin1data IN SELECT id, place_name FROM admin1Regions WHERE (country_id = country_iso)
	LOOP
		FOR admin2data IN SELECT name_2, wkb_geometry, shape_length, shape_area FROM fra_adm2 
		WHERE name_1 = admin1data.place_name LOOP
			-- Now "admin2data" has one record from cs_materialized_views
			INSERT INTO admin2Regions(admin1_id, place_name, geometry, shape_length, shape_area)
			VALUES (admin1data.id, admin2data.name_2, admin2data.wkb_geometry, admin2data.shape_length,
			admin2data.shape_area);

			RAISE NOTICE 'Added admin2 region % in admin1 region %', admin2data.name_2, admin1data.place_name;
		END LOOP;
	END LOOP;

	RAISE NOTICE 'Done reading admin2 data';
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION add_admin3(country_iso char(3)) RETURNS integer AS $$
DECLARE
	admin2data RECORD;
	admin3data RECORD;
BEGIN
	RAISE NOTICE 'Reading admin3 data';
	FOR admin2data IN SELECT admin2Regions.id, admin2Regions.place_name as admin2place,
	admin1Regions.place_name as admin1place
	FROM admin2Regions 
	INNER JOIN admin1Regions ON admin2Regions.admin1_id = admin1Regions.id
	LOOP
		FOR admin3data IN SELECT name_3, wkb_geometry, shape_length, shape_area FROM fra_adm3
		WHERE name_1 = admin2data.admin1place AND name_2 = admin2data.admin2place AND iso = country_iso
		LOOP
			-- Now "admin2data" has one record from cs_materialized_views
			INSERT INTO admin3Regions(admin2_id, place_name, geometry, shape_length, shape_area)
			VALUES (admin2data.id, admin3data.name_3, admin3data.wkb_geometry, admin3data.shape_length,
			admin3data.shape_area);

			RAISE NOTICE 'Added admin3 region % in admin2 region %', admin3data.name_3, admin2data.admin2place;
		END LOOP;
	END LOOP;

	RAISE NOTICE 'Done reading admin3 data';
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION add_all_country_area_data(country_iso char(3)) RETURNS integer AS $$
BEGIN
	PERFORM add_country(country_iso);
	PERFORM add_admin1(country_iso);
	PERFORM add_admin2(country_iso);
	PERFORM add_admin3(country_iso);
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION add_france() RETURNS integer AS $$
BEGIN
	PERFORM add_all_country_area_data(CAST('FRA' AS CHAR(3)));
	RETURN 1;
END;
$$ LANGUAGE plpgsql;






