﻿CREATE PROCEDURE [dbo].[uspICAllocateInventoryReceiptOtherChargesByContractAndUnits]
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

		,@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2
		,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
		,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

DECLARE	-- Receipt Types
		@RECEIPT_TYPE_PurchaseContract AS NVARCHAR(50) = 'Purchase Contract'
		,@RECEIPT_TYPE_PurchaseOrder AS NVARCHAR(50) = 'Purchase Order'
		,@RECEIPT_TYPE_TransferOrder AS NVARCHAR(50) = 'Transfer Order'
		,@RECEIPT_TYPE_Direct AS NVARCHAR(50) = 'Direct'
		-- Source Types
		,@SOURCE_TYPE_None AS INT = 0
		,@SOURCE_TYPE_Scale AS INT = 1
		,@SOURCE_TYPE_Inbound_Shipment AS INT = 2
		,@SOURCE_TYPE_Transport AS INT = 3

-- Allocate by cost by 'Unit' on cost methods using 'Per Unit' and 'Percentage' 
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
					AND Receipt.strReceiptType = @RECEIPT_TYPE_PurchaseContract
					AND ReceiptItem.intOrderId IS NOT NULL 
					AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
				INNER JOIN dbo.tblICItemUOM ItemUOM	
					ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId 
				INNER JOIN (					
					SELECT	dblTotalOtherCharge = SUM(dblCalculatedAmount) 								
							,ysnAccrue
							,intContractId
							,intEntityVendorId
							,ysnInventoryCost
							,intInventoryReceiptId
							,intInventoryReceiptChargeId
					FROM	dbo.tblICInventoryReceiptChargePerItem CalculatedCharge				
					WHERE	CalculatedCharge.intInventoryReceiptId = @intInventoryReceiptId
							AND CalculatedCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Unit
							AND CalculatedCharge.intContractId IS NOT NULL 
					GROUP BY ysnAccrue
							, intContractId
							, intEntityVendorId
							, ysnInventoryCost
							, intInventoryReceiptId
							, intInventoryReceiptChargeId
				) CalculatedCharges 
					ON CalculatedCharges.intContractId = ReceiptItem.intOrderId 
				LEFT JOIN (
					SELECT	dblTotalUnits = SUM(ReceiptItem.dblOpenReceive)
							,ReceiptItem.intOrderId 
					FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
								ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
								AND Receipt.strReceiptType = @RECEIPT_TYPE_PurchaseContract
							INNER JOIN dbo.tblICItemUOM ItemUOM
								ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId 
					WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
							AND ReceiptItem.intOrderId IS NOT NULL 
					GROUP BY ReceiptItem.intOrderId 
				) TotalUnitsOfItemsPerContract 
					ON TotalUnitsOfItemsPerContract.intOrderId = ReceiptItem.intOrderId 

	) AS Source_Query  
		ON ReceiptItemAllocatedCharge.intInventoryReceiptId = Source_Query.intInventoryReceiptId
		AND ReceiptItemAllocatedCharge.intEntityVendorId = Source_Query.intEntityVendorId
		AND ReceiptItemAllocatedCharge.ysnAccrue = Source_Query.ysnAccrue
		AND ReceiptItemAllocatedCharge.ysnInventoryCost = Source_Query.ysnInventoryCost

	-- Add the other charge to an existing allocation. 
	WHEN MATCHED AND ISNULL(Source_Query.dblTotalUnits, 0) <> 0 THEN 
		UPDATE 
		SET		dblAmount = ROUND(
								ISNULL(dblAmount, 0) 
								+ (
									Source_Query.dblTotalOtherCharge
									* Source_Query.dblOpenReceive
									/ Source_Query.dblTotalUnits 
								)
								, 2
							)

	-- Create a new allocation record for the item. 
	WHEN NOT MATCHED AND ISNULL(Source_Query.dblTotalUnits, 0) <> 0 THEN 
		INSERT (
			[intInventoryReceiptId]
			,[intInventoryReceiptChargeId]
			,[intInventoryReceiptItemId]
			,[intEntityVendorId]
			,[dblAmount]
			,[ysnAccrue]
			,[ysnInventoryCost]
		)
		VALUES (
			Source_Query.intInventoryReceiptId
			,Source_Query.intInventoryReceiptChargeId
			,Source_Query.intInventoryReceiptItemId
			,Source_Query.intEntityVendorId
			,ROUND (
				Source_Query.dblTotalOtherCharge
				* Source_Query.dblOpenReceive
				/ Source_Query.dblTotalUnits 
				,2 
			)
			,Source_Query.ysnAccrue
			,Source_Query.ysnInventoryCost
		)
	;
END 

-- Allocate by cost by 'Unit' on cost methods using 'Amount' 
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
					AND Receipt.strReceiptType = @RECEIPT_TYPE_PurchaseContract
					AND ReceiptItem.intOrderId IS NOT NULL 
					AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
				INNER JOIN dbo.tblICItemUOM ItemUOM	
					ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId 
				INNER JOIN (					
					SELECT	dblFixedAmount = SUM(dblAmount) 								
							,ysnAccrue
							,intContractId
							,intEntityVendorId
							,ysnInventoryCost
							,intInventoryReceiptId
							,intInventoryReceiptChargeId
					FROM	dbo.tblICInventoryReceiptCharge CalculatedCharge				
					WHERE	CalculatedCharge.intInventoryReceiptId = @intInventoryReceiptId
							AND CalculatedCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Unit
							AND CalculatedCharge.strCostMethod = @COST_METHOD_Amount
							AND CalculatedCharge.intContractId IS NOT NULL 
					GROUP BY ysnAccrue
							, intContractId
							, intEntityVendorId
							, ysnInventoryCost
							, intInventoryReceiptId
							, intInventoryReceiptChargeId
				) CalculatedCharges 
					ON CalculatedCharges.intContractId = ReceiptItem.intOrderId 
				LEFT JOIN (
					SELECT	dblTotalUnits = SUM(ReceiptItem.dblOpenReceive)
							,ReceiptItem.intOrderId 
					FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
								ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
								AND Receipt.strReceiptType = @RECEIPT_TYPE_PurchaseContract
							INNER JOIN dbo.tblICItemUOM ItemUOM
								ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId 
					WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
							AND ReceiptItem.intOrderId IS NOT NULL 
					GROUP BY ReceiptItem.intOrderId 
				) TotalUnitsOfItemsPerContract 
					ON TotalUnitsOfItemsPerContract.intOrderId = ReceiptItem.intOrderId 

	) AS Source_Query  
		ON ReceiptItemAllocatedCharge.intInventoryReceiptId = Source_Query.intInventoryReceiptId
		AND ReceiptItemAllocatedCharge.intEntityVendorId = Source_Query.intEntityVendorId
		AND ReceiptItemAllocatedCharge.ysnAccrue = Source_Query.ysnAccrue
		AND ReceiptItemAllocatedCharge.ysnInventoryCost = Source_Query.ysnInventoryCost

	-- Add the other charge to an existing allocation. 
	WHEN MATCHED AND ISNULL(Source_Query.dblTotalUnits, 0) <> 0 THEN 
		UPDATE 
		SET		dblAmount = ROUND(
								ISNULL(dblAmount, 0) 
								+ (
									Source_Query.dblFixedAmount
									* Source_Query.dblOpenReceive
									/ Source_Query.dblTotalUnits 
								)
								, 2
							)

	-- Create a new allocation record for the item. 
	WHEN NOT MATCHED AND ISNULL(Source_Query.dblTotalUnits, 0) <> 0 THEN 
		INSERT (
			[intInventoryReceiptId]
			,[intInventoryReceiptChargeId]
			,[intInventoryReceiptItemId]
			,[intEntityVendorId]
			,[dblAmount]
			,[ysnAccrue]
			,[ysnInventoryCost]
		)
		VALUES (
			Source_Query.intInventoryReceiptId
			,Source_Query.intInventoryReceiptChargeId
			,Source_Query.intInventoryReceiptItemId
			,Source_Query.intEntityVendorId
			,ROUND (
				Source_Query.dblFixedAmount
				* Source_Query.dblOpenReceive
				/ Source_Query.dblTotalUnits 
				,2 
			)
			,Source_Query.ysnAccrue
			,Source_Query.ysnInventoryCost
		)
	;
END 


_Exit: