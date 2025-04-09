--liquibase formatted sql
--changeset eshardakov:create_view_v_product_card runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Представление Карточка товара.

drop view if exists supply_manager.v_product_card;

create or replace view supply_manager.v_product_card
as 
/*
 * version: 1.0
 * date: 2025-04-09
 * author: eshardakov
 * description: АРМ Менеджер по поставкам. Представление Карточка товара.
 * version: 1.0, eshardakov, 2025-04-09 - Первоначальное создание.
 */
    select s.supplier_id,
           s.supplier_version_id,
           p.id as product_id,
           p.version_id as product_version_id,
           u.id as user_id,
           u.version_id as user_version_id,
           scp.name as category_name,
           sps.name as product_status,
           p.product_name,
           p.price,
           p.quantity,
           p.photo,
           p.video,
           p.rating,
           jsonb_object_agg(a.name, pa.value) FILTER (WHERE a.name IS NOT NULL AND pa.value IS NOT NULL) as attributes,
           p.begin_ts::date as created_date
      from supply_manager.supplier s
      join supply_manager.product p 
        on p.supplier_id = s.supplier_id
       and not p.obsolete
      join supply_manager.user u
        on u.email = s.email
      join supply_manager.sp_category_product scp 
        on scp.id = p.category_product_id
      join supply_manager.sp_product_status sps
        on sps.id = p.status_id
      left join supply_manager.product_attribute pa
        on p.id = pa.product_id
       and not pa.obsolete
      left join supply_manager.attribute a
        on pa.attribute_id = a.id        
       and not a.obsolete
     where not s.obsolete
     group by s.supplier_id, s.supplier_version_id, p.id, p.version_id
            , u.id, u.version_id, scp.name, sps.name, p.product_name
            , p.price, p.quantity, p.photo, p.video, p.rating, p.begin_ts;

/* Пример использования
   
   select * from supply_manager.v_product_card
 */

comment on view supply_manager.v_product_card is 'Представление Карточка товара';

comment on column supply_manager.v_product_card.supplier_id is 'Идентификатор Поставщика';
comment on column supply_manager.v_product_card.supplier_version_id is 'Идентификатор версии Поставщика';
comment on column supply_manager.v_product_card.product_id is 'Идентификатор товара';
comment on column supply_manager.v_product_card.product_version_id is 'Идентификатор версии товара';
comment on column supply_manager.v_product_card.user_id is 'Идентификатор Пользователя';
comment on column supply_manager.v_product_card.user_version_id is 'Идентификатор версии Пользователя';
comment on column supply_manager.v_product_card.category_name is 'Категория товара';
comment on column supply_manager.v_product_card.product_status is 'Статус товара';
comment on column supply_manager.v_product_card.product_name is 'Наименование товара';
comment on column supply_manager.v_product_card.price is 'Стоимость товара';
comment on column supply_manager.v_product_card.quantity is 'Количество товара';
comment on column supply_manager.v_product_card.created_date is 'Дата добавления товара';