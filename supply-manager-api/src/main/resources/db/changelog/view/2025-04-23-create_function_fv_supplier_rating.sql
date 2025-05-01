--liquibase formatted sql
--changeset eshardakov:create_function_fv_supplier_rating runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Параметризованная функция для рейтинга поставщиков с учетом даты.

create or replace function supply_manager.fv_supplier_rating(
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
               p.price,
               p.quantity,
               p.photo,
               p.video,
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
    product_cnt as materialized (
        -- Подсчитываем количество товаров для каждого поставщика
        select count(fd.product_id) as product_cnt,
               fd.supplier_id
          from filtered_data fd
         group by fd.supplier_id
    ),
    product_cnt_param as materialized (
        -- Вычисляем максимальное и минимальное количество товаров
        select pc.supplier_id,
               pc.product_cnt,
               max(pc.product_cnt) over () as max_product_cnt,
               min(pc.product_cnt) over () as min_product_cnt
          from product_cnt pc
    ),
    product_has_order as materialized (
        -- Подсчитываем количество заказанных товаров для каждого поставщика
        select sum(pho.ordered_product_cnt) as total_ordered_product_cnt,
               pho.supplier_id
          from (
              select count(od.id) as ordered_product_cnt,
                     o.user_id,
                     fd.supplier_id
                from filtered_data fd
                join supply_manager.order_detail od 
                  on fd.product_id = od.product_id
                 and not od.obsolete
                join supply_manager."order" o 
                  on od.order_id = o.id
                 and not o.obsolete
               group by o.user_id, fd.supplier_id
          ) pho
         group by pho.supplier_id
    ),
    unique_customers as materialized (
        -- Подсчитываем количество уникальных покупателей для каждого поставщика
        select count(distinct o.user_id) as unique_customer_cnt,
               fd.supplier_id
          from filtered_data fd
          join supply_manager.order_detail od 
            on fd.product_id = od.product_id
           and not od.obsolete
          join supply_manager."order" o 
            on od.order_id = o.id
           and not o.obsolete
         group by fd.supplier_id
    ),
    normalized_params as (
        -- Нормализация параметров
        select pcp.supplier_id,
               -- Нормализованное количество товаров
               case 
                   when pcp.max_product_cnt = pcp.min_product_cnt then 1.0
                   else (pcp.product_cnt::numeric - pcp.min_product_cnt) / 
                        (pcp.max_product_cnt - pcp.min_product_cnt)
               end as norm_product_cnt,
               -- Нормализованное количество заказанных товаров
               case 
                   when max(pho.total_ordered_product_cnt) over () = min(pho.total_ordered_product_cnt) over () then 1.0
                   else (pho.total_ordered_product_cnt::numeric - min(pho.total_ordered_product_cnt) over ()) / 
                        (max(pho.total_ordered_product_cnt) over () - min(pho.total_ordered_product_cnt) over ())
               end as norm_ordered_product_cnt,
               -- Нормализованное количество уникальных покупателей
               case 
                   when max(uc.unique_customer_cnt) over () = min(uc.unique_customer_cnt) over () then 1.0
                   else (uc.unique_customer_cnt::numeric - min(uc.unique_customer_cnt) over ()) / 
                        (max(uc.unique_customer_cnt) over () - min(uc.unique_customer_cnt) over ())
               end as norm_unique_customer_cnt
          from product_cnt_param pcp
          left join product_has_order pho on pcp.supplier_id = pho.supplier_id
          left join unique_customers uc on pcp.supplier_id = uc.supplier_id
    ),
    final_rating as (
        -- Расчет итогового рейтинга
        select np.supplier_id,
               -- Веса для параметров
               0.4 * np.norm_product_cnt +
               0.3 * coalesce(np.norm_ordered_product_cnt, 0) +
               0.3 * coalesce(np.norm_unique_customer_cnt, 0) as total_rating,
               s.contact_person
          from normalized_params np
          join supply_manager.supplier s 
            on np.supplier_id = s.supplier_id
           and not s.obsolete
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
   
   select * from supply_manager.fv_supplier_rating(now()::date);
 */