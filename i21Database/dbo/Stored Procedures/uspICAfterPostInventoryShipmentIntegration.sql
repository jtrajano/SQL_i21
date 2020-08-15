CREATE PROCEDURE uspICAfterPostInventoryShipmentIntegration
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
		,@STR_ORDER_TYPE_ITEM_CONTRACT AS NVARCHAR(50) = 'Item Contract'

		,@INT_ORDER_TYPE_SALES_CONTRACT AS INT = 1
		,@INT_ORDER_TYPE_SALES_ORDER AS INT = 2
		,@INT_ORDER_TYPE_TRANSFER_ORDER AS INT = 3
		,@INT_ORDER_TYPE_DIRECT AS INT = 4
		,@INT_ORDER_TYPE_ITEM_CONTRACT AS INT = 5

		-- Source Types
		,@STR_SOURCE_TYPE_NONE AS NVARCHAR(50) = 'None'
		,@STR_SOURCE_TYPE_SCALE AS NVARCHAR(50) = 'Scale'
		,@STR_SOURCE_TYPE_INBOUND_SHIPMENT AS NVARCHAR(50) = 'Inbound Shipment'
		,@STR_SOURCE_TYPE_TRANSPORT AS NVARCHAR(50) = 'Transport'

		,@INT_SOURCE_TYPE_NONE AS INT = 0
		,@INT_SOURCE_TYPE_SCALE AS INT = 1
		,@INT_SOURCE_TYPE_INBOUND_SHIPMENT AS INT = 2
		,@INT_SOURCE_TYPE_TRANSPORT AS INT = 3

DECLARE @INVENTORY_SHIPMENT_TYPE AS INT = 5

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
		,[intEntityCustomerId]

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
		,[intStorageScheduleTypeId]
		,[ysnLoad]
		,[intLoadShipped]
		,[intItemContractHeaderId]
		,[intItemContractDetailId]
	)
	EXEC dbo.uspICGetItemsFromItemShipment
		@intShipmentId = @intTransactionId

	-- Change quantity to negative if doing a post. Otherwise, it should be the same value if doing an unpost. 
	UPDATE @ItemsFromInventoryShipment
	SET dblQty = dblQty * CASE WHEN @ysnPost = 1 THEN -1 ELSE 1 END,
		intLoadShipped = CASE WHEN ysnLoad = 1 THEN intLoadShipped * CASE WHEN @ysnPost = 1 THEN -1 ELSE 1 END ELSE NULL END
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

-- Call the integration scripts based on Order type
BEGIN 
	-- Update the shipped quantities back to the Contract Management
	IF @OrderType = @INT_ORDER_TYPE_SALES_CONTRACT  
	BEGIN   
		 EXEC dbo.uspCTShipped @ItemsFromInventoryShipment ,@intEntityUserSecurityId ,@ysnPost
	END  

	IF @OrderType = @INT_ORDER_TYPE_ITEM_CONTRACT
	BEGIN 
		EXEC dbo.uspCTItemContractShipped @ItemsFromInventoryShipment ,@intEntityUserSecurityId ,@ysnPost
	END 

	-- Update the shipped quantities back to Account Receivable
	IF	@OrderType = @INT_ORDER_TYPE_SALES_ORDER AND ISNULL(@SourceType, @INT_SOURCE_TYPE_NONE) = @INT_SOURCE_TYPE_NONE
	BEGIN 
		EXEC dbo.uspSOShipped @ItemsFromInventoryShipment, @ysnPost
	END
END 

-- Call the integration scripts based on Source Type
BEGIN 
	-- Update the shipped quantities back to Inbound Shipment 
	IF	ISNULL(@SourceType, @INT_SOURCE_TYPE_NONE) = @INT_SOURCE_TYPE_INBOUND_SHIPMENT
	BEGIN 
		EXEC dbo.uspLGShipped 
			@ItemsFromInventoryShipment
			,@intEntityUserSecurityId
	END

	-- Update the shipped quantities back to a Scale Ticket
	IF	ISNULL(@SourceType, @INT_SOURCE_TYPE_NONE) = @INT_SOURCE_TYPE_SCALE
	BEGIN 
		EXEC dbo.uspSCShipped 
			@ItemsFromInventoryShipment
			,@intEntityUserSecurityId
	END

	-- Update the shipped quantities back to Transport
	IF	ISNULL(@SourceType, @INT_SOURCE_TYPE_NONE) = @INT_SOURCE_TYPE_TRANSPORT
	BEGIN 
		EXEC dbo.uspTRShipped 
			@ItemsFromInventoryShipment
			,@intEntityUserSecurityId
	END
END 

-- Mark stock reservation as unposted
IF @ysnPost = 0
BEGIN 
	EXEC dbo.uspICPostStockReservation
		@intTransactionId
		,@INVENTORY_SHIPMENT_TYPE
		,@ysnPost
END

_Exit: 