--liquibase formatted sql
--changeset eshardakov:create_table_sp_payment_method runOnChange:true
--comment АРМ Менеджер по поставкам. Cправочник Способ оплаты.

--drop sequence supply_manager.sp_payment_method_id_seq;

create sequence if not exists supply_manager.sp_payment_method_id_seq;

--drop table supply_manager.sp_payment_method;

create table if not exists supply_manager.sp_payment_method(
/*
 * Date: 2025-01-21.
 * Version: 1.0.
 * Author: eshardakov.
 * description: АРМ Менеджер по поставкам. Cправочник Способ оплаты.
 * Version 1.0, eshardakov, 2025-01-21.
 */
  id int8 not null default nextval('supply_manager.sp_payment_method_id_seq'::regclass),
  name text not null,
  constraint pk_sp_payment_method primary key (id)
);
comment on table supply_manager.sp_payment_method is 'Cправочник Способ оплаты.';

comment on column supply_manager.sp_payment_method.id is 'Идентификатор записи';
comment on column supply_manager.sp_payment_method.name is 'Наименование способа оплаты';