CREATE TABLE JUGADOR
(
  ID_jugador NUMBER(20) NOT NULL,
  nombre VARCHAR2(50) NOT NULL,
  PRIMARY KEY (ID_jugador)
);

CREATE TABLE JUEGO
(
ID_juego NUMBER(20) NOT NULL, 
fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (ID_juego)
);

CREATE TABLE JUGAR
(
  ID_jugador NUMBER(20) NOT NULL,
  ID_juego NUMBER(20) NOT NULL,
  PRIMARY KEY (ID_jugador,ID_juego ),
  FOREIGN KEY (ID_jugador) REFERENCES JUGADOR(ID_jugador),
  FOREIGN KEY (ID_juego) REFERENCES JUEGO(ID_juego)
);



--cambiar tablas de abajo
--ahora jugada sera foranea de organo_en_mesa y cubre_organo
CREATE TABLE JUGADA
(
  ID_jugada NUMBER(20) NOT NULL,
  ID_juego NUMBER(20) NOT NULL,
  pasada NUMBER(1) DEFAULT 0,
  ID_jugador NUMBER(20) NOT NULL,
  PRIMARY KEY (ID_juego, ID_jugada),
  FOREIGN KEY (ID_jugador) REFERENCES JUGADOR(ID_jugador),
  FOREIGN KEY (ID_juego) REFERENCES JUEGO(ID_juego)
);


CREATE TABLE ORGANO_EN_MESA
(
  organo VARCHAR(50)  NOT NULL,
  ID_carta NUMBER(20) NOT NULL,
  color VARCHAR(30) NOT NULL,
  ID_jugada NUMBER(20),
  ID_juego NUMBER(20), 
  PRIMARY KEY (ID_carta),
CONSTRAINT chk_color_o CHECK (color IN ('AMARILLO','ROJO','AZUL','VERDE')),
CONSTRAINT chk_organo CHECK (organo IN ('HUESO','CORAZON','CEREBRO','ESTOMAGO')),
 FOREIGN KEY (ID_juego,ID_jugada) REFERENCES JUGADA(ID_juego,ID_jugada)
);



CREATE TABLE CUBRE_ORGANO
(
  tipo VARCHAR(20) NOT NULL,
  ID_carta NUMBER(20) NOT NULL,
  ID_jugada NUMBER(20),
  ID_juego NUMBER(20), 
  color VARCHAR2(30) NOT NULL,
  ID_carta_cubierta NUMBER(20) NULL,
  PRIMARY KEY (ID_carta),
  CONSTRAINT chk_tipo_cubre CHECK (tipo IN ('VIRUS', 'MEDICINA')) ,
  CONSTRAINT chk_color_c CHECK (color IN ('AMARILLO','ROJO','AZUL','VERDE')) ,
  FOREIGN KEY (ID_carta_cubierta) REFERENCES ORGANO_EN_MESA(ID_carta),
  FOREIGN KEY (ID_juego,ID_jugada) REFERENCES JUGADA(ID_juego,ID_jugada)
);


ALTER TABLE cubre_organo MODIFY (ID_carta_cubierta NULL);

