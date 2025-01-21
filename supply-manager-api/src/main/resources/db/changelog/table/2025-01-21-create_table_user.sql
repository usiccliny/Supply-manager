--liquibase formatted sql
--changeset eshardakov:create_table_user runOnChange:true labels:GASUCONORD-66
--comment АРМ Контроль поручений. Представление Карточка проекта.

create sequence if not exists supply_manager.user_id_seq;