USE MASTER
GO

DECLARE @EliminarDB BIT = 1;
--Eliminar BDD si ya existe y si @EliminarDB = 1
if (((select COUNT(1) from sys.databases where name = 'Admisiones')>0) AND (@EliminarDB = 1))
begin
	EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'Admisiones'
	
	
	use [master];
	ALTER DATABASE [Admisiones] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE;
		
	DROP DATABASE [Admisiones]
	print 'Admisiones ha sido eliminada'
end

	
GO



CREATE DATABASE [Admisiones]
GO

use Admisiones
go

CREATE TABLE ColegioCandidato
(
	ID_Colegio INT IDENTITY PRIMARY KEY,
	Nombre VARCHAR(600) NOT NULL
)

INSERT INTO ColegioCandidato (Nombre)
VALUES ('Colegio URL')
GO

CREATE TABLE Diversificado
(
	ID_Diversificado INT IDENTITY PRIMARY KEY,
	Nombre VARCHAR(600) NOT NULL
)

INSERT INTO Diversificado(Nombre)
VALUES ('Bachiller en Ciencias y Letras')
GO

CREATE TABLE Candidato
(
	ID_Candidato INT IDENTITY PRIMARY KEY,
	ID_Colegio  INT REFERENCES ColegioCandidato(ID_Colegio),
	ID_Diversificado INT REFERENCES Diversificado(ID_Diversificado),
	Nombre VARCHAR(300) NOT NULL,
	Apellido VARCHAR(300) NOT NULL,
	Genero CHAR(1) NOT NULL,
	FechaNacimiento DATETIME
)

INSERT INTO Candidato(ID_Colegio,ID_Diversificado,Nombre,Apellido,Genero,FechaNacimiento)
VALUES (1,1,'Juan','Perez','M','1990-01-01')
GO

CREATE TABLE Facultad
(
	ID_Facultad INT IDENTITY PRIMARY KEY,
	Nombre VARCHAR(300) NOT NULL	
)


INSERT INTO Facultad(Nombre)
VALUES ('Ingeniería')
GO

CREATE TABLE Carrera
(
	ID_Carrera INT IDENTITY PRIMARY KEY,
	ID_Facultad INT REFERENCES Facultad(ID_Facultad),
	Nombre VARCHAR(300) NOT NULL	
)

INSERT INTO Carrera(ID_Facultad,Nombre)
VALUES (@@IDENTITY,'Ingenieria en Informatica y Sistemas')
GO



CREATE TABLE Descuento
(
	ID_Descuento INT IDENTITY PRIMARY KEY,
	Descripcion VARCHAR(300) NOT NULL,
	PorcentajeDescuento DECIMAL(6,2)
)

INSERT INTO Descuento(Descripcion,PorcentajeDescuento)
VALUES ('Descuento Expo Landivar',0.10)
GO


CREATE TABLE Examen
(
	ID_Examen INT IDENTITY PRIMARY KEY,
	ID_Candidato INT REFERENCES Candidato(ID_Candidato),
	ID_Carrera INT REFERENCES Carrera(ID_Carrera),	
	ID_Descuento INT REFERENCES Descuento(ID_Descuento),
	FechaPrueba DATETIME DEFAULT(GETDATE()),
	Precio DECIMAL(6,2),	
	Nota DECIMAL(5,2) 
)

INSERT INTO Examen(ID_Candidato,ID_Carrera,ID_Descuento,FechaPrueba,Precio,Nota)
VALUES (1,1,1,getdate(),200.00,80.00)
GO


CREATE TABLE Materia
(
	ID_Materia INT IDENTITY PRIMARY KEY,		
	NombreMateria VARCHAR(300) NOT NULL
)

INSERT INTO Materia(NombreMateria)
VALUES ('Matematicas')
GO


CREATE TABLE Examen_detalle
(
	ID_ExamenDetalle INT IDENTITY PRIMARY KEY,
	ID_Examen INT REFERENCES Examen(ID_Examen),	
	ID_Materia INT REFERENCES Materia(ID_Materia),	
	NotaArea DECIMAL(5,2)
)

INSERT INTO Examen_detalle(ID_Examen,ID_Materia,NotaArea)
VALUES (1,1,80.00)
GO

select * 
from Candidato as c inner join
ColegioCandidato as co on c.ID_Colegio=co.ID_Colegio inner join
Diversificado as d on d.ID_Diversificado = c.ID_Diversificado inner join
Examen as e on e.ID_Candidato = c.ID_Candidato





