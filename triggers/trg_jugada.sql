CREATE OR REPLACE TRIGGER trg_antes_jugada
BEFORE INSERT ON JUGADA
FOR EACH ROW
BEGIN
    pkg_reglas_del_juego.prc_verificar_juego_en_curso(
        p_juego_id => :NEW.ID_juego
    );
END;
/