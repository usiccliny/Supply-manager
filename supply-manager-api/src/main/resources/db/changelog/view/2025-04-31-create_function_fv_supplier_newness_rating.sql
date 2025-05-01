--liquibase formatted sql
--changeset eshardakov:create_function_fv_supplier_newness_rating runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Параметризованная функция для Рейтинга поставщиков по новизне товаров с учетом даты.

create or replace function supply_manager.fv_supplier_newness_rating(
    i_date date -- Дата для фильтрации данных
)
returns table (
    supplier_id int8,
    contact_person text,
    total_rating numeric,
    total_rank int8
)
as $$
begin
    return query
    with filtered_data as materialized (
        -- Фильтруем данные по дате и выбираем актуальные записи
        select p.id as product_id,
               p.supplier_id,
               p.supplier_version_id,
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
    new_products as materialized (
        -- Количество новых товаров за последний месяц
        select fd.supplier_id,
               count(*) as new_product_count
          from filtered_data fd
         where fd.begin_ts >= (i_date - interval '1 month')::timestamp
         group by fd.supplier_id
    ),
    average_age as materialized (
        -- Средний возраст товаров в каталоге
        select fd.supplier_id,
               avg(extract(epoch from (i_date::timestamp - fd.begin_ts)) / (60 * 60 * 24)) as avg_age_days
          from filtered_data fd
         group by fd.supplier_id
    ),
    obsolete_percentage as materialized (
        -- Процент устаревших товаров
        select fd.supplier_id,
               (count(case when fd.obsolete then 1 end)::numeric / nullif(count(*), 0)) * 100 as obsolete_pct
          from filtered_data fd
         group by fd.supplier_id
    ),
    normalized_params as (
        -- Нормализация параметров
        select s.supplier_id,
               s.contact_person,
               -- Нормализованное количество новых товаров
               case 
                   when max(np.new_product_count) over () = min(np.new_product_count) over () then 1.0
                   else (np.new_product_count::numeric - min(np.new_product_count) over ()) / 
                        (max(np.new_product_count) over () - min(np.new_product_count) over ())
               end as norm_new_product_count,
               -- Нормализованный средний возраст товаров
               case 
                   when max(aa.avg_age_days) over () = min(aa.avg_age_days) over () then 1.0
                   else (max(aa.avg_age_days) over () - aa.avg_age_days::numeric) / 
                        (max(aa.avg_age_days) over () - min(aa.avg_age_days) over ())
               end as norm_avg_age_days,
               -- Нормализованный процент устаревших товаров
               case 
                   when max(op.obsolete_pct) over () = min(op.obsolete_pct) over () then 1.0
                   else (max(op.obsolete_pct) over () - op.obsolete_pct::numeric) / 
                        (max(op.obsolete_pct) over () - min(op.obsolete_pct) over ())
               end as norm_obsolete_pct
          from supply_manager.supplier s
          join new_products np on s.supplier_id = np.supplier_id
          join average_age aa on s.supplier_id = aa.supplier_id
          join obsolete_percentage op on s.supplier_id = op.supplier_id
         where (i_date = current_date and not s.obsolete) -- Если дата сегодняшняя, берем только неустаревшие записи
            or (i_date < current_date and s.begin_ts <= i_date::timestamp and 
                s.begin_ts = (
                    select max(p2.begin_ts)
                      from supply_manager.supplier p2
                     where p2.supplier_id = s.supplier_id
                       and p2.begin_ts <= i_date::timestamp
                ))
    ),
    final_rating as (
        -- Расчет итогового рейтинга
        select np.supplier_id,
               np.contact_person,
               -- Веса для параметров
               0.5 * coalesce(np.norm_new_product_count, 0) +
               0.3 * coalesce(np.norm_avg_age_days, 0) +
               0.2 * coalesce(np.norm_obsolete_pct, 0) as total_rating
          from normalized_params np
    )
    -- Ранжирование поставщиков
    select fr.supplier_id,
           fr.contact_person,
           fr.total_rating,
           dense_rank() over (order by fr.total_rating desc) as total_rank
      from final_rating fr
     order by fr.total_rating desc;
end;
$$ language plpgsql;
/

/* Пример использования
   
   select * from supply_manager.fv_supplier_newness_rating(now()::date);
 */

comment on function supply_manager.fv_supplier_newness_rating(date) is 'Параметризованная функция для Рейтинга поставщиков по новизне товаров с учетом даты';