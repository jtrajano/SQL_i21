CREATE PROCEDURE [dbo].[uspSCProcessToItemReceipt]
	 @intSourceTransactionId AS INT
	,@strSourceType AS NVARCHAR(100) 
	,@intUserId AS INT
	,@dblNetUnits AS DECIMAL
	,@dblCost AS DECIMAL
	,@intLineNo AS INT
	,@intEntityId AS INT 
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
DECLARE @strTransactionId NVARCHAR(40) = NULL

DECLARE @ItemsForItemReceipt AS ItemCostingTableType 

BEGIN TRY
	-- Get the items to process
	INSERT INTO @ItemsForItemReceipt (
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
		,intSubLocationId
		,intStorageLocationId -- ???? I don't see usage for this in the PO to Inventory receipt conversion. 
	)
	EXEC dbo.uspSCGetScaleItemForItemReceipt 
		 @intSourceTransactionId
		,@dblNetUnits
		,@dblCost
		,@strSourceType

	-- Validate the items to receive 
	EXEC dbo.uspICValidateProcessToItemReceipt @ItemsForItemReceipt; 

	select * from @ItemsForItemReceipt
	select @strSourceType, @SourceType_Direct
	-- Add the items to the item receipt 
	IF @strSourceType = @SourceType_Direct
	BEGIN 
		EXEC dbo.uspSCAddScaleTicketToItemReceipt @intSourceTransactionId, @intUserId, @dblNetUnits, @dblCost, @intLineNo, @intEntityId, @InventoryReceiptId OUTPUT; 
	END

	select @InventoryReceiptId 
	BEGIN 
	SELECT	@strTransactionId = IR.strReceiptNumber
	FROM	dbo.tblICInventoryReceipt IR	        
	WHERE	IR.intInventoryReceiptId = @InventoryReceiptId		
	END

	EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intUserId, @intEntityId; 

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