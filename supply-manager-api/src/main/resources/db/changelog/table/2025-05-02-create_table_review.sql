--liquibase formatted sql
--changeset eshardakov:create_table_review runOnChange:true
--comment АРМ Менеджер по поставкам. Таблица отзывов.

create sequence if not exists supply_manager.review_id_seq;

create table if not exists supply_manager.review (
/*
 * Date: 2025-04-10.
 * Version: 1.0.
 * Author: eshardakov.
 * Description: АРМ Менеджер по поставкам. Таблица отзывов.
 * Version 1.0, eshardakov, 2025-04-10.
 */
  id int8 not null,
  version_id int8 not null,
  author_id int8 not null, -- ID автора отзыва (пользователя или поставщика)
  author_version_id int8 not null,
  target_id int8 not null, -- ID цели отзыва (пользователя или поставщика)
  target_version_id int8 not null,
  order_id int8 not null, -- ID заказа, к которому относится отзыв
  order_version_id int8 not null,
  rating int4 not null check (rating between 1 and 5), -- Оценка (от 1 до 5)
  comment text null, -- Текстовый комментарий
  obsolete bool not null default false, -- Признак устаревшей записи
  begin_ts timestamp not null default current_timestamp, -- Дата начала действия записи
  end_ts timestamp not null default supply_manager.f_max_timestamp(), -- Дата окончания действия записи
  constraint pk_review primary key (version_id),
  constraint uk_review unique(id, version_id),
  constraint fk_review_author foreign key (author_id, author_version_id) references supply_manager."user"(id, version_id),
  constraint fk_review_target foreign key (target_id, target_version_id) references supply_manager."user"(id, version_id),
  constraint fk_review_order foreign key (order_id, order_version_id) references supply_manager."order"(id, version_id)
);

comment on table supply_manager.review is 'Таблица отзывов.';

comment on column supply_manager.review.id is 'Идентификатор записи';
comment on column supply_manager.review.version_id is 'Идентификатор версии записи';
comment on column supply_manager.review.author_id is 'ID автора отзыва (пользователя или поставщика)';
comment on column supply_manager.review.target_id is 'ID цели отзыва (пользователя или поставщика)';
comment on column supply_manager.review.order_id is 'ID заказа, к которому относится отзыв';
comment on column supply_manager.review.rating is 'Оценка (от 1 до 5)';
comment on column supply_manager.review.comment is 'Текстовый комментарий';
comment on column supply_manager.review.obsolete is 'Признак устаревшей записи';
comment on column supply_manager.review.begin_ts is 'Дата начала действия записи';
comment on column supply_manager.review.end_ts is 'Дата окончания действия записи';