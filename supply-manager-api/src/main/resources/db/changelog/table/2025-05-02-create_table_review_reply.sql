--liquibase formatted sql
--changeset eshardakov:create_table_review_reply runOnChange:true
--comment АРМ Менеджер по поставкам. Таблица ответов на отзывы.

create sequence if not exists supply_manager.review_reply_id_seq;

create table if not exists supply_manager.review_reply (
/*
 * Date: 2025-04-10.
 * Version: 1.0.
 * Author: eshardakov.
 * Description: АРМ Менеджер по поставкам. Таблица ответов на отзывы.
 * Version 1.0, eshardakov, 2025-04-10.
 */
  id int8 not null,
  version_id int8 not null,
  review_id int8 not null, -- ID отзыва, на который дан ответ
  review_version_id int8 not null,
  author_id int8 not null, -- ID автора ответа
  author_version_id int8 not null,
  reply_text text not null, -- Текст ответа
  obsolete bool not null default false, -- Признак устаревшей записи
  begin_ts timestamp not null default current_timestamp, -- Дата начала действия записи
  end_ts timestamp not null default supply_manager.f_max_timestamp(), -- Дата окончания действия записи
  constraint pk_review_reply primary key (version_id),
  constraint uk_review_reply unique(id, version_id),
  constraint fk_review_reply_review foreign key (review_id, review_version_id) references supply_manager.review(id, version_id),
  constraint fk_review_reply_author foreign key (author_id, author_version_id) references supply_manager."user"(id, version_id)
);

comment on table supply_manager.review_reply is 'Таблица ответов на отзывы.';

comment on column supply_manager.review_reply.id is 'Идентификатор записи';
comment on column supply_manager.review_reply.version_id is 'Идентификатор версии записи';
comment on column supply_manager.review_reply.review_id is 'ID отзыва, на который дан ответ';
comment on column supply_manager.review_reply.author_id is 'ID автора ответа';
comment on column supply_manager.review_reply.reply_text is 'Текст ответа';
comment on column supply_manager.review_reply.obsolete is 'Признак устаревшей записи';
comment on column supply_manager.review_reply.begin_ts is 'Дата начала действия записи';
comment on column supply_manager.review_reply.end_ts is 'Дата окончания действия записи';