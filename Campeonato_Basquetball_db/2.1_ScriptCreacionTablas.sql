-- Tabla Datos.
-- Tabla sin normalizar.
create table datos(
equipoOP_ciudad varchar(30),
equipoOP_codigo varchar(30),
equipoOP_sigla varchar(5),
equipoOP_conferencia varchar(20),
equipoOP_division varchar(20),
equipoOP_id INT,
equipoOP_nombre varchar(30),
stat_asistencias_id INT,
stat_asistencias_nombre varchar(50),
stat_asistencias_valor INT,
stat_bloqueos_id INT,
stat_bloqueos_nombre varchar(50),
stat_bloqueos_valor INT,
equipo_ciudad varchar(30),
jugador_codigo varchar(40),
pais varchar(50),
stat_rebotes_defensivos_id INT,
stat_rebotes_defensivos_nombre varchar(50),
stat_rebotes_defensivos_valor int,
equipo_sigla varchar(5),
equipo_conferencia varchar(20),
nombre_completo varchar(40),
equipo_division varchar(20),
draft_year int,
fecha datetime,
stat_tiros_intentos_id INT,
stat_tiros_intentos_nombre varchar(50),
stat_tiros_intentos_valor int,
stat_tiros_convertidos_id INT,
stat_tiros_convertidos_nombre varchar(50),
stat_tiros_convertidos_valor int,
tiros_porcentaje decimal(5,2),
nombre varchar(30),
stat_faltas_id INT,
stat_faltas_nombre varchar(50),
stat_faltas_valor int,
stat_tiros_libres_intentos_id INT,
stat_tiros_libres_intentos_nombre varchar(50),
stat_tiros_libres_intentos_valor int,
stat_tiros_libres_convertidos_id INT,
stat_tiros_libres_convertidos_nombre varchar(50),
stat_tiros_libres_convertidos_valor int,
tiros_libres_porcentaje decimal(5,2),
partido_id int,
altura decimal(5,2),
esLocal varchar(20),
camiseta int,
apellido varchar(30),
stat_minutos_id INT,
stat_minutos_nombre varchar(50),
stat_minutos_valor int,
equipo_nombre varchar(30),
stat_rebotes_ofensivos_id INT,
stat_rebotes_ofensivos_nombre varchar(50),
stat_rebotes_ofensivos_valor int,
equipoOP_puntos int,
jugador_id int,
stat_puntos_id INT,
stat_puntos_nombre varchar(50),
stat_puntos_valor int,
posicion varchar(5),
rebotes int,
temporada_id int,
stat_segundos_id INT,
stat_segundos_nombre varchar(50),
stat_segundos_valor int,
stat_robos_id INT,
stat_robos_nombre varchar(50),
stat_robos_valor int,
equipo_codigo varchar(30),
equipo_puntos int,
equipo_id int,
stat_tiros_triples_intentos_id INT,
stat_tiros_triples_intentos_nombre varchar(50),
stat_tiros_triples_intentos_valor int,
stat_tiros_triples_convertidos_id INT,
stat_tiros_triples_convertidos_nombre varchar(50),
stat_tiros_triples_convertidos_valor int,
tiros_triples_porcentaje decimal(5,2),
stat_perdidas_id INT,
stat_perdidas_nombre varchar(50),
stat_perdidas_valor int,
peso varchar(50),
resultado varchar(10),
temporada_descripcion varchar(20),
idPais int,
equipo_idCiudad int,
equipoOP_idCiudad int
)

-- Tablas Diagrama
-- Tabla anterior, normalizada
Create Table Temporada(
ID_T int not null,
Descripcion varchar(20)

constraint pk_Temporada primary key clustered (id_T)
)

Create Table Conferencia(
Id int not null identity(1,1),
Nombre varchar(20)

constraint pk_Conferencia primary key clustered (id)
)

Create table Division(
Id int not null identity(1,1),
Nombre varchar(20),
id_conferencia int 

constraint pk_Division primary key clustered (id),
foreign key (id_conferencia) references Conferencia(id)
)

Create table Ciudad(
Id_Ciu int not null,
Nombre varchar(30)

constraint pk_Ciudad primary key clustered (Id_Ciu)
)

Create table Pais(
Id_Pais int not null,
Nombre varchar(30)

constraint pk_Pais primary key clustered (Id_Pais)
)

Create table Equipo(
Id_EQ int not null,
Codigo varchar(30),
Nombre varchar(30),
Sigla varchar(5),
Id_Ciudad int,
id_Division int

constraint pk_Equipo primary key clustered (Id_EQ),
foreign key (Id_Ciudad) references Ciudad(Id_Ciu),
foreign key (Id_Division) references Division(id)

)

Create Table Partido(
Id_Partido int not null,
Fecha date,
id_Temporada int

constraint pk_Partido primary key clustered (Id_Partido),
foreign key (id_Temporada) references Temporada(ID_T),
)

CREATE TABLE Resultado(
id INT NOT NULL IDENTITY(1,1),
id_local INT NOT NULL,
id_visitante INT NOT NULL,
pts_local INT NOT NULL,
pts_visitante INT NOT NULL,
resultado VARCHAR(30) NOT NULL,
id_partido INT NOT NULL,

constraint pk_Resultado primary key clustered (id),
foreign key (id_Local) references Equipo(Id_EQ),
foreign key (id_Visitante) references Equipo(Id_EQ),
foreign key (id_partido) references Partido(Id_Partido)
);

Create table Jugador(
Id_Jugador int not null,
Codigo varchar (40) ,
Nombre varchar (30),
Apellido varchar(30),
Posicion varchar(5),
AñoReclutamiento int,
Peso varchar(50),
Altura decimal(5,2),
Id_Pais int

constraint pk_Jugador primary key clustered (Id_Jugador)
foreign key (Id_Pais) references Pais(Id_Pais)
)

Create Table Tipo_Estadistica(
IdTipoEstadistica int not null,
Descripcion varchar(50)

constraint pk_TEstadistica primary key clustered (IdTipoEstadistica)
)

Create table Estadistica(
IdTEstadistica int not null,
IdJugador int not null,
IdPartido int not null,
Valor int

constraint pk_Estadistica primary key clustered (IdPartido,IdJugador,IdTEstadistica)
foreign key (IdPartido) references Partido(id_Partido),
foreign key (IdJugador) references Jugador(id_Jugador),
foreign key (idTEstadistica) references Tipo_Estadistica(IdTipoEstadistica)
)

Create Table Equipo_Jugador(
idEquipo int,
idJugador int,
Camiseta int 
constraint pk_EQJug primary key clustered (IdEquipo,IdJugador)
foreign key (IdEquipo) references Equipo(id_EQ),
foreign key (IdJugador) references Jugador(id_Jugador)
)

Create table Partido_Equipo(
idPartido int,
idEquipo int,

constraint pk_Part_EQ primary key clustered (IdEquipo,IdPartido),
foreign key (IdEquipo) references Equipo(id_EQ),
foreign key (IdPartido) references Partido(id_Partido)
)