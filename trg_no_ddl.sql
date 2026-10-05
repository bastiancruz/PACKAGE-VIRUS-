
-- SOLO IMPLEMENTAR EN LANZAMIENTO
CREATE OR REPLACE TRIGGER trg_bloquear_ddl
BEFORE DDL ON SCHEMA
BEGIN
    prc_bloquear_ddl(
        p_evento      => ORA_SYSEVENT,
        p_objeto      => ORA_DICT_OBJ_NAME,
        p_tipo_objeto => ORA_DICT_OBJ_TYPE
    );
END;
/