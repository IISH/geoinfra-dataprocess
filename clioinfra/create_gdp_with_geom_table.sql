create table geoinfra.gdp_with_geom as 
select b.*, a.amount, a.year from geoinfra.gdp_unpivot a
right outer join geoinfra.entities b
on a.name = lower(b.name)
and (a.year||'-01-01')::date <@ b.time;
