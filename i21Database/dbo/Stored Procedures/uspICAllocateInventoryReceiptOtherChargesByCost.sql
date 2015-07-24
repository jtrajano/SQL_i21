CREATE PROCEDURE [dbo].[uspICAllocateInventoryReceiptOtherChargesByCost]
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

-- Allocate by 'cost
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
				,ReceiptItem.dblUnitCost
				,TotalCostOfItemsPerContract.dblTotalCost 
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
					AND Receipt.intInventoryReceiptId = @intInventoryReceiptId
					AND ReceiptItem.intOrderId IS NULL 	
				INNER JOIN (
					SELECT	dblTotalOtherCharge = SUM(dblCalculatedAmount)
							,strCostBilledBy
							,intContractId
							,intEntityVendorId
							,ysnInventoryCost
							,intInventoryReceiptId
					FROM	dbo.tblICInventoryReceiptChargePerItem CalculatedCharge 					
					WHERE	CalculatedCharge.intInventoryReceiptId = @intInventoryReceiptId
							AND CalculatedCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Cost
							AND CalculatedCharge.intContractId IS NULL 
					GROUP BY strCostBilledBy, intContractId, intEntityVendorId, ysnInventoryCost, intInventoryReceiptId
				) CalculatedCharges 
					ON ReceiptItem.intInventoryReceiptId = CalculatedCharges.intInventoryReceiptId
				LEFT JOIN (
					SELECT	dblTotalCost = SUM(ISNULL(ReceiptItem.dblOpenReceive, 0) * ISNULL(ReceiptItem.dblUnitCost, 0))
							,ReceiptItem.intInventoryReceiptId 
					FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
								ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
					WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
					GROUP BY ReceiptItem.intInventoryReceiptId 
				) TotalCostOfItemsPerContract 
					ON TotalCostOfItemsPerContract.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId 
	) AS Source_Query  
		ON ReceiptItemAllocatedCharge.intInventoryReceiptId = Source_Query.intInventoryReceiptId
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