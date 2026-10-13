-- ============================================================
-- PAQUETE: ESPECIFICACION
-- ============================================================
CREATE OR REPLACE PACKAGE pkg_reglas_del_juego AS

    PROCEDURE verificar_victoria (
        p_juego_id   IN NUMBER,
        p_jugada_id  IN NUMBER
    );

    PROCEDURE prc_verificar_juego_en_curso (
        p_juego_id IN NUMBER
    );

    PROCEDURE prc_validar_ataque_o_cura (
        p_tipo       IN VARCHAR2,
        p_id_organo  IN NUMBER,
        p_jugador_id IN NUMBER
    );

    PROCEDURE VALIDAR_COLOR_ORGANO (
        p_color_carta   IN CUBRE_ORGANO.Color%TYPE,
        p_id_carta      IN CUBRE_ORGANO.ID_carta_cubierta%TYPE
    );

    PROCEDURE validar_turno_cubre (
        p_id_juego  IN CUBRE_ORGANO.ID_juego%TYPE,
        p_id_jugada IN CUBRE_ORGANO.ID_jugada%TYPE
    );

    PROCEDURE validar_turno_organo (
        p_id_juego  IN ORGANO_EN_MESA.ID_juego%TYPE,
        p_id_jugada IN ORGANO_EN_MESA.ID_jugada%TYPE
    );
END pkg_reglas_del_juego;
/

-- ============================================================
-- PAQUETE: CUERPO
-- ============================================================
CREATE OR REPLACE PACKAGE BODY pkg_reglas_del_juego AS

    /*------------------------------------------------------------
      VERIFICA SI EL JUGADOR GANÓ
      Un jugador gana cuando tiene 4 órganos con salud >= 0
    ------------------------------------------------------------*/
    PROCEDURE verificar_victoria (
        p_juego_id  IN NUMBER,
        p_jugada_id IN NUMBER
    ) IS
        v_cant_organos NUMBER;
        v_jugador_id   NUMBER;
    BEGIN

        SELECT ID_jugador
        INTO v_jugador_id
        FROM JUGADA
        WHERE ID_juego = p_juego_id
        AND ID_jugada = p_jugada_id;

        SELECT COUNT(*)
        INTO v_cant_organos
        FROM v_organo_salud
        WHERE ID_jugador = v_jugador_id
            AND puntaje_salud >= 0;

        IF v_cant_organos = 4 THEN
            UPDATE JUEGO
            SET Estado = 'CONCLUIDO'
            WHERE ID_juego = p_juego_id;
        END IF;

    END verificar_victoria;

    /*------------------------------------------------------------
      VERIFICA QUE EL JUEGO SIGA EN CURSO
    ------------------------------------------------------------*/
    PROCEDURE prc_verificar_juego_en_curso (
        p_juego_id IN NUMBER
    ) IS
        v_estado VARCHAR2(20);
    BEGIN
        SELECT Estado
        INTO v_estado
        FROM JUEGO
        WHERE ID_juego = p_juego_id;
        IF v_estado = 'CONCLUIDO' THEN
            RAISE_APPLICATION_ERROR(
                -20008,
                'Juego ya terminado, no se permiten más jugadas.'
            );
        END IF;
    END prc_verificar_juego_en_curso;


    /*------------------------------------------------------------
      VALIDA VIRUS Y MEDICINA
    ------------------------------------------------------------*/
    PROCEDURE prc_validar_ataque_o_cura (
        p_tipo         IN VARCHAR2,
        p_id_organo    IN NUMBER,
        p_jugador_id   IN NUMBER
    ) IS
        v_jugador_dueno NUMBER;
    BEGIN

        SELECT j.ID_jugador
        INTO v_jugador_dueno
        FROM ORGANO_EN_MESA o
        JOIN JUGADA j
        ON o.ID_juego = j.ID_juego
        AND o.ID_jugada = j.ID_jugada
        WHERE o.ID_carta = p_id_organo;
        IF p_tipo = 'VIRUS' THEN
            IF p_jugador_id = v_jugador_dueno THEN
                RAISE_APPLICATION_ERROR(
                    -20009,
                    'No puedes infectar tus propios órganos.'
                );
            END IF;
        ELSIF p_tipo = 'MEDICINA' THEN
            IF p_jugador_id != v_jugador_dueno THEN
                RAISE_APPLICATION_ERROR(
                    -20010,
                    'No puedes curar órganos ajenos.'
                );
            END IF;
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20015, 'El órgano especificado no existe en mesa.');

    END prc_validar_ataque_o_cura;

    PROCEDURE VALIDAR_COLOR_ORGANO (
        p_color_carta   IN CUBRE_ORGANO.Color%TYPE,
        p_id_carta      IN CUBRE_ORGANO.ID_carta_cubierta%TYPE
    )
    AS
        v_color_organo ORGANO_EN_MESA.Color%TYPE;
    BEGIN
        -- Obtener el color del órgano objetivo en la mesa
        SELECT Color
        INTO v_color_organo
        FROM ORGANO_EN_MESA
        WHERE ID_carta = p_id_carta;

        -- Comparar los colores
        IF p_color_carta <> v_color_organo THEN
            RAISE_APPLICATION_ERROR(
                -20004,
                'Regla de color violada: La carta jugada es '
                || p_color_carta
                || ' y no coincide con el color del órgano ('
                || v_color_organo || ').'
            );
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20005,
                'Error: El órgano objetivo especificado no existe en la mesa.'
            );
    END;


    PROCEDURE VALIDAR_TURNO_CUBRE (
        p_id_juego  IN CUBRE_ORGANO.ID_juego%TYPE,
        p_id_jugada IN CUBRE_ORGANO.ID_jugada%TYPE
    )
    AS
        v_pasada        JUGADA.Pasada%TYPE;
        v_total_organos NUMBER;
    BEGIN
        -- Primero se comprueba si la jugada fue una pasada
        SELECT Pasada
        INTO v_pasada
        FROM JUGADA
        WHERE ID_juego = p_id_juego
        AND ID_jugada = p_id_jugada;

        IF v_pasada = 1 THEN
            RAISE_APPLICATION_ERROR(
                -20011,
                'Error: En una jugada donde se descarto carta no se permite Curar/Atacar.'
            );
        END IF;

        -- Se comprueba si ya se jugó un órgano en ese turno
        SELECT COUNT(*)
        INTO v_total_organos
        FROM ORGANO_EN_MESA
        WHERE ID_juego = p_id_juego
        AND ID_jugada = p_id_jugada;

        IF v_total_organos > 0 THEN
            RAISE_APPLICATION_ERROR(
                -20012,
                'Error: Solo se permite jugar UNA carta en total por turno.'
            );
        END IF;
    END;


    PROCEDURE VALIDAR_TURNO_ORGANO (
        p_id_juego  IN ORGANO_EN_MESA.ID_juego%TYPE,
        p_id_jugada IN ORGANO_EN_MESA.ID_jugada%TYPE
    )
    AS
        v_pasada           JUGADA.Pasada%TYPE;
        v_total_cubiertas  NUMBER;
    BEGIN
        -- Primero se comprueba si la jugada fue una pasada
        SELECT Pasada
        INTO v_pasada
        FROM JUGADA
        WHERE ID_juego = p_id_juego
        AND ID_jugada = p_id_jugada;

        IF v_pasada = 1 THEN
            RAISE_APPLICATION_ERROR(
                -20011,
                'Error: En una jugada donde se descarto carta no se permite jugar órganos a la mesa.'
            );
        END IF;

        -- Se comprueba si ya se jugó un virus o una cura
        SELECT COUNT(*)
        INTO v_total_cubiertas
        FROM CUBRE_ORGANO
        WHERE ID_juego = p_id_juego
        AND ID_jugada = p_id_jugada;

        IF v_total_cubiertas > 0 THEN
            RAISE_APPLICATION_ERROR(
                -20012,
                'Error: Solo se permite jugar UNA carta en total por turno.'
            );
        END IF;
    END;

END pkg_reglas_del_juego;
/

