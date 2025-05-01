--liquibase formatted sql
--changeset eshardakov:create_function_fv_product_rating runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Параметризованная функция для Рейтинга товаров с учетом даты.

create or replace function supply_manager.fv_product_rating(
    i_product_category text, -- Категория товара
    i_date date            -- Дата для фильтрации данных
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
    -- 1. Фильтруем данные по дате
    with filtered_data as materialized (
        select p.id as product_id,
               p.product_name,
               p.price,
               p.quantity,
               p.begin_ts,
               p.obsolete
          from supply_manager.product p
         where (i_date = current_date and not p.obsolete) -- Если дата сегодняшняя, берем только неустаревшие записи
            or (i_date < current_date and p.begin_ts <= i_date::timestamp and 
                p.begin_ts = (
                    select max(p2.begin_ts)
                      from supply_manager.product p2
                     where p2.id = p.id
                       and p2.begin_ts <= i_date::timestamp
                ))
    )
    -- 2. Определяем максимальные и минимальные значения для нормализации
    select
        max(fd.price),
        min(fd.price),
        max(od.total_orders),
        max(od.completed_orders),
        max(pa.attribute_count)
    into
        max_price,
        min_price,
        max_orders,
        max_completed_orders,
        max_attributes
    from filtered_data fd
    left join lateral (
        select
            count(*) as total_orders,
            sum(case when o.order_status_id = 4 then 1 else 0 end) as completed_orders
        from supply_manager.order_detail od
        join supply_manager."order" o on od.order_id = o.id and not o.obsolete
        where od.product_id = fd.product_id and not od.obsolete
    ) od on true
    left join lateral (
        select count(*) as attribute_count
        from supply_manager.product_attribute pa
        where pa.product_id = fd.product_id and not pa.obsolete
    ) pa on true
    where fd.product_id in (
        select id from supply_manager.product where category_product_id = (
            select id from supply_manager.sp_category_product where name = i_product_category
        )
    );

    -- 3. Рассчитываем рейтинги для товаров
    return query
    with filtered_data as materialized (
        select p.id as product_id,
               p.product_name,
               p.price,
               p.quantity,
               p.begin_ts,
               p.obsolete
          from supply_manager.product p
         where (i_date = current_date and not p.obsolete) -- Если дата сегодняшняя, берем только неустаревшие записи
            or (i_date < current_date and p.begin_ts <= i_date::timestamp and 
                p.begin_ts = (
                    select max(p2.begin_ts)
                      from supply_manager.product p2
                     where p2.id = p.id
                       and p2.begin_ts <= i_date::timestamp
                ))
    )
    select
        fd.product_id,
        fd.product_name,
        -- Финальный рейтинг
        (
            0.2 * coalesce((max_price - fd.price) / nullif(max_price - min_price, 0), 0) + -- Цена
            0.2 * case when fd.quantity > 0 then 1 else 0 end + -- Доступность
            0.3 * coalesce(od.total_orders / nullif(max_orders, 0), 0) + -- Количество заказов
            0.2 * coalesce(od.completed_orders / nullif(max_completed_orders, 0), 0) + -- Завершенные заказы
            0.1 * coalesce(pa.attribute_count / nullif(max_attributes, 0), 0) -- Детализация описания
        ) as total_rating,
        dense_rank() over (order by (
            0.2 * coalesce((max_price - fd.price) / nullif(max_price - min_price, 0), 0) +
            0.2 * case when fd.quantity > 0 then 1 else 0 end +
            0.3 * coalesce(od.total_orders / nullif(max_orders, 0), 0) +
            0.2 * coalesce(od.completed_orders / nullif(max_completed_orders, 0), 0) +
            0.1 * coalesce(pa.attribute_count / nullif(max_attributes, 0), 0)
        ) desc) as total_rank
    from filtered_data fd
    left join lateral (
        select
            count(*) as total_orders,
            sum(case when o.order_status_id = 4 then 1 else 0 end) as completed_orders
        from supply_manager.order_detail od
        join supply_manager."order" o on od.order_id = o.id and not o.obsolete
        where od.product_id = fd.product_id and not od.obsolete
    ) od on true
    left join lateral (
        select count(*) as attribute_count
        from supply_manager.product_attribute pa
        where pa.product_id = fd.product_id and not pa.obsolete
    ) pa on true
    where fd.product_id in (
        select id from supply_manager.product where category_product_id = (
            select id from supply_manager.sp_category_product where name = i_product_category
        )
    );
end;
$$ language plpgsql;
/

/* Пример использования
   
   select * from supply_manager.fv_product_rating('Смартфоны и аксессуары', now()::date);
 */

comment on function supply_manager.fv_product_rating(text, date) is 'Параметризованная функция для Рейтинга товаров с учетом даты';