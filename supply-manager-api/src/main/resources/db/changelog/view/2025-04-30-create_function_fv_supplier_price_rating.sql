--liquibase formatted sql
--changeset eshardakov:create_function_fv_supplier_price_rating runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Параметризованная функция для Рейтинга поставщиков по ценам с учетом даты.

create or replace function supply_manager.fv_supplier_price_rating(
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
               p.category_product_id,
               p.price,
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
    supplier_avg_prices as materialized (
        -- Средняя цена товаров каждого поставщика
        select fd.supplier_id,
               avg(fd.price) as avg_price
          from filtered_data fd
         group by fd.supplier_id
    ),
    category_min_prices as materialized (
        -- Минимальная цена товаров в каждой категории
        select fd.category_product_id,
               min(fd.price) as min_price
          from filtered_data fd
         group by fd.category_product_id
    ),
    supplier_lowest_prices as materialized (
        -- Количество товаров поставщика с самой низкой ценой в категории
        select fd.supplier_id,
               count(*) as lowest_price_count
          from filtered_data fd
          join category_min_prices cmp 
            on fd.category_product_id = cmp.category_product_id
           and fd.price = cmp.min_price
         group by fd.supplier_id
    ),
    price_changes as materialized (
        -- Динамика изменения цен (частота повышения цен)
        select p.supplier_id,
               sum(case when p.price > prev_price then 1 else 0 end) as price_increase_count
          from (
              select fd.supplier_id,
                     fd.price,
                     lag(fd.price) over (partition by fd.product_id order by fd.begin_ts) as prev_price
                from filtered_data fd
          ) p
         group by p.supplier_id
    ),
    normalized_params as (
        -- Нормализация параметров
        select sap.supplier_id,
               -- Нормализованная средняя цена
               case 
                   when max(sap.avg_price) over () = min(sap.avg_price) over () then 1.0
                   else (max(sap.avg_price) over () - sap.avg_price::numeric) / 
                        (max(sap.avg_price) over () - min(sap.avg_price) over ())
               end as norm_avg_price,
               -- Нормализованное количество товаров с самой низкой ценой
               case 
                   when max(slp.lowest_price_count) over () = min(slp.lowest_price_count) over () then 1.0
                   else (slp.lowest_price_count::numeric - min(slp.lowest_price_count) over ()) / 
                        (max(slp.lowest_price_count) over () - min(slp.lowest_price_count) over ())
               end as norm_lowest_price_count,
               -- Нормализованная частота повышения цен
               case 
                   when max(pc.price_increase_count) over () = min(pc.price_increase_count) over () then 1.0
                   else (pc.price_increase_count::numeric - min(pc.price_increase_count) over ()) / 
                        (max(pc.price_increase_count) over () - min(pc.price_increase_count) over ())
               end as norm_price_increase_count
          from supplier_avg_prices sap
          left join supplier_lowest_prices slp on sap.supplier_id = slp.supplier_id
          left join price_changes pc on sap.supplier_id = pc.supplier_id
    ),
    final_rating as (
        -- Расчет итогового рейтинга
        select np.supplier_id,
               -- Веса для параметров
               0.5 * coalesce(np.norm_avg_price, 0) +
               0.3 * coalesce(np.norm_lowest_price_count, 0) +
               0.2 * coalesce(np.norm_price_increase_count, 0) as total_rating
          from normalized_params np
    )
    -- Ранжирование поставщиков
    select fr.supplier_id,
           s.contact_person,
           fr.total_rating,
           dense_rank() over (order by fr.total_rating desc) as total_rank
      from final_rating fr
      join supply_manager.supplier s 
        on fr.supplier_id = s.supplier_id
         where (i_date = current_date and not s.obsolete) -- Если дата сегодняшняя, берем только неустаревшие записи
            or (i_date < current_date and s.begin_ts <= i_date::timestamp and 
                s.begin_ts = (
                    select max(p2.begin_ts)
                      from supply_manager.product p2
                     where p2.supplier_id = s.supplier_id
                       and p2.begin_ts <= i_date::timestamp
                ))
     order by fr.total_rating desc;
end;
$$ language plpgsql;
/

/* Пример использования
   
   select * from supply_manager.fv_supplier_price_rating(now()::date);
 */

comment on function supply_manager.fv_supplier_price_rating(date) is 'Параметризованная функция для Рейтинга поставщиков по ценам с учетом даты';