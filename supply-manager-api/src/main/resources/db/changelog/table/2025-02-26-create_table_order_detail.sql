--liquibase formatted sql
--changeset eshardakov:create_table_order_detail runOnChange:true
--comment АРМ Менеджер по поставкам. Таблица Детали Заказов.

--drop sequence supply_manager.order_detail_id_seq;

create sequence if not exists supply_manager.order_detail_id_seq;

--drop table supply_manager.order_detail;

create table if not exists supply_manager.order_detail(
/*
 * Date: 2025-02-25.
 * Version: 1.0.
 * Author: eshardakov.
 * description: АРМ Менеджер по поставкам. Таблица Детали Заказов.
 * Version 1.0, eshardakov, 2025-02-25.
 */
  id int8 not null,
  version_id int8 not null,
  order_id int8 not null,
  order_version_id int8 not null,
  supplier_id int8 not null,
  supplier_version_id int8 not null,
  product_id int8 not null,
  product_version_id int8 not null,
  quantity int8 not null,
  date_created timestamp not null default current_timestamp,
  date_modified timestamp not null default current_timestamp,
  obsolete bool not null default false,
  begin_ts timestamp not null default current_timestamp,
  end_ts timestamp not null default supply_manager.f_max_timestamp(),
  constraint pk_order_detail primary key (version_id),
  constraint uk_order_detail unique (id, version_id),
  constraint fk_order_detail_order foreign key (order_id, order_version_id) references
      supply_manager.order (id, version_id),
  constraint fk_order_detail_supplier foreign key (supplier_id, supplier_version_id) references
      supply_manager.supplier (supplier_id, supplier_version_id),
  constraint fk_order_detail_product foreign key (product_id, product_version_id) references
      supply_manager.product (id, version_id)
);
comment on table supply_manager.order_detail is 'Таблица Детали Заказов.';

comment on column supply_manager.order_detail.id is 'Идентификатор детали заказа';
comment on column supply_manager.order_detail.version_id is 'Идентификатор версии детали заказа';
comment on column supply_manager.order_detail.order_id is 'Идентификатор заказа';
comment on column supply_manager.order_detail.order_version_id is 'Идентификатор версии заказа';
comment on column supply_manager.order_detail.supplier_id is 'Идентификатор поставщика';
comment on column supply_manager.order_detail.supplier_version_id is 'Идентификатор версии поставщика';
comment on column supply_manager.order_detail.product_id is 'Идентификатор продукта';
comment on column supply_manager.order_detail.product_version_id is 'Идентификатор версии продукта';
comment on column supply_manager.order_detail.quantity is 'Количество товара';
comment on column supply_manager.order_detail.date_created is 'Дата создания детали заказа';
comment on column supply_manager.order_detail.date_modified is 'Дата последнего изменения детали заказа';
comment on column supply_manager.order_detail.obsolete is 'Признак устаревшей записи';
comment on column supply_manager.order_detail.begin_ts is 'Дата начала действия записи';
comment on column supply_manager.order_detail.end_ts is 'Дата окончания действия записи';