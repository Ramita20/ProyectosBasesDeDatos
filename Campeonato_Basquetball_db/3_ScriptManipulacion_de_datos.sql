-- Temporadas
INSERT INTO Temporada
SELECT DISTINCT d.temporada_id, d.temporada_descripcion 
FROM datos AS d;

-- Ciudades
INSERT INTO Ciudad
SELECT DISTINCT d.equipoOP_idCiudad, d.equipoOP_ciudad
FROM datos AS d
ORDER BY d.equipoOP_idCiudad;

-- Paises
INSERT INTO Pais 
SELECT DISTINCT d.idPais, d.pais 
FROM datos AS d
ORDER BY d.idPais;


-- Conferencias
INSERT INTO Conferencia
SELECT DISTINCT d.equipoOP_conferencia
FROM datos AS d;

-- Divisiones
INSERT INTO Division 
SELECT DISTINCT d.equipoOP_division, c.id
FROM datos AS d join Conferencia c on d.equipoOP_conferencia=c.nombre;

-- Equipos
INSERT INTO Equipo 
SELECT DISTINCT d.equipoOP_id, d.equipoOP_codigo, d.equipoOP_nombre, d.equipoOP_sigla, d.equipoOP_idCiudad, di.id
FROM datos AS d join Division di on d.equipoOP_division=di.nombre
ORDER BY d.equipoOP_id;

-- Jugadores
INSERT INTO Jugador
SELECT DISTINCT d.jugador_id, d.jugador_codigo, d.nombre, d.apellido, d.posicion, d.draft_year, d.peso, d.altura ,d.idPais
FROM datos AS d
ORDER BY d.jugador_id;

-- Partidos
INSERT INTO Partido
SELECT DISTINCT d.partido_id, CONVERT(DATE, d.fecha), temporada_id
FROM datos AS d
ORDER BY d.partido_id;

-- Resultados
INSERT INTO Resultado
SELECT DISTINCT d.equipo_id, d.equipoOP_id, d.equipo_puntos, d.equipoOP_puntos, d.resultado, d.partido_id
FROM datos d;

-- Tipo de estadisticas
INSERT INTO Tipo_Estadistica
SELECT * FROM (SELECT DISTINCT d.stat_asistencias_id, d.stat_asistencias_nombre
FROM datos AS d UNION
SELECT DISTINCT d.stat_bloqueos_id, d.stat_bloqueos_nombre
FROM datos AS d UNION
SELECT DISTINCT d.stat_rebotes_defensivos_id, d.stat_rebotes_defensivos_nombre
FROM datos AS d UNION
SELECT DISTINCT d.stat_tiros_intentos_id, d.stat_tiros_intentos_nombre
FROM datos AS d UNION
SELECT DISTINCT d.stat_tiros_convertidos_id, d.stat_tiros_convertidos_nombre
FROM datos AS d UNION
SELECT DISTINCT d.stat_faltas_id, d.stat_faltas_nombre
FROM datos AS d UNION
SELECT DISTINCT d.stat_tiros_libres_intentos_id, d.stat_tiros_libres_intentos_nombre
FROM datos AS d UNION
SELECT DISTINCT d.stat_tiros_libres_convertidos_id, d.stat_tiros_libres_convertidos_nombre
FROM datos AS d UNION
SELECT DISTINCT d.stat_minutos_id, d.stat_minutos_nombre
FROM datos AS d UNION
SELECT DISTINCT d.stat_rebotes_ofensivos_id, d.stat_rebotes_ofensivos_nombre
FROM datos AS d UNION
SELECT DISTINCT d.stat_puntos_id, d.stat_puntos_nombre
FROM datos AS d UNION
SELECT DISTINCT d.stat_segundos_id, d.stat_segundos_nombre
FROM datos AS d UNION
SELECT DISTINCT d.stat_robos_id, d.stat_robos_nombre
FROM datos AS d UNION
SELECT DISTINCT d.stat_tiros_triples_intentos_id, d.stat_tiros_triples_intentos_nombre
FROM datos AS d UNION
SELECT DISTINCT d.stat_tiros_triples_convertidos_id, d.stat_tiros_triples_convertidos_nombre
FROM datos AS d UNION
SELECT DISTINCT d.stat_perdidas_id, d.stat_perdidas_nombre
FROM datos AS d) AS estadisticas
ORDER BY estadisticas.stat_asistencias_id;

INSERT INTO Tipo_Estadistica VALUES(17, 'Rebotes');
INSERT INTO Tipo_Estadistica VALUES(18, 'Porcentaje de tiros');
INSERT INTO Tipo_Estadistica VALUES(19, 'Porcentaje tiros libres');
INSERT INTO Tipo_Estadistica VALUES(20, 'Porcentaje tiros triples');

-- Estadisticas
INSERT INTO Estadistica
SELECT * 
FROM (SELECT d.stat_asistencias_id, d.jugador_id, d.partido_id, d.stat_asistencias_valor
	FROM datos AS d UNION
	SELECT d.stat_bloqueos_id, d.jugador_id, d.partido_id, d.stat_bloqueos_valor
	FROM datos AS d UNION
	SELECT d.stat_rebotes_defensivos_id, d.jugador_id, d.partido_id, d.stat_rebotes_defensivos_valor
	FROM datos AS d UNION
	SELECT d.stat_tiros_intentos_id, d.jugador_id, d.partido_id, d.stat_tiros_intentos_valor
	FROM datos AS d UNION
	SELECT d.stat_tiros_convertidos_id, d.jugador_id, d.partido_id, d.stat_tiros_convertidos_valor
	FROM datos AS d UNION
	SELECT d.stat_faltas_id, d.jugador_id, d.partido_id, d.stat_faltas_valor
	FROM datos AS d UNION
	SELECT d.stat_tiros_libres_intentos_id, d.jugador_id, d.partido_id, d.stat_tiros_libres_intentos_valor
	FROM datos AS d UNION
	SELECT d.stat_tiros_libres_convertidos_id, d.jugador_id, d.partido_id, d.stat_tiros_libres_convertidos_valor
	FROM datos AS d UNION
	SELECT d.stat_minutos_id, d.jugador_id, d.partido_id, d.stat_minutos_valor
	FROM datos AS d UNION
	SELECT d.stat_rebotes_ofensivos_id, d.jugador_id, d.partido_id, d.stat_rebotes_ofensivos_valor
	FROM datos AS d UNION
	SELECT d.stat_puntos_id, d.jugador_id, d.partido_id, d.stat_puntos_valor
	FROM datos AS d UNION
	SELECT d.stat_segundos_id, d.jugador_id, d.partido_id, d.stat_segundos_valor
	FROM datos AS d UNION
	SELECT d.stat_robos_id, d.jugador_id, d.partido_id, d.stat_robos_valor
	FROM datos AS d UNION
	SELECT d.stat_tiros_triples_intentos_id, d.jugador_id, d.partido_id, d.stat_tiros_triples_intentos_valor
	FROM datos AS d UNION
	SELECT d.stat_tiros_triples_convertidos_id, d.jugador_id, d.partido_id, d.stat_tiros_triples_convertidos_valor
	FROM datos AS d UNION
	SELECT d.stat_perdidas_id, d.jugador_id, d.partido_id, d.stat_perdidas_valor
	FROM datos AS d UNION
	SELECT id = 17, d.jugador_id, d.partido_id, d.rebotes 
	FROM datos AS d UNION
	SELECT id = 18, d.jugador_id, d.partido_id, d.tiros_porcentaje
	FROM datos AS d UNION
	SELECT id = 19, d.jugador_id, d.partido_id, d.tiros_libres_porcentaje
	FROM datos AS d UNION
	SELECT id = 20, d.jugador_id, d.partido_id, d.tiros_triples_porcentaje
	FROM datos AS d) AS estadisticas
ORDER BY estadisticas.stat_asistencias_id;

-- Equipos_Jugadores
INSERT INTO Equipo_Jugador
SELECT *
FROM (SELECT d.equipoOP_id, d.jugador_id, d.camiseta
FROM datos AS d UNION
SELECT d.equipo_id, d.jugador_id, d.camiseta
FROM datos AS d) AS ej
ORDER BY ej.equipoOP_id;

-- Partidos_Equipos
INSERT INTO Partido_Equipo
SELECT *
FROM (SELECT d.partido_id, d.equipoOP_id
FROM datos AS d UNION
SELECT d.partido_id, d.equipo_id
FROM datos AS d) AS pe
ORDER BY pe.partido_id;