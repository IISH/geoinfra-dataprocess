CREATE TABLE geoinfra.geacron1
as select
     area,
     supra_area,
     st_multi(st_collect(geom)) as geom,
     substring(date,2,4)::integer as year
from geoinfra.geacron_import
group by area, supra_area, year;

alter table geoinfra.geacron1
add column gid serial not null;

