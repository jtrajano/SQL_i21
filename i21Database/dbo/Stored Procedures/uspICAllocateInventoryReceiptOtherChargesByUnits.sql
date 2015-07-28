﻿CREATE PROCEDURE [dbo].[uspICAllocateInventoryReceiptOtherChargesByUnits]
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

		,@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2
		,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
		,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

-- Allocate cost by 'unit'
BEGIN 
	-- Upsert (update or insert) a record into the Receipt Item Allocated Charge table. 
	MERGE	
	INTO	dbo.tblICInventoryReceiptItemAllocatedCharge 
	WITH	(HOLDLOCK) 
	AS		ReceiptItemAllocatedCharge
	USING (
		SELECT	CalculatedCharges.*
				,ReceiptItem.intInventoryReceiptItemId
				,ReceiptItem.dblOpenReceive
				,ItemUOM.dblUnitQty
				,TotalUnitsOfItemsPerContract.dblTotalUnits 
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
					AND Receipt.intInventoryReceiptId = @intInventoryReceiptId
					AND ReceiptItem.intOrderId IS NULL 		
					AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own			
				INNER JOIN dbo.tblICItemUOM ItemUOM	
					ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId 
				INNER JOIN (
					SELECT	dblTotalOtherCharge = SUM(dblCalculatedAmount)
							,strCostBilledBy
							,intContractId
							,intEntityVendorId
							,ysnInventoryCost
							,intInventoryReceiptId
							,intInventoryReceiptChargeId
					FROM	dbo.tblICInventoryReceiptChargePerItem CalculatedCharge 					
					WHERE	CalculatedCharge.intInventoryReceiptId = @intInventoryReceiptId
							AND CalculatedCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Unit
							AND CalculatedCharge.intContractId IS NULL 
					GROUP BY strCostBilledBy, intContractId, intEntityVendorId, ysnInventoryCost, intInventoryReceiptId, intInventoryReceiptChargeId
				) CalculatedCharges 
					ON ReceiptItem.intInventoryReceiptId = CalculatedCharges.intInventoryReceiptId
				LEFT JOIN (
					SELECT	dblTotalUnits = SUM(ReceiptItem.dblOpenReceive)
							,ReceiptItem.intInventoryReceiptId 
					FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
								ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
							INNER JOIN dbo.tblICItemUOM ItemUOM
								ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId 
					WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
					GROUP BY ReceiptItem.intInventoryReceiptId 
				) TotalUnitsOfItemsPerContract 
					ON TotalUnitsOfItemsPerContract.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId 
	) AS Source_Query  
		ON ReceiptItemAllocatedCharge.intInventoryReceiptId = Source_Query.intInventoryReceiptId
		AND ReceiptItemAllocatedCharge.intEntityVendorId = Source_Query.intEntityVendorId
		AND ReceiptItemAllocatedCharge.strCostBilledBy = Source_Query.strCostBilledBy
		AND ReceiptItemAllocatedCharge.ysnInventoryCost = Source_Query.ysnInventoryCost
		
	-- Add the other charge to an existing allocation. 
	WHEN MATCHED AND ISNULL(Source_Query.dblTotalUnits, 0) <> 0 THEN 
		UPDATE 
		SET		dblAmount = ISNULL(dblAmount, 0) + (
					Source_Query.dblTotalOtherCharge
					* Source_Query.dblOpenReceive
					/ Source_Query.dblTotalUnits 
				)

	-- Create a new allocation record for the item. 
	WHEN NOT MATCHED AND ISNULL(Source_Query.dblTotalUnits, 0) <> 0 THEN 
		INSERT (
			[intInventoryReceiptId]
			,[intInventoryReceiptChargeId]
			,[intInventoryReceiptItemId]
			,[intEntityVendorId]
			,[dblAmount]
			,[strCostBilledBy]
			,[ysnInventoryCost]
		)
		VALUES (
			Source_Query.intInventoryReceiptId
			,Source_Query.intInventoryReceiptChargeId
			,Source_Query.intInventoryReceiptItemId
			,Source_Query.intEntityVendorId
			,(
				Source_Query.dblTotalOtherCharge
				* Source_Query.dblOpenReceive
				/ Source_Query.dblTotalUnits 
			)
			,Source_Query.strCostBilledBy
			,Source_Query.ysnInventoryCost
		)
	;
END 

_Exit: