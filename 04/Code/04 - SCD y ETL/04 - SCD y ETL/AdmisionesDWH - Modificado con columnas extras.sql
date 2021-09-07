USE master
GO


DECLARE @EliminarDB BIT = 1;
--Eliminar BDD si ya existe y si @EliminarDB = 1
if (((select COUNT(1) from sys.databases where name = 'Admisiones_DWH')>0) AND (@EliminarDB = 1))
begin
	EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'Admisiones_DWH'
	
	
	use [master];
	ALTER DATABASE [Admisiones_DWH] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE;
		
	DROP DATABASE [Admisiones_DWH]
	print 'Admisiones_DWH ha sido eliminada'
end


CREATE DATABASE Admisiones_DWH
GO

USE Admisiones_DWH
GO

--Enteros
 --User Defined Type _ Surrogate Key
	--Tipo para SK entero: Surrogate Key
	CREATE TYPE [UDT_SK] FROM INT
	GO

	--Tipo para PK entero
	CREATE TYPE [UDT_PK] FROM INT
	GO

--Cadenas

	--Tipo para cadenas largas
	CREATE TYPE [UDT_VarcharLargo] FROM VARCHAR(600)
	GO

	--Tipo para cadenas medianas
	CREATE TYPE [UDT_VarcharMediano] FROM VARCHAR(300)
	GO

	--Tipo para cadenas cortas
	CREATE TYPE [UDT_VarcharCorto] FROM VARCHAR(100)
	GO

	--Tipo para cadenas cortas
	CREATE TYPE [UDT_UnCaracter] FROM CHAR(1)
	GO

--Decimal

	--Tipo Decimal 6,2
	CREATE TYPE [UDT_Decimal6.2] FROM DECIMAL(6,2)
	GO

	--Tipo Decimal 5,2
	CREATE TYPE [UDT_Decimal5.2] FROM DECIMAL(5,2)
	GO

--Fechas
	CREATE TYPE [UDT_DateTime] FROM DATETIME
	GO

--Schemas para separar objetos
	CREATE SCHEMA Fact
	GO

	CREATE SCHEMA Dimension
	GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dimension].[Candidato](
	[SK_Candidato] [dbo].[UDT_SK] IDENTITY(1,1) NOT NULL,
	[ID_Candidato] [dbo].[UDT_PK] NULL,
	[ID_Colegio] [dbo].[UDT_PK] NULL,
	[ID_Diversificado] [dbo].[UDT_PK] NULL,
	[NombreCandidato] [dbo].[UDT_VarcharCorto] NULL,
	[ApellidoCandidato] [dbo].[UDT_VarcharCorto] NULL,
	[Genero] [dbo].[UDT_UnCaracter] NULL,
	[FechaNacimiento] [dbo].[UDT_DateTime] NULL,
	[NombreColegio] [dbo].[UDT_VarcharLargo] NULL,
	[NombreDiversificado] [dbo].[UDT_VarcharLargo] NULL,
	--Columnas SCD Tipo 2
	[FechaInicioValidez] DATETIME NOT NULL DEFAULT(GETDATE()),
	[FechaFinValidez] DATETIME NULL,
	--Columnas Auditoria
	FechaCreacion DATETIME NULL DEFAULT(GETDATE()),
	UsuarioCreacion NVARCHAR(100) NULL DEFAULT(SUSER_NAME()),
	FechaModificacion DATETIME NULL,
	UsuarioModificacion NVARCHAR(100) NULL,
	--Columnas Linaje
	ID_Batch UNIQUEIDENTIFIER NULL,
	ID_SourceSystem VARCHAR(20)	
PRIMARY KEY CLUSTERED 
(
	[SK_Candidato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Dimension].[Carrera]    Script Date: 8/31/2020 5:11:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dimension].[Carrera](
	[SK_Carrera] [dbo].[UDT_SK] IDENTITY(1,1) NOT NULL,
	[ID_Carrera] [dbo].[UDT_PK] NULL,
	[ID_Facultad] [dbo].[UDT_PK] NULL,
	[NombreCarrera] [dbo].[UDT_VarcharMediano] NULL,
	[NombreFacultad] [dbo].[UDT_VarcharMediano] NULL,
	--Columnas SCD Tipo 2
	[FechaInicioValidez] DATETIME NOT NULL DEFAULT(GETDATE()),
	[FechaFinValidez] DATETIME NULL,
	--Columnas Auditoria
	FechaCreacion DATETIME NOT NULL DEFAULT(GETDATE()),
	UsuarioCreacion NVARCHAR(100) NOT NULL DEFAULT(SUSER_NAME()),
	FechaModificacion DATETIME NULL,
	UsuarioModificacion NVARCHAR(100) NULL,
	--Columnas Linaje
	ID_Batch UNIQUEIDENTIFIER NULL,
	ID_SourceSystem VARCHAR(50)
	
PRIMARY KEY CLUSTERED 
(
	[SK_Carrera] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Dimension].[Fecha]    Script Date: 8/31/2020 5:11:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dimension].[Fecha](
	[DateKey] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[Day] [tinyint] NOT NULL,
	[DaySuffix] [char](2) NOT NULL,
	[Weekday] [tinyint] NOT NULL,
	[WeekDayName] [varchar](10) NOT NULL,
	[WeekDayName_Short] [char](3) NOT NULL,
	[WeekDayName_FirstLetter] [char](1) NOT NULL,
	[DOWInMonth] [tinyint] NOT NULL,
	[DayOfYear] [smallint] NOT NULL,
	[WeekOfMonth] [tinyint] NOT NULL,
	[WeekOfYear] [tinyint] NOT NULL,
	[Month] [tinyint] NOT NULL,
	[MonthName] [varchar](10) NOT NULL,
	[MonthName_Short] [char](3) NOT NULL,
	[MonthName_FirstLetter] [char](1) NOT NULL,
	[Quarter] [tinyint] NOT NULL,
	[QuarterName] [varchar](6) NOT NULL,
	[Year] [int] NOT NULL,
	[MMYYYY] [char](6) NOT NULL,
	[MonthYear] [char](7) NOT NULL,
	[IsWeekend] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Fact].[Examen]    Script Date: 8/31/2020 5:11:56 PM ******/
DROP TABLE IF EXISTS FACT.Examen 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Fact].[Examen](
	[SK_Examen] [dbo].[UDT_SK] IDENTITY(1,1) NOT NULL,
	[SK_Candidato] [dbo].[UDT_SK] NULL,
	[SK_Carrera] [dbo].[UDT_SK] NULL,
	[DateKey] [int] NULL,
	[ID_Examen] [dbo].[UDT_PK] NULL,
	[ID_Descuento] [dbo].[UDT_PK] NULL,
	[DescripcionDescuento] [dbo].[UDT_VarcharMediano] NULL,
	[PorcentajeDescuento] [dbo].[UDT_Decimal6.2] NULL,
	[Precio] [dbo].[UDT_Decimal6.2] NULL,
	[NotaTotal] [dbo].[UDT_Decimal5.2] NULL,
	[NotaArea] [dbo].[UDT_Decimal5.2] NULL,
	[NombreMateria] [dbo].[UDT_VarcharMediano] NULL,
	[FechaPrueba] DATETIME NOT NULL,
	[FechaModificacionSource] DATETIME NULL,
	--Columnas Auditoria
	FechaCreacion DATETIME NOT NULL DEFAULT(GETDATE()),
	UsuarioCreacion VARCHAR(100) NOT NULL DEFAULT(SUSER_NAME()),
	FechaModificacion DATETIME NULL,
	UsuarioModificacion VARCHAR(100) NULL,
	--Columnas Linaje
	ID_Batch UNIQUEIDENTIFIER NULL,
	ID_SourceSystem VARCHAR(50)
PRIMARY KEY CLUSTERED 
(
	[SK_Examen] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Fact].[Examen]  WITH CHECK ADD FOREIGN KEY([DateKey])
REFERENCES [Dimension].[Fecha] ([DateKey])
GO
ALTER TABLE [Fact].[Examen]  WITH CHECK ADD FOREIGN KEY([SK_Candidato])
REFERENCES [Dimension].[Candidato] ([SK_Candidato])
GO
ALTER TABLE [Fact].[Examen]  WITH CHECK ADD FOREIGN KEY([SK_Carrera])
REFERENCES [Dimension].[Carrera] ([SK_Carrera])
GO
EXEC sys.sp_addextendedproperty @name=N'Desnormalizacion', @value=N'La dimension candidato provee una vista desnormalizada de las tablas origen Candidato, Diversificado y Colegio, dejando todo en una única dimensión para un modelo estrella' , @level0type=N'SCHEMA',@level0name=N'Dimension', @level1type=N'TABLE',@level1name=N'Candidato'
GO
EXEC sys.sp_addextendedproperty @name=N'Desnormalizacion', @value=N'La dimension carrera provee una vista desnormalizada de las tablas origen Facultad y Carrera en una sola dimensión para un modelo estrella' , @level0type=N'SCHEMA',@level0name=N'Dimension', @level1type=N'TABLE',@level1name=N'Carrera'
GO
EXEC sys.sp_addextendedproperty @name=N'Desnormalizacion', @value=N'La dimension fecha es generada de forma automatica y no tiene datos origen, se puede regenerar enviando un rango de fechas al stored procedure USP_FillDimDate' , @level0type=N'SCHEMA',@level0name=N'Dimension', @level1type=N'TABLE',@level1name=N'Fecha'
GO

INSERT INTO Dimension.Carrera
	(ID_Carrera, 
	 ID_Facultad, 
	 NombreCarrera, 
	 NombreFacultad,
	 [FechaInicioValidez],
	 [FechaFinValidez],
	 FechaCreacion,
	 UsuarioCreacion,
	 FechaModificacion,
	 UsuarioModificacion,
	 ID_Batch,
	 ID_SourceSystem
	)
	SELECT C.ID_Carrera, 
			F.ID_Facultad, 
			C.Nombre as NombreCarrera, 
			F.Nombre as NombreFacultad
			  --Columnas Auditoria
			  ,GETDATE() AS FechaCreacion
			  ,CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioCreacion
			  ,GETDATE() AS FechaModificacion
			  ,CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioModificacion
			  --Columnas Linaje
			  ,'1-ETL' as ID_Batch
			  ,'Admisiones' as ID_SourceSystem
			  ,CAST('2020-01-01' AS DATETIME) as FechaInicioValidez

	FROM Admisiones.dbo.Facultad F
		INNER JOIN Admisiones.dbo.Carrera C ON(C.ID_Facultad = F.ID_Facultad);
		
	--DimCandidato
	INSERT INTO Dimension.Candidato
	([ID_Candidato], 
	 [ID_Colegio], 
	 [ID_Diversificado], 
	 [NombreCandidato], 
	 [ApellidoCandidato], 
	 [Genero], 
	 [FechaNacimiento], 
	 [NombreColegio], 
	 [NombreDiversificado],
	 [FechaInicioValidez],
	 [FechaFinValidez],
	 FechaCreacion,
	 UsuarioCreacion,
	 FechaModificacion,
	 UsuarioModificacion,
	 ID_Batch,
	 ID_SourceSystem
	)
	SELECT C.ID_Candidato, 
			CC.ID_Colegio, 
			D.ID_Diversificado, 
			C.Nombre as NombreCandidato, 
			C.Apellido as ApellidoCandidato, 
			C.Genero, 
			C.FechaNacimiento, 
			CC.Nombre as NombreColegio, 
			D.Nombre as NombreDiversificado
			  --Columnas Auditoria
			  ,GETDATE() AS FechaCreacion
			  ,CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioCreacion
			  ,GETDATE() AS FechaModificacion
			  ,CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioModificacion
			  --Columnas Linaje
			  ,'1-ETL' as ID_Batch
			  ,'Admisiones' as ID_SourceSystem
			  ,CAST('2020-01-01' AS DATETIME) as FechaInicioValidez
	FROM Admisiones.DBO.Candidato C
		INNER JOIN Admisiones.DBO.ColegioCandidato CC ON(C.ID_Colegio = CC.ID_Colegio)
		INNER JOIN Admisiones.DBO.Diversificado D ON(C.ID_Diversificado = D.ID_Diversificado);
	GO

	--Dimension Fecha (SP que llena la dimension)
	
	CREATE PROCEDURE USP_FillDimDate @CurrentDate DATE = '2016-01-01', 
									 @EndDate     DATE = '2022-12-31'
	AS
		BEGIN
			SET NOCOUNT ON;
			WHILE @CurrentDate < @EndDate
				BEGIN
					IF NOT EXISTS (SELECT 1 FROM Dimension.Fecha WHERE DATE = @CurrentDate)
					INSERT INTO Dimension.Fecha
					([DateKey], 
					 [Date], 
					 [Day], 
					 [DaySuffix], 
					 [Weekday], 
					 [WeekDayName], 
					 [WeekDayName_Short], 
					 [WeekDayName_FirstLetter], 
					 [DOWInMonth], 
					 [DayOfYear], 
					 [WeekOfMonth], 
					 [WeekOfYear], 
					 [Month], 
					 [MonthName], 
					 [MonthName_Short], 
					 [MonthName_FirstLetter], 
					 [Quarter], 
					 [QuarterName], 
					 [Year], 
					 [MMYYYY], 
					 [MonthYear], 
					 [IsWeekend]
					)
						   SELECT DateKey = YEAR(@CurrentDate) * 10000 + MONTH(@CurrentDate) * 100 + DAY(@CurrentDate), 
								  DATE = @CurrentDate, 
								  Day = DAY(@CurrentDate), 
								  [DaySuffix] = CASE
													WHEN DAY(@CurrentDate) = 1
														 OR DAY(@CurrentDate) = 21
														 OR DAY(@CurrentDate) = 31
													THEN 'st'
													WHEN DAY(@CurrentDate) = 2
														 OR DAY(@CurrentDate) = 22
													THEN 'nd'
													WHEN DAY(@CurrentDate) = 3
														 OR DAY(@CurrentDate) = 23
													THEN 'rd'
													ELSE 'th'
												END, 
								  WEEKDAY = DATEPART(dw, @CurrentDate), 
								  WeekDayName = DATENAME(dw, @CurrentDate), 
								  WeekDayName_Short = UPPER(LEFT(DATENAME(dw, @CurrentDate), 3)), 
								  WeekDayName_FirstLetter = LEFT(DATENAME(dw, @CurrentDate), 1), 
								  [DOWInMonth] = DAY(@CurrentDate), 
								  [DayOfYear] = DATENAME(dy, @CurrentDate), 
								  [WeekOfMonth] = DATEPART(WEEK, @CurrentDate) - DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM, 0, @CurrentDate), 0)) + 1, 
								  [WeekOfYear] = DATEPART(wk, @CurrentDate), 
								  [Month] = MONTH(@CurrentDate), 
								  [MonthName] = DATENAME(mm, @CurrentDate), 
								  [MonthName_Short] = UPPER(LEFT(DATENAME(mm, @CurrentDate), 3)), 
								  [MonthName_FirstLetter] = LEFT(DATENAME(mm, @CurrentDate), 1), 
								  [Quarter] = DATEPART(q, @CurrentDate), 
								  [QuarterName] = CASE
													  WHEN DATENAME(qq, @CurrentDate) = 1
													  THEN 'First'
													  WHEN DATENAME(qq, @CurrentDate) = 2
													  THEN 'second'
													  WHEN DATENAME(qq, @CurrentDate) = 3
													  THEN 'third'
													  WHEN DATENAME(qq, @CurrentDate) = 4
													  THEN 'fourth'
												  END, 
								  [Year] = YEAR(@CurrentDate), 
								  [MMYYYY] = RIGHT('0' + CAST(MONTH(@CurrentDate) AS VARCHAR(2)), 2) + CAST(YEAR(@CurrentDate) AS VARCHAR(4)), 
								  [MonthYear] = CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + UPPER(LEFT(DATENAME(mm, @CurrentDate), 3)), 
								  [IsWeekend] = CASE
													WHEN DATENAME(dw, @CurrentDate) = 'Sunday'
														 OR DATENAME(dw, @CurrentDate) = 'Saturday'
													THEN 1
													ELSE 0
												END     ;
					SET @CurrentDate = DATEADD(DD, 1, @CurrentDate);
				END;
		END;
	go

	exec USP_FillDimDate @CurrentDate = '2016-01-01', 
						 @EndDate     = '2022-12-31'

	--Fact
	INSERT INTO [Fact].[Examen]
	([SK_Candidato], 
	 [SK_Carrera], 
	 [DateKey], 
	 [ID_Examen], 
	 [ID_Descuento], 	
	 [DescripcionDescuento], 
	 [PorcentajeDescuento], 
	 [Precio], 
	 [NotaTotal], 
	 [NotaArea], 
	 [NombreMateria],
	 FechaCreacion,
	 UsuarioCreacion,
	 FechaModificacion,
	 UsuarioModificacion,	 
	 ID_Batch,
	 ID_SourceSystem 
	)
	SELECT SK_Candidato, 
			SK_Carrera, 
			CAST( (CAST(YEAR(R.FechaPrueba) AS VARCHAR(4)))+left('0'+CAST(MONTH(R.FechaPrueba) AS VARCHAR(4)),2)+left('0'+(CAST(DAY(R.FechaPrueba) AS VARCHAR(4))),2) AS INT)  as DateKey, 
			R.ID_Examen, 
			R.ID_Descuento, 			
			D.Descripcion, 
			D.PorcentajeDescuento, 
			R.Precio, 
			R.Nota,
			RR.NotaArea, 
			EA.NombreMateria
			--Columnas Auditoria
	  ,GETDATE() AS FechaCreacion
	  ,SUSER_NAME() AS UsuarioCreacion
	  ,NULL AS FechaModificacion
	  ,NULL AS UsuarioModificacion
	  --Columnas Linaje
	  ,NULL as ID_Batch
	  ,'Admisiones' as ID_SourceSystem
	FROM Admisiones.DBO.Examen R
		INNER JOIN Admisiones.DBO.Examen_Detalle RR ON(R.ID_Examen = RR.ID_Examen)
		INNER JOIN Admisiones.DBO.Materia EA ON(EA.ID_Materia = RR.ID_Materia)
		INNER JOIN Admisiones.DBO.Descuento D ON(D.ID_Descuento = R.ID_Descuento)
		INNER JOIN Dimension.Candidato C ON(C.ID_Candidato = R.ID_Candidato and
											R.FechaPrueba BETWEEN c.FechaInicioValidez AND ISNULL(c.FechaFinValidez, '9999-12-31')) 
		INNER JOIN Dimension.Carrera CA ON(CA.ID_Carrera = R.ID_Carrera and
											R.FechaPrueba BETWEEN CA.FechaInicioValidez AND ISNULL(CA.FechaFinValidez, '9999-12-31')) 
		LEFT JOIN Dimension.Fecha F ON(CAST( (CAST(YEAR(R.FechaPrueba) AS VARCHAR(4)))+left('0'+CAST(MONTH(R.FechaPrueba) AS VARCHAR(4)),2)+left('0'+(CAST(DAY(R.FechaPrueba) AS VARCHAR(4))),2) AS INT)  = F.DateKey);


select * 
FROM	Fact.Examen E INNER JOIN
		Dimension.Candidato c  on e.SK_Candidato = c.SK_Candidato inner join
		Dimension.Carrera ca on e.SK_Carrera = ca.SK_Carrera inner join
		Dimension.Fecha f on e.DateKey = f.DateKey
WHERE ID_Candidato = 1

Select *
from dimension.Carrera

select *
from Dimension.Candidato
where ID_Candidato = 1


select *
from Admisiones.dbo.Candidato

update 
Admisiones.dbo.Candidato
set ID_Colegio=2
where ID_Candidato=1


