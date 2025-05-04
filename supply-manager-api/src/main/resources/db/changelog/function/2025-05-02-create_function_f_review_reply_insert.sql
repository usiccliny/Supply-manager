--liquibase formatted sql
--changeset eshardakov:create_function_f_review_reply_insert runOnChange:true endDelimiter:/
--comment Триггерная функция для управления вставкой записей в таблицу ответов на отзывы.

create or replace function supply_manager.f_review_reply_insert()
returns trigger as $$
/*
 * version: 1.0
 * date: 2025-04-10
 * author: eshardakov
 * description: Триггерная функция для управления вставкой записей в таблицу ответов на отзывы.
 * version: 1.0, eshardakov, 2025-04-10.
 */
declare
  p_date date;
  p_new_id int8;
  p_version_id supply_manager.review_reply.version_id%type;
  p_review_id supply_manager.review_reply.review_id%type;
  p_review_version_id supply_manager.review_reply.review_version_id%type;
  p_author_id supply_manager.review_reply.author_id%type;
  p_author_version_id supply_manager.review_reply.author_version_id%type;
  p_reply_text supply_manager.review_reply.reply_text%type;
  p_obsolete bool;
begin
    if new.id is null then
        -- Проверяем, есть ли такая же запись в таблице по уникальным полям
        select id, version_id, review_id, review_version_id, author_id, author_version_id,
               reply_text, obsolete
          into new.id, p_version_id, p_review_id, p_review_version_id, p_author_id, p_author_version_id,
               p_reply_text, p_obsolete
          from supply_manager.review_reply
         where new.review_id = review_id
           and new.author_id = author_id
         order by end_ts desc
         limit 1;

        p_date := now()::date; -- дата добавления записи
        
        -- Проверяем является ли вставляемая строка полным дубликатом существующей
        if ( md5(row(new.review_id, new.review_version_id, new.author_id, new.author_version_id,
                     new.reply_text)::text)
           = md5(row(p_review_id, p_review_version_id, p_author_id, p_author_version_id,
                     p_reply_text)::text) )
        then
            -- Если все значения равны, не вставляем строку
            return null;
        end if;

        -- Обновляем срок действия предыдущей версии
        update supply_manager.review_reply
           set end_ts = p_date::timestamp - '0.00001 sec'::interval
         where id = new.id
           and end_ts >= p_date::timestamp;

        -- Если признак устаревшей записи в любых старых версиях равен false, ставим true
        update supply_manager.review_reply
           set obsolete = false
         where id = new.id
           and obsolete is false;

        -- Если запись не найдена, заполняем id сущности из последовательности 
        if new.id is null then
              p_new_id := nextval('supply_manager.review_reply_id_seq');
              new.id := p_new_id;
              new.version_id := p_new_id; -- Используем id для версии, если это необходимо
              new.begin_ts := p_date::timestamp;
              new.end_ts := supply_manager.f_max_timestamp();
        else
            if new.obsolete is true
            then
                update supply_manager.review_reply
                   set obsolete = false,
                       end_ts = p_date::timestamp - '0.00001 sec'::interval
                 where id = new.id
                   and version_id = p_version_id;

                return null;
            else
                new.obsolete := false;
            end if;

            new.version_id := nextval('supply_manager.review_reply_id_seq');
        end if;

        -- Период действия новой записи
        new.begin_ts := p_date::timestamp;
        new.end_ts := supply_manager.f_max_timestamp();
    end if;

    return new;
end;
$$ language plpgsql;
/


create or replace trigger tg_review_reply_insert
before insert on supply_manager.review_reply
for each row
execute function supply_manager.f_review_reply_insert();
/