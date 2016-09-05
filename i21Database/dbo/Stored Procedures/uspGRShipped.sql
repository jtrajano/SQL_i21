CREATE PROCEDURE [dbo].[uspGRShipped]
	@ItemsFromInventoryShipment ShipmentItemTableType READONLY 
	,@intEntityUserSecurityId AS INT = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


-- Clean up the list of items. 
BEGIN 
	DECLARE @StorageItems AS ShipmentItemTableType

	INSERT INTO @StorageItems (
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
	SELECT 
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
	FROM @ItemsFromInventoryShipment
	-- TODO: Add a where clause if system only needs to process 'Storage' type stocks. 
END 

-- Delete any existing "Storage Charge" from the shipment charge table. 
BEGIN 
	DELETE	shipmentCharge 
	FROM	tblICInventoryShipmentCharge shipmentCharge INNER JOIN tblICItem i
				ON shipmentCharge.intChargeId = i.intItemId
			INNER JOIN @StorageItems si
				ON si.intInventoryShipmentItemId = shipmentCharge.intInventoryShipmentId
	WHERE	i.strCostType = 'Storage Charge'
			and i.strType = 'Other Charge'
END 

IF NOT EXISTS (SELECT TOP 1 1 FROM @StorageItems) 
	GOTO _Exit;

-- Add other charges from Grain
BEGIN 
	-- Create a table variable to store the other charges create by Grain. 
	DECLARE @StorageTicketInfoByFIFO AS TABLE 
	(
		[intCustomerStorageId] INT
		,[strStorageTicketNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,[dblOpenBalance] NUMERIC(18, 6)
		,[intUnitMeasureId] INT
		,[strUnitMeasure] NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,[strItemType] NVARCHAR(50) COLLATE Latin1_General_CI_AS ---'Inventory','Storage Charge','Fee','Discount'
		,[intItemId] INT
		,[strItem] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,[dblCharge] DECIMAL(24, 10)
		,[intInventoryShipmentId] INT NULL 
		,[intInventoryShipmentItemId] INT NULL 
	)

	DECLARE @intCustomerEntityId AS INT
			,@intItemId AS INT 
			,@intStorageTypeId AS INT 
			,@dblUnits AS NUMERIC(38, 20) 
			,@intTicketId AS INT -- Default to NULL. Inventory Shipment is calling uspGRShipped if Order Type is 'Sales Order', 'Direct', and Source type is not 'Scale'. 
			,@intId AS INT 
			,@intInventoryShipmentId AS INT 
			,@intInventoryShipmentItemId AS INT 

	WHILE EXISTS (SELECT TOP 1 1 FROM @StorageItems)
	BEGIN 
		-- Get the top record to begin the loop. 
		SELECT	TOP 1 
				@intId = intId
				,@intItemId = intItemId
				,@dblUnits = dbo.fnCalculateQtyBetweenUOM(
								storageItem.intItemUOMId
								,dbo.fnGetItemStockUOM(storageItem.intItemId)
								,storageItem.dblQty
							)
				,@intInventoryShipmentItemId = storageItem.intInventoryShipmentItemId		
		FROM	@StorageItems storageItem 

		SELECT 	@intStorageTypeId = gcs.intStorageTypeId
				,@intInventoryShipmentId = shipItem.intInventoryShipmentId
		FROM	tblICInventoryShipmentItem shipItem	INNER JOIN tblGRCustomerStorage gcs
					ON gcs.intCustomerStorageId = shipItem.intCustomerStorageId					
		WHERE	shipItem.intInventoryShipmentItemId = @intInventoryShipmentItemId

		-- Call the Grain sp. 
		BEGIN TRY 
			-- Get the charges created by the Grain sp. 
			INSERT INTO @StorageTicketInfoByFIFO 
			(
				[intCustomerStorageId]
				,[strStorageTicketNumber]
				,[dblOpenBalance]
				,[intUnitMeasureId]
				,[strUnitMeasure]
				,[strItemType]
				,[intItemId]
				,[strItem]
				,[dblCharge]
			)
			EXEC uspGRUpdateGrainOpenBalanceByFIFO 
				'Update'
				,'InventoryShipment'
				, @intCustomerEntityId
				, @intItemId
				, @intStorageTypeId
				, @dblUnits
				, @intTicketId 
				, @intEntityUserSecurityId

			-- Populate the link ids for the shipment and shipment detail id. 
			UPDATE	@StorageTicketInfoByFIFO
			SET		intInventoryShipmentId = @intInventoryShipmentId
					,intInventoryShipmentItemId = @intInventoryShipmentItemId
			WHERE	intInventoryShipmentId IS NULL 
		END TRY 
		BEGIN CATCH 
			DECLARE @ErrMsg	NVARCHAR(MAX)
			SET @ErrMsg = ERROR_MESSAGE()  
			RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
			GOTO _Exit; 
		END CATCH 
		
		-- Delete the loop record. 
		DELETE FROM @StorageItems WHERE intId = @intId
	END 
	
	-- Insert the other charge into the Shipment Charge table. 
	BEGIN 
		INSERT INTO tblICInventoryShipmentCharge (
			[intInventoryShipmentId] 
			,[intContractId] 
			,[intChargeId] 
			,[strCostMethod] 
			,[dblRate] 
			,[intCostUOMId] 
			,[intCurrencyId] 
			,[dblAmount] 
			,[ysnAccrue] 
			,[intEntityVendorId] 
			,[ysnPrice] 
		)
		SELECT 
			[intInventoryShipmentId]	= grainCharge.intInventoryShipmentId
			,[intContractId]			= NULL -- Shipment is a "Sales Order" / "Direct" type. It will not have contract id.  
			,[intChargeId]				= grainCharge.intItemId
			,[strCostMethod]			= charge.strCostMethod
			,[dblRate]					= grainCharge.dblCharge
			,[intCostUOMId]				= charge.intCostUOMId
			,[intCurrencyId]			= dbo.fnSMGetDefaultCurrency('FUNCTIONAL') -- uspGRUpdateGrainOpenBalanceByFIFO is not returning a currency id. Use the default functional currency. 
			,[dblAmount]				= grainCharge.dblCharge
			,[ysnAccrue]				= charge.ysnAccrue
			,[intEntityVendorId]		= NULL -- uspGRUpdateGrainOpenBalanceByFIFO is not returning a vendor id. So I assume all storage charges are meant to increase the receivable from shipment customer. 
			,[ysnPrice]					= charge.ysnPrice
		FROM @StorageTicketInfoByFIFO grainCharge INNER JOIN tblICItem charge
				ON grainCharge.intItemId = charge.intItemId

	END 
END 

_Exit:

