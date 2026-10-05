-- ============================================================
-- PAQUETE: ESPECIFICACION
-- ============================================================
CREATE OR REPLACE PACKAGE pkg_virus_game AS

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
END pkg_virus_game;
/

-- ============================================================
-- PAQUETE: CUERPO
-- ============================================================
CREATE OR REPLACE PACKAGE BODY pkg_virus_game AS

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
    END;
END pkg_virus_game;
/