--liquibase formatted sql
--changeset eshardakov:create_function_fv_orders runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Параметризованное представление для заказов.

drop function supply_manager.fv_orders (int8, date);

create or replace function supply_manager.fv_orders(p_user_id int8, i_date date default null )
returns table (
        order_id         int8
      , user_id          int8
      , order_date       timestamp
      , order_status     text
      , total_amount     numeric
      , shipping_address text
      , billing_address  text
      , payment_method   text
      , tracking_number  text
      , notes            text
        )
as $$
/*
 * version: 1.0
 * date: 2025-03-04
 * author: eshardakov
 * description: АРМ Менеджер по поставкам. Параметризованное представление для заказов.
 * version: 1.0, eshardakov, 2025-03-04 - Первоначальное создание.
 */
begin
return query
    select o.id as order_id
         , u.id as user_id
         , o.order_date
         , os.name as order_status
         , o.total_amount
         , o.shipping_address
         , o.billing_address
         , pm.name as payment_method
         , o.tracking_number
         , o.notes
      from supply_manager.order o
      join supply_manager.user u
        on o.user_id = u.id
      join supply_manager.sp_order_status os
        on o.order_status_id = os.id
      join supply_manager.sp_payment_method pm
        on pm.id = o.payment_method_id
     where case
               when i_date is null
               then not o.obsolete
               else o.begin_ts::date = i_date
           end
       and u.id = p_user_id; 
end;
$$ language plpgsql;
/

/* Пример использования
   
   select * from supply_manager.fv_orders(7)
 */

comment on function supply_manager.fv_orders(int8, date) is 'Параметризованное представление для заказов';