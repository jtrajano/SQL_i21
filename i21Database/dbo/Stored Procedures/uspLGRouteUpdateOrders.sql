﻿CREATE PROCEDURE [dbo].[uspLGRouteUpdateOrders]
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
		SELECT TOP 1 @ErrMsg = 'Unable to Post. Order Number ' + LTRIM(RTRIM(TMD.strOrderNumber))  + ' is already Routed for another record.'
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
			WHERE RO.intRouteId = @intRouteId AND R.intSourceType = 2 AND IsNull(intDispatchID, 0) <> 0 ORDER BY RO.intSequence ASC

			Exec dbo.uspTMUpdateRouteSequence @OrdersFromRouting

			UPDATE tblLGRoute SET ysnPosted = @ysnPost, dtmPostedDate=GETDATE() WHERE intRouteId = @intRouteId

			SELECT @intSourceType = intSourceType FROM tblLGRoute WHERE intRouteId = @intRouteId
			
			IF (@intSourceType = 1) 
			BEGIN
				UPDATE Load SET 
					intDriverEntityId = Rte.intDriverEntityId
				FROM tblLGLoad Load 
				JOIN tblLGLoadDetail LD ON LD.intLoadId = Load.intLoadId
				JOIN tblLGRouteOrder RO ON RO.intLoadDetailId = LD.intLoadDetailId
				JOIN tblLGRoute Rte ON Rte.intRouteId = RO.intRouteId
				WHERE Rte.intRouteId=@intRouteId

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
			WHERE RO.intRouteId = @intRouteId AND R.intSourceType = 2 AND IsNull(RO.intDispatchID, 0) <> 0 ORDER BY RO.intSequence ASC
			
			Exec dbo.uspTMUpdateRouteSequence @OrdersFromRouting

			UPDATE tblLGRoute SET ysnPosted = @ysnPost, dtmPostedDate=NULL WHERE intRouteId = @intRouteId
	END
GO
