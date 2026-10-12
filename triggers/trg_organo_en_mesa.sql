CREATE OR REPLACE TRIGGER trg_despues_organo
AFTER INSERT ON ORGANO_EN_MESA
FOR EACH ROW
BEGIN

    pkg_reglas_del_juego.verificar_victoria(
        p_jugada_id => :NEW.ID_jugada,
        p_juego_id => :NEW.ID_juego
    );

END;
/

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
/

CREATE OR REPLACE TRIGGER VERIFICAR_TURNO_ORGANO
BEFORE INSERT ON ORGANO_EN_MESA
FOR EACH ROW
DECLARE
    v_pasada NUMBER(1);
    v_total_cubiertas NUMBER;
BEGIN--Primero se ve si la jugada fue una pasada
    SELECT Pasada INTO v_pasada
      FROM JUGADA
     WHERE ID_juego = :NEW.ID_juego 
       AND ID_jugada = :NEW.ID_jugada;

    IF v_pasada = 1 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Error: En una jugada donde se descarto carta no se permite jugar órganos a la mesa.');
    END IF;

--luego se ve si se jugo un virus/cura, si es asi tira error
    SELECT COUNT(*) INTO v_total_cubiertas
      FROM CUBRE_ORGANO
     WHERE ID_juego = :NEW.ID_juego 
       AND ID_jugada = :NEW.ID_jugada;

    IF v_total_cubiertas > 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Error: Solo se permite jugar UNA carta en total por turno.');
    END IF;
END;
/
