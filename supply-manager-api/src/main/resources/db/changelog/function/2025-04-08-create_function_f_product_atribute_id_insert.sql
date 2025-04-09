--liquibase formatted sql
--changeset eshardakov:create_function_f_product_attribute_insert runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Триггер для вычисления значений версионных полей для таблицы Атрибуты товара.

create or replace function supply_manager.f_product_attribute_insert()
returns trigger as $$
/*
 * version: 1.0
 * date: 2025-04-08
 * author: eshardakov
 * description: АРМ Менеджер по поставкам. Триггер для вычисления значений версионных полей для таблицы Атрибуты товара.
 * version: 1.0, eshardakov, 2025-04-08 - Создаем триггер для обновления значений версионных полей.
 */
declare
  p_date date;
  p_new_id int8;
  p_version_id supply_manager.product_attribute.version_id%type;
  p_product_id supply_manager.product_attribute.product_id%type;
  p_product_version_id supply_manager.product_attribute.product_version_id%type;
  p_attribute_id supply_manager.product_attribute.attribute_id%type;
  p_value supply_manager.product_attribute.value%type;
  p_obsolete bool;
begin
    if new.id is null then
        -- Проверяем, есть ли такая же запись в таблице
        select id, version_id, product_id, product_version_id, attribute_id,
               value, obsolete
          into new.id, p_version_id, p_product_id, p_product_version_id,
               p_attribute_id, p_value, p_obsolete
          from supply_manager.product_attribute
         where new.product_id = product_id
           and new.product_version_id = product_version_id
           and new.attribute_id = attribute_id
         order by end_ts desc
         limit 1;

        p_date := now()::date; -- дата добавления записи
        
        -- Проверяем является ли вставляемая строка полным дубликатом существующей
--        if ( md5(row(new.product_id, new.product_version_id, new.attribute_id, new.value,
--                     new.price, new.quantity, new.product_attribute_name)::text)
--           = md5(row(p_product_id, p_product_version_id, p_attribute_id, p_value,
--                     p_price, p_quantity, p_product_attribute_name)::text) )
--        then
--            -- Если все значения равны, не вставляем строку
--            return null;
--        end if;

        -- Обновляем срок действия предыдущей версии
        update supply_manager.product_attribute
           set end_ts = p_date::timestamp - '0.00001 sec'::interval
         where id = new.id
           and end_ts >= p_date::timestamp;

        -- Если признак устаревшей записи в любых старых версиях равен false, ставим true
        update supply_manager.product_attribute
           set obsolete = true
         where id = new.id
           and obsolete is false;

        -- Если запись не найдена, заполняем id сущности из последовательности 
        if new.id is null then
              p_new_id := nextval('supply_manager.product_attribute_id_seq');
              new.id := p_new_id;
              new.version_id := p_new_id; -- Используя id для версии, если это необходимо
              new.begin_ts := p_date::timestamp;
              new.end_ts := supply_manager.f_max_timestamp();
        else
            if new.obsolete is true
            then
                update supply_manager.product_attribute
                   set obsolete = true,
                       end_ts = p_date::timestamp - '0.00001 sec'::interval
                 where id = new.id
                   and version_id = p_version_id;

                return null;
            else
                new.obsolete := false;
            end if;

            new.version_id := nextval('supply_manager.product_attribute_id_seq');
        end if;

        -- Период действия новой записи
        new.begin_ts := p_date::timestamp;
        new.end_ts := supply_manager.f_max_timestamp();
    end if;

    return new;
end;
$$ language plpgsql;
/

create or replace trigger tg_product_attribute_insert
before insert on supply_manager.product_attribute
for each row
execute function supply_manager.f_product_attribute_insert();
/