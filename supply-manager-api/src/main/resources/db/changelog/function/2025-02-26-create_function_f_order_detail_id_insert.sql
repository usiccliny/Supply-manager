--liquibase formatted sql
--changeset eshardakov:create_function_f_order_detail_insert runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Триггер для вычисления значений версионных полей для таблицы Детали Заказов.

create or replace function supply_manager.f_order_detail_insert()
returns trigger as $$
/*
 * version: 1.0
 * date: 2025-02-25
 * author: eshardakov
 * description: АРМ Менеджер по поставкам. Триггер для вычисления значений версионных полей для таблицы Детали Заказов.
 * version: 1.0, eshardakov, 2025-02-25 - Создаем триггер для обновления значений версионных полей.
 */
declare
  p_date date;
  p_new_id int8;
  p_version_id supply_manager.order_detail.version_id%type;
  p_order_id supply_manager.order_detail.order_id%type;
  p_order_version_id supply_manager.order_detail.order_version_id%type;
  p_supplier_id supply_manager.order_detail.supplier_id%type;
  p_supplier_version_id supply_manager.order_detail.supplier_version_id%type;
  p_product_id supply_manager.order_detail.product_id%type;
  p_product_version_id supply_manager.order_detail.product_version_id%type;
  p_quantity supply_manager.order_detail.quantity%type;
  p_obsolete bool;
begin
    if new.id is null then
        -- Проверяем, есть ли такая же запись в таблице по уникальным полям
        select id, version_id, order_id, order_version_id, supplier_id, supplier_version_id,
               product_id, product_version_id, quantity, obsolete
          into new.id, p_version_id, p_order_id, p_order_version_id, p_supplier_id,
               p_supplier_version_id, p_product_id, p_product_version_id, p_quantity, p_obsolete
          from supply_manager.order_detail
         where new.order_id = order_id
           and new.supplier_id = supplier_id
           and new.product_id = product_id
         order by end_ts desc
         limit 1;

        p_date := now()::date; -- дата добавления записи
        
        -- Проверяем является ли вставляемая строка полным дубликатом существующей
        if ( md5(row(new.order_id, new.order_version_id, new.supplier_id, new.supplier_version_id,
                     new.product_id, new.product_version_id, new.quantity)::text)
           = md5(row(p_order_id, p_order_version_id, p_supplier_id, p_supplier_version_id,
                     p_product_id, p_product_version_id, p_quantity)::text) )
        then
            -- Если все значения равны, не вставляем строку
            return null;
        end if;

        -- Обновляем срок действия предыдущей версии
        update supply_manager.order_detail
           set end_ts = p_date::timestamp - '0.00001 sec'::interval
         where id = new.id
           and end_ts >= p_date::timestamp;

        -- Если признак устаревшей записи в любых старых версиях равен false, ставим true
        update supply_manager.order_detail
           set obsolete = true
         where id = new.id
           and obsolete is false;

        -- Если запись не найдена, заполняем id сущности из последовательности 
        if new.id is null then
              p_new_id := nextval('supply_manager.order_detail_id_seq');
              new.id := p_new_id;
              new.version_id := p_new_id; -- Используя id для версии, если это необходимо
              new.begin_ts := p_date::timestamp;
              new.end_ts := supply_manager.f_max_timestamp();
        else
            if new.obsolete is true
            then
                update supply_manager.order_detail
                   set obsolete = true,
                       end_ts = p_date::timestamp - '0.00001 sec'::interval
                 where id = new.id
                   and version_id = p_version_id;

                return null;
            else
                new.obsolete := false;
            end if;

            new.version_id := nextval('supply_manager.order_detail_id_seq');
        end if;

        -- Период действия новой записи
        new.begin_ts := p_date::timestamp;
        new.end_ts := supply_manager.f_max_timestamp();
    end if;

    return new;
end;
$$ language plpgsql;
/

create or replace trigger tg_order_detail_insert
before insert on supply_manager.order_detail
for each row
execute function supply_manager.f_order_detail_insert();
/