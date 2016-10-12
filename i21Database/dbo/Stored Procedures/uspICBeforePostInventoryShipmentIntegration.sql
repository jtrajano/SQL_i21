CREATE PROCEDURE uspICBeforePostInventoryShipmentIntegration
	@ysnPost BIT = 0  
	,@intTransactionId INT = NULL   
	,@intEntityUserSecurityId INT  = NULL      
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

-- Declare the constants 
DECLARE	-- Order Types
		@STR_ORDER_TYPE_SALES_CONTRACT AS NVARCHAR(50) = 'Sales Contract'
		,@STR_ORDER_TYPE_SALES_ORDER AS NVARCHAR(50) = 'Sales Order'
		,@STR_ORDER_TYPE_TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'
		,@STR_ORDER_TYPE_DIRECT AS NVARCHAR(50) = 'Direct'
		,@INT_ORDER_TYPE_SALES_CONTRACT AS INT = 1
		,@INT_ORDER_TYPE_SALES_ORDER AS INT = 2
		,@INT_ORDER_TYPE_TRANSFER_ORDER AS INT = 3
		,@INT_ORDER_TYPE_DIRECT AS INT = 4

		-- Source Types
		,@STR_SOURCE_TYPE_NONE AS NVARCHAR(50) = 'None'
		,@STR_SOURCE_TYPE_SCALE AS NVARCHAR(50) = 'Scale'
		,@STR_SOURCE_TYPE_INBOUND_SHIPMENT AS NVARCHAR(50) = 'Inbound Shipment'
		,@STR_SOURCE_TYPE_TRANSPORT AS NVARCHAR(50) = 'Transport'

		,@INT_SOURCE_TYPE_NONE AS INT = 0
		,@INT_SOURCE_TYPE_SCALE AS INT = 1
		,@INT_SOURCE_TYPE_INBOUND_SHIPMENT AS INT = 2
		,@INT_SOURCE_TYPE_TRANSPORT AS INT = 3

-- Get the details from the inventory receipt 
BEGIN 
	DECLARE @ItemsFromInventoryShipment AS dbo.ShipmentItemTableType
	INSERT INTO @ItemsFromInventoryShipment (
		-- Header
		[intShipmentId]
		,[strShipmentId]
		,[intOrderType]
		,[intSourceType]
		,[dtmDate]
		,[intCurrencyId]
		,[dblExchangeRate]

		-- Detail 
		,[intInventoryShipmentItemId]
		,[intItemId]
		,[intLotId]
		,[strLotNumber]
		,[intLocationId]
		,[intItemLocationId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[intItemUOMId]
		,[intWeightUOMId]
		,[dblQty]
		,[dblUOMQty]
		,[dblNetWeight]
		,[dblSalesPrice]
		,[intDockDoorId]
		,[intOwnershipType]
		,[intOrderId]
		,[intSourceId]
		,[intLineNo]
	)
	EXEC dbo.uspICGetItemsFromItemShipment
		@intShipmentId = @intTransactionId

	-- Change quantity to negative if doing a post. Otherwise, it should be the same value if doing an unpost. 
	UPDATE @ItemsFromInventoryShipment
	SET dblQty = CASE WHEN @ysnPost = 1 THEN -dblQty ELSE dblQty END 
END

-- Get the Order-type and Source-type from tblICInventoryShipment
BEGIN 
	DECLARE @OrderType AS INT 
			,@SourceType AS INT 
	
	SELECT	@OrderType = intOrderType
			,@SourceType = intSourceType
	FROM	tblICInventoryShipment
	WHERE	intInventoryShipmentId = @intTransactionId 
END 

-- Update the Grain bank if the item is coming from Sales Order or Direct type. 
-- and it is not coming from Scale. 
BEGIN 
	IF	@OrderType IN (@INT_ORDER_TYPE_SALES_ORDER, @INT_ORDER_TYPE_DIRECT)
		AND ISNULL(@SourceType, @INT_SOURCE_TYPE_NONE) <> @INT_SOURCE_TYPE_SCALE		
	BEGIN 
		IF @ysnPost = 1
		BEGIN 
			EXEC dbo.uspGRShipped 
				@ItemsFromInventoryShipment
				,@intEntityUserSecurityId
		END 
		ELSE IF @ysnPost = 0 
		BEGIN 
			EXEC uspGRReverseTicketOpenBalance
				   @strSourceType = 'InventoryShipment'
				  ,@IntSourceKey = @intTransactionId 
				  ,@intUserId = @intEntityUserSecurityId
		END 
	END
END 

_Exit: 