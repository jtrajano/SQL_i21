﻿CREATE PROCEDURE [dbo].[uspICAllocateInventoryReceiptOtherChargesByContractAndStockUnit]
	@intInventoryReceiptId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

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
		@RECEIPT_TYPE_Purchase_Contract AS NVARCHAR(50) = 'Purchase Contract'
		,@RECEIPT_TYPE_Purchase_Order AS NVARCHAR(50) = 'Purchase Order'
		,@RECEIPT_TYPE_Transfer_Order AS NVARCHAR(50) = 'Transfer Order'
		,@RECEIPT_TYPE_Direct AS NVARCHAR(50) = 'Direct'
		-- Source Types
		,@SOURCE_TYPE_None AS INT = 0
		,@SOURCE_TYPE_Scale AS INT = 1
		,@SOURCE_TYPE_Inbound_Shipment AS INT = 2
		,@SOURCE_TYPE_Transport AS INT = 3

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END 

-- Allocate cost by 'Stock Unit' and by Contract and cost methods used are 'Per Unit' and 'Percentage' 
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
				,TotalStockUnitOfItemsPerContract.dblTotalStockUnit 
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
					AND Receipt.intInventoryReceiptId = @intInventoryReceiptId
					AND Receipt.strReceiptType = @RECEIPT_TYPE_Purchase_Contract
					AND ReceiptItem.intOrderId IS NOT NULL 
					AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
				INNER JOIN tblICItem Item
					ON Item.intItemId = ReceiptItem.intItemId 
					AND Item.strType IN ('Inventory') 
				INNER JOIN (
					SELECT	dblTotalOtherCharge = 
								-- Convert the other charge amount to functional currency. 
								SUM(
									dblCalculatedAmount
									--* CASE WHEN ISNULL(Charge.dblForexRate, 0) = 0 AND ISNULL(Charge.intCurrencyId, @intFunctionalCurrencyId) = @intFunctionalCurrencyId THEN 1 ELSE Charge.dblForexRate END 
								)
							,dblOriginalTotalOtherCharge = 
								-- Convert the other charge amount to functional currency. 
								SUM(
									dblOriginalCalculatedAmount
									--* CASE WHEN ISNULL(Charge.dblForexRate, 0) = 0 AND ISNULL(Charge.intCurrencyId, @intFunctionalCurrencyId) = @intFunctionalCurrencyId THEN 1 ELSE Charge.dblForexRate END 
								)
							,CalculatedCharge.ysnAccrue 
							,CalculatedCharge.intContractId
							,CalculatedCharge.intContractDetailId
							,CalculatedCharge.intEntityVendorId
							,CalculatedCharge.ysnInventoryCost
							,CalculatedCharge.intInventoryReceiptId
							,CalculatedCharge.intInventoryReceiptChargeId
							,CalculatedCharge.ysnPrice
							,Charge.strChargesLink 
					FROM	dbo.tblICInventoryReceiptChargePerItem CalculatedCharge	INNER JOIN tblICInventoryReceiptCharge Charge
								ON CalculatedCharge.intInventoryReceiptChargeId = Charge.intInventoryReceiptChargeId
					WHERE	CalculatedCharge.intInventoryReceiptId = @intInventoryReceiptId
							AND CalculatedCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Stock_Unit
							AND CalculatedCharge.intContractId IS NOT NULL 
					GROUP BY 
						CalculatedCharge.ysnAccrue
						, CalculatedCharge.intContractId
						, CalculatedCharge.intContractDetailId
						, CalculatedCharge.intEntityVendorId
						, CalculatedCharge.ysnInventoryCost
						, CalculatedCharge.intInventoryReceiptId
						, CalculatedCharge.intInventoryReceiptChargeId
						, CalculatedCharge.ysnPrice
						, Charge.strChargesLink 
				) CalculatedCharges 
					ON ReceiptItem.intOrderId = CalculatedCharges.intContractId
					AND ReceiptItem.intLineNo = CalculatedCharges.intContractDetailId
					AND (
						ISNULL(CalculatedCharges.strChargesLink, '') = ISNULL(ReceiptItem.strChargesLink, '')
					)					 
				LEFT JOIN (
					SELECT  dblTotalStockUnit = SUM(
								CASE	WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN 
											dbo.fnCalculateStockUnitQty(ReceiptItem.dblNet, GrossNetUOM.dblUnitQty) 
										ELSE 
											dbo.fnCalculateStockUnitQty(ReceiptItem.dblOpenReceive, ItemUOM.dblUnitQty)
								END 								
							)
							,ReceiptItem.intOrderId 
							,ReceiptItem.intLineNo
							,ReceiptItem.strChargesLink
					FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem 
								ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId	
								AND Receipt.strReceiptType = @RECEIPT_TYPE_Purchase_Contract
							INNER JOIN tblICItem Item
								ON Item.intItemId = ReceiptItem.intItemId 
								AND Item.strType IN ('Inventory') 
							INNER JOIN dbo.tblICItemUOM ItemUOM
								ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
							LEFT JOIN  dbo.tblICItemUOM GrossNetUOM
								ON GrossNetUOM.intItemUOMId = ReceiptItem.intWeightUOMId
					WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
							AND ReceiptItem.intOrderId IS NOT NULL 
					GROUP BY ReceiptItem.intOrderId, ReceiptItem.intLineNo, ReceiptItem.strChargesLink
				) TotalStockUnitOfItemsPerContract 
					ON TotalStockUnitOfItemsPerContract.intOrderId = ReceiptItem.intOrderId 
					AND TotalStockUnitOfItemsPerContract.intLineNo = ReceiptItem.intLineNo
					AND (
						ISNULL(TotalStockUnitOfItemsPerContract.strChargesLink, '') = ISNULL(ReceiptItem.strChargesLink, '')
					)
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
		AND ReceiptItemAllocatedCharge.intInventoryReceiptChargeId = Source_Query.intInventoryReceiptChargeId
		AND ISNULL(ReceiptItemAllocatedCharge.strChargesLink, '') = ISNULL(Source_Query.strChargesLink, '')

	-- Add the other charge to an existing allocation. 
	WHEN MATCHED AND ISNULL(Source_Query.dblTotalStockUnit, 0) <> 0 THEN 
		UPDATE 
		SET		dblAmount = ROUND (
								ISNULL(dblAmount, 0) 
								+ dbo.fnDivide (
									dbo.fnMultiply(
										Source_Query.dblTotalOtherCharge
										, dbo.fnCalculateStockUnitQty(
											Source_Query.Qty
											, Source_Query.dblUnitQty
										)
									)
									, Source_Query.dblTotalStockUnit 
								) 								
								, 2
							)
				,dblOriginalAmount = ROUND (
								ISNULL(dblOriginalAmount, 0) 
								+ dbo.fnDivide (
									dbo.fnMultiply(
										Source_Query.dblOriginalTotalOtherCharge
										, dbo.fnCalculateStockUnitQty(
											Source_Query.Qty
											, Source_Query.dblUnitQty
										)
									)
									, Source_Query.dblTotalStockUnit 
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
			,[strChargesLink]
			,[dblOriginalAmount]
		)
		VALUES (
			Source_Query.intInventoryReceiptId
			,Source_Query.intInventoryReceiptChargeId
			,Source_Query.intInventoryReceiptItemId
			,Source_Query.intEntityVendorId
			,-- dblAmount: 
			ROUND (
				dbo.fnDivide(
					dbo.fnMultiply(
						Source_Query.dblTotalOtherCharge
						, dbo.fnCalculateStockUnitQty(
							Source_Query.Qty
							, Source_Query.dblUnitQty
						)
					)
					,Source_Query.dblTotalStockUnit 
				) 
				, 2
			)
			,Source_Query.ysnAccrue
			,Source_Query.ysnInventoryCost
			,Source_Query.ysnPrice
			,Source_Query.strChargesLink
			,-- dblOriginalAmount: 
			ROUND (
				dbo.fnDivide(
					dbo.fnMultiply(
						Source_Query.dblOriginalTotalOtherCharge
						, dbo.fnCalculateStockUnitQty(
							Source_Query.Qty
							, Source_Query.dblUnitQty
						)
					)
					,Source_Query.dblTotalStockUnit 
				) 
				, 2
			)

		)
	;
END 

-- Fix any decimal discrepancy 
BEGIN 
	UPDATE	fixDiscrepancy
	SET
		fixDiscrepancy.dblAmount += (rc.dblAmount - a.dblTotal) 
	FROM	
		tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge rc
			ON r.intInventoryReceiptId = rc.intInventoryReceiptId	
		CROSS APPLY (
			SELECT 
				dblTotal = SUM(a.dblAmount)
			FROM
				tblICInventoryReceiptItemAllocatedCharge a
			WHERE 
				r.intInventoryReceiptId = a.intInventoryReceiptId
				AND a.intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId
		) a
		CROSS APPLY (
			SELECT TOP 1 
				discrepancy.intInventoryReceiptItemAllocatedChargeId
			FROM
				tblICInventoryReceiptItemAllocatedCharge discrepancy
			WHERE 
				discrepancy.intInventoryReceiptId = r.intInventoryReceiptId
				AND discrepancy.intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId	
			ORDER BY 
				discrepancy.intInventoryReceiptItemId DESC
		) findDiscrepancy
		INNER JOIN tblICInventoryReceiptItemAllocatedCharge fixDiscrepancy
			ON fixDiscrepancy.intInventoryReceiptItemAllocatedChargeId = findDiscrepancy.intInventoryReceiptItemAllocatedChargeId
	WHERE 
		r.intInventoryReceiptId = @intInventoryReceiptId
		AND (rc.dblAmount - a.dblTotal) <> 0 
		AND (rc.dblAmount - a.dblTotal) BETWEEN -1 AND 1 -- Limit the fix on decimal discrepancies. 
END 

_Exit: