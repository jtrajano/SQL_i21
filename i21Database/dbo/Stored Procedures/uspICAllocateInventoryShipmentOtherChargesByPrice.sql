CREATE PROCEDURE [dbo].[uspICAllocateInventoryShipmentOtherChargesByPrice]
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
			@SHIPMENT_TYPE_Sales_Contract AS INT = 1 -- Sales Contract
			,@SHIPMENT_TYPE_Sales_Order AS INT = 2 -- Sales Order
			,@SHIPMENT_TYPE_Transfer_Order AS INT = 3 -- Transfer Order
			,@SHIPMENT_TYPE_Direct AS INT = 4 -- Direct
			-- Source Types
			,@SOURCE_TYPE_None AS INT = 0
			,@SOURCE_TYPE_Scale AS INT = 1
			,@SOURCE_TYPE_Inbound_Shipment AS INT = 2
			,@SOURCE_TYPE_PickLot AS INT = 3

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END

-- Allocate price by 'Price' regardless if there are contracts and cost methods used are 'Per Unit' and 'Percentage' 
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
				,ShipmentItem.dblUnitPrice 
				,TotalCostOfItemsPerContract.dblTotalCost 
		FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem
					ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
					AND Shipment.intInventoryShipmentId = @intInventoryShipmentId
					AND 1 = CASE WHEN Shipment.intOrderType = @SHIPMENT_TYPE_Sales_Contract AND ShipmentItem.intOrderId IS NULL THEN 1
								 WHEN Shipment.intOrderType <> @SHIPMENT_TYPE_Sales_Contract THEN 1
								 ELSE 0
							END 					
					AND ISNULL(ShipmentItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
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
					FROM	dbo.tblICInventoryShipmentChargePerItem CalculatedCharge INNER JOIN tblICInventoryShipmentCharge Charge
								ON CalculatedCharge.intInventoryShipmentChargeId = Charge.intInventoryShipmentChargeId					
					WHERE	CalculatedCharge.intInventoryShipmentId = @intInventoryShipmentId
							AND CalculatedCharge.strAllocatePriceBy = @ALLOCATE_PRICE_BY_Price
							AND CalculatedCharge.intContractId IS NULL 
					GROUP BY 
						CalculatedCharge.ysnAccrue
						, CalculatedCharge.intEntityVendorId
						, CalculatedCharge.intInventoryShipmentId
						, CalculatedCharge.intInventoryShipmentChargeId
						, CalculatedCharge.ysnPrice
				) CalculatedCharges 
					ON ShipmentItem.intInventoryShipmentId = CalculatedCharges.intInventoryShipmentId
				LEFT JOIN (
					SELECT	dblTotalCost = SUM(dbo.fnMultiply(ISNULL(ShipmentItem.dblQuantity, 0), ISNULL(ShipmentItem.dblUnitPrice, 0)))
							,ShipmentItem.intInventoryShipmentId 
					FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem
								ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
					WHERE	Shipment.intInventoryShipmentId = @intInventoryShipmentId
					GROUP BY ShipmentItem.intInventoryShipmentId 
				) TotalCostOfItemsPerContract 
					ON TotalCostOfItemsPerContract.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId 
	) AS Source_Query  
		ON ShipmentItemAllocatedCharge.intInventoryShipmentId = Source_Query.intInventoryShipmentId
		AND ShipmentItemAllocatedCharge.ysnAccrue = Source_Query.ysnAccrue	
		AND ShipmentItemAllocatedCharge.ysnPrice = Source_Query.ysnPrice

	-- Add the other charge to an existing allocation. 
	WHEN MATCHED AND ISNULL(Source_Query.dblTotalCost, 0) <> 0 THEN 
		UPDATE 
		SET		dblAmount = ROUND(
								ISNULL(dblAmount, 0) 
								+ (
									Source_Query.dblTotalOtherCharge
									* Source_Query.Qty 
									* Source_Query.dblUnitPrice
									/ Source_Query.dblTotalCost 
								)
								, 2
							)

	-- Create a new allocation record for the item. 
	WHEN NOT MATCHED AND ISNULL(Source_Query.dblTotalCost, 0) <> 0 THEN 
		INSERT (
			[intInventoryShipmentId]
			,[intInventoryShipmentChargeId]
			,[intInventoryShipmentItemId]
			,[intEntityVendorId]
			,[dblAmount]
			,[ysnAccrue]
			,[ysnPrice]
		)
		VALUES (
			Source_Query.intInventoryShipmentId
			,Source_Query.intInventoryShipmentChargeId
			,Source_Query.intInventoryShipmentItemId
			,Source_Query.intEntityVendorId
			,ROUND(	
				Source_Query.dblTotalOtherCharge
				* Source_Query.Qty 
				* Source_Query.dblUnitPrice
				/ Source_Query.dblTotalCost 
				, 2
			)
			,Source_Query.ysnAccrue
			,Source_Query.ysnPrice
		)
	;
END 

_Exit: