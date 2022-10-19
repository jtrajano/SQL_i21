CREATE PROCEDURE [dbo].[uspLGRouteUpdateOrders]
			@intRouteId INT
			,@intEntityUserSecurityId INT
			,@ysnPost BIT
AS

DECLARE @OrdersFromRouting AS RouteOrdersTableType

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE		@ErrMsg		NVARCHAR(MAX) = NULL;
	DECLARE		@intSourceType INT;

	SELECT @intSourceType = intSourceType FROM tblLGRoute WHERE intRouteId = @intRouteId

	IF @ysnPost = 1 
	BEGIN
		/* Check for TM Orders that are already posted on another LCR */
		SELECT TOP 1 @ErrMsg = 'Unable to Post. Order Number ' + LTRIM(RTRIM(TMD.strOrderNumber))  + ' is already Routed for another record.'
		FROM tblLGRouteOrder RO LEFT JOIN tblLGRoute R ON R.intRouteId = RO.intRouteId LEFT JOIN tblTMDispatch TMD ON TMD.intDispatchID = RO.intDispatchID 
		WHERE R.intSourceType = 2 AND RO.intDispatchID IS NOT NULL AND TMD.strWillCallStatus IN ('Routed') AND R.intRouteId = @intRouteId

		IF (@ErrMsg IS NOT NULL)
		BEGIN
			RAISERROR (@ErrMsg,16,1,'WITH NOWAIT') 
			RETURN 0; 
		END

		/* Check for TM Orders that are already Delivered */
		SELECT TOP 1 @ErrMsg = 'Unable to Post. Order Number ' + LTRIM(RTRIM(TMD.strOrderNumber))  + ' is already Delivered.'
		FROM tblLGRouteOrder RO LEFT JOIN tblLGRoute R ON R.intRouteId = RO.intRouteId LEFT JOIN tblTMDispatch TMD ON TMD.intDispatchID = RO.intDispatchID 
		WHERE R.intSourceType = 2 AND RO.intDispatchID IS NOT NULL AND TMD.strWillCallStatus IN ('Delivered') AND R.intRouteId = @intRouteId

		IF (@ErrMsg IS NOT NULL)
		BEGIN
			RAISERROR (@ErrMsg,16,1,'WITH NOWAIT') 
			RETURN 0; 
		END

		/* Check for TM Orders that no longer exists */
		SELECT TOP 1 @ErrMsg = 'Unable to Post. Order Number ' + LTRIM(RTRIM(RO.strOrderNumber))  + ' no longer exists or is already Completed.'
		FROM tblLGRouteOrder RO LEFT JOIN tblLGRoute R ON R.intRouteId = RO.intRouteId LEFT JOIN tblTMDispatch TMD ON TMD.intDispatchID = RO.intDispatchID 
		WHERE R.intSourceType = 2 AND RO.intDispatchID IS NOT NULL AND TMD.intDispatchID IS NULL AND R.intRouteId = @intRouteId

		IF (@ErrMsg IS NOT NULL)
		BEGIN
			RAISERROR (@ErrMsg,16,1,'WITH NOWAIT') 
			RETURN 0; 
		END

		INSERT INTO @OrdersFromRouting
			(
				intOrderId
				,intRouteId
				,intDriverEntityId
				,dblLatitude
				,dblLongitude
				,intSequence
				,strComments
			)
			SELECT 
				RO.intDispatchID, 
				R.intRouteId, 
				R.intDriverEntityId, 
				RO.dblToLatitude, 
				RO.dblToLongitude, 
				RO.intSequence, 
				R.strComments 
			FROM tblLGRouteOrder RO 
				JOIN tblLGRoute R ON R.intRouteId = RO.intRouteId
				LEFT JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = RO.intLoadDetailId
				LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			WHERE RO.intRouteId = @intRouteId AND IsNull(RO.intDispatchID, 0) <> 0 ORDER BY RO.intSequence ASC

			Exec dbo.uspTMUpdateRouteSequence @OrdersFromRouting

			UPDATE tblLGRoute SET ysnPosted = @ysnPost, dtmPostedDate=GETDATE() WHERE intRouteId = @intRouteId
			
			IF (@intSourceType IN (1, 3, 7)) 
			BEGIN
				/* Update Load Schedule */
				UPDATE L 
					SET intDriverEntityId = Rte.intDriverEntityId
						,ysnDispatched = 1
						,intShipmentStatus = CASE WHEN (L.intShipmentStatus = 1) THEN 2 ELSE L.intShipmentStatus END
						,dtmDispatchedDate = GETDATE()
						,intDispatcherId = @intEntityUserSecurityId
				FROM tblLGLoad L 
				JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
				JOIN tblLGRouteOrder RO ON RO.intLoadDetailId = LD.intLoadDetailId
				JOIN tblLGRoute Rte ON Rte.intRouteId = RO.intRouteId
				WHERE Rte.intRouteId = @intRouteId
					AND ISNULL(L.ysnDispatched, 0) = 0
					AND L.intTransUsedBy <> 1

				UPDATE EL SET 
					dblLatitude = RO.dblToLatitude
					,dblLongitude = RO.dblToLongitude
				FROM tblEMEntityLocation EL 
				JOIN tblLGLoadDetail LD ON LD.intCustomerEntityLocationId = EL.intEntityLocationId
				JOIN tblLGRouteOrder RO ON RO.intLoadDetailId = LD.intLoadDetailId
				WHERE EL.dblLatitude = 0 AND EL.dblLongitude = 0 AND RO.intRouteId=@intRouteId
			END
	END
	ELSE IF @ysnPost = 0
	BEGIN
		INSERT INTO @OrdersFromRouting
			(
				intOrderId
				,intRouteId
				,intDriverEntityId
				,dblLatitude
				,dblLongitude
				,intSequence
				,strComments
			)
			SELECT 
				intOrderId = RO.intDispatchID
				,intRouteId = NULL
				,intDriverEntityId = S.intDriverID
				,dblLatitude = 0
				,dblLongitude = 0
				,intSequence = NULL 
				,strComments = NULL 
			FROM tblLGRouteOrder RO 
				JOIN tblLGRoute R ON R.intRouteId = RO.intRouteId
				JOIN tblTMDispatch D ON D.intDispatchID = RO.intDispatchID
				LEFT JOIN tblTMSite S ON S.intSiteID = D.intSiteID
			WHERE RO.intRouteId = @intRouteId AND IsNull(RO.intDispatchID, 0) <> 0 ORDER BY RO.intSequence ASC
			
			Exec dbo.uspTMUpdateRouteSequence @OrdersFromRouting

			UPDATE tblLGRoute SET ysnPosted = @ysnPost, dtmPostedDate=NULL WHERE intRouteId = @intRouteId

			IF (@intSourceType IN (1, 3, 7)) 
			BEGIN
				/* Update Load Schedule */
				UPDATE L 
					SET ysnDispatched = 0
						,intShipmentStatus = 1
						,dtmDispatchedDate = NULL
						,intDispatcherId = NULL
				FROM tblLGLoad L 
				JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
				JOIN tblLGRouteOrder RO ON RO.intLoadDetailId = LD.intLoadDetailId
				JOIN tblLGRoute Rte ON Rte.intRouteId = RO.intRouteId
				WHERE Rte.intRouteId = @intRouteId
					AND L.intShipmentStatus = 2
					AND L.intTransUsedBy <> 1
			END
	END
GO
