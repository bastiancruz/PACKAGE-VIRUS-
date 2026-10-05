--BLOQUE 'INSERT' CUBRE_ORGANO
BEGIN
    pkg_virus_game.aplicar_cobertura(
        p_tipo_cubre       => 'MEDICINA',
        p_cubre_carta_id      => 1,
        p_jugada_id      => 4,
        p_juego_id => 1,
        p_color     => 'AZUL' ,
        p_organo_id => 2
    );
    COMMIT;
END;