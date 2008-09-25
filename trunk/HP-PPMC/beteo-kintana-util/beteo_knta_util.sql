
  CREATE OR REPLACE PACKAGE "PPMC"."BETEO_KNTA_UTIL" is

  -- Author  : TOR_NEU
  -- Created : 12.03.2004 15:13:57
  -- Version : $Id: beteo_knta_util.pck,v 1.7 2006/03/01 20:38:07 tor_neu Exp $
  -- Purpose : Helper functions for Kintana

  /* History

    Date        Author     Description
    -------------------------------------------------------------------------------------------------------
    03.02.2005  Torsten    Added functions get_username()
                                           add_note_entry()
    15.02.2005  Torsten    Added function debug()
    02.03.2005  Torsten    Added function is_date_in_period_range()
    16.02.2006  Torsten    Added functions work_alloc_allow_user_access()
                                           work_alloc_restrict_user_access()
                                           work_alloc_allow_group_access()
                                           work_alloc_restrict_group_access()
    01.03.2006  Torsten    Support user-defined separator in multi-value-list
  */

  -----------------------------------------------------------------------
  -- Helper functions to iterate through Kintana multi-valued fields
  --
  -- (mvl = multi-value-list)
  --
  -- Usage:
  --   my_mvl := mvl_create('Item-1#@#Item-2#@#Item-3');
  --   my_item := mvl_get_first(my_mvl);
  --   while (my_item is not null) loop
  --     -- do something with my_item
  --     my_item := mvl_get_next(my_mvl);
  --   end loop;
  -----------------------------------------------------------------------

  -- Public type declarations
  type t_mvl is record(
     complete_list VARCHAR2(2000)
    ,current_list  VARCHAR2(2000)
    ,separator     VARCHAR2(10));

  -- Public function and procedure declarations
  function mvl_create(p_mv_string VARCHAR2
                     ,p_separator VARCHAR2 DEFAULT NULL) return t_mvl;

  function mvl_is_empty(p_mvl IN t_mvl) return BOOLEAN;

  function mvl_get_first(p_mvl IN OUT t_mvl) return VARCHAR2;

  function mvl_get_next(p_mvl IN OUT t_mvl) return VARCHAR2;

  /* Get user id for username.
  */
  function get_user_id(p_username knta_users.username%TYPE)
    return knta_users.user_id%TYPE;

  /* Get username for user id.
  */
  function get_username(p_user_id knta_users.user_id%TYPE)
    return knta_users.username%TYPE;

  -----------------------------------------------------------------------
  -- sg_get_first_user()
  --
  -- returns the user name of the first user in a security group or
  -- NULL if the security group has no members
  -----------------------------------------------------------------------
  function sg_get_first_user(p_security_group_name knta_security_groups.security_group_name%TYPE)
    return knta_users.username%TYPE;

  /* Returns the period id of the time period of the given type which includes
  * the start date.
  *
  * #param p_period_type The period type of the period that is to be found. Possible values:
  *                      {*} FISCAL_MONTH
  * #param p_start_date  Start date which must be in the period.
  *
  * #return Identifier of period in table KNTA_PERIODS. Throws no_data_found exception
  *         if no period with the given spec can be found.
  */
  function get_period_for_start_date(p_period_type knta_periods.period_type%TYPE
                                    ,p_start_date  DATE)
    return knta_periods.period_id%TYPE;
  pragma restrict_references(get_period_for_start_date, WNDS, WNPS, RNPS);

  /*
  * Returns the sequence number of the first period which starts on or after p_start_date.
  *
  *   #param p_period_type    YEAR, MONTH, FISCAL_YEAR, FISCAL_MONTH, ...
  *   #param p_start_date     start date of the period or a date before the start date
  */
  function get_period_seq(p_period_type knta_periods.period_type%TYPE
                         ,p_start_date  DATE) return NUMBER;

  /* Returns the period id for a given seqence and period type
  *
  */
  function get_period_id_for_seq(p_seq         in knta_periods.seq%TYPE
                                ,p_period_type in knta_periods.period_type%TYPE)
    return knta_periods.period_id%TYPE;

  /*
  * Adds notes to an ITG object.
  *
  * #param p_parent_entity_id  Here are a few examples of entities (full list in table knta_entities)
  *                             # 1 Package
  *                             # 20 Request
  *                             # 309 Staffing Profile
  * #param p_parent_entity_primary_key The Primary key of the parent entity (e.g. Package ID)
  * #param p_username The username of the user adding the note. If null, "Author Unknown".
  * #param p_note     The note text to be added.
  */
  procedure add_note_entry(p_parent_entity_id          knta_note_entries.parent_entity_id%TYPE
                          ,p_parent_entity_primary_key knta_note_entries.parent_entity_primary_key%TYPE
                          ,p_username                  knta_users.username%TYPE DEFAULT NULL
                          ,p_note                      VARCHAR2);

  procedure debug(p_function_name varchar2, p_message varchar2);

  /*
  * Returns TRUE if the date is between the start and end periods, FALSE otherwise and NULL upon error.
  *
  * #param p_date  The date that needs to be checked.
  * #param p_start_period_id
  * #param p_end_period_id
  *
  * #return TRUE if the date is between the start and end periods, FALSE otherwise and NULL upon error.
  */
  function is_date_in_period_range(p_date            DATE
                                  ,p_start_period_id knta_periods.period_id%TYPE
                                  ,p_end_period_id   knta_periods.period_id%TYPE)
    return BOOLEAN;

  /*
  * Allows access for the given user to the work allocation.
  *
  * #param p_work_alloc_type     Type of work allocation: REQUEST
  * #param p_work_allocation_id  ID of work allocation request
  * #param p_username            Username of the user that should get access
  *
  * #return Returns SUCCESS if successfully completed and FAILURE otherwise.
  */
  function work_alloc_allow_user_access(p_work_alloc_type VARCHAR2
                                       ,p_work_alloc_id   ktmg_work_allocations.work_allocation_id%TYPE
                                       ,p_username        knta_users.username%TYPE)
    return VARCHAR2;

  /*
  * Restricts access for the given user to the work allocation.
  *
  * #param p_work_alloc_type     Type of work allocation: REQUEST
  * #param p_work_allocation_id  ID of work allocation request
  * #param p_username            Username of the user that should have no access
  *
  * #return Returns SUCCESS if successfully completed and FAILURE otherwise.
  */
  function work_alloc_revoke_user_access(p_work_alloc_type VARCHAR2
                                        ,p_work_alloc_id   ktmg_work_allocations.work_allocation_id%TYPE
                                        ,p_username        knta_users.username%TYPE)
    return VARCHAR2;

  /*
  * Allows access for the given security group to the work allocation.
  *
  * #param p_work_alloc_type     Type of work allocation: REQUEST
  * #param p_work_allocation_id  ID of work allocation request
  * #param p_group_name          Name of the security group that should get access
  *
  * #return Returns SUCCESS if successfully completed and FAILURE otherwise.
  */
  function work_alloc_allow_group_access(p_work_alloc_type VARCHAR2
                                        ,p_work_alloc_id   ktmg_work_allocations.work_allocation_id%TYPE
                                        ,p_group_name      knta_security_groups.security_group_name%TYPE)
    return VARCHAR2;

  /*
  * Restricts access for the given security group to the work allocation.
  *
  * #param p_work_alloc_type     Type of work allocation: REQUEST
  * #param p_work_allocation_id  ID of work allocation request
  * #param p_group_name          Name of the security group that should have no access
  *
  * #return Returns SUCCESS if successfully completed and FAILURE otherwise.
  */
  function work_alloc_revoke_group_access(p_work_alloc_type VARCHAR2
                                         ,p_work_alloc_id   ktmg_work_allocations.work_allocation_id%TYPE
                                         ,p_group_name      knta_security_groups.security_group_name%TYPE)
    return VARCHAR2;

end beteo_KNTA_UTIL;
/
CREATE OR REPLACE PACKAGE BODY "PPMC"."BETEO_KNTA_UTIL" is

  c_separator constant VARCHAR2(10) := '#@#';

  function mvl_create(p_mv_string VARCHAR2, p_separator VARCHAR2)
    return t_mvl is
    l_mvl t_mvl;
  begin
    l_mvl.complete_list := p_mv_string;
    l_mvl.current_list  := NULL;
    if (p_separator is null) then
      l_mvl.separator := c_separator;
    else
      l_mvl.separator := p_separator;
    end if;

    return l_mvl;
  end mvl_create;

  function mvl_is_empty(p_mvl IN t_mvl) return BOOLEAN is
  begin
    if (p_mvl.complete_list is null) then
      return true;
    else
      if (length(p_mvl.complete_list) = 0) then
        return true;
      else
        return false;
      end if;
    end if;
  end mvl_is_empty;

  function mvl_get_first(p_mvl IN OUT t_mvl) return VARCHAR2 is
  begin
    if (mvl_is_empty(p_mvl)) then
      -- list is empty
      return NULL;
    else
      p_mvl.current_list := p_mvl.complete_list;

      return mvl_get_next(p_mvl);
    end if;
  end mvl_get_first;

  function mvl_get_next(p_mvl IN OUT t_mvl) return VARCHAR2 is
    l_item          VARCHAR2(2000);
    l_separator_pos NUMBER;
  begin
    l_item := NULL;

    if (p_mvl.current_list is not NULL) then
      -- there is at least one element
      l_separator_pos := instr(p_mvl.current_list, p_mvl.separator);
      if (l_separator_pos = 0) then
        -- only one element left
        l_item             := p_mvl.current_list;
        p_mvl.current_list := NULL;
      else
        -- more than one element left
        l_item             := substr(p_mvl.current_list
                                    ,1
                                    ,l_separator_pos - 1);
        p_mvl.current_list := substr(p_mvl.current_list
                                    ,l_separator_pos +
                                     length(p_mvl.separator));
      end if;
    end if;

    return l_item;
  end mvl_get_next;

  function sg_get_first_user(p_security_group_name knta_security_groups.security_group_name%TYPE)
    return knta_users.username%TYPE is
    cursor c_sg_get_users(cp_security_group_name knta_security_groups.security_group_name%TYPE) is
      select u.username
        from knta_users u, knta_security_groups sg, knta_user_security us
       where u.user_id = us.user_id and
             sg.security_group_id = us.security_group_id and
             sg.security_group_name = cp_security_group_name;
    l_username knta_users.username%TYPE;
  begin
    open c_sg_get_users(p_security_group_name);
    fetch c_sg_get_users
      into l_username;
    close c_sg_get_users;

    return l_username;
  end sg_get_first_user;

  -- Get user id for username
  function get_user_id(p_username knta_users.username%TYPE)
    return knta_users.user_id%TYPE is
    l_user_id knta_users.user_id%TYPE;
  begin
    select user_id
      into l_user_id
      from knta_users
     where username = p_username;
    return l_user_id;
  exception
    when no_data_found then
      return null;
  end get_user_id;

  -- Get username for user id
  function get_username(p_user_id knta_users.user_id%TYPE)
    return knta_users.username%TYPE is
    l_username knta_users.username%TYPE;
  begin
    select username
      into l_username
      from knta_users
     where user_id = p_user_id;
    return l_username;
  exception
    when no_data_found then
      return null;
  end get_username;

  -- Function and procedure implementations
  function get_period_seq(p_period_type knta_periods.period_type%TYPE
                         ,p_start_date  DATE) return NUMBER is
    l_seq knta_periods.seq%TYPE;
  begin
    if (p_start_date is null) then
      return null;
    end if;

    -- 2004-06-03: added min() function, so that lowest seq is returned
    select min(seq)
      into l_seq
      from knta_periods
     where start_date >= p_start_date and period_type = p_period_type;

    return l_seq;
  end get_period_seq;

  function get_period_for_start_date(p_period_type knta_periods.period_type%TYPE
                                    ,p_start_date  DATE)
    return knta_periods.period_id%TYPE is
    l_period_id knta_periods.period_id%TYPE;
  begin
    select p.period_id
      into l_period_id
      from knta_periods p
     where p.start_date <= p_start_date and p.end_date >= p_start_date and
           p.period_type = p_period_type;

    return l_period_id;
  end get_period_for_start_date;

  ------------------------------------------------------------------------------------------------------------
  -- get_period_id_for_seq() returns the period id for a given seqence and period type
  function get_period_id_for_seq(p_seq         in knta_periods.seq%TYPE
                                ,p_period_type in knta_periods.period_type%TYPE)
    return knta_periods.period_id%TYPE is
    l_period_id knta_periods.period_id%TYPE;
  begin
    select period_id
      into l_period_id
      from knta_periods
     where period_type = p_period_type and seq = p_seq;

    return l_period_id;
  exception
    when no_data_found then
      return null;
  end;

  ------------------------------------------------------------------------------------------------------------
  procedure add_note_entry(p_parent_entity_id          knta_note_entries.parent_entity_id%TYPE
                          ,p_parent_entity_primary_key knta_note_entries.parent_entity_primary_key%TYPE
                          ,p_username                  knta_users.username%TYPE
                          ,p_note                      VARCHAR2) is
    l_user_id knta_users.user_id%TYPE := NULL;
  begin
    -- 1. Verify user name
    if (p_username is not null) then
      l_user_id := get_user_id(p_username);
    end if;

    if (l_user_id is null) then
      l_user_id := 60; -- Author Unknown
    end if;

    -- 2. Add note entry
    insert into knta_note_entries
      (note_entry_id
      ,creation_date
      ,created_by
      ,last_update_date
      ,last_updated_by
      ,parent_entity_id
      ,parent_entity_primary_key
      ,author_id
      ,authored_date
      ,note_context_value
      ,note_context_visible_value
      ,note)
    values
      (knta_note_entries_s.nextval
      ,sysdate
      ,l_user_id
      ,sysdate
      ,l_user_id
      ,p_parent_entity_id
      ,p_parent_entity_primary_key
      ,l_user_id
      ,sysdate
      ,null
      ,null
      ,p_note);

  exception
    when others then
      return;
  end add_note_entry;

  procedure debug(p_function_name varchar2, p_message varchar2) is
  begin
    insert into beteo_messages
      (creation_date, function_name, message)
    values
      (to_char(systimestamp, 'YYYY-MM-DD HH24:MI:SS.FF3')
      ,p_function_name
      ,p_message);
  end;

  function is_date_in_period_range(p_date            DATE
                                  ,p_start_period_id knta_periods.period_id%TYPE
                                  ,p_end_period_id   knta_periods.period_id%TYPE)
    return BOOLEAN is
    l_return       BOOLEAN;
    l_start_period knta_periods%ROWTYPE;
    l_end_period   knta_periods%ROWTYPE;
  begin
    select *
      into l_start_period
      from knta_periods
     where period_id = p_start_period_id;

    select *
      into l_end_period
      from knta_periods
     where period_id = p_end_period_id;

    -- Check if period types are the same
    if (l_start_period.period_type != l_end_period.period_type) then
      return NULL;
    end if;

    -- Check if end period is greater than start period
    if (l_start_period.seq <= l_end_period.seq) then
      -- End period is greater than start period
      l_return := p_date between l_start_period.start_date and
                  l_end_period.end_date;
    else
      -- Start period is greater than end period
      l_return := p_date between l_end_period.start_date and
                  l_start_period.end_date;
    end if;

    return l_return;
  exception
    when no_data_found then
      return NULL;
  end is_date_in_period_range;

  -----------------------------------------------------------------------------------------------------------------------
  function work_alloc_allow_user_access(p_work_alloc_type VARCHAR2
                                       ,p_work_alloc_id   ktmg_work_allocations.work_allocation_id%TYPE
                                       ,p_username        knta_users.username%TYPE)
    return VARCHAR2 is
    l_entrycount         number;
    l_work_allocation_id ktmg_work_allocations.work_allocation_id%TYPE;
    l_user_id            knta_users.user_id%TYPE;
  begin
    -- check if entry already exists
    select count(wa.work_allocation_id)
      into l_entrycount
      from ktmg_work_allocations      wa
          ,ktmg_work_alloc_res_access wara
          ,knta_users                 u
     where wa.work_allocation_id = wara.work_allocation_id and
           u.username = p_username and
           wa.work_item_type_code = p_work_alloc_type and
           wa.work_item_id = p_work_alloc_id and
           wara.source_type_code = 'RESOURCE' and
           wara.source_id = u.user_id;

    if l_entrycount = 0 then
      select wa.work_allocation_id
        into l_work_allocation_id
        from ktmg_work_allocations wa
       where wa.work_item_type_code = p_work_alloc_type and
             wa.work_item_id = p_work_alloc_id;

      select user_id
        into l_user_id
        from knta_users u
       where u.username = p_username;

      insert into ktmg_work_alloc_res_access
        (work_alloc_res_access_id
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,work_allocation_id
        ,source_type_code
        ,source_id)
      values
        (ktmg_work_alloc_res_access_s.nextval
        ,sysdate
        ,60 -- Author Unknown
        ,sysdate
        ,60 -- Author Unknown
        ,l_work_allocation_id
        ,'RESOURCE'
        ,l_user_id);

      update ktmg_work_allocations wa
         set wa.entity_last_update_date  = sysdate
            ,wa.restrict_res_access_flag = 'Y'
       where wa.work_allocation_id = l_work_allocation_id;

    end if;

    return 'SUCCESS';
  exception
    when others then
      dbms_output.put_line('ERROR: ' || sqlerrm);
      return 'FAILURE';
  end work_alloc_allow_user_access;

  -----------------------------------------------------------------------------------------------------------------------
  function work_alloc_revoke_user_access(p_work_alloc_type VARCHAR2
                                        ,p_work_alloc_id   ktmg_work_allocations.work_allocation_id%TYPE
                                        ,p_username        knta_users.username%TYPE)
    return VARCHAR2 is
  begin
    delete from ktmg_work_alloc_res_access wara
     where wara.work_allocation_id =
           (select wa.work_allocation_id
              from ktmg_work_allocations wa
             where wa.work_item_type_code = p_work_alloc_type and
                   wa.work_item_id = p_work_alloc_id) and
           wara.source_type_code = 'RESOURCE' and
           wara.source_id =
           (select user_id from knta_users where username = p_username);

    return 'SUCCESS';
  exception
    when others then
      dbms_output.put_line('ERROR: ' || sqlerrm);
      return 'FAILURE';
  end work_alloc_revoke_user_access;

  -----------------------------------------------------------------------------------------------------------------------
  function work_alloc_allow_group_access(p_work_alloc_type VARCHAR2
                                        ,p_work_alloc_id   ktmg_work_allocations.work_allocation_id%TYPE
                                        ,p_group_name      knta_security_groups.security_group_name%TYPE)
    return VARCHAR2 is
    l_entrycount         number;
    l_work_allocation_id ktmg_work_allocations.work_allocation_id%TYPE;
    l_security_group_id  knta_security_groups.security_group_id%TYPE;
  begin
    -- check if entry already exists
    select count(wa.work_allocation_id)
      into l_entrycount
      from ktmg_work_allocations      wa
          ,ktmg_work_alloc_res_access wara
          ,knta_security_groups       sg
     where wa.work_allocation_id = wara.work_allocation_id and
           sg.security_group_name = p_group_name and
           wa.work_item_type_code = p_work_alloc_type and
           wa.work_item_id = p_work_alloc_id and
           wara.source_type_code = 'GROUP' and
           wara.source_id = sg.security_group_id;

    if l_entrycount = 0 then
      select wa.work_allocation_id
        into l_work_allocation_id
        from ktmg_work_allocations wa
       where wa.work_item_type_code = p_work_alloc_type and
             wa.work_item_id = p_work_alloc_id;

      select security_group_id
        into l_security_group_id
        from knta_security_groups
       where security_group_name = p_group_name;

      insert into ktmg_work_alloc_res_access
        (work_alloc_res_access_id
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,work_allocation_id
        ,source_type_code
        ,source_id)
      values
        (ktmg_work_alloc_res_access_s.nextval
        ,sysdate
        ,60 -- Author Unknown
        ,sysdate
        ,60 -- Author Unknown
        ,l_work_allocation_id
        ,'GROUP'
        ,l_security_group_id);

      update ktmg_work_allocations wa
         set wa.entity_last_update_date  = sysdate
            ,wa.restrict_res_access_flag = 'Y'
       where wa.work_allocation_id = l_work_allocation_id;

    end if;

    return 'SUCCESS';
  exception
    when others then
      dbms_output.put_line('ERROR: ' || sqlerrm);
      return 'FAILURE';
  end work_alloc_allow_group_access;

  -----------------------------------------------------------------------------------------------------------------------
  function work_alloc_revoke_group_access(p_work_alloc_type VARCHAR2
                                         ,p_work_alloc_id   ktmg_work_allocations.work_allocation_id%TYPE
                                         ,p_group_name      knta_security_groups.security_group_name%TYPE)
    return VARCHAR2 is
  begin
    delete from ktmg_work_alloc_res_access wara
     where wara.work_allocation_id =
           (select wa.work_allocation_id
              from ktmg_work_allocations wa
             where wa.work_item_type_code = p_work_alloc_type and
                   wa.work_item_id = p_work_alloc_id) and
           wara.source_type_code = 'GROUP' and
           wara.source_id =
           (select security_group_id
              from knta_security_groups
             where security_group_name = p_group_name);

    return 'SUCCESS';
  exception
    when others then
      dbms_output.put_line('ERROR: ' || sqlerrm);
      return 'FAILURE';
  end work_alloc_revoke_group_access;

end beteo_KNTA_UTIL;
/
 