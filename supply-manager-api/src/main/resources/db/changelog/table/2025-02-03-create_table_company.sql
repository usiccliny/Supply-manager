--liquibase formatted sql
--changeset eshardakov:create_table_company runOnChange:true
--comment АРМ Менеджер по поставкам. Таблица Поставщики.

--drop sequence supply_manager.company_id_seq;

create sequence if not exists supply_manager.company_id_seq;

--drop table supply_manager.company;

create table if not exists supply_manager.company(
/*
 * Date: 2025-02-03.
 * Version: 1.0.
 * Author: eshardakov.
 * description: АРМ Менеджер по поставкам. Таблица Поставщики.
 * Version 1.0, eshardakov, 2025-02-03.
 */
  id int8 not null,
  version_id int8 not null,
  name text, 
  email text,
  address text,
  website text,
  lifetime int,
  rating numeric,
  compyany_code text not null,
  obsolete bool not null default false,
  begin_ts timestamp not null default current_timestamp,
  end_ts timestamp not null default supply_manager.f_max_timestamp(),
  constraint pk_company primary key (id),
  constraint uk_company unique (id, version_id),
  constraint uk_company$companyname unique (compyany_code)
);
comment on table supply_manager.company is 'Таблица Поставщики.';

comment on column supply_manager.company.id is 'Идентификатор записи';
comment on column supply_manager.company.version_id is 'Идентификатор версии записи';
comment on column supply_manager.company.name is 'Наименование компании';
comment on column supply_manager.company.email is 'Адрес электронной почты';
comment on column supply_manager.company.address is 'Физический адрес почты';
comment on column supply_manager.company.website is 'Адрес вебсайта';
comment on column supply_manager.company.lifetime is 'Продолжительность работы компании';
comment on column supply_manager.company.rating is 'Ретийнг компании';
comment on column supply_manager.company.compyany_code is 'Уникальный код компании';
comment on column supply_manager.company.obsolete is 'Признак устаревшей записи';
comment on column supply_manager.company.begin_ts is 'Дата начала действия записи';
comment on column supply_manager.company.end_ts is 'Дата окончания действия записи';