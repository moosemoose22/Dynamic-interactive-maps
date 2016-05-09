
CREATE TABLE countries (
    id               serial,
    name             varchar(50) NOT NULL,
    geometry         varchar,
    population       integer
);
CREATE TABLE admin1Regions (
    id               serial,
    country_id       integer,
    name             varchar(50) NOT NULL,
    geometry         text,
    population       integer
);
CREATE TABLE admin2Regions (
    id               serial,
    country_id       integer,
    admin1_id        integer,
    name             varchar(50) NOT NULL,
    geometry         text,
    sub_region_list  varchar,
    population       integer
);
CREATE TABLE admin3Regions (
    id               serial,
    country_id       integer,
    admin1_id        integer,
    admin2_id        integer,
    name             varchar(50) NOT NULL,
    geometry         text,
    sub_region_list  varchar,
    population       integer
);
CREATE TABLE cities (
    id               serial,
    country_id       integer,
    admin1_id        integer,
    admin2_id        integer,
    admin3_id        integer,
    name             varchar(50) NOT NULL,
    lat              double precision,
    long             double precision,
    sub_region_list  varchar,
    population       integer,
    official_langs   
);
CREATE TABLE languages (
    id               serial,
    lang_name        varchar(40) NOT NULL
);
CREATE TABLE lang_region (
    id               serial,
    table_name       varchar(25) NOT NULL,
    lang_id          integer,
    region_id        integer
);
