--liquibase formatted sql
--changeset eshardakov:create_view_v_product runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Представление Товары.

drop view if exists supply_manager.v_product;

create or replace view supply_manager.v_product
as 
/*
 * version: 1.0
 * date: 2025-03-29
 * author: eshardakov
 * description: АРМ Менеджер по поставкам. Представление Товары.
 * version: 1.0, eshardakov, 2025-03-29 - Первоначальное создание.
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
     where not s.obsolete;

/* Пример использования
   
   select * from supply_manager.v_product
 */

comment on view supply_manager.v_product is 'Представление Товары';

comment on column supply_manager.v_product.supplier_id is 'Идентификатор Поставщика';
comment on column supply_manager.v_product.supplier_version_id is 'Идентификатор версии Поставщика';
comment on column supply_manager.v_product.product_id is 'Идентификатор товара';
comment on column supply_manager.v_product.product_version_id is 'Идентификатор версии товара';
comment on column supply_manager.v_product.user_id is 'Идентификатор Пользователя';
comment on column supply_manager.v_product.user_version_id is 'Идентификатор версии Пользователя';
comment on column supply_manager.v_product.category_name is 'Категория товара';
comment on column supply_manager.v_product.product_status is 'Статус товара';
comment on column supply_manager.v_product.product_name is 'Наименование товара';
comment on column supply_manager.v_product.price is 'Стоимость товара';
comment on column supply_manager.v_product.quantity is 'Количество товара';
comment on column supply_manager.v_product.created_date is 'Дата добавления товара';