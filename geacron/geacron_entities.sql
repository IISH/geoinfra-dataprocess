--create geacron entities in entities table

insert into geoinfra.entities (name, time, geometry, source_id)
select area as name, daterange((min(year)||'-01-01')::date, (max(year)+19||'-12-31')::date) as time, geom as geometry, 2 as source_id
from geoinfra.geacron1
group by area, supra_area, geom;

--patch dateranges that got too long
with foo as (
select id, time, name, source_id, upper(time), lead(lower(time)) over (order by time) as llow, lead(upper(time)) over (order by time) as lhigh from geoinfra.entities
)
update geoinfra.entities ent set time = daterange(lower(foo.time),foo.llow-1) from foo where ent.id = foo.id and foo.upper > foo.lhigh;
