
  CREATE OR REPLACE FUNCTION "PPMC"."FLATTEN_QUERY_RESULT" (
  p_query       varchar2
  ,p_separator  varchar2
) return varchar2 is
  l_result varchar2(4000);
  l_row    varchar2(2000);
  l_cursor integer;
  l_rows   integer;
begin
  l_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor, p_query, dbms_sql.native);
  dbms_sql.define_column_char(l_cursor, 1, l_row, 2000);
  l_rows := dbms_sql.execute_and_fetch(l_cursor);
  while (l_rows > 0) loop
    dbms_sql.column_value_char(l_cursor, 1, l_row);
    if (l_result is null) then
      l_result := trim(l_row);
    else
      l_result := l_result || p_separator || trim(l_row);
    end if;
    l_rows := dbms_sql.fetch_rows(l_cursor);
  end loop;
  dbms_sql.close_cursor(l_cursor);

  return l_result;
end flatten_query_result;
/
 