CREATE PROCEDURE [dbo].[uspICProcessToItemReceipt]
	@intSourceTransactionId AS INT
	,@strSourceType AS NVARCHAR(100) 
	,@intUserId AS INT 
	,@InventoryReceiptId AS INT OUTPUT 
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
DECLARE @SourceType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
DECLARE @SourceType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'
DECLARE @SourceType_Direct AS NVARCHAR(100) = 'Direct'

DECLARE @ItemsToReceive AS ItemCostingTableType 

BEGIN TRY
	-- Get the items to process
	INSERT INTO @ItemsToReceive (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,dtmDate
		,dblQty
		,dblUOMQty
		,dblCost
		,dblSalesPrice
		,intCurrencyId
		,dblExchangeRate
		,intTransactionId
		,strTransactionId
		,intTransactionTypeId
		,intLotId
	)
	EXEC dbo.uspICGetItemsForItemReceipt 
		@intSourceTransactionId
		,@strSourceType

	-- Validate the items to receive 
	EXEC dbo.uspICValidateProcessToItemReceipt @ItemsToReceive; 

	-- Add the items to the item receipt 
	IF @strSourceType = @SourceType_PurchaseOrder
	BEGIN 
		EXEC dbo.uspICAddPurchaseOrderToItemReceipt @intSourceTransactionId, @intUserId, @InventoryReceiptId OUTPUT; 
		EXEC dbo.uspICIncreaseOnOrderQty @ItemsToReceive;
	END

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