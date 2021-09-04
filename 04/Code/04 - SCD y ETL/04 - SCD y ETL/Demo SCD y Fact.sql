--Resultados

--Carga Dimensiones

select top 100 *
from Dimension.Fecha

select top 100 *
from Dimension.Carrera

select top 100 *
from Dimension.Candidato

--Actualizamos FechaInicioValidez para carga inicial, dado que tenemos mucha informacion historica

select min(fechaPrueba) from Admisiones.dbo.Examen

update Dimension.Carrera
set FechaInicioValidez = '2000-01-01'

update Dimension.Candidato
set FechaInicioValidez = '2000-01-01'

--Candidato que actualizaremos
select *
from Dimension.Candidato
where ID_Candidato = 192

update Admisiones.dbo.Candidato
set ID_Colegio = 1
where ID_Candidato=192

--Agregamos fecha de modificacion

ALTER TABLE Admisiones.dbo.Examen ADD FechaModificacion DATETIME


USE [Admisiones_DWH]
GO

--Creamos tabla para log de fact batches
CREATE TABLE FactLog
(
	ID_Batch UNIQUEIDENTIFIER DEFAULT(NEWID()),
	FechaEjecucion DATETIME DEFAULT(GETDATE()),
	NuevosRegistros INT,
	CONSTRAINT [PK_FactLog] PRIMARY KEY
	(
		ID_Batch
	)
)
GO

--Ultima Fecha del FactLog
SELECT ISNULL(MAX(FechaEjecucion),'1900-01-01') AS UltimaFecha
FROM FactLog


--Creamos schema de transicion (staging)
create schema [staging]
go

DROP TABLE IF EXISTS [staging].[Examen]
GO

CREATE TABLE [staging].[Examen](
	[ID_Examen] [int] NOT NULL,
	[ID_Candidato] [int] NULL,
	[ID_Carrera] [int] NULL,
	[ID_Descuento] [int] NULL,
	[FechaPrueba] [datetime] NULL,
	[Precio] [decimal](6, 2) NULL,
	[Nota] [decimal](5, 2) NULL,
	[ID_ExamenDetalle] [int] NOT NULL,
	[NotaArea] [decimal](5, 2) NULL,
	[ID_Materia] [int] NOT NULL,
	[NombreMateria] [varchar](300) NOT NULL,
	[Descripcion] [varchar](300)  NULL,
	[PorcentajeDescuento] [decimal](6, 2) NULL
) ON [PRIMARY]
GO

--Query para llenar datos en Staging
SELECT r.ID_Examen, 
       r.ID_Candidato, 
       r.ID_Carrera, 
       r.ID_Descuento, 
	   R.FechaPrueba,
       r.Precio, 
       r.Nota, 
       rr.[ID_ExamenDetalle], 
       rr.[NotaArea], 
	   ea.ID_Materia,
       ea.NombreMateria,
       d.[Descripcion], 
       d.[PorcentajeDescuento]
FROM Admisiones.DBO.Examen R
     INNER JOIN Admisiones.DBO.Examen_Detalle RR ON(R.ID_Examen = RR.ID_Examen)
     INNER JOIN Admisiones.DBO.Materia EA ON(EA.ID_Materia = RR.ID_Materia)
     LEFT JOIN Admisiones.DBO.Descuento D ON(D.ID_Descuento = R.ID_Descuento)
--WHERE ((FechaPrueba>?) OR (FechaModificacion>?))
go

--Script de SP para MERGE
ALTER PROCEDURE USP_MergeFact 
as
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN
		DECLARE @NuevoGUIDInsert UNIQUEIDENTIFIER = NEWID()

		INSERT INTO FactLog
		VALUES (@NuevoGUIDInsert,getdate(),NULL)
		
		MERGE Fact.Examen AS T
		USING (
			SELECT [SK_Candidato], [SK_Carrera], [DateKey], [ID_Examen], [ID_Descuento], r.Descripcion AS DescripcionDescuento, [PorcentajeDescuento], [Precio], r.Nota as NotaTotal, [NotaArea], [NombreMateria], getdate() as FechaCreacion, 'ETL' as UsuarioCreacion, NULL as FechaModificacion, NULL as UsuarioModificacion, @NuevoGUIDINsert as ID_Batch, 'ssis' as ID_SourceSystem
			FROM STAGING.Examen R
				INNER JOIN Dimension.Candidato C ON(C.ID_Candidato = R.ID_Candidato and
													R.FechaPrueba BETWEEN c.FechaInicioValidez AND ISNULL(c.FechaFinValidez, '9999-12-31')) 
				INNER JOIN Dimension.Carrera CA ON(CA.ID_Carrera = R.ID_Carrera and
													R.FechaPrueba BETWEEN CA.FechaInicioValidez AND ISNULL(CA.FechaFinValidez, '9999-12-31')) 
				LEFT JOIN Dimension.Fecha F ON(CAST( (CAST(YEAR(R.FechaPrueba) AS VARCHAR(4)))+left('0'+CAST(MONTH(R.FechaPrueba) AS VARCHAR(4)),2)+left('0'+(CAST(DAY(R.FechaPrueba) AS VARCHAR(4))),2) AS INT)  = F.DateKey)
				) AS S ON (S.ID_examen = T.ID_Examen)

		WHEN NOT MATCHED BY TARGET THEN --No existe en Fact
		INSERT ([SK_Candidato], [SK_Carrera], [DateKey], [ID_Examen], [ID_Descuento], [DescripcionDescuento], [PorcentajeDescuento], [Precio], [NotaTotal], [NotaArea], [NombreMateria], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion], [ID_Batch], [ID_SourceSystem])
		VALUES (S.[SK_Candidato], S.[SK_Carrera], S.[DateKey], S.[ID_Examen], S.[ID_Descuento], S.[DescripcionDescuento], S.[PorcentajeDescuento], S.[Precio], S.[NotaTotal], S.[NotaArea], S.[NombreMateria], S.[FechaCreacion], S.[UsuarioCreacion], S.[FechaModificacion], S.[UsuarioModificacion], S.[ID_Batch], S.[ID_SourceSystem]);

		UPDATE FactLog
		SET NuevosRegistros=@@ROWCOUNT
		WHERE ID_Batch = @NuevoGUIDInsert

		COMMIT
	END TRY
	BEGIN CATCH
		SELECT @@ERROR,'Ocurrio el siguiente error: '+ERROR_MESSAGE()
		IF (@@TRANCOUNT>0)
			ROLLBACK;
	END CATCH

END
go

--miremos resultados


select * 
from FactLog

truncate table fact.examen
truncate table factlog

select *
from staging.Examen

--Ahora ingresaremos un nuevo examen para candidato 192

INSERT INTO  Admisiones.dbo.[Examen]
([ID_Candidato], [ID_Carrera], [ID_Descuento], [FechaPrueba], [Precio], [Nota], [FechaModificacion])
values
(192,1,1,getdate(),400.00,100,null)


INSERT INTO Admisiones.DBO.Examen_detalle
([ID_Examen], [ID_Materia], [NotaArea])
VALUES(@@IDENTITY,1,100)


select *
from fact.Examen f inner join
Dimension.Candidato c on f.SK_Candidato = c.SK_Candidato
WHERE id_candidato = 192
