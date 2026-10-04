--Vista utilizada

CREATE OR REPLACE VIEW v_organo_salud AS 
SELECT 
    o.id_carta AS id_organo, 
    o.id_juego, 
    o.id_jugada, 
    j.id_jugador,
    o.Organo, 
    o.Color, 

    -- Calculo del puntaje numerico de salud 
    NVL(SUM( 
        CASE 
            WHEN co.Tipo = 'MEDICINA' THEN 1 
            WHEN co.Tipo = 'VIRUS' THEN -1 
            ELSE 0 
        END 
    ), 0) AS puntaje_salud, 

    -- Traduccion del puntaje numerico a estado en texto 
    CASE NVL(SUM( 
            CASE 
                WHEN co.Tipo = 'MEDICINA' THEN 1 
                WHEN co.Tipo = 'VIRUS' THEN -1 
                ELSE 0 
            END 
        ), 0) 
        WHEN 2 THEN 'inmunizado' 
        WHEN 1 THEN 'vacunado' 
        WHEN 0 THEN 'sano' 
        WHEN -1 THEN 'infectado' 
        WHEN -2 THEN 'extirpado' 
        ELSE 'desconocido' 
    END AS estado_salud 

FROM organo_en_mesa o 
JOIN jugada j ON o.id_juego = j.id_juego AND o.id_jugada = j.id_jugada 
LEFT JOIN cubre_organo co ON o.id_carta = co.id_carta_cubierta
GROUP BY 
    o.id_carta, 
    o.id_juego, 
    o.id_jugada, 
    j.id_jugador, 
    o.Organo, 
    o.Color;