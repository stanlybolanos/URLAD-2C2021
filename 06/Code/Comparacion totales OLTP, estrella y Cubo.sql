select  DATEPART(Year,e.FechaPrueba) as Anio, Sum(E.Precio) as TotalIngresos
from	Admisiones.dbo.Examen e INNER JOIN
		Admisiones.dbo.Carrera c on E.ID_Carrera = C.ID_Carrera
where  C.Nombre = 'Ingenieria en Informatica y Sistemas'
group by DATEPART(Year,e.FechaPrueba)

select  Sum(E.Precio)  as TotalIngresos
from	Admisiones.dbo.Examen e INNER JOIN
		Admisiones.dbo.Carrera c on E.ID_Carrera = C.ID_Carrera
where  C.Nombre = 'Ingenieria en Informatica y Sistemas'


select  DATEPART(Year,e.FechaPrueba) as Anio, Sum(E.Precio)  as TotalIngresos
from	Admisiones_DWH.Fact.Examen e inner join
		Admisiones_DWH.Dimension.Carrera c on e.SK_Carrera = c.SK_Carrera
where  C.NombreCarrera = 'Ingenieria en Informatica y Sistemas'
group by DATEPART(Year,e.FechaPrueba)

select  Sum(E.Precio)  as TotalIngresos
from	Admisiones_DWH.Fact.Examen e inner join
		Admisiones_DWH.Dimension.Carrera c on e.SK_Carrera = c.SK_Carrera
where  C.NombreCarrera = 'Ingenieria en Informatica y Sistemas'

--nuevo registro
INSERT INTO Admisiones.DBO.Examen
( [ID_Candidato], [ID_Carrera], [ID_Descuento], [FechaPrueba], [Precio], [Nota], [FechaModificacion])
VALUES (1,1,1,GETDATE(),500,100,NULL)
GO

INSERT INTO Admisiones.DBO.Examen_detalle
([ID_Examen], [ID_Materia], [NotaArea])
VALUES (SCOPE_IDENTITY(),1,100)
