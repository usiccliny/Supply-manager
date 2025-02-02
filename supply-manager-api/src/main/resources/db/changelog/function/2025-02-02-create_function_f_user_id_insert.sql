--liquibase formatted sql
--changeset eshardakov:create_table_user runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Триггер для вычисления значений версионных полей для таблицы Пользователи.

create or replace function supply_manager.f_user_id_insert()
returns trigger as $$
/*
 * version: 1.0
 * date: 2025-02-02
 * author: eshardakov
 * description: АРМ Менеджер по поставкам. Триггер для вычисления значений версионных полей для таблицы Пользователи.
 * version: 1.0, eshardakov, 2025-02-02 - Создаем триггер для обновления значений версионных полей.
 */
declare
  p_date date;
  p_new_id int8;
  p_version_id supply_manager.user.version_id%type;
  p_username supply_manager.user.username%type;
  p_password supply_manager.user.password%type;
  p_email supply_manager.user.email%type;
  p_role_id supply_manager.user.role_id%type;
  p_obsolete bool;
begin
    if new.id is null then
        -- Проверяем, есть ли такая же запись в таблице
        select id
             , version_id
             , username
             , password
             , email
             , role_id
             , obsolete
          into new.id
             , p_version_id
             , p_username
             , p_password
             , p_email
             , p_role_id
             , p_obsolete
          from supply_manager.user
         where new.username = username
         order by end_ts desc
         limit 1;

        p_date := now()::date; -- дата добавления записи
        
        -- Проверяем является ли вставляемая строка полным дубликатом существующей
        if ( md5(row(new.username, new.password, new.email, new.role_id, new.obsolete)::text)
           = md5(row(p_username, p_password, p_email, p_role_id, p_obsolete)::text) )
        then
            -- Если все значения равны, не вставляем строку
            return null;
        end if;
        
        -- Обновляем срок действия предыдущей версии
        update supply_manager.user
           set end_ts = p_date::timestamp - '0.00001 sec'::interval
         where id = new.id
           and end_ts >= p_date::timestamp;
       
        -- Если признак устаревшей записи в любых старых версиях равен false, ставим true
        update supply_manager.user
           set obsolete = true
         where id = new.id
           and obsolete is false;
       
        -- Если запись не найдена, заполняем id сущности из последовательности 
        if new.id is null then
              p_new_id := nextval('supply_manager.user_id_seq');
              new.id := p_new_id;
              new.version_id := p_new_id;
              new.begin_ts := p_date::timestamp;
              new.end_ts := supply_manager.f_max_timestamp();
        else
            if new.obsolete is true
            then
                update supply_manager.user
                   set obsolete = true,
                       end_ts = p_date::timestamp - '0.00001 sec'::interval
                 where id = new.id
                   and version_id = p_version_id;
                
                return null;
            else
                new.obsolete := false;
            end if;
        
            new.version_id := nextval('supply_manager.user_id_seq');
        end if;
        
        -- Период действия новой записи
        new.begin_ts := p_date::timestamp;
        new.end_ts := supply_manager.f_max_timestamp();
    end if;

    return new;
end;
$$ language plpgsql;
/

create or replace trigger tg_user_bir
before insert on supply_manager.user
for each row
execute function supply_manager.f_user_id_insert();
/