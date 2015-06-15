--create geacron entities in entities table

drop table if exists geoinfra.geacron_pits;

create table geoinfra.geacron_pits as
select area as name, daterange((min(year)||'-01-01')::date, (max(year)+19||'-12-31')::date) as time, geom as geometry, 2 as source_id
from geoinfra.geacron1
group by area, supra_area, geom;

alter table geoinfra.geacron_pits add column id serial;

--patch dateranges that got too long
--not quite working. leave it out for now.
--with foo as (
--select id, time, name, source_id, upper(time), lead(lower(time)) over (order by time) as llow, lead(upper(time)) over (order by time) as lhigh from geoinfra.geacron_pits
--)
--update geoinfra.geacron_pits ent set time = daterange(lower(foo.time),foo.llow-1) from foo where ent.id = foo.id and foo.upper > foo.lhigh;

