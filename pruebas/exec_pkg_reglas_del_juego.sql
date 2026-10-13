-- SET SERVEROUTPUT ON;
--------------------------------------------------------------------------------
-- prueba de prc_verificar_juego_en_curso
DECLARE
    juego number := &juego;
BEGIN
    pkg_reglas_del_juego.prc_verificar_juego_en_curso(juego);
    DBMS_OUTPUT.PUT_LINE('OK: juego en curso aceptado.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20008 THEN
            DBMS_OUTPUT.PUT_LINE('OK: juego concluido rechazado.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
        END IF;
END;
/
--------------------------------------------------------------------------------
-- prueba prc_validar_ataque_o_cura

-- CASO 1: Virus sobre órgano ajeno. Debe permitirlo.
BEGIN
    pkg_reglas_del_juego.prc_validar_ataque_o_cura(
        'VIRUS', 102, 1
    );
    DBMS_OUTPUT.PUT_LINE('OK: virus contra organo ajeno permitido.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
END;
/

-- CASO 2: Virus sobre órgano propio. Esperado: -20009
BEGIN
    pkg_reglas_del_juego.prc_validar_ataque_o_cura(
        'VIRUS', 101, 1
    );
    DBMS_OUTPUT.PUT_LINE('FALLO: permitio infectar organo propio.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20009 THEN
            DBMS_OUTPUT.PUT_LINE('OK: virus sobre organo propio rechazado.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
        END IF;
END;
/

-- CASO 3: Medicina sobre órgano propio. Debe permitirlo.
BEGIN
    pkg_reglas_del_juego.prc_validar_ataque_o_cura(
        'MEDICINA', 102, 2
    );
    DBMS_OUTPUT.PUT_LINE('OK: medicina sobre organo propio permitida.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
END;
/

-- CASO 4: Medicina sobre órgano ajeno. Esperado: -20010
BEGIN
    pkg_reglas_del_juego.prc_validar_ataque_o_cura(
        'MEDICINA', 101, 2
    );
    DBMS_OUTPUT.PUT_LINE('FALLO: permitio curar organo ajeno.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20010 THEN
            DBMS_OUTPUT.PUT_LINE('OK: medicina sobre organo ajeno rechazada.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
        END IF;
END;
/

-- CASO 5: Órgano inexistente. Esperado: -20015
BEGIN
    pkg_reglas_del_juego.prc_validar_ataque_o_cura(
        'VIRUS', 999999, 1
    );
    DBMS_OUTPUT.PUT_LINE('FALLO: acepto un organo inexistente.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20015 THEN
            DBMS_OUTPUT.PUT_LINE('OK: organo inexistente rechazado.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
        END IF;
END;
/

--------------------------------------------------------------------------------

-- prueba validar_color_organo

-- CASO 1: Color correcto
BEGIN
    pkg_reglas_del_juego.validar_color_organo('AZUL', 102);
    DBMS_OUTPUT.PUT_LINE('OK: color correcto.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
END;
/

-- CASO 2: Color incorrecto. Esperado: -20004
BEGIN
    pkg_reglas_del_juego.validar_color_organo('ROJO', 102);
    DBMS_OUTPUT.PUT_LINE('FALLO: acepto un color incorrecto.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20004 THEN
            DBMS_OUTPUT.PUT_LINE('OK: color incorrecto rechazado.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
        END IF;
END;
/

-- CASO 3: Órgano inexistente. Esperado: -20005
BEGIN
    pkg_reglas_del_juego.validar_color_organo('AZUL', 999999);
    DBMS_OUTPUT.PUT_LINE('FALLO: acepto un organo inexistente.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20005 THEN
            DBMS_OUTPUT.PUT_LINE('OK: organo inexistente rechazado.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
        END IF;
END;
/

--------------------------------------------------------------------------------
-- prueba validar_turno_cubre

-- CASO 1: Turno normal. Debe permitir cobertura.
BEGIN
    pkg_reglas_del_juego.validar_turno_cubre(1, 14);
    DBMS_OUTPUT.PUT_LINE('OK: turno habilitado para cobertura.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
END;
/

-- CASO 2: Pasada. Esperado: -20011
BEGIN
    pkg_reglas_del_juego.validar_turno_cubre(1, 13);
    DBMS_OUTPUT.PUT_LINE('FALLO: permitio cubrir durante una pasada.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20011 THEN
            DBMS_OUTPUT.PUT_LINE('OK: cobertura rechazada durante pasada.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
        END IF;
END;
/

-- CASO 3: Ya se jugó un órgano. Esperado: -20012
BEGIN
    pkg_reglas_del_juego.validar_turno_cubre(1, 1);
    DBMS_OUTPUT.PUT_LINE('FALLO: permitio dos cartas en el turno.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20012 THEN
            DBMS_OUTPUT.PUT_LINE('OK: segunda carta rechazada.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
        END IF;
END;
/

--------------------------------------------------------------------------------

-- prueba validar_turno_organo


-- CASO 1: Turno normal. Debe permitir órgano.
BEGIN
    pkg_reglas_del_juego.validar_turno_organo(1, 14);
    DBMS_OUTPUT.PUT_LINE('OK: turno habilitado para organo.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
END;
/

-- CASO 2: Pasada. Esperado: -20011
BEGIN
    pkg_reglas_del_juego.validar_turno_organo(1, 13);
    DBMS_OUTPUT.PUT_LINE('FALLO: permitio jugar organo durante pasada.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20011 THEN
            DBMS_OUTPUT.PUT_LINE('OK: organo rechazado durante pasada.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
        END IF;
END;
/

-- CASO 3: Ya se jugó una cobertura en la jugada 10.
-- Esperado: -20012
BEGIN
    pkg_reglas_del_juego.validar_turno_organo(1, 10);
    DBMS_OUTPUT.PUT_LINE('FALLO: permitio dos cartas en el turno.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20012 THEN
            DBMS_OUTPUT.PUT_LINE('OK: organo rechazado por cobertura previa.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
        END IF;
END;
/

--------------------------------------------------------------------------------

-- prueba verificar victoria


-- CASO 1: El jugador 2 tiene solo tres órganos.
BEGIN
    pkg_reglas_del_juego.verificar_victoria(1, 14);

    IF (SELECT COUNT(*) FROM JUEGO
        WHERE ID_juego = 1 AND Estado = 'CONCLUIDO') > 0 THEN
        DBMS_OUTPUT.PUT_LINE('REVISAR: el juego quedo concluido.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('OK: no se declaro victoria con tres organos.');
    END IF;
END;
/


DECLARE
    v_estado JUEGO.Estado%TYPE;
BEGIN
    pkg_reglas_del_juego.verificar_victoria(1, 14);

    SELECT Estado
    INTO v_estado
    FROM JUEGO
    WHERE ID_juego = 1;

    IF v_estado <> 'CONCLUIDO' THEN
        DBMS_OUTPUT.PUT_LINE(
            'OK: no se declaro victoria con tres organos.'
        );
    ELSE
        DBMS_OUTPUT.PUT_LINE(
            'REVISAR: el juego quedo concluido.'
        );
    END IF;
END;
/

-- CASO 2: Cuarto órgano del jugador 3.
INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (17, 1, 0, 3);

INSERT INTO ORGANO_EN_MESA
    (ID_carta, Organo, Color, ID_jugada, ID_juego)
VALUES
    (110, 'CORAZON', 'AMARILLO', 17, 1);

BEGIN
    pkg_reglas_del_juego.verificar_victoria(1, 17);
END;
/

DECLARE
    v_estado JUEGO.Estado%TYPE;
BEGIN
    SELECT Estado
    INTO v_estado
    FROM JUEGO
    WHERE ID_juego = 1;

    IF v_estado = 'CONCLUIDO' THEN
        DBMS_OUTPUT.PUT_LINE(
            'OK: el juego fue concluido por victoria.'
        );
    ELSE
        DBMS_OUTPUT.PUT_LINE(
            'REVISAR: no se detecto la victoria.'
        );
    END IF;
END;
/

SELECT ID_juego, Estado
FROM JUEGO
WHERE ID_juego = 1;

SELECT ID_jugada, ID_jugador, Pasada
FROM JUGADA
WHERE ID_juego = 1
ORDER BY ID_jugada;

-- LIMPIEZA: retirar los datos temporales de la prueba
UPDATE JUEGO
SET Estado = 'EN CURSO'
WHERE ID_juego = 1;

DELETE FROM ORGANO_EN_MESA
WHERE ID_carta = 110
  AND ID_juego = 1;

DELETE FROM JUGADA
WHERE ID_juego = 1
  AND ID_jugada = 17;

COMMIT;
