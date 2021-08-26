--------------------------------------------------------------------------------------------
----------------------------PRUEBA # 1 - TRAER TODA LA DATA --------------------------------
--------------------------------------------------------------------------------------------

	set statistics time on
	set statistics io on

		select *
		from	Admisiones.DBO.Candidato as c inner join 
				Admisiones.DBO.ColegioCandidato as cc on c.ID_Colegio = cc.ID_Colegio inner join
				Admisiones.DBO.Diversificado as D on c.ID_Diversificado = d.ID_Diversificado inner join
				Admisiones.DBO.Examen as e on e.ID_Candidato = c.ID_Candidato inner join
				Admisiones.DBO.Examen_detalle as ed on e.ID_Examen = ed.ID_Examen inner join
				Admisiones.DBO.Materia as m on ed.ID_Materia = m.ID_Materia inner join
				Admisiones.DBO.Descuento as de on de.ID_Descuento = e.ID_Descuento inner join
				Admisiones.DBO.carrera as ca on ca.ID_Carrera = e.ID_Carrera inner join
				Admisiones.DBO.Facultad as f on f.ID_Facultad = ca.ID_Facultad

	set statistics time off
	set statistics io off
	
	GO
	
	set statistics time on
	set statistics io on

		select *
		from	Admisiones_DWH.Fact.Examen as e inner join
				Admisiones_DWH.Dimension.Candidato as c on e.SK_Candidato = c.SK_Candidato inner join
				Admisiones_DWH.Dimension.Carrera as ca on ca.SK_Carrera = e.SK_Carrera inner join
				Admisiones_DWH.Dimension.Fecha as f on e.DateKey = f.DateKey

	set statistics time off
	set statistics io off

	GO
--------------------------------------------------------------------------------------------
-------------------------- PRUEBA # 2 - COMPARAR AGREGACIONES ------------------------------
--------------------------------------------------------------------------------------------


	set statistics time on
	set statistics io on

		select	c.Nombre AS NombreCandidato,
				c.Apellido AS ApellidoCandidato,
				cc.Nombre as NombreColegio,
				D.Nombre as NombreDiversificado,
				M.NombreMateria as NombreMateria,
				De.Descripcion as DescripcionDescuento,
				ca.Nombre as NombreCarrera,
				F.Nombre as NombreFacultad,
				SUM(E.Precio) as TotalPrecio,
				AVG(E.Nota) as PromedioNota
		from	Admisiones.DBO.Candidato as c inner join 
				Admisiones.DBO.ColegioCandidato as cc on c.ID_Colegio = cc.ID_Colegio inner join
				Admisiones.DBO.Diversificado as D on c.ID_Diversificado = d.ID_Diversificado inner join
				Admisiones.DBO.Examen as e on e.ID_Candidato = c.ID_Candidato inner join
				Admisiones.DBO.Examen_detalle as ed on e.ID_Examen = ed.ID_Examen inner join
				Admisiones.DBO.Materia as m on ed.ID_Materia = m.ID_Materia inner join
				Admisiones.DBO.Descuento as de on de.ID_Descuento = e.ID_Descuento inner join
				Admisiones.DBO.carrera as ca on ca.ID_Carrera = e.ID_Carrera inner join
				Admisiones.DBO.Facultad as f on f.ID_Facultad = ca.ID_Facultad
		GROUP BY	c.Nombre,
					c.Apellido,
					cc.Nombre,
					D.Nombre,
					M.NombreMateria,
					De.Descripcion,
					ca.Nombre,
					F.Nombre

	set statistics time off
	set statistics io off

	go

	set statistics time on
	set statistics io on

		select  C.NombreCandidato,
				C.ApellidoCandidato,
				c.NombreColegio,
				c.NombreDiversificado,
				e.NombreMateria,
				e.DescripcionDescuento,
				ca.NombreCarrera,
				ca.NombreFacultad,
				SUM(E.Precio) as TOtalPrecio,
				AVG(e.NotaTotal) as PromedioNota
		from	Admisiones_DWH.Fact.Examen as e inner join
				Admisiones_DWH.Dimension.Candidato as c on e.SK_Candidato = c.SK_Candidato inner join
				Admisiones_DWH.Dimension.Carrera as ca on ca.SK_Carrera = e.SK_Carrera inner join
				Admisiones_DWH.Dimension.Fecha as f on e.DateKey = f.DateKey

		GROUP BY	C.NombreCandidato,
					C.ApellidoCandidato,
					c.NombreColegio,
					c.NombreDiversificado,
					e.NombreMateria,
					e.DescripcionDescuento,
					ca.NombreFacultad,
					ca.NombreCarrera

	set statistics time off
	set statistics io off

	go