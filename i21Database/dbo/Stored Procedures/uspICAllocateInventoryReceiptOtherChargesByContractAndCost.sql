﻿CREATE PROCEDURE [dbo].[uspICAllocateInventoryReceiptOtherChargesByContractAndCost]
	@intInventoryReceiptId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Constants
DECLARE @COST_METHOD_Per_Unit AS NVARCHAR(50) = 'Per Unit'
		,@COST_METHOD_Percentage AS NVARCHAR(50) = 'Percentage'
		,@COST_METHOD_Amount AS NVARCHAR(50) = 'Amount'

		,@ALLOCATE_COST_BY_Unit AS NVARCHAR(50) = 'Unit'
		,@ALLOCATE_COST_BY_Stock_Unit AS NVARCHAR(50) = 'Stock Unit'
		,@ALLOCATE_COST_BY_Weight AS NVARCHAR(50) = 'Weight'
		,@ALLOCATE_COST_BY_Cost AS NVARCHAR(50) = 'Cost'

		,@UNIT_TYPE_Weight AS NVARCHAR(50) = 'Weight'

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

-- Allocate by 'cost'
--BEGIN 
--	DECLARE @totalOtherChargesForContracts_AllocateByCost AS NUMERIC(38,20)
--			,@totalCostOfAllItems AS NUMERIC(18,2)

--	-- Get the total other charges with 'allocate cost' set to 'cost'. 
--	SELECT	@totalOtherChargesForContracts_AllocateByCost = SUM(dblCalculatedAmount)
--	FROM	dbo.tblICInventoryReceiptChargePerItem OtherCharge
--	WHERE	OtherCharge.intInventoryReceiptId = @intInventoryReceiptId
--			AND OtherCharge.intContractId = @intContractId
--			AND OtherCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Cost

--	-- If there are no other charge to process, then exit.
--	IF ISNULL(@totalOtherChargesForContracts_AllocateByCost, 0) = 0 
--		GOTO _Exit;

--	-- Get the total cost from items that share the same contract id. 
--	SELECT @totalCostOfAllItems = SUM(ISNULL(ReceiptItem.dblOpenReceive, 0) * ISNULL(ReceiptItem.dblUnitCost, 0))
--	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
--				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
--			INNER JOIN dbo.tblICItemUOM ItemUOM
--				ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
--	WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
--			AND ReceiptItem.intOrderId = @intContractId

--	-- Distribute the other charge by 'Cost'. 
--	IF ISNULL(@totalCostOfAllItems, 0) <> 0 
--	BEGIN 
--		UPDATE	ReceiptItem
--		SET		dblOtherCharges +=	(	@totalOtherChargesForContracts_AllocateByCost
--										* (ISNULL(ReceiptItem.dblOpenReceive, 0) * ISNULL(ReceiptItem.dblUnitCost, 0))
--										/ @totalCostOfAllItems
--									)				 
--		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem 
--					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId	
--				INNER JOIN dbo.tblICItemUOM ItemUOM
--					ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
--		WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId						
--				AND Receipt.strReceiptType = @RECEIPT_TYPE_Purchase_Contract
--				AND ReceiptItem.intOrderId = @intContractId
--	END 
--END 

-- Allocate by 'cost
BEGIN
	-- Upsert (update or insert) a record into the Receipt Item Allocated Charge table. 
	MERGE	
	INTO	dbo.tblICInventoryReceiptItemAllocatedCharge 
	WITH	(HOLDLOCK) 
	AS		ReceiptItemAllocatedCharge
	USING (
		SELECT	CalculatedCharges.*
				,Receipt.intInventoryReceiptId
				,ReceiptItem.intInventoryReceiptItemId
				,ReceiptItem.dblOpenReceive
				,ReceiptItem.dblUnitCost
				,TotalCostOfItemsPerContract.dblTotalCost 
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
					AND Receipt.strReceiptType = @RECEIPT_TYPE_Purchase_Contract
				INNER JOIN (
					SELECT	dblTotalOtherCharge = SUM(dblCalculatedAmount)
							,strCostBilledBy
							,intContractId
							,intEntityVendorId
							,ysnInventoryCost
					FROM	dbo.tblICInventoryReceiptChargePerItem CalculatedCharge 					
					WHERE	CalculatedCharge.intInventoryReceiptId = @intInventoryReceiptId
							AND CalculatedCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Cost
							AND CalculatedCharge.intContractId IS NOT NULL 
					GROUP BY strCostBilledBy, intContractId, intEntityVendorId, ysnInventoryCost
				) CalculatedCharges 
					ON ReceiptItem.intOrderId = CalculatedCharges.intContractId
				LEFT JOIN (
					SELECT	dblTotalCost = SUM(ISNULL(ReceiptItem.dblOpenReceive, 0) * ISNULL(ReceiptItem.dblUnitCost, 0))
							,ReceiptItem.intOrderId 
					FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
								ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
								AND Receipt.strReceiptType = @RECEIPT_TYPE_Purchase_Contract
					WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
							AND ReceiptItem.intOrderId IS NOT NULL 
					GROUP BY ReceiptItem.intOrderId 
				) TotalCostOfItemsPerContract 
					ON TotalCostOfItemsPerContract.intOrderId = ReceiptItem.intOrderId 
	) AS Source_Query  
		ON ReceiptItemAllocatedCharge.intInventoryReceiptId = Source_Query.intInventoryReceiptId
		AND ReceiptItemAllocatedCharge.intEntityVendorId = Source_Query.intEntityVendorId
		AND ReceiptItemAllocatedCharge.strCostBilledBy = Source_Query.strCostBilledBy
		AND ReceiptItemAllocatedCharge.ysnInventoryCost = Source_Query.ysnInventoryCost

	-- Add the other charge to an existing allocation. 
	WHEN MATCHED AND ISNULL(Source_Query.dblTotalCost, 0) <> 0 THEN 
		UPDATE 
		SET		dblAmount = ISNULL(dblAmount, 0) + (
					Source_Query.dblTotalOtherCharge
					* Source_Query.dblOpenReceive 
					* Source_Query.dblUnitCost
					/ Source_Query.dblTotalCost 
				)

	-- Create a new allocation record for the item. 
	WHEN NOT MATCHED AND ISNULL(Source_Query.dblTotalCost, 0) <> 0 THEN 
		INSERT (
			[intInventoryReceiptId]
			,[intInventoryReceiptItemId]
			,[intEntityVendorId]
			,[dblAmount]
			,[strCostBilledBy]
			,[ysnInventoryCost]
		)
		VALUES (
			Source_Query.intInventoryReceiptId
			,Source_Query.intInventoryReceiptItemId
			,Source_Query.intEntityVendorId
			,(	Source_Query.dblTotalOtherCharge
				* Source_Query.dblOpenReceive 
				* Source_Query.dblUnitCost
				/ Source_Query.dblTotalCost 
			)
			,Source_Query.strCostBilledBy
			,Source_Query.ysnInventoryCost
		)
	;
END 




_Exit: