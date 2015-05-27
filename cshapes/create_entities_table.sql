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
