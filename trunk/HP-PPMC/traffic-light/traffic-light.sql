SELECT /*+ RULE */ DISTINCT r.user_id,
	              users.full_name,
	              users.username,
	              (SELECT role_name FROM rsc_roles WHERE role_id=NVL(r.primary_role_id,0)),
	              users.department_meaning,
	              users.email_address
  FROM rsc_resources r,
	     knta_users_v users
  WHERE ((UPPER(first_name) like UPPER('?' || '%')
        AND (first_name like upper(substr('?',1,2)) || '%'
          OR   first_name like lower(substr('?',1,1)) || upper(substr('?',2,1)) || '%'
          OR   first_name like upper(substr('?',1,1)) || lower(substr('?',2,1)) || '%'
          OR   first_name like lower(substr('?',1,2)) || '%'))
    OR (UPPER(last_name) like UPPER('?' || '%')
        AND (last_name like upper(substr('?',1,2)) || '%'
         OR   last_name like lower(substr('?',1,1)) || upper(substr('?',2,1)) || '%'
         OR   last_name like upper(substr('?',1,1)) || lower(substr('?',2,1)) || '%'
         OR   last_name like lower(substr('?',1,2)) || '%'))
    OR (UPPER(full_name) like UPPER('?' || '%')
        AND (full_name like upper(substr('?',1,2)) || '%'
         OR   full_name like lower(substr('?',1,1)) || upper(substr('?',2,1)) || '%'
         OR   full_name like upper(substr('?',1,1)) || lower(substr('?',2,1)) || '%'
         OR   full_name like lower(substr('?',1,2)) || '%'))
    OR (UPPER(username) like UPPER('?' || '%')
        AND (username like upper(substr('?',1,2)) || '%'
         OR   username like lower(substr('?',1,1)) || upper(substr('?',2,1)) || '%'
         OR   username like upper(substr('?',1,1)) || lower(substr('?',2,1)) || '%'
         OR   username like lower(substr('?',1,2)) || '%')))
    AND r.resource_id IN (
		SELECT dist.resource_id
		FROM rsc_rp_distribution_entries dist
		WHERE (dist.finish_time is null OR dist.finish_time >= current_date) -- users managed by current user sometime in the future
		AND dist.distribution_percent > 0
 		AND dist.resource_pool_id IN (
			SELECT DISTINCT resource_pool_id
			FROM rsc_resource_pools rp
			START WITH rp.resource_pool_id IN (
				-- get resource pools directly managed by user
				SELECT	resource_pool_id
				FROM	rsc_resource_pool_managers
				WHERE 	manager_user_id = [USR.USER_ID] AND rownum > 0)
			CONNECT BY rp.parent_resource_pool_id = PRIOR rp.resource_pool_id )
		UNION
		SELECT rsc_assign.resource_id
		FROM wp_tasks tasks, pm_work_plans wp, pm_projects projects, rsc_staffing_profiles sp,
			 rsc_positions p, rsc_resource_assignments rsc_assign
		WHERE rsc_assign.position_id = p.position_id
		AND p.staffing_profile_id = sp.staffing_profile_id
		AND sp.container_entity_type_code = 1 -- project type
		AND sp.container_entity_id = projects.project_id
		AND projects.project_id = wp.project_id
		AND tasks.work_plan_id = wp.work_plan_id
		--AND tasks.task_id = [SELECTED_TASK_ID]
	)
    AND r.user_id = users.user_id
    AND (users.end_date is null OR users.end_date >= current_date) -- users enabled sometime in the future
	ORDER BY users.full_name