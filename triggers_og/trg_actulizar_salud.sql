create or replace trigger trg_actualizar_salud
before insert on cubre_organo
for each row
declare
    v_organo organo_en_mesa;
    organo_muerto exception;
begin
    if :NEW.salud < 2  or :NEW.salud > -2 then
        if :NEW.tipo = 'VIRUS' then
            :NEW.salud := :NEW.salud -1;
        elsif :NEW.tipo = 'MEDICINA' then
            :NEW.salud := :NEW.salud +1;
        end if;
    else
        raise organo_muerto;
    end if;
exception
    when organo_muerto then
        RAISE_APPLICATION_ERROR(-20020, 'Organo ya muerto. No puede curarlo ni infectarlo');
end;
