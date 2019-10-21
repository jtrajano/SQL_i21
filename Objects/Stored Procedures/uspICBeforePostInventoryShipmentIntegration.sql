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

-- Call the Grain stored procedures. 
BEGIN 
	DECLARE @intSalesOrderId INT
	SELECT TOP 1 @intSalesOrderId = ISNULL(ISI.intOrderId,0) FROM tblICInventoryShipment [IS]
	INNER JOIN tblICInventoryShipmentItem ISI
		ON ISI.intInventoryShipmentId = [IS].intInventoryShipmentId	
	WHERE [IS].intInventoryShipmentId = @intTransactionId

	IF @ysnPost = 1 --AND ISNULL(@SourceType, @INT_SOURCE_TYPE_NONE) = @INT_SOURCE_TYPE_SCALE		
	BEGIN 
		IF	@OrderType = @INT_ORDER_TYPE_SALES_ORDER AND ISNULL(@SourceType, @INT_SOURCE_TYPE_NONE) = @INT_SOURCE_TYPE_NONE
		BEGIN 
			EXEC dbo.uspSOUpdateOrderShipmentStatus @intSalesOrderId, 'InventoryShipment', 0
		END

		-- Call this to generate the Other Charges coming from Grain. 
		EXEC dbo.uspGRShipped 
			@ItemsFromInventoryShipment
			,@intEntityUserSecurityId
	END 

	IF @ysnPost = 0 --AND ISNULL(@SourceType, @INT_SOURCE_TYPE_NONE) = @INT_SOURCE_TYPE_SCALE
	BEGIN 
		-- Call this to reverse the ticket open balance. 
		EXEC uspGRReverseTicketOpenBalance
				@strSourceType = 'InventoryShipment'
				,@IntSourceKey = @intTransactionId 
				,@intUserId = @intEntityUserSecurityId
	END 
END 

-- Mark stock reservation as posted 
IF @ysnPost = 1
BEGIN 
	EXEC dbo.uspICPostStockReservation
		@intTransactionId
		,@INVENTORY_SHIPMENT_TYPE
		,@ysnPost
END

-- Remove Payables from Vendor Charges (Other charges of IS)
IF @ysnPost = 0
BEGIN
	DECLARE @voucherPayable VoucherPayable

	INSERT INTO @voucherPayable(
		[intEntityVendorId]			
		,[intTransactionType]		
		,[intLocationId]	
		,[intShipToId]	
		,[intShipFromId]			
		,[intShipFromEntityId]
		,[intPayToAddressId]
		,[intCurrencyId]					
		,[dtmDate]				
		,[strVendorOrderNumber]			
		,[strReference]						
		,[strSourceNumber]					
		,[intPurchaseDetailId]				
		,[intContractHeaderId]				
		,[intContractDetailId]				
		,[intContractSeqId]					
		,[intScaleTicketId]					
		,[intInventoryReceiptItemId]		
		,[intInventoryReceiptChargeId]		
		,[intInventoryShipmentItemId]		
		,[intInventoryShipmentChargeId]		
		,[intLoadShipmentId]				
		,[intLoadShipmentDetailId]			
		,[intItemId]						
		,[intPurchaseTaxGroupId]			
		,[strMiscDescription]				
		,[dblOrderQty]						
		,[dblOrderUnitQty]					
		,[intOrderUOMId]					
		,[dblQuantityToBill]				
		,[dblQtyToBillUnitQty]				
		,[intQtyToBillUOMId]				
		,[dblCost]							
		,[dblCostUnitQty]					
		,[intCostUOMId]						
		,[dblNetWeight]						
		,[dblWeightUnitQty]					
		,[intWeightUOMId]					
		,[intCostCurrencyId]
		,[dblTax]							
		,[dblDiscount]
		,[intCurrencyExchangeRateTypeId]	
		,[dblExchangeRate]					
		,[ysnSubCurrency]					
		,[intSubCurrencyCents]				
		,[intAccountId]						
		,[intShipViaId]						
		,[intTermId]						
		,[strBillOfLading]					
		,[ysnReturn]						
	)
	SELECT 
		[intEntityVendorId]			
		,[intTransactionType] = 1
		,[intLocationId]	
		,[intShipToId] = NULL	
		,[intShipFromId] = NULL	 		
		,[intShipFromEntityId] = NULL
		,[intPayToAddressId] = NULL
		,[intCurrencyId] = ISNULL(ShipmentCharges.intCurrencyId, (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference))					
		,[dtmDate]				
		,[strVendorOrderNumber] = Shipment.strBOLNumber
		,[strReference]						
		,[strSourceNumber]					
		,[intPurchaseDetailId] = NULL				
		,[intContractHeaderId]				
		,[intContractDetailId]				
		,[intContractSeqId] = NULL					
		,[intScaleTicketId]					
		,[intInventoryReceiptItemId] = NULL	
		,[intInventoryReceiptChargeId] = NULL
		,[intInventoryShipmentItemId]		
		,[intInventoryShipmentChargeId]		
		,[intLoadShipmentId] = NULL				
		,[intLoadShipmentDetailId] = NULL			
		,[intItemId]						
		,[intPurchaseTaxGroupId] = NULL		
		,[strMiscDescription]				
		,[dblOrderQty]						
		,[dblOrderUnitQty] = 0.00					
		,[intOrderUOMId] = NULL	 				
		,[dblQuantityToBill] 			
		,[dblQtyToBillUnitQty] = CAST(1 AS DECIMAL(38,20))				
		,[intQtyToBillUOMId] = NULL		
		,[dblCost] = CASE WHEN ShipmentCharges.dblOrderQty > 1 -- PER UNIT
						THEN CASE WHEN ShipmentCharges.ysnSubCurrency > 0 THEN CAST(ShipmentCharges.dblUnitCost AS DECIMAL(38,20)) / ISNULL(ShipmentCharges.intSubCurrencyCents,100) ELSE CAST(ShipmentCharges.dblUnitCost AS DECIMAL(38,20))  END
						ELSE CAST(ShipmentCharges.dblUnitCost AS DECIMAL(38,20))
						END							
		,[dblCostUnitQty] = CAST(1 AS DECIMAL(38,20))
		,[intCostUOMId]	= ShipmentCharges.intCostUnitMeasureId
		,[dblNetWeight]	= CAST(0 AS DECIMAL(38,20))
		,[dblWeightUnitQty]	= CAST(1 AS DECIMAL(38,20))				
		,[intWeightUOMId] = NULL
		,[intCostCurrencyId] = ShipmentCharges.intCurrencyId
		,[dblTax]							
		,[dblDiscount] = 0
		,[intCurrencyExchangeRateTypeId] = ShipmentCharges.intForexRateTypeId
		,[dblExchangeRate] = ShipmentCharges.dblForexRate
		,[ysnSubCurrency]					
		,[intSubCurrencyCents]				
		,[intAccountId]						
		,[intShipViaId]						
		,[intTermId] = NULL 			
		,[strBillOfLading] = Shipment.strBOLNumber
		,[ysnReturn] = 0 
	FROM vyuICShipmentChargesPayables ShipmentCharges
	LEFT JOIN tblICInventoryShipment Shipment
		ON Shipment.intInventoryShipmentId = ShipmentCharges.intInventoryShipmentId
	WHERE Shipment.intInventoryShipmentId = @intTransactionId
		AND Shipment.ysnPosted = 0

	EXEC dbo.uspAPRemoveVoucherPayable @voucherPayable

END

_Exit: