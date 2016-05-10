CREATE FUNCTION add_france() RETURNS integer AS $$
DECLARE
	countrydata RECORD;
BEGIN
	RAISE NOTICE 'Reading country data';
	FOR countrydata IN SELECT iso, name_english, wkb_geometry, shape_length, shape_area FROM fra_adm0 LOOP
		-- Now "countrydata" has one record from cs_materialized_views
		INSERT INTO countries(id, place_name, geometry, shape_length, shape_area)
		VALUES (countrydata.iso, countrydata.name_english, countrydata.wkb_geometry, countrydata.shape_length, countrydata.shape_area);

		add_admin1(countrydata.iso);

		RAISE NOTICE 'Added country %', (countrydata.name_english);
	END LOOP;

	RAISE NOTICE 'Done reading country data';
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION add_admin1(country_iso char(3)) RETURNS integer AS $$
DECLARE
	admin1data RECORD;
BEGIN
	RAISE NOTICE 'Reading admin1 data';
	FOR admin1data IN SELECT name_1, wkb_geometry, shape_length, shape_area FROM fra_adm1
	WHERE iso = country_iso LOOP
		-- Now "admin1data" has one record from cs_materialized_views
		INSERT INTO admin1Regions(country_id, place_name, geometry, shape_length, shape_area)
		VALUES (country_iso, admin1data.name_1, admin1data.wkb_geometry, admin1data.shape_length,
		admin1data.shape_area);

		RAISE NOTICE 'Added admin1 region %', (admin1data.name_english);
		RAISE NOTICE 'Added admin1 region % in country %', (admin1data.name_english, country_iso);
	END LOOP;

	RAISE NOTICE 'Done reading admin1 data';
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION add_admin2(country_iso char(3)) RETURNS integer AS $$
DECLARE
	admin2data RECORD;
BEGIN
	RAISE NOTICE 'Reading admin2 data';
	FOR admin1data IN SELECT id, place_name FROM admin1Regions WHERE iso = country_iso
		WHERE iso = country_iso LOOP
		FOR admin2data IN SELECT name_2, wkb_geometry, shape_length, shape_area FROM fra_adm2 
		WHERE name_1 = admin1data.place_name LOOP
			-- Now "admin2data" has one record from cs_materialized_views
			INSERT INTO admin2Regions(admin1_id, place_name, geometry, shape_length, shape_area)
			VALUES (admin1data.id, admin2data.name_2, admin2data.wkb_geometry, admin2data.shape_length,
			admin2data.shape_area);

			RAISE NOTICE 'Added admin2 region % in admin1 region %', (admin2data.name_2, admin1data.place_name);
		END LOOP;
	END LOOP;

	RAISE NOTICE 'Done reading admin2 data';
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION add_admin3(country_iso char(3)) RETURNS integer AS $$
DECLARE
	admin2data RECORD;
BEGIN
	RAISE NOTICE 'Reading admin2 data';
	FOR admin1data IN SELECT id, place_name FROM admin1Regions
		WHERE iso = country_iso LOOP
		FOR admin2data IN SELECT name_2, wkb_geometry, shape_length, shape_area FROM fra_adm2 
		WHERE name_1 = admin1data.place_name LOOP
			-- Now "admin2data" has one record from cs_materialized_views
			INSERT INTO admin2Regions(admin1_id, place_name, geometry, shape_length, shape_area)
			VALUES (admin1data.id, admin2data.name_2, admin2data.wkb_geometry, admin2data.shape_length,
			admin2data.shape_area);

			RAISE NOTICE 'Added admin2 region % in admin1 region %', (admin2data.name_2, admin1data.place_name);
		END LOOP;
	END LOOP;

	RAISE NOTICE 'Done reading admin2 data';
	RETURN 1;
END;
$$ LANGUAGE plpgsql;
