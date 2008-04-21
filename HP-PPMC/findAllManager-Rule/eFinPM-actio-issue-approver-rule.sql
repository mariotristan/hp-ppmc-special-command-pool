select manid,manname
from
(select us.user_id, us.username, manager_user_id as manid, manager_username as manname
from itg.knta_users_v us
where us.user_id='30090'
union
select orgm.user_id, use.username, orge.manager_id, orge.manager_username
from itg.krsc_org_unit_members_v orgm ,itg.knta_users_V use, itg.krsc_org_units_v orge
where orgm.user_id=use.user_id
  and orgm.org_unit_id=orge.org_unit_id
  and orgm.enabled_flag='Y'
  and use.user_id='30090'
)

