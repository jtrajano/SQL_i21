CREATE PROCEDURE [dbo].[uspICProcessToInventoryShipment]
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

DECLARE @ItemsForItemShipment AS ItemCostingTableType 

DECLARE @SALES_CONTRACT AS NVARCHAR(50) = 'Sales Contract'
		,@SALES_ORDER AS NVARCHAR(50) = 'Sales Order'
		,@TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'

BEGIN TRY
	-- Get the items to process
	INSERT INTO @ItemsForItemShipment (
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
		,intStorageLocationId 
	)
	EXEC dbo.uspICGetItemsForInventoryShipment
		@intSourceTransactionId
		,@strSourceType

	-- Validate the items to shipment 
	EXEC dbo.uspICValidateProcessToInventoryShipment @ItemsForItemShipment; 

	-- Add the items into inventory shipment > sales order type. 
	IF @strSourceType = @SALES_ORDER
	BEGIN 
		EXEC dbo.uspICAddSalesOrderToInventoryShipment 
			@intSourceTransactionId, 
			@intUserId, 
			@InventoryShipmentId OUTPUT; 
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