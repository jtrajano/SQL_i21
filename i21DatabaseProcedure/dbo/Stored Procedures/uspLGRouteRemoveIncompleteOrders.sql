CREATE PROCEDURE [dbo].[uspLGRouteRemoveIncompleteOrders]
			@intRouteId INT
			,@intEntityUserSecurityId INT
			,@intDispatchID INT
AS

BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE		@ErrMsg		NVARCHAR(MAX);
	DELETE FROM tblLGRouteOrder WHERE intRouteId = @intRouteId AND intDispatchID=@intDispatchID

END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspLGRouteRemoveIncompleteOrders - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
