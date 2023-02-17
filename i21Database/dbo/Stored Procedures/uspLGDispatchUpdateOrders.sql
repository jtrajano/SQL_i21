CREATE PROCEDURE [dbo].[uspLGDispatchUpdateOrders]
	@intDispatchOrderId INT
	,@intEntityUserSecurityId INT = NULL
AS
BEGIN
	DECLARE @intSourceType INT
			,@intDispatchStatus INT

	SELECT @intSourceType = intSourceType 
		,@intDispatchStatus = intDispatchStatus
	FROM tblLGDispatchOrder WHERE intDispatchOrderId = @intDispatchOrderId 

	IF (@intSourceType = 2) /* Update TM Orders Status */
	BEGIN
		IF (@intDispatchStatus IN (4))
		BEGIN
			/* Load Delivered */
			UPDATE TMD
				SET strWillCallStatus = 'Delivered'
			FROM tblTMDispatch TMD
				INNER JOIN tblLGDispatchOrderDetail DOD ON DOD.intTMDispatchId = TMD.intDispatchID
				INNER JOIN tblLGDispatchOrder DO ON DO.intDispatchOrderId = DOD.intDispatchOrderId
			WHERE DO.intDispatchOrderId = @intDispatchOrderId
				AND TMD.strWillCallStatus NOT IN ('Delivered')
		END
		ELSE IF (@intDispatchStatus IN (3)) 
		BEGIN
			/* Load Dispatched */
			UPDATE TMD
				SET ysnDispatched = 1
					,strWillCallStatus = 'Routed'
					,dtmDispatchingDate = DO.dtmDispatchDate
					,intDriverID = COALESCE(DOR.intDriverEntityId, DO.intDriverEntityId, TMD.intDriverID)
					,intDispatchOrderId = DO.intDispatchOrderId
			FROM tblTMDispatch TMD
				INNER JOIN tblLGDispatchOrderDetail DOD ON DOD.intTMDispatchId = TMD.intDispatchID
				INNER JOIN tblLGDispatchOrder DO ON DO.intDispatchOrderId = DOD.intDispatchOrderId
				LEFT JOIN tblLGDispatchOrderRoute DOR ON DOR.intDispatchOrderDetailId = DOD.intDispatchOrderDetailId
			WHERE DO.intDispatchOrderId = @intDispatchOrderId
				AND TMD.strWillCallStatus NOT IN ('Delivered')
		END
		ELSE
		BEGIN
			/* Load Cancelled */
			UPDATE TMD
				SET ysnDispatched = 0
					,strWillCallStatus = 'Generated'
					,dtmDispatchingDate = NULL
					,intDriverID = COALESCE(DOR.intDriverEntityId, DO.intDriverEntityId, TMD.intDriverID)
					,intDispatchOrderId = NULL
				FROM tblTMDispatch TMD
				INNER JOIN tblLGDispatchOrderDetail DOD ON DOD.intTMDispatchId = TMD.intDispatchID
				INNER JOIN tblLGDispatchOrder DO ON DO.intDispatchOrderId = DOD.intDispatchOrderId
				LEFT JOIN tblLGDispatchOrderRoute DOR ON DOR.intDispatchOrderDetailId = DOD.intDispatchOrderDetailId
				LEFT JOIN tblTMSite TMS ON TMS.intSiteID = TMD.intSiteID
			WHERE DO.intDispatchOrderId = @intDispatchOrderId
				AND TMD.strWillCallStatus NOT IN ('Delivered')
		END
	END
END
GO
