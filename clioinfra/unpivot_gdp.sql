--unpivot the GDP table so each country,date is its own row.
--uses hstore, which we will therefore first install:

create extension if not exists hstore;

CREATE table geoinfra.gdp_unpivot
AS 
SELECT year, (h).key as name,
       case when (h).value = '' then null
       else (h).value::integer
       end as amount
       FROM (SELECT year, each(hstore(foo) - 'year'::text) As h
               FROM geoinfra.gdp as foo  ) As unpiv ;
