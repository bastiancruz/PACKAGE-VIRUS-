-- =========================================
-- 1. JUGADORES
-- =========================================

INSERT INTO JUGADOR (ID_jugador, Nombre) VALUES (1, 'Ana');
INSERT INTO JUGADOR (ID_jugador, Nombre) VALUES (2, 'Pedro');
INSERT INTO JUGADOR (ID_jugador, Nombre) VALUES (3, 'Camila');
INSERT INTO JUGADOR (ID_jugador, Nombre) VALUES (4, 'Diego');
INSERT INTO JUGADOR (ID_jugador, Nombre) VALUES (5, 'Sofia');


-- =========================================
-- 2. JUEGOS
-- =========================================

INSERT INTO JUEGO (ID_juego, Fecha_creacion, Estado)
VALUES (1, TIMESTAMP '2026-10-10 15:00:00', 'EN CURSO');

INSERT INTO JUEGO (ID_juego, Fecha_creacion, Estado)
VALUES (2, TIMESTAMP '2026-10-11 18:30:00', 'PLANIFICADO');

INSERT INTO JUEGO (ID_juego, Fecha_creacion, Estado)
VALUES (3, TIMESTAMP '2026-10-09 12:00:00', 'CONCLUIDO');


-- =========================================
-- 3. JUGADORES PARTICIPANTES
-- =========================================

-- Juego 1
INSERT INTO JUGAR (ID_jugador, ID_juego) VALUES (1, 1);
INSERT INTO JUGAR (ID_jugador, ID_juego) VALUES (2, 1);
INSERT INTO JUGAR (ID_jugador, ID_juego) VALUES (3, 1);

-- Juego 2
INSERT INTO JUGAR (ID_jugador, ID_juego) VALUES (2, 2);
INSERT INTO JUGAR (ID_jugador, ID_juego) VALUES (4, 2);
INSERT INTO JUGAR (ID_jugador, ID_juego) VALUES (5, 2);

-- Juego 3
INSERT INTO JUGAR (ID_jugador, ID_juego) VALUES (1, 3);
INSERT INTO JUGAR (ID_jugador, ID_juego) VALUES (4, 3);
