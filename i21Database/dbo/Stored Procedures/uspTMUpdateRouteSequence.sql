CREATE PROCEDURE uspTMUpdateRouteSequence 
	@RouteOrder RouteOrdersTableType READONLY
AS
BEGIN

	--Update Dispatch
	UPDATE tblTMDispatch
		SET intRouteId = A.intRouteId
			,intDriverID = A.[intDriverEntityId]
			,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
			,strWillCallStatus = CASE WHEN A.intRouteId IS NULL THEN 'Generated' ELSE 'Routed' END
			,ysnReceived = 0
			,dtmReceivedDate = NULL
			,ysnDispatched = CASE WHEN A.intRouteId IS NULL THEN 0 ELSE 1 END
			,dtmDispatchingDate = CASE WHEN A.intRouteId IS NULL THEN NULL ELSE GETDATE() END
	FROM @RouteOrder A
	WHERE tblTMDispatch.intDispatchID = A.intOrderId
	AND strWillCallStatus <> 'Delivered'


	---Update Site
	UPDATE tblTMSite
	SET dblLongitude = A.dblLongitude
		,dblLatitude =A.dblLatitude
		,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
	FROM ( 
		SELECT A.*
			,B.intSiteID
		FROM @RouteOrder A
		INNER JOIN tblTMDispatch B
			ON A.intOrderId = B.intDispatchID
		WHERE A.dblLongitude IS NOT NULL OR A.dblLatitude IS NOT NULL
	) A
	WHERE tblTMSite.intSiteID = A.intSiteID
		AND (ISNULL(tblTMSite.dblLongitude,0) <> A.dblLongitude OR ISNULL(tblTMSite.dblLatitude,0) <> A.dblLatitude)


	
END
GO
