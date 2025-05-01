--liquibase formatted sql
--changeset eshardakov:create_function_fv_user_loyalty_rating runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Параметризованная функция для Рейтинга лояльности пользователей к конкретному поставщику с учетом даты.

create or replace function supply_manager.fv_user_loyalty_rating(
    i_date date, -- Дата для фильтрации данных
    i_supplier_id int8 -- Идентификатор поставщика
)
returns table (
    user_id int8,
    username text,
    total_rating numeric,
    total_rank int8
)
as $$
begin
    return query
    with filtered_data as materialized (
        -- Фильтруем данные по дате и выбираем актуальные записи для указанного поставщика
        select o.id as order_id,
               o.user_id,
               o.user_version_id,
               od.supplier_id,
               od.supplier_version_id,
               p.category_product_id,
               o.order_date,
               o.begin_ts,
               o.obsolete
          from supply_manager."order" o
          join supply_manager.order_detail od 
            on o.id = od.order_id
           and o.version_id = od.order_version_id
          join supply_manager.product p 
            on od.product_id = p.id
           and od.product_version_id = p.version_id
         where (i_date = current_date and not o.obsolete) -- Если дата сегодняшняя, берем только неустаревшие записи
            or (i_date < current_date and o.begin_ts <= i_date::timestamp and 
                o.begin_ts = (
                    select max(o2.begin_ts)
                      from supply_manager."order" o2
                     where o2.id = o.id
                       and o2.begin_ts <= i_date::timestamp
                ))
           and od.supplier_id = i_supplier_id -- Фильтр по поставщику
    ),
    repeated_orders as materialized (
        -- Количество повторных заказов у одного поставщика
        select fd.user_id,
               count(*) as repeated_order_count
          from filtered_data fd
         group by fd.user_id
        having count(*) > 1
    ),
    category_percentage as materialized (
        -- Процент заказов в одной категории
        select fd.user_id,
               (count(case when fd.category_product_id = cp.most_popular_category then 1 end)::numeric / nullif(count(*), 0)) * 100 as category_pct
          from filtered_data fd
          join (
              -- Находим самую популярную категорию для каждого пользователя
              select fd_inner.user_id,
                     fd_inner.category_product_id as most_popular_category
                from filtered_data fd_inner
               group by fd_inner.user_id, fd_inner.category_product_id
               order by fd_inner.user_id, count(*) desc
               limit 1
          ) cp on fd.user_id = cp.user_id
         group by fd.user_id, cp.most_popular_category
    ),
    order_intervals as materialized (
        -- Вычисляем интервалы между заказами для каждого пользователя
        select fd.user_id,
               extract(epoch from (fd.order_date - lag(fd.order_date) over (partition by fd.user_id order by fd.order_date))) / (60 * 60 * 24) as interval_days
          from filtered_data fd
    ),
    avg_order_interval as materialized (
        -- Средний интервал между заказами
        select oi.user_id,
               avg(oi.interval_days) as avg_interval_days
          from order_intervals oi
         where oi.interval_days is not null
         group by oi.user_id
    ),
    global_metrics as (
        -- Вычисляем глобальные минимумы и максимумы для нормализации
        select 
            min(ro.repeated_order_count) as min_repeated_orders,
            max(ro.repeated_order_count) as max_repeated_orders,
            min(cp.category_pct) as min_category_pct,
            max(cp.category_pct) as max_category_pct,
            min(aoi.avg_interval_days) as min_avg_interval_days,
            max(aoi.avg_interval_days) as max_avg_interval_days
          from repeated_orders ro
          full join category_percentage cp on true
          full join avg_order_interval aoi on true
    ),
    normalized_params as (
        -- Нормализация параметров
        select u.id as user_id,
               u.username,
               -- Нормализованное количество повторных заказов
               case 
                   when gm.max_repeated_orders = gm.min_repeated_orders then 1.0
                   else (ro.repeated_order_count::numeric - gm.min_repeated_orders) / 
                        (gm.max_repeated_orders - gm.min_repeated_orders)
               end as norm_repeated_orders,
               -- Нормализованный процент заказов в одной категории
               case 
                   when gm.max_category_pct = gm.min_category_pct then 1.0
                   else (cp.category_pct::numeric - gm.min_category_pct) / 
                        (gm.max_category_pct - gm.min_category_pct)
               end as norm_category_pct,
               -- Нормализованный средний интервал между заказами
               case 
                   when gm.max_avg_interval_days = gm.min_avg_interval_days then 1.0
                   else (gm.max_avg_interval_days - aoi.avg_interval_days::numeric) / 
                        (gm.max_avg_interval_days - gm.min_avg_interval_days)
               end as norm_avg_interval_days
          from supply_manager."user" u
          join repeated_orders ro on u.id = ro.user_id
          left join category_percentage cp on u.id = cp.user_id
          left join avg_order_interval aoi on u.id = aoi.user_id
          cross join global_metrics gm
         where not u.obsolete
    ),
    final_rating as (
        -- Расчет итогового рейтинга
        select np.user_id,
               np.username,
               -- Веса для параметров
               0.5 * coalesce(np.norm_repeated_orders, 0) +
               0.3 * coalesce(np.norm_category_pct, 0) +
               0.2 * coalesce(np.norm_avg_interval_days, 0) as total_rating
          from normalized_params np
    )
    -- Ранжирование пользователей
    select fr.user_id,
           fr.username,
           fr.total_rating,
           dense_rank() over (order by fr.total_rating desc) as total_rank
      from final_rating fr
     order by fr.total_rating desc;
end;
$$ language plpgsql;
/

/* Пример использования
   
   select * from supply_manager.fv_user_loyalty_rating(now()::date, 62);
 */

comment on function supply_manager.fv_user_loyalty_rating(date, int8) is 'Параметризованная функция для Рейтинга лояльности пользователей к конкретному поставщику с учетом даты';