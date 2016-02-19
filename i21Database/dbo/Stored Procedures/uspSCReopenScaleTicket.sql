CREATE PROCEDURE [dbo].[uspSCReopenScaleTicket]
	@intSourceId AS INT
	,@intModuleId AS INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

DECLARE @total AS INT
DECLARE @ErrMsg NVARCHAR(MAX)
DECLARE @strTransactionId NVARCHAR(40) = NULL
--1 - inventory receipt
--2 - inventory shipment
--3 - inventory transfer
BEGIN TRY
	IF @intModuleId = 1
		UPDATE dbo.tblSCTicket SET strTicketStatus = 'R', intInventoryReceiptId = null WHERE intTicketId = @intSourceId;
	IF @intModuleId = 2
		UPDATE dbo.tblSCTicket SET strTicketStatus = 'R', intInventoryTransferId = null WHERE intTicketId = @intSourceId;
	_Exit:
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