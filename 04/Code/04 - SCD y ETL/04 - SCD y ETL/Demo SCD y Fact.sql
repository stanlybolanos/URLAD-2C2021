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
from Dimension.Candidato AS C
INNER JOIN FACT.Examen AS E ON C.SK_Candidato = E.SK_Candidato
where ID_Candidato = 192

update Admisiones.dbo.Candidato
set ID_Colegio = 2
where ID_Candidato=192

SELECT *
FROM Dimension.Candidato
where ID_Candidato=192


USE [Admisiones_DWH]
GO


--Ultima Fecha del FactLog
SELECT ISNULL(MAX(FechaEjecucion),'1900-01-01') AS UltimaFecha
FROM FactLog


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
