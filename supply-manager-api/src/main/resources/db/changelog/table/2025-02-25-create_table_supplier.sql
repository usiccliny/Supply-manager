--liquibase formatted sql
--changeset eshardakov:create_table_supplier runOnChange:true
--comment АРМ Менеджер по поставкам. Таблица Поставщики.

--drop sequence supply_manager.supplier_id_seq;

create sequence if not exists supply_manager.supplier_id_seq;

--drop table supply_manager.supplier;

create table if not exists supply_manager.supplier(
/*
 * Date: 2025-02-25.
 * Version: 1.0.
 * Author: eshardakov.
 * description: АРМ Менеджер по поставкам. Таблица Поставщики.
 * Version 1.0, eshardakov, 2025-02-25.
 */
  supplier_id int8 not null,
  supplier_version_id int8 not null,
  name text,
  contact_person text,
  phone_number text,
  email text,
  address text,
  company_id int8 not null,
  company_vers_id int8 not null,
  post_id int8 not null,
  obsolete bool not null default false,
  begin_ts timestamp not null default current_timestamp,
  end_ts timestamp not null default supply_manager.f_max_timestamp(),
  constraint pk_supplier primary key (supplier_version_id),
  constraint uk_supplier unique (supplier_id, supplier_version_id),
  constraint fk_supplier_company foreign key (company_id, company_vers_id) references
      supply_manager.company (id, version_id),
  constraint fk_supplier_post foreign key (post_id) references
      supply_manager.sp_post (id)
);
comment on table supply_manager.supplier is 'Таблица Поставщики.';

comment on column supply_manager.supplier.supplier_id is 'Идентификатор поставщика';
comment on column supply_manager.supplier.supplier_version_id is 'Идентификатор версии поставщика';
comment on column supply_manager.supplier.contact_person is 'Контактное лицо';
comment on column supply_manager.supplier.phone_number is 'Номер телефона';
comment on column supply_manager.supplier.email is 'Адрес электронной почты';
comment on column supply_manager.supplier.address is 'Физический адрес';
comment on column supply_manager.supplier.company_id is 'Идентификатор компании';
comment on column supply_manager.supplier.company_vers_id is 'Идентификатор версии компании';
comment on column supply_manager.supplier.post_id is 'Идентификатор должности';
comment on column supply_manager.supplier.obsolete is 'Признак устаревшей записи';
comment on column supply_manager.supplier.begin_ts is 'Дата начала действия записи';
comment on column supply_manager.supplier.end_ts is 'Дата окончания действия записи';