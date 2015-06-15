select * from geoinfra.geacron1 where area ilike '%hungary%';

select * from geoinfra.geacron1 where area = 'Aceh';

--ok, need to redo this. grr. What whas the idea? grouping by change in geometry. Hmm.

with aceh as (
    select * from geoinfra.geacron1 where area = 'Aceh' order by year
)

select area, min(year), max(year), geom from aceh group by area, supra_area, geom




with aceh as (
    select * from geoinfra.geacron1 where area = 'Netherlands' order by year
)

select area, min(year), geom from aceh group by area, geom order  by min(year)


with foo as (
with aceh as (
    select * from geoinfra.geacron1 where area = 'Canada' order by year
)

select row_number() over() as id, area, min(year), max(year), supra_area, geom from aceh group by area, supra_area, geom order  by min(year)
)


select min, max - min from foo;


--ok, could perhaps do something with lead() and lag() for filtering out the bad ones. But for now, going to leave them!

select st_srid(geom) from geoinfra.geacron1;

update geoinfra.geacron1 set geom = st_setsrid(geom,4326);

insert into geoinfra.entities (name, time, geometry, source_id)
select area as name, daterange((min(year)||'-01-01')::date, (max(year)+19||'-12-31')::date) as time, geom as geometry, 2 as source_id
from geoinfra.geacron1
group by area, supra_area, geom

--note the end of the daterange extended
--note that that would need to be patched to join geacron seamlessly to cshapes. e.g. canada is like this:

select * from geoinfra.entities where name = 'Canada' order by time;

--that could be done like this:
with foo as (
select time, name, source_id, upper(time), lead(upper(time)) over (order by time) from geoinfra.entities where name = 'Aceh'
)
select * from foo where upper > lead;
--just need to figure out the update clause.
--oh, this algorithm also identifies the Aceh problem earlier! Cool.
--so, update with a 'with' clause?
with foo as (
select id, time, name, source_id, upper(time), lead(lower(time)) over (order by time) as llow, lead(upper(time)) over (order by time) as lhigh from geoinfra.entities
)
update geoinfra.entities ent set time = daterange(lower(foo.time),foo.llow-1) from foo where ent.id = foo.id and foo.upper > foo.lhigh;
--56 rows affected
--note llow-1 to again get non-overlapping date ranges

--ah: Canada 471(newfoundland?) doesn't get updated, because the 'next' one wasn't lower. hmm. Oh well.


--performance of queries

select * from geoinfra.relations limit 100;

select id, name, geometry
from geoinfra.entities
where time && daterange('1980-01-01','1990-01-01')

create index ent_date_idx on geoinfra.entities using gist(time);
create index ent_name_idx on geoinfra.entities (name);

drop index geoinfra.ent_date_idx;
drop index geoinfra.ent_name_idx;


select * from geoinfra.gdp_unpivot limit 10;

create index gdp_name_idx on geoinfra.gdp_unpivot (name);

drop table geoinfra.gdp_with_geom;

--one approach: create a table with a row for every year.
create table geoinfra.gdp_with_geom as
    select a.amount, a.year, b.name, b,geometry
    from geoinfra.gdp_unpivot a inner join geoinfra.entities b
    on a.name = lower(b.name)
    and (a.year||'-01-01')::date <@ b.time;


--but we want more control than this.
create table geoinfra.gdp_with_geom as
select a.*, b.geometry from geoinfra.gdp_unpivot a
inner join geoinfra.entities b
on a.name = lower(b.name)
and (a.year||'-01-01')::date <@ b.time

--ok, now we can select from there with a year parameter.
--for year queries we can select fro


--view
with gdp_with_geom as (
select b.*, a.amount, a.year from geoinfra.gdp_unpivot a
right outer join geoinfra.entities b
on a.name = lower(b.name)
and (a.year||'-01-01')::date <@ b.time
),
stats as (
select avg(amount) as avg,
stddev(amount) as stddev
from geoinfra.pop_unpivot
)
select
gdp_with_geom.id,
gdp_with_geom.name,
gdp_with_geom.geometry as geom,
(gdp_with_geom.year||'-01-01 00:00:00.0Z')::timestamp as date,
gdp_with_geom.amount as data,
(gdp_with_geom.amount - avg) / stddev as normalized_data
from stats, gdp_with_geom
