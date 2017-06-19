CREATE PROCEDURE [dbo].[uspICCalculateInventoryShipmentOtherCharges]
	@intInventoryShipmentId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Declare the variables
BEGIN
	-- Constants
	DECLARE @COST_METHOD_PER_UNIT AS NVARCHAR(50) = 'Per Unit'
			,@COST_METHOD_PERCENTAGE AS NVARCHAR(50) = 'Percentage'
			,@COST_METHOD_AMOUNT AS NVARCHAR(50) = 'Amount'

			,@INVENTORY_SHIPMENT_TYPE AS INT = 4
			,@STARTING_NUMBER_BATCH AS INT = 3  
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'AP Clearing'
		
			,@OWNERSHIP_TYPE_Own AS INT = 1
			,@OWNERSHIP_TYPE_Storage AS INT = 2
			,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
			,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

	DECLARE @strItemNo AS NVARCHAR(50)
			,@strUnitMeasure AS NVARCHAR(50)
			,@intItemId AS INT
			,@strOtherCharge AS NVARCHAR(50)
END 


-- Do the validation
BEGIN 
	-- Check if there are shipment charges to process
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblICInventoryShipmentCharge WHERE intInventoryShipmentId = @intInventoryShipmentId)
	BEGIN
		-- Exit and do nothing. 
		GOTO _Exit
	END
END

-- Clear any existing records in the tblICInventoryShipmentChargePerItem table
BEGIN 
	DELETE tblICInventoryShipmentChargePerItem
	WHERE intInventoryShipmentId = @intInventoryShipmentId
END 

-- Get the default currency ID
DECLARE @intFunctionalCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

-- Calculate the cost method for "Per Unit"
BEGIN 
	INSERT INTO dbo.tblICInventoryShipmentChargePerItem (
			[intInventoryShipmentId]
			,[intInventoryShipmentChargeId] 
			,[intInventoryShipmentItemId] 
			,[intChargeId] 
			,[intEntityVendorId] 
			,[dblCalculatedAmount]
			,[intContractId]
			,[intContractDetailId]
			,[strAllocatePriceBy]
			,[ysnAccrue]
			,[ysnPrice]
	)
	SELECT	[intInventoryShipmentId]		= ShipmentItem.intInventoryShipmentId
			,[intInventoryShipmentChargeId]	= Charge.intInventoryShipmentChargeId
			,[intInventoryShipmentItemId]	= ShipmentItem.intInventoryShipmentItemId
			,[intChargeId]					= Charge.intChargeId
			,[intEntityVendorId]			= Charge.intEntityVendorId
			,[dblCalculatedAmount]			= ROUND (			
												Charge.dblRate 
												* dbo.fnCalculateQtyBetweenUOM(
													ShipmentItem.intItemUOMId
													, dbo.fnGetMatchingItemUOMId(ShipmentItem.intItemId, Charge.intCostUOMId)
													, ISNULL(ShipmentItem.dblQuantity, 0) 
												)
												, 2
											 )
			,[intContractId]				= Charge.intContractId
			,[intContractDetailId]			= Charge.intContractDetailId
			,[strAllocatePriceBy]			= Charge.strAllocatePriceBy
			,[ysnAccrue]					= Charge.ysnAccrue
			,[ysnPrice]						= Charge.ysnPrice
	FROM	tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem 
				ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
			INNER JOIN dbo.tblICInventoryShipmentCharge Charge	
				ON ShipmentItem.intInventoryShipmentId = Charge.intInventoryShipmentId
			INNER JOIN dbo.tblICItem Item 
				ON Item.intItemId = Charge.intChargeId		
	WHERE	ShipmentItem.intInventoryShipmentId = @intInventoryShipmentId
			AND Charge.strCostMethod = @COST_METHOD_PER_UNIT
			AND 
			(
				1 =
				CASE	WHEN 
							Shipment.intOrderType = 1 -- Sales Contract 
							AND Charge.intContractId IS NULL 
							AND ShipmentItem.intOrderId IS NULL 
						THEN 
							1
						
						WHEN 
							Shipment.intOrderType = 1 -- Sales Contract 
							AND Charge.intContractId IS NOT NULL 
							AND ShipmentItem.intOrderId = Charge.intContractId
							AND ShipmentItem.intLineNo = Charge.intContractDetailId
						THEN 
							1
						
						WHEN 
							ISNULL(Shipment.intOrderType, 1) <> 1 
							AND Charge.intContractId IS NULL 
						THEN 
							1
						
						ELSE 
							0
				END 				
			)
			AND Item.intOnCostTypeId IS NULL 
			AND ISNULL(ShipmentItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own

	-- Check if the calculated values are valid. 
	BEGIN 
		SET @intItemId = NULL 

		SELECT	TOP 1 
				@strItemNo = Item.strItemNo
				,@strUnitMeasure = UOM.strUnitMeasure
				,@intItemId = Item.intItemId
				,@strOtherCharge = ItemOtherCharge.strItemNo
		FROM	dbo.tblICInventoryShipmentChargePerItem ChargePerItem INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem
					ON ChargePerItem.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId		
				INNER JOIN dbo.tblICInventoryShipmentCharge Charge	
					ON Charge.intInventoryShipmentChargeId = ChargePerItem.intInventoryShipmentChargeId
				LEFT JOIN tblICItem Item
					ON Item.intItemId = ShipmentItem.intItemId					
				LEFT JOIN tblICItemUOM ChargeUOM
					ON ChargeUOM.intItemUOMId = Charge.intCostUOMId
				LEFT JOIN tblICUnitMeasure UOM
					ON UOM.intUnitMeasureId = ChargeUOM.intUnitMeasureId
				--For Other Charge
				LEFT JOIN tblICItem ItemOtherCharge
					ON ItemOtherCharge.intItemId = ChargePerItem.intChargeId
		WHERE	ChargePerItem.intInventoryShipmentId = @intInventoryShipmentId 
				AND ChargePerItem.dblCalculatedAmount IS NULL

		IF @intItemId IS NOT NULL 
		BEGIN 
			-- 'Unable to calculate {Other Charge Item} as {Unit of Measure} is not found in {Item} > UOM setup.'
			EXEC uspICRaiseError 80050, @strOtherCharge, @strUnitMeasure, @strItemNo;
			GOTO _Exit
		END 
	END 
END 

-- Calculate the cost method for "Percentage"
BEGIN 
	INSERT INTO dbo.tblICInventoryShipmentChargePerItem (
			[intInventoryShipmentId]
			,[intInventoryShipmentChargeId] 
			,[intInventoryShipmentItemId] 
			,[intChargeId] 
			,[intEntityVendorId] 
			,[dblCalculatedAmount] 
			,[intContractId]
			,[intContractDetailId]
			,[strAllocatePriceBy]
			,[ysnAccrue]
			,[ysnPrice]
	)
	SELECT	[intInventoryShipmentId]			= ShipmentItem.intInventoryShipmentId
			,[intInventoryShipmentChargeId]	= Charge.intInventoryShipmentChargeId
			,[intInventoryShipmentItemId]	= ShipmentItem.intInventoryShipmentItemId
			,[intChargeId]					= Charge.intChargeId
			,[intEntityVendorId]			= Charge.intEntityVendorId
			,[dblCalculatedAmount]			= 
											ROUND (
												(ISNULL(Charge.dblRate, 0) / 100)
												*	ISNULL(ShipmentItem.dblQuantity, 0) 
												*	CASE 
														WHEN ISNULL(Shipment.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(ShipmentItem.dblForexRate, 0) <> 0 THEN 
															-- Convert the foreign price to transaction currency. 
															ISNULL(ShipmentItem.dblUnitPrice, 0) * ISNULL(ShipmentItem.dblForexRate, 0) 
														ELSE 
															ISNULL(ShipmentItem.dblUnitPrice, 0)
													END
												* 
													-- and then convert the transaction price to the other charge currency. 
													CASE WHEN ISNULL(Charge.intCurrencyId, Shipment.intCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(Charge.dblForexRate, 0) <> 0 THEN 
															1 / Charge.dblForexRate
														ELSE 
															1
												END 
												, 2
											)

			,[intContractId]				= Charge.intContractId
			,[intContractDetailId]			= Charge.intContractDetailId
			,[strAllocatePriceBy]			= Charge.strAllocatePriceBy
			,[ysnAccrue]					= Charge.ysnAccrue
			,[ysnPrice]						= Charge.ysnPrice
	FROM	dbo.tblICInventoryShipmentItem ShipmentItem INNER JOIN dbo.tblICInventoryShipmentCharge Charge	
				ON ShipmentItem.intInventoryShipmentId = Charge.intInventoryShipmentId
			INNER JOIN dbo.tblICItem Item 
				ON Item.intItemId = Charge.intChargeId				
			INNER JOIN tblICInventoryShipment Shipment 
				ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
	WHERE	ShipmentItem.intInventoryShipmentId = @intInventoryShipmentId
			AND Charge.strCostMethod = @COST_METHOD_PERCENTAGE
			AND 
			(
				1 =
				CASE	WHEN 
							Shipment.intOrderType = 1 -- Sales Contract 
							AND Charge.intContractId IS NULL 
							AND ShipmentItem.intOrderId IS NULL 
						THEN 
							1
						
						WHEN 
							Shipment.intOrderType = 1 -- Sales Contract 
							AND Charge.intContractId IS NOT NULL 
							AND ShipmentItem.intOrderId = Charge.intContractId
							AND ShipmentItem.intLineNo = Charge.intContractDetailId
						THEN 
							1
						
						WHEN 
							ISNULL(Shipment.intOrderType, 1) <> 1 
							AND Charge.intContractId IS NULL 
						THEN 
							1
						
						ELSE 
							0
				END 				
			)
			AND Item.intOnCostTypeId IS NULL 
			AND ISNULL(ShipmentItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
END 

-- Calculate the cost method for "Amount" or Fixed Amount. 
BEGIN 
	INSERT INTO dbo.tblICInventoryShipmentChargePerItem (
			[intInventoryShipmentId]
			,[intInventoryShipmentChargeId] 
			,[intInventoryShipmentItemId] 
			,[intChargeId] 
			,[intEntityVendorId] 
			,[dblCalculatedAmount] 
			,[intContractId]
			,[intContractDetailId]
			,[strAllocatePriceBy]
			,[ysnAccrue]
			,[ysnPrice]
	)
	SELECT	[intInventoryShipmentId]			= Shipment.intInventoryShipmentId
			,[intInventoryShipmentChargeId]	= Charge.intInventoryShipmentChargeId
			,[intInventoryShipmentItemId]	= NULL 
			,[intChargeId]					= Charge.intChargeId
			,[intEntityVendorId]			= Charge.intEntityVendorId
			,[dblCalculatedAmount]			= ROUND(Charge.dblAmount, 2)
			,[intContractId]				= Charge.intContractId
			,[intContractDetailId]			= Charge.intContractDetailId
			,[strAllocatePriceBy]			= Charge.strAllocatePriceBy
			,[ysnAccrue]					= Charge.ysnAccrue
			,[ysnPrice]						= Charge.ysnPrice
	FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge Charge	
				ON Shipment.intInventoryShipmentId = Charge.intInventoryShipmentId
			INNER JOIN dbo.tblICItem Item 
				ON Item.intItemId = Charge.intChargeId				
	WHERE	Shipment.intInventoryShipmentId = @intInventoryShipmentId
			AND Charge.strCostMethod = @COST_METHOD_AMOUNT
			AND Item.intOnCostTypeId IS NULL 			
END 

-- Update the Other Charge amounts
-- Also, the sub-currency amounts must be converted back to the currency amounts.
BEGIN 
	UPDATE	Charge
	SET		dblAmount =  ROUND(	
							ISNULL(CalculatedCharges.dblAmount, 0)
							/ 
							CASE	WHEN Charge.ysnSubCurrency = 1 THEN 
										CASE WHEN ISNULL(Charge.intCent, 1) <> 0 THEN ISNULL(Charge.intCent, 1) ELSE 1 END 
									ELSE 
										1
							END 
						, 2)						

	FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge Charge 	
				ON Shipment.intInventoryShipmentId = Charge.intInventoryShipmentId
			INNER JOIN dbo.tblICItem Item 
				ON Item.intItemId = Charge.intChargeId		
			LEFT JOIN (
					SELECT	dblAmount = SUM(dblCalculatedAmount)
							,intInventoryShipmentChargeId
					FROM	dbo.tblICInventoryShipmentChargePerItem
					WHERE	intInventoryShipmentId = @intInventoryShipmentId
					GROUP BY intInventoryShipmentChargeId
			) CalculatedCharges
				ON CalculatedCharges.intInventoryShipmentChargeId = Charge.intInventoryShipmentChargeId
	WHERE	Shipment.intInventoryShipmentId = @intInventoryShipmentId
			AND Item.intOnCostTypeId IS NULL
			AND Charge.strCostMethod <> @COST_METHOD_AMOUNT
END 

-- Exit point
_Exit: