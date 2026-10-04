-- ============================================================
-- PAQUETE: ESPECIFICACION
-- ============================================================
CREATE OR REPLACE PACKAGE pkg_virus_game AS
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
END pkg_virus_game;
/

-- ============================================================
-- PAQUETE: CUERPO
-- ============================================================
CREATE OR REPLACE PACKAGE BODY pkg_virus_game AS

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
        v_jugador_cubridor NUMBER;
        v_dueno_organo     NUMBER;
    BEGIN

        -- 1. Obtener la salud actual del organo objetivo
        SELECT NVL(puntaje_salud, 0) 
        INTO v_puntaje_actual
        FROM v_organo_salud
        WHERE ID_organo = p_organo_id;

        -- 2. Restriccion: Organo inmune (+2) no puede recibir virus
        IF v_puntaje_actual = 2 AND UPPER(p_tipo_cubre) = 'VIRUS' THEN
            RAISE_APPLICATION_ERROR(-20003, 'Error: El organo esta INMUNE (+2) y no puede ser atacado.');
        END IF;

        -- 3. Identificar quién está haciendo la jugada y de quién es el órgano
        SELECT ID_jugador INTO v_jugador_cubridor
        FROM jugada
        WHERE ID_juego = p_juego_id AND ID_jugada = p_jugada_id;

        SELECT id_jugador INTO v_dueno_organo
        FROM v_organo_salud
        WHERE id_organo = p_organo_id;
        
        -- 4. Restricciones de Ataque y Cura cruzada
        IF UPPER(p_tipo_cubre) = 'VIRUS' AND v_jugador_cubridor = v_dueno_organo THEN
            RAISE_APPLICATION_ERROR(-20005, 'Jugada inválida: No puedes jugar un virus sobre tus propios órganos.');
        END IF;

        IF UPPER(p_tipo_cubre) = 'MEDICINA' AND v_jugador_cubridor != v_dueno_organo THEN
            RAISE_APPLICATION_ERROR(-20006, 'Jugada inválida: Solo puedes aplicar medicinas sobre tus propios órganos.');
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

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20004, 'Error: El organo o la jugada no existen.');
    END aplicar_cobertura;

END pkg_virus_game;


-- Trigger 1: Valida al insertar un nuevo organo a la mesa
CREATE OR REPLACE TRIGGER trg_valida_organo_mesa
BEFORE INSERT ON organo_en_mesa
FOR EACH ROW
BEGIN
    pkg_virus_game.valida_nuevo_organo(
        p_juego_id  => :NEW.ID_juego,
        p_jugada_id => :NEW.ID_jugada,
        p_organo => :NEW.organo,
        p_color => :NEW.color
    );
END;

--Vista utilizada

CREATE OR REPLACE VIEW v_organo_salud AS 
SELECT 
    o.id_carta AS id_organo, 
    o.id_juego, 
    o.id_jugada, 
    j.id_jugador,
    o.organo, 
    o.color, 

    -- Calculo del puntaje numerico de salud 
    NVL(SUM( 
        CASE 
            WHEN co.tipo = 'MEDICINA' THEN 1 
            WHEN co.tipo = 'VIRUS' THEN -1 
            ELSE 0 
        END 
    ), 0) AS puntaje_salud, 

    -- Traduccion del puntaje numerico a estado en texto 
    CASE NVL(SUM( 
            CASE 
                WHEN co.tipo = 'MEDICINA' THEN 1 
                WHEN co.tipo = 'VIRUS' THEN -1 
                ELSE 0 
            END 
        ), 0) 
        WHEN 2 THEN 'inmunizado' 
        WHEN 1 THEN 'vacunado' 
        WHEN 0 THEN 'sano' 
        WHEN -1 THEN 'infectado' 
        WHEN -2 THEN 'extirpado' 
        ELSE 'desconocido' 
    END AS estado_salud 

FROM organo_en_mesa o 
JOIN jugada j ON o.id_juego = j.id_juego AND o.id_jugada = j.id_jugada 
LEFT JOIN cubre_organo co ON o.id_carta = co.id_carta_cubierta
GROUP BY 
    o.id_carta, 
    o.id_juego, 
    o.id_jugada, 
    j.id_jugador, 
    o.organo, 
    o.color;


--BLOQUE 'INSERT' CUBRE_ORGANO -- FUNCIONAAAA
BEGIN
    pkg_virus_game.aplicar_cobertura(
        p_tipo_cubre       => 'MEDICINA',
        p_cubre_carta_id      => 1,
        p_jugada_id      => 4,  
        p_juego_id => 1,       
        p_color     => 'AZUL' ,
        p_organo_id => 2
    );
    COMMIT; 
END;