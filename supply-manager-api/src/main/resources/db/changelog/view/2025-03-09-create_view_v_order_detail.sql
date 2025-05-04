--liquibase formatted sql
--changeset eshardakov:create_function_fv_order_detail runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Параметризованное представление для детализации заказов с учетом роли пользователя.

drop function if exists supply_manager.fv_order_detail(int8, int8);

create or replace function supply_manager.fv_order_detail(
    i_order_id int8, -- Идентификатор заказа
    role int8        -- Роль пользователя (3 - покупатель, 4 - поставщик)
)
returns table (
    order_detail_id int8,
    order_id int8,
    user_id int8,
    supplier_id int8,
    product_id int8,
    product_name text,
    contact_person text,
    contact_data text,
    price numeric,
    quantity int8
)
as $$
/*
 * version: 1.2
 * date: 2025-03-09
 * author: eshardakov
 * description: АРМ Менеджер по поставкам. Параметризованное представление для детализации заказов с учетом роли пользователя.
 * version: 1.2, eshardakov, 2025-03-09 - Добавлена фильтрация по роли и пользователю.
 */
begin
    return query
        with supplier_c as (
             select s.supplier_id,
                    u.id
               from supply_manager.user u
               join supply_manager.supplier s
                 on s.email = u.email
              where not u.obsolete
                and not s.obsolete
        )
        select 
            od.id as order_detail_id,
            od.order_id,
            case 
                when role = 4 then u.id -- Показываем ID пользователя для поставщика
                else null
            end as user_id,
            case 
                when role = 3 then sc.id -- Показываем ID поставщика для покупателя
                else null
            end as supplier_id,
            od.product_id,
            p.product_name,
            case
                when role = 3 then s.contact_person -- Показываем контактное лицо поставщика для покупателя
                when role = 4 then u.username       -- Показываем имя пользователя для поставщика
                else null
            end as contact_person,
            case
                when role = 3 then s.phone_number  -- Показываем телефон поставщика для покупателя
                when role = 4 then u.email         -- Показываем email пользователя для поставщика
                else null
            end as contact_data,
            p.price,
            od.quantity
        from 
            supply_manager.order_detail od
        join 
            supply_manager.product p
            on od.product_id = p.id
            and not p.obsolete
        join 
            supply_manager.supplier s
            on s.supplier_id = od.supplier_id
            and not s.obsolete
        join 
            supplier_c sc
            on sc.supplier_id = s.supplier_id
        left join 
            supply_manager."order" o
            on od.order_id = o.id
            and not o.obsolete
        left join 
            supply_manager."user" u
            on o.user_id = u.id
            and not u.obsolete
        where 
            not od.obsolete
            and o.id = i_order_id;
end;
$$ language plpgsql;
/

/* Пример использования
   
   -- Для роли 3 (покупатель): информация о поставщике
   select * from supply_manager.fv_order_detail(30, 3);

   -- Для роли 4 (поставщик): информация о пользователе
   select * from supply_manager.fv_order_detail(30, 4);
 */

comment on function supply_manager.fv_order_detail(int8, int8) is 'Параметризованное представление для детализации заказов с учетом роли пользователя';