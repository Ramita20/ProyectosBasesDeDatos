-- CREACION DE TABLAS

CREATE TABLE Tipos_Socios(
	tipo_socio VARCHAR(15) NOT NULL,
	detalle VARCHAR(100) NOT NULL,
	PRIMARY KEY(tipo_socio)
);

CREATE TABLE Precios(
	tipo_precio CHAR NOT NULL,
	precio_cuota FLOAT NOT NULL,
	PRIMARY KEY(tipo_precio)
);

CREATE TABLE Grados_Parentescos(
	id_grado_parent SERIAL NOT NULL,
	descripcion VARCHAR(15) NOT NULL,
	grado INT NOT NULL,
	PRIMARY KEY(id_grado_parent)
);

CREATE TABLE Provincias(
	id_provincia SERIAL NOT NULL,
	prov_nombre VARCHAR(50) NOT NULL,
	PRIMARY KEY(id_provincia)
);

CREATE TABLE Localidades(
	cod_postal INT NOT NULL,
	local_nombre VARCHAR(50),
	id_provincia INT NOT NULL,
	PRIMARY KEY(cod_postal),
	FOREIGN KEY(id_provincia) REFERENCES Provincias(id_provincia)
);

CREATE TABLE Socios_Titulares(
	nro_socio INT NOT NULL,
	dni INT NOT NULL,
	nombre VARCHAR(20) NOT NULL,
	apellido VARCHAR(20) NOT NULL,
	fecha_nac DATE NOT NULL,
	sexo CHAR,
	fecha_insc DATE NOT NULL,
	cod_postal INT NOT NULL,
	estatura FLOAT,
	individual_familiar CHAR NOT NULL,
	tipo_socio VARCHAR(15) NOT NULL,
	estado VARCHAR(50) NOT NULL,
	PRIMARY KEY(nro_socio),
	FOREIGN KEY(cod_postal) REFERENCES Localidades(cod_postal),
	FOREIGN KEY(tipo_socio) REFERENCES Tipos_Socios(tipo_socio)
);

CREATE TABLE Socios_Adherentes(
	dni_pariente INT NOT NULL,
	nombre VARCHAR(20) NOT NULL,
	apellido VARCHAR(20) NOT NULL,
	fecha_nac DATE NOT NULL,
	sexo CHAR,
	id_grado_parent INT NOT NULL,
	nro_socio_titular INT NOT NULL,
	PRIMARY KEY(dni_pariente),
	FOREIGN KEY(id_grado_parent) REFERENCES Grados_Parentescos(id_grado_parent),
	FOREIGN KEY(nro_socio_titular) REFERENCES Socios_Titulares(nro_socio)
);

CREATE TABLE Becas(
	nro_socio INT NOT NULL,
	desde_mes_anio DATE NOT NULL,
	hasta_mes_anio DATE NOT NULL,
	porc_cuotas FLOAT NOT NULL,
	FOREIGN KEY(nro_socio) REFERENCES Socios_Titulares(nro_socio)
);

CREATE TABLE Deportes(
	codigo INT NOT NULL,
	nombre VARCHAR(70),
	feder_nombre VARCHAR(70),
	PRIMARY KEY(codigo)
);

CREATE TABLE Socios_Deportes(
	cod_deporte INT NOT NULL,
	nro_socio INT NOT NULL,
	nro_inscripcion INT NOT NULL,
	FOREIGN KEY(cod_deporte) REFERENCES Deportes(codigo),
	FOREIGN KEY(nro_socio) REFERENCES Socios_Titulares(nro_socio)
);

CREATE TABLE Socios_Periodos(
	nro_socio INT NOT NULL,
	fecha_desde DATE NOT NULL,
	fecha_hasta DATE,
	motivo_baja VARCHAR(150),
	FOREIGN KEY(nro_socio) REFERENCES Socios_Titulares(nro_socio)
);

CREATE TABLE Cuotas(
	nro_socio INT NOT NULL,
	mes_anio DATE NOT NULL,
	fecha_venc DATE NOT NULL,
	importe FLOAT NOT NULL,
	estado VARCHAR(20) NOT NULL,
	cuotas_adeudadas INT DEFAULT NULL,
	deuda DECIMAL(10,2) DEFAULT NULL,
	FOREIGN KEY(nro_socio) REFERENCES Socios_Titulares(nro_socio)
);

CREATE TABLE Cuotas_Detalle(
	nro_socio INT NOT NULL,
	dni_adherente INT,
	mes_anio DATE NOT NULL,
	tipo_precio VARCHAR(1) NOT NULL,
	FOREIGN KEY(nro_socio) REFERENCES Socios_Titulares(nro_socio),
	FOREIGN KEY(dni_adherente) REFERENCES Socios_Adherentes(dni_pariente),
	FOREIGN KEY(tipo_precio) REFERENCES Precios(tipo_precio)
);

CREATE TABLE Pagos_Cuotas(
	nro_socio INT NOT NULL,
	mes_anio DATE NOT NULL,
	fecha_pago DATE NOT NULL,
	monto DECIMAL(10,2) NOT NULL,
	recargo DECIMAL(10,2) NOT NULL,
	estado VARCHAR(20) NOT NULL,
	FOREIGN KEY(nro_socio) REFERENCES Socios_Titulares(nro_socio)
);

CREATE TABLE Direcciones(
	nro_socio INT NOT NULL,
	calle VARCHAR(30) NOT NULL,
	numero INT NOT NULL,
	piso INT,
	dpto INT,
	FOREIGN KEY(nro_socio) REFERENCES Socios_Titulares(nro_socio)
);

CREATE TABLE Empleados(
	cuil VARCHAR(20) NOT NULL,
	nombre VARCHAR(20) NOT NULL,
	apellido VARCHAR(20) NOT NULL,
	fecha_ingreso DATE NOT NULL,
	cargo VARCHAR(20) NOT NULL,
	cuil_supervisor VARCHAR(20),
	PRIMARY KEY(cuil),
	FOREIGN KEY(cuil_supervisor) REFERENCES Empleados(cuil)
);

-- INSERTS
-- Para poder probar los triggers, view y procedimientos del siguiente archivo.

INSERT INTO Tipos_Socios(tipo_socio, detalle)
VALUES
	('Deportivo', 'Uso de instalacion deportiva del deporte que realiza'),
	('Vitalicio', 'No abona cuota'),
	('Normal', 'Abona cuota');

INSERT INTO Precios(tipo_precio, precio_cuota)
VALUES
	('T', 400),
	('A', 150);

INSERT INTO Grados_Parentescos(descripcion, grado)
VALUES
	('Padre', 1), ('Madre', 1), ('Hermano/a', 2), ('Primo/a', 4),
	('Abuelo/a', 2), ('Tío/a', 3);
	
INSERT INTO Provincias(prov_nombre)
VALUES
	('Entre Ríos'), ('Buenos Aires'), ('Cordóba');
	
INSERT INTO Localidades(cod_postal, local_nombre, id_provincia)
VALUES
	('3100', 'Parana', 1), ('1900', 'La Plata', 2), ('5000', 'Cordóba', 3);
	
INSERT INTO Socios_Titulares
	(nro_socio, dni, nombre, apellido, fecha_nac, sexo, fecha_insc,
	 cod_postal, estatura, individual_familiar, tipo_socio, estado)
VALUES
	(12, 12345678, 'Juan', 'Sanchez', '1980-07-18', 'M', '1990-08-02',
	 3100, 1.75, 'F', 'Normal', 'Activo'),
	(17, 87654321, 'Raúl', 'Peralta', '1985-09-19', 'M', '1993-04-05',
	 1900, 1.69, 'I', 'Deportivo', 'Activo'),
	(18, 18273645, 'Carlos', 'Ortega', '1998-03-20', 'M', '2000-01-09',
	 5000, 1.73, 'I', 'Vitalicio', 'Activo'),
	(25, 54637281, 'Juan', 'Samboni', '1985-11-03', 'M', '1994-04-04',
	 1900, 1.77, 'F', 'Normal', 'Activo');

INSERT INTO Socios_Adherentes
	(dni_pariente, nombre, apellido, fecha_nac,
	 sexo, id_grado_parent, nro_socio_titular)
VALUES
	(56348345, 'Luis', 'Sánchez', '1989-02-25', 'M', 4, 12),
	(75870454, 'María', 'Fuentes', '1950-05-23', 'F', 2, 12),
	(63456043, 'Mariana', 'Samboni', '2003-09-18', 'F', 6, 25);

INSERT INTO Becas(nro_socio, desde_mes_anio, hasta_mes_anio, porc_cuotas)
VALUES(17, '1995-03-04', '1996-04-03', 8.33);

INSERT INTO Deportes(codigo, nombre, feder_nombre)
VALUES(1234, 'Basquet', 'Federación de Basquetbol de la Policia de Buenos Aires');

INSERT INTO Socios_Deportes(cod_deporte, nro_socio, nro_inscripcion)
VALUES(1234, 17, 4321);

INSERT INTO Socios_Periodos(nro_socio, fecha_desde, fecha_hasta, motivo_baja)
VALUES
	(12, '1990-08-02', NULL, NULL),
	(17, '1993-04-05', NULL, NULL),
	(18, '2000-01-09', NULL, NULL),
	(25, '1994-04-04', NULL, NULL);

INSERT INTO Cuotas(nro_socio, mes_anio, fecha_venc, importe, estado)
VALUES
	(12, '2024-04-01', '2024-04-29', 700, 'Activa'),
	(17, '2024-04-01', '2024-04-29', 400, 'Activa'),
	(18, '2024-04-01', '2024-04-29', 400, 'Activa'),
	(25, '2024-04-01', '2024-04-29', 550, 'Activa');

INSERT INTO Cuotas_Detalle(nro_socio, dni_adherente, mes_anio, tipo_precio)
VALUES
	(12, NULL, '2024-04-01', 'T'),
	(17, NULL, '2024-04-01', 'T'),
	(18, NULL, '2024-04-01', 'T'),
	(25, NULL, '2024-04-01', 'T'),
	(12, 56348345, '2024-04-01', 'A'),
	(12, 75870454, '2024-04-01', 'A'),
	(25, 63456043, '2024-04-01', 'A');

INSERT INTO Pagos_Cuotas(nro_socio, mes_anio, fecha_pago, monto, recargo, estado)
VALUES
	(12, '2024-03-01', '2024-03-25', 700, 0, 'Pagada'),
	(17, '2024-03-01', '2024-04-04', 400, 25, 'Pagada'),
	(18, '2024-03-01', '2024-03-15', 400, 50, 'Pagada'),
	(25, '2024-03-01', '2024-04-02', 550, 25, 'Pagada');

INSERT INTO Direcciones(nro_socio, calle, numero, piso, dpto)
VALUES
	(12, 'Sarmiento', 155, 2, 53),
	(17, 'San Martin', 353, 1, 66),
	(18, 'Urquiza', 132, 4, 77),
	(25, 'Belgrano', 235, 3, 12);

INSERT INTO Empleados(cuil, nombre, apellido, fecha_ingreso, cargo, cuil_supervisor)
VALUES
	('23-16620782-8', 'Jose', 'López', '2015-07-30', 'Consultor','26-13990485-4'),
	('26-13990485-4', 'Pedro', 'García', '2018-11-22', 'Gerente', NULL),
	('25-22942016-2', 'Ana', 'Sánchez', '2019-06-17', 'Supervisor','26-13990485-4'),
	('25-32691962-1', 'Lucía', 'Martínez', '2017-03-10', 'Operario', '23-94956047-1'),
	('26-87386699-2', 'Carlos', 'Pérez', '2020-09-05', 'Técnico', '25-22942016-2'),
	('23-94956047-1', 'María', 'Gómez', '2016-04-28', 'Administrativo','26-13990485-4'),
	('23-66764055-2', 'Juan', 'Ruiz', '2021-02-14', 'Vendedor', '25-22942016-2'),
	('20-91930143-7', 'Carmen', 'Hernández', '2019-12-03', 'Consultor', '25-22942016-2'),
	('25-79246988-0', 'Luis', 'Díaz', '2018-08-19', 'Asistente', '23-94956047-1'),
	('26-50692739-7', 'Sofía', 'Fernández', '2021-04-16', 'Técnico', '23-94956047-1');
