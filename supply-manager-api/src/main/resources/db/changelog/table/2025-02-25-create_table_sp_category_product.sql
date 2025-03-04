--liquibase formatted sql
--changeset eshardakov:create_table_sp_category_product runOnChange:true
--comment АРМ Менеджер по поставкам. Таблица Категории продуктов.

--drop sequence supply_manager.sp_category_product_id_seq;

create sequence if not exists supply_manager.sp_category_product_id_seq;

--drop table supply_manager.sp_category_product;

create table if not exists supply_manager.sp_category_product(
/*
 * Date: 2025-02-25.
 * Version: 1.0.
 * Author: eshardakov.
 * description: АРМ Менеджер по поставкам. Таблица Категории продуктов.
 * Version 1.0, eshardakov, 2025-02-25.
 */
  id int8 not null default nextval('supply_manager.sp_role_id_seq'::regclass),
  name text not null,
  created_at timestamp not null default current_timestamp,
  obsolete bool not null default false,
  constraint pk_sp_category_product primary key (id),
  constraint uk_sp_category_product unique (name)
);
comment on table supply_manager.sp_category_product is 'Таблица Категории продуктов.';

comment on column supply_manager.sp_category_product.id is 'Идентификатор категории';
comment on column supply_manager.sp_category_product.name is 'Наименование категории';
comment on column supply_manager.sp_category_product.created_at is 'Дата создания категории';
comment on column supply_manager.sp_category_product.obsolete is 'Признак устаревшей записи';