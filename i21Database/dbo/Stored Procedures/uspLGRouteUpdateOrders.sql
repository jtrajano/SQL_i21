CREATE PROCEDURE [dbo].[uspLGRouteUpdateOrders]
			@intRouteId INT
AS

DECLARE @OrdersFromRouting AS RouteOrdersTableType

BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE		@ErrMsg		NVARCHAR(MAX)

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

END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspLGRouteUpdateOrders - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
