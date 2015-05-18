--fill it with values

--with this we could insert 'succeeded_by'. but it's kind of pointless for cshapes, because we can't reliably get all relations automatically; need to do it manually.
--select row_number() over() as id, a.name as fid_name, b.name as tid_name, a.id as fid, b.id as tid, a.name,'succeeded_by' as rel_type
--from geoinfra.entities a
--inner join geoinfra.entities b on lower(b.time) - upper(a.time) = 1 and a.concept_id = b.concept_id
