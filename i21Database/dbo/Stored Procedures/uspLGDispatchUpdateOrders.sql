CREATE PROCEDURE [dbo].[uspLGDispatchUpdateOrders]
	@intDispatchOrderId INT
	,@intEntityUserSecurityId INT = NULL
AS
BEGIN
	DECLARE @intSourceType INT
			,@intDispatchStatus INT
			,@intLoadHeaderId INT = NULL
			,@ysnTRPosted BIT

	/* Get Dispatch Schedule Status */
	SELECT @intSourceType = intSourceType 
		,@intDispatchStatus = intDispatchStatus
	FROM tblLGDispatchOrder WHERE intDispatchOrderId = @intDispatchOrderId 

	/* Check for associated Transport Load */
	SELECT TOP 1 
		@intLoadHeaderId = intLoadHeaderId
		,@ysnTRPosted = ysnPosted FROM tblTRLoadHeader 
	WHERE intDispatchOrderId = @intDispatchOrderId
	ORDER BY dtmLoadDateTime DESC

	IF @intLoadHeaderId IS NOT NULL
	BEGIN
		/* If TR is Posted */
		IF (ISNULL(@ysnTRPosted, 0) = 1)
		BEGIN
			UPDATE tblLGDispatchOrder
			SET intDispatchStatus = CASE WHEN (ISNULL(@ysnTRPosted, 0) = 1) 
				THEN 5 /* Complete */ 
				ELSE 4 /* In Progress */
				END
			WHERE intDispatchOrderId = @intDispatchOrderId

			/* Check for deleted orders and mark them as 'Cancelled' on Route */
			UPDATE tblLGDispatchOrderRoute
			SET intOrderStatus = 6 /* Cancelled */ 
			WHERE intDispatchOrderId = @intDispatchOrderId
			AND intStopType = 2
			AND intDispatchOrderDetailId NOT IN (
				SELECT intDispatchOrderDetailId FROM tblTRLoadDistributionDetail 
				WHERE intLoadDistributionHeaderId IN (SELECT intLoadDistributionHeaderId FROM tblTRLoadDistributionHeader 
														WHERE intLoadHeaderId = @intLoadHeaderId))			
		END
		ELSE /* If TR is Saved or Unposted */
		BEGIN
			/* If Receipt Header with intDispatchOrderRouteId exists, update the route Id status to 'Loaded' */
			UPDATE tblLGDispatchOrderRoute
			SET intOrderStatus = 4 /* Loaded */ 
			WHERE intDispatchOrderId = @intDispatchOrderId
			AND intStopType = 1
			AND intDispatchOrderRouteId IN (
				SELECT intDispatchOrderRouteId FROM tblTRLoadReceipt 
				WHERE intLoadHeaderId = @intLoadHeaderId)
			AND intOrderStatus NOT IN (4, 6)

			/* If Distribution Detail with intDispatchOrderDetailId exists, update the order and route status to 'Delivered' */
			UPDATE tblLGDispatchOrderRoute
			SET intOrderStatus = 4 /* Delivered */ 
			WHERE intDispatchOrderId = @intDispatchOrderId
			AND intStopType = 2
			AND intDispatchOrderDetailId IN (
				SELECT intDispatchOrderDetailId FROM tblTRLoadDistributionDetail 
				WHERE intLoadDistributionHeaderId IN (SELECT intLoadDistributionHeaderId FROM tblTRLoadDistributionHeader 
														WHERE intLoadHeaderId = @intLoadHeaderId))
			AND intOrderStatus NOT IN (4, 6)
		END

	END
	ELSE
	BEGIN
		/* If deleting associated TR, set DS back to 'Dispatched' status */
		IF (@intDispatchStatus = 4)
		BEGIN
			UPDATE tblLGDispatchOrder
				SET intDispatchStatus = 3 /* Dispatched */ 
			WHERE intDispatchOrderId = @intDispatchOrderId
			AND intDispatchStatus = 4
		END
	END

	/* Copy Order status from Route */
	UPDATE DOD
	SET intOrderStatus = DOR.intOrderStatus /* Cancelled */ 
	FROM tblLGDispatchOrderDetail DOD
	INNER JOIN tblLGDispatchOrderRoute DOR ON DOR.intDispatchOrderDetailId = DOD.intDispatchOrderDetailId
	WHERE DOD.intDispatchOrderId = @intDispatchOrderId

	/* Get Dispatch Schedule Status again */
	SELECT @intDispatchStatus = intDispatchStatus
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
