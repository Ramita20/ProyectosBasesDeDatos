-- 1. Cantidad de jugadores que jugaron el campeonato.
SELECT COUNT(*) as Cant_Jugadores FROM Jugador;

-- 2. Cantidad de partidos que se jugaron en el mes de febrero.
SELECT COUNT(*) as Partidos_Febrero
FROM Partido p 
WHERE MONTH(p.fecha) = 02

 -- 3. Cantidad de jugadores que jugaron para los Raptors.
SELECT COUNT(*) as Jugadores_Raptors FROM Equipo_Jugador ej 
JOIN Equipo e ON ej.idEquipo = e.Id_EQ
WHERE e.nombre = 'Raptors'

/* 4. Indicar fecha, equipo local, puntos realizados, equipo visitante y puntos realizados de los
partidos que se jugaron en noviembre. */
SELECT p.Fecha,e.Nombre,R.pts_local , ev.Nombre, R.pts_visitante
FROM Resultado R
join Partido p on p.Id_Partido=r.id_partido
JOIN Equipo e ON R.id_Local=e.Id_EQ
JOIN Equipo ev on R.id_Visitante=ev.Id_EQ
WHERE MONTH(p.Fecha) = 11
ORDER BY p.Fecha

-- 5. Cantidad de partidos que perdieron los Raptors jugando como local.
Select COUNT(*) as PartidosPerdidosComoLocal from Resultado as R 
join Equipo E on R.id_local=e.Id_EQ
JOIN Equipo EV ON R.id_visitante = ev.Id_EQ
where E.Nombre='Raptors' and R.Resultado = 'Lost'  

-- 6. Listar los 5 equipos con menor promedio de peso de sus jugadores.
Select top 5 e.Nombre, AVG(CAST(j.Peso as decimal(5,2))) as Promedio_Peso_Equipo from Equipo e
JOIN Equipo_Jugador EJ on e.Id_EQ=EJ.idEquipo
JOIN Jugador J on j.Id_Jugador=ej.idJugador 
group by e.Nombre 
order by Promedio_Peso_Equipo asc

-- 7. Promedio de rebotes por partido de los equipos agrupados por división.

SELECT d.nombre, AVG(cant_rebotes.tot_rebotes) AS promedio FROM Jugador j
INNER JOIN Equipo_Jugador ej ON j.Id_Jugador = ej.idJugador
INNER JOIN Equipo e ON ej.idEquipo = e.Id_EQ
INNER JOIN Division d ON e.id_division = d.id
INNER JOIN (SELECT e.Id_EQ AS eq_id, p.Id_Partido AS part_id, SUM(est.valor) AS tot_rebotes FROM Partido p
			INNER JOIN Resultado r ON p.Id_Partido = r.id_partido
			INNER JOIN Equipo e ON r.id_local = e.Id_EQ
			INNER JOIN Estadistica est ON p.Id_Partido = est.idpartido
			WHERE est.idTEstadistica = 17
			GROUP BY e.Id_EQ, p.Id_Partido) AS cant_rebotes ON e.Id_EQ = cant_rebotes.eq_id --Cantidad de rebotes por partido de cada equipo
GROUP BY d.nombre

-- 8. Promedio de asistencias por partido de los jugadores agrupados por conferencia.

SELECT d.id_conferencia ,AVG(est.valor) AS promedio FROM Jugador j 
INNER JOIN Estadistica est ON j.Id_Jugador = est.idJugador
INNER JOIN Equipo_Jugador ej ON j.Id_Jugador = ej.idJugador
INNER JOIN Equipo e ON ej.idEquipo = e.Id_EQ
INNER JOIN Division d ON e.id_division = d.id
WHERE est.idTestadistica = 1
GROUP BY d.id_conferencia

/* 9 - Cantidad de bloqueos, rebotes totales y asistencias realizados por Kawhi Leonard contra
equipos de la otra conferencia. */
SELECT 
	SUM(CASE WHEN es.idTEstadistica = 2 THEN es.valor ELSE 0 END) AS bloqueos_totales,
    SUM(CASE WHEN es.idTEstadistica = 17 THEN es.valor ELSE 0 END) AS rebotes_totales,
    SUM(CASE WHEN es.idTEstadistica = 1 THEN es.valor ELSE 0 END) AS asistencias_totales 
FROM 
   Equipo_Jugador ej
   INNER JOIN Jugador j ON ej.idJugador = j.id_Jugador
   INNER JOIN Equipo e ON ej.idEquipo = e.id_EQ
   INNER JOIN Division d ON e.id_Division = d.id
   INNER JOIN Conferencia c ON d.id_conferencia = c.id
   INNER JOIN Estadistica es ON j.id_Jugador = es.idjugador
	INNER JOIN Resultado R ON r.id_local=e.Id_EQ and r.id_partido=es.IdPartido
WHERE 
   j.nombre = 'Kawhi' and es.IdPartido IN(  SELECT r.id_partido from Resultado r
	 inner join equipo e on r.id_visitante=e.Id_EQ
	 inner join Division d on e.id_Division=d.id
	 inner join equipo eq on r.id_local=eq.Id_EQ
	 inner join Division di on eq.id_Division=di.id
	 where d.id_conferencia <> di.id_conferencia)


--10 Jugadores que jugaron en más de un equipo, indicando su nombre completo y equipo.

SELECT j.nombre jdor_nombre, j.apellido jdor_apellido, e.nombre eq_nombre
FROM Jugador j
INNER JOIN Equipo_Jugador ej ON j.Id_Jugador = ej.idJugador
INNER JOIN Equipo e ON ej.idEquipo = e.Id_EQ
WHERE (SELECT COUNT(*) FROM Jugador j
	   INNER JOIN Equipo_Jugador ej ON j.Id_Jugador = ej.idJugador
	   INNER JOIN Equipo e ON ej.idEquipo = e.Id_EQ ) >= 2
	   

/* 11. Mostrar nombre, apellido, camiseta y nombre de su equipo, del jugador con mayor
promedio de bloqueos por partido */

SELECT TOP 1 j.nombre, j.apellido, ej.camiseta, e.nombre, prom_bloq.promedio
FROM Jugador j
INNER JOIN Equipo_Jugador ej ON j.Id_Jugador = ej.idJugador
INNER JOIN Equipo e ON ej.idEquipo = e.Id_EQ
INNER JOIN (SELECT est.idJugador, AVG(est.valor) AS promedio
	  FROM Estadistica est
	  WHERE est.idTEstadistica = 2
	  GROUP BY est.idJugador) AS prom_bloq ON j.Id_Jugador = prom_bloq.idJugador
ORDER BY prom_bloq.promedio DESC

/* 12. Cantidad de jugadores con más de 15 años de carrera, cantidad entre 15 y 10 y cantidad
con menos de 10 años. */
SELECT 'Más de 15 años' AS descripcion, COUNT(*) AS cantidad FROM Jugador j 
WHERE (2023 - j.AñoReclutamiento) > 15 
UNION SELECT 'Entre 15 y 10 años', COUNT(*) FROM Jugador j 
WHERE (2023 - j.AñoReclutamiento) <= 15 AND (2023 - j.AñoReclutamiento) >= 10
UNION SELECT 'Menos de 10 años', COUNT(*) FROM Jugador j 
WHERE (2023 - j.AñoReclutamiento) < 10
ORDER BY cantidad;

/* 13. Listado de jugadores que jugaron para los Bulls, indicando su nombre completo, equipo,
número de camiseta y antigüedad al año 2023. */
SELECT J.Nombre, J.apellido, E.nombre, EJ.camiseta, 2023-j.AñoReclutamiento AS Antiguedad FROM Jugador J
JOIN Equipo_Jugador EJ ON j.Id_Jugador=EJ.idJugador
JOIN Equipo E ON EJ.idEquipo=E.Id_EQ
WHERE E.Nombre='Bulls'

/* 14. Cantidad de partidos en que los que al menos un jugador de los Pacers obtuvo más de 15
puntos. */
SELECT COUNT(distinct ES.IdPartido) AS PartidosPacersMas15Ptos FROM Estadistica ES
JOIN Partido P ON P.Id_Partido=ES.IdPartido
JOIN Resultado R ON P.Id_Partido=R.id_partido
JOIN Equipo E ON E.Id_EQ=R.id_local OR E.Id_EQ=R.id_visitante
JOIN Tipo_Estadistica TE ON TE.IdTipoEstadistica=ES.IdTEstadistica
WHERE E.Nombre='Pacers' AND TE.IdTipoEstadistica=11 AND ES.Valor>15;

/* 15. Indicar ID de partido, fecha, sigla y puntos realizados del equipo local y visitante, 
del partido en que el equipo de Kawhi Leonard ganó por mayor diferencia de puntos en la temporada. */

SELECT TOP 1 R.id_partido,P.Fecha,E.Sigla,R.pts_local,R.pts_visitante FROM Equipo E
JOIN Equipo_Jugador EJ ON E.Id_EQ= EJ.idEquipo
JOIN Jugador J on EJ.idJugador=J.Id_Jugador
JOIN Resultado R ON R.id_local=E.Id_EQ
JOIN Partido P ON P.Id_Partido=R.id_partido
WHERE J.Nombre='Kawhi' AND R.resultado='Won' 
ORDER BY (pts_local-pts_visitante) DESC