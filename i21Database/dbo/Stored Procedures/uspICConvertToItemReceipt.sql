CREATE PROCEDURE [dbo].[uspICConvertToItemReceipt]
	@ItemsToReceive AS ItemCostingTableType READONLY 
	,@SourceTransactionId AS INT
	,@SourceType AS INT 
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

-- Constant variables for the source type
DECLARE @SourceType_PurchaseOrder AS INT = 1;

BEGIN TRY
	-- Do the Validation
	EXEC dbo.uspICValidateConvertToItemReceipt @ItemsToReceive; 

	-- Create the Item Receipt
	-- TODO by Lawrence 

	-- Increase the On-Order Qty for the items
	IF @SourceType = @SourceType_PurchaseOrder
		EXEC dbo.uspICIncreaseOnOrderQty @ItemsToReceive;

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
