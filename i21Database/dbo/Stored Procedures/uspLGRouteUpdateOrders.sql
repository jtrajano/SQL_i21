CREATE PROCEDURE [dbo].[uspLGRouteUpdateOrders]
			@intRouteId INT
			,@intEntityUserSecurityId INT
			,@ysnPost BIT
AS

DECLARE @OrdersFromRouting AS RouteOrdersTableType

BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE		@ErrMsg		NVARCHAR(MAX);
	DECLARE		@intSourceType INT;

	IF @ysnPost = 1 
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
				RO.intDispatchID, 
				NULL, 
				NULL, 
				0, 
				0, 
				NULL, 
				NULL 
			FROM tblLGRouteOrder RO 
				JOIN tblLGRoute R ON R.intRouteId = RO.intRouteId
			WHERE RO.intRouteId = @intRouteId AND R.intSourceType = 2 AND IsNull(intDispatchID, 0) <> 0 ORDER BY RO.intSequence ASC
			
			Exec dbo.uspTMUpdateRouteSequence @OrdersFromRouting

			UPDATE tblLGRoute SET ysnPosted = @ysnPost, dtmPostedDate=NULL WHERE intRouteId = @intRouteId
	END
END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspLGRouteUpdateOrders - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
