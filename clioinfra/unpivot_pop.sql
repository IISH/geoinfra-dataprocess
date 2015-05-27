--unpivot the pop table so each country,date is its own row.
--uses hstore, which we will therefore first install:

create extension if not exists hstore;

CREATE table geoinfra.pop_unpivot
AS 
SELECT year, (h).key as name, 
       case when (h).value = '' then null
       else (h).value::float
       end as amount
     FROM (SELECT year, each(hstore(foo) - 'year'::text) As h
  FROM geoinfra.pop as foo  ) As unpiv ;

