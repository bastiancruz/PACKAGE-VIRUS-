-- Trigger: Valida al insertar un nuevo organo a la mesa
CREATE OR REPLACE TRIGGER trg_valida_organo_mesa
BEFORE INSERT ON organo_en_mesa
FOR EACH ROW
FOLLOWS VERIFICAR_TURNO_ORGANO
BEGIN
    pkg_reglas_organo.valida_nuevo_organo(
        p_juego_id  => :NEW.ID_juego,
        p_jugada_id => :NEW.ID_jugada,
        p_organo => :NEW.organo,
        p_color => :NEW.color
    );
END;