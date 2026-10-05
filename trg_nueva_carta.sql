CREATE OR REPLACE TRIGGER trg_antes_jugada
BEFORE INSERT ON JUGADA
FOR EACH ROW
BEGIN
    pkg_virus_game.prc_verificar_juego_en_curso(
        p_juego_id => :NEW.ID_juego
    );
END;
/

CREATE OR REPLACE TRIGGER trg_despues_organo
AFTER INSERT ON ORGANO_EN_MESA
FOR EACH ROW
BEGIN

    pkg_virus_game.verificar_victoria(
        p_jugada_id => :NEW.ID_jugada,
        p_juego_id => :NEW.ID_juego
    );

END;
/

CREATE OR REPLACE TRIGGER trg_despues_cubre
AFTER INSERT ON CUBRE_ORGANO
FOR EACH ROW
BEGIN

    pkg_virus_game.verificar_victoria(
        p_jugada_id => :NEW.ID_jugada,
        p_juego_id => :NEW.ID_juego
    );

END;
/

CREATE OR REPLACE TRIGGER trg_validar_ataque_cura
BEFORE INSERT ON CUBRE_ORGANO
FOR EACH ROW
DECLARE
    v_jugador_id NUMBER;
BEGIN

    SELECT ID_jugador
    INTO v_jugador_id
    FROM JUGADA
    WHERE ID_juego = :NEW.ID_juego
      AND ID_jugada = :NEW.ID_jugada;

    pkg_virus_game.prc_validar_ataque_o_cura(
        p_tipo       => :NEW.Tipo,
        p_id_organo  => :NEW.ID_carta_cubierta,
        p_jugador_id => v_jugador_id
    );

END;
/