-- add tablefunc extension to enable crosstab queries in PostgreSQL, see https://www.postgresql.org/docs/current/tablefunc.html
create extension tablefunc;

-- vineyard view using example attributes transposed with crosstab query, joined to core table
create or replace view vw_vineyard as
with vineyard_attributes as (
	select * from crosstab(
		'select vineyard_id, attr_name, attr_value from vineyard_attr
	    where attr_name in (''gi_region'', ''grower_code'', ''winery'')
	    order by 1,2'
		)
	as (vineyard_id int, gi_region varchar, grower_code varchar, winery varchar)
)
select
	v.id,
	v.name,
	v.owned_by,
	v.street_address,
	vya.gi_region,
	vya.grower_code,
	vya.winery,
	v.geom
from vineyard v
join vineyard_attributes vya on vya.vineyard_id = v.id
order by v.id;


-- block view with example attribute and statistics
-- st_length, st_transform, st_area are PostGIS functions, see https://postgis.net/docs/reference.html
-- ESPG:3577 is Australian Albers equal area projection, see https://spatialreference.org/ref/epsg/gda94-australian-albers
create or replace view vw_block as
with block_attributes as (
	select * from crosstab('
		select block_id, attr_name, attr_value from block_attr
		where attr_name in (''gw_id'')
		order by 1
	')
	as (block_id int, gw_id varchar)
),
vinerow_stats as (
	select
		block_id,
		count(*) as num_rows,
		round(sum(st_length(st_transform(vr.geom, 3577))))::numeric total_row_len_m
	from vinerow vr	group by block_id
)
select
	b.id,
	b.user_defined_id as block_name,
	ba.gw_id,
	b.row_spacing_m,
	b.vine_spacing_m,
	b.date_start,
	b.date_end,
	round((st_area(st_transform(b.geom, 3577)) / 10000)::numeric, 3) as area_ha,
	coalesce(vrs.num_rows, 0) as num_rows,
	coalesce(vrs.total_row_len_m, 0) as total_row_len_m,
	geom
from block b
left join block_attributes ba on b.id = ba.block_id
left join vinerow_stats vrs on b.id = vrs.block_id
order by b.id;
