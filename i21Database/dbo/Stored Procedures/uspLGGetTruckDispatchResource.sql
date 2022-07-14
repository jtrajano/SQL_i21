CREATE PROCEDURE [dbo].[uspLGGetTruckDispatchResource] (
	@dtmDateFrom DATETIME
	,@dtmDateTo DATETIME
)
AS
BEGIN
	SELECT 
		intDriverEntityId = 0
		,strDriver = '(Unassigned)'
		,intEntityShipViaId = NULL
		,strShipVia = '(Unassigned)'
		,intEntityShipViaTruckId = 0
		,strTruckNumber = '(Unassigned)'
		,intEntityShipViaTrailerId = NULL
		,strTrailerNumber = NULL
	
	UNION ALL

	SELECT
		intDriverEntityId = DV.intEntityId
		,strDriver = DV.strName
		,intEntityShipViaId = DO.intEntityShipViaId
		,strShipVia = DO.strShipVia 
		,DO.intEntityShipViaTruckId
		,DO.strTruckNumber 
		,DO.intEntityShipViaTrailerId
		,DO.strTrailerNumber 
	FROM tblEMEntity DV
		INNER JOIN tblARSalesperson SP ON SP.intEntityId = DV.intEntityId AND SP.strType = 'Driver'
		OUTER APPLY 
			(SELECT TOP 1
				do.intEntityShipViaId
				,strShipVia = DV.strName
				,do.intEntityShipViaTrailerId 
				,strTrailerNumber = SVTR.strTrailerNumber
				,do.intEntityShipViaTruckId
				,strTruckNumber = SVTK.strTruckNumber
			 FROM 
				tblLGDispatchOrderDetail dod 
				INNER JOIN tblLGDispatchOrder do ON do.intDispatchOrderId = dod.intDispatchOrderId
				LEFT JOIN tblSMShipVia SV ON SV.intEntityId = do.intEntityShipViaId
				LEFT JOIN tblSMShipViaTruck SVTK ON SVTK.intEntityShipViaTruckId = do.intEntityShipViaTruckId
				LEFT JOIN tblSMShipViaTrailer SVTR ON SVTR.intEntityShipViaTrailerId = do.intEntityShipViaTrailerId
			 WHERE do.intDriverEntityId = DV.intEntityId
				AND do.dtmDispatchDate >= @dtmDateFrom
				AND do.dtmDispatchDate <= @dtmDateTo
			 ORDER BY dod.dtmStartTime DESC) DO

END
GO