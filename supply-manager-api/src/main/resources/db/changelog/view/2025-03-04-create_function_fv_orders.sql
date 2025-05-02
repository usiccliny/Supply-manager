--liquibase formatted sql
--changeset eshardakov:create_function_fv_orders_with_supplier_and_user runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Параметризованное представление для заказов с фильтрацией по поставщику и пользователю.

drop function if exists supply_manager.fv_orders(int8, date, int8);

create or replace function supply_manager.fv_orders(
    p_user_id int8 default null, 
    i_date date default null,
    p_supplier_id int8 default null
)
returns table (
        order_id         int8,
        user_id          int8,
        order_date       timestamp,
        order_status     text,
        total_amount     numeric,
        shipping_address text,
        billing_address  text,
        payment_method   text,
        tracking_number  text,
        notes            text
)
as $$
/*
 * version: 1.2
 * date: 2025-03-04
 * author: eshardakov
 * description: АРМ Менеджер по поставкам. Параметризованное представление для заказов с фильтрацией по поставщику и пользователю.
 * version: 1.2, eshardakov, 2025-03-04 - Добавлена фильтрация по поставщику и опциональность параметра user_id.
 */
begin
return query
    select distinct o.id as order_id
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
      left join supply_manager.order_detail od
        on o.id = od.order_id
      left join supply_manager.product p
        on od.product_id = p.id
     where case
               when i_date is null
               then not o.obsolete
               else o.begin_ts::date = i_date
           end
       and (p_user_id is null or u.id = p_user_id)
       and (p_supplier_id is null or p.supplier_id = p_supplier_id);
end;
$$ language plpgsql;
/

/* Пример использования
   
   -- Все заказы за все время
   select * from supply_manager.fv_orders();

   -- Заказы пользователя с ID 7
   select * from supply_manager.fv_orders(7);

   -- Заказы за определенную дату
   select * from supply_manager.fv_orders(null, '2025-03-01');

   -- Заказы пользователя с ID 7 за определенную дату
   select * from supply_manager.fv_orders(7, '2025-03-01');

   -- Заказы, включающие товары от поставщика с ID 5
   select * from supply_manager.fv_orders(null, null, 62);

   -- Заказы пользователя с ID 7, включающие товары от поставщика с ID 5
   select * from supply_manager.fv_orders(7, null, 5);

   -- Заказы за определенную дату, включающие товары от поставщика с ID 5
   select * from supply_manager.fv_orders(null, '2025-03-01', 62);

   -- Заказы пользователя с ID 7 за определенную дату, включающие товары от поставщика с ID 5
   select * from supply_manager.fv_orders(7, '2025-03-01', 5);
 */

comment on function supply_manager.fv_orders(int8, date, int8) is 'Параметризованное представление для заказов с фильтрацией по поставщику и пользователю';