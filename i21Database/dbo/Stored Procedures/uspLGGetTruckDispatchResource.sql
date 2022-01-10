CREATE PROCEDURE [dbo].[uspLGGetTruckDispatchResource] (
	@dtmDateFrom DATETIME
	,@dtmDateTo DATETIME
)
AS
BEGIN
	SELECT 
		intEntityShipViaId = NULL
		,strShipVia = '(Unassigned)'
		,intEntityShipViaTruckId = 0
		,strTruckNumber = '(Unassigned)'
		,intDriverEntityId = NULL
		,strDriver = NULL
		,intEntityShipViaTrailerId = NULL
		,strTrailerNumber = NULL
	
	UNION ALL

	SELECT
		intEntityShipViaId = SVT.intEntityShipViaId
		,strShipVia = SV.strName 
		,SVT.intEntityShipViaTruckId
		,SVT.strTruckNumber 
		,DO.intDriverEntityId
		,DO.strDriver
		,DO.intEntityShipViaTrailerId
		,DO.strTrailerNumber 
	FROM tblSMShipViaTruck SVT
	INNER JOIN tblEMEntity SV ON SV.intEntityId = SVT.intEntityShipViaId
	OUTER APPLY 
		(SELECT TOP 1
			do.intDriverEntityId
			,strDriver = DV.strName
			,do.intEntityShipViaTrailerId 
			,strTrailerNumber = SVTR.strTrailerNumber
		 FROM 
			tblLGDispatchOrderDetail dod 
			INNER JOIN tblLGDispatchOrder do ON do.intDispatchOrderId = dod.intDispatchOrderId
			LEFT JOIN tblEMEntity DV ON DV.intEntityId = do.intDriverEntityId
			LEFT JOIN tblSMShipViaTrailer SVTR ON SVTR.intEntityShipViaTrailerId = do.intEntityShipViaTrailerId
		 WHERE do.intEntityShipViaTruckId = SVT.intEntityShipViaTruckId 
			AND do.dtmDispatchDate >= @dtmDateFrom
			AND do.dtmDispatchDate <= @dtmDateTo
		 ORDER BY dod.dtmStartTime DESC
		) DO
END
GO