CREATE PROCEDURE [dbo].[uspICAllocateInventoryShipmentOtherChargesByContractAndStockUnit]
	@intInventoryShipmentId AS INT
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

		,@ALLOCATE_PRICE_BY_Unit AS NVARCHAR(50) = 'Unit'
		,@ALLOCATE_PRICE_BY_Stock_Unit AS NVARCHAR(50) = 'Stock Unit'
		,@ALLOCATE_PRICE_BY_Weight AS NVARCHAR(50) = 'Weight'
		,@ALLOCATE_PRICE_BY_Price AS NVARCHAR(50) = 'Price'

		,@UNIT_TYPE_Weight AS NVARCHAR(50) = 'Weight'

		,@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2
		,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
		,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

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

-- Allocate price by 'Stock Unit' and by Contract and cost methods used are 'Per Unit' and 'Percentage' 
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
				,dblUnitQty = ISNULL(ShipmentItem.dblQuantity, 0)
				,TotalStockUnitOfItemsPerContract.dblTotalStockUnit 
		FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem
					ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
					AND Shipment.intInventoryShipmentId = @intInventoryShipmentId
					AND Shipment.intOrderType = @SHIPMENT_TYPE_SalesContract
					AND ShipmentItem.intOrderId IS NOT NULL 
					AND ISNULL(ShipmentItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
				INNER JOIN (
					SELECT	dblTotalOtherCharge = 
								-- Convert the other charge amount to functional currency. 
								SUM(
									dblCalculatedAmount
									--* CASE WHEN ISNULL(Charge.dblForexRate, 0) = 0 AND ISNULL(Charge.intCurrencyId, @intFunctionalCurrencyId) = @intFunctionalCurrencyId THEN 1 ELSE Charge.dblForexRate END 
								)
							,CalculatedCharge.ysnAccrue 
							,CalculatedCharge.intContractId
							,CalculatedCharge.intContractDetailId
							,CalculatedCharge.intEntityVendorId
							,CalculatedCharge.intInventoryShipmentId
							,CalculatedCharge.intInventoryShipmentChargeId
							,CalculatedCharge.ysnPrice
							,Charge.strChargesLink
					FROM	dbo.tblICInventoryShipmentChargePerItem CalculatedCharge INNER JOIN tblICInventoryShipmentCharge Charge
								ON CalculatedCharge.intInventoryShipmentChargeId = Charge.intInventoryShipmentChargeId	
					WHERE	CalculatedCharge.intInventoryShipmentId = @intInventoryShipmentId
							AND CalculatedCharge.strAllocatePriceBy = @ALLOCATE_PRICE_BY_Stock_Unit
							AND CalculatedCharge.intContractId IS NOT NULL 
					GROUP BY 
						CalculatedCharge.ysnAccrue
						,CalculatedCharge.intContractId
						,CalculatedCharge.intContractDetailId
						,CalculatedCharge.intEntityVendorId
						,CalculatedCharge.intInventoryShipmentId
						,CalculatedCharge.intInventoryShipmentChargeId
						,CalculatedCharge.ysnPrice
						,Charge.strChargesLink
				) CalculatedCharges 
					ON ShipmentItem.intOrderId = CalculatedCharges.intContractId
					AND CalculatedCharges.intContractDetailId = ShipmentItem.intLineNo
					AND (
						ISNULL(CalculatedCharges.strChargesLink, '') = ISNULL(ShipmentItem.strChargesLink, '')
					)				
				LEFT JOIN (
					SELECT  dblTotalStockUnit = SUM(dbo.fnCalculateStockUnitQty(ShipmentItem.dblQuantity, ItemUOM.dblUnitQty))
							,ShipmentItem.intOrderId 
							,ShipmentItem.intLineNo
							,ShipmentItem.strChargesLink
					FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem 
								ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId	
								AND Shipment.intOrderType = @SHIPMENT_TYPE_SalesContract
							INNER JOIN dbo.tblICItemUOM ItemUOM
								ON ItemUOM.intItemUOMId = ShipmentItem.intItemUOMId
							LEFT JOIN  dbo.tblICItemUOM GrossNetUOM
								ON GrossNetUOM.intItemUOMId = ShipmentItem.intWeightUOMId
					WHERE	Shipment.intInventoryShipmentId = @intInventoryShipmentId
							AND ShipmentItem.intOrderId IS NOT NULL 
					GROUP BY ShipmentItem.intOrderId, ShipmentItem.intLineNo, ShipmentItem.strChargesLink
				) TotalStockUnitOfItemsPerContract 
					ON TotalStockUnitOfItemsPerContract.intOrderId = ShipmentItem.intOrderId 
					AND CalculatedCharges.intContractDetailId = ShipmentItem.intLineNo
					AND (
						ISNULL(TotalStockUnitOfItemsPerContract.strChargesLink, '') = ISNULL(ShipmentItem.strChargesLink, '')
					)

				LEFT JOIN dbo.tblICItemUOM ItemUOM	
					ON ItemUOM.intItemUOMId = ShipmentItem.intItemUOMId 
				LEFT JOIN dbo.tblICItemUOM GrossNetUOM
					ON GrossNetUOM.intItemUOMId = ShipmentItem.intWeightUOMId


	) AS Source_Query  
		ON ShipmentItemAllocatedCharge.intInventoryShipmentId = Source_Query.intInventoryShipmentId
		AND ShipmentItemAllocatedCharge.intEntityVendorId = Source_Query.intEntityVendorId
		AND ShipmentItemAllocatedCharge.ysnAccrue = Source_Query.ysnAccrue
		AND ShipmentItemAllocatedCharge.ysnPrice = Source_Query.ysnPrice

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

	-- Create a new allocation record for the item. 
	WHEN NOT MATCHED AND ISNULL(Source_Query.dblTotalStockUnit, 0) <> 0 THEN 
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