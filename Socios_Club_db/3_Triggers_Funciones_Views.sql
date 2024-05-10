-- TRIGGERS, STORED PROCEDURES Y VIEWS

-- FUNCIONES GENERICAS

-- Corrobora si existe un socio con un número de socio especifico.
CREATE OR REPLACE FUNCTION fn_existe_sociot(socio_nro INT)
RETURNS BOOL AS
$$
DECLARE
	cant INT;
BEGIN
	IF socio_nro IS NULL THEN
		cant := 0;
	ELSE
		SELECT COUNT(*) INTO cant
		FROM socios_titulares
		WHERE nro_socio = socio_nro;
	END IF;
	
	IF cant > 0 THEN
		RETURN TRUE;
	END IF;
	
	RETURN FALSE;
END
$$ LANGUAGE plpgsql;

-- Corrobora si existe un socio en base a su DNI.
CREATE OR REPLACE FUNCTION fn_existe_sociot_dni(dni_buscado INT)
RETURNS BOOL AS
$$
DECLARE
	cant INT;
BEGIN
	IF dni_buscado IS NULL THEN
		cant := 0;
	ELSE
		SELECT COUNT(*) INTO cant
		FROM socios_titulares st
		WHERE st.dni = dni_buscado;
	END IF;

	IF cant > 0 THEN
		RETURN TRUE;
	END IF;
	
	RETURN FALSE;
END
$$ LANGUAGE plpgsql;

-- Punto 2 - Consigna D
-- Vista que contiene los socios titulares y adherentes
-- indicando con que titular tienen relación.
CREATE OR REPLACE VIEW vsocios AS
SELECT 
	st.nro_socio AS codigo_socio,
	st.apellido AS apellido,
	st.nombre AS nombre,
	'T' AS titular_adherente,
	NULL AS titular_nombre
FROM Socios_Titulares st
UNION
SELECT 
	st.nro_socio AS codigo_socio,
	sa.apellido AS apellido,
	sa.nombre AS nombre,
	'A' AS titular_adherente,
	st.apellido || ' ' || st.nombre AS titular_nombre
FROM socios_titulares st
INNER JOIN socios_adherentes sa
ON st.nro_socio = sa.nro_socio_titular
ORDER BY codigo_socio ASC, titular_adherente DESC;


-- Punto 2 - Consigna H
-- Stored procedure para generar un subarbol de empleados
-- a partir de un cuil dado.

CREATE OR REPLACE FUNCTION subarbol_empleados(cuil_ini VARCHAR)
RETURNS TABLE (
    cuil VARCHAR,
    nombre VARCHAR,
    apellido VARCHAR,
    fecha_ingreso DATE,
    cargo VARCHAR
) AS
$$
DECLARE
    emp_inicial VARCHAR := cuil_ini;
BEGIN
    SELECT em.cuil_supervisor INTO emp_inicial
    FROM empleados em
    WHERE em.cuil = cuil_ini;

    RETURN QUERY WITH RECURSIVE arbol_empleados AS (
        SELECT
			em1.cuil,
			em1.nombre,
			em1.apellido,
			em1.fecha_ingreso,
			em1.cargo
        FROM empleados em1
        WHERE cuil_supervisor = emp_inicial
        UNION ALL
        SELECT
			em2.cuil,
			em2.nombre,
			em2.apellido,
			em2.fecha_ingreso,
			em2.cargo
        FROM empleados em2
        INNER JOIN arbol_empleados ae ON em2.cuil_supervisor = ae.cuil
    )
    SELECT * FROM arbol_empleados;
END
$$ LANGUAGE plpgsql;


-- Punto 3 - Consigna A

-- Calcula el importe total a pagar por socio titular y adherentes.
CREATE OR REPLACE FUNCTION fn_calcularImporteSocio(socio_nro INT)
RETURNS NUMERIC AS
$$
DECLARE
	importe NUMERIC := 0;
BEGIN
	SELECT SUM(p.precio_cuota)
	INTO importe
	FROM cuotas_detalle cd
	INNER JOIN precios p ON cd.tipo_precio = p.tipo_precio
	WHERE cd.nro_socio = socio_nro;

	RETURN importe;
END
$$ LANGUAGE plpgsql;


-- Verifica si la cuota ya fue abonada y devulve la fecha en que la abonó
-- o NULL si dicha cuota aun no fue abonada.
CREATE OR REPLACE FUNCTION fn_verificarCuotaPaga(
	socio_nro INT,
	mes VARCHAR, 
	anio VARCHAR
)
RETURNS DATE AS
$$
DECLARE
	fecha_fact DATE := NULL;
BEGIN
	SELECT pc.fecha_pago INTO fecha_fact
	FROM pagos_cuotas pc
	WHERE pc.nro_socio = socio_nro
		AND EXTRACT(YEAR FROM pc.mes_anio) = anio::INT
		AND EXTRACT(MONTH FROM pc.mes_anio) = mes::INT;
	
	RETURN fecha_fact;
END
$$ LANGUAGE plpgsql;


-- Genera la cuota del siguiente mes y la inserta en la tabla.
CREATE OR REPLACE FUNCTION fn_generarNuevaCuota(socio_nro INT)
RETURNS VOID AS
$$
DECLARE
	mes_anio_nuevo DATE;
	fecha_venc_nuevo DATE;
	importe_nuevo NUMERIC;
BEGIN
	-- Actualizamos las fechas correspondientes al siguiente mes
	-- a facturar.
	SELECT 
		mes_anio + INTERVAL '1 month',
		fecha_venc + INTERVAL '1 month'
		INTO mes_anio_nuevo, fecha_venc_nuevo
	FROM cuotas 
	WHERE nro_socio = socio_nro;
	
	-- Calculamos el importe para dicho mes.
	importe_nuevo := fn_calcularImporteSocio(socio_nro);
	
	-- Insertamos los datos en la tabla de cuotas.
	INSERT INTO cuotas(nro_socio, mes_anio, fecha_venc, importe)
	VALUES(socio_nro, mes_anio_nuevo, fecha_venc_nuevo, importe_nuevo);
END
$$ LANGUAGE plpgsql;

-- Actualiza la cuota de un cliente indicado por su número 
-- de socio.
CREATE OR REPLACE FUNCTION fn_actualizarCuota(
    socio_nro INT,
    mes VARCHAR,
    anio VARCHAR
)
RETURNS TEXT AS
$$
DECLARE
    fecha_fact DATE := NULL;
	respuesta TEXT := '';
BEGIN
    fecha_fact := fn_verificarCuotaPaga(socio_nro, mes, anio);

    IF (fecha_fact IS NULL) THEN
		SELECT fn_generarNuevaCuota(socio_nro);
        respuesta := '0@Cuota actualizada con éxito.';
    ELSE
        respuesta := '-1@Mes facturado el ' || fecha_fact;
    END IF;
	
	RETURN respuesta;
END
$$ LANGUAGE plpgsql;


-- Punto 3 - Consigna B

-- Convierte un valor entero en una cadena de texto.
CREATE OR REPLACE FUNCTION monto_a_texto(monto INT)
RETURNS TEXT AS
$$
DECLARE
	unidades TEXT[] := '{UNO, DOS, TRES, CUATRO, CINCO,
	SEIS, SIETE, OCHO, NUEVE}';
	descenas TEXT[] := '{DIEZ, VEINTE, TREINTA, CUARENTA, CINCUENTA,
	SESENTA, SETENTA, OCHENTA, NOVENTA}';
	descenas_unidades TEXT[] := '{ONCE, DOCE, TRECE, CATORCE, QUINCE,
	DIECISÉIS, DIECISIETE, DIECIOCHO, DIECINUEVE}';
	centenas TEXT[] := '{CIEN, DOSCIENTOS, TRESCIENTOS, CUATROCIENTOS, QUINIENTOS,
	SEISCIENTOS, SETECIENTOS, OCHOCIENTOS, NOVECIENTOS}';
BEGIN
	IF monto = 0 THEN
		RETURN '';
	END IF;
	
	IF monto BETWEEN 1 AND 9 THEN
		RETURN unidades[monto];
	END IF;
	
	IF monto BETWEEN 11 AND 19 THEN
		RETURN descenas_unidades[monto - 10];
	END IF;
	
	IF monto BETWEEN 20 AND 99 THEN
		IF monto % 10 = 0 THEN
			RETURN descenas[monto / 10];
		ELSE
			RETURN descenas[monto / 10] || ' Y ' || monto_a_texto(monto % 10);
		END IF;
	END IF;
	
	IF monto BETWEEN 100 AND 999 THEN
		RETURN centenas[monto / 100] || ' ' || monto_a_texto(monto % 100);
	END IF;
	
	IF monto BETWEEN 1000 AND 1999 THEN
		RETURN 'MIL ' || monto_a_texto(monto % 1000);
	END IF;
	
	IF monto BETWEEN 2000 AND 999999 THEN
		RETURN monto_a_texto(monto / 1000) || ' MIL ' || monto_a_texto(monto % 1000);
	END IF;
	
	RETURN 'Número fuera de rango.';
END
$$ LANGUAGE plpgsql;


-- Convierte un valor decimal en una cadena de texto.
CREATE OR REPLACE FUNCTION monto_a_texto_dec(monto DECIMAL(10,2))
RETURNS TEXT AS
$$
DECLARE
	monto_txt TEXT;
	parte_entera INT;
	parte_decimal INT;
BEGIN
	monto_txt := monto::TEXT;
	
	parte_entera := CAST(SPLIT_PART(monto_txt, '.', 1) AS INT);
    parte_decimal := CAST(SPLIT_PART(monto_txt, '.', 2) AS INT);
	
	IF parte_entera = 0 AND parte_decimal = 0 THEN
		RETURN 'CERO';
	ELSIF parte_decimal = 0 THEN
		RETURN monto_a_texto(parte_entera) || ' PESOS';
	ELSIF parte_entero = 0 THEN
		RETURN monto_a_texto(parte_decimal) || ' CENTAVOS.';
	END IF;
	
	RETURN monto_a_texto(parte_entera) || ' PESOS CON ' || 
		monto_a_texto(parte_decimal) || ' CENTAVOS.';
END
$$ LANGUAGE plpgsql;


-- Punto 3 - Consigna C

CREATE OR REPLACE VIEW v_historial_cuotas AS
SELECT
	st.dni AS soc_dni,
	st.nombre AS soc_nombre,
	st.apellido AS soc_apellido,
	st.fecha_nac AS soc_fecha_nac,
	st.sexo AS soc_sexo,
	pc.total_adherentes AS cu_total_adherentes,
	pc.mes_anio AS cu_fecha_fact,
	pc.fecha_pago AS cu_fecha_pago,
	monto_a_texto_dec(pc.monto) AS cu_importe,
	monto_a_texto_dec(pc.recargo) AS cu_recargo,
	pc.estado AS cu_estado,
	b.monto AS monto_beca
FROM socios_titulares st
JOIN pagos_cuotas pc
ON st.nro_socio = pc.nro_socio
LEFT JOIN becas b
ON st.nro_socio = b.nro_socio


-- Punto 3 - Consigna D

CREATE OR REPLACE FUNCTION fn_calcular_recargo(
	socio_nro INT,
	pago_fecha DATE,
	OUT recargo DECIMAL,
	OUT coderr VARCHAR,
	OUT caderr VARCHAR
)
RETURNS RECORD AS
$$
DECLARE
	existe BOOL;
	monto DECIMAL;
	fecha_limite DATE;
	dias_recargo DECIMAL;
	intervalo INTERVAL;
BEGIN
	coderr := 0;
	caderr := '';
	existe := fn_existe_sociot(socio_nro);
	
	IF existe THEN
		RAISE EXCEPTION 'No existe socio titular con ese número de socio.';
	END IF;

	-- Tomamos la fecha limite para pagar.
	SELECT c.fecha_venc, c.importe INTO fecha_limite, monto
	FROM cuotas c
	WHERE c.nro_socio = socio_nro;
	
	-- Verificamos que fecha es mayor para obtener un
	-- resultado positivo.
	IF pago_fecha > fecha_limite THEN
		intervalo := AGE(pago_fecha, fecha_limite);
	ELSE
		intervalo := AGE(fecha_limite, pago_fecha);
	END IF;
	
	-- Calculamos la cantidad de dias que pasaron desde la
	-- fecha limite y la fecha de pago.
	dias_recargo := (EXTRACT(YEAR FROM intervalo) * 365) +
					(EXTRACT(MONTH FROM intervalo) * 30) +
					EXTRACT(DAY FROM intervalo);
					
	recargo := ROUND((monto * (dias_recargo / 100)), 2);
	
EXCEPTION
    WHEN OTHERS THEN
        coderr := 1;
		caderr := SQLERRM;	
END
$$ LANGUAGE plpgsql;


-- Transfiere la cuota a pagos_cuotas para almacenarla en
-- un historial.
CREATE OR REPLACE FUNCTION fn_persistir_cuota(
	socio_nro INT,
	pago_fecha DATE,
	OUT coderr VARCHAR,
	OUT caderr VARCHAR
)
RETURNS RECORD AS
$$
DECLARE
	existe BOOL;
BEGIN
	coderr := 0;
	caderr := '';
	existe := fn_existe_sociot(socio_nro);
	
	-- Verificamos si existe socio con el numero pasado por parametros.
	IF existe THEN
		RAISE EXCEPTION 'No existe socio titular con ese número de socio.';
	END IF;
	
	-- Insertamos los datos de la cuota en la tabla
	-- pagos_cuotas.
	INSERT INTO pagos_cuotas
	SELECT 
		c.nro_socio, 
		c.mes_anio,
		pago_fecha,
		c.total_adherentes,
		c.importe,
		(SELECT recargo FROM fn_calcular_recargo(socio_nro, pago_fecha)),
		'Pagada'
	FROM cuotas c
	WHERE c.nro_socio = socio_nro;
	
EXCEPTION
    WHEN OTHERS THEN
        coderr := 1;
		caderr := SQLERRM;	
END;
$$ LANGUAGE plpgsql;


-- TRIGGERS - REGLAS ACTIVAS

-- Punto 4 - Consigna A

CREATE OR REPLACE FUNCTION fn_socios_disjuntos()
RETURNS TRIGGER AS
$$
DECLARE
	tabla TEXT;
	cant INT;
BEGIN
	tabla := TG_TABLE_NAME;
	
	IF TG_OP = 'INSERT' THEN
		IF tabla = 'socios_titulares' THEN
			SELECT COUNT(*) INTO cant
			FROM socios_adherentes
			WHERE dni_pariente = NEW.dni;
			
			IF cant > 0 THEN
				RAISE EXCEPTION 'ERR::Existe un socio adherente con esos datos.';
			END IF;
		ELSIF tabla = 'socios_adherentes' THEN
			SELECT COUNT(*) INTO cant
			FROM socios_titulares
			WHERE dni = NEW.dni_pariente;
			
			IF cant > 0 THEN
				RAISE EXCEPTION 'ERR::Existe un socio titular con esos datos.';
			END IF;
		END IF;
	END IF;
	
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_socios_disjuntos_t
BEFORE INSERT OR UPDATE ON Socios_Titulares
	FOR EACH ROW EXECUTE PROCEDURE fn_socios_disjuntos();
	
CREATE TRIGGER tg_socios_disjuntos_a
BEFORE INSERT OR UPDATE ON Socios_Adherentes
	FOR EACH ROW EXECUTE PROCEDURE fn_socios_disjuntos();
	

-- Punto 4 - Consigna B

-- Funcion que solo actualiza la cantidad de cuotas adeudadas
-- y el total a pagar de todas las cuotas.
CREATE OR REPLACE FUNCTION fn_modificar_deuda(
	socio_nro INT,
	cant_cuotas INT,
	deuda_total DECIMAL,
	OUT coderr INT,
	OUT caderr VARCHAR
) RETURNS RECORD AS
$$
DECLARE
	existe BOOL;
BEGIN
	coderr = 0;
	caderr = '';
	existe := fn_existe_sociot(socio_nro);
	
	IF existe THEN
		RAISE EXCEPTION 'ERR::No existe un socio con el código ingresado.';
	END IF;

	UPDATE cuotas
	SET cuotas_adeudadas = cant_cuotas, deuda = deuda_total
	WHERE nro_socio = socio_nro;
	
EXCEPTION
    WHEN OTHERS THEN
        coderr := 1;
		caderr := SQLERRM;
END
$$ LANGUAGE plpgsql;


-- Calcula y actualiza la cantidad de cuotas y el total adeudado
-- de todas las cuotas vencidas.
CREATE OR REPLACE FUNCTION fn_acumular_deuda()
RETURNS TRIGGER AS
$$
DECLARE
	cant_cuotas_adeudadas INT;
	saldo_deudor DECIMAL;
BEGIN
	IF TG_OP = 'INSERT' THEN
		SELECT COUNT(*), SUM(pc.monto)
		INTO cant_cuotas_adeudadas, saldo_deudor
		FROM pagos_cuotas pc
		WHERE pc.nro_socio = NEW.nro_socio
			AND pc.estado = 'Vencida';
			
		PERFORM fn_modificar_deuda(
			NEW.nro_socio,
			cant_cuotas_adeudadas,
			saldo_deudor
		);
	END IF;
	
	RETURN NULL;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_acumular_deuda
AFTER INSERT ON pagos_cuotas
	FOR EACH ROW EXECUTE PROCEDURE fn_acumular_deuda();
	

-- Punto 4 - Consigna C

CREATE OR REPLACE FUNCTION fn_indice_socio_t()
RETURNS TRIGGER AS
$$
DECLARE
	cant INT;
	prox_indice INT := 900;
BEGIN
	IF TG_OP = 'INSERT' THEN
		IF NEW.nro_socio IS NULL THEN
			SELECT COUNT(*) INTO cant
			FROM socios_titulares;
		
			IF cant > 0 THEN
				SELECT MAX(nro_socio) + 1 INTO prox_indice
				FROM socios_titulares;
			END IF;
			
			NEW.nro_socio := prox_indice;
		ELSE
			SELECT COUNT(*) INTO cant
			FROM socios_titulares st
			WHERE st.nro_socio = NEW.nro_socio;
			
			IF cant > 0 THEN
				SELECT MAX(nro_socio) + 1 INTO prox_indice
				FROM socios_titulares;
				
				NEW.nro_socio := prox_indice;
			END IF;
		END IF;
	END IF;
	
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_nuevo_socio_t
BEFORE INSERT ON socios_titulares
	FOR EACH ROW EXECUTE PROCEDURE fn_indice_socio_t();
	
	
-- Punto 4 - Consigna E

CREATE TABLE direcciones_historial(
	nro_socio INT NOT NULL,
	calle VARCHAR(30) NOT NULL,
	numero INT NOT NULL,
	piso INT,
	dpto INT,
	fecha_act TIMESTAMP NOT NULL,
	usuario_mod VARCHAR(255) NOT NULL,
	FOREIGN KEY(nro_socio) REFERENCES Socios_Titulares(nro_socio)
)

CREATE OR REPLACE FUNCTION fn_guardar_dir_historial()
RETURNS TRIGGER AS
$$
DECLARE
	cant INT;
BEGIN
	SELECT COUNT(*) INTO cant
	FROM direcciones
	WHERE nro_socio = NEW.nro_socio;
	
	IF cant = 0 THEN
		RAISE EXCEPTION 'ERR::No existe dirección asociada a ese número de socio.';
	END IF;

	IF TG_OP = 'UPDATE' THEN
		INSERT INTO direcciones_historial
			SELECT
				d.nro_socio,
				d.calle,
				d.numero,
				d.piso,
				d.dpto,
				CURRENT_TIMESTAMP,
				CURRENT_USER
			FROM direcciones d
			WHERE nro_socio = NEW.nro_socio;
	END IF;
	
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_guardar_dir_historial
BEFORE UPDATE ON direcciones
	FOR EACH ROW EXECUTE PROCEDURE fn_guardar_dir_historial();
	

-- Punto 4 - Consigna F

CREATE OR REPLACE FUNCTION fn_dar_de_baja_sociot(
	socio_nro INT,
	baja_origen VARCHAR,
	baja_motivo VARCHAR,
	OUT coderr INT,
	OUT caderr VARCHAR
)
RETURNS RECORD AS
$$
DECLARE
	existe BOOL;
BEGIN
	coderr := 0;
	caderr := '';
	existe := fn_existe_sociot(socio_nro);
	
	IF NOT existe THEN
		RAISE EXCEPTION 'ERR::No existe socio titular con el número de socio %', socio_nro;
	END IF;
	
	UPDATE socios_periodos 
	SET fecha_hasta = CURRENT_DATE, motivo_baja = baja_motivo
	WHERE nro_socio = socio_nro
		AND fecha_hasta = NULL
		AND motivo_baja = NULL;
	
	UPDATE socios_titulares
	SET estado = baja_origen
	WHERE nro_socio = socio_nro;
	
EXCEPTION
    WHEN OTHERS THEN
        coderr := 1;
		caderr := SQLERRM;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fn_dar_de_alta_sociot(
	n_socio_nro INT,
	n_dni INT,
	n_nombre VARCHAR,
	n_apellido VARCHAR,
	n_fecha_nac DATE,
	n_sexo CHAR,
	n_fecha_insc DATE,
	n_cod_postal INT,
	n_estatura FLOAT,
	n_individual_familiar CHAR,
	n_tipo_socio VARCHAR,
	n_estado VARCHAR,
	OUT coderr INT,
	OUT caderr VARCHAR
)
RETURNS RECORD AS
$$
DECLARE
	existe BOOL;
BEGIN
	coderr := 0;
	caderr := '';
	existe := fn_existe_sociot(n_socio_nro);
	
	IF existe THEN
		RAISE EXCEPTION 'ERR::Ya existe un socio con el número de socio %', n_socio_nro;
	END IF;
	
	INSERT INTO socios_titulares
	VALUES(
		n_socio_nro,
		n_dni,
		n_nombre,
		n_apellido,
		n_fecha_nac,
		n_sexo,
		n_fecha_insc,
		n_cod_postal,
		n_estatura,
		n_individual_familiar,
		n_tipo_socio,
		n_estado
	);
EXCEPTION
    WHEN OTHERS THEN
        coderr := 1;
		caderr := SQLERRM;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fn_nuevo_periodo()
RETURNS TRIGGER AS
$$
BEGIN
	IF TG_OP = 'INSERT' THEN
		INSERT INTO socios_periodos
		VALUES(NEW.nro_socio, CURRENT_DATE, NULL, NULL);
	END IF;
	
	RETURN NULL;
END
$$ LANGUAGE plpgsql;

SELECT coderr, caderr FROM fn_dar_de_alta_sociot(NULL, 86439054, 'José', 'Ruiz', '1998-08-05', 'M', '2023-11-25', 1900, 1.75, 'I', 'Normal', 'Activo');

SELECT coderr, caderr FROM fn_dar_de_baja_sociot(26, 'Porque quise');

SELECT * FROM socios_titulares;
SELECT * FROM socios_periodos;

CREATE TRIGGER tg_nuevo_periodo
AFTER INSERT OR UPDATE ON socios_titulares
	FOR EACH ROW EXECUTE PROCEDURE fn_nuevo_periodo();
