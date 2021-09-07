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

/*
select top 1 FechaEjecucion 
from FactLog
order by FechaEjecucion DESC

select * from fact.Examen

--Actualizamos nuestra columna de ID_batch
update fact.Examen
set ID_Batch = newid()
go

--Insertamos el entry en factlog para el registro que ya existe
INSERT INTO FactLog VALUES ((SELECT ID_Batch from fact.Examen),(SELECT GETDATE() from fact.Examen),1)
go

SELECT MAX(FechaEjecucion) as FechaEjecucion
FROM dbo.FactLog

--Transformamos nuestra columna a UNIQUEID
ALTER TABLE Fact.Examen
ALTER COLUMN ID_Batch UNIQUEIDENTIFIER
GO*/

--Agregamos FK
ALTER TABLE Fact.Examen ADD CONSTRAINT [FK_IDBatch] FOREIGN KEY (ID_Batch) 
REFERENCES Factlog(ID_Batch)
go


/****** Object:  Table [staging].[Examen]    Script Date: 8/31/2020 6:34:39 PM ******/
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
	[PorcentajeDescuento] [decimal](6, 2) NULL,
	[FechaModificacionSource] DATETIME NULL,

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
       d.[PorcentajeDescuento],
	   R.FechaModificacion
FROM DBO.Examen R
     INNER JOIN DBO.Examen_Detalle RR ON(R.ID_Examen = RR.ID_Examen)
     INNER JOIN DBO.Materia EA ON(EA.ID_Materia = RR.ID_Materia)
     LEFT JOIN DBO.Descuento D ON(D.ID_Descuento = R.ID_Descuento)
WHERE ((FechaPrueba>?) OR (FechaModificacion>?))
go

--Script de SP para MERGE
CREATE PROCEDURE USP_MergeFact
as
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN
		DECLARE @NuevoGUIDInsert UNIQUEIDENTIFIER = NEWID(), @MaxFechaEjecucion DATETIME, @RowsAffected INT

		INSERT INTO FactLog ([ID_Batch], [FechaEjecucion], [NuevosRegistros])
		VALUES (@NuevoGUIDInsert,NULL,NULL)
		
		MERGE Fact.Examen AS T
		USING (
			SELECT [SK_Candidato], [SK_Carrera], [DateKey], [ID_Examen], [ID_Descuento], r.Descripcion AS DescripcionDescuento, [PorcentajeDescuento], [Precio], r.Nota as NotaTotal, [NotaArea], [NombreMateria], getdate() as FechaCreacion, 'ETL' as UsuarioCreacion, NULL as FechaModificacion, NULL as UsuarioModificacion, @NuevoGUIDINsert as ID_Batch, 'ssis' as ID_SourceSystem, r.FechaPrueba, r.FechaModificacionSource
			FROM STAGING.Examen R
				INNER JOIN Dimension.Candidato C ON(C.ID_Candidato = R.ID_Candidato and
													R.FechaPrueba BETWEEN c.FechaInicioValidez AND ISNULL(c.FechaFinValidez, '9999-12-31')) 
				INNER JOIN Dimension.Carrera CA ON(CA.ID_Carrera = R.ID_Carrera and
													R.FechaPrueba BETWEEN CA.FechaInicioValidez AND ISNULL(CA.FechaFinValidez, '9999-12-31')) 
				LEFT JOIN Dimension.Fecha F ON(CAST( (CAST(YEAR(R.FechaPrueba) AS VARCHAR(4)))+left('0'+CAST(MONTH(R.FechaPrueba) AS VARCHAR(4)),2)+left('0'+(CAST(DAY(R.FechaPrueba) AS VARCHAR(4))),2) AS INT)  = F.DateKey)
				) AS S ON (S.ID_examen = T.ID_Examen)

		WHEN NOT MATCHED BY TARGET THEN --No existe en Fact
		INSERT ([SK_Candidato], [SK_Carrera], [DateKey], [ID_Examen], [ID_Descuento], [DescripcionDescuento], [PorcentajeDescuento], [Precio], [NotaTotal], [NotaArea], [NombreMateria], [FechaCreacion], [UsuarioCreacion], [FechaModificacion], [UsuarioModificacion], [ID_Batch], [ID_SourceSystem], FechaPrueba, FechaModificacionSource)
		VALUES (S.[SK_Candidato], S.[SK_Carrera], S.[DateKey], S.[ID_Examen], S.[ID_Descuento], S.[DescripcionDescuento], S.[PorcentajeDescuento], S.[Precio], S.[NotaTotal], S.[NotaArea], S.[NombreMateria], S.[FechaCreacion], S.[UsuarioCreacion], S.[FechaModificacion], S.[UsuarioModificacion], S.[ID_Batch], S.[ID_SourceSystem], S.FechaPrueba, S.FechaModificacionSource);

		SET @RowsAffected =@@ROWCOUNT

		SELECT @MaxFechaEjecucion=MAX(MaxFechaEjecucion)
		FROM(
			SELECT MAX(FechaPrueba) as MaxFechaEjecucion
			FROM FACT.Examen
			UNION
			SELECT MAX(FechaModificacionSource)  as MaxFechaEjecucion
			FROM FACT.Examen
		)AS A

		UPDATE FactLog
		SET NuevosRegistros=@RowsAffected, FechaEjecucion = @MaxFechaEjecucion
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


--Test de SCD
USE Admisiones
go

INSERT INTO dbo.Examen ([ID_Candidato], [ID_Carrera], [ID_Descuento], [FechaPrueba], [Precio], [Nota])
values (1,1,1,getdate(),200.00,90)
go

insert into dbo.Examen_Detalle( [ID_Examen], [ID_Materia], [NotaArea])
values (@@IDENTITY,1,90)

select *
from	Admisiones_DWH.Fact.Examen e inner join
		Admisiones_DWH.Dimension.Candidato c on e.SK_Candidato = c.SK_Candidato
where	c.ID_Candidato = 1


