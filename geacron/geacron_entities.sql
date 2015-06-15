--create geacron entities in entities table

insert into geoinfra.entities (name, time, geometry, source_id)
select name, time, geometry, source_id
from geoinfra.geacron_pits;
