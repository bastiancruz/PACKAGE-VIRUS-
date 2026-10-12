
-- Ta mal, se lo pedí a chatgpt mientras xd pero está mal
-- NO USAR
-- =========================================
-- 4. JUGADAS
-- =========================================

-- Juego 1
INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (1, 1, 0, 1);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (2, 1, 0, 2);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (3, 1, 1, 3);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (4, 1, 0, 1);

-- Juego 2
INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (1, 2, 0, 2);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (2, 2, 0, 4);

-- Juego 3
INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (1, 3, 0, 1);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (2, 3, 0, 4);


-- =========================================
-- 5. ORGANOS EN MESA
-- =========================================

-- Juego 1: órganos colocados durante distintas jugadas
INSERT INTO ORGANO_EN_MESA
(Organo, ID_carta, Color, ID_jugada, ID_juego)
VALUES ('CORAZON', 101, 'ROJO', 1, 1);

INSERT INTO ORGANO_EN_MESA
(Organo, ID_carta, Color, ID_jugada, ID_juego)
VALUES ('CEREBRO', 102, 'AZUL', 2, 1);

INSERT INTO ORGANO_EN_MESA
(Organo, ID_carta, Color, ID_jugada, ID_juego)
VALUES ('HUESO', 103, 'AMARILLO', 3, 1);

INSERT INTO ORGANO_EN_MESA
(Organo, ID_carta, Color, ID_jugada, ID_juego)
VALUES ('ESTOMAGO', 104, 'VERDE', 4, 1);

-- Juego 2
INSERT INTO ORGANO_EN_MESA
(Organo, ID_carta, Color, ID_jugada, ID_juego)
VALUES ('CORAZON', 201, 'ROJO', 1, 2);

INSERT INTO ORGANO_EN_MESA
(Organo, ID_carta, Color, ID_jugada, ID_juego)
VALUES ('CEREBRO', 202, 'VERDE', 2, 2);

-- Juego 3
INSERT INTO ORGANO_EN_MESA
(Organo, ID_carta, Color, ID_jugada, ID_juego)
VALUES ('HUESO', 301, 'AZUL', 1, 3);

INSERT INTO ORGANO_EN_MESA
(Organo, ID_carta, Color, ID_jugada, ID_juego)
VALUES ('ESTOMAGO', 302, 'AMARILLO', 2, 3);


-- =========================================
-- 6. VIRUS Y MEDICINAS
-- =========================================

-- Juego 1: virus sobre órganos
INSERT INTO CUBRE_ORGANO
(Tipo, ID_carta, ID_jugada, ID_juego, Color, ID_carta_cubierta)
VALUES ('VIRUS', 401, 2, 1, 'ROJO', 101);

INSERT INTO CUBRE_ORGANO
(Tipo, ID_carta, ID_jugada, ID_juego, Color, ID_carta_cubierta)
VALUES ('VIRUS', 402, 3, 1, 'AZUL', 102);

-- Juego 1: medicina sobre órgano
INSERT INTO CUBRE_ORGANO
(Tipo, ID_carta, ID_jugada, ID_juego, Color, ID_carta_cubierta)
VALUES ('MEDICINA', 403, 4, 1, 'ROJO', 101);

-- Juego 2
INSERT INTO CUBRE_ORGANO
(Tipo, ID_carta, ID_jugada, ID_juego, Color, ID_carta_cubierta)
VALUES ('MEDICINA', 404, 2, 2, 'VERDE', 201);

-- Juego 3
INSERT INTO CUBRE_ORGANO
(Tipo, ID_carta, ID_jugada, ID_juego, Color, ID_carta_cubierta)
VALUES ('VIRUS', 405, 2, 3, 'AMARILLO', 301);


COMMIT;