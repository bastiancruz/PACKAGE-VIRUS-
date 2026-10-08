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
