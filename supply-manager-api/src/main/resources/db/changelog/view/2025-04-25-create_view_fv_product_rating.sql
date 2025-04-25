--liquibase formatted sql
--changeset eshardakov:create_function_fv_product_rating runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Параметризованное представление для Рейтинга товаров.

create or replace function supply_manager.fv_product_rating(
    i_product_category text 
)
returns table (
    product_id int8,
    product_name text,
    total_rating numeric,
    total_rank int8
)
as $$
declare
    max_price numeric;
    min_price numeric; 
    max_orders numeric;
    max_completed_orders numeric; 
    max_attributes numeric;
begin
    -- 1. Определяем максимальные и минимальные значения для нормализации
    select
        max(p.price),
        min(p.price),
        max(od.total_orders),
        max(od.completed_orders),
        max(pa.attribute_count)
    into
        max_price,
        min_price,
        max_orders,
        max_completed_orders,
        max_attributes
    from supply_manager.product p
    left join lateral (
        select
            count(*) as total_orders,
            sum(case when o.order_status_id = 4 then 1 else 0 end) as completed_orders
        from supply_manager.order_detail od
        join supply_manager."order" o on od.order_id = o.id and not o.obsolete
        where od.product_id = p.id and not od.obsolete
    ) od on true
    left join lateral (
        select count(*) as attribute_count
        from supply_manager.product_attribute pa
        where pa.product_id = p.id and not pa.obsolete
    ) pa on true
    where p.category_product_id = (
        select id from supply_manager.sp_category_product where name = i_product_category
    )
    and not p.obsolete;

    -- 2. Рассчитываем рейтинги для товаров
    return query
    select
        p.id as product_id,
        p.product_name,
        -- Финальный рейтинг
        (
            0.2 * coalesce((max_price - p.price) / nullif(max_price - min_price, 0), 0) + -- Цена
            0.2 * case when p.quantity > 0 then 1 else 0 end + -- Доступность
            0.3 * coalesce(od.total_orders / nullif(max_orders, 0), 0) + -- Количество заказов
            0.2 * coalesce(od.completed_orders / nullif(max_completed_orders, 0), 0) + -- Завершенные заказы
            0.1 * coalesce(pa.attribute_count / nullif(max_attributes, 0), 0) -- Детализация описания
        ) as total_rating,
        dense_rank() over (order by (
            0.2 * coalesce((max_price - p.price) / nullif(max_price - min_price, 0), 0) +
            0.2 * case when p.quantity > 0 then 1 else 0 end +
            0.3 * coalesce(od.total_orders / nullif(max_orders, 0), 0) +
            0.2 * coalesce(od.completed_orders / nullif(max_completed_orders, 0), 0) +
            0.1 * coalesce(pa.attribute_count / nullif(max_attributes, 0), 0)
        ) desc) as total_rank
    from supply_manager.product p
    left join lateral (
        select
            count(*) as total_orders,
            sum(case when o.order_status_id = 4 then 1 else 0 end) as completed_orders
        from supply_manager.order_detail od
        join supply_manager."order" o on od.order_id = o.id and not o.obsolete
        where od.product_id = p.id and not od.obsolete
    ) od on true
    left join lateral (
        select count(*) as attribute_count
        from supply_manager.product_attribute pa
        where pa.product_id = p.id and not pa.obsolete
    ) pa on true
    where p.category_product_id = (
        select id from supply_manager.sp_category_product where name = i_product_category
    )
    and not p.obsolete;
end;
$$ language plpgsql;
/

/* Пример использования
   
   select * from supply_manager.fv_product_rating('Смартфоны и аксессуары');
 */

comment on function supply_manager.fv_product_rating(text) is 'Параметризованное представление для Рейтинга товаров';