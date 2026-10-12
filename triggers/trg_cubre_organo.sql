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

CREATE OR REPLACE TRIGGER trg_verificar_turno_cubre
BEFORE INSERT ON CUBRE_ORGANO
FOR EACH ROW
BEGIN
    pkg_reglas_del_juego.VALIDAR_TURNO_CUBRE(
        p_id_juego  => :NEW.ID_juego,
        p_id_jugada => :NEW.ID_jugada
    );
END;
/

CREATE OR REPLACE TRIGGER trg_verificar_color
BEFORE INSERT OR UPDATE OF Color, ID_carta_cubierta
ON CUBRE_ORGANO
FOR EACH ROW
BEGIN
    pkg_reglas_del_juego.VALIDAR_COLOR_ORGANO(
        p_color_carta => :NEW.Color,
        p_id_carta    => :NEW.ID_carta_cubierta
    );
END;