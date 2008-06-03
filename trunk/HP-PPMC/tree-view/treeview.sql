select
us.user_id,
us.username,
us.user_id,
us.username
from knta_users_v us
where
user_id=nvl(,1)
and us.enabled_flag='Y'