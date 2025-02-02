--liquibase formatted sql
--changeset eshardakov:create_table_user runOnChange:true
--comment АРМ Менеджер по поставкам. Таблица Пользователи.

--drop sequence supply_manager.user_id_seq;

create sequence if not exists supply_manager.user_id_seq;

--drop table supply_manager.user;

create table if not exists supply_manager.user(
/*
 * Date: 2025-01-21.
 * Version: 1.0.
 * Author: eshardakov.
 * description: АРМ Менеджер по поставкам. Таблица Пользователи.
 * Version 1.0, eshardakov, 2025-01-21.
 */
  id int8 not null,
  version_id int8 not null,
  username text, 
  password text,
  email text, 
  obsolete bool not null default false,
  role_id int null,
  begin_ts timestamp not null default current_timestamp,
  end_ts timestamp not null default supply_manager.f_max_timestamp(),
  constraint pk_user primary key (id),
  constraint uk_user unique (id, version_id),
  constraint uk_user$username unique (username),
  constraint uk_user$email unique (email),
  constraint fk_user_role foreign key (role_id) references supply_manager.sp_role(id)
);
comment on table supply_manager.user is 'Таблица Пользователи.';

comment on column supply_manager.user.id is 'Идентификатор записи';
comment on column supply_manager.user.version_id is 'Идентификатор версии записи';
comment on column supply_manager.user.username is 'Имя пользователя';
comment on column supply_manager.user.password is 'Пароль пользователя';
comment on column supply_manager.user.email is 'Адрес электронной почты';
comment on column supply_manager.user.role_id is 'Идентификатор роли';
comment on column supply_manager.user.obsolete is 'Признак устаревшей записи';
comment on column supply_manager.user.begin_ts is 'Дата начала действия записи';
comment on column supply_manager.user.end_ts is 'Дата окончания действия записи';