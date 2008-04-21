select us.user_id, us.username, manager_user_id, manager_username
from itg.knta_users_v us
union
select orgm.user_id, use.username, orge.manager_id, orge.manager_username
from itg.krsc_org_unit_members_v orgm ,itg.knta_users_V use, itg.krsc_org_units_v orge
where orgm.user_id=use.user_id
  and orgm.org_unit_id=orge.org_unit_id
  and orgm.enabled_flag='Y'

