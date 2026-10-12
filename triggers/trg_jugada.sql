CREATE OR REPLACE TRIGGER trg_generar_id_jugada
BEFORE INSERT ON JUGADA
FOR EACH ROW
DECLARE
    v_max_id NUMBER;
BEGIN
    -- Si el usuario no proporcionó ID_jugada, se calcula
    IF :NEW.ID_jugada IS NULL THEN
        SELECT NVL(MAX(ID_jugada), 0) + 1
          INTO v_max_id
          FROM JUGADA
         WHERE ID_juego = :NEW.ID_juego
           FOR UPDATE;

        :NEW.ID_jugada := v_max_id;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_antes_jugada
BEFORE INSERT ON JUGADA
FOR EACH ROW
BEGIN
    pkg_reglas_del_juego.prc_verificar_juego_en_curso(
        p_juego_id => :NEW.ID_juego
    );
END;
/