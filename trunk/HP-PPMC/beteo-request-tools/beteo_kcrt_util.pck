
  CREATE OR REPLACE PACKAGE "PPMC1"."BETEO_KCRT_UTIL" is

  -- Author  : TOR_NEU<br>
  -- Created : 11.03.2004 10:59:43<br>
  -- Version : $Id: BETEO_kcrt_util.pck,v 6.0 2006/03/06 11:03:59 tor_neu Exp $<br>
  -- Purpose : Utility functions for Kintana Create<br>
  /*
  *  Date        Author           Description
  *  ========================================================================================
  *  07/07/2004  Torsten Neumann  added function set_header_detail_fields()
  *  07/14/2004  Torsten Neumann  fixed Kintana Open Interface Bug: assigned_to_group_name
  *                               field is too small in KCRT_REQUESTS_INT
  *  07/16/2004  Torsten Neumann  fixed bug with all_siblings_done_for_step(): can now handle
  *                               subrequests with different workflows.
  *  08/17/2004  Torsten Neumann  fixed bug where "ORA-20000: ORU-10028: line length overflow,
  *                               limit of 255 chars per line" was thrown in submit_request()
  *  09/20/2004  Torsten Neumann  allow to set workflow name in set_header_fields()
  *  09/22/2004  Torsten Neumann  added support for portfolio management field groups
  *  12/08/2004  Torsten Neumann  added function add_note_to_request()
  *  01/27/2005  Torsten Neumann  added parameter p_status_name to set_header_fields()
  *  06/06/2005  Torsten Neumann  decision_vote() supports sub-workflows
  *  09/23/2005  Torsten Neumann  added start and finish period to set_fg_pfm_proposal_fields()
  *  02/15/2006  Torsten Neumann  added set_assigned_user() and set_assigned_group()
  *  03/02/2006  Torsten Neumann  added append_table_entry()
  *  12/07/2007  Torsten Neumann  add support for custom reference types in create_reference_cust()
  *                               deprecated set_fg_pfm_proposal_fields() and
  *                                          set_fg_pfm_project_fields() for PPM 7.1
  *  12/12/2007  Torsten Neumann  added delete_reference()
  *  05/05/2008  Markus von der Heiden added decision_vote_variable()
  */
  -- Public type declarations
  type t_request_handle is record(
    group_id          kcrt_requests_int.group_id%type := null,
    transaction_id    kcrt_requests_int.transaction_id%type := null,
    request_id        kcrt_requests.request_id%type := null,
    parent_request_id kcrt_requests.request_id%type := null,
    valid             boolean := false);

  -- Public constant declarations
  BETEO_OK constant number := 0;

  BETEO_ERROR constant number := -1;

  --------------------------------------------------------------------------------------------
  -- Public function and procedure declarations
  --------------------------------------------------------------------------------------------
  /*
  *  Create a request handle for further usage of the ITG request open interface.
  *  This is the first function that has to be called to create a new request.
  *
  *  If you create a request with an automatic step as a first step in the workflow, the
  *  step will not get executed due to an ITG bug (at least until 5.5 PL10). The workaround
  *  is to use a dummy decision step with a timeout of 1 minute (for users who create it
  *  manually). If you create the request through the open interface, use decision_vote()
  *  to forward the first step.
  *
  *  #param p_parent_request_id The newly created request will have a parent-child reference
  *                             with this request. If NULL, the request is created standalone.
  *
  *  #usage <code>my_handle t_request_handle;
  *  my_handle := create_mt_request();
  *  if (is_handle_valid(my_handle) then begin
  *    set_header_fields(my_handle, ...);
  *    set_detail_fields(my_handle, ...);
  *    set_fg_pfm_project_fields(my_handle, ...);
  *    submit_request(my_handle);
  *  end if;</code>
  */
  function create_mt_request(p_parent_request_id kcrt_requests.request_id%type default null)
    return t_request_handle;

  /*
  * Checks whether a request handle is valid. A valid handle can be obtained by calling
  * create_mt_request().
  *
  * #param p_request_handle The handle that should be checked.
  *
  * #return Returns TRUE if the handle is valid and FALSE otherwise.
  */
  function is_handle_valid(p_request_handle t_request_handle) return boolean;

  function set_header_fields(p_request_handle         t_request_handle,
                             p_created_username       kcrt_requests_int.created_username%type,
                             p_last_updated_username  kcrt_requests_int.last_updated_username%type,
                             p_request_type_name      kcrt_requests_int.request_type_name%type,
                             p_request_subtype_name   kcrt_requests_int.request_subtype_name%type default null,
                             p_description            kcrt_requests_int.description%type default null,
                             p_status_name            kcrt_requests_int.status_name%type default null,
                             p_workflow_name          kcrt_requests_int.workflow_name%type default null,
                             p_department_name        kcrt_requests_int.department_name%type default null,
                             p_priority_name          kcrt_requests_int.priority_name%type default null,
                             p_application            kcrt_requests_int.application%type default null,
                             p_assigned_to_username   kcrt_requests_int.assigned_to_username%type default null,
                             p_assigned_to_group_name kcrt_requests_int.assigned_to_group_name%type default null,
                             p_project_code           kcrt_requests_int.project_code%type default null,
                             p_contact_first_name     kcrt_requests_int.contact_first_name%type default null,
                             p_contact_last_name      kcrt_requests_int.contact_last_name%type default null,
                             p_company                kcrt_requests_int.company%type default null,
                             p_notes                  varchar2 default null,
                             p_user_data1             kcrt_requests.user_data1%type default null,
                             p_visible_user_data1     kcrt_requests.visible_user_data1%type default null,
                             p_user_data2             kcrt_requests.user_data1%type default null,
                             p_visible_user_data2     kcrt_requests.visible_user_data1%type default null,
                             p_user_data3             kcrt_requests.user_data1%type default null,
                             p_visible_user_data3     kcrt_requests.visible_user_data1%type default null,
                             p_user_data4             kcrt_requests.user_data1%type default null,
                             p_visible_user_data4     kcrt_requests.visible_user_data1%type default null,
                             p_user_data5             kcrt_requests.user_data1%type default null,
                             p_visible_user_data5     kcrt_requests.visible_user_data1%type default null,
                             p_user_data6             kcrt_requests.user_data1%type default null,
                             p_visible_user_data6     kcrt_requests.visible_user_data1%type default null,
                             p_user_data7             kcrt_requests.user_data1%type default null,
                             p_visible_user_data7     kcrt_requests.visible_user_data1%type default null,
                             p_user_data8             kcrt_requests.user_data1%type default null,
                             p_visible_user_data8     kcrt_requests.visible_user_data1%type default null,
                             p_user_data9             kcrt_requests.user_data1%type default null,
                             p_visible_user_data9     kcrt_requests.visible_user_data1%type default null,
                             p_user_data10            kcrt_requests.user_data1%type default null,
                             p_visible_user_data10    kcrt_requests.visible_user_data1%type default null,
                             p_user_data11            kcrt_requests.user_data1%type default null,
                             p_visible_user_data11    kcrt_requests.visible_user_data1%type default null,
                             p_user_data12            kcrt_requests.user_data1%type default null,
                             p_visible_user_data12    kcrt_requests.visible_user_data1%type default null,
                             p_user_data13            kcrt_requests.user_data1%type default null,
                             p_visible_user_data13    kcrt_requests.visible_user_data1%type default null,
                             p_user_data14            kcrt_requests.user_data1%type default null,
                             p_visible_user_data14    kcrt_requests.visible_user_data1%type default null,
                             p_user_data15            kcrt_requests.user_data1%type default null,
                             p_visible_user_data15    kcrt_requests.visible_user_data1%type default null,
                             p_user_data16            kcrt_requests.user_data1%type default null,
                             p_visible_user_data16    kcrt_requests.visible_user_data1%type default null,
                             p_user_data17            kcrt_requests.user_data1%type default null,
                             p_visible_user_data17    kcrt_requests.visible_user_data1%type default null,
                             p_user_data18            kcrt_requests.user_data1%type default null,
                             p_visible_user_data18    kcrt_requests.visible_user_data1%type default null,
                             p_user_data19            kcrt_requests.user_data1%type default null,
                             p_visible_user_data19    kcrt_requests.visible_user_data1%type default null,
                             p_user_data20            kcrt_requests.user_data1%type default null,
                             p_visible_user_data20    kcrt_requests.visible_user_data1%type default null)
    return number;

  function set_header_detail_fields(p_request_handle      t_request_handle,
                                    p_batch_number        kcrt_req_header_details_int.batch_number%type default 1,
                                    p_parameter1          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter1  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter2          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter2  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter3          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter3  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter4          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter4  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter5          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter5  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter6          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter6  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter7          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter7  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter8          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter8  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter9          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter9  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter10         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter10 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter11         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter11 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter12         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter12 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter13         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter13 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter14         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter14 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter15         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter15 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter16         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter16 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter17         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter17 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter18         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter18 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter19         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter19 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter20         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter20 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter21         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter21 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter22         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter22 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter23         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter23 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter24         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter24 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter25         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter25 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter26         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter26 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter27         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter27 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter28         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter28 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter29         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter29 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter30         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter30 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter31         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter31 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter32         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter32 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter33         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter33 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter34         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter34 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter35         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter35 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter36         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter36 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter37         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter37 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter38         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter38 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter39         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter39 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter40         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter40 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter41         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter41 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter42         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter42 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter43         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter43 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter44         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter44 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter45         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter45 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter46         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter46 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter47         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter47 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter48         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter48 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter49         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter49 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter50         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter50 kcrt_req_header_details_int.visible_parameter41%type default null)
    return number;
  /*
    function set_fg_pfm_proposal_fields(p_request_handle               t_request_handle
                       ,p_proposal_name                kcrt_fg_pfm_proposal_int.proposal_name%type default null
                       ,p_prop_business_unit_code      kcrt_fg_pfm_proposal_int.prop_business_unit_code%type default null
                       ,p_prop_business_unit_meaning   kcrt_fg_pfm_proposal_int.prop_business_unit_meaning%type default null
                       ,p_prop_business_objective_id   kcrt_fg_pfm_proposal_int.prop_business_objective_id%type default null
                       ,p_prop_business_objective_name kcrt_fg_pfm_proposal_int.prop_business_unit_meaning%type default null
                       ,p_prop_project_class_code      kcrt_fg_pfm_proposal_int.prop_project_class_code%type default null
                       ,p_prop_project_class_meaning   kcrt_fg_pfm_proposal_int.prop_project_class_meaning%type default null
                       ,p_prop_asset_class_code        kcrt_fg_pfm_proposal_int.prop_asset_class_code%type default null
                       ,p_prop_asset_class_meaning     kcrt_fg_pfm_proposal_int.prop_asset_class_meaning%type default null
                       ,p_prop_project_manager_user_id kcrt_fg_pfm_proposal_int.prop_project_manager_user_id%type default null
                       ,p_prop_project_mgr_username    kcrt_fg_pfm_proposal_int.prop_project_manager_username%type default null
                       ,p_prop_project_template_id     kcrt_fg_pfm_proposal_int.prop_project_template_id%type default null
                       ,p_prop_project_template_name   kcrt_fg_pfm_proposal_int.prop_project_template_name%type default null
                       ,p_prop_budget_id               kcrt_fg_pfm_proposal_int.prop_budget_id%type default null
                       ,p_prop_budget_name             kcrt_fg_pfm_proposal_int.prop_budget_name%type default null
                       ,p_prop_staff_prof_id           kcrt_fg_pfm_proposal_int.prop_staff_prof_id%type default null
                       ,p_prop_staff_prof_name         kcrt_fg_pfm_proposal_int.prop_staff_prof_name%type default null
                       ,p_prop_benefit_id              kcrt_fg_pfm_proposal_int.prop_benefit_id%type default null
                       ,p_prop_benefit_name            kcrt_fg_pfm_proposal_int.prop_benefit_name%type default null
                       ,p_prop_return_on_investment    kcrt_fg_pfm_proposal_int.prop_return_on_investment%type default null
                       ,p_prop_net_present_value       kcrt_fg_pfm_proposal_int.prop_net_present_value%type default null
                       ,p_prop_custom_field_value      kcrt_fg_pfm_proposal_int.prop_custom_field_value%type default null
                       ,p_prop_value_rating            kcrt_fg_pfm_proposal_int.prop_value_rating%type default null
                       ,p_prop_risk_rating             kcrt_fg_pfm_proposal_int.prop_risk_rating%type default null
                       ,p_prop_total_score             kcrt_fg_pfm_proposal_int.prop_total_score%type default null
                       ,p_prop_discount_rate           kcrt_fg_pfm_proposal_int.prop_discount_rate%type default null
                       ,p_prop_plan_start_period_id    kcrt_fg_pfm_proposal_int.prop_plan_start_period_id%type default null
                       ,p_prop_plan_finish_period_id   kcrt_fg_pfm_proposal_int.prop_plan_finish_period_id%type default null
                       ,p_prop_plan_start_period_name  kcrt_fg_pfm_proposal_int.prop_plan_start_period_name%type default null
                       ,p_prop_plan_finish_period_name kcrt_fg_pfm_proposal_int.prop_plan_finish_period_name%type default null)
      return number;

    function set_fg_pfm_project_fields(p_request_handle               t_request_handle
                      ,p_project_name                 kcrt_fg_pfm_project_int.project_name%type default null
                      ,p_project_health_code          kcrt_fg_pfm_project_int.project_health_code%type default null
                      ,p_project_health_meaning       kcrt_fg_pfm_project_int.project_health_meaning%type default null
                      ,p_prj_business_unit_code       kcrt_fg_pfm_project_int.prj_business_unit_code%type default null
                      ,p_prj_business_unit_meaning    kcrt_fg_pfm_project_int.prj_business_unit_meaning%type default null
                      ,p_prj_business_objective_id    kcrt_fg_pfm_project_int.prj_business_objective_id%type default null
                      ,p_prj_business_objective_name  kcrt_fg_pfm_project_int.prj_business_unit_meaning%type default null
                      ,p_prj_project_class_code       kcrt_fg_pfm_project_int.prj_project_class_code%type default null
                      ,p_prj_project_class_meaning    kcrt_fg_pfm_project_int.prj_project_class_meaning%type default null
                      ,p_prj_asset_class_code         kcrt_fg_pfm_project_int.prj_asset_class_code%type default null
                      ,p_prj_asset_class_meaning      kcrt_fg_pfm_project_int.prj_asset_class_meaning%type default null
                      ,p_prj_project_manager_user_id  kcrt_fg_pfm_project_int.prj_project_manager_user_id%type default null
                      ,p_prj_project_manager_username kcrt_fg_pfm_project_int.prj_project_manager_username%type default null
                      ,p_prj_project_plan_id          kcrt_fg_pfm_project_int.prj_project_plan_id%type default null
                      ,p_prj_project_plan_name        kcrt_fg_pfm_project_int.prj_project_plan_name%type default null
                      ,p_prj_project_plan_url         kcrt_fg_pfm_project_int.prj_project_plan_url%type default null
                      ,p_prj_budget_id                kcrt_fg_pfm_project_int.prj_budget_id%type default null
                      ,p_prj_budget_name              kcrt_fg_pfm_project_int.prj_budget_name%type default null
                      ,p_prj_staff_prof_id            kcrt_fg_pfm_project_int.prj_staff_prof_id%type default null
                      ,p_prj_staff_prof_name          kcrt_fg_pfm_project_int.prj_staff_prof_name%type default null
                      ,p_prj_benefit_id               kcrt_fg_pfm_project_int.prj_benefit_id%type default null
                      ,p_prj_benefit_name             kcrt_fg_pfm_project_int.prj_benefit_name%type default null
                      ,p_prj_return_on_investment     kcrt_fg_pfm_project_int.prj_return_on_investment%type default null
                      ,p_prj_net_present_value        kcrt_fg_pfm_project_int.prj_net_present_value%type default null
                      ,p_prj_custom_field_value       kcrt_fg_pfm_project_int.prj_custom_field_value%type default null
                      ,p_prj_value_rating             kcrt_fg_pfm_project_int.prj_value_rating%type default null
                      ,p_prj_risk_rating              kcrt_fg_pfm_project_int.prj_risk_rating%type default null
                      ,p_prj_total_score              kcrt_fg_pfm_project_int.prj_total_score%type default null
                      ,p_prj_discount_rate            kcrt_fg_pfm_project_int.prj_discount_rate%type default null)
      return number;
  */
  function set_detail_fields(p_request_handle      t_request_handle,
                             p_batch_number        kcrt_request_details_int.batch_number%type default 1,
                             p_parameter1          kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter1  kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter2          kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter2  kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter3          kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter3  kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter4          kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter4  kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter5          kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter5  kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter6          kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter6  kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter7          kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter7  kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter8          kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter8  kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter9          kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter9  kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter10         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter10 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter11         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter11 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter12         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter12 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter13         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter13 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter14         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter14 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter15         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter15 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter16         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter16 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter17         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter17 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter18         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter18 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter19         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter19 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter20         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter20 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter21         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter21 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter22         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter22 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter23         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter23 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter24         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter24 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter25         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter25 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter26         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter26 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter27         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter27 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter28         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter28 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter29         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter29 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter30         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter30 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter31         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter31 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter32         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter32 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter33         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter33 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter34         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter34 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter35         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter35 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter36         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter36 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter37         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter37 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter38         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter38 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter39         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter39 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter40         kcrt_request_details_int.parameter1%type default null,
                             p_visible_parameter40 kcrt_request_details_int.visible_parameter1%type default null,
                             p_parameter41         kcrt_request_details_int.parameter41%type default null,
                             p_visible_parameter41 kcrt_request_details_int.visible_parameter41%type default null,
                             p_parameter42         kcrt_request_details_int.parameter41%type default null,
                             p_visible_parameter42 kcrt_request_details_int.visible_parameter41%type default null,
                             p_parameter43         kcrt_request_details_int.parameter41%type default null,
                             p_visible_parameter43 kcrt_request_details_int.visible_parameter41%type default null,
                             p_parameter44         kcrt_request_details_int.parameter41%type default null,
                             p_visible_parameter44 kcrt_request_details_int.visible_parameter41%type default null,
                             p_parameter45         kcrt_request_details_int.parameter41%type default null,
                             p_visible_parameter45 kcrt_request_details_int.visible_parameter41%type default null,
                             p_parameter46         kcrt_request_details_int.parameter41%type default null,
                             p_visible_parameter46 kcrt_request_details_int.visible_parameter41%type default null,
                             p_parameter47         kcrt_request_details_int.parameter41%type default null,
                             p_visible_parameter47 kcrt_request_details_int.visible_parameter41%type default null,
                             p_parameter48         kcrt_request_details_int.parameter41%type default null,
                             p_visible_parameter48 kcrt_request_details_int.visible_parameter41%type default null,
                             p_parameter49         kcrt_request_details_int.parameter41%type default null,
                             p_visible_parameter49 kcrt_request_details_int.visible_parameter41%type default null,
                             p_parameter50         kcrt_request_details_int.parameter41%type default null,
                             p_visible_parameter50 kcrt_request_details_int.visible_parameter41%type default null)
    return number;

  function submit_request(p_request_handle t_request_handle) return number;

  function create_reference(p_parent_request_id in kcrt_requests.request_id%type,
                            p_child_request_id  in kcrt_requests.request_id%type)
    return number;

  /*
  * create_reference_cust()
  *
  * Creates a custom reference between two requests.
  *
  * #param p_from_request_id      Request from which the reference starts
  * #param p_to_request_id        Request to which the reference points
  * #param p_ref_relationship_id  Reference Type from KNTA_REF_RELATIONSHIPS table with entity ID = 20 (Request) and target_type_code = 20
  *
  * #return Returns BETEO_OK if all is fine and BETEO_ERROR if the reference could not be created.
  */
  function create_reference_cust(p_from_request_id     in kcrt_requests.request_id%type,
                                 p_to_request_id       in kcrt_requests.request_id%type,
                                 p_ref_relationship_id in knta_references.ref_relationship_id%type)
    return number;

  /*
  * delete_reference()
  *
  * Deletes a reference between two requests.
  *
  * #param p_from_request_id      Request from which the reference starts
  * #param p_to_request_id        Request to which the reference points
  * #param p_ref_relationship_id  Reference Type from KNTA_REF_RELATIONSHIPS table with entity ID = 20 (Request) and target_type_code = 20
  *
  * #return Returns BETEO_OK if all is fine and BETEO_ERROR if the reference could not be deleted.
  */
  function delete_reference(p_from_request_id     in kcrt_requests.request_id%type,
                            p_to_request_id       in kcrt_requests.request_id%type,
                            p_ref_relationship_id in knta_references.ref_relationship_id%type default null)
    return number;

  /*
  * all_siblings_done_for_step()
  *
  * Returns true if there are no more sub requests which have not completed
  * a certain step in the workflow. This function assumes that all sub requests
  * of a parent request use the same workflow.
  *
  * If at least one sub request has not yet finished the specified step
  * in the workflow, this function returns false.
  */
  function all_siblings_done_for_step(p_parent_request_id kcrt_requests.request_id%type,
                                      p_workflow_name     kwfl_workflows.workflow_name%type,
                                      p_step_number       kwfl_workflow_steps.sort_order%type,
                                      p_step_name         kwfl_workflow_steps.step_name%type)
    return boolean;

  /*
  * Forwards a request workflow step that has a "Decision" step source. It can not be used to run
  * automatic execution steps (see Transaction Open Interface documentation for reasons).
  *
  * #param p_request_id  Identifier of the request that should be forwarded.
  * #param p_username    The username that acts on the decision step.
  * #param p_step_number The sequence number (sort order) of the step the workflow is currently in.
  * #param p_step_name   The name of the step that the workflow is scurrently in.
  * #param p_visible_result_value The desired visible outcome of the decision step.
  * #param p_user_comment An optional user comment which will be placed in the request notes.
  *
  * #return Returns BETEO_OK upon success and BETEO_ERROR otherwise.
  */
  function decision_vote(p_request_id           kcrt_requests.request_id%type,
                         p_username             knta_users.username%type,
                         p_step_number          kwfl_transactions_int.workflow_step_seq%type,
                         p_step_name            kwfl_transactions_int.workflow_step_name%type,
                         p_visible_result_value kwfl_step_transactions.visible_result_value%type,
                         p_user_comment         varchar2 default null)
    return number;

  /*
  * Forwards any request workflow step
  *
  * #param p_request_id  Identifier of the request that should be forwarded.
  * #param p_username    The username that acts on the decision step.
  * #param p_from_step_number The sequence number (sort order) of the step the workflow is currently in.
  * #param p_step_name   The name of the step that the workflow is scurrently in.
  * #param p_to_step_number The sequence number (sort order) of the step the workflow will be moved.
  * #param p_visible_result_value The desired visible outcome of the decision step.
  * #param p_user_comment An optional user comment which will be placed in the request notes.
  *
  * #return Returns BETEO_OK upon success and BETEO_ERROR otherwise.
  */
  function decision_vote_variable(p_request_id           kcrt_requests.request_id%type,
                                  p_username             knta_users.username%type,
                                  p_from_step_number     kwfl_transactions_int.workflow_step_seq%type,
                                  p_from_step_name       kwfl_transactions_int.workflow_step_name%type,
                                  p_to_step_number     kwfl_transactions_int.workflow_step_seq%type,
                                  p_to_step_name       kwfl_transactions_int.workflow_step_name%type,
                                  p_visible_result_value kwfl_step_transactions.visible_result_value%type,
                                  p_user_comment         varchar2 default null)
    return number;

  function get_security_group_id(p_security_group_name knta_security_groups.security_group_name%type)
    return knta_security_groups.security_group_id%type;

  pragma restrict_references(get_security_group_id, wnds, wnps);

  /*
  * Adds a note entry to a request. The current status of the request is added automatically.
  *
  * #param p_request_id  The note will be attached to this request.
  * #param p_username    This user will appear as the author of the note.
  * #param p_note_text   The text that will be attached as a note.
  *
  * #return Returns BETEO_OK upon success and BETEO_ERROR otherwise.
  */
  function add_note_to_request(p_request_id kcrt_requests.request_id%type,
                               p_username   knta_users.username%type,
                               p_note_text  varchar2) return number;

  /*
  *  Sets the assigned user on a request.
  *
  *  #param p_request_id  The ID of the request to get a new assigned user
  *  #param p_user_id     The ID of the newly assigned user.
  *
  *  #return Returns SUCCESS on successful completion, FAILURE otherwise.
  */
  function set_assigned_user(p_request_id kcrt_requests.request_id%type,
                             p_user_id    knta_users.user_id%type)
    return varchar2;

  /*
  *  Sets the assigned user on a request.
  *
  *  #param p_request_id  The ID of the request to get a new assigned user
  *  #param p_user_id     The ID of the newly assigned user.
  *
  *  #return Returns SUCCESS on successful completion, FAILURE otherwise.
  */
  function set_assigned_group(p_request_id kcrt_requests.request_id%type,
                              p_group_id   knta_security_groups.security_group_id%type)
    return varchar2;

  /*
  *  Appends an entry to a table component in a request.
  *
  *  #param p_request_id              ID of the request in which the table component is located
  *  #param p_field_token             Token name of the request field of the table component
  *  #param p_parameter1-40           Internal Parameter Value (Length 200)
  *  #param p_visible_parameter1-40   Visible Parameter Value (Length 200)
  *  #param p_parameter41-50          Internal Parameter Value (Length 2000)
  *  #param p_visible_parameter41-50  Visible Parameter Value (Length 2000)
  *
  *  #return Returns SUCCESS upon successful completion and FAILURE otherwise
  */
  function append_table_entry(p_request_id          kcrt_requests.request_id%type,
                              p_field_token         knta_parameter_set_fields.parameter_token%type,
                              p_parameter1          kcrt_table_entries.parameter1%type default null,
                              p_parameter2          kcrt_table_entries.parameter1%type default null,
                              p_parameter3          kcrt_table_entries.parameter1%type default null,
                              p_parameter4          kcrt_table_entries.parameter1%type default null,
                              p_parameter5          kcrt_table_entries.parameter1%type default null,
                              p_parameter6          kcrt_table_entries.parameter1%type default null,
                              p_parameter7          kcrt_table_entries.parameter1%type default null,
                              p_parameter8          kcrt_table_entries.parameter1%type default null,
                              p_parameter9          kcrt_table_entries.parameter1%type default null,
                              p_parameter10         kcrt_table_entries.parameter1%type default null,
                              p_parameter11         kcrt_table_entries.parameter1%type default null,
                              p_parameter12         kcrt_table_entries.parameter1%type default null,
                              p_parameter13         kcrt_table_entries.parameter1%type default null,
                              p_parameter14         kcrt_table_entries.parameter1%type default null,
                              p_parameter15         kcrt_table_entries.parameter1%type default null,
                              p_parameter16         kcrt_table_entries.parameter1%type default null,
                              p_parameter17         kcrt_table_entries.parameter1%type default null,
                              p_parameter18         kcrt_table_entries.parameter1%type default null,
                              p_parameter19         kcrt_table_entries.parameter1%type default null,
                              p_parameter20         kcrt_table_entries.parameter1%type default null,
                              p_parameter21         kcrt_table_entries.parameter1%type default null,
                              p_parameter22         kcrt_table_entries.parameter1%type default null,
                              p_parameter23         kcrt_table_entries.parameter1%type default null,
                              p_parameter24         kcrt_table_entries.parameter1%type default null,
                              p_parameter25         kcrt_table_entries.parameter1%type default null,
                              p_parameter26         kcrt_table_entries.parameter1%type default null,
                              p_parameter27         kcrt_table_entries.parameter1%type default null,
                              p_parameter28         kcrt_table_entries.parameter1%type default null,
                              p_parameter29         kcrt_table_entries.parameter1%type default null,
                              p_parameter30         kcrt_table_entries.parameter1%type default null,
                              p_parameter31         kcrt_table_entries.parameter1%type default null,
                              p_parameter32         kcrt_table_entries.parameter1%type default null,
                              p_parameter33         kcrt_table_entries.parameter1%type default null,
                              p_parameter34         kcrt_table_entries.parameter1%type default null,
                              p_parameter35         kcrt_table_entries.parameter1%type default null,
                              p_parameter36         kcrt_table_entries.parameter1%type default null,
                              p_parameter37         kcrt_table_entries.parameter1%type default null,
                              p_parameter38         kcrt_table_entries.parameter1%type default null,
                              p_parameter39         kcrt_table_entries.parameter1%type default null,
                              p_parameter40         kcrt_table_entries.parameter1%type default null,
                              p_parameter41         kcrt_table_entries.parameter41%type default null,
                              p_parameter42         kcrt_table_entries.parameter41%type default null,
                              p_parameter43         kcrt_table_entries.parameter41%type default null,
                              p_parameter44         kcrt_table_entries.parameter41%type default null,
                              p_parameter45         kcrt_table_entries.parameter41%type default null,
                              p_parameter46         kcrt_table_entries.parameter41%type default null,
                              p_parameter47         kcrt_table_entries.parameter41%type default null,
                              p_parameter48         kcrt_table_entries.parameter41%type default null,
                              p_parameter49         kcrt_table_entries.parameter41%type default null,
                              p_parameter50         kcrt_table_entries.parameter41%type default null,
                              p_visible_parameter1  kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter2  kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter3  kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter4  kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter5  kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter6  kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter7  kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter8  kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter9  kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter10 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter11 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter12 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter13 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter14 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter15 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter16 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter17 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter18 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter19 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter20 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter21 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter22 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter23 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter24 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter25 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter26 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter27 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter28 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter29 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter30 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter31 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter32 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter33 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter34 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter35 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter36 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter37 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter38 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter39 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter40 kcrt_table_entries.visible_parameter1%type default null,
                              p_visible_parameter41 kcrt_table_entries.visible_parameter41%type default null,
                              p_visible_parameter42 kcrt_table_entries.visible_parameter41%type default null,
                              p_visible_parameter43 kcrt_table_entries.visible_parameter41%type default null,
                              p_visible_parameter44 kcrt_table_entries.visible_parameter41%type default null,
                              p_visible_parameter45 kcrt_table_entries.visible_parameter41%type default null,
                              p_visible_parameter46 kcrt_table_entries.visible_parameter41%type default null,
                              p_visible_parameter47 kcrt_table_entries.visible_parameter41%type default null,
                              p_visible_parameter48 kcrt_table_entries.visible_parameter41%type default null,
                              p_visible_parameter49 kcrt_table_entries.visible_parameter41%type default null,
                              p_visible_parameter50 kcrt_table_entries.visible_parameter41%type default null)
    return varchar2;

end BETEO_KCRT_UTIL;
/
CREATE OR REPLACE PACKAGE BODY "PPMC1"."BETEO_KCRT_UTIL" is

  -- Private variable declarations
  BETEO_INVALID_HANDLE_EX exception;

  BETEO_INTERFACE_ERROR_EX exception;

  BETEO_CREATE_REFERENCE_EX exception;

  BETEO_TXN_INTERFACE_EX exception;

  -- Cursor declarations
  cursor c_get_errors(p_group_id number) is
    select kie.message_name, kie.message
      from knta_interface_errors kie
     where kie.group_id = p_group_id
       and message_type_id != 30; -- 30 is a warning
  cursor c_get_warnings(p_group_id number) is
    select kie.message_name, kie.message
      from knta_interface_errors kie
     where kie.group_id = p_group_id
       and message_type_id = 30; -- 30 is a warning
  -- Helper functions
  function get_next_interface_txn_id return number is
    l_interface_txn_id number;
    cursor c_get_next_interface_txn_id is
      select knta_interface_txns_s.nextval from dual;
  begin
    open c_get_next_interface_txn_id;
    fetch c_get_next_interface_txn_id
      into l_interface_txn_id;
    close c_get_next_interface_txn_id;
    return l_interface_txn_id;
  end get_next_interface_txn_id;

  function get_security_group_id(p_security_group_name knta_security_groups.security_group_name%type)
    return knta_security_groups.security_group_id%type is
    l_sec_grp_id number;
    cursor c_get_sec_grp_id(cp_group_name knta_security_groups.security_group_name%type) is
      select security_group_id
        from knta_security_groups
       where security_group_name = cp_group_name;
  begin
    open c_get_sec_grp_id(p_security_group_name);
    fetch c_get_sec_grp_id
      into l_sec_grp_id;
    if (c_get_sec_grp_id%notfound) then
      l_sec_grp_id := null;
    end if;
    close c_get_sec_grp_id;
    return l_sec_grp_id;
  end get_security_group_id;

  function get_next_request_id return number is
    l_request_id number;
    cursor c_get_next_request_id is
      select kcrt_requests_s.nextval from dual;
  begin
    open c_get_next_request_id;
    fetch c_get_next_request_id
      into l_request_id;
    close c_get_next_request_id;
    return l_request_id;
  end get_next_request_id;

  -- Function and procedure implementations
  function create_mt_request(p_parent_request_id kcrt_requests.request_id%type)
    return t_request_handle is
    l_request_handle t_request_handle;
  begin
    l_request_handle.group_id          := kcrt_request_int.get_next_group_id();
    l_request_handle.transaction_id    := get_next_interface_txn_id();
    l_request_handle.request_id        := get_next_request_id();
    l_request_handle.parent_request_id := p_parent_request_id;
    l_request_handle.valid             := true;
    return l_request_handle;
  exception
    when others then
      dbms_output.put_line('ERROR: create_mt_request() ' || sqlcode || ' ' ||
                           sqlerrm);
      l_request_handle.valid := false;
      return l_request_handle;
  end;

  function is_handle_valid(p_request_handle t_request_handle) return boolean is
  begin
    return p_request_handle.valid;
  end is_handle_valid;

  function set_header_fields(p_request_handle         t_request_handle,
                             p_created_username       kcrt_requests_int.created_username%type,
                             p_last_updated_username  kcrt_requests_int.last_updated_username%type,
                             p_request_type_name      kcrt_requests_int.request_type_name%type,
                             p_request_subtype_name   kcrt_requests_int.request_subtype_name%type,
                             p_description            kcrt_requests_int.description%type,
                             p_status_name            kcrt_requests_int.status_name%type,
                             p_workflow_name          kcrt_requests_int.workflow_name%type,
                             p_department_name        kcrt_requests_int.department_name%type,
                             p_priority_name          kcrt_requests_int.priority_name%type,
                             p_application            kcrt_requests_int.application%type,
                             p_assigned_to_username   kcrt_requests_int.assigned_to_username%type,
                             p_assigned_to_group_name kcrt_requests_int.assigned_to_group_name%type,
                             p_project_code           kcrt_requests_int.project_code%type,
                             p_contact_first_name     kcrt_requests_int.contact_first_name%type,
                             p_contact_last_name      kcrt_requests_int.contact_last_name%type,
                             p_company                kcrt_requests_int.company%type,
                             p_notes                  varchar2,
                             p_user_data1             kcrt_requests.user_data1%type,
                             p_visible_user_data1     kcrt_requests.visible_user_data1%type,
                             p_user_data2             kcrt_requests.user_data1%type,
                             p_visible_user_data2     kcrt_requests.visible_user_data1%type,
                             p_user_data3             kcrt_requests.user_data1%type,
                             p_visible_user_data3     kcrt_requests.visible_user_data1%type,
                             p_user_data4             kcrt_requests.user_data1%type,
                             p_visible_user_data4     kcrt_requests.visible_user_data1%type,
                             p_user_data5             kcrt_requests.user_data1%type,
                             p_visible_user_data5     kcrt_requests.visible_user_data1%type,
                             p_user_data6             kcrt_requests.user_data1%type,
                             p_visible_user_data6     kcrt_requests.visible_user_data1%type,
                             p_user_data7             kcrt_requests.user_data1%type,
                             p_visible_user_data7     kcrt_requests.visible_user_data1%type,
                             p_user_data8             kcrt_requests.user_data1%type,
                             p_visible_user_data8     kcrt_requests.visible_user_data1%type,
                             p_user_data9             kcrt_requests.user_data1%type,
                             p_visible_user_data9     kcrt_requests.visible_user_data1%type,
                             p_user_data10            kcrt_requests.user_data1%type,
                             p_visible_user_data10    kcrt_requests.visible_user_data1%type,
                             p_user_data11            kcrt_requests.user_data1%type,
                             p_visible_user_data11    kcrt_requests.visible_user_data1%type,
                             p_user_data12            kcrt_requests.user_data1%type,
                             p_visible_user_data12    kcrt_requests.visible_user_data1%type,
                             p_user_data13            kcrt_requests.user_data1%type,
                             p_visible_user_data13    kcrt_requests.visible_user_data1%type,
                             p_user_data14            kcrt_requests.user_data1%type,
                             p_visible_user_data14    kcrt_requests.visible_user_data1%type,
                             p_user_data15            kcrt_requests.user_data1%type,
                             p_visible_user_data15    kcrt_requests.visible_user_data1%type,
                             p_user_data16            kcrt_requests.user_data1%type,
                             p_visible_user_data16    kcrt_requests.visible_user_data1%type,
                             p_user_data17            kcrt_requests.user_data1%type,
                             p_visible_user_data17    kcrt_requests.visible_user_data1%type,
                             p_user_data18            kcrt_requests.user_data1%type,
                             p_visible_user_data18    kcrt_requests.visible_user_data1%type,
                             p_user_data19            kcrt_requests.user_data1%type,
                             p_visible_user_data19    kcrt_requests.visible_user_data1%type,
                             p_user_data20            kcrt_requests.user_data1%type,
                             p_visible_user_data20    kcrt_requests.visible_user_data1%type)
    return number is
  begin
    if (not is_handle_valid(p_request_handle)) then
      raise BETEO_INVALID_HANDLE_EX;
    end if;
    insert into kcrt_requests_int
      (GROUP_ID,
       TRANSACTION_ID,
       PROCESS_PHASE,
       PROCESS_STATUS,
       REQUEST_ID,
       CREATION_DATE,
       CREATED_USERNAME,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_USERNAME,
       LAST_UPDATED_BY,
       ENTITY_LAST_UPDATE_DATE,
       REQUEST_NUMBER,
       REQUEST_TYPE_NAME,
       REQUEST_TYPE_ID,
       REQUEST_SUBTYPE_NAME,
       REQUEST_SUBTYPE_ID,
       DESCRIPTION,
       RELEASE_DATE,
       STATUS_NAME,
       STATUS_ID,
       WORKFLOW_NAME,
       WORKFLOW_ID,
       DEPARTMENT_CODE,
       DEPARTMENT_NAME,
       PRIORITY_CODE,
       PRIORITY_NAME,
       APPLICATION,
       ASSIGNED_TO_USERNAME,
       ASSIGNED_TO_USER_ID,
       ASSIGNED_TO_GROUP_NAME,
       ASSIGNED_TO_GROUP_ID,
       PROJECT_CODE,
       CONTACT_FIRST_NAME,
       CONTACT_LAST_NAME,
       CONTACT_ID,
       RELEASED_FLAG,
       USER_DATA_SET_CONTEXT_ID,
       USER_DATA1,
       VISIBLE_USER_DATA1,
       USER_DATA2,
       VISIBLE_USER_DATA2,
       USER_DATA3,
       VISIBLE_USER_DATA3,
       USER_DATA4,
       VISIBLE_USER_DATA4,
       USER_DATA5,
       VISIBLE_USER_DATA5,
       USER_DATA6,
       VISIBLE_USER_DATA6,
       USER_DATA7,
       VISIBLE_USER_DATA7,
       USER_DATA8,
       VISIBLE_USER_DATA8,
       USER_DATA9,
       VISIBLE_USER_DATA9,
       USER_DATA10,
       VISIBLE_USER_DATA10,
       USER_DATA11,
       VISIBLE_USER_DATA11,
       USER_DATA12,
       VISIBLE_USER_DATA12,
       USER_DATA13,
       VISIBLE_USER_DATA13,
       USER_DATA14,
       VISIBLE_USER_DATA14,
       USER_DATA15,
       VISIBLE_USER_DATA15,
       USER_DATA16,
       VISIBLE_USER_DATA16,
       USER_DATA17,
       VISIBLE_USER_DATA17,
       USER_DATA18,
       VISIBLE_USER_DATA18,
       USER_DATA19,
       VISIBLE_USER_DATA19,
       USER_DATA20,
       VISIBLE_USER_DATA20,
       PARAMETER_SET_CONTEXT_ID,
       NOTES,
       SOURCE_TYPE_CODE,
       source,
       WORKFLOW_STEP_ID,
       COMPANY)
    values
      (p_request_handle.group_id,
       p_request_handle.transaction_id,
       1,
       1,
       p_request_handle.request_id,
       sysdate,
       p_created_username,
       null,
       sysdate,
       p_last_updated_username,
       null,
       null,
       p_request_handle.request_id,
       p_request_type_name,
       null,
       p_request_subtype_name,
       null,
       p_description,
       null,
       p_status_name,
       null,
       p_workflow_name,
       null,
       null,
       p_department_name,
       null,
       p_priority_name,
       p_application,
       p_assigned_to_username,
       null,
       null,
       get_security_group_id(p_assigned_to_group_name),
       p_project_code,
       p_contact_first_name,
       p_contact_last_name,
       null,
       'Y',
       null,
       p_user_data1,
       p_visible_user_data1,
       p_user_data2,
       p_visible_user_data2,
       p_user_data3,
       p_visible_user_data3,
       p_user_data4,
       p_visible_user_data4,
       p_user_data5,
       p_visible_user_data5,
       p_user_data6,
       p_visible_user_data6,
       p_user_data7,
       p_visible_user_data7,
       p_user_data8,
       p_visible_user_data8,
       p_user_data9,
       p_visible_user_data9,
       p_user_data10,
       p_visible_user_data10,
       p_user_data11,
       p_visible_user_data11,
       p_user_data12,
       p_visible_user_data12,
       p_user_data13,
       p_visible_user_data13,
       p_user_data14,
       p_visible_user_data14,
       p_user_data15,
       p_visible_user_data15,
       p_user_data16,
       p_visible_user_data16,
       p_user_data17,
       p_visible_user_data17,
       p_user_data18,
       p_visible_user_data18,
       p_user_data19,
       p_visible_user_data19,
       p_user_data20,
       p_visible_user_data20,
       null,
       p_notes,
       null,
       null,
       null,
       p_company);
    return BETEO_OK;
  exception
    when BETEO_INVALID_HANDLE_EX then
      dbms_output.put_line('ERROR: set_header_fields: Invalid request handle exception.');
      dbms_output.put_line('ERROR: call create_mt_request() to get a valid handle.');
      return BETEO_ERROR;
    when others then
      dbms_output.put_line('ERROR: Cannot insert into KCRT_REQUESTS_INT (set_header_fields)');
      dbms_output.put_line('ERROR: SQLCODE = ' || sqlcode);
      dbms_output.put_line('ERROR: SQLMSG  = ' || sqlerrm);
      return BETEO_ERROR;
  end set_header_fields;

  function set_header_detail_fields(p_request_handle      t_request_handle,
                                    p_batch_number        kcrt_req_header_details_int.batch_number%type default 1,
                                    p_parameter1          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter1  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter2          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter2  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter3          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter3  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter4          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter4  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter5          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter5  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter6          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter6  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter7          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter7  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter8          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter8  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter9          kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter9  kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter10         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter10 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter11         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter11 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter12         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter12 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter13         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter13 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter14         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter14 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter15         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter15 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter16         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter16 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter17         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter17 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter18         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter18 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter19         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter19 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter20         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter20 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter21         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter21 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter22         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter22 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter23         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter23 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter24         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter24 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter25         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter25 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter26         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter26 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter27         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter27 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter28         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter28 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter29         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter29 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter30         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter30 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter31         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter31 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter32         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter32 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter33         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter33 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter34         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter34 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter35         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter35 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter36         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter36 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter37         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter37 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter38         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter38 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter39         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter39 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter40         kcrt_req_header_details_int.parameter1%type default null,
                                    p_visible_parameter40 kcrt_req_header_details_int.visible_parameter1%type default null,
                                    p_parameter41         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter41 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter42         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter42 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter43         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter43 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter44         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter44 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter45         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter45 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter46         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter46 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter47         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter47 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter48         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter48 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter49         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter49 kcrt_req_header_details_int.visible_parameter41%type default null,
                                    p_parameter50         kcrt_req_header_details_int.parameter41%type default null,
                                    p_visible_parameter50 kcrt_req_header_details_int.visible_parameter41%type default null)
    return number is
    l_interface_txn_id kcrt_req_header_details_int.transaction_id%type;
  begin
    if (not is_handle_valid(p_request_handle)) then
      raise BETEO_INVALID_HANDLE_EX;
    end if;
    l_interface_txn_id := get_next_interface_txn_id();
    insert into kcrt_req_header_details_int
      (group_id,
       transaction_id,
       parent_transaction_id,
       req_header_detail_id,
       request_id,
       request_type_id,
       batch_number,
       PARAMETER1,
       VISIBLE_PARAMETER1,
       PARAMETER2,
       VISIBLE_PARAMETER2,
       PARAMETER3,
       VISIBLE_PARAMETER3,
       PARAMETER4,
       VISIBLE_PARAMETER4,
       PARAMETER5,
       VISIBLE_PARAMETER5,
       PARAMETER6,
       VISIBLE_PARAMETER6,
       PARAMETER7,
       VISIBLE_PARAMETER7,
       PARAMETER8,
       VISIBLE_PARAMETER8,
       PARAMETER9,
       VISIBLE_PARAMETER9,
       PARAMETER10,
       VISIBLE_PARAMETER10,
       PARAMETER11,
       VISIBLE_PARAMETER11,
       PARAMETER12,
       VISIBLE_PARAMETER12,
       PARAMETER13,
       VISIBLE_PARAMETER13,
       PARAMETER14,
       VISIBLE_PARAMETER14,
       PARAMETER15,
       VISIBLE_PARAMETER15,
       PARAMETER16,
       VISIBLE_PARAMETER16,
       PARAMETER17,
       VISIBLE_PARAMETER17,
       PARAMETER18,
       VISIBLE_PARAMETER18,
       PARAMETER19,
       VISIBLE_PARAMETER19,
       PARAMETER20,
       VISIBLE_PARAMETER20,
       PARAMETER21,
       VISIBLE_PARAMETER21,
       PARAMETER22,
       VISIBLE_PARAMETER22,
       PARAMETER23,
       VISIBLE_PARAMETER23,
       PARAMETER24,
       VISIBLE_PARAMETER24,
       PARAMETER25,
       VISIBLE_PARAMETER25,
       PARAMETER26,
       VISIBLE_PARAMETER26,
       PARAMETER27,
       VISIBLE_PARAMETER27,
       PARAMETER28,
       VISIBLE_PARAMETER28,
       PARAMETER29,
       VISIBLE_PARAMETER29,
       PARAMETER30,
       VISIBLE_PARAMETER30,
       PARAMETER31,
       VISIBLE_PARAMETER31,
       PARAMETER32,
       VISIBLE_PARAMETER32,
       PARAMETER33,
       VISIBLE_PARAMETER33,
       PARAMETER34,
       VISIBLE_PARAMETER34,
       PARAMETER35,
       VISIBLE_PARAMETER35,
       PARAMETER36,
       VISIBLE_PARAMETER36,
       PARAMETER37,
       VISIBLE_PARAMETER37,
       PARAMETER38,
       VISIBLE_PARAMETER38,
       PARAMETER39,
       VISIBLE_PARAMETER39,
       PARAMETER40,
       VISIBLE_PARAMETER40,
       PARAMETER41,
       VISIBLE_PARAMETER41,
       PARAMETER42,
       VISIBLE_PARAMETER42,
       PARAMETER43,
       VISIBLE_PARAMETER43,
       PARAMETER44,
       VISIBLE_PARAMETER44,
       PARAMETER45,
       VISIBLE_PARAMETER45,
       PARAMETER46,
       VISIBLE_PARAMETER46,
       PARAMETER47,
       VISIBLE_PARAMETER47,
       PARAMETER48,
       VISIBLE_PARAMETER48,
       PARAMETER49,
       VISIBLE_PARAMETER49,
       PARAMETER50,
       VISIBLE_PARAMETER50)
    values
      (p_request_handle.group_id,
       l_interface_txn_id,
       p_request_handle.transaction_id,
       null,
       p_request_handle.request_id,
       null,
       p_batch_number,
       p_parameter1,
       p_visible_parameter1,
       p_parameter2,
       p_visible_parameter2,
       p_parameter3,
       p_visible_parameter3,
       p_parameter4,
       p_visible_parameter4,
       p_parameter5,
       p_visible_parameter5,
       p_parameter6,
       p_visible_parameter6,
       p_parameter7,
       p_visible_parameter7,
       p_parameter8,
       p_visible_parameter8,
       p_parameter9,
       p_visible_parameter9,
       p_parameter10,
       p_visible_parameter10,
       p_parameter11,
       p_visible_parameter11,
       p_parameter12,
       p_visible_parameter12,
       p_parameter13,
       p_visible_parameter13,
       p_parameter14,
       p_visible_parameter14,
       p_parameter15,
       p_visible_parameter15,
       p_parameter16,
       p_visible_parameter16,
       p_parameter17,
       p_visible_parameter17,
       p_parameter18,
       p_visible_parameter18,
       p_parameter19,
       p_visible_parameter19,
       p_parameter20,
       p_visible_parameter20,
       p_parameter21,
       p_visible_parameter21,
       p_parameter22,
       p_visible_parameter22,
       p_parameter23,
       p_visible_parameter23,
       p_parameter24,
       p_visible_parameter24,
       p_parameter25,
       p_visible_parameter25,
       p_parameter26,
       p_visible_parameter26,
       p_parameter27,
       p_visible_parameter27,
       p_parameter28,
       p_visible_parameter28,
       p_parameter29,
       p_visible_parameter29,
       p_parameter30,
       p_visible_parameter30,
       p_parameter31,
       p_visible_parameter31,
       p_parameter32,
       p_visible_parameter32,
       p_parameter33,
       p_visible_parameter33,
       p_parameter34,
       p_visible_parameter34,
       p_parameter35,
       p_visible_parameter35,
       p_parameter36,
       p_visible_parameter36,
       p_parameter37,
       p_visible_parameter37,
       p_parameter38,
       p_visible_parameter38,
       p_parameter39,
       p_visible_parameter39,
       p_parameter40,
       p_visible_parameter40,
       p_parameter41,
       p_visible_parameter41,
       p_parameter42,
       p_visible_parameter42,
       p_parameter43,
       p_visible_parameter43,
       p_parameter44,
       p_visible_parameter44,
       p_parameter45,
       p_visible_parameter45,
       p_parameter46,
       p_visible_parameter46,
       p_parameter47,
       p_visible_parameter47,
       p_parameter48,
       p_visible_parameter48,
       p_parameter49,
       p_visible_parameter49,
       p_parameter50,
       p_visible_parameter50);
    return BETEO_OK;
  exception
    when BETEO_INVALID_HANDLE_EX then
      dbms_output.put_line('ERROR: set_detail_fields: Invalid request handle exception.');
      dbms_output.put_line('ERROR: call create_mt_request() to get a valid handle.');
      return BETEO_ERROR;
    when others then
      dbms_output.put_line('ERROR: Cannot insert into KCRT_REQUEST_DETAILS_INT (set_detail_fields)');
      dbms_output.put_line('ERROR: SQLCODE = ' || sqlcode);
      dbms_output.put_line('ERROR: SQLMSG  = ' || sqlerrm);
      return BETEO_ERROR;
  end set_header_detail_fields;

  /*
    function set_fg_pfm_proposal_fields(p_request_handle               t_request_handle
                       ,p_proposal_name                kcrt_fg_pfm_proposal_int.proposal_name%type
                       ,p_prop_business_unit_code      kcrt_fg_pfm_proposal_int.prop_business_unit_code%type
                       ,p_prop_business_unit_meaning   kcrt_fg_pfm_proposal_int.prop_business_unit_meaning%type
                       ,p_prop_business_objective_id   kcrt_fg_pfm_proposal_int.prop_business_objective_id%type
                       ,p_prop_business_objective_name kcrt_fg_pfm_proposal_int.prop_business_unit_meaning%type
                       ,p_prop_project_class_code      kcrt_fg_pfm_proposal_int.prop_project_class_code%type
                       ,p_prop_project_class_meaning   kcrt_fg_pfm_proposal_int.prop_project_class_meaning%type
                       ,p_prop_asset_class_code        kcrt_fg_pfm_proposal_int.prop_asset_class_code%type
                       ,p_prop_asset_class_meaning     kcrt_fg_pfm_proposal_int.prop_asset_class_meaning%type
                       ,p_prop_project_manager_user_id kcrt_fg_pfm_proposal_int.prop_project_manager_user_id%type
                       ,p_prop_project_mgr_username    kcrt_fg_pfm_proposal_int.prop_project_manager_username%type
                       ,p_prop_project_template_id     kcrt_fg_pfm_proposal_int.prop_project_template_id%type
                       ,p_prop_project_template_name   kcrt_fg_pfm_proposal_int.prop_project_template_name%type
                       ,p_prop_budget_id               kcrt_fg_pfm_proposal_int.prop_budget_id%type
                       ,p_prop_budget_name             kcrt_fg_pfm_proposal_int.prop_budget_name%type
                       ,p_prop_staff_prof_id           kcrt_fg_pfm_proposal_int.prop_staff_prof_id%type
                       ,p_prop_staff_prof_name         kcrt_fg_pfm_proposal_int.prop_staff_prof_name%type
                       ,p_prop_benefit_id              kcrt_fg_pfm_proposal_int.prop_benefit_id%type
                       ,p_prop_benefit_name            kcrt_fg_pfm_proposal_int.prop_benefit_name%type
                       ,p_prop_return_on_investment    kcrt_fg_pfm_proposal_int.prop_return_on_investment%type
                       ,p_prop_net_present_value       kcrt_fg_pfm_proposal_int.prop_net_present_value%type
                       ,p_prop_custom_field_value      kcrt_fg_pfm_proposal_int.prop_custom_field_value%type
                       ,p_prop_value_rating            kcrt_fg_pfm_proposal_int.prop_value_rating%type
                       ,p_prop_risk_rating             kcrt_fg_pfm_proposal_int.prop_risk_rating%type
                       ,p_prop_total_score             kcrt_fg_pfm_proposal_int.prop_total_score%type
                       ,p_prop_discount_rate           kcrt_fg_pfm_proposal_int.prop_discount_rate%type
                       ,p_prop_plan_start_period_id    kcrt_fg_pfm_proposal_int.prop_plan_start_period_id%type
                       ,p_prop_plan_finish_period_id   kcrt_fg_pfm_proposal_int.prop_plan_finish_period_id%type
                       ,p_prop_plan_start_period_name  kcrt_fg_pfm_proposal_int.prop_plan_start_period_name%type
                       ,p_prop_plan_finish_period_name kcrt_fg_pfm_proposal_int.prop_plan_finish_period_name%type)
      return number is
      l_interface_txn_id kcrt_fg_pfm_proposal_int.transaction_id%type;
    begin
      if (not is_handle_valid(p_request_handle)) then
        raise BETEO_INVALID_HANDLE_EX;
      end if;
      l_interface_txn_id := get_next_interface_txn_id();
      insert into kcrt_fg_pfm_proposal_int
        (pfm_proposal_interface_id
        ,group_id
        ,transaction_id
        ,parent_transaction_id
        ,process_phase
        ,process_status
        ,request_id
        ,request_type_id
        ,proposal_name
        ,prop_business_unit_code
        ,prop_business_unit_meaning
        ,prop_business_objective_id
        ,prop_business_objective_name
        ,prop_project_class_code
        ,prop_project_class_meaning
        ,prop_asset_class_code
        ,prop_asset_class_meaning
        ,prop_project_manager_user_id
        ,prop_project_manager_username
        ,prop_project_template_id
        ,prop_project_template_name
        ,prop_budget_id
        ,prop_budget_name
        ,prop_staff_prof_id
        ,prop_staff_prof_name
        ,prop_benefit_id
        ,prop_benefit_name
        ,prop_return_on_investment
        ,prop_net_present_value
        ,prop_custom_field_value
        ,prop_value_rating
        ,prop_risk_rating
        ,prop_total_score
        ,prop_discount_rate
        ,prop_plan_start_period_id
        ,prop_plan_finish_period_id
        ,prop_plan_start_period_name
        ,prop_plan_finish_period_name)
      values
        (null
        ,p_request_handle.group_id
        ,l_interface_txn_id
        ,p_request_handle.transaction_id
        ,1
        ,1
        ,p_request_handle.request_id
        ,null
        ,p_proposal_name
        ,p_prop_business_unit_code
        ,p_prop_business_unit_meaning
        ,p_prop_business_objective_id
        ,p_prop_business_objective_name
        ,p_prop_project_class_code
        ,p_prop_project_class_meaning
        ,p_prop_asset_class_code
        ,p_prop_asset_class_meaning
        ,p_prop_project_manager_user_id
        ,p_prop_project_mgr_username
        ,p_prop_project_template_id
        ,p_prop_project_template_name
        ,p_prop_budget_id
        ,p_prop_budget_name
        ,p_prop_staff_prof_id
        ,p_prop_staff_prof_name
        ,p_prop_benefit_id
        ,p_prop_benefit_name
        ,p_prop_return_on_investment
        ,p_prop_net_present_value
        ,p_prop_custom_field_value
        ,p_prop_value_rating
        ,p_prop_risk_rating
        ,p_prop_total_score
        ,p_prop_discount_rate
        ,p_prop_plan_start_period_id
        ,p_prop_plan_finish_period_id
        ,p_prop_plan_start_period_name
        ,p_prop_plan_finish_period_name);
      return BETEO_OK;
    exception
      when BETEO_INVALID_HANDLE_EX then
        dbms_output.put_line('ERROR: set_fg_pfm_proposal_fields: Invalid request handle exception.');
        dbms_output.put_line('ERROR: call create_mt_request() to get a valid handle.');
        return BETEO_ERROR;
      when others then
        dbms_output.put_line('ERROR: Cannot insert into KCRT_FG_PFM_PROPOSAL_INT (set_fg_pfm_proposal_fields)');
        dbms_output.put_line('ERROR: SQLCODE = ' || sqlcode);
        dbms_output.put_line('ERROR: SQLMSG  = ' || sqlerrm);
        return BETEO_ERROR;
    end set_fg_pfm_proposal_fields;

    function set_fg_pfm_project_fields(p_request_handle               t_request_handle
                      ,p_project_name                 kcrt_fg_pfm_project_int.project_name%type default null
                      ,p_project_health_code          kcrt_fg_pfm_project_int.project_health_code%type default null
                      ,p_project_health_meaning       kcrt_fg_pfm_project_int.project_health_meaning%type default null
                      ,p_prj_business_unit_code       kcrt_fg_pfm_project_int.prj_business_unit_code%type default null
                      ,p_prj_business_unit_meaning    kcrt_fg_pfm_project_int.prj_business_unit_meaning%type default null
                      ,p_prj_business_objective_id    kcrt_fg_pfm_project_int.prj_business_objective_id%type default null
                      ,p_prj_business_objective_name  kcrt_fg_pfm_project_int.prj_business_unit_meaning%type default null
                      ,p_prj_project_class_code       kcrt_fg_pfm_project_int.prj_project_class_code%type default null
                      ,p_prj_project_class_meaning    kcrt_fg_pfm_project_int.prj_project_class_meaning%type default null
                      ,p_prj_asset_class_code         kcrt_fg_pfm_project_int.prj_asset_class_code%type default null
                      ,p_prj_asset_class_meaning      kcrt_fg_pfm_project_int.prj_asset_class_meaning%type default null
                      ,p_prj_project_manager_user_id  kcrt_fg_pfm_project_int.prj_project_manager_user_id%type default null
                      ,p_prj_project_manager_username kcrt_fg_pfm_project_int.prj_project_manager_username%type default null
                      ,p_prj_project_plan_id          kcrt_fg_pfm_project_int.prj_project_plan_id%type default null
                      ,p_prj_project_plan_name        kcrt_fg_pfm_project_int.prj_project_plan_name%type default null
                      ,p_prj_project_plan_url         kcrt_fg_pfm_project_int.prj_project_plan_url%type default null
                      ,p_prj_budget_id                kcrt_fg_pfm_project_int.prj_budget_id%type default null
                      ,p_prj_budget_name              kcrt_fg_pfm_project_int.prj_budget_name%type default null
                      ,p_prj_staff_prof_id            kcrt_fg_pfm_project_int.prj_staff_prof_id%type default null
                      ,p_prj_staff_prof_name          kcrt_fg_pfm_project_int.prj_staff_prof_name%type default null
                      ,p_prj_benefit_id               kcrt_fg_pfm_project_int.prj_benefit_id%type default null
                      ,p_prj_benefit_name             kcrt_fg_pfm_project_int.prj_benefit_name%type default null
                      ,p_prj_return_on_investment     kcrt_fg_pfm_project_int.prj_return_on_investment%type default null
                      ,p_prj_net_present_value        kcrt_fg_pfm_project_int.prj_net_present_value%type default null
                      ,p_prj_custom_field_value       kcrt_fg_pfm_project_int.prj_custom_field_value%type default null
                      ,p_prj_value_rating             kcrt_fg_pfm_project_int.prj_value_rating%type default null
                      ,p_prj_risk_rating              kcrt_fg_pfm_project_int.prj_risk_rating%type default null
                      ,p_prj_total_score              kcrt_fg_pfm_project_int.prj_total_score%type default null
                      ,p_prj_discount_rate            kcrt_fg_pfm_project_int.prj_discount_rate%type default null)
      return number is
      l_interface_txn_id kcrt_fg_pfm_proposal_int.transaction_id%type;
    begin
      if (not is_handle_valid(p_request_handle)) then
        raise BETEO_INVALID_HANDLE_EX;
      end if;
      l_interface_txn_id := get_next_interface_txn_id();
      insert into kcrt_fg_pfm_project_int
        (pfm_project_interface_id
        ,group_id
        ,transaction_id
        ,parent_transaction_id
        ,process_phase
        ,process_status
        ,request_id
        ,request_type_id
        ,project_name
        ,project_health_code
        ,project_health_meaning
        ,prj_business_unit_code
        ,prj_business_unit_meaning
        ,prj_business_objective_id
        ,prj_business_objective_name
        ,prj_project_class_code
        ,prj_project_class_meaning
        ,prj_asset_class_code
        ,prj_asset_class_meaning
        ,prj_project_manager_user_id
        ,prj_project_manager_username
        ,prj_project_plan_id
        ,prj_project_plan_name
        ,prj_project_plan_url
        ,prj_budget_id
        ,prj_budget_name
        ,prj_staff_prof_id
        ,prj_staff_prof_name
        ,prj_benefit_id
        ,prj_benefit_name
        ,prj_return_on_investment
        ,prj_net_present_value
        ,prj_custom_field_value
        ,prj_value_rating
        ,prj_risk_rating
        ,prj_total_score
        ,prj_discount_rate)
      values
        (null
        ,p_request_handle.group_id
        ,l_interface_txn_id
        ,p_request_handle.transaction_id
        ,1
        ,1
        ,p_request_handle.request_id
        ,null
        ,p_project_name
        ,p_project_health_code
        ,p_project_health_meaning
        ,p_prj_business_unit_code
        ,p_prj_business_unit_meaning
        ,p_prj_business_objective_id
        ,p_prj_business_objective_name
        ,p_prj_project_class_code
        ,p_prj_project_class_meaning
        ,p_prj_asset_class_code
        ,p_prj_asset_class_meaning
        ,p_prj_project_manager_user_id
        ,p_prj_project_manager_username
        ,p_prj_project_plan_id
        ,p_prj_project_plan_name
        ,p_prj_project_plan_url
        ,p_prj_budget_id
        ,p_prj_budget_name
        ,p_prj_staff_prof_id
        ,p_prj_staff_prof_name
        ,p_prj_benefit_id
        ,p_prj_benefit_name
        ,p_prj_return_on_investment
        ,p_prj_net_present_value
        ,p_prj_custom_field_value
        ,p_prj_value_rating
        ,p_prj_risk_rating
        ,p_prj_total_score
        ,p_prj_discount_rate);
      return BETEO_OK;
    exception
      when BETEO_INVALID_HANDLE_EX then
        dbms_output.put_line('ERROR: set_fg_pfm_project_fields: Invalid request handle exception.');
        dbms_output.put_line('ERROR: call create_mt_request() to get a valid handle.');
        return BETEO_ERROR;
      when others then
        dbms_output.put_line('ERROR: Cannot insert into KCRT_FG_PFM_PROJECT_INT (set_fg_pfm_proposal_fields)');
        dbms_output.put_line('ERROR: SQLCODE = ' || sqlcode);
        dbms_output.put_line('ERROR: SQLMSG  = ' || sqlerrm);
        return BETEO_ERROR;
    end set_fg_pfm_project_fields;
  */
  function set_detail_fields(p_request_handle      t_request_handle,
                             p_batch_number        kcrt_request_details_int.batch_number%type,
                             p_parameter1          kcrt_request_details_int.parameter1%type,
                             p_visible_parameter1  kcrt_request_details_int.visible_parameter1%type,
                             p_parameter2          kcrt_request_details_int.parameter1%type,
                             p_visible_parameter2  kcrt_request_details_int.visible_parameter1%type,
                             p_parameter3          kcrt_request_details_int.parameter1%type,
                             p_visible_parameter3  kcrt_request_details_int.visible_parameter1%type,
                             p_parameter4          kcrt_request_details_int.parameter1%type,
                             p_visible_parameter4  kcrt_request_details_int.visible_parameter1%type,
                             p_parameter5          kcrt_request_details_int.parameter1%type,
                             p_visible_parameter5  kcrt_request_details_int.visible_parameter1%type,
                             p_parameter6          kcrt_request_details_int.parameter1%type,
                             p_visible_parameter6  kcrt_request_details_int.visible_parameter1%type,
                             p_parameter7          kcrt_request_details_int.parameter1%type,
                             p_visible_parameter7  kcrt_request_details_int.visible_parameter1%type,
                             p_parameter8          kcrt_request_details_int.parameter1%type,
                             p_visible_parameter8  kcrt_request_details_int.visible_parameter1%type,
                             p_parameter9          kcrt_request_details_int.parameter1%type,
                             p_visible_parameter9  kcrt_request_details_int.visible_parameter1%type,
                             p_parameter10         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter10 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter11         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter11 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter12         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter12 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter13         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter13 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter14         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter14 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter15         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter15 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter16         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter16 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter17         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter17 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter18         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter18 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter19         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter19 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter20         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter20 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter21         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter21 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter22         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter22 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter23         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter23 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter24         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter24 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter25         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter25 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter26         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter26 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter27         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter27 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter28         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter28 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter29         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter29 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter30         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter30 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter31         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter31 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter32         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter32 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter33         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter33 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter34         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter34 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter35         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter35 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter36         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter36 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter37         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter37 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter38         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter38 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter39         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter39 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter40         kcrt_request_details_int.parameter1%type,
                             p_visible_parameter40 kcrt_request_details_int.visible_parameter1%type,
                             p_parameter41         kcrt_request_details_int.parameter41%type,
                             p_visible_parameter41 kcrt_request_details_int.visible_parameter41%type,
                             p_parameter42         kcrt_request_details_int.parameter41%type,
                             p_visible_parameter42 kcrt_request_details_int.visible_parameter41%type,
                             p_parameter43         kcrt_request_details_int.parameter41%type,
                             p_visible_parameter43 kcrt_request_details_int.visible_parameter41%type,
                             p_parameter44         kcrt_request_details_int.parameter41%type,
                             p_visible_parameter44 kcrt_request_details_int.visible_parameter41%type,
                             p_parameter45         kcrt_request_details_int.parameter41%type,
                             p_visible_parameter45 kcrt_request_details_int.visible_parameter41%type,
                             p_parameter46         kcrt_request_details_int.parameter41%type,
                             p_visible_parameter46 kcrt_request_details_int.visible_parameter41%type,
                             p_parameter47         kcrt_request_details_int.parameter41%type,
                             p_visible_parameter47 kcrt_request_details_int.visible_parameter41%type,
                             p_parameter48         kcrt_request_details_int.parameter41%type,
                             p_visible_parameter48 kcrt_request_details_int.visible_parameter41%type,
                             p_parameter49         kcrt_request_details_int.parameter41%type,
                             p_visible_parameter49 kcrt_request_details_int.visible_parameter41%type,
                             p_parameter50         kcrt_request_details_int.parameter41%type,
                             p_visible_parameter50 kcrt_request_details_int.visible_parameter41%type)
    return number is
    l_interface_txn_id kcrt_request_details_int.transaction_id%type;
  begin
    if (not is_handle_valid(p_request_handle)) then
      raise BETEO_INVALID_HANDLE_EX;
    end if;
    l_interface_txn_id := get_next_interface_txn_id();
    insert into kcrt_request_details_int
      (GROUP_ID,
       TRANSACTION_ID,
       PARENT_TRANSACTION_ID,
       REQUEST_DETAIL_ID,
       REQUEST_ID,
       REQUEST_TYPE_ID,
       PARAMETER_SET_CONTEXT_ID,
       BATCH_NUMBER,
       PARAMETER1,
       VISIBLE_PARAMETER1,
       PARAMETER2,
       VISIBLE_PARAMETER2,
       PARAMETER3,
       VISIBLE_PARAMETER3,
       PARAMETER4,
       VISIBLE_PARAMETER4,
       PARAMETER5,
       VISIBLE_PARAMETER5,
       PARAMETER6,
       VISIBLE_PARAMETER6,
       PARAMETER7,
       VISIBLE_PARAMETER7,
       PARAMETER8,
       VISIBLE_PARAMETER8,
       PARAMETER9,
       VISIBLE_PARAMETER9,
       PARAMETER10,
       VISIBLE_PARAMETER10,
       PARAMETER11,
       VISIBLE_PARAMETER11,
       PARAMETER12,
       VISIBLE_PARAMETER12,
       PARAMETER13,
       VISIBLE_PARAMETER13,
       PARAMETER14,
       VISIBLE_PARAMETER14,
       PARAMETER15,
       VISIBLE_PARAMETER15,
       PARAMETER16,
       VISIBLE_PARAMETER16,
       PARAMETER17,
       VISIBLE_PARAMETER17,
       PARAMETER18,
       VISIBLE_PARAMETER18,
       PARAMETER19,
       VISIBLE_PARAMETER19,
       PARAMETER20,
       VISIBLE_PARAMETER20,
       PARAMETER21,
       VISIBLE_PARAMETER21,
       PARAMETER22,
       VISIBLE_PARAMETER22,
       PARAMETER23,
       VISIBLE_PARAMETER23,
       PARAMETER24,
       VISIBLE_PARAMETER24,
       PARAMETER25,
       VISIBLE_PARAMETER25,
       PARAMETER26,
       VISIBLE_PARAMETER26,
       PARAMETER27,
       VISIBLE_PARAMETER27,
       PARAMETER28,
       VISIBLE_PARAMETER28,
       PARAMETER29,
       VISIBLE_PARAMETER29,
       PARAMETER30,
       VISIBLE_PARAMETER30,
       PARAMETER31,
       VISIBLE_PARAMETER31,
       PARAMETER32,
       VISIBLE_PARAMETER32,
       PARAMETER33,
       VISIBLE_PARAMETER33,
       PARAMETER34,
       VISIBLE_PARAMETER34,
       PARAMETER35,
       VISIBLE_PARAMETER35,
       PARAMETER36,
       VISIBLE_PARAMETER36,
       PARAMETER37,
       VISIBLE_PARAMETER37,
       PARAMETER38,
       VISIBLE_PARAMETER38,
       PARAMETER39,
       VISIBLE_PARAMETER39,
       PARAMETER40,
       VISIBLE_PARAMETER40,
       PARAMETER41,
       VISIBLE_PARAMETER41,
       PARAMETER42,
       VISIBLE_PARAMETER42,
       PARAMETER43,
       VISIBLE_PARAMETER43,
       PARAMETER44,
       VISIBLE_PARAMETER44,
       PARAMETER45,
       VISIBLE_PARAMETER45,
       PARAMETER46,
       VISIBLE_PARAMETER46,
       PARAMETER47,
       VISIBLE_PARAMETER47,
       PARAMETER48,
       VISIBLE_PARAMETER48,
       PARAMETER49,
       VISIBLE_PARAMETER49,
       PARAMETER50,
       VISIBLE_PARAMETER50)
    values
      (p_request_handle.group_id,
       l_interface_txn_id,
       p_request_handle.transaction_id,
       null,
       p_request_handle.request_id,
       null,
       null,
       p_batch_number,
       p_parameter1,
       p_visible_parameter1,
       p_parameter2,
       p_visible_parameter2,
       p_parameter3,
       p_visible_parameter3,
       p_parameter4,
       p_visible_parameter4,
       p_parameter5,
       p_visible_parameter5,
       p_parameter6,
       p_visible_parameter6,
       p_parameter7,
       p_visible_parameter7,
       p_parameter8,
       p_visible_parameter8,
       p_parameter9,
       p_visible_parameter9,
       p_parameter10,
       p_visible_parameter10,
       p_parameter11,
       p_visible_parameter11,
       p_parameter12,
       p_visible_parameter12,
       p_parameter13,
       p_visible_parameter13,
       p_parameter14,
       p_visible_parameter14,
       p_parameter15,
       p_visible_parameter15,
       p_parameter16,
       p_visible_parameter16,
       p_parameter17,
       p_visible_parameter17,
       p_parameter18,
       p_visible_parameter18,
       p_parameter19,
       p_visible_parameter19,
       p_parameter20,
       p_visible_parameter20,
       p_parameter21,
       p_visible_parameter21,
       p_parameter22,
       p_visible_parameter22,
       p_parameter23,
       p_visible_parameter23,
       p_parameter24,
       p_visible_parameter24,
       p_parameter25,
       p_visible_parameter25,
       p_parameter26,
       p_visible_parameter26,
       p_parameter27,
       p_visible_parameter27,
       p_parameter28,
       p_visible_parameter28,
       p_parameter29,
       p_visible_parameter29,
       p_parameter30,
       p_visible_parameter30,
       p_parameter31,
       p_visible_parameter31,
       p_parameter32,
       p_visible_parameter32,
       p_parameter33,
       p_visible_parameter33,
       p_parameter34,
       p_visible_parameter34,
       p_parameter35,
       p_visible_parameter35,
       p_parameter36,
       p_visible_parameter36,
       p_parameter37,
       p_visible_parameter37,
       p_parameter38,
       p_visible_parameter38,
       p_parameter39,
       p_visible_parameter39,
       p_parameter40,
       p_visible_parameter40,
       p_parameter41,
       p_visible_parameter41,
       p_parameter42,
       p_visible_parameter42,
       p_parameter43,
       p_visible_parameter43,
       p_parameter44,
       p_visible_parameter44,
       p_parameter45,
       p_visible_parameter45,
       p_parameter46,
       p_visible_parameter46,
       p_parameter47,
       p_visible_parameter47,
       p_parameter48,
       p_visible_parameter48,
       p_parameter49,
       p_visible_parameter49,
       p_parameter50,
       p_visible_parameter50);
    return BETEO_OK;
  exception
    when BETEO_INVALID_HANDLE_EX then
      dbms_output.put_line('ERROR: set_detail_fields: Invalid request handle exception.');
      dbms_output.put_line('ERROR: call create_mt_request() to get a valid handle.');
      return BETEO_ERROR;
    when others then
      dbms_output.put_line('ERROR: Cannot insert into KCRT_REQUEST_DETAILS_INT (set_detail_fields)');
      dbms_output.put_line('ERROR: SQLCODE = ' || sqlcode);
      dbms_output.put_line('ERROR: SQLMSG  = ' || sqlerrm);
      return BETEO_ERROR;
  end set_detail_fields;

  function submit_request(p_request_handle t_request_handle) return number is
    p_o_message_type number;
    p_o_message_name varchar2(100);
    p_o_message      varchar2(2000);
    l_result         number;
    l_group_id       number;
    l_sql_statement  number;
  begin
    if (not is_handle_valid(p_request_handle)) then
      raise BETEO_INVALID_HANDLE_EX;
    end if;
    l_group_id := p_request_handle.group_id;
    -- run import interface
    l_sql_statement := 100;
    kcrt_request_int.run_interface(p_group_id     => l_group_id,
                                   p_source       => null,
                                   p_usr_dbg      => knta_constant.DEBUG_ALL,
                                   p_user_id      => 1,
                                   o_message_type => p_o_message_type,
                                   o_message_name => p_o_message_name,
                                   o_message      => p_o_message);
    dbms_output.put_line('run_interface(group_id=' || l_group_id ||
                         ') returned: ' || p_o_message_type);
    if (p_o_message_type != knta_constant.SUCCESS) then
      dbms_output.put_line('  ' || p_o_message_name);
      dbms_output.put_line('  ' || p_o_message);
    end if;
    -- get interface warnings
    l_sql_statement := 200;
    open c_get_warnings(p_request_handle.group_id);
    fetch c_get_warnings
      into p_o_message_name, p_o_message;
    while (c_get_warnings%found) loop
      dbms_output.put_line('WARNING: Request creation generated the following warning');
      dbms_output.put_line('WARNING: Message Name: ' || p_o_message_name);
      --commented out by Torsten Neumann on 08/17/2004 (see change history for reason)
      --dbms_output.put_line('WARNING:      Message: ' || substr(p_o_message,1,254));
      fetch c_get_warnings
        into p_o_message_name, p_o_message;
    end loop;
    close c_get_warnings;
    -- get interface errors
    l_sql_statement := 300;
    open c_get_errors(p_request_handle.group_id);
    fetch c_get_errors
      into p_o_message_name, p_o_message;
    if (c_get_errors%found) then
      close c_get_errors;
      raise BETEO_INTERFACE_ERROR_EX;
    end if;
    close c_get_errors;
    dbms_output.put_line('Request #' || p_request_handle.request_id ||
                         ' successfully created');
    -- create reference if parent request id is present
    if (p_request_handle.parent_request_id is not null) then
      l_sql_statement := 400;
      l_result        := create_reference(p_request_handle.parent_request_id,
                                          p_request_handle.request_id);
      if (l_result != BETEO_OK) then
        raise BETEO_CREATE_REFERENCE_EX;
      end if;
    end if;
    return BETEO_OK;
  exception
    when BETEO_INVALID_HANDLE_EX then
      dbms_output.put_line('ERROR: submit_request: Invalid request handle exception.');
      dbms_output.put_line('ERROR: call create_mt_request() to get a valid handle.');
      return BETEO_ERROR;
    when BETEO_INTERFACE_ERROR_EX then
      dbms_output.put_line('ERROR: Request creation FAILED');
      dbms_output.put_line('ERROR: Message Name: ' || p_o_message_name);
      dbms_output.put_line('ERROR:      Message: ' || p_o_message);
      return BETEO_ERROR;
    when BETEO_CREATE_REFERENCE_EX then
      dbms_output.put_line('ERROR: Reference creation FAILED');
      dbms_output.put_line('ERROR: Parent Request ID: ' ||
                           p_request_handle.parent_request_id);
      dbms_output.put_line('ERROR:  Child Request ID: ' ||
                           p_request_handle.request_id);
      return BETEO_ERROR;
    when others then
      dbms_output.put_line('ERROR: Other Oracle Request Thrown (statement=' ||
                           l_sql_statement || ')');
      dbms_output.put_line('ERROR: SQLCODE : ' || sqlcode);
      dbms_output.put_line('ERROR:  SQLMSG : ' || sqlerrm);
      return BETEO_ERROR;
  end submit_request;

  function create_reference(p_parent_request_id in kcrt_requests.request_id%type,
                            p_child_request_id  in kcrt_requests.request_id%type)
    return number is
    l_reference_id     knta_references.reference_id%type;
    l_message_type     number;
    l_message_name     varchar2(100);
    l_message          varchar2(2000);
    l_creation_date    date;
    l_last_update_date date;
  begin
    l_reference_id := null;
    --select knta_references_s.nextval
    --  into l_reference_id
    --  from dual;
    knta_references_th.Process_Row(p_event                    => 'INSERT',
                                   p_reference_id             => l_reference_id,
                                   p_last_updated_by          => 1,
                                   p_target_type_code         => KNTA_CONSTANT.ENTITY_REQUEST,
                                   p_ref_relationship_id      => KNTA_CONSTANT.REF_REQUEST_IS_PARENT,
                                   p_source_entity_id         => KNTA_CONSTANT.ENTITY_REQUEST,
                                   p_source_id                => p_child_request_id,
                                   p_original_source_id       => p_child_request_id,
                                   p_reverse_reference_id     => null,
                                   p_enabled_flag             => 'Y',
                                   p_parameter_set_context_ID => KNTA_CONSTANT.PARAMSCONTEXTID_REF_REQUEST,
                                   p_parameter1               => p_parent_request_id,
                                   p_visible_parameter1       => p_parent_request_id,
                                   p_usr_dbg                  => null,
                                   O_LAST_UPDATE_DATE         => l_last_update_date,
                                   O_CREATION_DATE            => l_creation_date,
                                   O_MESSAGE_TYPE             => l_message_type,
                                   O_MESSAGE_NAME             => l_message_name,
                                   O_MESSAGE                  => l_message);
    if (l_message_type != knta_constant.SUCCESS) then
      raise BETEO_CREATE_REFERENCE_EX;
    end if;
    dbms_output.put_line('Reference between parent request #' ||
                         p_parent_request_id || ' and child request #' ||
                         p_child_request_id || ' created successfully');
    return BETEO_OK;
  exception
    when BETEO_CREATE_REFERENCE_EX then
      dbms_output.put_line('ERROR: Reference Creation FAILED');
      dbms_output.put_line('ERROR: Message Name: ' || l_message_name);
      dbms_output.put_line('ERROR:      Message: ' || l_message);
      return BETEO_ERROR;
    when others then
      dbms_output.put_line('ERROR: Reference Creation FAILED');
      dbms_output.put_line('ERROR: SQLCODE : ' || sqlcode);
      dbms_output.put_line('ERROR:  SQLMSG : ' || sqlerrm);
      return BETEO_ERROR;
  end create_reference;

  ---------------------------------------------------------------------------------------------------------------------------------
  -- create_reference_cust()
  ---------------------------------------------------------------------------------------------------------------------------------
  function create_reference_cust(p_from_request_id     in kcrt_requests.request_id%type,
                                 p_to_request_id       in kcrt_requests.request_id%type,
                                 p_ref_relationship_id in knta_references.ref_relationship_id%type)
    return number is
    l_reference_id     knta_references.reference_id%type;
    l_message_type     number;
    l_message_name     varchar2(100);
    l_message          varchar2(2000);
    l_creation_date    date;
    l_last_update_date date;
  begin
    l_reference_id := null;
    --select knta_references_s.nextval
    --  into l_reference_id
    --  from dual;
    knta_references_th.Process_Row(p_event                    => 'INSERT',
                                   p_reference_id             => l_reference_id,
                                   p_last_updated_by          => 1,
                                   p_target_type_code         => KNTA_CONSTANT.ENTITY_REQUEST,
                                   p_ref_relationship_id      => p_ref_relationship_id,
                                   p_source_entity_id         => KNTA_CONSTANT.ENTITY_REQUEST,
                                   p_source_id                => p_from_request_id,
                                   p_original_source_id       => p_from_request_id,
                                   p_reverse_reference_id     => null,
                                   p_enabled_flag             => 'Y',
                                   p_parameter_set_context_ID => KNTA_CONSTANT.PARAMSCONTEXTID_REF_REQUEST,
                                   p_parameter1               => p_to_request_id,
                                   p_visible_parameter1       => p_to_request_id,
                                   p_usr_dbg                  => null,
                                   O_LAST_UPDATE_DATE         => l_last_update_date,
                                   O_CREATION_DATE            => l_creation_date,
                                   O_MESSAGE_TYPE             => l_message_type,
                                   O_MESSAGE_NAME             => l_message_name,
                                   O_MESSAGE                  => l_message);
    if (l_message_type != knta_constant.SUCCESS) then
      raise BETEO_CREATE_REFERENCE_EX;
    end if;
    dbms_output.put_line('Reference between request #' ||
                         p_from_request_id || ' and request #' ||
                         p_to_request_id || ' created successfully');
    return BETEO_OK;
  exception
    when BETEO_CREATE_REFERENCE_EX then
      dbms_output.put_line('ERROR: Reference Creation FAILED');
      dbms_output.put_line('ERROR: Message Name: ' || l_message_name);
      dbms_output.put_line('ERROR:      Message: ' || l_message);
      return BETEO_ERROR;
    when others then
      dbms_output.put_line('ERROR: Reference Creation FAILED');
      dbms_output.put_line('ERROR: SQLCODE : ' || sqlcode);
      dbms_output.put_line('ERROR:  SQLMSG : ' || sqlerrm);
      return BETEO_ERROR;
  end create_reference_cust;

  ----------------------------------------------------------------------------------------------------------------------------------------
  -- delete_reference()
  ----------------------------------------------------------------------------------------------------------------------------------------
  function delete_reference(p_from_request_id     in kcrt_requests.request_id%type,
                            p_to_request_id       in kcrt_requests.request_id%type,
                            p_ref_relationship_id in knta_references.ref_relationship_id%type default null)
    return number is
    l_reference_id     knta_references.reference_id%type;
    l_message_type     number;
    l_message_name     varchar2(100);
    l_message          varchar2(2000);
    l_creation_date    date;
    l_last_update_date date;
  begin
    -- Determine reference id
    select ref.reference_id
      into l_reference_id
      from knta_references ref
     where source_entity_id = 20
       and target_type_code = 20
       and source_id = p_from_request_id
       and parameter1 = p_to_request_id
       and (ref.ref_relationship_id = p_ref_relationship_id or
           p_ref_relationship_id is null);

    -- Delete reference
    knta_references_th.Process_Row(p_event            => 'DELETE',
                                   p_reference_id     => l_reference_id,
                                   p_last_updated_by  => 1,
                                   O_LAST_UPDATE_DATE => l_last_update_date,
                                   O_CREATION_DATE    => l_creation_date,
                                   O_MESSAGE_TYPE     => l_message_type,
                                   O_MESSAGE_NAME     => l_message_name,
                                   O_MESSAGE          => l_message);
    if (l_message_type != knta_constant.SUCCESS) then
      raise BETEO_CREATE_REFERENCE_EX;
    end if;
    dbms_output.put_line('Reference between request #' ||
                         p_from_request_id || ' and request #' ||
                         p_to_request_id || ' deleted successfully');
    return BETEO_OK;
  exception
    when BETEO_CREATE_REFERENCE_EX then
      dbms_output.put_line('ERROR: Reference Deletion FAILED');
      dbms_output.put_line('ERROR: Message Name: ' || l_message_name);
      dbms_output.put_line('ERROR:      Message: ' || l_message);
      return BETEO_ERROR;
    when others then
      dbms_output.put_line('ERROR: Reference Deletion FAILED');
      dbms_output.put_line('ERROR: SQLCODE : ' || sqlcode);
      dbms_output.put_line('ERROR:  SQLMSG : ' || sqlerrm);
      return BETEO_ERROR;
  end delete_reference;

  ----------------------------------------------------------------------------------------------------------------------------------------
  function all_siblings_done_for_step(p_parent_request_id kcrt_requests.request_id%type,
                                      p_workflow_name     kwfl_workflows.workflow_name%type,
                                      p_step_number       kwfl_workflow_steps.sort_order%type,
                                      p_step_name         kwfl_workflow_steps.step_name%type)
    return boolean is
    cursor c_get_unfinished_siblings(cp_parent_request_id kcrt_requests.request_id%type, cp_workflow_name kwfl_workflows.workflow_name%type, cp_step_number kwfl_workflow_steps.sort_order%type, cp_step_name kwfl_workflow_steps.step_name%type) is
      select sub.request_id, step_status.status
        from (select wst.instance_source_id as request_id,
                     ws.step_name,
                     wst.status as status
                from kwfl_step_transactions wst,
                     kwfl_workflow_steps    ws,
                     kwfl_workflows         w
               where wst.workflow_step_id = ws.workflow_step_id
                 and ws.sort_order = cp_step_number
                 and ws.step_name = cp_step_name
                 and wst.status = 'COMPLETE'
                 and w.workflow_id = wst.workflow_id
                 and w.workflow_name = cp_workflow_name
              union
              select wst.instance_source_id as request_id,
                     null,
                     wst.status as status
                from kwfl_step_transactions wst, kwfl_workflows w
               where wst.status = 'CANCELLED'
                 and w.workflow_id = wst.workflow_id
                 and w.workflow_name = cp_workflow_name) step_status,
             (select rs.request_id as request_id
                from kcrt_requests   r,
                     kcrt_requests   rs,
                     knta_references ref,
                     kwfl_workflows  w
               where ref.ref_relationship_id = 15
                 and ref.source_id = r.request_id
                 and ref.parameter1 = rs.request_id
                 and r.request_id = cp_parent_request_id
                 and w.workflow_name = cp_workflow_name
                 and w.workflow_id = rs.workflow_id) sub
       where sub.request_id = step_status.request_id(+)
         and step_status.status is null;
    l_request_id kcrt_requests.request_id%type;
    l_status     kwfl_step_transactions.status%type;
    l_result     boolean;
  begin
    open c_get_unfinished_siblings(p_parent_request_id,
                                   p_workflow_name,
                                   p_step_number,
                                   p_step_name);
    fetch c_get_unfinished_siblings
      into l_request_id, l_status;
    if (c_get_unfinished_siblings%found) then
      dbms_output.put_line('child request #' || l_request_id ||
                           ' still pending');
      l_result := false;
    else
      dbms_output.put_line('no more pending child requests found');
      l_result := true;
    end if;
    close c_get_unfinished_siblings;
    return l_result;
  exception
    when others then
      dbms_output.put_line('ERROR: all_siblings_done_for_step()');
      dbms_output.put_line('ERROR: SQLCODE : ' || sqlcode);
      dbms_output.put_line('ERROR:  SQLMSG : ' || sqlerrm);
      return false;
  end all_siblings_done_for_step;

  function decision_vote(p_request_id           kcrt_requests.request_id%type,
                         p_username             knta_users.username%type,
                         p_step_number          kwfl_transactions_int.workflow_step_seq%type,
                         p_step_name            kwfl_transactions_int.workflow_step_name%type,
                         p_visible_result_value kwfl_step_transactions.visible_result_value%type,
                         p_user_comment         varchar2) return number is
    l_group_id     kwfl_transactions_int.group_id%type;
    l_message_type number;
    l_message_name varchar2(100);
    l_message      varchar2(2000);
  begin
    l_group_id := kcrt_request_int.get_next_group_id();
    kwfl_txn_int.insert_row(p_event                 => 'APPROVAL_VOTE',
                            p_group_id              => l_group_id,
                            p_created_username      => p_username,
                            p_source                => null,
                            p_request_number        => p_request_id,
                            p_package_number        => null,
                            p_package_line_seq      => null,
                            p_workflow_step_seq     => p_step_number,
                            p_workflow_step_name    => p_step_name,
                            p_visible_result_value  => p_visible_result_value,
                            p_user_comments         => p_user_comment,
                            p_delegated_to_username => null,
                            p_schedule_date         => null,
                            p_to_workflow_step_name => null,
                            p_to_workflow_step_seq  => null,
                            O_MESSAGE_TYPE          => l_message_type,
                            O_MESSAGE_NAME          => l_message_name,
                            O_MESSAGE               => l_message);
    if (l_message_type != knta_constant.SUCCESS) then
      raise BETEO_TXN_INTERFACE_EX;
    end if;
    kwfl_txn_int.run_interface(P_GROUP_ID     => l_group_id,
                               P_SOURCE       => null,
                               P_USER_ID      => 1,
                               P_USR_DBG      => knta_constant.DEBUG_ALL,
                               O_MESSAGE_TYPE => l_message_type,
                               O_MESSAGE_NAME => l_message_name,
                               O_MESSAGE      => l_message);
    if (l_message_type != knta_constant.SUCCESS) then
      raise BETEO_TXN_INTERFACE_EX;
    end if;
    dbms_output.put_line('decision_vote() completed successfully');
    return BETEO_OK;
  exception
    when BETEO_TXN_INTERFACE_EX then
      dbms_output.put_line('ERROR: decision_vote() FAILED');
      dbms_output.put_line('ERROR: Message Name: ' || l_message_name);
      dbms_output.put_line('ERROR:      Message: ' || l_message);
      return BETEO_ERROR;
    when others then
      dbms_output.put_line('ERROR: decision_vote() FAILED');
      dbms_output.put_line('ERROR: SQLCODE : ' || sqlcode);
      dbms_output.put_line('ERROR:  SQLMSG : ' || sqlerrm);
      return BETEO_ERROR;
  end;

  function decision_vote_variable(p_request_id           kcrt_requests.request_id%type,
                                  p_username             knta_users.username%type,
                                  p_from_step_number     kwfl_transactions_int.workflow_step_seq%type,
                                  p_from_step_name       kwfl_transactions_int.workflow_step_name%type,
                                  p_to_step_number       kwfl_transactions_int.workflow_step_seq%type,
                                  p_to_step_name         kwfl_transactions_int.workflow_step_name%type,
                                  p_visible_result_value kwfl_step_transactions.visible_result_value%type,
                                  p_user_comment         varchar2) return number is
    l_group_id     kwfl_transactions_int.group_id%type;
    l_message_type number;
    l_message_name varchar2(100);
    l_message      varchar2(2000);
  begin
    l_group_id := kcrt_request_int.get_next_group_id();
    kwfl_txn_int.insert_row(p_event                 => 'FORCE_TRANSITION',
                            p_group_id              => l_group_id,
                            p_created_username      => p_username,
                            p_source                => null,
                            p_request_number        => p_request_id,
                            p_package_number        => null,
                            p_package_line_seq      => null,
                            p_workflow_step_seq     => p_from_step_number,
                            p_workflow_step_name    => p_from_step_name,
                            p_visible_result_value  => p_visible_result_value,
                            p_user_comments         => p_user_comment,
                            p_delegated_to_username => null,
                            p_schedule_date         => null,
                            p_to_workflow_step_name => p_to_step_name,
                            p_to_workflow_step_seq  => p_to_step_number,
                            O_MESSAGE_TYPE          => l_message_type,
                            O_MESSAGE_NAME          => l_message_name,
                            O_MESSAGE               => l_message);
    if (l_message_type != knta_constant.SUCCESS) then
      raise BETEO_TXN_INTERFACE_EX;
    end if;
    kwfl_txn_int.run_interface(P_GROUP_ID     => l_group_id,
                               P_SOURCE       => null,
                               P_USER_ID      => 1,
                               P_USR_DBG      => knta_constant.DEBUG_ALL,
                               O_MESSAGE_TYPE => l_message_type,
                               O_MESSAGE_NAME => l_message_name,
                               O_MESSAGE      => l_message);
    if (l_message_type != knta_constant.SUCCESS) then
      raise BETEO_TXN_INTERFACE_EX;
    end if;
    dbms_output.put_line('decision_vote_variable() completed successfully');
    return BETEO_OK;
  exception
    when BETEO_TXN_INTERFACE_EX then
      dbms_output.put_line('ERROR: decision_vote() FAILED');
      dbms_output.put_line('ERROR: Message Name: ' || l_message_name);
      dbms_output.put_line('ERROR:      Message: ' || l_message);
      return BETEO_ERROR;
    when others then
      dbms_output.put_line('ERROR: decision_vote() FAILED');
      dbms_output.put_line('ERROR: SQLCODE : ' || sqlcode);
      dbms_output.put_line('ERROR:  SQLMSG : ' || sqlerrm);
      return BETEO_ERROR;
  end;

  -------------------------------------------------------------------------------------------------
  function add_note_to_request(p_request_id kcrt_requests.request_id%type,
                               p_username   knta_users.username%type,
                               p_note_text  varchar2) return number is
    cursor c_get_request_status(cp_request_id kcrt_requests.request_id%type) is
      select s.status_id, s.status_name
        from kcrt_requests r, kcrt_statuses s
       where r.request_id = cp_request_id
         and r.status_id = s.status_id(+);
    l_req_status c_get_request_status%rowtype;
    l_user_id    knta_users.user_id%type;
    BETEO_REQ_NOT_FOUND exception;
    l_sql_statement number;
  begin
    savepoint BETEO_KCRT_1;
    -- 1. Check whether request exists
    l_sql_statement := 100;
    open c_get_request_status(p_request_id);
    fetch c_get_request_status
      into l_req_status;
    if (c_get_request_status%notfound) then
      raise BETEO_REQ_NOT_FOUND;
    end if;
    close c_get_request_status;
    -- 2. Check if user exists
    l_sql_statement := 200;
    select u.user_id
      into l_user_id
      from knta_users u
     where u.username = p_username;
    -- 3. Add note entry
    l_sql_statement := 300;
    insert into knta_note_entries
      (note_entry_id,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       parent_entity_id,
       parent_entity_primary_key,
       author_id,
       authored_date,
       note_context_value,
       note_context_visible_value,
       note)
    values
      (knta_note_entries_s.nextval,
       sysdate,
       l_user_id,
       sysdate,
       l_user_id,
       20 -- Request
      ,
       p_request_id,
       l_user_id,
       sysdate,
       l_req_status.status_id,
       l_req_status.status_name,
       p_note_text);
    -- 4. Update Request Last Update Date (make cache aware of changes)
    l_sql_statement := 400;
    update kcrt_requests r
       set r.entity_last_update_date = sysdate,
           r.last_update_date        = sysdate,
           r.last_updated_by         = l_user_id
     where r.request_id = p_request_id;
    return BETEO_OK;
  exception
    when BETEO_REQ_NOT_FOUND then
      close c_get_request_status;
      rollback to savepoint BETEO_KCRT_1;
      dbms_output.put_line('ERROR: BETEO_kcrt_util.add_note_to_request(REQUEST_ID=' ||
                           p_request_id || ')');
      dbms_output.put_line('ERROR: Request not found.');
      return BETEO_ERROR;
    when NO_DATA_FOUND then
      rollback to savepoint BETEO_KCRT_1;
      dbms_output.put_line('ERROR: BETEO_kcrt_util.add_note_to_request(REQUEST_ID=' ||
                           p_request_id || ',USERNAME="' || p_username || '")');
      dbms_output.put_line('ERROR: User not found.');
      return BETEO_ERROR;
    when others then
      rollback to savepoint BETEO_KCRT_1;
      dbms_output.put_line('ERROR: BETEO_kcrt_util.add_note_to_request(REQUEST_ID=' ||
                           p_request_id || ') statement = ' ||
                           l_sql_statement);
      dbms_output.put_line('ERROR: SQLCODE : ' || sqlcode);
      dbms_output.put_line('ERROR:  SQLMSG : ' || sqlerrm);
      return BETEO_ERROR;
  end;

  -------------------------------------------------------------------------
  function set_assigned_user(p_request_id kcrt_requests.request_id%type,
                             p_user_id    knta_users.user_id%type)
    return varchar2 is
  begin
    update kcrt_requests r
       set r.entity_last_update_date = sysdate,
           r.assigned_to_user_id     = p_user_id
     where r.request_id = p_request_id;
    return 'SUCCESS';
  exception
    when others then
      dbms_output.put_line('ERROR: set_assigned_user() FAILED');
      dbms_output.put_line('ERROR: SQLCODE : ' || sqlcode);
      dbms_output.put_line('ERROR:  SQLMSG : ' || sqlerrm);
      return 'FAILURE';
  end set_assigned_user;

  ---------------------------------------------------------------------------
  function set_assigned_group(p_request_id kcrt_requests.request_id%type,
                              p_group_id   knta_security_groups.security_group_id%type)
    return varchar2 is
  begin
    update kcrt_requests r
       set r.entity_last_update_date = sysdate,
           r.assigned_to_group_id    = p_group_id
     where r.request_id = p_request_id;
    return 'SUCCESS';
  exception
    when others then
      dbms_output.put_line('ERROR: set_assigned_group() FAILED');
      dbms_output.put_line('ERROR: SQLCODE : ' || sqlcode);
      dbms_output.put_line('ERROR:  SQLMSG : ' || sqlerrm);
      return 'FAILURE';
  end set_assigned_group;

  -----------------------------------------------------------------------------
  function append_table_entry(p_request_id          kcrt_requests.request_id%type,
                              p_field_token         knta_parameter_set_fields.parameter_token%type,
                              p_parameter1          kcrt_table_entries.parameter1%type,
                              p_parameter2          kcrt_table_entries.parameter1%type,
                              p_parameter3          kcrt_table_entries.parameter1%type,
                              p_parameter4          kcrt_table_entries.parameter1%type,
                              p_parameter5          kcrt_table_entries.parameter1%type,
                              p_parameter6          kcrt_table_entries.parameter1%type,
                              p_parameter7          kcrt_table_entries.parameter1%type,
                              p_parameter8          kcrt_table_entries.parameter1%type,
                              p_parameter9          kcrt_table_entries.parameter1%type,
                              p_parameter10         kcrt_table_entries.parameter1%type,
                              p_parameter11         kcrt_table_entries.parameter1%type,
                              p_parameter12         kcrt_table_entries.parameter1%type,
                              p_parameter13         kcrt_table_entries.parameter1%type,
                              p_parameter14         kcrt_table_entries.parameter1%type,
                              p_parameter15         kcrt_table_entries.parameter1%type,
                              p_parameter16         kcrt_table_entries.parameter1%type,
                              p_parameter17         kcrt_table_entries.parameter1%type,
                              p_parameter18         kcrt_table_entries.parameter1%type,
                              p_parameter19         kcrt_table_entries.parameter1%type,
                              p_parameter20         kcrt_table_entries.parameter1%type,
                              p_parameter21         kcrt_table_entries.parameter1%type,
                              p_parameter22         kcrt_table_entries.parameter1%type,
                              p_parameter23         kcrt_table_entries.parameter1%type,
                              p_parameter24         kcrt_table_entries.parameter1%type,
                              p_parameter25         kcrt_table_entries.parameter1%type,
                              p_parameter26         kcrt_table_entries.parameter1%type,
                              p_parameter27         kcrt_table_entries.parameter1%type,
                              p_parameter28         kcrt_table_entries.parameter1%type,
                              p_parameter29         kcrt_table_entries.parameter1%type,
                              p_parameter30         kcrt_table_entries.parameter1%type,
                              p_parameter31         kcrt_table_entries.parameter1%type,
                              p_parameter32         kcrt_table_entries.parameter1%type,
                              p_parameter33         kcrt_table_entries.parameter1%type,
                              p_parameter34         kcrt_table_entries.parameter1%type,
                              p_parameter35         kcrt_table_entries.parameter1%type,
                              p_parameter36         kcrt_table_entries.parameter1%type,
                              p_parameter37         kcrt_table_entries.parameter1%type,
                              p_parameter38         kcrt_table_entries.parameter1%type,
                              p_parameter39         kcrt_table_entries.parameter1%type,
                              p_parameter40         kcrt_table_entries.parameter1%type,
                              p_parameter41         kcrt_table_entries.parameter41%type,
                              p_parameter42         kcrt_table_entries.parameter41%type,
                              p_parameter43         kcrt_table_entries.parameter41%type,
                              p_parameter44         kcrt_table_entries.parameter41%type,
                              p_parameter45         kcrt_table_entries.parameter41%type,
                              p_parameter46         kcrt_table_entries.parameter41%type,
                              p_parameter47         kcrt_table_entries.parameter41%type,
                              p_parameter48         kcrt_table_entries.parameter41%type,
                              p_parameter49         kcrt_table_entries.parameter41%type,
                              p_parameter50         kcrt_table_entries.parameter41%type,
                              p_visible_parameter1  kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter2  kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter3  kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter4  kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter5  kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter6  kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter7  kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter8  kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter9  kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter10 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter11 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter12 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter13 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter14 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter15 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter16 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter17 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter18 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter19 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter20 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter21 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter22 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter23 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter24 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter25 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter26 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter27 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter28 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter29 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter30 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter31 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter32 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter33 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter34 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter35 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter36 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter37 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter38 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter39 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter40 kcrt_table_entries.visible_parameter1%type,
                              p_visible_parameter41 kcrt_table_entries.visible_parameter41%type,
                              p_visible_parameter42 kcrt_table_entries.visible_parameter41%type,
                              p_visible_parameter43 kcrt_table_entries.visible_parameter41%type,
                              p_visible_parameter44 kcrt_table_entries.visible_parameter41%type,
                              p_visible_parameter45 kcrt_table_entries.visible_parameter41%type,
                              p_visible_parameter46 kcrt_table_entries.visible_parameter41%type,
                              p_visible_parameter47 kcrt_table_entries.visible_parameter41%type,
                              p_visible_parameter48 kcrt_table_entries.visible_parameter41%type,
                              p_visible_parameter49 kcrt_table_entries.visible_parameter41%type,
                              p_visible_parameter50 kcrt_table_entries.visible_parameter41%type)
    return varchar2 is
    l_field_context_id knta_parameter_set_contexts.parameter_set_context_id%type;
    l_field_id         knta_parameter_set_fields.parameter_set_field_id%type;
    l_field_par_no     knta_parameter_set_fields.parameter_column_number%type;
    l_field_batch_no   knta_parameter_set_fields.batch_number%type;
    l_entrycount       number;
    l_sql              varchar2(32767);
    l_entrytext        varchar2(100);
    l_cursor           number := null;
    l_rows             number;
  begin
    -- Determine table component parameter field/context/parameter number
    begin
      select psc2.parameter_set_context_id,
             psf.parameter_column_number,
             psf.batch_number,
             psf.parameter_set_field_id
        into l_field_context_id,
             l_field_par_no,
             l_field_batch_no,
             l_field_id
        from knta_parameter_set_fields   psf,
             knta_parameter_set_contexts psc,
             knta_parameter_set_contexts psc2 -- Context of table columns
            ,
             kcrt_request_types          rt,
             kcrt_requests               r
       where psf.parameter_token = p_field_token
         and psc.parameter_set_context_id = psf.parameter_set_context_id
         and psc.entity_id = 19
         and psc.context_value = rt.request_type_id
         and r.request_type_id = rt.request_type_id
         and r.request_id = p_request_id
         and psc2.context_value = to_char(psf.validation_id)
         and psc2.entity_id = 13;
    exception
      when no_data_found then
        dbms_output.put_line('ERROR: No Table Component found for Token="' ||
                             p_field_token || '" in request #' ||
                             p_request_id || '.');
        dbms_output.put_line('Possible Cause: Misspelled Token.');
        dbms_output.put_line('Possible Cause: Table Component not defined in Request Type Details.');
        return 'FAILURE';
    end;
    -- Determine number of entries for table component
    select count(*)
      into l_entrycount
      from kcrt_table_entries te
     where te.request_id = p_request_id
       and te.parameter_set_field_id = l_field_id
       and te.parameter_set_context_id = l_field_context_id;
    -- Append table entry to table
    insert into kcrt_table_entries
      (table_entry_id,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       request_id,
       parameter_set_field_id,
       seq,
       parameter_set_context_id,
       visible_parameter1,
       visible_parameter2,
       visible_parameter3,
       visible_parameter4,
       visible_parameter5,
       visible_parameter6,
       visible_parameter7,
       visible_parameter8,
       visible_parameter9,
       visible_parameter10,
       visible_parameter11,
       visible_parameter12,
       visible_parameter13,
       visible_parameter14,
       visible_parameter15,
       visible_parameter16,
       visible_parameter17,
       visible_parameter18,
       visible_parameter19,
       visible_parameter20,
       visible_parameter21,
       visible_parameter22,
       visible_parameter23,
       visible_parameter24,
       visible_parameter25,
       visible_parameter26,
       visible_parameter27,
       visible_parameter28,
       visible_parameter29,
       visible_parameter30,
       visible_parameter31,
       visible_parameter32,
       visible_parameter33,
       visible_parameter34,
       visible_parameter35,
       visible_parameter36,
       visible_parameter37,
       visible_parameter38,
       visible_parameter39,
       visible_parameter40,
       visible_parameter41,
       visible_parameter42,
       visible_parameter43,
       visible_parameter44,
       visible_parameter45,
       visible_parameter46,
       visible_parameter47,
       visible_parameter48,
       visible_parameter49,
       visible_parameter50,
       parameter1,
       parameter2,
       parameter3,
       parameter4,
       parameter5,
       parameter6,
       parameter7,
       parameter8,
       parameter9,
       parameter10,
       parameter11,
       parameter12,
       parameter13,
       parameter14,
       parameter15,
       parameter16,
       parameter17,
       parameter18,
       parameter19,
       parameter20,
       parameter21,
       parameter22,
       parameter23,
       parameter24,
       parameter25,
       parameter26,
       parameter27,
       parameter28,
       parameter29,
       parameter30,
       parameter31,
       parameter32,
       parameter33,
       parameter34,
       parameter35,
       parameter36,
       parameter37,
       parameter38,
       parameter39,
       parameter40,
       parameter41,
       parameter42,
       parameter43,
       parameter44,
       parameter45,
       parameter46,
       parameter47,
       parameter48,
       parameter49,
       parameter50)
    values
      (kcrt_table_entries_s.nextval,
       60 -- Author unknown
      ,
       sysdate,
       60 -- Author unknown
      ,
       sysdate,
       p_request_id,
       l_field_id,
       l_entrycount + 1,
       l_field_context_id,
       p_visible_parameter1,
       p_visible_parameter2,
       p_visible_parameter3,
       p_visible_parameter4,
       p_visible_parameter5,
       p_visible_parameter6,
       p_visible_parameter7,
       p_visible_parameter8,
       p_visible_parameter9,
       p_visible_parameter10,
       p_visible_parameter11,
       p_visible_parameter12,
       p_visible_parameter13,
       p_visible_parameter14,
       p_visible_parameter15,
       p_visible_parameter16,
       p_visible_parameter17,
       p_visible_parameter18,
       p_visible_parameter19,
       p_visible_parameter20,
       p_visible_parameter21,
       p_visible_parameter22,
       p_visible_parameter23,
       p_visible_parameter24,
       p_visible_parameter25,
       p_visible_parameter26,
       p_visible_parameter27,
       p_visible_parameter28,
       p_visible_parameter29,
       p_visible_parameter30,
       p_visible_parameter31,
       p_visible_parameter32,
       p_visible_parameter33,
       p_visible_parameter34,
       p_visible_parameter35,
       p_visible_parameter36,
       p_visible_parameter37,
       p_visible_parameter38,
       p_visible_parameter39,
       p_visible_parameter40,
       p_visible_parameter41,
       p_visible_parameter42,
       p_visible_parameter43,
       p_visible_parameter44,
       p_visible_parameter45,
       p_visible_parameter46,
       p_visible_parameter47,
       p_visible_parameter48,
       p_visible_parameter49,
       p_visible_parameter50,
       p_parameter1,
       p_parameter2,
       p_parameter3,
       p_parameter4,
       p_parameter5,
       p_parameter6,
       p_parameter7,
       p_parameter8,
       p_parameter9,
       p_parameter10,
       p_parameter11,
       p_parameter12,
       p_parameter13,
       p_parameter14,
       p_parameter15,
       p_parameter16,
       p_parameter17,
       p_parameter18,
       p_parameter19,
       p_parameter20,
       p_parameter21,
       p_parameter22,
       p_parameter23,
       p_parameter24,
       p_parameter25,
       p_parameter26,
       p_parameter27,
       p_parameter28,
       p_parameter29,
       p_parameter30,
       p_parameter31,
       p_parameter32,
       p_parameter33,
       p_parameter34,
       p_parameter35,
       p_parameter36,
       p_parameter37,
       p_parameter38,
       p_parameter39,
       p_parameter40,
       p_parameter41,
       p_parameter42,
       p_parameter43,
       p_parameter44,
       p_parameter45,
       p_parameter46,
       p_parameter47,
       p_parameter48,
       p_parameter49,
       p_parameter50);
    -- Increase entry count
    l_entrycount := l_entrycount + 1;
    if l_entrycount = 1 then
      l_entrytext := '1 Entry';
    else
      l_entrytext := l_entrycount || ' Entries';
    end if;
    l_sql    := 'update kcrt_request_details rd set rd.parameter' ||
                l_field_par_no || ' = ' || l_entrycount ||
                ' ,rd.visible_parameter' || l_field_par_no || ' = ''' ||
                l_entrytext || '''' || ' where rd.request_id = ' ||
                p_request_id || ' and rd.batch_number = ' ||
                l_field_batch_no;
    l_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(c             => l_cursor,
                   statement     => l_sql,
                   language_flag => dbms_sql.native);
    l_rows := dbms_sql.execute(c => l_cursor);
    if (l_rows <> 1) then
      dbms_output.put_line('WARNING: Number of updated rows does not equal 1.');
    end if;
    dbms_sql.close_cursor(c => l_cursor);
    -- Update request last update date
    update kcrt_requests r
       set r.entity_last_update_date = sysdate
     where r.request_id = p_request_id;
    dbms_output.put_line('Line successfully added to table.');
    return 'SUCCESS';
  exception
    when others then
      dbms_output.put_line('ERROR: Cannot append row to table for Token="' ||
                           p_field_token || '" in request #' ||
                           p_request_id || '.');
      dbms_output.put_line('ERROR: ' || sqlerrm);
      if (dbms_sql.is_open(c => l_cursor)) then
        dbms_sql.close_cursor(c => l_cursor);
      end if;
      return 'FAILURE';
  end append_table_entry;

end BETEO_KCRT_UTIL;
/
 