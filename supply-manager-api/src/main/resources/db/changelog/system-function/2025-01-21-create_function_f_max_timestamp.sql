--liquibase formatted sql
--changeset eshardakov:create_function_f_max_timestamp runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Функция, которая возвращает максимальную дату ("конец времен").

create or replace function supply_manager.f_max_timestamp()
 returns timestamp without time zone
 language plpgsql
 immutable
as $function$
declare
    c_max_timestamp constant timestamp(6) := to_timestamp('2999-12-31 23:59:59.999999',
                                                          'yyyy-mm-dd hh24:mi:ss.us');
begin
    return c_max_timestamp;
end;
$function$;
/