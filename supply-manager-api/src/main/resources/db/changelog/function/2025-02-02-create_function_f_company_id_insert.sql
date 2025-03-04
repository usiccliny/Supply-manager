--liquibase formatted sql
--changeset eshardakov:create_function_f_company_id_insert runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Триггер для вычисления значений версионных полей для таблицы Пользователи.

create or replace function supply_manager.f_company_id_insert()
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
  p_version_id supply_manager.company.version_id%type;
  p_name supply_manager.company.name%type;
  p_email supply_manager.company.email%type;
  p_address supply_manager.company.address%type;
  p_website supply_manager.company.website%type;
  p_lifetime supply_manager.company.lifetime%type;
  p_rating supply_manager.company.rating%type;
  p_company_code supply_manager.company.company_code%type;
  p_logotype supply_manager.company.logotype%type;
  p_obsolete bool;
begin
    if new.id is null then
        -- Проверяем, есть ли такая же запись в таблице
        select id
             , version_id
             , name
             , email
             , address
             , website
             , lifetime
             , rating
             , company_code
             , logotype
             , obsolete
          into new.id
             , p_version_id
             , p_name
             , p_email
             , p_address
             , p_website
             , p_lifetime
             , p_rating
             , p_company_code
             , p_logotype
             , p_obsolete
          from supply_manager.company
         where new.company_code = company_code
         order by end_ts desc
         limit 1;

        p_date := now()::date; -- дата добавления записи
        
        -- Проверяем является ли вставляемая строка полным дубликатом существующей
        if ( md5(row(new.name, new.email, new.address, new.website, new.lifetime, new.rating, new.company_code, new.logotype)::text)
           = md5(row(p_name, p_email, p_address, p_website, p_lifetime, p_rating, p_company_code, p_logotype)::text) )
        then
            -- Если все значения равны, не вставляем строку
            return null;
        end if;
        
        -- Обновляем срок действия предыдущей версии
        update supply_manager.company
           set end_ts = p_date::timestamp - '0.00001 sec'::interval
         where id = new.id
           and end_ts >= p_date::timestamp;
       
        -- Если признак устаревшей записи в любых старых версиях равен false, ставим true
        update supply_manager.company
           set obsolete = true
         where id = new.id
           and obsolete is false;
       
        -- Если запись не найдена, заполняем id сущности из последовательности 
        if new.id is null then
              p_new_id := nextval('supply_manager.company_id_seq');
              new.id := p_new_id;
              new.version_id := p_new_id;
              new.begin_ts := p_date::timestamp;
              new.end_ts := supply_manager.f_max_timestamp();
        else
            if new.obsolete is true
            then
                update supply_manager.company
                   set obsolete = true,
                       end_ts = p_date::timestamp - '0.00001 sec'::interval
                 where id = new.id
                   and version_id = p_version_id;
                
                return null;
            else
                new.obsolete := false;
            end if;
        
            new.version_id := nextval('supply_manager.company_id_seq');
        end if;
        
        -- Период действия новой записи
        new.begin_ts := p_date::timestamp;
        new.end_ts := supply_manager.f_max_timestamp();
    end if;

    return new;
end;
$$ language plpgsql;
/

create or replace trigger tg_company_bir
before insert on supply_manager.company
for each row
execute function supply_manager.f_company_id_insert();
/