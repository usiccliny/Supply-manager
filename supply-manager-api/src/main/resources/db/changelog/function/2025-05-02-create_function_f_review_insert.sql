--liquibase formatted sql
--changeset eshardakov:create_function_f_review_insert runOnChange:true endDelimiter:/
--comment Триггерная функция для управления вставкой записей в таблицу отзывов.

create or replace function supply_manager.f_review_insert()
returns trigger as $$
/*
 * version: 1.0
 * date: 2025-04-10
 * author: eshardakov
 * description: Триггерная функция для управления вставкой записей в таблицу отзывов.
 * version: 1.0, eshardakov, 2025-04-10.
 */
declare
  p_date date;
  p_new_id int8;
  p_version_id supply_manager.review.version_id%type;
  p_author_id supply_manager.review.author_id%type;
  p_author_version_id supply_manager.review.author_version_id%type;
  p_target_id supply_manager.review.target_id%type;
  p_target_version_id supply_manager.review.target_version_id%type;
  p_order_id supply_manager.review.order_id%type;
  p_order_version_id supply_manager.review.order_version_id%type;
  p_rating supply_manager.review.rating%type;
  p_comment supply_manager.review.comment%type;
  p_obsolete bool;
begin
    if new.id is null then
        -- Проверяем, есть ли такая же запись в таблице по уникальным полям
        select id, version_id, author_id, author_version_id, target_id, target_version_id,
               order_id, order_version_id, rating, comment, obsolete
          into new.id, p_version_id, p_author_id, p_author_version_id, p_target_id, p_target_version_id,
               p_order_id, p_order_version_id, p_rating, p_comment, p_obsolete
          from supply_manager.review
         where new.author_id = author_id
           and new.target_id = target_id
           and new.order_id = order_id
         order by end_ts desc
         limit 1;

        p_date := now()::date; -- дата добавления записи
        
        -- Проверяем является ли вставляемая строка полным дубликатом существующей
        if ( md5(row(new.author_id, new.author_version_id, new.target_id, new.target_version_id,
                     new.order_id, new.order_version_id, new.rating, new.comment)::text)
           = md5(row(p_author_id, p_author_version_id, p_target_id, p_target_version_id,
                     p_order_id, p_order_version_id, p_rating, p_comment)::text) )
        then
            -- Если все значения равны, не вставляем строку
            return null;
        end if;

        -- Обновляем срок действия предыдущей версии
        update supply_manager.review
           set end_ts = p_date::timestamp - '0.00001 sec'::interval
         where id = new.id
           and end_ts >= p_date::timestamp;

        -- Если признак устаревшей записи в любых старых версиях равен false, ставим true
        update supply_manager.review
           set obsolete = true
         where id = new.id
           and obsolete is false;

        -- Если запись не найдена, заполняем id сущности из последовательности 
        if new.id is null then
              p_new_id := nextval('supply_manager.review_id_seq');
              new.id := p_new_id;
              new.version_id := p_new_id; -- Используем id для версии, если это необходимо
              new.begin_ts := p_date::timestamp;
              new.end_ts := supply_manager.f_max_timestamp();
        else
            if new.obsolete is true
            then
                update supply_manager.review
                   set obsolete = true,
                       end_ts = p_date::timestamp - '0.00001 sec'::interval
                 where id = new.id
                   and version_id = p_version_id;

                return null;
            else
                new.obsolete := false;
            end if;

            new.version_id := nextval('supply_manager.review_id_seq');
        end if;

        -- Период действия новой записи
        new.begin_ts := p_date::timestamp;
        new.end_ts := supply_manager.f_max_timestamp();
    end if;

    return new;
end;
$$ language plpgsql;
/

create or replace trigger tg_review_insert
before insert on supply_manager.review
for each row
execute function supply_manager.f_review_insert();