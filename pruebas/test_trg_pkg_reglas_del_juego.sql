
-- ============================================================
-- JUGADAS PARA PROBAR LOS TRIGGERS
-- ============================================================

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (18, 1, 0, 1);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (19, 1, 0, 1);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (20, 1, 0, 1);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (21, 1, 0, 2);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (22, 1, 0, 1);

COMMIT;

--------------------------------------------------------------------------------
-- prueba trg_verificar_turno_cubre

-- CASO 1: Pasada (jugada 13). Esperado: ORA-20011.
BEGIN
    INSERT INTO CUBRE_ORGANO
        (ID_carta, Tipo, ID_jugada, ID_juego, Color, ID_carta_cubierta)
    VALUES
        (204, 'VIRUS', 13, 1, 'AZUL', 102);

    DBMS_OUTPUT.PUT_LINE('FALLO: permitio jugar despues de pasar.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20011 THEN
            DBMS_OUTPUT.PUT_LINE('OK: pasada rechazada.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        END IF;
END;
/

-- CASO 2: La jugada 1 ya tiene un órgano.
-- Esperado: ORA-20012.
BEGIN
    INSERT INTO CUBRE_ORGANO
        (ID_carta, Tipo, ID_jugada, ID_juego, Color, ID_carta_cubierta)
    VALUES
        (205, 'VIRUS', 1, 1, 'ROJO', 101);

    DBMS_OUTPUT.PUT_LINE('FALLO: permitio dos cartas en el turno.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20012 THEN
            DBMS_OUTPUT.PUT_LINE('OK: segunda carta rechazada.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        END IF;
END;
/

--------------------------------------------------------------------------------
-- prueba trg_validar_ataque_cura

-- CASO 1: Virus sobre órgano propio.
-- Jugador 1 intenta infectar su corazón (101).
-- Esperado: ORA-20009.
BEGIN
    INSERT INTO CUBRE_ORGANO
        (ID_carta, Tipo, ID_jugada, ID_juego, Color, ID_carta_cubierta)
    VALUES
        (206, 'VIRUS', 19, 1, 'ROJO', 101);

    DBMS_OUTPUT.PUT_LINE('FALLO: permitio infectar organo propio.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20009 THEN
            DBMS_OUTPUT.PUT_LINE('OK: ataque a organo propio rechazado.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        END IF;
END;
/

-- CASO 2: Medicina sobre órgano ajeno.
BEGIN
    INSERT INTO CUBRE_ORGANO
        (ID_carta, Tipo, ID_jugada, ID_juego, Color, ID_carta_cubierta)
    VALUES
        (207, 'MEDICINA', 20, 1, 'AZUL', 102);

    DBMS_OUTPUT.PUT_LINE('FALLO: permitio curar organo ajeno.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20010 THEN
            DBMS_OUTPUT.PUT_LINE('OK: curacion de organo ajeno rechazada.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        END IF;
END;
/

-- CASO 3: Virus sobre órgano ajeno.
BEGIN
    INSERT INTO CUBRE_ORGANO
        (ID_carta, Tipo, ID_jugada, ID_juego, Color, ID_carta_cubierta)
    VALUES
        (208, 'VIRUS', 18, 1, 'VERDE', 103);

    DBMS_OUTPUT.PUT_LINE(
        'INSERT ejecutado: revisar resultado del trigger posterior.'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            'El INSERT fallo: ' || SQLERRM
        );
END;
/

--------------------------------------------------------------------------------
-- probar trg_verificar_color

-- CASO 1: Color incorrecto.
BEGIN
    INSERT INTO CUBRE_ORGANO
        (ID_carta, Tipo, ID_jugada, ID_juego, Color, ID_carta_cubierta)
    VALUES
        (209, 'VIRUS', 22, 1, 'ROJO', 102);

    DBMS_OUTPUT.PUT_LINE('FALLO: acepto un color incorrecto.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20004 THEN
            DBMS_OUTPUT.PUT_LINE('OK: color incorrecto rechazado.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        END IF;
END;
/

-- CASO 2: Color correcto.
BEGIN
    INSERT INTO CUBRE_ORGANO
        (ID_carta, Tipo, ID_jugada, ID_juego, Color, ID_carta_cubierta)
    VALUES
        (210, 'VIRUS', 22, 1, 'AZUL', 102);

    DBMS_OUTPUT.PUT_LINE('INSERT ejecutado correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20004 THEN
            DBMS_OUTPUT.PUT_LINE('FALLO: rechazo inesperado del color.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Resultado del INSERT: ' || SQLERRM);
        END IF;
END;
/

--------------------------------------------------------------------------------
-- prueba trg_despues_cubre

SELECT id_organo, id_jugador, Organo, Color, puntaje_salud, estado_salud
FROM v_organo_salud
WHERE id_juego = 1
and id_jugador = 1
ORDER BY id_organo;

INSERT INTO JUGADA (ID_juego, ID_jugada, Pasada, ID_jugador)
VALUES (1, 23, 0, 1);

INSERT INTO JUGADA (ID_juego, ID_jugada, Pasada, ID_jugador)
VALUES (1, 24, 0, 1);

INSERT INTO ORGANO_EN_MESA (Organo, ID_carta, Color, ID_jugada, ID_juego)
VALUES ('ESTOMAGO', 212, 'VERDE', 23, 1);

INSERT INTO CUBRE_ORGANO (ID_carta, Tipo, ID_jugada, ID_juego, Color, ID_carta_cubierta)
VALUES (211, 'MEDICINA', 24, 1, 'AMARILLO', 104);

SELECT ID_juego, Estado
FROM JUEGO
WHERE ID_juego = 1;

--------------------------
DELETE FROM CUBRE_ORGANO
WHERE ID_carta = 211
  AND ID_juego = 1;
DELETE FROM ORGANO_EN_MESA
WHERE ID_carta = 212
  AND ID_juego = 1;
DELETE FROM JUGADA
WHERE ID_juego = 1
  AND ID_jugada IN (23, 24);
COMMIT;

--------------------------------------------------------------------------------
-- prueba trg_antes_jugada

BEGIN
    INSERT INTO JUGADA (
        ID_juego,
        ID_jugada,
        Pasada,
        ID_jugador
    )
    VALUES (
        3,
        999,
        0,
        1
    );

    DBMS_OUTPUT.PUT_LINE(
        'ERROR: se permitió insertar una jugada en un juego concluido.'
    );

EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20008 THEN
            DBMS_OUTPUT.PUT_LINE(
                'PRUEBA CORRECTA: el trigger rechazó la jugada.'
            );
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
        ELSE
            RAISE;
        END IF;
END;
/

--------------------------------------------------------------------------------
-- prueba trg_valida_organo_mesa
SET SERVEROUTPUT ON;

SAVEPOINT prueba_valida_organo;

DECLARE
    v_jugada_id JUGADA.ID_jugada%TYPE;
    v_carta_id  ORGANO_EN_MESA.ID_carta%TYPE;
BEGIN
    SELECT MIN(j.ID_jugada)
    INTO v_jugada_id
    FROM JUGADA j
    WHERE j.ID_juego = 1
      AND j.Pasada = 0
      AND NOT EXISTS (
          SELECT 1
          FROM ORGANO_EN_MESA o
          WHERE o.ID_juego = j.ID_juego
            AND o.ID_jugada = j.ID_jugada
      )
      AND NOT EXISTS (
          SELECT 1
          FROM CUBRE_ORGANO c
          WHERE c.ID_juego = j.ID_juego
            AND c.ID_jugada = j.ID_jugada
      );

    IF v_jugada_id IS NULL THEN
        RAISE_APPLICATION_ERROR(
            -20050,
            'No hay jugadas disponibles para la prueba.'
        );
    END IF;

    SELECT NVL(MAX(ID_carta), 0) + 1
    INTO v_carta_id
    FROM ORGANO_EN_MESA;

    INSERT INTO ORGANO_EN_MESA (
        Organo, ID_carta, Color, ID_jugada, ID_juego
    )
    VALUES (
        'ESTOMAGO', v_carta_id, 'VERDE', v_jugada_id, 1
    );

    DBMS_OUTPUT.PUT_LINE(
        'PRUEBA CORRECTA: se aceptó el órgano en la jugada '
        || v_jugada_id
    );

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            'La prueba fue rechazada: ' || SQLERRM
        );
END;
/

ROLLBACK TO prueba_valida_organo;

--------------------------------------------------------------------------------
-- prueba trg_despues_organo
SET SERVEROUTPUT ON;

SAVEPOINT prueba_despues_organo;

DECLARE
    v_jugada_id JUGADA.ID_jugada%TYPE;
    v_carta_id  ORGANO_EN_MESA.ID_carta%TYPE;
    v_estado    JUEGO.Estado%TYPE;
BEGIN
    SELECT MIN(j.ID_jugada)
    INTO v_jugada_id
    FROM JUGADA j
    WHERE j.ID_juego = 1
      AND j.Pasada = 0
      AND NOT EXISTS (
          SELECT 1
          FROM ORGANO_EN_MESA o
          WHERE o.ID_juego = j.ID_juego
            AND o.ID_jugada = j.ID_jugada
      )
      AND NOT EXISTS (
          SELECT 1
          FROM CUBRE_ORGANO c
          WHERE c.ID_juego = j.ID_juego
            AND c.ID_jugada = j.ID_jugada
      );

    IF v_jugada_id IS NULL THEN
        RAISE_APPLICATION_ERROR(
            -20050,
            'No hay jugadas disponibles para la prueba.'
        );
    END IF;

    SELECT NVL(MAX(ID_carta), 0) + 1
    INTO v_carta_id
    FROM ORGANO_EN_MESA;

    INSERT INTO ORGANO_EN_MESA (
        Organo, ID_carta, Color, ID_jugada, ID_juego
    )
    VALUES (
        'ESTOMAGO', v_carta_id, 'VERDE', v_jugada_id, 1
    );

    SELECT Estado
    INTO v_estado
    FROM JUEGO
    WHERE ID_juego = 1;

    DBMS_OUTPUT.PUT_LINE(
        'INSERT correcto: trg_despues_organo terminó sin errores.'
    );

    DBMS_OUTPUT.PUT_LINE(
        'Estado del juego durante la prueba: ' || v_estado
    );

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            'ERROR durante la prueba: ' || SQLERRM
        );
END;
/

ROLLBACK TO prueba_despues_organo;