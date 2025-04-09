--liquibase formatted sql
--changeset eshardakov:create_table_attribute runOnChange:true
--comment АРМ Менеджер по поставкам. Таблица атрибутов товара.

--drop sequence supply_manager.attribute_id_seq;

create sequence if not exists supply_manager.attribute_id_seq;

--drop table supply_manager.attribute;

create table if not exists supply_manager.attribute(
/*
 * Date: 2025-04-08.
 * Version: 1.0.
 * Author: eshardakov.
 * description: АРМ Менеджер по поставкам. Таблица атрибутов товара.
 * Version 1.0, eshardakov, 2025-04-08.
 */
  id int8 not null default nextval('supply_manager.attribute_id_seq'::regclass),
  category_id int8 not null,
  name text not null,
  type text not null,
  unit text null,
  created_at timestamp not null default current_timestamp,
  obsolete bool not null default false,
  constraint pk_attribute primary key (id)
);
comment on table supply_manager.attribute is 'Таблица атрибутов товара.';

comment on column supply_manager.attribute.id is 'Идентификатор атрибута';
comment on column supply_manager.attribute.category_id is 'Категория товара';
comment on column supply_manager.attribute.name is 'Наименование атрибута';
comment on column supply_manager.attribute.type is 'Тип значения (строка, число, логическое значение).';
comment on column supply_manager.attribute.unit is 'Единица измерения (если применимо).';
comment on column supply_manager.attribute.created_at is 'Дата создания записи';
comment on column supply_manager.attribute.obsolete is 'Признак устаревшей записи';