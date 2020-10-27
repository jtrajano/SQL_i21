CREATE PROCEDURE [dbo].[uspICAllocateInventoryReceiptOtherCharges]
	@intInventoryReceiptId AS INT 
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

			,@ALLOCATE_COST_BY_Unit AS NVARCHAR(50) = 'Unit'
			,@ALLOCATE_COST_BY_Stock_Unit AS NVARCHAR(50) = 'Stock Unit'
			,@ALLOCATE_COST_BY_Weight AS NVARCHAR(50) = 'Weight'
			,@ALLOCATE_COST_BY_Cost AS NVARCHAR(50) = 'Cost'

			,@UNIT_TYPE_Weight AS NVARCHAR(50) = 'Weight'

	DECLARE @strItemNo AS NVARCHAR(50)
			,@strUnitMeasure AS NVARCHAR(50)
			,@intItemId AS INT

	DECLARE	-- Receipt Types
			@RECEIPT_TYPE_Purchase_Contract AS NVARCHAR(50) = 'Purchase Contract'
			,@RECEIPT_TYPE_Purchase_Order AS NVARCHAR(50) = 'Purchase Order'
			,@RECEIPT_TYPE_Transfer_Order AS NVARCHAR(50) = 'Transfer Order'
			,@RECEIPT_TYPE_Direct AS NVARCHAR(50) = 'Direct'
			-- Source Types
			,@SOURCE_TYPE_None AS INT = 0
			,@SOURCE_TYPE_Scale AS INT = 1
			,@SOURCE_TYPE_Inbound_Shipment AS INT = 2
			,@SOURCE_TYPE_Transport AS INT = 3
				
	DECLARE @totalOtherCharges AS NUMERIC(38,20)
			,@intContractId AS INT 
END 

-- Do the validation
BEGIN 
	-- Check if there are receipt charges to process
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblICInventoryReceiptCharge WHERE intInventoryReceiptId = @intInventoryReceiptId)
	BEGIN
		-- Exit and do nothing. 
		GOTO _Exit
	END
END

-- Remove the allocated records for the inventory receipt. 
BEGIN 
	DELETE FROM dbo.tblICInventoryReceiptItemAllocatedCharge
	WHERE intInventoryReceiptId = @intInventoryReceiptId
END 

-- Allocate the other cost by contract. 
BEGIN 

	-- Allocate cost by 'unit'
	EXEC dbo.uspICAllocateInventoryReceiptOtherChargesByContractAndUnits
		@intInventoryReceiptId
	IF @@ERROR <> 0 GOTO _Exit;

	-- Allocate by 'cost'
	EXEC dbo.uspICAllocateInventoryReceiptOtherChargesByContractAndCost
		@intInventoryReceiptId
	IF @@ERROR <> 0 GOTO _Exit;

	-- Allocate by 'stock unit'
	EXEC dbo.uspICAllocateInventoryReceiptOtherChargesByContractAndStockUnit
		@intInventoryReceiptId
	IF @@ERROR <> 0 GOTO _Exit;
END

-- Allocate the other costs that is not bound by a contract
BEGIN 
	-- Allocate the other cost by unit
	BEGIN 	
		EXEC dbo.uspICAllocateInventoryReceiptOtherChargesByUnits
			@intInventoryReceiptId
		IF @@ERROR <> 0 GOTO _Exit;
	END 

	-- Allocate by cost
	BEGIN 	
		EXEC dbo.uspICAllocateInventoryReceiptOtherChargesByCost
			@intInventoryReceiptId
		IF @@ERROR <> 0 GOTO _Exit;
	END 

	-- Allocate by stock unit
	BEGIN 	
		EXEC dbo.uspICAllocateInventoryReceiptOtherChargesByStockUnit
			@intInventoryReceiptId
		IF @@ERROR <> 0 GOTO _Exit;
	END 
END

-- Validate the Other charges -> ysnInventoryCost = true. 
-- Check if the charge was properly allocated or not. 
BEGIN 
	EXEC [uspICValidateAllocateInventoryReceiptOtherCharges] @intInventoryReceiptId
	IF @@ERROR <> 0 GOTO _Exit;
END 

-- Exit point
_Exit: