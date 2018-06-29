CREATE PROCEDURE [dbo].[uspICAllocateInventoryShipmentOtherCharges]
	@intInventoryShipmentId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Declare the variables
BEGIN
	-- Constants
	DECLARE @COST_METHOD_Per_Unit AS NVARCHAR(50) = 'Per Unit'
			,@COST_METHOD_Percentage AS NVARCHAR(50) = 'Percentage'
			,@COST_METHOD_Amount AS NVARCHAR(50) = 'Amount'

			,@ALLOCATE_PRICE_BY_Unit AS NVARCHAR(50) = 'Unit'
			,@ALLOCATE_PRICE_BY_Stock_Unit AS NVARCHAR(50) = 'Stock Unit'
			,@ALLOCATE_PRICE_BY_Weight AS NVARCHAR(50) = 'Weight'
			,@ALLOCATE_PRICE_BY_Price AS NVARCHAR(50) = 'Price'

			,@UNIT_TYPE_Weight AS NVARCHAR(50) = 'Weight'

	DECLARE @strItemNo AS NVARCHAR(50)
			,@strUnitMeasure AS NVARCHAR(50)
			,@intItemId AS INT

	DECLARE	-- Shipment Types
			@SHIPMENT_TYPE_Sales_Contract AS NVARCHAR(50) = 'Sales Contract'
			,@SHIPMENT_TYPE_Sales_Order AS NVARCHAR(50) = 'Sales Order'
			,@SHIPMENT_TYPE_Transfer_Order AS NVARCHAR(50) = 'Transfer Order'
			,@SHIPMENT_TYPE_Direct AS NVARCHAR(50) = 'Direct'
			-- Source Types
			,@SOURCE_TYPE_None AS INT = 0
			,@SOURCE_TYPE_Scale AS INT = 1
			,@SOURCE_TYPE_Inbound_Shipment AS INT = 2
			,@SOURCE_TYPE_PickLot AS INT = 3
				
	DECLARE @totalOtherCharges AS NUMERIC(38,20)
			,@intContractId AS INT 
END 

-- Do the validation
BEGIN 
	-- Check if there are shipment charges to process
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblICInventoryShipmentCharge WHERE intInventoryShipmentId = @intInventoryShipmentId)
	BEGIN
		-- Exit and do nothing. 
		GOTO _Exit
	END
END

-- Remove the allocated records for the inventory shipment. 
BEGIN 
	DELETE FROM dbo.tblICInventoryShipmentItemAllocatedCharge
	WHERE intInventoryShipmentId = @intInventoryShipmentId
END 

-- Allocate the other price by contract. 
BEGIN 

	-- Allocate price by 'unit'
	EXEC dbo.uspICAllocateInventoryShipmentOtherChargesByContractAndUnits
		@intInventoryShipmentId
	IF @@ERROR <> 0 GOTO _Exit;

	-- Allocate by 'price'
	EXEC dbo.uspICAllocateInventoryShipmentOtherChargesByContractAndPrice
		@intInventoryShipmentId
	IF @@ERROR <> 0 GOTO _Exit;

	-- Allocate by 'stock unit'
	EXEC dbo.uspICAllocateInventoryShipmentOtherChargesByContractAndStockUnit
		@intInventoryShipmentId
	IF @@ERROR <> 0 GOTO _Exit;
END

-- Allocate the other price that is not bound by a contract
BEGIN 
	-- Allocate the other price by unit
	BEGIN 	
		EXEC dbo.uspICAllocateInventoryShipmentOtherChargesByUnits
			@intInventoryShipmentId
		IF @@ERROR <> 0 GOTO _Exit;
	END 

	-- Allocate by price
	BEGIN 	
		EXEC dbo.uspICAllocateInventoryShipmentOtherChargesByPrice
			@intInventoryShipmentId
		IF @@ERROR <> 0 GOTO _Exit;
	END 

	-- Allocate by stock unit
	BEGIN 	
		EXEC dbo.uspICAllocateInventoryShipmentOtherChargesByStockUnit
			@intInventoryShipmentId
		IF @@ERROR <> 0 GOTO _Exit;
	END 
END

-- Exit point
_Exit: