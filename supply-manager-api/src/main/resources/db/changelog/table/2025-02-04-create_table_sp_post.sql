--liquibase formatted sql
--changeset eshardakov:create_table_sp_post
--comment АРМ Менеджер по поставкам. Cправочник Должность.

--drop sequence supply_manager.sp_post_id_seq;

create sequence if not exists supply_manager.sp_post_id_seq;

--drop table supply_manager.sp_post;

create table if not exists supply_manager.sp_post(
/*
 * Date: 2025-01-21.
 * Version: 1.0.
 * Author: eshardakov.
 * description: АРМ Менеджер по поставкам. Cправочник Должность.
 * Version 1.0, eshardakov, 2025-01-21.
 */
  id int8 not null default nextval('supply_manager.sp_post_id_seq'::regclass),
  name text not null,
  short_name text null,
  constraint pk_sp_post primary key (id),
  constraint uk_sp_post unique (name)
);
comment on table supply_manager.sp_post is 'Cправочник Должность.';

comment on column supply_manager.sp_post.id is 'Идентификатор записи';
comment on column supply_manager.sp_post.name is 'Наименование должности';
comment on column supply_manager.sp_post.name is 'Краткое наименование должности';