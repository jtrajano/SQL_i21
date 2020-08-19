CREATE PROCEDURE [dbo].[uspICAllocateInventoryReceiptOtherChargesByUnits]
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

-- Allocate cost by 'Unit' regardless if there are contracts and cost methods used are 'Per Unit' and 'Percentage' 
BEGIN 
	-- Upsert (update or insert) a record into the Receipt Item Allocated Charge table. 
	MERGE	
	INTO	dbo.tblICInventoryReceiptItemAllocatedCharge 
	WITH	(HOLDLOCK) 
	AS		ReceiptItemAllocatedCharge
	USING (
		SELECT	CalculatedCharges.*
				,ReceiptItem.intInventoryReceiptItemId
				,Qty = 
					COALESCE(
						CalculatedChargeQty.dblUnit
						,NULLIF(ReceiptItem.dblNet, 0)
						,ReceiptItem.dblOpenReceive
						,0
					)
				,dblTotalUnits = 
					CASE 
						WHEN CalculatedCharges.strCostMethod = 'Amount' THEN
							ISNULL(TotalAmountOnSameChargesLink.dblTotalUnits, TotalUnitsOfAllItems.dblTotalUnits) 
						ELSE 
							TotalUnitsOnSameChargesLink.dblTotalUnits 
					END 				
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
								SUM(CalculatedCharge.dblCalculatedAmount)								
							,CalculatedCharge.ysnAccrue
							,CalculatedCharge.intEntityVendorId
							,CalculatedCharge.ysnInventoryCost
							,CalculatedCharge.intInventoryReceiptId
							,CalculatedCharge.intInventoryReceiptChargeId
							,CalculatedCharge.ysnPrice
							,Charge.strChargesLink 
					FROM	dbo.tblICInventoryReceiptChargePerItem CalculatedCharge INNER JOIN tblICInventoryReceiptCharge Charge
								ON CalculatedCharge.intInventoryReceiptChargeId = Charge.intInventoryReceiptChargeId				
					WHERE	CalculatedCharge.intInventoryReceiptId = @intInventoryReceiptId
							AND CalculatedCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Unit
							AND CalculatedCharge.intContractId IS NULL 
					GROUP BY 
						CalculatedCharge.ysnAccrue
						, CalculatedCharge.intEntityVendorId
						, CalculatedCharge.ysnInventoryCost
						, CalculatedCharge.intInventoryReceiptId
						, CalculatedCharge.intInventoryReceiptChargeId
						, CalculatedCharge.ysnPrice
						, Charge.strChargesLink 
				) CalculatedCharges 
					ON ReceiptItem.intInventoryReceiptId = CalculatedCharges.intInventoryReceiptId
					AND (
						ISNULL(CalculatedCharges.strChargesLink, '') = ISNULL(ReceiptItem.strChargesLink, '')
						OR CalculatedCharges.strChargesLink IS NULL 
					)
				OUTER APPLY (
					SELECT 
						dblUnit = CalculatedCharge.dblCalculatedQty
					FROM
						tblICInventoryReceiptChargePerItem CalculatedCharge
					WHERE
						CalculatedCharge.intInventoryReceiptId = @intInventoryReceiptId
						AND CalculatedCharge.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
						AND CalculatedCharge.intInventoryReceiptChargeId = CalculatedCharges.intInventoryReceiptChargeId
				) CalculatedChargeQty
				OUTER APPLY (
					SELECT 
						dblTotalUnits = SUM(CalculatedCharge.dblCalculatedQty) 
					FROM
						tblICInventoryReceiptChargePerItem CalculatedCharge
					WHERE
						CalculatedCharge.intInventoryReceiptId = @intInventoryReceiptId
						AND CalculatedCharge.intInventoryReceiptChargeId = CalculatedCharges.intInventoryReceiptChargeId
				) TotalUnitsOnSameChargesLink
				OUTER APPLY (
					SELECT	dblTotalUnits = 
								SUM(
									COALESCE(
										NULLIF(ri.dblNet, 0)
										,ri.dblOpenReceive
										,0
									)
								)
							,ReceiptItem.intInventoryReceiptId 						
					FROM	dbo.tblICInventoryReceipt r INNER JOIN dbo.tblICInventoryReceiptItem ri
								ON r.intInventoryReceiptId = ri.intInventoryReceiptId
					WHERE	
						r.intInventoryReceiptId = @intInventoryReceiptId
						AND 1 = CASE WHEN r.strReceiptType = @RECEIPT_TYPE_PurchaseContract AND ri.intOrderId IS NULL THEN 1
									WHEN r.strReceiptType <> @RECEIPT_TYPE_PurchaseContract THEN 1
									ELSE 0
							END 
						AND ISNULL(ri.strChargesLink, '') = ISNULL(ReceiptItem.strChargesLink, '')
				) TotalAmountOnSameChargesLink 	
				LEFT JOIN (
							SELECT	dblTotalUnits = SUM(
										COALESCE(
											NULLIF(ReceiptItem.dblNet, 0)
											,ReceiptItem.dblOpenReceive
											,0
										)
									)
							,ReceiptItem.intInventoryReceiptId 						
					FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
								ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
					WHERE	
						Receipt.intInventoryReceiptId = @intInventoryReceiptId
						AND 1 = CASE WHEN Receipt.strReceiptType = @RECEIPT_TYPE_PurchaseContract AND ReceiptItem.intOrderId IS NULL THEN 1
								 WHEN Receipt.strReceiptType <> @RECEIPT_TYPE_PurchaseContract THEN 1
								 ELSE 0
							END 
					GROUP BY 
						ReceiptItem.intInventoryReceiptId						
				) TotalUnitsOfAllItems 
					ON TotalUnitsOfAllItems.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId 

	) AS Source_Query  
		ON ReceiptItemAllocatedCharge.intInventoryReceiptId = Source_Query.intInventoryReceiptId
		AND ReceiptItemAllocatedCharge.intEntityVendorId = Source_Query.intEntityVendorId
		AND ReceiptItemAllocatedCharge.ysnAccrue = Source_Query.ysnAccrue
		AND ReceiptItemAllocatedCharge.ysnInventoryCost = Source_Query.ysnInventoryCost
		AND ReceiptItemAllocatedCharge.ysnPrice = Source_Query.ysnPrice
		AND ReceiptItemAllocatedCharge.intInventoryReceiptChargeId = Source_Query.intInventoryReceiptChargeId
		AND (
			ISNULL(ReceiptItemAllocatedCharge.strChargesLink, '') = ISNULL(Source_Query.strChargesLink, '')
			OR Source_Query.strChargesLink IS NULL 
		)

	-- Add the other charge to an existing allocation. 
	WHEN MATCHED AND ISNULL(Source_Query.dblTotalUnits, 0) <> 0 THEN 
		UPDATE 
		SET		dblAmount = 
					ROUND (
						ISNULL(dblAmount, 0) 
						+ (
							Source_Query.dblTotalOtherCharge
							* Source_Query.Qty
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
			,[ysnPrice]
			,[strChargesLink]
		)
		VALUES (
			Source_Query.intInventoryReceiptId
			,Source_Query.intInventoryReceiptChargeId
			,Source_Query.intInventoryReceiptItemId
			,Source_Query.intEntityVendorId
			,ROUND (
				Source_Query.dblTotalOtherCharge
				* Source_Query.Qty
				/ Source_Query.dblTotalUnits 
				, 2
			)
			,Source_Query.ysnAccrue 
			,Source_Query.ysnInventoryCost
			,Source_Query.ysnPrice
			,Source_Query.strChargesLink
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
