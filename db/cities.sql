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


CREATE OR REPLACE FUNCTION get_landingpage_cities()
RETURNS TABLE (
	"admin1name"  varchar,
	"admin2name"  varchar,
	"admin3name"  varchar,
	"cityname"  varchar,
	"latitude"  double precision,
	"longitude"  double precision,
	"citypopulation"  int) AS $$
DECLARE
	citydataOuter RECORD;
	citydataInner RECORD;
BEGIN
	UPDATE cities
	SET show_on_landing = false;

	FOR citydataOuter IN SELECT distinct a1.id as a1_id, a2.id as a2_id
	from cities
	inner join admin3regions a3 on cities.admin3_id = a3.id
	inner join admin2regions a2 on a3.admin2_id = a2.id
	inner join admin1regions a1 on a2.admin1_id = a1.id
	LOOP
		FOR citydataInner in 
		select cities.id as cityID
		from cities
		inner join admin3regions a3 on cities.admin3_id = a3.id
		inner join admin2regions a2 on a3.admin2_id = a2.id
		where a2.id = citydataOuter.a2_id and a2.admin1_id = citydataOuter.a1_id
		and cities.population in
		(
			select max(cities.population) as maxPop
			from cities
			inner join admin3regions a3 on cities.admin3_id = a3.id
			inner join admin2regions a2 on a3.admin2_id = a2.id
			where a2.id = citydataOuter.a2_id and a2.admin1_id = citydataOuter.a1_id
		)
		LIMIT 1
		LOOP
			UPDATE cities
			SET show_on_landing = true
			WHERE id = citydataInner.cityID;
			--RAISE NOTICE 'City % has population %', citydataInner.place_name, citydataInner.population;
		END LOOP;
	END LOOP;
	
	return QUERY
	(
		SELECT a1.place_name, a2.place_name, a3.place_name, cities.place_name, cities.latitude, cities.longitude, cities.population
		from cities
		inner join admin3regions a3 on cities.admin3_id = a3.id
		inner join admin2regions a2 on a3.admin2_id = a2.id
		inner join admin1regions a1 on a2.admin1_id = a1.id
		WHERE show_on_landing = true
	);

	RAISE NOTICE 'Done getting landing page population data';
END;
$$ LANGUAGE plpgsql;

