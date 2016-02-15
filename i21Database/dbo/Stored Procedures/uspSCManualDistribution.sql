CREATE PROCEDURE [dbo].[uspSCManualDistribution]
	@LineItem ScaleManualCostingTableType READONLY,
	@intTicketId AS INT, 
	@intUserId AS INT,
	@intEntityId AS INT,
	@InventoryReceiptId AS INT OUTPUT 
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

DECLARE @ItemsForItemReceipt AS ItemCostingTableType
DECLARE @total AS INT
DECLARE @ErrMsg NVARCHAR(MAX)
DECLARE @strTransactionId NVARCHAR(40) = NULL

BEGIN TRY
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
				,intTransactionDetailId
				,strTransactionId
				,intTransactionTypeId
				,intLotId
				,intSubLocationId
				,intStorageLocationId -- ???? I don't see usage for this in the PO to Inventory receipt conversion.
				,ysnIsStorage 
			)SELECT 
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
				,intTransactionDetailId
				,strTransactionId
				,intTransactionTypeId
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,ysnIsStorage
			FROM @LineItem

EXEC dbo.uspICValidateProcessToItemReceipt @ItemsForItemReceipt; 

SELECT @total = COUNT(*) FROM @ItemsForItemReceipt;
IF (@total = 0)
	RETURN;
	
BEGIN 
	EXEC dbo.uspSCAddScaleTicketToItemReceipt @intTicketId, @intUserId, @ItemsForItemReceipt, @intEntityId, NULL, @InventoryReceiptId OUTPUT; 
END

BEGIN 
SELECT	@strTransactionId = IR.strReceiptNumber
FROM	dbo.tblICInventoryReceipt IR	        
WHERE	IR.intInventoryReceiptId = @InventoryReceiptId		
END
EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intEntityId;

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