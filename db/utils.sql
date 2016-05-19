CREATE OR REPLACE FUNCTION table_exists(table_name_input varchar) RETURNS integer AS $$
DECLARE
	table_exists regclass;
BEGIN
	SELECT to_regclass(table_name_input::cstring) INTO table_exists;
	IF table_exists IS NULL THEN 
		RETURN 0;
	ELSE
		RETURN 1;
	END IF;
END;
$$ LANGUAGE plpgsql;
