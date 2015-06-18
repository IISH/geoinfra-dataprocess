--create geacron entities in entities table

drop table if exists geoinfra.geacron_pits;

create table geoinfra.geacron_pits as
select area||'_'||supra_area as name, daterange((min(year)||'-01-01')::date, (max(year)+19||'-12-31')::date) as time, geom as geometry, 2 as source_id
from geoinfra.geacron1
group by area, supra_area, geom;

alter table geoinfra.geacron_pits add column id serial;

--patch dateranges that got too long
--not quite working. e.g. spain 1660, what happens to it?
with pre as (
        with foo as (
            select id,
            lower(time) as start_date,
            upper(time) as end_date,
            name,
            lead(name) over (partition by name order by time) as next_name,
            source_id,
            upper(time),
            lead(lower(time)) over (partition by name order by time) as llow,
            lead(upper(time)) over (partition by name order by time) as lhigh,
            geometry
            from geoinfra.entities
            )
        select * from foo where llow < upper
        )
--select ent.*, daterange(start_date,pre.llow) as newtime from geoinfra.entities ent, pre where  ent.id = pre.id;

update geoinfra.entities ent set time = daterange(pre.start_date,pre.llow-1) from pre where ent.id = pre.id;
