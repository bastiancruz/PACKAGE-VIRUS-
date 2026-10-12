
CREATE OR REPLACE TRIGGER trg_despues_cubre
AFTER INSERT ON CUBRE_ORGANO
FOR EACH ROW
BEGIN

    pkg_reglas_del_juego.verificar_victoria(
        p_jugada_id => :NEW.ID_jugada,
        p_juego_id => :NEW.ID_juego
    );

END;
/

CREATE OR REPLACE TRIGGER trg_validar_ataque_cura
BEFORE INSERT ON CUBRE_ORGANO
FOR EACH ROW
FOLLOWS trg_verificar_turno_cubre
DECLARE
    v_jugador_id NUMBER;
BEGIN

    SELECT ID_jugador
    INTO v_jugador_id
    FROM JUGADA
    WHERE ID_juego = :NEW.ID_juego
      AND ID_jugada = :NEW.ID_jugada;

    pkg_reglas_del_juego.prc_validar_ataque_o_cura(
        p_tipo       => :NEW.Tipo,
        p_id_organo  => :NEW.ID_carta_cubierta,
        p_jugador_id => v_jugador_id
    );

END;
/

CREATE OR REPLACE TRIGGER trg_verificar_color
BEFORE INSERT OR UPDATE OF Color, ID_carta_cubierta ON CUBRE_ORGANO
FOR EACH ROW
FOLLOWS trg_validar_ataque_cura
WHEN (NEW.ID_carta_cubierta IS NOT NULL)
DECLARE
    v_color_organo VARCHAR2(30);
BEGIN
    -- Obtener el color del órgano objetivo en la mesa
    SELECT Color
    INTO v_color_organo
    FROM ORGANO_EN_MESA
     WHERE ID_carta = :NEW.ID_carta_cubierta;

    -- Comparar colores directamente
    IF :NEW.Color <> v_color_organo THEN
        RAISE_APPLICATION_ERROR(-20016,
            'Regla de color violada: La carta jugada es ' || :NEW.Color ||
            ' y no coincide con el color del órgano (' || v_color_organo || ').');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20017, 'Error: El órgano objetivo especificado no existe en la mesa.');
END;
/

CREATE OR REPLACE TRIGGER trg_verificar_turno_cubre
BEFORE INSERT ON CUBRE_ORGANO
FOR EACH ROW
DECLARE
    v_pasada NUMBER(1);
    v_total_organos NUMBER;
BEGIN --Primero se ve si la jugada fue una pasada
    SELECT Pasada INTO v_pasada
      FROM JUGADA
     WHERE ID_juego = :NEW.ID_juego 
       AND ID_jugada = :NEW.ID_jugada;

    IF v_pasada = 1 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Error: En una jugada donde se descarto carta no se permite Curar/Atacar.');
    END IF;
--luego se ve si se jugo un organo, si es asi tira error
    SELECT COUNT(*) INTO v_total_organos
      FROM ORGANO_EN_MESA
     WHERE ID_juego = :NEW.ID_juego 
       AND ID_jugada = :NEW.ID_jugada;

    IF v_total_organos > 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Error: Solo se permite jugar UNA carta en total por turno.');
    END IF;
END;
/
