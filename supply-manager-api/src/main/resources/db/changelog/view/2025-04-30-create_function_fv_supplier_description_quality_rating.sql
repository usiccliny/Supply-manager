--liquibase formatted sql
--changeset eshardakov:create_function_fv_supplier_description_quality_rating runOnChange:true endDelimiter:/
--comment АРМ Менеджер по поставкам. Параметризованная функция для рейтинга поставщиков с учетом даты.

create or replace function supply_manager.fv_supplier_description_quality_rating(
    i_date date -- Дата для фильтрации данных
)
returns table (
    supplier_id int8,
    contact_person text,
    total_rating numeric,
    total_rank int8
)
as $$
begin
    return query
    with filtered_data as materialized (
        -- Фильтруем данные по дате и выбираем актуальные записи
        select p.id as product_id,
               p.supplier_id,
               p.price,
               p.quantity,
               p.photo,
               p.video,
               p.begin_ts,
               p.obsolete
          from supply_manager.product p
         where (i_date = current_date and not p.obsolete) -- Если дата сегодняшняя, берем только неустаревшие записи
            or (i_date < current_date and p.begin_ts <= i_date::timestamp and 
                p.begin_ts = (
                    select max(p2.begin_ts)
                      from supply_manager.product p2
                     where p2.id = p.id
                       and p2.begin_ts <= i_date::timestamp
                ))
    ),
    supplier_attributes as materialized (
        -- Подсчитываем среднее количество атрибутов у товаров каждого поставщика
        select fd.supplier_id,
               avg(pa.attribute_count) as avg_attribute_count
          from filtered_data fd
          left join (
              select pa.product_id,
                     count(*) as attribute_count
                from supply_manager.product_attribute pa
               where not pa.obsolete
               group by pa.product_id
          ) pa on fd.product_id = pa.product_id
         group by fd.supplier_id
    ),
    supplier_photos as materialized (
        -- Подсчитываем процент товаров с фотографиями для каждого поставщика
        select fd.supplier_id,
               avg(case when fd.photo is not null then 1.0 else 0.0 end) as photo_percentage
          from filtered_data fd
         group by fd.supplier_id
    ),
    supplier_videos as materialized (
        -- Подсчитываем процент товаров с видео для каждого поставщика
        select fd.supplier_id,
               avg(case when fd.video is not null then 1.0 else 0.0 end) as video_percentage
          from filtered_data fd
         group by fd.supplier_id
    ),
    normalized_params as (
        -- Нормализация параметров
        select sa.supplier_id,
               -- Нормализованное среднее количество атрибутов
               case 
                   when max(sa.avg_attribute_count) over () = min(sa.avg_attribute_count) over () then 1.0
                   else (sa.avg_attribute_count::numeric - min(sa.avg_attribute_count) over ()) / 
                        (max(sa.avg_attribute_count) over () - min(sa.avg_attribute_count) over ())
               end as norm_avg_attribute_count,
               -- Нормализованный процент товаров с фотографиями
               case 
                   when max(sp.photo_percentage) over () = min(sp.photo_percentage) over () then 1.0
                   else (sp.photo_percentage::numeric - min(sp.photo_percentage) over ()) / 
                        (max(sp.photo_percentage) over () - min(sp.photo_percentage) over ())
               end as norm_photo_percentage,
               -- Нормализованный процент товаров с видео
               case 
                   when max(sv.video_percentage) over () = min(sv.video_percentage) over () then 1.0
                   else (sv.video_percentage::numeric - min(sv.video_percentage) over ()) / 
                        (max(sv.video_percentage) over () - min(sv.video_percentage) over ())
               end as norm_video_percentage
          from supplier_attributes sa
          left join supplier_photos sp on sa.supplier_id = sp.supplier_id
          left join supplier_videos sv on sa.supplier_id = sv.supplier_id
    ),
    final_rating as (
        -- Расчет итогового рейтинга
        select np.supplier_id,
               -- Веса для параметров
               0.5 * coalesce(np.norm_avg_attribute_count, 0) +
               0.3 * coalesce(np.norm_photo_percentage, 0) +
               0.2 * coalesce(np.norm_video_percentage, 0) as total_rating
          from normalized_params np
    )
    -- Ранжирование поставщиков
    select fr.supplier_id,
           s.contact_person,
           fr.total_rating,
           dense_rank() over (order by fr.total_rating desc) as total_rank
      from final_rating fr
      join supply_manager.supplier s 
        on fr.supplier_id = s.supplier_id
       and not s.obsolete
     order by fr.total_rating desc;
end;
$$ language plpgsql;
/

/* Пример использования
   
   select * from supply_manager.fv_supplier_description_quality_rating(now()::date);
 */