--liquibase formatted sql
--changeset eshardakov:update_function_f_order_insert runOnChange:true endDelimiter:/
--comment Изменение триггерной функции для учета новых полей.

create or replace function supply_manager.f_order_insert()
returns trigger as $$
/*
 * version: 1.1
 * date: 2025-02-28
 * author: eshardakov
 * description: Обновленная триггерная функция для учета полей способа оплаты и статуса заказа.
 * version: 1.1, eshardakov, 2025-02-28.
 */
declare
  p_date date;
  p_new_id int8;
  p_version_id supply_manager."order".version_id%type;
  p_user_id supply_manager."order".user_id%type;
  p_user_version_id supply_manager."order".user_version_id%type;
  p_status_id supply_manager.sp_order_status.id%type;
  p_payment_method_id supply_manager.sp_payment_method.id%type;
  p_total_amount supply_manager."order".total_amount%type;
  p_shipping_address supply_manager."order".shipping_address%type;
  p_billing_address supply_manager."order".billing_address%type;
  p_tracking_number supply_manager."order".tracking_number%type;
  p_notes supply_manager."order".notes%type;
  p_obsolete bool;
begin
    if new.id is null then
        -- Проверяем, есть ли такая же запись в таблице по уникальным полям
        select id, version_id, user_id, user_version_id, 
               order_status_id, payment_method_id, 
               total_amount, shipping_address, 
               billing_address, tracking_number, notes, obsolete
          into new.id, p_version_id, p_user_id, p_user_version_id,
               p_status_id, p_payment_method_id, 
               p_total_amount, p_shipping_address, 
               p_billing_address, p_tracking_number, p_notes, p_obsolete
          from supply_manager."order"
         where new.user_id = user_id
           and new.tracking_number = tracking_number
         order by end_ts desc
         limit 1;

        p_date := now()::date; -- дата добавления записи
        
        -- Проверяем является ли вставляемая строка полным дубликатом существующей
        if ( md5(row(new.user_id, new.user_version_id, new.payment_method_id, new.order_status_id,
                     new.total_amount, new.shipping_address,
                     new.billing_address, new.tracking_number,
                     new.notes)::text)
           = md5(row(p_user_id, p_user_version_id, p_payment_method_id,
                     p_status_id, p_total_amount, p_shipping_address,
                     p_billing_address, p_tracking_number, p_notes)::text) )
        then
            -- Если все значения равны, не вставляем строку
            return null;
        end if;

        -- Обновляем срок действия предыдущей версии
        update supply_manager."order"
           set end_ts = p_date::timestamp - '0.00001 sec'::interval
         where id = new.id
           and end_ts >= p_date::timestamp;

        -- Если признак устаревшей записи в любых старых версиях равен false, ставим true
        update supply_manager."order"
           set obsolete = true
         where id = new.id
           and obsolete is false;

        -- Если запись не найдена, заполняем id сущности из последовательности 
        if new.id is null then
              p_new_id := nextval('supply_manager.order_id_seq');
              new.id := p_new_id;
              new.version_id := p_new_id; -- Используя id для версии, если это необходимо
              new.begin_ts := p_date::timestamp;
              new.end_ts := supply_manager.f_max_timestamp();
        else
            if new.obsolete is true
            then
                update supply_manager."order"
                   set obsolete = true,
                       end_ts = p_date::timestamp - '0.00001 sec'::interval
                 where id = new.id
                   and version_id = p_version_id;

                return null;
            else
                new.obsolete := false;
            end if;

            new.version_id := nextval('supply_manager.order_id_seq');
        end if;

        -- Период действия новой записи
        new.begin_ts := p_date::timestamp;
        new.end_ts := supply_manager.f_max_timestamp();
    end if;

    return new;
end;
$$ language plpgsql;
/

create or replace trigger tg_order_insert
before insert on supply_manager."order"
for each row
execute function supply_manager.f_order_insert();
/