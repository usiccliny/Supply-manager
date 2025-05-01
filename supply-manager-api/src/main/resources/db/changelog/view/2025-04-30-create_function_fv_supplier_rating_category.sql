--liquibase formatted sql
--changeset eshardakov:create_function_fv_supplier_rating_category runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Параметризованная функция для Поставщиков в разрезе категорий с учетом даты.

create or replace function supply_manager.fv_supplier_rating_category(
    i_product_category text, -- Наименование категории
    i_date date            -- Дата для фильтрации данных
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
    with category_data as materialized (
        -- Получаем ID категории по её имени
        select id
        from supply_manager.sp_category_product
        where name = i_product_category
    ),
    filtered_data as materialized (
        -- Фильтруем данные по дате и выбираем актуальные записи
        select p.id as product_id,
               p.supplier_id,
               p.category_product_id,
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
        -- Количество товаров поставщика в выбранной категории
        select count(fd.product_id) as product_cnt,
               s.supplier_id
          from supply_manager.supplier s
          join filtered_data fd 
            on fd.supplier_id = s.supplier_id
         where fd.category_product_id = (select id from category_data)
           and not s.obsolete
         group by s.supplier_id
    ),
    product_cnt_param as materialized (
        -- Нормализация количества товаров
        select c.supplier_id,
               c.product_cnt,
               max(c.product_cnt) over () as max_product_cnt,
               min(c.product_cnt) over () as min_product_cnt
          from product_cnt c
    ),
    product_has_order as materialized (
        -- Количество заказанных товаров в выбранной категории
        select sum(pho.ordered_product_cnt) as total_ordered_product_cnt,
               pho.supplier_id
          from (
                select count(od.id) as ordered_product_cnt,
                       o.user_id,
                       s.supplier_id
                  from supply_manager.supplier s
                  join filtered_data fd 
                    on s.supplier_id = fd.supplier_id
                  join supply_manager.order_detail od 
                    on od.product_id = fd.product_id
                   and not od.obsolete
                  join supply_manager."order" o 
                    on od.order_id = o.id
                   and not o.obsolete
                 where fd.category_product_id = (select id from category_data)
                   and not s.obsolete
                 group by o.user_id, s.supplier_id
           ) pho
         group by pho.supplier_id
    ),
    unique_customers as materialized (
        -- Количество уникальных покупателей в выбранной категории
        select count(distinct o.user_id) as unique_customer_cnt,
               s.supplier_id
          from supply_manager.supplier s
          join filtered_data fd 
            on s.supplier_id = fd.supplier_id
          join supply_manager.order_detail od 
            on od.product_id = fd.product_id
           and not od.obsolete
          join supply_manager."order" o 
            on od.order_id = o.id
           and not o.obsolete
         where fd.category_product_id = (select id from category_data)
           and not s.obsolete
         group by s.supplier_id
    ),
    normalized_params as (
        -- Нормализация параметров
        select pcp.supplier_id,
               -- Нормализованное количество товаров
               case 
                   when pcp.max_product_cnt = pcp.min_product_cnt then 1.0
                   else (pcp.product_cnt::numeric - pcp.min_product_cnt) / (pcp.max_product_cnt - pcp.min_product_cnt)
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
            on s.supplier_id = np.supplier_id
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
   
   select * from supply_manager.fv_supplier_rating_category('Смартфоны и аксессуары', now()::date);
 */

comment on function supply_manager.fv_supplier_rating_category(text, date) is 'Параметризованная функция для Поставщиков в разрезе категорий с учетом даты';