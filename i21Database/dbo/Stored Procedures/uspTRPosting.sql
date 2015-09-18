CREATE PROCEDURE [dbo].[uspTRPosting]
	 @intTransportLoadId AS INT
	,@intUserId AS INT	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

BEGIN TRY

EXEC uspTRPostingValidation @intTransportLoadId
EXEC uspTRProcessToInventoryReceipt @intTransportLoadId,@intUserId
EXEC uspTRProcessToInventoryTransfer @intTransportLoadId,@intUserId
EXEC uspTRProcessToInvoice @intTransportLoadId,@intUserId
EXEC uspTRProcessTransportLoad @intTransportLoadId

END TRY
BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrorMessage = ERROR_MESSAGE()
	RAISERROR (	@ErrorMessage,16,1,'WITH NOWAIT')

END CATCH