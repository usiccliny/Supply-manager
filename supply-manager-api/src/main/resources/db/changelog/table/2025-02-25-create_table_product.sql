--liquibase formatted sql
--changeset eshardakov:create_table_product runOnChange:true
--comment АРМ Менеджер по поставкам. Таблица Продукты.

--drop sequence supply_manager.product_id_seq;

create sequence if not exists supply_manager.product_id_seq;

--drop table supply_manager.product;

create table if not exists supply_manager.product(
/*
 * Date: 2025-02-25.
 * Version: 1.0.
 * Author: eshardakov.
 * description: АРМ Менеджер по поставкам. Таблица Продукты.
 * Version 1.0, eshardakov, 2025-02-25.
 */
  id int8 not null,
  version_id int8 not null,
  company_id int8 not null,
  company_version_id int8 not null,
  category_product_id int8 not null,
  status text,
  price numeric,
  quantity int,
  description text,
  obsolete bool not null default false,
  begin_ts timestamp not null default current_timestamp,
  end_ts timestamp not null default supply_manager.f_max_timestamp(),
  constraint pk_product primary key (version_id),
  constraint uk_product unique (id, version_id),
  constraint fk_product_company foreign key (company_id, company_version_id) references
      supply_manager.company (id, version_id),
  constraint fk_product_sp_category_product foreign key (category_product_id) references
      supply_manager.sp_category_product (id)      
);
comment on table supply_manager.product is 'Таблица Продукты.';

comment on column supply_manager.product.id is 'Идентификатор продукта';
comment on column supply_manager.product.version_id is 'Идентификатор версии продукта';
comment on column supply_manager.product.company_id is 'Идентификатор компании';
comment on column supply_manager.product.company_version_id is 'Идентификатор версии компании';
comment on column supply_manager.product.category_product_id is 'Идентификатор категории продукта';
comment on column supply_manager.product.status is 'Статус продукта';
comment on column supply_manager.product.price is 'Цена продукта';
comment on column supply_manager.product.quantity is 'Количество продукта';
comment on column supply_manager.product.description is 'Описание продукта';
comment on column supply_manager.product.obsolete is 'Признак устаревшей записи';
comment on column supply_manager.product.begin_ts is 'Дата начала действия записи';
comment on column supply_manager.product.end_ts is 'Дата окончания действия записи';