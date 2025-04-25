--liquibase formatted sql
--changeset eshardakov:create_view_v_supplier_rating runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Представление Рейтинг поставщиков.

drop view if exists supply_manager.v_supplier_rating;

create or replace view supply_manager.v_supplier_rating
as 
/*
 * version: 1.0
 * date: 2025-04-23
 * author: eshardakov
 * description: АРМ Менеджер по поставкам. Представление Рейтинг поставщиков.
 * version: 1.0, eshardakov, 2025-04-23 - Первоначальное создание.
 */
    with product_cnt as materialized (
         select count(p.id) as product_cnt,
                s.supplier_id
           from supply_manager.supplier s
           join supply_manager.product p 
             on p.supplier_id = s.supplier_id
            and not p.obsolete
          where not s.obsolete
          group by s.supplier_id
    )
    , product_cnt_param as materialized (
         select supplier_id,
                product_cnt,
                max(product_cnt) over() as max_product_cnt,
                min(product_cnt) over() as min_product_cnt
           from product_cnt
    )
    , product_has_order as materialized (
         select sum(pho.ordered_product_cnt) as total_ordered_product_cnt,
                pho.supplier_id
           from (
                select count(od.id) as ordered_product_cnt,
                       o.user_id,
                       s.supplier_id
                  from supply_manager.supplier s
                  join supply_manager.product p 
                    on s.supplier_id = p.supplier_id
                   and not p.obsolete
                  join supply_manager.order_detail od 
                    on od.product_id = p.id
                   and not od.obsolete
                  join supply_manager."order" o 
                    on od.order_id = o.id
                   and not o.obsolete
                 where not s.obsolete
                 group by o.user_id, s.supplier_id
           ) pho
          group by pho.supplier_id
    )
    , unique_customers as materialized (
         select count(distinct o.user_id) as unique_customer_cnt,
                s.supplier_id
           from supply_manager.supplier s
           join supply_manager.product p 
             on s.supplier_id = p.supplier_id
            and not p.obsolete
           join supply_manager.order_detail od 
             on od.product_id = p.id
            and not od.obsolete
           join supply_manager."order" o 
             on od.order_id = o.id
            and not o.obsolete
          where not s.obsolete
          group by s.supplier_id
    )
    , normalized_params as (
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
    )
    , final_rating as (
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
    select fr.supplier_id,
           fr.contact_person,
           fr.total_rating,
           dense_rank() over (order by fr.total_rating desc) as total_rank
      from final_rating fr
     order by fr.total_rating desc;

/* Пример использования
   
   select * from supply_manager.v_supplier_rating
 */

comment on view supply_manager.v_supplier_rating is 'Представление Рейтинг поставщиков';

comment on column supply_manager.v_supplier_rating.supplier_id is 'Идентификатор Поставщика';
comment on column supply_manager.v_supplier_rating.contact_person is 'Контактное лицо';
comment on column supply_manager.v_supplier_rating.total_rating is 'Значение рейтинга';