--liquibase formatted sql
--changeset eshardakov:create_table_review_reaction runOnChange:true
--comment АРМ Менеджер по поставкам. Таблица реакций на отзывы.

create sequence if not exists supply_manager.review_reaction_id_seq;

create table if not exists supply_manager.review_reaction (
/*
 * Date: 2025-04-10.
 * Version: 1.0.
 * Author: eshardakov.
 * Description: АРМ Менеджер по поставкам. Таблица реакций на отзывы.
 * Version 1.0, eshardakov, 2025-04-10.
 */
  id int8 not null,
  version_id int8 not null,
  review_id int8 not null, -- ID отзыва
  review_version_id int8 not null,
  user_id int8 not null, -- ID пользователя, который поставил реакцию
  user_version_id int8 not null,
  reaction_type text not null check (reaction_type in ('like', 'dislike')), -- Тип реакции (лайк или дизлайк)
  obsolete bool not null default false, -- Признак устаревшей записи
  begin_ts timestamp not null default current_timestamp, -- Дата начала действия записи
  end_ts timestamp not null default supply_manager.f_max_timestamp(), -- Дата окончания действия записи
  constraint pk_review_reaction primary key (version_id),
  constraint uk_review_reaction unique(id, version_id, review_id, user_id),
  constraint fk_review_reaction_review foreign key (review_id, review_version_id) references supply_manager.review(id, version_id),
  constraint fk_review_reaction_user foreign key (user_id, user_version_id) references supply_manager."user"(id, version_id)
);

comment on table supply_manager.review_reaction is 'Таблица реакций на отзывы.';

comment on column supply_manager.review_reaction.id is 'Идентификатор записи';
comment on column supply_manager.review_reaction.version_id is 'Идентификатор версии записи';
comment on column supply_manager.review_reaction.review_id is 'ID отзыва';
comment on column supply_manager.review_reaction.user_id is 'ID пользователя, который поставил реакцию';
comment on column supply_manager.review_reaction.reaction_type is 'Тип реакции (лайк или дизлайк)';
comment on column supply_manager.review_reaction.obsolete is 'Признак устаревшей записи';
comment on column supply_manager.review_reaction.begin_ts is 'Дата начала действия записи';
comment on column supply_manager.review_reaction.end_ts is 'Дата окончания действия записи';