-- add PostGIS extension for spatial data types and functions
create extension postgis;

create table variety (
	id serial primary key,
	name varchar unique
	);

create table vineyard (
	id serial primary key,
	name varchar,
	owned_by varchar,
	street_address varchar,
	geom geometry (multipolygon)
	);

create table vineyard_attr (
	vineyard_id int references vineyard (id),
	attr_name varchar,
	attr_value varchar,
	primary key (vineyard_id, attr_name)
	);

create table block (
	id serial primary key,
	vineyard_id int references vineyard (id),
	user_defined_id varchar,
	row_spacing_m numeric,
	vine_spacing_m numeric,
	date_start date,
	date_end date,
	geom geometry (multipolygon)
	);

create table block_attr (
	block_id int references block (id),
	attr_name varchar,
	attr_value varchar,
	primary key (block_id, attr_name)
	);

create table zone_type (
	id serial primary key,
	zone_type varchar unique
	);

create table zone (
	id serial primary key,
	vineyard_id int references vineyard (id),
	user_defined_id varchar,
	zone_type_id int references zone_type (id),
	date_start date,
	date_end date,
	geom geometry (multipolygon)
	);

create table zone_attr (
	zone_id int references zone (id),
	attr_name varchar,
	attr_value varchar,
	primary key (zone_id, attr_name)
	);

create table vinerow (
	id serial primary key,
	block_id int references block (id),
	user_defined_id varchar,
	orientation integer,
	geom geometry (multilinestring)
	);

create table vinerow_attr (
	vinerow_id int references vinerow (id),
	attr_name varchar,
	attr_value varchar,
	primary key (vinerow_id, attr_name)
	);

create table vine (
	id serial primary key,
	vinerow_id int references vinerow (id),
	user_defined_id varchar,
	variety_id int references variety (id),
	clone varchar,
	rootstock varchar,
	geom geometry (point)
	);

create table vine_attr (
	vine_id int references vine (id),
	attr_name varchar,
	attr_value varchar,
	primary key (vine_id, attr_name)
	);
