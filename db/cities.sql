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


CREATE OR REPLACE FUNCTION update_cities_admin2(country_iso char(3)) RETURNS integer AS $$
DECLARE
	citydata RECORD;
BEGIN
	FOR citydata IN SELECT id, place_name, geometry FROM cities WHERE (country_id = country_iso and admin3_id IS NULL) order by place_name desc
	LOOP
		RAISE NOTICE 'Attempting admin2region for  %', (citydata.place_name);
		update cities
		set admin2_id = (select id from admin2regions where ST_Within(citydata.geometry, admin2regions.geometry))
		where id = citydata.id;
	END LOOP;

	RAISE NOTICE 'Done updating admin2 data for  %', (country_iso);
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION update_cities_admin1(country_iso char(3)) RETURNS integer AS $$
DECLARE
	citydata RECORD;
BEGIN
	FOR citydata IN SELECT id, place_name, geometry FROM cities WHERE (country_id = country_iso and admin2_id IS NULL and admin3_id IS NULL) order by place_name desc
	LOOP
		RAISE NOTICE 'Attempting admin1region for  %', (citydata.place_name);
		update cities
		set admin1_id = (select id from admin1regions where ST_Within(citydata.geometry, admin1regions.geometry))
		where id = citydata.id;
	END LOOP;

	RAISE NOTICE 'Done updating admin1 data for  %', (country_iso);
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION update_cities_admin0(country_iso char(3)) RETURNS integer AS $$
DECLARE
	citydata RECORD;
BEGIN
	FOR citydata IN SELECT id, place_name, geometry FROM cities WHERE (admin1_id_no_admin2 IS NULL AND admin2_id_no_admin3 IS NULL AND admin3_id IS NULL) order by place_name desc
	LOOP
		RAISE NOTICE 'Attempting admin2region for  %', (citydata.place_name);
		update cities
		set country_id_no_admin1 = (select id from countries where ST_Within(citydata.geometry, countries.geometry) AND id = country_iso)
		where id = citydata.id;
	END LOOP;
	
--	update cities
--	set country_id_no_admin1 = country_iso
--	where ST_Within(citydata.geometry, admin2regions.geometry))
	--place_name in (select place_name from countries);

	RAISE NOTICE 'Done matching city to country for %', (country_iso);
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fix_rando_city_data() RETURNS integer AS $$
DECLARE
	citydata RECORD;
BEGIN
	update cities set admin3_id = (select id from admin3regions where place_name like '%Horta Sud Ciutat de Valencia%') where place_name like '%Valencia%';
	update cities set capital = false;
	update cities set capital = true where place_name = 'Paris' and admin3_id in
		(select id from admin3regions WHERE admin2_id in
			(select id from admin2regions where admin1_id in
				(select id from admin1regions where country_id = 'FRA')
			)
		);
	update cities set capital = true where place_name = 'Madrid' and admin3_id in
		(select id from admin3regions WHERE admin2_id in
			(select id from admin2regions where admin1_id in
				(select id from admin1regions where country_id = 'ESP')
			)
		);

	update cities set capital = true where place_name = 'Andorra la Vella' and admin1_id_no_admin2 in
		(select id from admin1regions where country_id = 'AND');

	update cities set capital = true where place_name = 'Monaco' and country_id_no_admin1 = 'MCO';

	RAISE NOTICE 'Done fixing rando city admin3 data';
	RETURN 1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION init_city_zoom() RETURNS integer AS $$
DECLARE
	citydataOuter RECORD;
	citydataInner RECORD;
BEGIN
	UPDATE cities
	SET min_zoom = 10;

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
			GROUP BY a2.admin1_id, a2.id
		)
		LIMIT 1
		LOOP
			UPDATE cities
			SET min_zoom = 0
			WHERE id = citydataInner.cityID;
			--RAISE NOTICE 'City % has population %', citydataInner.place_name, citydataInner.population;
		END LOOP;
	END LOOP;


	FOR citydataInner in 
	select cities.id as cityID
	from cities
	where cities.population in
	(
		select max(cities.population) as maxPop
		from cities
		inner join admin1regions a1 on cities.admin1_id_no_admin2 = a1.id
		inner join countries on countries.id = a1.country_id
		GROUP BY countries.id
	)
	LIMIT 1
	LOOP
		UPDATE cities
		SET min_zoom = 0
		WHERE id = citydataInner.cityID;
		--RAISE NOTICE 'City % has population %', citydataInner.place_name, citydataInner.population;
	END LOOP;

	UPDATE cities
	SET min_zoom = 0
	WHERE country_id_no_admin1 IS NOT NULL;


	-- Don't show largest cities per admin2 area which are either around Paris or running into other city names on the landing page
	UPDATE cities
	SET min_zoom = 7
	WHERE place_name in ('Boulogne-Billancourt', 'Vitry-sur-Seine', 'Saint-Denis', 'Argenteuil', 'Versailles', 'Le Puy-en-Velay', 'Périgueux');

	RAISE NOTICE 'Done updating city zoom data';
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
	"citypopulation"  int,
	"capital"  boolean,
	"textposition"  varchar) AS $$
DECLARE
	citydataOuter RECORD;
	citydataInner RECORD;
BEGIN
	return QUERY
	(
		SELECT a1.place_name, a2.place_name, a3.place_name, city1.place_name as cityname, city1.latitude, city1.longitude, city1.population, city1.capital, city1.text_position
		from cities city1
		inner join admin3regions a3 on city1.admin3_id = a3.id
		inner join admin2regions a2 on a3.admin2_id = a2.id
		inner join admin1regions a1 on a2.admin1_id = a1.id
		WHERE min_zoom < 3
		UNION
		-- Query for Andorra that only has admin1 regions
		SELECT a1.place_name, CAST('' as varchar), CAST('' as varchar), city2.place_name as cityname, city2.latitude, city2.longitude, city2.population, city2.capital, city2.text_position
		from cities city2
		inner join admin1regions a1 on city2.admin1_id_no_admin2 = a1.id
		WHERE min_zoom < 3
		UNION
		-- Query for Monaco that only has an admin0 region
		SELECT CAST('' as varchar), CAST('' as varchar), CAST('' as varchar), city3.place_name as cityname, city3.latitude, city3.longitude, city3.population, city3.capital, city3.text_position
		from cities city3
		inner join countries on city3.country_id_no_admin1 = countries.id
		WHERE min_zoom < 3
		ORDER BY cityname ASC
	);

	RAISE NOTICE 'Done getting landing page population data';
END;
$$ LANGUAGE plpgsql;

