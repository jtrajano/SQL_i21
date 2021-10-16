﻿CREATE PROCEDURE [dbo].[uspICAllocateInventoryShipmentOtherChargesByUnits]
	@intInventoryShipmentId AS INT
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

		,@ALLOCATE_PRICE_BY_Unit AS NVARCHAR(50) = 'Unit'

		,@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2
		,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
		,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

		,@SHIPMENT_ITEM_TYPE AS NVARCHAR(50) = 'Kit Item'

DECLARE	-- Shipment Types
		@SHIPMENT_TYPE_SalesContract AS INT = 1  --Sales Contract
		,@SHIPMENT_TYPE_SalesOrder AS INT = 2  --Sales Order
		,@SHIPMENT_TYPE_TransferOrder AS INT = 3  --Transfer Order
		,@SHIPMENT_TYPE_Direct AS INT = 4  --Direct
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

-- Allocate price by 'Unit' regardless if there are contracts and cost methods used are 'Per Unit' and 'Percentage' 
BEGIN 
	-- Upsert (update or insert) a record into the Shipment Item Allocated Charge table. 
	MERGE	
	INTO	dbo.tblICInventoryShipmentItemAllocatedCharge 
	WITH	(HOLDLOCK) 
	AS		ShipmentItemAllocatedCharge
	USING (
		SELECT	CalculatedCharges.*
				,ShipmentItem.intInventoryShipmentItemId
				,Qty = ISNULL(ShipmentItem.dblQuantity, 0)
				,TotalUnitsOfItemsPerContract.dblTotalUnits 
		FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem
					ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
					AND Shipment.intInventoryShipmentId = @intInventoryShipmentId
					AND 1 = CASE WHEN Shipment.intOrderType = @SHIPMENT_TYPE_SalesContract AND ShipmentItem.intOrderId IS NULL THEN 1
								 WHEN Shipment.intOrderType <> @SHIPMENT_TYPE_SalesContract THEN 1
								 ELSE 0
							END 					
					AND ISNULL(ShipmentItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
				INNER JOIN dbo.tblICItem Item 
					ON Item.intItemId = ShipmentItem.intItemId
					-- Do not include Kit Components when calculating the other charges. 
					AND 1 = 
						CASE	
							WHEN ShipmentItem.strItemType = @SHIPMENT_ITEM_TYPE THEN 0
							ELSE 1
						END
				INNER JOIN dbo.tblICItemUOM ItemUOM	
					ON ItemUOM.intItemUOMId = ISNULL(ShipmentItem.intWeightUOMId, ShipmentItem.intItemUOMId) 
				INNER JOIN (
					SELECT	dblTotalOtherCharge = 
								-- Convert the other charge amount to functional currency. 
								SUM(
									dblCalculatedAmount
									--* CASE WHEN ISNULL(Charge.dblForexRate, 0) = 0 AND ISNULL(Charge.intCurrencyId, @intFunctionalCurrencyId) = @intFunctionalCurrencyId THEN 1 ELSE Charge.dblForexRate END 
								)								
							,CalculatedCharge.ysnAccrue
							,CalculatedCharge.intEntityVendorId
							,CalculatedCharge.intInventoryShipmentId
							,CalculatedCharge.intInventoryShipmentChargeId
							,CalculatedCharge.ysnPrice
							,Charge.strChargesLink
					FROM	dbo.tblICInventoryShipmentChargePerItem CalculatedCharge INNER JOIN tblICInventoryShipmentCharge Charge
								ON CalculatedCharge.intInventoryShipmentChargeId = Charge.intInventoryShipmentChargeId	 					
					WHERE	CalculatedCharge.intInventoryShipmentId = @intInventoryShipmentId
							AND CalculatedCharge.strAllocatePriceBy = @ALLOCATE_PRICE_BY_Unit
							AND CalculatedCharge.intContractId IS NULL 
					GROUP BY 
						CalculatedCharge.ysnAccrue
						,CalculatedCharge.intEntityVendorId
						,CalculatedCharge.intInventoryShipmentId
						,CalculatedCharge.intInventoryShipmentChargeId
						,CalculatedCharge.ysnPrice
						,Charge.strChargesLink
				) CalculatedCharges 
					ON ShipmentItem.intInventoryShipmentId = CalculatedCharges.intInventoryShipmentId
				LEFT JOIN (
							SELECT	dblTotalUnits = SUM(ISNULL(ShipmentItem.dblQuantity, 0))
									,ShipmentItem.intInventoryShipmentId 
									,ShipmentItem.strChargesLink 
					FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem
								ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
							INNER JOIN dbo.tblICItem Item 
								ON Item.intItemId = ShipmentItem.intItemId
								-- Do not include Kit Components when calculating the other charges. 
								AND 1 = 
									CASE	
										WHEN ShipmentItem.strItemType = @SHIPMENT_ITEM_TYPE THEN 0
										ELSE 1
									END
							INNER JOIN dbo.tblICItemUOM ItemUOM
								ON ItemUOM.intItemUOMId = ISNULL(ShipmentItem.intWeightUOMId, ShipmentItem.intItemUOMId) 
					WHERE	Shipment.intInventoryShipmentId = @intInventoryShipmentId
					GROUP BY ShipmentItem.intInventoryShipmentId, ShipmentItem.strChargesLink
				) TotalUnitsOfItemsPerContract 
					ON TotalUnitsOfItemsPerContract.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId 
					AND ISNULL(TotalUnitsOfItemsPerContract.strChargesLink, '') = ISNULL(ShipmentItem.strChargesLink, '')
	) AS Source_Query  
		ON ShipmentItemAllocatedCharge.intInventoryShipmentId = Source_Query.intInventoryShipmentId
		AND ShipmentItemAllocatedCharge.intEntityVendorId = Source_Query.intEntityVendorId
		AND ShipmentItemAllocatedCharge.ysnAccrue = Source_Query.ysnAccrue
		AND ShipmentItemAllocatedCharge.ysnPrice = Source_Query.ysnPrice
		AND ISNULL(ShipmentItemAllocatedCharge.strChargesLink, '') = ISNULL(Source_Query.strChargesLink, '')

	-- Add the other charge to an existing allocation. 
	WHEN MATCHED AND ISNULL(Source_Query.dblTotalUnits, 0) <> 0 THEN 
		UPDATE 
		SET		dblAmount = ROUND (
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
			[intInventoryShipmentId]
			,[intInventoryShipmentChargeId]
			,[intInventoryShipmentItemId]
			,[intEntityVendorId]
			,[dblAmount]
			,[ysnAccrue]
			,[ysnPrice]
			,[strChargesLink]
		)
		VALUES (
			Source_Query.intInventoryShipmentId
			,Source_Query.intInventoryShipmentChargeId
			,Source_Query.intInventoryShipmentItemId
			,Source_Query.intEntityVendorId
			,ROUND (
				Source_Query.dblTotalOtherCharge
				* Source_Query.Qty
				/ Source_Query.dblTotalUnits 
				, 2
			)
			,Source_Query.ysnAccrue 
			,Source_Query.ysnPrice
			,Source_Query.strChargesLink
		)
	;
END 

-- Fix any decimal discrepancy 
BEGIN 
	UPDATE	fixDiscrepancy
	SET
		fixDiscrepancy.dblAmount += (sc.dblAmount - a.dblTotal) 
	FROM	
		tblICInventoryShipment s INNER JOIN tblICInventoryShipmentCharge sc
			ON s.intInventoryShipmentId = sc.intInventoryShipmentId	
		CROSS APPLY (
			SELECT 
				dblTotal = SUM(a.dblAmount)
			FROM
				tblICInventoryShipmentItemAllocatedCharge a
			WHERE 
				a.intInventoryShipmentId = s.intInventoryShipmentId
				AND a.intInventoryShipmentChargeId = sc.intInventoryShipmentChargeId
		) a
		CROSS APPLY (
			SELECT TOP 1 
				discrepancy.intInventoryShipmentItemAllocatedChargeId
			FROM
				tblICInventoryShipmentItemAllocatedCharge discrepancy
			WHERE 
				discrepancy.intInventoryShipmentId = s.intInventoryShipmentId
				AND discrepancy.intInventoryShipmentChargeId = sc.intInventoryShipmentChargeId
			ORDER BY 
				discrepancy.intInventoryShipmentItemId DESC
		) findDiscrepancy
		INNER JOIN tblICInventoryShipmentItemAllocatedCharge fixDiscrepancy
			ON fixDiscrepancy.intInventoryShipmentItemAllocatedChargeId = findDiscrepancy.intInventoryShipmentItemAllocatedChargeId
	WHERE 
		s.intInventoryShipmentId = @intInventoryShipmentId
		AND (sc.dblAmount - a.dblTotal) <> 0 
		AND (sc.dblAmount - a.dblTotal) BETWEEN -1 AND 1 -- Limit the fix on decimal discrepancies. 
END 

_Exit: