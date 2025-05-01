--liquibase formatted sql
--changeset eshardakov:create_function_fv_category_rating runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Параметризованная функция для Рейтинга категорий товаров с учетом даты.

create or replace function supply_manager.fv_category_rating(
    i_date date -- Дата для фильтрации данных
)
returns table (
    category_id int8,
    category_name text,
    total_rating numeric,
    total_rank int8
)
as $$
begin
    return query
    with filtered_data as materialized (
        -- Фильтруем данные по дате и выбираем актуальные записи
        select p.id as product_id,
               p.category_product_id,
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
    ),
    category_data as materialized (
        -- Получаем данные о категориях товаров
        select cp.id as category_id,
               cp.name as category_name
          from supply_manager.sp_category_product cp
         where not cp.obsolete
           and cp.nesting_level = 3           
    ),
    product_data as materialized (
        -- Получаем данные о товарах в каждой категории
        select fd.category_product_id,
               count(fd.product_id) as total_products,
               sum(case when fd.quantity > 0 then 1 else 0 end) as available_products,
               avg(fd.price) as average_price
          from filtered_data fd
         group by fd.category_product_id
    ),
    order_data as materialized (
        -- Получаем данные о заказах для товаров каждой категории
        select fd.category_product_id,
               count(distinct o.id) as total_orders,
               count(distinct o.user_id) as unique_customers
          from supply_manager.order_detail od
          join filtered_data fd 
            on od.product_id = fd.product_id
          join supply_manager."order" o 
            on od.order_id = o.id
         where (i_date = current_date and not o.obsolete) -- Если дата сегодняшняя, берем только неустаревшие записи
            or (i_date < current_date and o.begin_ts <= i_date::timestamp and 
                o.begin_ts = (
                    select max(p2.begin_ts)
                      from supply_manager.order p2
                     where p2.id = o.id
                       and p2.begin_ts <= i_date::timestamp
                ))
         group by fd.category_product_id
    ),
    normalized_params as (
        -- Нормализация параметров
        select cd.category_id,
               cd.category_name,
               -- Нормализованное количество заказов
               case 
                   when max(od.total_orders) over () = min(od.total_orders) over () then 1.0
                   else (od.total_orders::numeric - min(od.total_orders) over ()) / 
                        (max(od.total_orders) over () - min(od.total_orders) over ())
               end as norm_total_orders,
               -- Нормализованное количество уникальных покупателей
               case 
                   when max(od.unique_customers) over () = min(od.unique_customers) over () then 1.0
                   else (od.unique_customers::numeric - min(od.unique_customers) over ()) / 
                        (max(od.unique_customers) over () - min(od.unique_customers) over ())
               end as norm_unique_customers,
               -- Нормализованное количество доступных товаров
               case 
                   when max(pd.available_products) over () = min(pd.available_products) over () then 1.0
                   else (pd.available_products::numeric - min(pd.available_products) over ()) / 
                        (max(pd.available_products) over () - min(pd.available_products) over ())
               end as norm_available_products,
               -- Нормализованная средняя цена
               case 
                   when max(pd.average_price) over () = min(pd.average_price) over () then 1.0
                   else (max(pd.average_price) over () - pd.average_price::numeric) / 
                        (max(pd.average_price) over () - min(pd.average_price) over ())
               end as norm_average_price
          from category_data cd
          left join product_data pd on cd.category_id = pd.category_product_id
          left join order_data od on cd.category_id = od.category_product_id
    ),
    final_rating as (
        -- Расчет итогового рейтинга
        select np.category_id,
               np.category_name,
               -- Веса для параметров
               0.4 * coalesce(np.norm_total_orders, 0) +
               0.3 * coalesce(np.norm_unique_customers, 0) +
               0.2 * coalesce(np.norm_available_products, 0) +
               0.1 * coalesce(np.norm_average_price, 0) as total_rating
          from normalized_params np
    )
    -- Ранжирование категорий
    select fr.category_id,
           fr.category_name,
           fr.total_rating,
           dense_rank() over (order by fr.total_rating desc) as total_rank
      from final_rating fr
     order by fr.total_rating desc;
end;
$$ language plpgsql;
/

/* Пример использования
   
   select * from supply_manager.fv_category_rating(now()::date);
 */

comment on function supply_manager.fv_category_rating(date) is 'Параметризованная функция для Рейтинга категорий товаров с учетом даты';