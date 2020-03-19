CREATE PROCEDURE [dbo].uspSCProcessReversalDeliverySheetSummaryToTicket
	@intDeliverySheetId INT
	,@intUserId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
		,@ErrorSeverity INT
		,@ErrorState INT
		,@jsonData NVARCHAR(MAX)

DECLARE @currencyDecimal INT


BEGIN TRY
	SET @currencyDecimal = 20

	--create reversal for the tickets

	--GEt all IR for the tickets under the deliverysheet that don't have reversals
	BEGIN
		INSERT INTO @TicketReceiptShipmentIds
		SELECT DISTINCT
			A.intInventoryReceiptId
		FROM tblICInventoryReceipt A
		INNER JOIN tblICInventoryReceiptItem B
			ON A.intInventoryReceiptId = B.intInventoryReceiptId
		WHERE A.intSourceType = 1
			AND B.intSourceId = @intTicketId
			AND ISNULL(A.strDataSource,0) <> 'Reversal'
			AND NOT EXISTS(SELECT TOP 1 1 FROM tblICInventoryReceipt WHERE intSourceInventoryReceiptId = A.intInventoryReceiptId)
		ORDER BY A.intInventoryReceiptId ASC
	END
	
	_Exit:
END TRY

BEGIN CATCH
BEGIN
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
	END
END CATCH
GO