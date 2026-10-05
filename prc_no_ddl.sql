CREATE OR REPLACE PROCEDURE prc_bloquear_ddl (
    p_evento      IN VARCHAR2,
    p_objeto      IN VARCHAR2,
    p_tipo_objeto IN VARCHAR2
) IS
BEGIN
    RAISE_APPLICATION_ERROR(
        -20100,
        'Operación DDL no permitida: ' ||
        p_evento || ' sobre ' ||
        p_tipo_objeto || ' ' ||
        p_objeto
    );
END;
/