--liquibase formatted sql
--changeset eshardakov:create_function_f_product_insert runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Триггер для вычисления значений версионных полей для таблицы Продукты.

create or replace function supply_manager.f_product_insert()
returns trigger as $$
/*
 * version: 1.0
 * date: 2025-02-25
 * author: eshardakov
 * description: АРМ Менеджер по поставкам. Триггер для вычисления значений версионных полей для таблицы Продукты.
 * version: 1.0, eshardakov, 2025-02-25 - Создаем триггер для обновления значений версионных полей.
 */
declare
  p_date date;
  p_new_id int8;
  p_version_id supply_manager.product.version_id%type;
  p_supplier_id supply_manager.product.supplier_id%type;
  p_supplier_version_id supply_manager.product.supplier_version_id%type;
  p_category_product_id supply_manager.product.category_product_id%type;
  p_status_id supply_manager.product.status_id%type;
  p_price supply_manager.product.price%type;
  p_quantity supply_manager.product.quantity%type;
  p_product_name supply_manager.product.product_name%type;
  p_photo supply_manager.product.photo%type;
  p_video supply_manager.product.video%type;
  p_rating supply_manager.product.rating%type;
  p_obsolete bool;
begin
    if new.id is null then
        -- Проверяем, есть ли такая же запись в таблице
        select id, version_id, supplier_id, supplier_version_id, category_product_id,
               status_id, price, quantity, product_name, photo, video, rating, obsolete
          into new.id, p_version_id, p_supplier_id, p_supplier_version_id,
               p_category_product_id, p_status_id, p_price, p_quantity, p_product_name, p_photo, p_video, p_rating, p_obsolete
          from supply_manager.product
         where new.supplier_id = supplier_id
           and new.supplier_version_id = supplier_version_id
           and new.category_product_id = category_product_id
           and new.product_name = product_name
         order by end_ts desc
         limit 1;

        p_date := now()::date; -- дата добавления записи
        
        -- Проверяем является ли вставляемая строка полным дубликатом существующей
--        if ( md5(row(new.supplier_id, new.supplier_version_id, new.category_product_id, new.status_id,
--                     new.price, new.quantity, new.product_name)::text)
--           = md5(row(p_supplier_id, p_supplier_version_id, p_category_product_id, p_status_id,
--                     p_price, p_quantity, p_product_name)::text) )
--        then
--            -- Если все значения равны, не вставляем строку
--            return null;
--        end if;

        -- Обновляем срок действия предыдущей версии
        update supply_manager.product
           set end_ts = p_date::timestamp - '0.00001 sec'::interval
         where id = new.id
           and end_ts >= p_date::timestamp;

        -- Если признак устаревшей записи в любых старых версиях равен false, ставим true
        update supply_manager.product
           set obsolete = true
         where id = new.id
           and obsolete is false;

        -- Если запись не найдена, заполняем id сущности из последовательности 
        if new.id is null then
              p_new_id := nextval('supply_manager.product_id_seq');
              new.id := p_new_id;
              new.version_id := p_new_id; -- Используя id для версии, если это необходимо
              new.begin_ts := p_date::timestamp;
              new.end_ts := supply_manager.f_max_timestamp();
        else
            if new.obsolete is true
            then
                update supply_manager.product
                   set obsolete = true,
                       end_ts = p_date::timestamp - '0.00001 sec'::interval
                 where id = new.id
                   and version_id = p_version_id;

                return null;
            else
                new.obsolete := false;
            end if;

            new.version_id := nextval('supply_manager.product_id_seq');
        end if;

        -- Период действия новой записи
        new.begin_ts := p_date::timestamp;
        new.end_ts := supply_manager.f_max_timestamp();
    end if;

    return new;
end;
$$ language plpgsql;
/

create or replace trigger tg_product_insert
before insert on supply_manager.product
for each row
execute function supply_manager.f_product_insert();
/