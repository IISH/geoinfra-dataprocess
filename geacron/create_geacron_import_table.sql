--create the table to import geacron
--maps all fields from shapefile, cause we're using ogr2ogr
--includes extra datesrc field to distinguish year layers.
CREATE TABLE geoinfra.geacron_import (
     ogc_fid serial NOT NULL,
     geom geometry(Polygon, 4326),
     line_color character varying,
     line_style character varying,
     fill_color character varying,
     fill_alpha character varying,
     tp_area character varying,
     area character varying,
     supra_area character varying,
     date character varying,
     CONSTRAINT geacron_import_pkey PRIMARY KEY (ogc_fid)
);
