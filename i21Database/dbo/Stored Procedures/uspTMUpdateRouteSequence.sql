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
	FROM @RouteOrder A
	WHERE tblTMDispatch.intDispatchID = A.intOrderId

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
	) A
	WHERE tblTMSite.intSiteID = A.intSiteID
		AND (ISNULL(tblTMSite.dblLongitude,0) = 0 OR ISNULL(tblTMSite.dblLatitude,0) = 0)


	
END

