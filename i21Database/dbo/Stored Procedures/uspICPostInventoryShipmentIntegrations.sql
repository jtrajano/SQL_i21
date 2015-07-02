CREATE PROCEDURE uspICPostInventoryShipmentIntegrations
	@ysnPost BIT  = 0  
	,@intTransactionId NVARCHAR(40) = NULL   
	,@intUserId  INT  = NULL   
	,@intEntityId INT  = NULL    
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
		,@INT_ORDER_TYPE_SALES_CONTRACT AS INT = 1
		,@INT_ORDER_TYPE_SALES_ORDER AS INT = 2
		,@INT_ORDER_TYPE_TRANSFER_ORDER AS INT = 3

		-- Source Types
		,@STR_SOURCE_TYPE_NONE AS NVARCHAR(50) = 'None'
		,@STR_SOURCE_TYPE_SCALE AS NVARCHAR(50) = 'Scale'
		,@STR_SOURCE_TYPE_INBOUND_SHIPMENT AS NVARCHAR(50) = 'Inbound Shipment'

		,@INT_SOURCE_TYPE_NONE AS INT = 0
		,@INT_SOURCE_TYPE_SCALE AS INT = 1
		,@INT_SOURCE_TYPE_INBOUND_SHIPMENT AS INT = 2

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
	EXEC dbo.uspICGetItemsFromItemReceipt
		@intReceiptId = @intTransactionId

	UPDATE @ItemsFromInventoryShipment
	SET dblQty = dblQty * CASE WHEN @ysnPost = 1 THEN -1 ELSE 1 END 
END

-- Get the receipt-type and source-type from tblICInventoryReceipt
BEGIN 
	DECLARE @ReceiptType AS NVARCHAR(50) 
			,@SourceType AS INT 
	
	SELECT	@ReceiptType = strReceiptType
			,@SourceType = intSourceType
	FROM	tblICInventoryReceipt 
	WHERE	intInventoryReceiptId = @intTransactionId 
END 

-- Update the received quantities back to the Purchase Order
IF	@ReceiptType = @RECEIPT_TYPE_PURCHASE_ORDER 
	AND ISNULL(@SourceType, @SOURCE_TYPE_NONE) = @SOURCE_TYPE_NONE
BEGIN 
	EXEC dbo.[uspPOReceived] @ItemsFromInventoryReceipt
	GOTO _Exit;
END

-- Update the received quantities back to Inbound Shipment 
IF	ISNULL(@SourceType, @SOURCE_TYPE_NONE) = @SOURCE_TYPE_INBOUND_SHIPMENT
BEGIN 
	EXEC dbo.uspLGReceived @ItemsFromInventoryReceipt
	GOTO _Exit;
END

-- Update the received quantities back to a Scale Ticket
IF	ISNULL(@SourceType, @SOURCE_TYPE_NONE) = @SOURCE_TYPE_SCALE
BEGIN 
	EXEC dbo.uspSCReceived @ItemsFromInventoryReceipt
	GOTO _Exit;
END

-- Update the received quantities back to Transport Order
IF	ISNULL(@SourceType, @SOURCE_TYPE_NONE) = @SOURCE_TYPE_TRANSPORT
BEGIN 
	EXEC dbo.uspTRReceived @ItemsFromInventoryReceipt
	GOTO _Exit;
END

_Exit: 