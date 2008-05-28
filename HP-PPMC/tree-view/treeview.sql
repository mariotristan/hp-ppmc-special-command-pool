select child, parent, LEVEL, lpad('_',2*(level-1)) || child, SYS_CONNECT_BY_PATH(child, '/'), type, connect_by_root child OHA
from
(
(select parameter1 as child, source_id as parent, decode(ref_relationship_id,15,'Request',408,'Task','N/A') as Type
       from knta_references
       where 1=1
         and ref_relationship_id=15
          or ref_relationship_id=408)
union
(select '0' as child, source_id as parent, decode(ref_relationship_id,14,'Request',401,'Task','N/A') as Type
       from knta_references
       where 1=1
         and ref_relationship_id=14
          or ref_relationship_id=401)
)
where child<>'0'
start with child='0'
connect by prior parent=child
order siblings by parent