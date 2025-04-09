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
  supplier_id int8 not null,
  supplier_version_id int8 not null,
  category_product_id int8 not null,
  status_id int8 not null,
  product_name text not null,
  price numeric not null,
  quantity int not null,
  photo text null,
  video text null,
  rating numeric null,
  obsolete bool not null default false,
  begin_ts timestamp not null default current_timestamp,
  end_ts timestamp not null default supply_manager.f_max_timestamp(),
  constraint pk_product primary key (version_id),
  constraint uk_product unique (id, version_id),
  constraint fk_product_supplier foreign key (supplier_id, supplier_version_id) references
      supply_manager.supplier (supplier_id, supplier_version_id),
  constraint fk_product_sp_category_product foreign key (category_product_id) references
      supply_manager.sp_category_product (id),
constraint fk_product_sp_product_status foreign key (status_id) references
      supply_manager.sp_product_status (id)      
);
comment on table supply_manager.product is 'Таблица Продукты.';

comment on column supply_manager.product.id is 'Идентификатор продукта';
comment on column supply_manager.product.version_id is 'Идентификатор версии продукта';
comment on column supply_manager.product.supplier_id is 'Идентификатор Поставщика';
comment on column supply_manager.product.supplier_version_id is 'Идентификатор версии Поставщика';
comment on column supply_manager.product.product_name is 'Наименование продукта';
comment on column supply_manager.product.category_product_id is 'Идентификатор категории продукта';
comment on column supply_manager.product.status_id is 'Идентификатор статуса продукта';
comment on column supply_manager.product.price is 'Цена продукта';
comment on column supply_manager.product.quantity is 'Количество продукта';
comment on column supply_manager.product.photo is 'Фото товара';
comment on column supply_manager.product.video is 'Видео товара';
comment on column supply_manager.product.rating is 'Рейтинг товара';
comment on column supply_manager.product.obsolete is 'Признак устаревшей записи';
comment on column supply_manager.product.begin_ts is 'Дата начала действия записи';
comment on column supply_manager.product.end_ts is 'Дата окончания действия записи';