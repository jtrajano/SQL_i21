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

-- Set to zero all the existing other charges in receipt item table. 
BEGIN 
	UPDATE	dbo.tblICInventoryReceiptItem
	SET		dblOtherCharges = 0.00
	WHERE	intInventoryReceiptId = @intInventoryReceiptId
END 

-- Allocate the other cost by contract. 
BEGIN 
	IF EXISTS (
		SELECT	TOP 1 1
		FROM	dbo.tblICInventoryReceipt Receipt 
		WHERE	ReceiptItem.intInventoryReceiptId = @intInventoryReceiptId
				AND Receipt.strReceiptType = @RECEIPT_TYPE_Purchase_Contract
	)
	BEGIN
		DECLARE loopContracts CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT	OtherCharge.intContractId
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptChargePerItem OtherCharge
					ON Receipt.intInventoryReceiptId = OtherCharge.intInventoryReceiptId	
		WHERE	ReceiptItem.intInventoryReceiptId = @intInventoryReceiptId
				AND Receipt.strReceiptType = @RECEIPT_TYPE_Purchase_Contract

		-- Initial fetch attempt
		FETCH NEXT FROM loopContracts INTO 
			@intContractId;

		-----------------------------------------------------------------------------------------------------------------------------
		-- Start of the loop
		-----------------------------------------------------------------------------------------------------------------------------
		WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE @totalOtherChargesForContracts_AllocateByUnit AS NUMERIC(38,20)
					,@totalOtherChargesForContracts_AllocateByWeight AS NUMERIC(38,20)
					,@totalOtherChargesForContracts_AllocateByCost AS NUMERIC(38,20)

			-- Get the total other charges with 'allocate cost' set to 'unit'. 
			SELECT	@totalOtherChargesForContracts_AllocateByUnit = SUM(dblCalculatedAmount)
			FROM	dbo.tblICInventoryReceiptChargePerItem OtherCharge
			WHERE	OtherCharge.intInventoryReceiptId = @intInventoryReceiptId
					AND OtherCharge.intContractId = @intContractId
					AND OtherCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Unit

			-- Get the total other charges with 'allocate cost' set to 'weight'. 
			SELECT	@totalOtherChargesForContracts_AllocateByWeight = SUM(dblCalculatedAmount)
			FROM	dbo.tblICInventoryReceiptChargePerItem OtherCharge
			WHERE	OtherCharge.intInventoryReceiptId = @intInventoryReceiptId
					AND OtherCharge.intContractId = @intContractId
					AND OtherCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Weight

			-- Get the total other charges with 'allocate cost' set to 'cost'. 
			SELECT	@totalOtherChargesForContracts_AllocateByCost = SUM(dblCalculatedAmount)
			FROM	dbo.tblICInventoryReceiptChargePerItem OtherCharge
			WHERE	OtherCharge.intInventoryReceiptId = @intInventoryReceiptId
					AND OtherCharge.intContractId = @intContractId
					AND OtherCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Cost

			-- Allocate cost by 'unit'
			UPDATE	ReceiptItem
			SET		dblOtherCharges = OtherChargeByContract.dblCalculatedAmount
			FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem 
						ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId	
					INNER JOIN (
						SELECT	dblCalculatedAmount = SUM(dblCalculatedAmount)
								,OtherCharge.intContractId
						FROM	dbo.tblICInventoryReceiptChargePerItem OtherCharge
						WHERE	OtherCharge.intInventoryReceiptId = @intInventoryReceiptId
								AND OtherCharge.intContractId IS NOT NULL 
						GROUP BY OtherCharge.intContractId
					) OtherChargeByContract
						ON ReceiptItem.intOrderId = OtherChargeByContract.intContractId
			WHERE	ReceiptItem.intInventoryReceiptId = @intInventoryReceiptId
					AND Receipt.strReceiptType = @RECEIPT_TYPE_Purchase_Contract

			UPDATE	ReceiptItem
			SET		dblOtherCharges = ReceiptItem.dblOtherCharges + @totalOtherCharges
			FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem 
						ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId	
			WHERE	ReceiptItem.intInventoryReceiptId = @intInventoryReceiptId
					AND Receipt.strReceiptType = @RECEIPT_TYPE_Purchase_Contract

			-- Attempt to fetch the next row from cursor. 
			FETCH NEXT FROM loopContracts INTO 
				@intContractId;
		END;
		-----------------------------------------------------------------------------------------------------------------------------
		-- End of the loop
		-----------------------------------------------------------------------------------------------------------------------------

		-- Deallocate the cursor objects. 
		CLOSE loopContracts;
		DEALLOCATE loopContracts;
	END 
END 

-- Allocate the other cost by unit
BEGIN 
	-- Get the total other charges with 'allocate cost' set to 'unit'. 
	SELECT	@totalOtherCharges = SUM(dblCalculatedAmount)
	FROM	dbo.tblICInventoryReceiptChargePerItem OtherCharge
	WHERE	OtherCharge.intInventoryReceiptId = @intInventoryReceiptId
			AND OtherCharge.intContractId IS NULL
			AND OtherCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Unit

	UPDATE	ReceiptItem
	SET		dblOtherCharges = ReceiptItem.dblOtherCharges + @totalOtherCharges
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem 
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId	
	WHERE	ReceiptItem.intInventoryReceiptId = @intInventoryReceiptId

END 


-- Exit point
_Exit: