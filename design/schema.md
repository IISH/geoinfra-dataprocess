Schema design
=============

(Work in progress)

The basic datamodel consists of two tables, `entities` and `relations`.

Entities:



column      type                comment
------      ------              ------
id          numeric             id of Entity
concept_id  numeric             id of longitudinal concept
name        text                name of entity
type        text enumerated     type of entity
time        daterange           range of entity validity
geometry    geometry            (multi)polygon
-----       ------

Relations:


column      type            comment
------      ------          ------
id          numeric         id of relation
fid         numeric         'from' id 
tid         numeric         'to' id
rel_type    text enumerated type of relation
------      ------          ------


How are we going to map from the diverse input sets to this model?

Let's start with cshapes.

Actually, let's start with OECD, geonames, etc. Let's create an idealized data model back in time.


Case Study
----------

Let's start with Nederland. According to what I can [find quickly](http://nl.wikipedia.org/wiki/Rijksgrens_van_Nederland), the borders of the Netherlands have been unchanged since 1963.

So:

    Entity
    --------
    id: 1234
    name: Netherlands
    concept_id: nld??
    type: sovereign_state
    time: [1963-04-23:12:00:00,null]
    geometry: multipolygon

Where do we put the authority id?

What do we even want from the authority id?


ISO 3166-1 alpha-3 : NLD


Now, let's go back in time. How many different PiT entities do we have to create for the Netherlands?

Well, Cshapes shows no change since 1946 ... and it's only 69 km2 or something. So ... according to our SOURCE, there's no change. So do we encode the SOURCE somehow?

I think that's a good solution. Let's add a `source` column to the entities table, and probably also the relations table. We fill this column with a source identifier in our import (encode this in our import scripts).

Check for temporal overlaps in the database. That's a good case for a test script (not necessarily a breaking test).

Temporal changes are one thing. But what about the hierarchical relations? 
