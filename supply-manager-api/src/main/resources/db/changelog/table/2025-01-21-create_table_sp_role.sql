--liquibase formatted sql
--changeset eshardakov:create_table_sp_role runOnChange:true
--comment АРМ Менеджер по поставкам. Cправочник Роль.

--drop sequence supply_manager.sp_role_id_seq;

create sequence if not exists supply_manager.sp_role_id_seq;

--drop table supply_manager.sp_role;

create table if not exists supply_manager.sp_role(
/*
 * Date: 2025-01-21.
 * Version: 1.0.
 * Author: eshardakov.
 * description: АРМ Менеджер по поставкам. Cправочник Роль.
 * Version 1.0, eshardakov, 2025-01-21.
 */
  id int8 not null default nextval('supply_manager.sp_role_id_seq'::regclass),
  name text not null,
  constraint pk_sp_role primary key (id)
);
comment on table supply_manager.sp_role is 'Cправочник Роли.';

comment on column supply_manager.sp_role.id is 'Идентификатор записи';
comment on column supply_manager.sp_role.name is 'Наименование роли';