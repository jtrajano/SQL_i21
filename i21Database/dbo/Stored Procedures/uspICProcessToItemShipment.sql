CREATE PROCEDURE [dbo].[uspICProcessToItemShipment]
	@intSourceTransactionId AS INT
	,@strSourceType AS NVARCHAR(100) 
	,@intUserId AS INT 
	,@InventoryShipmentId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

--DECLARE @ItemsForItemShipment AS ItemCostingTableType 

--BEGIN TRY
--	-- Get the items to process
--	INSERT INTO @ItemsForItemShipment (
--		intItemId
--		,intItemLocationId
--		,intItemUOMId
--		,dtmDate
--		,dblQty
--		,dblUOMQty
--		,dblCost
--		,dblSalesPrice
--		,intCurrencyId
--		,dblExchangeRate
--		,intTransactionId
--		,strTransactionId
--		,intTransactionTypeId
--		,intLotId
--		,intSubLocationId
--		,intStorageLocationId 
--	)
--	EXEC dbo.uspICGetItemsForItemShipment
--		@intSourceTransactionId
--		,@strSourceType

--	-- Validate the items to ship
--	EXEC dbo.uspICValidateProcessToItemShipment @ItemsForItemShipment; 

--	-- Add the items to the item shipment
--	IF @strSourceType = @SourceType_SalesOrder
--	BEGIN 
--		EXEC dbo.uspICAddPurchaseOrderToItemShipment @intSourceTransactionId, @intUserId, @InventoryReceiptId OUTPUT; 
--	END

--END TRY
--BEGIN CATCH
--	SELECT 
--		@ErrorMessage = ERROR_MESSAGE(),
--		@ErrorSeverity = ERROR_SEVERITY(),
--		@ErrorState = ERROR_STATE();

--	-- Use RAISERROR inside the CATCH block to return error
--	-- information about the original error that caused
--	-- execution to jump to the CATCH block.
--	RAISERROR (
--		@ErrorMessage, -- Message text.
--		@ErrorSeverity, -- Severity.
--		@ErrorState -- State.
--	);
--END CATCH