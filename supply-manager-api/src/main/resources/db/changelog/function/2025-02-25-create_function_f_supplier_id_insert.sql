--liquibase formatted sql
--changeset eshardakov:create_function_f_supplier_insert runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Триггер для вычисления значений версионных полей для таблицы Поставщики.

create or replace function supply_manager.f_supplier_insert()
returns trigger as $$
/*
 * version: 1.0
 * date: 2025-02-25
 * author: eshardakov
 * description: АРМ Менеджер по поставкам. Триггер для вычисления значений версионных полей для таблицы Поставщики.
 * version: 1.0, eshardakov, 2025-02-25 - Создаем триггер для обновления значений версионных полей.
 */
declare
  p_date date;
  p_new_id int8;
  p_version_id supply_manager.supplier.supplier_version_id%type;
  p_contact_person supply_manager.supplier.contact_person%type;
  p_phone_number supply_manager.supplier.phone_number%type;
  p_email supply_manager.supplier.email%type;
  p_address supply_manager.supplier.address%type;
  p_company_id supply_manager.supplier.company_id%type;
  p_company_vers_id supply_manager.supplier.company_vers_id%type;
  p_post_id supply_manager.supplier.post_id%type;
  p_obsolete bool;
begin
    if new.supplier_id is null then
        -- Проверяем, есть ли такая же запись в таблице
        select supplier_id, supplier_version_id, contact_person, phone_number,
               email, address, company_id, company_vers_id, post_id, obsolete
          into new.supplier_id, p_version_id, p_contact_person, 
               p_phone_number, p_email, p_address, p_company_id, p_company_vers_id,
               p_post_id, p_obsolete
          from supply_manager.supplier
         where new.company_id = company_id
           and new.company_vers_id = company_vers_id
           and new.post_id = post_id
         order by end_ts desc
         limit 1;

        p_date := now()::date; -- дата добавления записи
        
        -- Проверяем является ли вставляемая строка полным дубликатом существующей
        if ( md5(row(new.contact_person, new.phone_number, new.email,
                     new.address, new.company_id, new.company_vers_id, new.post_id)::text)
           = md5(row(p_contact_person, p_phone_number, p_email,
                     p_address, p_company_id, p_company_vers_id, p_post_id)::text) )
        then
            -- Если все значения равны, не вставляем строку
            return null;
        end if;

        -- Обновляем срок действия предыдущей версии
        update supply_manager.supplier
           set end_ts = p_date::timestamp - '0.00001 sec'::interval
         where supplier_id = new.supplier_id
           and end_ts >= p_date::timestamp;

        -- Если признак устаревшей записи в любых старых версиях равен false, ставим true
        update supply_manager.supplier
           set obsolete = true
         where supplier_id = new.supplier_id
           and obsolete is false;

        -- Если запись не найдена, заполняем id сущности из последовательности 
        if new.supplier_id is null then
              p_new_id := nextval('supply_manager.supplier_id_seq');
              new.supplier_id := p_new_id;
              new.supplier_version_id := p_new_id; -- Используя id для версии, если это необходимо
              new.begin_ts := p_date::timestamp;
              new.end_ts := supply_manager.f_max_timestamp();
        else
            if new.obsolete is true
            then
                update supply_manager.supplier
                   set obsolete = true,
                       end_ts = p_date::timestamp - '0.00001 sec'::interval
                 where supplier_id = new.supplier_id
                   and supplier_version_id = p_version_id;

                return null;
            else
                new.obsolete := false;
            end if;

            new.supplier_version_id := nextval('supply_manager.supplier_id_seq');
        end if;

        -- Период действия новой записи
        new.begin_ts := p_date::timestamp;
        new.end_ts := supply_manager.f_max_timestamp();
    end if;

    return new;
end;
$$ language plpgsql;
/

create or replace trigger tg_supplier_insert
before insert on supply_manager.supplier
for each row
execute function supply_manager.f_supplier_insert();
/