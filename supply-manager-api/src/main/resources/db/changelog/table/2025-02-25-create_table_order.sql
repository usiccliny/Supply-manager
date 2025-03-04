--liquibase formatted sql
--changeset eshardakov:create_table_order runOnChange:true
--comment АРМ Менеджер по поставкам. Таблица Заказы.

--drop sequence supply_manager.order_id_seq;

create sequence if not exists supply_manager.order_id_seq;

--drop table supply_manager.order;

create table if not exists supply_manager.order(
/*
 * Date: 2025-02-25.
 * Version: 1.0.
 * Author: eshardakov.
 * description: АРМ Менеджер по поставкам. Таблица Заказы.
 * Version 1.0, eshardakov, 2025-02-25.
 */
  id int8 not null,
  version_id int8 not null,
  user_id int8 not null,
  user_version_id int8 not null,
  order_date timestamp not null default current_timestamp,
  order_status_id int8,
  total_amount numeric,
  shipping_address text,
  billing_address text,
  payment_method_id int8,
  tracking_number text,
  date_created timestamp not null default current_timestamp,
  date_modified timestamp not null default current_timestamp,
  notes text,
  obsolete bool not null default false,
  begin_ts timestamp not null default current_timestamp,
  end_ts timestamp not null default supply_manager.f_max_timestamp(),
  constraint pk_order primary key (version_id),
  constraint uk_order unique (id, version_id),
  constraint fk_order_user foreign key (user_id, user_version_id) references
      supply_manager.user (id, version_id),
  constraint fk_order_user foreign key (status_id) references
      supply_manager.sp_order_status (id),  
  constraint fk_order_user foreign key (payment_method_id) references
      supply_manager.sp_payment_method (id)      
);
comment on table supply_manager.order is 'Таблица Заказы.';

comment on column supply_manager.order.id is 'Идентификатор заказа';
comment on column supply_manager.order.version_id is 'Идентификатор версии заказа';
comment on column supply_manager.order.user_id is 'Идентификатор пользователя';
comment on column supply_manager.order.user_version_id is 'Идентификатор версии пользователя';
comment on column supply_manager.order.order_date is 'Дата заказа';
comment on column supply_manager.order.order_status_id is 'Статус заказа';
comment on column supply_manager.order.total_amount is 'Общая сумма заказа';
comment on column supply_manager.order.shipping_address is 'Адрес доставки';
comment on column supply_manager.order.billing_address is 'Платежный адрес';
comment on column supply_manager.order.payment_method_id is 'Способ оплаты';
comment on column supply_manager.order.tracking_number is 'Номер отслеживания';
comment on column supply_manager.order.date_created is 'Дата создания заказа';
comment on column supply_manager.order.date_modified is 'Дата последнего изменения заказа';
comment on column supply_manager.order.notes is 'Примечания к заказу';
comment on column supply_manager.order.obsolete is 'Признак устаревшей записи';
comment on column supply_manager.order.begin_ts is 'Дата начала действия записи';
comment on column supply_manager.order.end_ts is 'Дата окончания действия записи';