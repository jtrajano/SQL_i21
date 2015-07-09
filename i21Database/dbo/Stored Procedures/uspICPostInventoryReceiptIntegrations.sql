CREATE PROCEDURE uspICPostInventoryReceiptIntegrations
	@ysnPost BIT  = 0  
	,@intTransactionId INT = NULL   
	,@intUserId  INT  = NULL   
	,@intEntityId INT  = NULL    
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

-- Declare the constants 
DECLARE	-- Receipt Types
		@RECEIPT_TYPE_PURCHASE_CONTRACT AS NVARCHAR(50) = 'Purchase Contract'
		,@RECEIPT_TYPE_PURCHASE_ORDER AS NVARCHAR(50) = 'Purchase Order'
		,@RECEIPT_TYPE_TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'
		,@RECEIPT_TYPE_DIRECT AS NVARCHAR(50) = 'Direct'
		-- Source Types
		,@SOURCE_TYPE_NONE AS INT = 0
		,@SOURCE_TYPE_SCALE AS INT = 1
		,@SOURCE_TYPE_INBOUND_SHIPMENT AS INT = 2
		,@SOURCE_TYPE_TRANSPORT AS INT = 3

-- Get the details from the inventory receipt 
BEGIN 
	DECLARE @ItemsFromInventoryReceipt AS dbo.ReceiptItemTableType
	INSERT INTO @ItemsFromInventoryReceipt (
		-- Header
		[intInventoryReceiptId] 
		,[strInventoryReceiptId] 
		,[strReceiptType] 
		,[intSourceType] 
		,[dtmDate] 
		,[intCurrencyId] 
		,[dblExchangeRate] 
		-- Detail 
		,[intInventoryReceiptDetailId] 
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
		,[dblCost] 
		,[intContainerId] 
		,[intOwnershipType] 
		,[intOrderId] 
		,[intSourceId] 
		,[intLineNo] 
	)
	EXEC dbo.uspICGetItemsFromItemReceipt
		@intReceiptId = @intTransactionId

	UPDATE @ItemsFromInventoryReceipt
	SET dblQty = dblQty * CASE WHEN @ysnPost = 1 THEN 1 ELSE -1 END 
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