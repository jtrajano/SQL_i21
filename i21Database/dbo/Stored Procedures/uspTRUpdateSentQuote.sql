CREATE PROCEDURE [dbo].[uspTRUpdateSentQuote]
	 @intQuoteHeaderId AS INT	 
	 ,@intEntityUserSecurityId AS INT	
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


EXEC uspSMAuditLog 
              @keyValue = @intQuoteHeaderId,                         -- Primary Key Value
              @screenName = 'Transports.view.Quote',           -- Screen Namespace
              @entityId = @intEntityUserSecurityId,                                -- Entity Id.
              @actionType = 'Updated',                               -- Action Type
              @changeDescription = 'Batch Email',                        -- Description
              @fromValue = 'Confirmed',                                        -- Previous Value
              @toValue = 'Sent'                                           -- New Value

Update tblTRQuoteHeader
set strQuoteStatus = 'Sent'
where intQuoteHeaderId = @intQuoteHeaderId 

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