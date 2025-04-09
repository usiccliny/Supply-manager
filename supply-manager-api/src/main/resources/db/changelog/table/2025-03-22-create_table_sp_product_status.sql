--liquibase formatted sql
--changeset eshardakov:create_table_sp_product_status runOnChange:true
--comment АРМ Менеджер по поставкам. Таблица статусов продуктов.

--drop sequence supply_manager.sp_product_status_id_seq;

create sequence if not exists supply_manager.sp_product_status_id_seq;

--drop table supply_manager.sp_product_status;

create table if not exists supply_manager.sp_product_status(
/*
 * Date: 2025-03-22.
 * Version: 1.0.
 * Author: eshardakov.
 * description: АРМ Менеджер по поставкам. Таблица статусов продуктов.
 * Version 1.0, eshardakov, 2025-03-22.
 */
  id int8 not null default nextval('supply_manager.sp_product_status_id_seq'::regclass),
  name text not null,
  created_at timestamp not null default current_timestamp,
  obsolete bool not null default false,
  constraint pk_sp_product_status primary key (id),
  constraint uk_sp_product_status unique (name)
);
comment on table supply_manager.sp_product_status is 'Таблица статусов продуктов.';

comment on column supply_manager.sp_product_status.id is 'Идентификатор статуса';
comment on column supply_manager.sp_product_status.name is 'Наименование статуса';
comment on column supply_manager.sp_product_status.created_at is 'Дата создания записи';
comment on column supply_manager.sp_product_status.obsolete is 'Признак устаревшей записи';