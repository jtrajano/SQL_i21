﻿CREATE PROCEDURE [dbo].[uspICAllocateInventoryReceiptOtherChargesByStockUnit]
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
		,@SOURCE_TYPE_InboundShipment AS INT = 2
		,@SOURCE_TYPE_Transport AS INT = 3

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END 

-- Allocate cost by 'Stock Unit' regardless if there are contracts and cost methods used are 'Per Unit' and 'Percentage' 
BEGIN 
	-- Upsert (update or insert) a record into the Receipt Item Allocated Charge table. 
	MERGE	
	INTO	dbo.tblICInventoryReceiptItemAllocatedCharge 
	WITH	(HOLDLOCK) 
	AS		ReceiptItemAllocatedCharge
	USING (
		SELECT	CalculatedCharges.*
				,ReceiptItem.intInventoryReceiptItemId
				,Qty = CASE WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN ReceiptItem.dblNet ELSE ReceiptItem.dblOpenReceive END 
				,dblUnitQty = CASE WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN GrossNetUOM.dblUnitQty ELSE ItemUOM.dblUnitQty END
				,TotalStockUnitOfItems.dblTotalStockUnit 
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
					AND Receipt.intInventoryReceiptId = @intInventoryReceiptId
					AND 1 = CASE WHEN Receipt.strReceiptType = @RECEIPT_TYPE_PurchaseContract AND ReceiptItem.intOrderId IS NULL THEN 1
								 WHEN Receipt.strReceiptType <> @RECEIPT_TYPE_PurchaseContract THEN 1
								 ELSE 0
							END 					
					AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own				
				INNER JOIN (
					SELECT	dblTotalOtherCharge = 
								-- Convert the other charge amount to functional currency. 
								SUM(
									dblCalculatedAmount
									--* CASE WHEN ISNULL(Charge.dblForexRate, 0) = 0 AND ISNULL(Charge.intCurrencyId, @intFunctionalCurrencyId) = @intFunctionalCurrencyId THEN 1 ELSE Charge.dblForexRate END 
								)
							,CalculatedCharge.ysnAccrue 
							,CalculatedCharge.intEntityVendorId
							,CalculatedCharge.ysnInventoryCost
							,CalculatedCharge.intInventoryReceiptId
							,CalculatedCharge.intInventoryReceiptChargeId
							,CalculatedCharge.ysnPrice
					FROM	dbo.tblICInventoryReceiptChargePerItem CalculatedCharge	INNER JOIN tblICInventoryReceiptCharge Charge
								ON CalculatedCharge.intInventoryReceiptChargeId = Charge.intInventoryReceiptChargeId		
					WHERE	CalculatedCharge.intInventoryReceiptId = @intInventoryReceiptId
							AND CalculatedCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Stock_Unit
							AND CalculatedCharge.intContractId IS NULL 
					GROUP BY 
						CalculatedCharge.ysnAccrue
						, CalculatedCharge.intEntityVendorId
						, CalculatedCharge.ysnInventoryCost
						, CalculatedCharge.intInventoryReceiptId
						, CalculatedCharge.intInventoryReceiptChargeId
						, CalculatedCharge.ysnPrice
				) CalculatedCharges 
					ON ReceiptItem.intInventoryReceiptId = CalculatedCharges.intInventoryReceiptId
				LEFT JOIN (
					SELECT  dblTotalStockUnit = SUM(
								CASE	WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN 
											dbo.fnCalculateStockUnitQty(ReceiptItem.dblNet, GrossNetUOM.dblUnitQty) 
										ELSE 
											dbo.fnCalculateStockUnitQty(ReceiptItem.dblOpenReceive, ItemUOM.dblUnitQty)
								END 								
							)
							,ReceiptItem.intInventoryReceiptId 
					FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem 
								ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId	
							INNER JOIN dbo.tblICItemUOM ItemUOM
								ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
							LEFT JOIN dbo.tblICItemUOM StockUOM
								ON StockUOM.intItemId = ReceiptItem.intItemId
								AND StockUOM.ysnStockUnit = 1
							LEFT JOIN dbo.tblICItemUOM GrossNetUOM
								ON GrossNetUOM.intItemUOMId = ReceiptItem.intWeightUOMId

					WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
							AND StockUOM.intItemUOMId IS NOT NULL 
					GROUP BY ReceiptItem.intInventoryReceiptId
				) TotalStockUnitOfItems 
					ON TotalStockUnitOfItems.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId 

				LEFT JOIN dbo.tblICItemUOM ItemUOM	
					ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId 
				LEFT JOIN dbo.tblICItemUOM GrossNetUOM
					ON GrossNetUOM.intItemUOMId = ReceiptItem.intWeightUOMId
	) AS Source_Query  
		ON ReceiptItemAllocatedCharge.intInventoryReceiptId = Source_Query.intInventoryReceiptId
		AND ReceiptItemAllocatedCharge.intEntityVendorId = Source_Query.intEntityVendorId
		AND ReceiptItemAllocatedCharge.ysnAccrue = Source_Query.ysnAccrue
		AND ReceiptItemAllocatedCharge.ysnInventoryCost = Source_Query.ysnInventoryCost
		AND ReceiptItemAllocatedCharge.ysnPrice = Source_Query.ysnPrice

	-- Add the other charge to an existing allocation. 
	WHEN MATCHED AND ISNULL(Source_Query.dblTotalStockUnit, 0) <> 0 THEN 
		UPDATE 
		SET		dblAmount = ROUND (
								ISNULL(dblAmount, 0) 
								+ (
									Source_Query.dblTotalOtherCharge
									* dbo.fnCalculateStockUnitQty(Source_Query.Qty, Source_Query.dblUnitQty)
									/ Source_Query.dblTotalStockUnit 
								)
								, 2 
							)

	-- Create a new allocation record for the item. 
	WHEN NOT MATCHED AND ISNULL(Source_Query.dblTotalStockUnit, 0) <> 0 THEN 
		INSERT (
			[intInventoryReceiptId]
			,[intInventoryReceiptChargeId]
			,[intInventoryReceiptItemId]
			,[intEntityVendorId]
			,[dblAmount]
			,[ysnAccrue]
			,[ysnInventoryCost]
			,[ysnPrice]
		)
		VALUES (
			Source_Query.intInventoryReceiptId
			,Source_Query.intInventoryReceiptChargeId
			,Source_Query.intInventoryReceiptItemId
			,Source_Query.intEntityVendorId
			,ROUND (
				Source_Query.dblTotalOtherCharge
				* dbo.fnCalculateStockUnitQty(Source_Query.Qty, Source_Query.dblUnitQty)
				/ Source_Query.dblTotalStockUnit 
				, 2	
			)
			,Source_Query.ysnAccrue
			,Source_Query.ysnInventoryCost
			,Source_Query.ysnPrice
		)
	;
END 

_Exit: