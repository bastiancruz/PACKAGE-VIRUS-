
-- ============================================================
-- SEEDS: JUGADAS DEL JUEGO 1
-- ============================================================

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (1, 1, 0, 1);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (2, 1, 0, 2);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (3, 1, 0, 3);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (4, 1, 0, 1);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (5, 1, 0, 2);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (6, 1, 0, 3);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (7, 1, 0, 1);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (8, 1, 0, 2);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (9, 1, 0, 3);

-- Turnos para jugar virus y medicina
INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (10, 1, 0, 1);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (11, 1, 0, 2);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (12, 1, 0, 3);

-- Jugadas pasadas
INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (13, 1, 1, 1);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (14, 1, 0, 2);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (15, 1, 0, 3);

INSERT INTO JUGADA (ID_jugada, ID_juego, Pasada, ID_jugador)
VALUES (16, 1, 0, 1);


-- ============================================================
-- SEEDS: ORGANOS EN MESA
-- ============================================================

-- Jugador 1
INSERT INTO ORGANO_EN_MESA
    (ID_carta, Organo, Color, ID_jugada, ID_juego)
VALUES
    (101, 'CORAZON', 'ROJO', 1, 1);

INSERT INTO ORGANO_EN_MESA
    (ID_carta, Organo, Color, ID_jugada, ID_juego)
VALUES
    (104, 'HUESO', 'AMARILLO', 4, 1);

INSERT INTO ORGANO_EN_MESA
    (ID_carta, Organo, Color, ID_jugada, ID_juego)
VALUES
    (107, 'CEREBRO', 'AZUL', 7, 1);


-- Jugador 2
INSERT INTO ORGANO_EN_MESA
    (ID_carta, Organo, Color, ID_jugada, ID_juego)
VALUES
    (102, 'CEREBRO', 'AZUL', 2, 1);

INSERT INTO ORGANO_EN_MESA
    (ID_carta, Organo, Color, ID_jugada, ID_juego)
VALUES
    (105, 'CORAZON', 'AMARILLO', 5, 1);

INSERT INTO ORGANO_EN_MESA
    (ID_carta, Organo, Color, ID_jugada, ID_juego)
VALUES
    (108, 'ESTOMAGO', 'VERDE', 8, 1);


-- Jugador 3
INSERT INTO ORGANO_EN_MESA
    (ID_carta, Organo, Color, ID_jugada, ID_juego)
VALUES
    (103, 'ESTOMAGO', 'VERDE', 3, 1);

INSERT INTO ORGANO_EN_MESA
    (ID_carta, Organo, Color, ID_jugada, ID_juego)
VALUES
    (106, 'CEREBRO', 'ROJO', 6, 1);

INSERT INTO ORGANO_EN_MESA
    (ID_carta, Organo, Color, ID_jugada, ID_juego)
VALUES
    (109, 'HUESO', 'AZUL', 9, 1);


-- ============================================================
-- SEEDS: VIRUS Y MEDICINAS
-- ============================================================

-- Jugador 1 ataca el cerebro azul del jugador 2
INSERT INTO CUBRE_ORGANO
    (ID_carta, Tipo, ID_jugada, ID_juego, Color, ID_carta_cubierta)
VALUES
    (201, 'VIRUS', 10, 1, 'AZUL', 102);

-- Jugador 2 cura su propio cerebro azul
INSERT INTO CUBRE_ORGANO
    (ID_carta, Tipo, ID_jugada, ID_juego, Color, ID_carta_cubierta)
VALUES
    (202, 'MEDICINA', 11, 1, 'AZUL', 102);

-- Jugador 3 ataca el hueso amarillo del jugador 1
INSERT INTO CUBRE_ORGANO
    (ID_carta, Tipo, ID_jugada, ID_juego, Color, ID_carta_cubierta)
VALUES
    (203, 'VIRUS', 12, 1, 'AMARILLO', 104);

COMMIT;
