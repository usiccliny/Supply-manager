--liquibase formatted sql
--changeset eshardakov:create_table_product_attribute runOnChange:true
--comment АРМ Менеджер по поставкам. Таблица атрибутов товара.

--drop sequence supply_manager.product_attribute_id_seq;

create sequence if not exists supply_manager.product_attribute_id_seq;

--drop table supply_manager.product_attribute;

create table if not exists supply_manager.product_attribute(
/*
 * Date: 2025-04-08.
 * Version: 1.0.
 * Author: eshardakov.
 * description: АРМ Менеджер по поставкам. Таблица атрибутов товара.
 * Version 1.0, eshardakov, 2025-04-08.
 */
  id int8 not null,
  version_id int8 not null,
  product_id int8 not null,
  product_version_id int8 not null,
  attribute_id int8 not null,
  value text not null,
  obsolete bool not null default false,
  begin_ts timestamp not null default current_timestamp,
  end_ts timestamp not null default supply_manager.f_max_timestamp(),
  constraint pk_product_attribute primary key (version_id),
  constraint uk_product_attribute unique(id, version_id),
  constraint fk_product_attribute_product foreign key (product_id, product_version_id) references supply_manager.product (id, version_id),
  constraint fk_product_attribute_attribute foreign key (id) references supply_manager.attribute (id)
);
comment on table supply_manager.product_attribute is 'Таблица атрибутов товара.';

comment on column supply_manager.product_attribute.id is 'Идентификатор записи';
comment on column supply_manager.product_attribute.version_id is 'Идентификатор версии записи';
comment on column supply_manager.product_attribute.product_id is 'Идентификатор товара';
comment on column supply_manager.product_attribute.product_version_id is 'Идентификатор версии товара';
comment on column supply_manager.product_attribute.attribute_id is 'Идентификатор атрибута';
comment on column supply_manager.product_attribute.value is 'Значение характеристики';
comment on column supply_manager.product_attribute.obsolete is 'Признак устаревшей записи';
comment on column supply_manager.product_attribute.begin_ts is 'Дата начала действия записи';
comment on column supply_manager.product_attribute.end_ts is 'Дата окончания действия записи';