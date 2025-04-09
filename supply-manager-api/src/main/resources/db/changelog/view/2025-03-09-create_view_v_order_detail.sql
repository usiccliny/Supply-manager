--liquibase formatted sql
--changeset eshardakov:create_view_v_order_detail runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Представление для детализации заказов.

drop view if exists supply_manager.v_order_detail;

create or replace view supply_manager.v_order_detail
as 
/*
 * version: 1.0
 * date: 2025-03-09
 * author: eshardakov
 * description: АРМ Менеджер по поставкам. Представление для детализации заказов.
 * version: 1.0, eshardakov, 2025-03-09 - Первоначальное создание.
 */
    select od.id as order_detail_id,
           od.order_id,
           od.supplier_id,
           od.product_id,
           p.product_name,
           s.contact_person,
           s.phone_number,
           p.price,
           od.quantity
      from supply_manager.order_detail od
      join supply_manager.product p
        on od.product_id = p.id
       and not p.obsolete
      join supply_manager.supplier s
        on s.supplier_id = od.supplier_id
       and not s.obsolete
     where not od.obsolete;

/* Пример использования
   
   select * from supply_manager.v_order_detail
 */

comment on view supply_manager.v_order_detail is 'Представление для детализации заказов';

comment on column supply_manager.v_order_detail.order_detail_id is 'Уникальный идентификатор детали заказа';
comment on column supply_manager.v_order_detail.order_id is 'Идентификатор заказа, к которому относится данная деталь';
comment on column supply_manager.v_order_detail.supplier_id is 'Идентификатор поставщика, отвечающего за поставку';
comment on column supply_manager.v_order_detail.product_id is 'Идентификатор продукта';
comment on column supply_manager.v_order_detail.product_name is 'Наименование продукта';
comment on column supply_manager.v_order_detail.contact_person is 'Контактное лицо поставщика';
comment on column supply_manager.v_order_detail.phone_number is 'Номер телефона поставщика';
comment on column supply_manager.v_order_detail.price is 'Цена продукта';
comment on column supply_manager.v_order_detail.quantity is 'Количество заказанного продукта';