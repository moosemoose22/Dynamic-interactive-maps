CREATE OR REPLACE FUNCTION update_cities(country_iso char(3)) RETURNS integer AS $$
DECLARE
	citydata RECORD;
BEGIN
	FOR citydata IN SELECT id, place_name, geometry FROM cities WHERE (country_id = country_iso) order by place_name desc
	LOOP
		RAISE NOTICE 'Attempting admin3region for  %', (citydata.place_name);
		update cities
		set admin3_id = (select id from admin3regions where ST_Within(citydata.geometry, admin3regions.geometry))
		where id = citydata.id;
	END LOOP;

	RAISE NOTICE 'Done updating admin3 data for  %', (country_iso);
	RETURN 1;
END;
$$ LANGUAGE plpgsql;
