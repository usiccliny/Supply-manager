--liquibase formatted sql
--changeset eshardakov:create_function_fv_suppliers runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Параметризованное представление для Поставщиков.

create or replace function supply_manager.fv_suppliers(p_user_id int8)
returns table (
        supplier_id      int8
      , user_id          int8
      , contact_person   text
      , phone_number     text
      , email            text
      , address          text
      , company_id       int8
      , company_name     text
      , post_name        text
      , post_short_name  text
        )
as $$
/*
 * version: 1.0
 * date: 2025-03-04
 * author: eshardakov
 * description: АРМ Менеджер по поставкам. Параметризованное представление для Поставщиков.
 * version: 1.0, eshardakov, 2025-03-04 - Первоначальное создание.
 */
begin
return query
    select distinct
           s.supplier_id
         , u.id as user_id
         , s.contact_person
         , s.phone_number
         , s.email
         , s.address
         , c.id as company_id
         , c.name as company_name
         , p.name as post_name
         , p.short_name as post_short_name
      from supply_manager.supplier s
      join supply_manager.sp_post p
        on p.id = s.post_id
      join supply_manager.company c
        on c.id = s.company_id
       and not c.obsolete
      join supply_manager.order_detail od
        on od.supplier_id = s.supplier_id
       and not od.obsolete
      join supply_manager.order o
        on o.id = od.order_id
       and not o.obsolete
      join supply_manager.user u
        on u.id = o.user_id
       and not u.obsolete
     where not s.obsolete
       and u.id = p_user_id;
end;
$$ language plpgsql;
/

/* Пример использования
   
   select * from supply_manager.fv_suppliers(7)
 */

comment on function supply_manager.fv_suppliers(int8) is 'Параметризованное представление для Поставщиков';