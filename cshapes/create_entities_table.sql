--create the entities table
create table geoinfra.entities (
    id serial not null primary key,
    name text,
    concept_id text,
    type text,
    time daterange,
    source_id integer,
    geometry geometry(Multipolygon,4326)
);
--fill it with values
insert into geoinfra.entities (
    name,
    concept_id,
    type,
    time,
    source_id,
    geometry
)
select
    cntry_name,
    iso1al3,
    'sovereign_state',
    daterange(concat_ws('-',cowsyear::text,cowsmonth::text,cowsday::text)::date, concat_ws('-',coweyear::text,cowemonth::text,coweday::text)::date) as time,
    001,
    geom
from geoinfra.cshapes_import
where COWCODE <> -1;

--add concept_ids (ISO codes) where those were empty, based on name.
--NOTE: provisional, because name may not be unique, and ISO3 doesn't actually apply to older countries!
with pre as (
    select concept_id, name from geoinfra.entities
    where concept_id is not null
)
update geoinfra.entities a set concept_id = pre.concept_id from pre where a.name = pre.name and a.concept_id is null;
