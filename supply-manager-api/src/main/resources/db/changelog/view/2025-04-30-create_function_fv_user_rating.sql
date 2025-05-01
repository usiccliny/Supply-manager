--liquibase formatted sql
--changeset eshardakov:create_function_fv_user_rating runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Параметризованная функция для Рейтинга пользователей с учетом даты.

create or replace function supply_manager.fv_user_rating(
    i_date date -- Дата для фильтрации данных
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
        -- Фильтруем данные по дате и выбираем актуальные записи
        select o.id as order_id,
               o.user_id,
               o.total_amount,
               o.order_date,
               od.product_id,
               od.quantity,
               p.category_product_id,
               o.begin_ts,
               o.obsolete
          from supply_manager."order" o
          join supply_manager.order_detail od 
            on o.id = od.order_id
          join supply_manager.product p 
            on od.product_id = p.id
         where (i_date = current_date and not o.obsolete) -- Если дата сегодняшняя, берем только неустаревшие записи
            or (i_date < current_date and o.begin_ts <= i_date::timestamp and 
                o.begin_ts = (
                    select max(o2.begin_ts)
                      from supply_manager."order" o2
                     where o2.id = o.id
                       and o2.begin_ts <= i_date::timestamp
                ))
    ),
    user_orders as materialized (
        -- Получаем данные о заказах каждого пользователя
        select fd.user_id,
               count(fd.order_id) as total_orders,
               sum(fd.total_amount) as total_spent
          from filtered_data fd
         group by fd.user_id
    ),
    user_categories as materialized (
        -- Получаем количество уникальных категорий товаров, которые заказывал пользователь
        select fd.user_id,
               count(distinct fd.category_product_id) as unique_categories
          from filtered_data fd
         group by fd.user_id
    ),
    order_frequency as materialized (
        -- Вычисляем частоту заказов (среднее количество заказов в месяц)
        select fd.user_id,
               extract(year from age(max(fd.order_date), min(fd.order_date))) * 12 +
               extract(month from age(max(fd.order_date), min(fd.order_date))) as months_active,
               count(fd.order_id) / nullif(extract(year from age(max(fd.order_date), min(fd.order_date))) * 12 +
                                           extract(month from age(max(fd.order_date), min(fd.order_date))), 0) as avg_orders_per_month
          from filtered_data fd
         group by fd.user_id
    ),
    normalized_params as (
        -- Нормализация параметров
        select uo.user_id,
               -- Нормализованное количество заказов
               case 
                   when max(uo.total_orders) over () = min(uo.total_orders) over () then 1.0
                   else (uo.total_orders::numeric - min(uo.total_orders) over ()) / 
                        (max(uo.total_orders) over () - min(uo.total_orders) over ())
               end as norm_total_orders,
               -- Нормализованная общая сумма потраченных средств
               case 
                   when max(uo.total_spent) over () = min(uo.total_spent) over () then 1.0
                   else (uo.total_spent::numeric - min(uo.total_spent) over ()) / 
                        (max(uo.total_spent) over () - min(uo.total_spent) over ())
               end as norm_total_spent,
               -- Нормализованное количество уникальных категорий
               case 
                   when max(uc.unique_categories) over () = min(uc.unique_categories) over () then 1.0
                   else (uc.unique_categories::numeric - min(uc.unique_categories) over ()) / 
                        (max(uc.unique_categories) over () - min(uc.unique_categories) over ())
               end as norm_unique_categories,
               -- Нормализованная частота заказов
               case 
                   when max(of.avg_orders_per_month) over () = min(of.avg_orders_per_month) over () then 1.0
                   else (of.avg_orders_per_month::numeric - min(of.avg_orders_per_month) over ()) / 
                        (max(of.avg_orders_per_month) over () - min(of.avg_orders_per_month) over ())
               end as norm_avg_orders_per_month
          from user_orders uo
          left join user_categories uc on uo.user_id = uc.user_id
          left join order_frequency of on uo.user_id = of.user_id
    ),
    final_rating as (
        -- Расчет итогового рейтинга
        select np.user_id,
               -- Веса для параметров
               0.4 * coalesce(np.norm_total_orders, 0) +
               0.3 * coalesce(np.norm_total_spent, 0) +
               0.2 * coalesce(np.norm_unique_categories, 0) +
               0.1 * coalesce(np.norm_avg_orders_per_month, 0) as total_rating
          from normalized_params np
    )
    -- Ранжирование пользователей
    select fr.user_id,
           s.username,
           fr.total_rating,
           dense_rank() over (order by fr.total_rating desc) as total_rank
      from final_rating fr
      join supply_manager."user" s 
        on s.id = fr.user_id
         where (i_date = current_date and not s.obsolete) -- Если дата сегодняшняя, берем только неустаревшие записи
            or (i_date < current_date and s.begin_ts <= i_date::timestamp and 
                s.begin_ts = (
                    select max(o2.begin_ts)
                      from supply_manager."user" o2
                     where o2.id = s.id
                       and o2.begin_ts <= i_date::timestamp
                ))
     order by fr.total_rating desc;
end;
$$ language plpgsql;
/

/* Пример использования
   
   select * from supply_manager.fv_user_rating(now()::date);
 */

comment on function supply_manager.fv_user_rating(date) is 'Параметризованная функция для Рейтинга пользователей с учетом даты';