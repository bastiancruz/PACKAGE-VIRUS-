-- ============================================================
-- PAQUETE: ESPECIFICACION
-- ============================================================
CREATE OR REPLACE PACKAGE pkg_reglas_organo AS
    PROCEDURE valida_nuevo_organo (
        p_juego_id  IN NUMBER,
        p_jugada_id IN NUMBER,
        p_organo    IN VARCHAR2,
        p_color     IN VARCHAR2
    );

    PROCEDURE aplicar_cobertura (
        p_tipo_cubre IN VARCHAR2,
        p_cubre_carta_id IN NUMBER,
        p_jugada_id IN NUMBER,
        p_juego_id IN NUMBER,
        p_color IN VARCHAR2,
        p_organo_id  IN NUMBER
    );
END pkg_reglas_organo;
/

-- ============================================================
-- PAQUETE: CUERPO
-- ============================================================
CREATE OR REPLACE PACKAGE BODY pkg_reglas_organo AS

    ------------------------------------------------------------
    -- VALIDA COLOCACION DE NUEVO ORGANO (Puntos 4 y 5)
    ------------------------------------------------------------

    PROCEDURE valida_nuevo_organo (
        p_juego_id  IN NUMBER,
        p_jugada_id IN NUMBER,
        p_organo    IN VARCHAR2,
        p_color     IN VARCHAR2
    ) IS
        v_jugador_id NUMBER;
        v_cant_tipo  NUMBER := 0;
        v_cant_color NUMBER := 0;
    BEGIN
        -- 1. Obtener el ID del jugador dueño de la jugada
        SELECT id_jugador
        INTO v_jugador_id
        FROM jugada
        WHERE id_juego = p_juego_id
          AND id_jugada = p_jugada_id;

        -- 2. Consulta la vista para verificar organos 'vivos' usando el v_jugador_id
        SELECT COUNT(*)
        INTO v_cant_tipo
        FROM v_organo_salud
        WHERE ID_jugador = v_jugador_id
          AND UPPER(organo) = UPPER(p_organo)
          AND puntaje_salud > -2;

        IF v_cant_tipo > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Error: Ya tienes un organo de tipo "' || p_organo || '" en tu mesa.');
        END IF;

        SELECT COUNT(*)
        INTO v_cant_color
        FROM v_organo_salud
        WHERE ID_jugador = v_jugador_id
          AND UPPER(color) = UPPER(p_color)
          AND puntaje_salud > -2;

        IF v_cant_color > 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Error: Ya tienes un organo de color "' || p_color || '" en tu mesa.');
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20007, 'Error: La jugada especificada no existe.');
    END valida_nuevo_organo;

    ------------------------------------------------------------
    -- APLICA COBERTURA A ORGANO
    ------------------------------------------------------------
    PROCEDURE aplicar_cobertura (
        p_tipo_cubre IN VARCHAR2,
        p_cubre_carta_id IN NUMBER,
        p_jugada_id IN NUMBER,
        p_juego_id IN NUMBER,
        p_color IN VARCHAR2,
        p_organo_id  IN NUMBER
    ) IS
        v_puntaje_actual   NUMBER := 0;
        v_carta_remover    NUMBER;
        v_color_organo     VARCHAR2(30);
        v_juego_organo     NUMBER;
    BEGIN
         -- 1. Validar tipo de carta
        IF UPPER(p_tipo_cubre) NOT IN ('VIRUS', 'MEDICINA') THEN
            RAISE_APPLICATION_ERROR(-20019, 'Tipo de carta inválido: ' || p_tipo_cubre);
        END IF;

        -- 2. Obtener salud, color y juego del órgano objetivo
        SELECT NVL(puntaje_salud, 0), Color, id_juego
        INTO v_puntaje_actual, v_color_organo, v_juego_organo
        FROM v_organo_salud
        WHERE ID_organo = p_organo_id;

        -- 3. Validar que el órgano pertenece al juego indicado
        IF v_juego_organo <> p_juego_id THEN
            RAISE_APPLICATION_ERROR(-20021,
                'El órgano ' || p_organo_id || 
                ' no pertenece al juego ' || p_juego_id);
        END IF;

        -- 4. Validar color (aplica a TODAS las cartas, vinculadas o descartadas)
        IF UPPER(p_color) <> UPPER(v_color_organo) THEN
            RAISE_APPLICATION_ERROR(-20013,
                'Regla de color violada: la carta es ' || p_color ||
                ' pero el órgano es ' || v_color_organo);
        END IF;

        -- 5. Restriccion: Organo inmune (+2) no puede recibir virus
        IF v_puntaje_actual = 2 AND UPPER(p_tipo_cubre) = 'VIRUS' THEN
            RAISE_APPLICATION_ERROR(-20003, 'Error: El organo esta INMUNE (+2) y no puede ser atacado.');
        END IF;

        -- . Restricción: órgano inmune no puede recibir más medicinas
        IF v_puntaje_actual = 2 AND UPPER(p_tipo_cubre) = 'MEDICINA' THEN
            RAISE_APPLICATION_ERROR(-20020,
                'El órgano ya está INMUNE (+2). No puedes aplicar más medicinas.');
        END IF;

        --------------------------------------------------------
        -- CASO A: SE JUEGA UN VIRUS (-1)
        --------------------------------------------------------
        IF UPPER(p_tipo_cubre) = 'VIRUS' THEN
            IF v_puntaje_actual = 1 THEN
                -- Neutraliza medicina vieja
                SELECT id_carta INTO v_carta_remover
                FROM cubre_organo
                WHERE ID_carta_cubierta = p_organo_id AND UPPER(tipo) = 'MEDICINA' AND ROWNUM = 1;

                UPDATE cubre_organo SET id_carta_cubierta = NULL WHERE id_carta = v_carta_remover;

                -- Inserta virus nuevo descartado (NULL)
                INSERT INTO cubre_organo (tipo, ID_carta, ID_jugada, ID_juego, color, ID_carta_cubierta)
                VALUES (UPPER(p_tipo_cubre), p_cubre_carta_id, p_jugada_id, p_juego_id, UPPER(p_color), NULL);

            ELSIF v_puntaje_actual = 0 THEN
                -- Inserta virus vinculado al organo
                INSERT INTO cubre_organo (tipo, ID_carta, ID_jugada, ID_juego, color, ID_carta_cubierta)
                VALUES (UPPER(p_tipo_cubre), p_cubre_carta_id, p_jugada_id, p_juego_id, UPPER(p_color), p_organo_id);

            ELSIF v_puntaje_actual = -1 THEN
                -- Desvincula primer virus viejo
                UPDATE cubre_organo SET id_carta_cubierta = NULL WHERE id_carta_cubierta = p_organo_id;

                -- Inserta virus nuevo descartado (NULL)
                INSERT INTO cubre_organo (tipo, ID_carta, ID_jugada, ID_juego, color, ID_carta_cubierta)
                VALUES (UPPER(p_tipo_cubre), p_cubre_carta_id, p_jugada_id, p_juego_id, UPPER(p_color), NULL);

                -- Elimina el organo muerto
                DELETE FROM organo_en_mesa WHERE id_carta = p_organo_id;
            END IF;

        --------------------------------------------------------
        -- CASO B: SE JUEGA UNA MEDICINA / CURA (+1)
        --------------------------------------------------------
        ELSIF UPPER(p_tipo_cubre) = 'MEDICINA' THEN
            IF v_puntaje_actual = -1 THEN
                -- Neutraliza virus viejo
                SELECT id_carta INTO v_carta_remover
                FROM cubre_organo
                WHERE id_carta_cubierta = p_organo_id AND UPPER(tipo) = 'VIRUS' AND ROWNUM = 1;

                UPDATE cubre_organo SET id_carta_cubierta = NULL WHERE id_carta = v_carta_remover;

                -- Inserta medicina nueva descartada (NULL)
                INSERT INTO cubre_organo (tipo, ID_carta, ID_jugada, ID_juego, color, ID_carta_cubierta)
                VALUES (UPPER(p_tipo_cubre), p_cubre_carta_id, p_jugada_id, p_juego_id, UPPER(p_color), NULL);

            ELSIF v_puntaje_actual IN (0, 1) THEN
                -- Inserta medicina vinculada al organo
                INSERT INTO cubre_organo (tipo, ID_carta, ID_jugada, ID_juego, color, ID_carta_cubierta)
                VALUES (UPPER(p_tipo_cubre),p_cubre_carta_id, p_jugada_id, p_juego_id, UPPER(p_color), p_organo_id);
            END IF;
        END IF;

        --3. Restriccion de organo muerto o extirpado
        IF v_puntaje_actual <= -2 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Error: El organo ya se encuentra EXTIRPADO, por lo que no se le puede atacar ni cubrir.');
        END IF;

        INSERT INTO cubre_organo (tipo, ID_carta, ID_jugada, ID_juego, color, ID_carta_cubierta)
        VALUES (UPPER(p_tipo_cubre), p_cubre_carta_id, p_jugada_id, p_juego_id, UPPER(p_color), p_organo_id);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20004, 'Error: El organo o la jugada no existen.');
    END aplicar_cobertura;

END pkg_reglas_organo;
