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
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH