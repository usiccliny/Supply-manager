--liquibase formatted sql
--changeset eshardakov:create_view_v_supplier_widget runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Представление Поставщики.

drop view if exists supply_manager.v_supplier_widget;

create or replace view supply_manager.v_supplier_widget
as 
/*
 * version: 1.0
 * date: 2025-03-09
 * author: eshardakov
 * description: АРМ Менеджер по поставкам. Представление Поставщики.
 * version: 1.0, eshardakov, 2025-03-09 - Первоначальное создание.
 */
    select s.supplier_id,
           s.supplier_version_id,
           u.id as user_id,
           u.version_id as user_version_id,
           count(p.id) as total_product_cnt,
           count(p.id) filter (where status_id = 1) as available_product_cnt,
           count(p.id) filter (where status_id = 2) as ended_product_cnt,
           count(p.id) filter (where status_id = 3) as coming_product_cnt
      from supply_manager.supplier s
      join supply_manager.product p 
        on p.supplier_id = s.supplier_id
       and not p.obsolete
      join supply_manager.user u
        on u.email = s.email
     where not s.obsolete
     group by s.supplier_id, s.supplier_version_id, u.id, u.version_id;

/* Пример использования
   
   select * from supply_manager.v_supplier_widget
 */

comment on view supply_manager.v_supplier_widget is 'Представление Поставщики';

comment on column supply_manager.v_supplier_widget.supplier_id is 'Идентификатор Поставщика';
comment on column supply_manager.v_supplier_widget.supplier_version_id is 'Идентификатор версии Поставщика';
comment on column supply_manager.v_supplier_widget.user_id is 'Идентификатор Пользователя';
comment on column supply_manager.v_supplier_widget.user_version_id is 'Идентификатор версии Пользователя';
comment on column supply_manager.v_supplier_widget.total_product_cnt is 'Общее количество товаров';
comment on column supply_manager.v_supplier_widget.available_product_cnt is 'Количество доступных товаров';
comment on column supply_manager.v_supplier_widget.coming_product_cnt is 'Количество товаров в пути';
comment on column supply_manager.v_supplier_widget.ended_product_cnt is 'Количество товаров, которые закончились';