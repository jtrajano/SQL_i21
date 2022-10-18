﻿CREATE PROCEDURE [dbo].[uspLGLoadUpdateOrders]
	@intLoadId INT
	,@intEntityUserSecurityId INT = NULL
AS
BEGIN
	DECLARE @intSourceType INT
			,@intShipmentStatus INT

	SELECT @intSourceType = intSourceType 
		,@intShipmentStatus = intShipmentStatus
	FROM tblLGLoad WHERE intLoadId = @intLoadId 

	IF (@intSourceType = 8) /* Update TM Orders Status */
	BEGIN
		IF (@intShipmentStatus IN (2, 3)) 
		BEGIN
			/* LS Dispatched */
			UPDATE TMD
				SET ysnDispatched = L.ysnDispatched
					,strWillCallStatus = 'Dispatched'
					,dtmDispatchingDate = L.dtmDispatchedDate
					,intDriverID = ISNULL(L.intDriverEntityId, TMD.intDriverID)
			FROM tblTMDispatch TMD
				INNER JOIN tblLGLoadDetail LD ON LD.intTMDispatchId = TMD.intDispatchID
				INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			WHERE L.intLoadId = @intLoadId
				AND TMD.strWillCallStatus NOT IN ('Delivered')
		END
		ELSE IF (@intShipmentStatus IN (4, 6))
		BEGIN
			/* LS Delivered */
			UPDATE TMD
				SET strWillCallStatus = 'Delivered'
			FROM tblTMDispatch TMD
				INNER JOIN tblLGLoadDetail LD ON LD.intTMDispatchId = TMD.intDispatchID
				INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			WHERE L.intLoadId = @intLoadId
				AND TMD.strWillCallStatus NOT IN ('Delivered')
		END
		ELSE
		BEGIN
			/* LS Scheduled or Cancelled */
			UPDATE TMD
				SET ysnDispatched = L.ysnDispatched
					,strWillCallStatus = 'Generated'
					,dtmDispatchingDate = NULL
					,intDriverID = ISNULL(L.intDriverEntityId, TMD.intDriverID)
				FROM tblTMDispatch TMD
				INNER JOIN tblLGLoadDetail LD ON LD.intTMDispatchId = TMD.intDispatchID
				INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
				LEFT JOIN tblTMSite TMS ON TMS.intSiteID = TMD.intSiteID
			WHERE L.intLoadId = @intLoadId
				AND TMD.strWillCallStatus NOT IN ('Delivered')
		END
	END
END
GO
