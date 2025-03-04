--liquibase formatted sql
--changeset eshardakov:create_table_sp_order_status runOnChange:true
--comment АРМ Менеджер по поставкам. Cправочник Статус заказа.

--drop sequence supply_manager.sp_order_status_id_seq;

create sequence if not exists supply_manager.sp_order_status_id_seq;

--drop table supply_manager.sp_order_status;

create table if not exists supply_manager.sp_order_status(
/*
 * Date: 2025-01-21.
 * Version: 1.0.
 * Author: eshardakov.
 * description: АРМ Менеджер по поставкам. Cправочник Статус заказа.
 * Version 1.0, eshardakov, 2025-01-21.
 */
  id int8 not null default nextval('supply_manager.sp_order_status_id_seq'::regclass),
  name text not null,
  constraint pk_sp_order_status primary key (id)
);
comment on table supply_manager.sp_order_status is 'Cправочник Статус заказа.';

comment on column supply_manager.sp_order_status.id is 'Идентификатор записи';
comment on column supply_manager.sp_order_status.name is 'Наименование статуса заказа';