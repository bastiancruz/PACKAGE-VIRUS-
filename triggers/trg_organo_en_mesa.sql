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
BEGIN
    pkg_reglas_del_juego.VALIDAR_TURNO_ORGANO(
        p_id_juego  => :NEW.ID_juego,
        p_id_jugada => :NEW.ID_jugada
    );
END;
/

CREATE OR REPLACE TRIGGER trg_despues_organo
FOR INSERT ON ORGANO_EN_MESA
COMPOUND TRIGGER

    TYPE t_jugada_record IS RECORD (
        id_juego  ORGANO_EN_MESA.ID_juego%TYPE,
        id_jugada ORGANO_EN_MESA.ID_jugada%TYPE
    );

    TYPE t_jugadas IS TABLE OF t_jugada_record
        INDEX BY PLS_INTEGER;

    v_jugadas  t_jugadas;
    v_contador PLS_INTEGER := 0;

    AFTER EACH ROW IS
    BEGIN
        v_contador := v_contador + 1;

        v_jugadas(v_contador).id_juego  := :NEW.ID_juego;
        v_jugadas(v_contador).id_jugada := :NEW.ID_jugada;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        FOR i IN 1 .. v_contador LOOP
            pkg_reglas_del_juego.verificar_victoria(
                p_jugada_id => v_jugadas(i).id_jugada,
                p_juego_id  => v_jugadas(i).id_juego
            );
        END LOOP;
    END AFTER STATEMENT;

END trg_despues_organo;
/