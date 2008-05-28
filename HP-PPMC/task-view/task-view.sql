select
tasks.task_id as TASK_ID,
infos.name as TASK_NAME,
infos.task_desc as TASK_DESCRIPTION, 
infos.critical_path_task as TASK_CP,
tasks.parent_task_id as TASK_PARENT,
tasks.creation_date as TASK_CREATIONDATE,
(select username from knta_users where user_id=tasks.created_by) as TASK_CREATOR,
tasks.last_update_date as TASK_LAST_UPDATE,
(select username from knta_users where user_id=owner.owner_resource_id) as TASK_OWNER,
(select username from knta_users where user_id=res.tm_approver_id) as TASK_APPROVER,
(select security_group_name from knta_security_groups where security_group_id=res.time_sheet_approver_sec_grp_id) as TASK_APPROVERS,
actual.act_duration as TASK_ACT_DURATION,
actual.act_effort as TASK_ACT_EFFORT,
actual.act_start_date as TASK_ACT_START,
actual.act_finish_date as TASK_ACT_FINISH,
actual.act_duration as TASK_ACT_DURATION,
actual.est_finish_date as TASK_EST_FINISH,
actual.est_rem_effort as TASK_EST_REMAINING,
actual.tot_sched_duration as TASK_PLANNED_DURATION,
actual.perc_complete as TASK_PERC_COMPLETE,
sched.sched_duration as TASK_PLANNED_DURATION,
sched.sched_effort as TASK_PLANNED_EFFORT,
sched.sched_start_date as TASK_PLANNED_START,
sched.sched_finish_date as TASK_PLANNED_FINISH
from wp_tasks tasks, wp_task_info infos, wp_task_owners owner, rsc_resources res, wp_task_actuals actual, wp_task_schedule sched, knta_users users
where 1=1 
  -- and tasks.task_id=owner.task_id
  and tasks.task_id=infos.task_info_id
  and owner.OWNER_RESOURCE_ID=res.resource_id
  and tasks.TASK_ACTUALS_ID=actual.actuals_id
  and tasks.TASK_SCHEDULE_ID=sched.task_schedule_id
  and res.RESOURCE_ID=users.user_id

