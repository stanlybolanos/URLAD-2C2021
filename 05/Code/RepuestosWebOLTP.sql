CREATE DATABASE RepuestosWeb
go

USE RepuestosWeb
go

exec sp_changedbowner 'sa'
go

CREATE TABLE Linea 
(
	ID_Linea  INT IDENTITY PRIMARY KEY,
	Nombre VARCHAR(100),
	Descripcion VARCHAR(500)
)

INSERT INTO Linea (nombre,descripcion) values ('Usados','Repuestos usados')
GO

CREATE TABLE Categoria
(
	ID_Categoria  INT IDENTITY PRIMARY KEY,
	ID_Linea INT REFERENCES Linea (ID_Linea),
	Nombre VARCHAR(100),
	Descripcion VARCHAR(500)
)

INSERT INTO Categoria (ID_Linea,Nombre,Descripcion) VALUES (@@IDENTITY,'Llantas','Llantas de vehiculos')
GO

CREATE TABLE Partes
(
	ID_Partes INT IDENTITY PRIMARY KEY,
	ID_Categoria INT NOT NULL REFERENCES Categoria(ID_Categoria),
	Nombre VARCHAR(100) NOT NULL,
	Descripcion VARCHAR(500) NULL,
	Precio Decimal(12,2) NOT NULL
)

INSERT INTO Partes (ID_Categoria,Nombre,Descripcion,Precio) values(@@IDENTITY,'Llantas todo terreno','Llantas para caminos todo terreno',100.00)
go

CREATE TABLE Clientes
(
	ID_Cliente  INT IDENTITY PRIMARY KEY,
	PrimerNombre VARCHAR(100) NOT NULL,
	SegundoNombre VARCHAR(100) NOT NULL,
	PrimerApellido VARCHAR(100) NOT NULL,
	SegundoApellido VARCHAR(100) NOT NULL,
	Genero CHAR(1) NOT NULL,
	Correo_Electronico VARCHAR(100) NULL,
	FechaNacimiento DATETIME
)

INSERT INTO Clientes (PrimerNombre,SegundoNombre,PrimerApellido,SegundoApellido,Genero,Correo_Electronico,FechaNacimiento) 
values ('Juan','Pablo','Perez','Lopez','M','JanPablo@Correo.com.gt','01/01/1980')

CREATE TABLE Pais
(
	ID_Pais  INT IDENTITY PRIMARY KEY,
	Nombre	VARCHAR(100) NOT NULL
)

INSERT INTO Pais (Nombre) values ('Guatemala')
go

CREATE TABLE Region
(
	ID_Region  INT IDENTITY PRIMARY KEY,
	ID_Pais INT NOT NULL REFERENCES Pais(ID_Pais),
	Nombre VARCHAR(100) NOT NULL
)

INSERT INTO Region (ID_Pais,Nombre) values (@@IDENTITY,'Occidente')

CREATE TABLE Ciudad
(
	ID_Ciudad  INT IDENTITY PRIMARY KEY,
	ID_Region INT NOT NULL REFERENCES Region(ID_Region),
	Nombre VARCHAR(100) NOT NULL,
	CodigoPostal INT NOT NULL
)

INSERT INTO Ciudad (ID_region,Nombre,CodigoPostal) values (@@IDENTITY,'Quetzaltenango', 9001)
go

CREATE TABLE StatusOrden
(
	ID_StatusOrden INT IDENTITY PRIMARY KEY,
	NombreStatus VARCHAR(100) NOT NULL
)

INSERT INTO StatusOrden (NombreStatus) values ('Ingresada')

CREATE TABLE Orden
(
	ID_Orden INT IDENTITY PRIMARY KEY,
	ID_Cliente INT NOT NULL REFERENCES Clientes(ID_Cliente),
	ID_Ciudad INT NOT NULL REFERENCES Ciudad(ID_Ciudad),
	ID_StatusOrden INT NOT NULL REFERENCES StatusOrden(ID_StatusOrden),
	Total_Orden DECIMAL(12,2) NOT NULL,
	Fecha_Orden DATETIME NOT NULL
)

INSERT INTO Orden (ID_Cliente,ID_Ciudad,ID_StatusOrden,Total_Orden,Fecha_Orden) values(1,1,1,180.00,getdate())
go

CREATE TABLE Descuento
(
	ID_Descuento INT IDENTITY PRIMARY KEY,
	NombreDescuento VARCHAR(200) NOT NULL,
	PorcentajeDescuento DECIMAL(2,2) NOT NULL
)

insert into Descuento (NombreDescuento,PorcentajeDescuento) values('Promocion de Invierno',0.10) --10% de descuento
go

CREATE TABLE Detalle_orden
(
	ID_DetalleOrden INT IDENTITY PRIMARY KEY,
	ID_Orden INT REFERENCES Orden(ID_orden),
	ID_Partes INT REFERENCES Partes(ID_Partes),
	ID_Descuento INT REFERENCES Descuento(ID_Descuento),
	Cantidad INT NOT NULL
)

insert into Detalle_orden (ID_Orden,ID_Partes,ID_Descuento,Cantidad)
values (1,1,1,2)
go